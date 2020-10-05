#' Get Game Data
#'
#' Request data about a game from a geek site.
#'
#' @param id A vector of game id numbers.
#'
#' @param additional_data One or multiple of `"stats"`, `"versions"`,
#'   `"marketplace"`, `"videos"`, `"comments"`, `"ratingcomments"`.
#'
#'   **Note.** The API will not return both `comments` and `ratingcomments`
#'   in the same call. If you request both, you will only get `comments`.
#'
#' @param output Decide the amount of processing for the response:
#'
#'   * `"tidy"` returns a list of data frames.
#'   * `"xml"` returns a list of XML documents, as read by [xml2::read_xml].
#'     This is useful if you wish to process the XML data in your own way.
#'   * `"response"` returns an unprocessed [httr::response] object for debugging.
#'     This option prevents paging from happening, so you will only get a single
#'     page.
#'
#' @param page Page number from which to start paging. Defaults to `1`.
#'
#' @param silent Whether to print the URL on request. Defaults to `FALSE`.
#'
#' @return See the value of `output`.
#'
#' @export
#'
#' @examples
#'
#' # You don't really need to name the vector, but it makes things clearer.
#' ids = c(gloomhaven = 174430, agricola = 31260, junkart = 193042)
#' res = get_game(ids, additional_data = "stats")
#' res

get_game = function(id,
                    additional_data = NULL,
                    output = c("tidy", "xml", "response"),
                    page = 1,
                    silent = TRUE) {

  output = match.arg(output, several.ok = FALSE)

  wanted = match.arg(
    additional_data,
    choices = c("stats", "versions", "marketplace",
                "videos", "comments",
                "ratingcomments"),
    several.ok = TRUE)

  if (all(c("comments", "ratingcomments") %in% wanted)) {

    # This is a limitation of the API.
    warning("Cannot retrieve 'comments' and 'ratingcomments' in one request. ",
            "Request will return 'comments' only.",
            call. = FALSE)

    # Ensure there is either only 'comments' if both exist.
    wanted = setdiff(wanted, "ratingcomments")

  }

  params = list()

  params[wanted] = 1L # the API requires format to be 'something=1'

  res = api2_get_game(id = id, params = params, page = page, silent = silent)

  # Paging does not happen when output='response' so no need to continue.
  if (identical(output, "response")) return(res)

  # Both remaining types of output ('xml' or 'tidy') require this step first.
  xml = res %>%
    httr::content() %>%
    xml2::xml_contents()

  # Update `params` for paging, ie. for 'comments' and 'ratingcomments'. The API
  # advertises "historical" info to be available as well but it does not seem
  # to work as of 2020-09-19.

  params = Filter(length, params[c("comments", "ratingcomments")])

  # If none of these two components are present, there is no need to continue.

  if (!length(params) & identical(output, "xml")) {
    return(xml)
  }

  if (!length(params) & identical(output, "tidy")) {
    return(structure(tidy_game_data(xml), class = c("geek_item")))
  }

  # The presence of 'comments' and 'ratingcomments' means paging is required.

  pages = list()

  page1 = xml # so we don't lose this during the repeat loop

  repeat {

    # If the page length for given game is less than 100 it indicates that there
    # are no more comments to fetch. If it is exactly 100, there may be more
    # results, so that game's id is returned and included in the next request.

    next_ids = has_full_page(xml)

    if (!length(next_ids)) break

    page = page + 1

    res = api2_get_game(id = next_ids, params = params, page = page,
                        silent = silent)

    xml = res %>%
      httr::content() %>%
      xml2::xml_contents()

    pages = append(pages, xml)

  }

  if (identical(output, "xml")) {

    pages = lapply(
      setNames(pages, nm = vapply(pages, xml_attr, "", "id")),
      FUN = xml_find_all, "comments")

    return(list(page1 = page1, comments = pages))

  }

  tidy = tidy_game_data(page1)

  pages = pages %>%
    lapply(game_comments) %>%
    do.call(what = rbind) %>%
    tibble::as_tibble()

  tidy[[names(params)]] = rbind(tidy[[names(params)]], pages)

  structure(tidy, class = c("geek_item"))

}

has_full_page = function(xml) {

  nodeset = xml_find_all(xml, "comments")

  id = nodeset %>%
    xml_find_first("./parent::item") %>%
    xml_attr("id")

  id[xml_length(nodeset) == 100]

}

api2_get_game = function(id, params, page = 1,
                         output = c("tidy", "xml", "response"),
                         silent = TRUE) {

  # The domains are interchangeable, and item id is unique across all of them.
  # This means that the same domain can be used to retrieve data from any geek
  # site.

  domain = "https://www.boardgamegeek.com"

  # The API accepts a list of ids, so multiple records can be retrieved at once.
  ids = paste(id, collapse = ",")

  url = httr::modify_url(
    url = domain,
    path = "/xmlapi2/thing",
    query = c(pagesize = 100, as.list(params), page = page, id = ids))

  if (!silent) message("Fetching URL: ", url)

  res = httr::GET(url)

  httr::stop_for_status(res)

  res

}

#' @export
print.geek_item = function(x, ...) {

  cat("<geek_item>\n ")

  str(x, max.level = 1, give.attr = FALSE)

  invisible(x)

}
