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

    tibble::tibble(id = game_item_id(node), value = value) %>%
      stats::setNames(nm = c("id", attr)) %>%
      stats::na.omit()
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
    utils::type.convert(as.is = TRUE) %>%
    tibble::as_tibble()

}

game_altnames = function(xml) {

  node_name = xml_find_all(xml, "name")

  tibble::tibble(
    id = node_name %>%
      xml_find_first("./parent::item") %>%
      xml_attr("id"),
    altname = xml_attr(node_name, "value"),
    type = xml_attr(node_name, "type")) %>%
    utils::type.convert(as.is = TRUE)

}

game_numplayers = function(xml) {

  node = xml_find_all(xml, "poll[@name='suggested_numplayers']/results/result")

  if (!length(node)) return()

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

game_playerage = function(xml) {

  node = xml_find_all(xml, "poll[@name='suggested_playerage']/results/result")

  if (!length(node)) return()

  tibble::tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    playerage = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes")) %>%
    utils::type.convert(as.is = TRUE)

}

game_language = function(xml) {

  node = xml_find_all(xml, "poll[@name='language_dependence']/results/result")

  if (!length(node)) return()

  tibble::tibble(
    id = node %>%
      xml_find_first("../../parent::item") %>%
      xml_attr("id"),
    langlevel = xml_attr(node, "value"),
    votes = xml_attr(node, "numvotes")) %>%
    utils::type.convert(as.is = TRUE)

}

game_links = function(xml) {

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

tidy_game_data = function(xml, wanted = NULL) {

  fn_info = list(
    info       = game_info,
    altnames   = game_altnames,
    numplayers = game_numplayers,
    playerage  = game_playerage,
    language   = game_language,
    links      = game_links)

  fn_additional = list(
    stats          = game_stats,
    versions       = game_versions,
    marketplace    = game_marketplace,
    videos         = game_videos,
    comments       = game_comments,
    ratingcomments = game_ratingcomments
  )[wanted]

  Filter(length, lapply(c(fn_info, fn_additional), function(f) f(xml)))

}

game_stats = function(xml) {

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

  tibble::tibble(
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

game_ratingcomments = game_comments

# To be implemented; for now, only XML is returned.

game_versions = identity

game_marketplace = identity

game_videos = identity
