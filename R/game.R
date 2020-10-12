# See geeks.R for imports

tidy_game_data = function(xml) {

  fn = list(
    info        = game_info,
    altnames    = game_altnames,
    numplayers  = game_numplayers,
    playerage   = game_playerage,
    language    = game_language,
    links       = game_links,
    stats       = game_stats,
    versions    = game_versions,
    marketplace = game_marketplace,
    videos      = game_videos,
    comments    = game_comments)

  Filter(length, lapply(fn, function(f) f(xml)))

}

# Basic game info --------------------------------------------------------------

game_info = function(xml) {

  infos = c("name", "yearpublished", "description", "minage", "minplayers",
            "maxplayers", "playingtime", "minplaytime", "maxplaytime", "image",
            "seriescode", "releasedate")

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

  infos %>%
    lapply(xml_value, xml = xml) %>%
    Filter(f = length) %>%
    Reduce(f = function(l, r) merge(l, r, all = TRUE, by = "id")) %>%
    type.convert(as.is = TRUE) %>%
    as_tibble()

}

game_altnames = function(xml) {

  node_name = xml_find_all(xml, "name")

  tibble(
    id = node_name %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    altname = xml_attr(node_name, "value"),
    type = xml_attr(node_name, "type")) %>%
    type.convert(as.is = TRUE)

}

game_numplayers = function(xml) {

  node = xml_find_all(xml, "poll[@name='suggested_numplayers']/results/result")

  if (!length(node)) return()

  tibble(id = node %>%
           xml_find_first("../../parent::item") %>%
           xml_attr("id"),
         numplayers = node %>%
           xml_find_first("./parent::results") %>%
           xml_attr("numplayers"),
         option = xml_attr(node, "value"),
         votes = xml_attr(node, "numvotes")) %>%
    type.convert(as.is = TRUE)

}

game_playerage = function(xml) {

  node = xml_find_all(xml, "poll[@name='suggested_playerage']/results/result")

  if (!length(node)) return()

  tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    playerage = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes")) %>%
    type.convert(as.is = TRUE)

}

game_language = function(xml) {

  node = xml_find_all(xml, "poll[@name='language_dependence']/results/result")

  if (!length(node)) return()

  lang = c(
    "No necessary in-game text" = "none",
    "Some necessary text - easily memorized or small crib sheet" = "some",
    "Moderate in-game text - needs crib sheet or paste ups" = "moderate",
    "Extensive use of text - massive conversion needed to be playable" =
      "extensive",
    "Unplayable in another language" = "essential")

  tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    langlevel = lang[xml_attr(node, "value")],
    votes = xml_attr(node, "numvotes")) %>%
    type.convert(as.is = TRUE)

}

game_links = function(xml) {

  links = xml_find_all(xml, "link")

  out = tibble(
    id = links %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    link_id   = xml_attr(links, "id"),
    link_type = xml_attr(links, "type"),
    link_name = xml_attr(links, "value")) %>%
    type.convert(as.is = TRUE)

  # The prefix "boardgame" is added regardless of what the game is actually
  # classified as (boardgame vs RPG vs videogame). Because it carries no
  # information, it is removed.

  out$link_type = gsub("^boardgame", "", out$link_type)

  out %>%
    split(.$link_type) %>%
    lapply(function(df) {
      x = df[, c("id", "link_id", "link_name")]
      setNames(x, nm = gsub("^link", df$link_type[1], names(x)))
    })

}

# Additional data --------------------------------------------------------------

game_stats = function(xml) {

  node = xml_find_all(xml, "statistics")

  if (!length(node)) return()

  stats = xml_contents(node)

  extract_value = function(xml, what) {
    xml %>%
      xml_find_all(what) %>%
      xml_attr("value")
  }

  statistics = c("usersrated", "average", "bayesaverage", "stddev",
                 "median", "owned", "trading", "wanting", "wishing",
                 "numcomments", "numweights", "averageweight")

  out = setNames(nm = statistics) %>%
    lapply(extract_value, xml = stats) %>%
    as_tibble() %>%
    tibble::add_column(id = xml_attr(xml, "id"), .before = 1) %>%
    type.convert(as.is = TRUE)

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

game_comments = function(xml) {

  # The node is identified as 'comments' for both comments and ratingcomments.
  node = xml_find_all(xml, "comments")

  if (!length(node)) return()

  text = node %>%
    xml_contents() %>%
    xml_attr("value")

  text[!nchar(text)] = NA_character_

  rating = node %>%
    xml_contents() %>%
    xml_attr("rating")

  rating[rating =="N/A"] = NA_character_

  tibble(
    id = node %>%
      xml_contents() %>%
      xml_find_first("./../parent::item") %>%
      xml_attr("id"),
    username = node %>%
      xml_contents() %>%
      xml_attr("username"),
    rating = rating,
    text = text)

}

# Not implemented yet ----------------------------------------------------------

game_versions = function(xml) {

  node = xml_find_all(xml, "versions")

  if (!length(node)) return()

  message("Parsing versions is not implemented yet, returning XML document")

  node

}

game_marketplace = function(xml) {

  node = xml_find_all(xml, "marketplace")

  if (!length(node)) return()

  message("Parsing marketplace is not implemented yet, returning XML document")

  node

}

game_videos = function(xml) {

  node = xml_find_all(xml, "videos")

  if (!length(node)) return()

  message("Parsing videos is not implemented yet, returning XML document")

  node

}
