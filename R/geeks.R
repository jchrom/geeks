#' geeks: Geek API client
#'
#' The purpose of `geeks` is to fetch tidy data from
#' [boardgamegeek](https://www.boardgamegeek.com),
#' [rpggeek](https://rpggeek.com) and
#' [videogamegeek](https://videogamegeek.com). Under the hood, it is using the
#' [httr](https://github.com/r-lib/httr) package to query the
#' [XMLAPI2](https://boardgamegeek.com/wiki/page/BGG_XML_API2).
#'
#' @importFrom magrittr %>%
#'
#' @importFrom xml2 xml_child xml_attr xml_text xml_find_first xml_find_all
#'   xml_contents xml_length xml_attrs xml_children xml_has_attr xml_missing
#'
#' @importFrom stats setNames na.omit reshape
#'
#' @importFrom utils type.convert str hasName modifyList
#'
#' @importFrom tibble tibble as_tibble add_column
#'
#' @docType package
#' @name geeks
NULL

#' Geek Sites Rate Limits
#'
#' Geek sites rate limits are not very well documented, and may even vary
#' in relation to server load. This makes it hard to predict when the limit will
#' be breached. Exponential back-off is used to mitigate this.
#'
#' @section Exponential back-off:
#'
#' This means that after an unsuccessful request, for example one that returned
#' a response with status 429 ("Too many requests"), R will pause for a time
#' and then try again. It will try 3 times in total, including the initial time,
#' increasing the pause duration before each-retry. This is implemented using
#' [httr::RETRY()], according to the formula `5 * 2 ^ attempt seconds`,
#' with the minimum of 5s pause.
#'
#' This will make it more likely that a large amount of data is retrieved
#' successfully, but will not help in other situations (e.g. badly formed
#' request).
#'
#' @section Throttling:
#'
#' According to some observations, throttling can vary depending on the current
#' server load.
#'
#' This is relevant for some functions like [get_games()] which allow you
#' to specify a vector of id numbers, and the API does not seem to place a hard
#' limit on how long it can be. This allows you to request hundreds of records
#' at a time, but if the server decides it is too busy, you will only get a 429
#' error back. Exponential back-off might not be enough to resolve this
#' if the server remains busy for a longer period of time.
#'
#' To mitigate this, if you are planning to make intensive requests, please
#' pick a time of day when the traffic is lowest (basically night time in the
#' US). To help distribute the load during paging (i.e. when fetching comments
#' or plays), you might also use the `delay_s` argument to space out
#' the requests.
#'
#' @name rate_limits
NULL

utils::globalVariables(c(

  # common
  ".", "id", "value",

  # output_language_tbl()
  "langlevel",

  # output_families_tbl()
  "family_name", "family_id",

  # output_links_tbl()
  "link_type",

  # output_plays_tbl()
  "page", "item_id", "item_name", "user_id", "date", "quantity", "length",
  "incomplete", "nowinstats", "location",
  "userid", "new", "rating", "play_id", "username", "name", "startposition",
  "color", "score", "win"
))
