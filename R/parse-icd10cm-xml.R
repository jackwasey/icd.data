# nocov start

icd10cm_get_xml_file <- function(...) {
  unzip_to_data_raw(
    url = paste0(icd10_url_cdc, "2016/ICD10CM_FY2016_Full_XML.ZIP"),
    file_name = "Tabular.xml", ...)
}

#' Get sub-chapters from the 2016 XML for ICD-10-CM
#'
#' This is not quite a super-set of ICD-10 sub-chapters: many more codes than
#' ICD-10, but some are abbreviated, notably HIV.
#'
#' This is complicated by the XML document specifying more hierarchical
#' levels,e.g. \code{C00-C96}, \code{C00-75} are both specified within the
#' chapter Neoplasms (\code{C00-D49}). A way of determining whether there are
#' extra levels would be to check the XML tree depth for a member of each
#' putative sub-chapter.
#' @template save_data
#' @keywords internal datagen
#' @noRd
icd10cm_extract_sub_chapters <- function(save_data = FALSE, offline = TRUE) {
  stopifnot(is.logical(save_data), is.logical(offline))
  f_info <- icd10cm_get_xml_file(offline = offline)
  stopifnot(!is.null(f_info))
  j <- xml2::read_xml(f_info$file_path)
  # using magrittr::equals and extract because I don't want to import them. See
  # \code{icd-package.R} for what is imported. No harm in being explicit, since
  # :: will do an implicit requireNamespace.
  xml2::xml_name(xml2::xml_children(j)) == "chapter" -> chapter_indices
  # could do xpath, but harder to loop
  chaps <- xml2::xml_children(j)[chapter_indices]
  icd10_sub_chapters <- list()
  for (chap in chaps) {
    c_kids <- xml2::xml_children(chap)
    subchap_indices <- xml2::xml_name(c_kids) == "section"
    subchaps <- c_kids[subchap_indices]
    for (subchap in subchaps) {
      new_sub_chap_range <-
        chapter_to_desc_range.icd10(
          xml2::xml_text(
            xml2::xml_children(
              subchap
            )[1]
          )
        )
      # should only match one at a time
      stopifnot(length(new_sub_chap_range) == 1)
      # check that this is a real sub-chapter, not an extra range defined in the
      # XML, e.g. C00-C96 is an empty range declaration for some neoplasms.
      ndiags <- length(xml2::xml_find_all(subchap, "diag"))
      if (ndiags == 0) {
        message("skipping empty range definition for ", new_sub_chap_range)
        next
      }
      # there is a defined Y09 in both ICD-10 WHO and CM, but the range is
      # incorrectly specified (in 2016 version of XML, at least)
      if (new_sub_chap_range[[1]]["end"] == "Y08")
        new_sub_chap_range[[1]]["end"] <- "Y09"
      icd10_sub_chapters <- append(icd10_sub_chapters, new_sub_chap_range)
    } #subchaps
  } #chapters
  if (save_data) save_in_data_dir(icd10_sub_chapters)
  invisible(icd10_sub_chapters)
}

# nocov end