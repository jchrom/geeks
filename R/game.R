#' Geek Game Data
#'
#' A collection of functions to deal with geek items, produced by [get_game()].
#'
#' @details
#'
#' Most functions in this family parse game data and return tibbles (data
#' frames). `is_geek_item()` returns TRUE if an object is produced by [get_game()]
#' and contains game data. `as_xml_nodeset` strips the `"geek_item"` class.
#'
#' @param xml A xml nodeset of class `geek_item`.
#' @param x An object to be tested or converted to an xml nodeset.
#'
#' @return A tibble (data frame)
#'
#' @name geek_item
NULL

#' @rdname geek_item
#' @export
game_info = function(xml) {
  UseMethod("game_info")
}

#' @rdname geek_item
#' @export
game_altnames = function(xml) {
  UseMethod("game_altnames")
}

#' @rdname geek_item
#' @export
game_numplayers = function(xml) {
  UseMethod("game_numplayers")
}

#' @rdname geek_item
#' @export
game_playerage = function(xml) {
  UseMethod("game_playerage")
}

#' @rdname geek_item
#' @export
game_language = function(xml) {
  UseMethod("game_language")
}

#' @rdname geek_item
#' @export
game_stats = function(xml) {
  UseMethod("game_stats")
}

#' @rdname geek_item
#' @export
game_links = function(xml) {
  UseMethod("game_links")
}

#' @rdname geek_item
#' @export
as_xml_nodeset = function(x) {
  UseMethod("as_xml_nodeset")
}

#' @rdname geek_item
#' @export
is_geek_item = function(x) {
  if (inherits(x, "geek_item")) TRUE else FALSE
}

#' @export
game_info.geek_item = function(xml) {

  node_attr = switch(
    names(attr(xml, "domain")),
    boardgame = c("name", "yearpublished", "description", "minage",
                  "minplayers", "maxplayers", "playingtime",
                  "minplaytime", "maxplaytime", "image"),
    rpg = c("name", "description", "yearpublished", "seriescode"),
    videogame = c("name", "description", "minplayers", "maxplayers",
                  "releasedate"),
    stop('Domain must be one of "boardgame", "rpg", "videogame"',
         call. = FALSE)
  )

  xml_value = function(xml, attr) {

    # Produce data frames with an ID column, identifying the parent item. This
    # is useful to ensure value/text will always be tied to the right game.

    node = xml_child(xml, attr)

    if (any(xml_has_attr(node, "value"))) {
      value = xml_attr(node, "value")
    } else {
      value = xml_text(node)
    }

    stats::setNames(
      tibble::tibble(id = game_item_id(node), value = value),
      nm = c("id", attr))
  }

  game_item_id = function(xml) {
    xml %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id")
  }

  node_attr %>%
    lapply(xml_value, xml = xml) %>%
    Reduce(merge, x = .) %>%
    utils::type.convert(as.is = TRUE) %>%
    tibble::as_tibble()

}

#' @export
game_altnames.geek_item = function(xml) {

  node_name = xml_find_all(xml, "name")

  tibble::tibble(
    id = node_name %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    altname = xml_attr(node_name, "value"),
    type = xml_attr(node_name, "type")) %>%
    utils::type.convert(as.is = TRUE)

}

#' @export
game_numplayers.geek_item = function(xml) {

  if (names(attr(xml, "domain")) != "boardgame") {
    warning('Data on recommended number of players is only available for boardgames',
            call. = FALSE)
    return()
  }

  node = xml_find_all(xml, "poll[@name='suggested_numplayers']/results/result")

  long = data.frame(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    numplayers = node %>%
      xml_find_first("./parent::results") %>%
      xml_attr("numplayers"),
    name = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes"),
    stringsAsFactors = FALSE) %>%
    utils::type.convert(as.is = TRUE)

  long %>%
    stats::reshape(v.names = "votes", idvar = c("id", "numplayers"),
                   timevar = c("name"),
                   direction = "wide") %>%
    stats::setNames(nm = gsub("^[^\\.]+\\.", "", x = names(.))) %>%
    tibble::as_tibble()

}

#' @export
game_playerage.geek_item = function(xml) {

  if (names(attr(xml, "domain")) != "boardgame") {
    warning("Data on recommended player age is only available for boardgames",
            call. = FALSE)
    return()
  }

  node = xml_find_all(xml, "poll[@name='suggested_playerage']/results/result")

  tibble::tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    playerage = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes")) %>%
    utils::type.convert(as.is = TRUE)

}

#' @export
game_language.geek_item = function(xml) {

  if (names(attr(xml, "domain")) != "boardgame") {
    warning("Language dependency data is only available for boardgames",
            call. = FALSE)
    return()
  }

  node = xml_find_all(xml, "poll[@name='language_dependence']/results/result")

  tibble::tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    langlevel = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes")) %>%
    utils::type.convert(as.is = TRUE)

}

#' @export
game_stats.geek_item = function(xml) {

  stats = xml %>%
    xml_find_all("statistics") %>%
    xml_children()

  extract_value = function(xml, what) {
    xml %>%
      xml_find_all(what) %>%
      xml_attr("value")
  }

  statistics = c("usersrated", "average", "bayesaverage", "stddev",
                 "median", "owned", "trading", "wanting", "wishing",
                 "numcomments", "numweights", "averageweight")

  stats::setNames(nm = statistics) %>%
    lapply(extract_value, xml = stats) %>%
    tibble::as_tibble() %>%
    tibble::add_column(id = xml_attr(xml, "id"), .before = 1) %>%
    utils::type.convert(as.is = TRUE)

}

#' @export
game_links.geek_item = function(xml) {

  links = xml_find_all(xml, "link")

  tibble::tibble(
    id = links %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    link_id   = xml_attr(links, "id"),
    link_type = xml_attr(links, "type"),
    link_name = xml_attr(links, "value")) %>%
    utils::type.convert(as.is = TRUE)

}

#' @export
as_xml_nodeset.geek_item = function(x) {
  structure(x, class = "xml_nodeset")
}
