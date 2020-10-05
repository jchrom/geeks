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
#' * __option__ int, whether this number of players was voted `"Best"`,
#'   `"Recommended"` or `"Not Recommended"`.
#' * __votes__ int, how many times was this number of players voted for.
#'
#' @section playerage:
#'
#' This dataset includes poll results on the most appropriate player age.
#'
#' * __id__ int, a unique game id.
#' * __playerage__ chr, mostly numbers but can be `"21 and up"`.
#' * __votes__ int, how many times this age was upvoted.
#'
#' @section language:
#'
#' This dataset includes poll results on the degree of language requirements.
#'
#' * __id__ int, a unique game id.
#' * __langlevel__ chr, one of four ordered values ranging from "no in-game text"
#'   to "unplayable in another language".
#' * __votes__ int, how many times this level upvoted.
#'
#' @section links:
#'
#' A list of data frames. Includes information on related items, such
#' as mechanics, categories, designers or artists. The actual column names
#' follow the same pattern but depend on what type of link is included.
#'
#' * __id__ int, a unique game id
#' * __link_id__ int, related item id.
#' * __link_name__ chr, related item name.
#'
#' @section stats:
#'
#' This dataset includes game statistics.
#'
#' * __id__ int, a unique game id.
#' * __usersrated__ int, voter count.
#' * __average__ num, average rating.
#' * __bayesaverage__ num, see note below.
#' * __stddev__ num
#' * __median__ int
#' * __owned__ int, how many people currently own this game.
#' * __trading__ int, how many people want to sell this game.
#' * __wanting__ int, how many people want to buy this game.
#' * __wishing__ int, how many people have this game on their wishlist.
#' * __numcomments__ int
#' * __numweights__ int
#' * __averageweight__ num, a measure of game complexity.
#'
#' __bayeaverage.__ Games with less than 30 ratings do not have `bayesaverage`,
#' so the value is `NA`. For games with at least 30 ratings, an average rating
#' across the whole database is taken, then repeated a number of times (starting
#' at 500 but can be more) and added to the actual ratings. This is to prevent
#' games with very few ratings to reach extremely low or high averages. See
#' [this BGG thread.](https://boardgamegeek.com/thread/71129/what-bayesian-average)
#' for discussion.
#'
"bgg"
