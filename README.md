
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
them into a list of data frames:

``` r
library(geeks)
games = get_game(c("174430", "161936", "224517"), additional_data = "stats")
games
#> <geek_item>
#>  list of 7
#>  $ info      : tibble [3 x 13]
#>  $ altnames  : tibble [24 x 3]
#>  $ numplayers: tibble [45 x 4]
#>  $ playerage : tibble [36 x 3]
#>  $ language  : tibble [15 x 3]
#>    links     : list of 9
#>    $ artist        : tibble [7 x 3]
#>    $ category      : tibble [10 x 3]
#>    $ designer      : tibble [6 x 3]
#>    $ expansion     : tibble [11 x 3]
#>    $ family        : tibble [22 x 3]
#>    $ implementation: tibble [3 x 3]
#>    $ integration   : tibble [2 x 3]
#>    $ mechanic      : tibble [36 x 3]
#>    $ publisher     : tibble [34 x 3]
#>  $ stats     : tibble [3 x 12]
```

Show basic game info:

``` r
games$info
#> # A tibble: 3 x 13
#>       id name  yearpublished description minage minplayers maxplayers
#>    <int> <chr>         <int> <chr>        <int>      <int>      <int>
#> 1 161936 Pand…          2015 Pandemic L…     13          2          4
#> 2 174430 Gloo…          2017 Gloomhaven…     14          1          4
#> 3 224517 Bras…          2018 Brass: Bir…     14          2          4
#> # … with 6 more variables: playingtime <int>, minplaytime <int>,
#> #   maxplaytime <int>, image <chr>, seriescode <lgl>, releasedate <lgl>
```

Show stats:

``` r
games$stats
#> # A tibble: 3 x 12
#>       id usersrated average bayesaverage stddev owned trading wanting wishing
#>    <int>      <int>   <dbl>        <dbl>  <dbl> <int>   <int>   <int>   <int>
#> 1 174430      38291    8.81         8.56   1.61 62065     381    1440   15268
#> 2 161936      39172    8.62         8.47   1.58 61664     284     843   10238
#> 3 224517      15715    8.64         8.32   1.28 23142      76    1323    8176
#> # … with 3 more variables: numcomments <int>, numweights <int>,
#> #   averageweight <dbl>
```

## Built on

[xml2](https://github.com/r-lib/xml2),
[httr](https://github.com/r-lib/httr),
[tibble](https://github.com/tidyverse/tibble) and the BGG [API2
docs](https://boardgamegeek.com/wiki/page/BGG_XML_API2).
