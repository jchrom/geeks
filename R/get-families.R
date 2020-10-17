#' Get Item Family Data
#'
#' Request item family data.
#'
#' @param id A vector of family id numbers.
#'
#' @return A tibble. To extract the raw HTTP response, call `attr(x, "res")`.
#'
#' @export

get_families = function(id) {

  page_xml = get_page(path = "family", params = list(id = id),
                      output_fn = output_families_xml)

  page_res = attr(page_xml, "res")

  if (warn_for_missing(page_xml)) {
    return(structure(tibble(), res = list(page_res)))
  }

  structure(output_families_tbl(page_xml), res = list(page_res))

}

output_families_xml = function(res) {

  xml = httr::content(res, as = "parsed")

  if (!xml_length(xml)) return(structure(xml_missing(), res = res))

  structure(xml, res = res)

}

output_families_tbl = function(xml) {

  families_xml = xml_find_all(xml, "item")

  if (!length(families_xml)) return(list(NULL))

  families_tbl = xml %>%
    xml_find_all("item") %>%
    xml_attrs() %>%
    do.call(what = rbind) %>%
    as_tibble() %>%
    add_column(family_name = xml %>%
                 xml_find_all("item/name[@type='primary']") %>%
                 xml_attr("value")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    .select(family_id = id, family_name)

  items_xml = xml_find_all(xml, "item/link")

  if (!length(families_xml)) {
    return(families_tbl)
  }

  items_xml %>%
    xml_attrs() %>%
    do.call(what = rbind) %>%
    as_tibble() %>%
    add_column(family_id = items_xml %>%
                 xml_find_first("./parent::item") %>%
                 xml_attr("id")) %>%
    type.convert(as.is = TRUE, na.strings = "") %>%
    convert_df(inbound = as.logical) %>%
    .select(family_id, item_id = id, item_name = value) %>%
    .left_join(x = families_tbl, y = ., by = "family_id")

}
