#' Get Game Data
#'
#' Request game data from one of the geek sites.
#'
#' @param id A vector of game id numbers.
#' @param domain One of `"boardgame"`, `"rpg"` or `"videogame"`. Determines
#'   which domain the request will go to. Defaults to `"boardgame"`.
#' @param data What kinds of data to retrieve (besides basic info). See
#'   [API2 documentation](https://boardgamegeek.com/wiki/page/BGG_XML_API2#toc3)
#'   for details.
#' @param silent Whether to print the URL on request.
#'
#' @return An xml2 nodeset of class "geek_item"
#'
#' @importFrom magrittr %>%
#'
#' @export
get_game = function(id, domain = c("boardgame", "rpg", "videogame"),
                    data = c("stats", "versions", "historical", "marketplace",
                             "comments", "ratingcomments", "videos"),
                    silent = TRUE) {

  domain = match.arg(domain, several.ok = FALSE)

  dom_nm = c(boardgame = "https://www.boardgamegeek.com",
             rpg       = "https://rpggeek.com",
             videogame = "https://videogamegeek.com")[domain]

  data = match.arg(data, several.ok = FALSE)

  url = httr::modify_url(
    url = dom_nm,
    path = "/xmlapi2/thing",
    query = c(pagesize = 100, id = paste(id, collapse = ","),
              stats::setNames(list(1), nm = data)))

  if (!silent) message("Fetching URL: ", url)

  res = httr::GET(url)

  httr::stop_for_status(res)

  xml = res %>%
    httr::content() %>%
    xml2::xml_children()

  structure(xml, class = c("geek_item", class(xml)), domain = dom_nm)

}

#' @export
print.geek_item = function(x, ...) {

  cat("<geek_item>")
  cat("\n Games:", length(x))
  cat("\n Domain:", attr(x, "domain"))
  cat("\n Data: XML nodeset (xml2)")

}
