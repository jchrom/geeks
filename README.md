
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geeks

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/geeks)](https://CRAN.R-project.org/package=geeks)
<!-- badges: end -->

The purpose of **geeks** is to download data from three game-related
geek sites: [boardgamegeek](https://www.boardgamegeek.com),
[rpggeek](https://rpggeek.com) and
[videogamegeek](https://videogamegeek.com).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jchrom/geeks")
```

## Example

At the moment, fetching and parsing most of game data is implemented.
Other components such as plays, threads and search are to be added
later.

The following snippet retrieves data about a set of games, and coerces
them into a data frame:

``` r
library(geeks)

games = get_game(c("174430", "161936", "224517"), domain = "boardgame")

game_info(games)
#> # A tibble: 3 x 11
#>       id name  yearpublished description minage minplayers maxplayers
#>    <int> <chr>         <int> <chr>        <int>      <int>      <int>
#> 1 161936 Pand…          2015 Pandemic L…     13          2          4
#> 2 174430 Gloo…          2017 Gloomhaven…     14          1          4
#> 3 224517 Bras…          2018 Brass: Bir…     14          2          4
#> # … with 4 more variables: playingtime <int>, minplaytime <int>,
#> #   maxplaytime <int>, image <chr>

game_stats(games)
#> # A tibble: 3 x 13
#>       id usersrated average bayesaverage stddev median owned trading wanting
#>    <int>      <int>   <dbl>        <dbl>  <dbl>  <int> <int>   <int>   <int>
#> 1 174430      37610    8.82         8.57   1.61      0 60619     377    1437
#> 2 161936      38745    8.62         8.47   1.58      0 61119     280     839
#> 3 224517      15105    8.64         8.31   1.27      0 22335      68    1304
#> # … with 4 more variables: wishing <int>, numcomments <int>, numweights <int>,
#> #   averageweight <dbl>
```

## Built on

Credits mostly to [xml2](https://github.com/r-lib/xml2),
[httr](https://github.com/r-lib/httr) and the BGG [API2
docs](https://boardgamegeek.com/wiki/page/BGG_XML_API2).
