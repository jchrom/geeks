# Issue HTTP requests with paging for the BGG XML API2.

get_pages = function(path, params, output_fn, page_start = 1, page_n = 1,
                     delay_s = 0.5) {

  if (hasName(params, "page")) {
    warning("The value of `page` will be overriden by `page_start`",
            call. = FALSE)
  }

  params$pagesize = 100
  params$page = page_start

  pages = list()

  repeat {

    page = get_page(path = path, params = params, output_fn = output_fn)

    pages = c(pages, list(page))

    if (!length(next_id(page))) break

    if (length(pages) >= page_n) break

    params = modifyList(params, list(page = attr(page, "page") + 1L,
                                     id = attr(page, "next_id")))

    Sys.sleep(delay_s)

  }

  pages

}

get_page = function(path, params, output_fn = NULL) {

  stopifnot(is.character(path))

  stopifnot(is.list(params), !is.null(names(params)))

  # Id numbers are unique across all geek domains. The three domains share
  # a single DB, so it does not matter which domain is used for the request.
  domain = "https://www.boardgamegeek.com"

  # Parameters of length > 1 (such as a vector of id numbers) must be collapsed.
  params = lapply(params, paste, collapse = ",")

  url = httr::modify_url(
    url = domain,
    path = c("xmlapi2", path),
    query = params)

  message("Fetching URL: ", curl::curl_unescape(url))

  res = httr::RETRY("GET", url = url, times = 3, pause_base = 5, pause_min = 5)

  httr::stop_for_status(res)

  output_fn(res)

}
