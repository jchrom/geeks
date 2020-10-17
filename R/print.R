#' @export
print.geek_item = function(x, ...) {

  cat("<geek_item>")

  cat_tibble = function(tbl, nm, indent = 1) {
    cat(sprintf(
      "\n%s$ %s: tibble [%s x %s]", paste(rep(" ", indent), collapse = ""),
      nm, nrow(tbl), ncol(tbl)
    ))
  }

  cat_list = function(lst, nm, indent = 1) {
    cat(sprintf(
      "\n%s%slist of %s", paste(rep(" ", indent), collapse = ""),
      if (length(nm)) paste0(nm, ": ") else "",
      length(lst)
    ))
  }

  cat_lines = function(x, nm = NULL, indent = 1) {

    cat_list(x, nm = nm, indent = indent)

    for (nm in format(names(x))) {

      el = x[[trimws(nm)]]

      if (is.data.frame(el))
        cat_tibble(el, nm = nm, indent = indent)
      else
        cat_lines(el, nm = nm, indent = indent + 2)
    }
  }

  cat_lines(x)

  invisible(x)
}
