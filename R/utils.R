# UTILS

type_convert = function(df, convert_fn = NULL, ...) {

  out = type.convert(df, as.is = TRUE, ...)

  if (length(convert_fn)) {
    nm = names(convert_fn)
    out[nm] = mapply(function(col, f) f(col), out[nm], convert_fn,
                     SIMPLIFY = FALSE)
  }

  out
}

as_minutes = function(x) {
  as.difftime(as.double(x), units = "mins")
}

convert_df = function(df, ...) {

  fns = list(...)

  for (nm in names(fns)) df[[nm]] = fns[[nm]](df[[nm]])

  df

}

convert_na = function(df, ...) {

  for (e in substitute(...())) {

    nm = all.vars(e)[1]
    ix = eval(e, envir = df)

    stopifnot(is.logical(ix), identical(length(ix), nrow(df)))

    df[[nm]][ix] = if (is.list(df[[nm]])) list(NULL) else NA

  }

  df

}

warn_for_missing = function(x) {

  if (!inherits(x[[1]], "xml_missing")) return(FALSE)

  warning('Nothing to return; call `attr(x, "res")` to get the raw response',
          call. = FALSE)

  TRUE
}

na_chr = function(x) {
  x[!nchar(x)] = NA_character_
  x
}

na_int = function(x) {
  x[x == 0] = NA_integer_
  x
}

na_dbl = function(x) {
  x[x == 0] = NA_real_
  x
}

next_id = function(x) {
  attr(x, "next_id")
}

.nest = function(df, group_by = "id", data_to = "data") {

  split_lst = split(df, df[[group_by]])

  setNames(tibble(
    id = as.integer(names(split_lst)),
    data = unname(split_lst)),
    nm = c(group_by, data_to))

}

.left_join = function(x, y, by = NULL, suffixes = c("_x", "_y")) {

  out = merge(x = x, y = y, all.x = TRUE, by = by, sort = FALSE,
              suffixes = suffixes)

  # Because of how base::merge treats list columns.
  is_list = vapply(out, is.list, FALSE)

  out[is_list] = lapply(out[is_list], function(x) {
    x[is.na(x)] = list(NULL)
    x
  })

  as_tibble(out)
}

.reduce = function(x, f, ..., init, right = FALSE, accumulate = FALSE) {

  Reduce(function(left, right) f(left, right, ...),
         x = Filter(f = length, x),
         init = init, right = right,
         accumulate = accumulate)

}

.select = function(df, ...) {

  cols = vapply(substitute(...()), deparse, "")

  names(cols)[names(cols) == ""] = cols[names(cols) == ""]

  setNames(df[, cols, drop = FALSE], nm = names(cols))

}
