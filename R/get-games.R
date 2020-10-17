#' Get Game Data
#'
#' Request game data.
#'
#' @param id A vector of game id numbers.
#' @param add One or multiple of `"stats"`, `"versions"`, `"marketplace"`,
#'   `"videos"`, `"comments"`, `"ratingcomments"`.
#'
#'   **Note.** The API will not return both `comments` and `ratingcomments`
#'   in the same call. If you request both, you will only get `comments`.
#'
#' @param page_start Page number from which to start paging. Defaults to `1`.
#' @param page_n How many pages to fetch.
#' @param delay_s How many seconds to wait between requests. Defaults to `0.5`.
#'
#' @return A tibble. To extract the raw HTTP response, call `attr(x, "res")`.
#'
#' @export
#'
#' @examples
#'
#' # You don't really need to name the vector, but it makes things clearer.
#' ids = c(gloomhaven = 174430, agricola = 31260, junkart = 193042)
#' res = get_games(ids, add = "stats")
#' res

get_games = function(id,
                     add = c("stats", "versions", "marketplace", "videos",
                             "comments", "ratingcomments"),
                     page_start = 1,
                     page_n = 1,
                     delay_s = 0.5) {

  params = list(id = id)

  params[match.arg(add, several.ok = TRUE)] = 1

  pages_xml = get_pages(path = "thing",
                        params = params,
                        output_fn = output_games_xml,
                        page_start = page_start,
                        page_n = page_n,
                        delay_s = delay_s)

  pages_res = lapply(
    setNames(pages_xml, nm = vapply(pages_xml, attr, 1L, which = "page")),
    FUN = attr,
    which = "res")

  if (warn_for_missing(pages_xml)) {
    return(structure(tibble(), res = pages_res))
  }

  pages_tbl = lapply(list(
    output_type_tbl,
    output_info_tbl,
    output_altnames_tbl,
    output_playerage_tbl,
    output_language_tbl,
    output_stats_tbl,
    output_links_tbl),
    FUN = function(fn) fn(pages_xml[[1]]))

  if (any(grepl("comments", add))) {

    pages_tbl = append(
      pages_tbl,
      pages_xml %>%
        lapply(output_comments_tbl) %>%
        do.call(what = rbind) %>%
        .nest(group_by = "id", data_to = "comments") %>%
        list())

  }

  tbl = .reduce(pages_tbl, f = .left_join, by = "id")

  structure(tbl, res = pages_res)

}

output_games_xml = function(res) {

  xml = httr::content(res, as = "parsed")
  len = xml_length(xml)

  if (!len) {
    return(structure(xml_missing(), next_id = NULL, page = NA, res = res))
  }

  # For path "/thing" the only element that uses paging, as of 2020-10-14, are
  # comments/ratingcomments, so paging information is extracted for those.

  comms_id = xml %>%
    xml_contents() %>%
    xml_attr("id") %>%
    as.integer()

  comms_len = xml %>%
    xml_contents() %>%
    xml_find_first("comments") %>%
    xml_length()

  next_id = comms_id[comms_len == 100]

  page = xml %>%
    xml_contents() %>%
    `[[`(1) %>%
    xml_find_first("comments") %>%
    xml_attr("page") %>%
    as.integer()

  structure(xml, next_id = next_id, page = page, res = res)
}

output_type_tbl = function(xml) {

  item_xml = xml_contents(xml)

  tibble(id   = xml_attr(item_xml, "id"),
         type = xml_attr(item_xml, "type")) %>%
    type.convert(as.is = TRUE)

}

output_info_tbl = function(xml) {

  infos = c("name", "yearpublished", "description", "minage",
            "minplayers", "maxplayers", "playingtime", "minplaytime",
            "maxplaytime", "image", "seriescode", "releasedate")

  xml_value = function(xml, attr) {

    # Produce data frames with an ID column, identifying the parent item. This
    # is useful to ensure value/text will always be tied to the right game.

    node = xml_find_first(xml, attr)

    if (any(xml_has_attr(node, "value"))) {
      value = xml_attr(node, "value")
    } else {
      value = xml_text(node)
    }

    tibble(id = game_item_id(node), value = value) %>%
      setNames(nm = c("id", attr)) %>%
      na.omit()
  }

  game_item_id = function(xml) {
    xml %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id")
  }

  items_xml = xml_contents(xml)

  infos %>%
    lapply(xml_value, xml = items_xml) %>%
    .reduce(.left_join, by = "id") %>%
    convert_df(playingtime = as_minutes,
               minplaytime = as_minutes,
               maxplaytime = as_minutes,
               releasedate = as.Date) %>%
    as_tibble()

}

output_altnames_tbl = function(xml) {

  altnames_xml = xml %>%
    xml_contents() %>%
    xml_find_all("name")

  tibble(
    id = altnames_xml %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    altname = xml_attr(altnames_xml, "value"),
    type = xml_attr(altnames_xml, "type")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    .nest(group_by = "id", data_to = "altnames")

}

output_playerage_tbl = function(xml) {

  playerage_xml = xml %>%
    xml_contents() %>%
    xml_find_all("poll[@name='suggested_playerage']/results/result")

  if (!length(playerage_xml)) return()

  tibble(id = playerage_xml %>%
           xml_find_first("../../parent::item") %>%
           xml_attr("id"),
         playerage = xml_attr(playerage_xml, "value"),
         votes = xml_attr(playerage_xml, "numvotes")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    .nest(group_by = "id", data_to = "playerage")

}

output_language_tbl = function(xml) {

  language_xml = xml %>%
    xml_contents() %>%
    xml_find_all("poll[@name='language_dependence']/results/result")

  if (!length(language_xml)) return()

  lang_levels = c(
    "No necessary in-game text",
    "Some necessary text - easily memorized or small crib sheet",
    "Moderate in-game text - needs crib sheet or paste ups",
    "Extensive use of text - massive conversion needed to be playable",
    "Unplayable in another language")

  lang_labels = c("none", "some", "moderate", "extensive", "essential")

  lang_tbl = tibble(
    id = language_xml %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    langlevel = xml_attr(language_xml, "value"),
    votes = xml_attr(language_xml, "numvotes")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    transform(langlevel = factor(langlevel, levels = lang_levels,
                                 labels = lang_labels)) %>%
    as_tibble()

  .nest(lang_tbl, group_by = "id", data_to = "language")

}

output_links_tbl = function(xml) {

  links_xml = xml %>%
    xml_contents() %>%
    xml_find_all("link")

  links_tbl = tibble(
    id = links_xml %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    link_id   = xml_attr(links_xml, "id"),
    link_type = xml_attr(links_xml, "type"),
    link_name = xml_attr(links_xml, "value")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    transform(link_type = gsub("^(.+game|rpg)", "", link_type)) %>%
    as_tibble()

  links_tbl %>%
    split(.$link_type) %>%
    mapply(FUN = .nest,
           df = ., group_by = "id", data_to = names(.),
           SIMPLIFY = FALSE,
           USE.NAMES = FALSE) %>%
    .reduce(.left_join, by = "id")
}

output_stats_tbl = function(xml) {

  stats_xml = xml %>%
    xml_contents() %>%
    xml_find_all("statistics")

  if (!length(stats_xml)) return()

  stats_xml = xml_contents(stats_xml)

  extract_value = function(xml, what) {
    xml %>%
      xml_find_all(what) %>%
      xml_attr("value")
  }

  statistics = c("usersrated", "average", "bayesaverage", "stddev",
                 "median", "owned", "trading", "wanting", "wishing",
                 "numcomments", "numweights", "averageweight")

  out = setNames(nm = statistics) %>%
    lapply(extract_value, xml = stats_xml) %>%
    as_tibble() %>%
    add_column(id = xml %>%
                 xml_contents() %>%
                 xml_attr("id"),
               .before = 1) %>%
    type.convert(as.is = TRUE, na.strings = "")

  # The value of `median` returned by the API seems to always be "0" (as of
  # 2020-10-03) so it can be dropped altogether. Looks like a bug.

  out$median = NULL

  # When there are no ratings, the `average`, `averageweight` and `stddev`
  # should be considered missing (even if the API returns "0").

  out$average[out$usersrated == 0] = NA_integer_
  out$stddev[out$usersrated == 0] = NA_integer_
  out$averageweight[out$numweights == 0] = NA_integer_

  # When there are less than 30 ratings, `bayesaverage` is not calculated
  # and should be considered missing (even if the API returns "0").

  out$bayesaverage[out$usersrated < 30] = NA_integer_

  out

}

output_comments_tbl = function(xml) {

  # The node is identified as 'comments' for both comments and ratingcomments.
  comms_xml = xml %>%
    xml_contents() %>%
    xml_find_all("comments")

  if (!length(comms_xml)) return()

  comms_xml = xml_contents(comms_xml)

  page_total = comms_xml %>%
    xml_find_first("./parent::comments") %>%
    xml_attr("totalitems") %>%
    as.integer()

  tibble(
    page = sprintf("%s/%s", attr(xml, "page"), ceiling(page_total / 100)),
    id = comms_xml %>%
      xml_find_first("./../parent::item") %>%
      xml_attr("id"),
    username = xml_attr(comms_xml, "username"),
    rating = xml_attr(comms_xml, "rating"),
    text = xml_attr(comms_xml, "value")) %>%
    type.convert(as.is = TRUE, na.strings = c("", "N/A"))

  # No nesting happens here: because multiple pages are expected, nesting
  # happens when all of them are bound together.
}
