#' Get Plays Data
#'
#' Request play data.
#'
#' @param id A game id number.
#' @param page_start Starting page.
#' @param page_n How many pages to fetch.
#' @param delay_s How many seconds to wait between requests. Defaults to `0.5`.
#'
#' @return A tibble. To extract the raw HTTP response, call `attr(x, "res")`.
#' @export

get_plays = function(id, page_start = 1, page_n = 1, delay_s = 0.5) {

  pages_xml = get_pages(path = "plays",
                        params = list(id = id),
                        output_fn = output_plays_xml,
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

  pages_tbl = pages_xml %>%
    lapply(output_plays_tbl) %>%
    do.call(what = rbind)

  structure(pages_tbl, res = pages_res)

}

output_plays_xml = function(res) {

  xml = httr::content(res, as = "parsed")
  len = xml_length(xml)

  if (!len) {
    return(structure(xml_missing(), next_id = NULL, page = NA, res = res))
  }

  attr(xml, "next_id") = if (len == 100)
    xml %>%
    xml_find_first("play/item") %>%
    xml_attr("objectid") %>%
    as.integer()

  attr(xml, "res") = res

  attr(xml, "page") = as.integer(xml_attr(xml, "page"))

  xml
}

output_plays_tbl = function(xml) {

  plays = xml_find_all(xml, "play")

  if (!length(plays)) return()

  pages_total = xml %>%
    xml_attr("total") %>%
    as.integer()

  plays_tbl = plays %>%
    xml_attrs() %>%
    do.call(what = rbind) %>%
    as_tibble() %>%
    add_column(
      page = sprintf("%s/%s", attr(xml, "page"), ceiling(pages_total / 100)),
      item_name = plays %>%
        xml_find_all("item") %>%
        xml_attr("name"),
      item_id = plays %>%
        xml_find_all("item") %>%
        xml_attr("objectid"),
      .before = 1) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    convert_df(incomplete = as.logical,
               date = as.Date,
               length = as_minutes) %>%
    convert_na(length == 0,
               nowinstats == 0) %>%
    .select(page, item_id, item_name, play_id = id, user_id = userid, date,
            quantity, length, incomplete, nowinstats, location)

  players_xml = xml %>%
    xml_contents() %>%
    xml_find_all("players/player")

  if (!length(players_xml)) {
    return(add_column(
      plays_tbl, players = vector("list", length = nrow(plays_tbl))
    ))
  }

  players_tbl = players_xml %>%
    xml_attrs() %>%
    do.call(what = rbind) %>%
    as_tibble() %>%
    add_column(play_id = players_xml %>%
                 xml_find_first("./../parent::play") %>%
                 xml_attr("id"),
               .before = 1) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    convert_df(win = as.logical) %>%
    convert_na(userid == 0,
               new == 0,
               rating == 0) %>%
    .select(play_id, user_id = userid, user_name = username, player_name = name,
            startposition, team = color, score, new, rating, win) %>%
    .nest(group_by = "play_id", data_to  = "players")

  plays_tbl %>%
    .left_join(players_tbl, by = "play_id") %>%
    as_tibble()

}
