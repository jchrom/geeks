#' Shut Up And Sit Down Recommends
#'
#' A dataset containing 611 games reviewed
#' by [Shut Up And Sit Down](https://www.shutupandsitdown.com/) (SUSD).
#'
#' @format A data frame with 2 variables
#'
#' * __id__ corresponds to the game entry in BoardGameGeek database.
#' * __susd_recommends__ indicates whether a game is recommended (1) by SUSD
#'   or not (0).
#'
#' @source https://www.shutupandsitdown.com
"susd"

#' BoardGameGeek Game Data
#'
#' A dataset containing 611 games acquired
#' from the [BoardGameGeek](https://boardgamegeek.com) (BGG) database.
#'
#' @format An object of class `<geek_item>` (a named list of data frames)
#'
#' @section info:
#'
#' This dataset includes basic game info.
#'
#' * __id__ int, a unique game id.
#' * __name__ chr, primary name.
#' * __yearpublished__ int
#' * __description__ chr
#' * __minage__ int
#' * __minplayers__ int
#' * __maxplayers__ int
#' * __playingtime__ int
#' * __minplaytime__ int
#' * __maxplaytime__ int
#' * __image__ chr, cover image URL.
#' * __seriescode__ logi
#' * __releasedate__ logi
#'
#' @section altnames:
#'
#' This dataset includes alternative game names.
#'
#' * __id__ int, a unique game id.
#' * __altname__ chr, game name.
#' * __type__ chr, indicates whether the name is a primary or alternate name.
#'
#' @section numplayers:
#'
#' This dataset includes poll results on the best number of players for a game.
#
#' * __id__ int, a unique game id.
#' * __numplayers__ chr, number of players, can be `4+` and similar string values.
#' * __Best__ int, how many times this number of players was voted "Best".
#' * __Recommended__ int, how many times this number of players was
#'   voted "Recommended".
#' * __Not Recommended__ int, how many times this number of players was voted
#'   "Not Recommended".
#'
#' @section playerage:
#'
#' This dataset includes poll results on the most appropriate player age.
#'
#' * __id__ int, a unique game id.
#' * __playerage__ chr, can be mostly numerical but can be `"21 and up"`.
#' * __votes__ int how many times this age was upvoted.
#'
#' @section language:
#'
#' This dataset includes poll results on the degree of language requirements.
#'
#' * __id__ int, a unique game id.
#' * __langlevel__ chr, one of four values ordered from no in-game text to
#'   unplayable in another language.
#' * __votes__ int, how many times this level upvoted.
#'
#' @section links:
#'
#' This dataset includes information on related items, such as mechanics.
#'
#' * __id__ int, a unique game id
#' * __link_id__ int, related item id.
#' * __link_type__ chr, related item type, such `"mechanic"` or `"category"`.
#' * __link_name__ chr, related item name.
#'
#' @section stats:
#'
#' This dataset includes game statistics.
#'
#' * __id__ int, a unique game id.
#' * __usersrated__ int, voter count.
#' * __average__ num, average rating.
#' * __bayesaverage__ num, a combination of the average rating and thirty
#'   additional average ratings across the whole site. This is intended
#'   to prevent a new or rare game with only a few high ratings from taking
#'   the top spots. See
#'   [BGG forum.](https://boardgamegeek.com/thread/71129/what-bayesian-average)
#' * __stddev__ num
#' * __median__ int
#' * __owned__ int, number of people who sold a game.
#' * __trading__ int, number of people who seek to sell a game.
#' * __wanting__ int, number of people who seek to buy a game.
#' * __wishing__ int
#' * __numcomments__ int
#' * __numweights__ int
#' * __averageweight__ num, a measure of game complexity.
"bgg"
