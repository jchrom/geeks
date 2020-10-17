
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

At the moment, the usage covers fetching and parsing game entries, plays
and families. Support for collections, search and threads is planned.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jchrom/geeks")
```

## Example

The following snippet retrieves data about a set of games, and coerces
them into a data frame:

``` r
library(geeks)
get_games(c(174430, 161936, 224517))
#> Fetching URL: https://www.boardgamegeek.com/xmlapi2/thing?id=174430,161936,224517&stats=1&versions=1&marketplace=1&videos=1&comments=1&ratingcomments=1&pagesize=100&page=1
#> # A tibble: 3 x 38
#>       id type  name  yearpublished description minage minplayers maxplayers
#> *  <int> <chr> <chr> <chr>         <chr>       <chr>  <chr>      <chr>     
#> 1 174430 boar… Gloo… 2017          Gloomhaven… 14     1          4         
#> 2 161936 boar… Pand… 2015          Pandemic L… 13     2          4         
#> 3 224517 boar… Bras… 2018          Brass: Bir… 14     2          4         
#> # … with 30 more variables: playingtime <drtn>, minplaytime <drtn>,
#> #   maxplaytime <drtn>, image <chr>, seriescode <chr>, releasedate <date>,
#> #   altnames <list>, playerage <list>, language <list>, usersrated <int>,
#> #   average <dbl>, bayesaverage <dbl>, stddev <dbl>, owned <int>,
#> #   trading <int>, wanting <int>, wishing <int>, numcomments <int>,
#> #   numweights <int>, averageweight <dbl>, artist <list>, category <list>,
#> #   designer <list>, expansion <list>, family <list>, implementation <list>,
#> #   integration <list>, mechanic <list>, publisher <list>, comments <list>
```

Play data can be obtained given a game id:

``` r
get_plays(174430)
#> Fetching URL: https://www.boardgamegeek.com/xmlapi2/plays?id=174430&pagesize=100&page=1
#> # A tibble: 100 x 12
#>    play_id page  item_id item_name user_id date       quantity length incomplete
#>  *   <int> <chr>   <int> <chr>       <int> <date>        <int> <drtn> <lgl>     
#>  1  4.60e7 1/25…  174430 Gloomhav…  464693 2020-10-24        1  NA m… FALSE     
#>  2  4.60e7 1/25…  174430 Gloomhav…  464693 2020-10-23        1  NA m… FALSE     
#>  3  4.60e7 1/25…  174430 Gloomhav…  464693 2020-10-23        1  NA m… FALSE     
#>  4  4.60e7 1/25…  174430 Gloomhav…  464693 2020-10-22        1  NA m… FALSE     
#>  5  4.60e7 1/25…  174430 Gloomhav…  464693 2020-10-21        1  NA m… FALSE     
#>  6  4.63e7 1/25…  174430 Gloomhav…  847807 2020-10-17        1  NA m… FALSE     
#>  7  4.63e7 1/25…  174430 Gloomhav…  265648 2020-10-17        1 245 m… FALSE     
#>  8  4.63e7 1/25…  174430 Gloomhav…  858330 2020-10-17        1  NA m… FALSE     
#>  9  4.63e7 1/25…  174430 Gloomhav… 1349419 2020-10-17        1  NA m… FALSE     
#> 10  4.63e7 1/25…  174430 Gloomhav…  598948 2020-10-17        1  NA m… FALSE     
#> # … with 90 more rows, and 3 more variables: nowinstats <int>, location <chr>,
#> #   players <list>
```

Multiple families can be obtained at once:

``` r
get_families(c(7544, 17634))
#> Fetching URL: https://www.boardgamegeek.com/xmlapi2/family?id=7544,17634
#> # A tibble: 126 x 4
#>    family_id family_name    item_id item_name             
#>  *     <int> <chr>            <int> <chr>                 
#>  1      7544 Animals: Foxes  227837 Atlas: Enchanted Lands
#>  2      7544 Animals: Foxes  156405 Auf zur Fuchsjagd     
#>  3      7544 Animals: Foxes  197945 Ausgefuchst!          
#>  4      7544 Animals: Foxes   32814 Bears, Foxes & Hares  
#>  5      7544 Animals: Foxes  101760 Boxing the Fox        
#>  6      7544 Animals: Foxes  213822 Chicken Roundup       
#>  7      7544 Animals: Foxes   13790 Cottontail and Peter  
#>  8      7544 Animals: Foxes  199792 Everdell              
#>  9      7544 Animals: Foxes  289057 Everdell: Bellfaire   
#> 10      7544 Animals: Foxes   19625 Fantastic Mr Fox      
#> # … with 116 more rows
```

## Built on

[xml2](https://github.com/r-lib/xml2),
[httr](https://github.com/r-lib/httr),
[tibble](https://github.com/tidyverse/tibble) and the BGG [API2
docs](https://boardgamegeek.com/wiki/page/BGG_XML_API2).
