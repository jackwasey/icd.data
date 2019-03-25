#' Generate all package data
#'
#' Parses (and downloads if necessary) CDC annual revisions of ICD-9-CM to get
#' the 'billable' codes. Also parses the AHRQ, Quan/Deyo, and CMS HCC
#' comorbidity mappings from the source SAS data. Elixhauser and Quan/Elixhauser
#' mappings are generated from transcribed codes.
#' @keywords internal datagen
#' @noRd
.update_everything <- function(offline = FALSE,
                               verbose = .verbose()) {
  old_opt <- options(icd.data.offline = offline)
  on.exit(options(old_opt), add = TRUE)
  .parse_icd9cm_leaf_year(
    year = "2014",
    save_data = TRUE,
    verbose = verbose
  )
  .icd9cm_gen_chap_hier(
    save_data = TRUE,
    verbose = verbose
  )
  # TODO: just need to save icd10cm2016 and icd10cm2019 in data, and have
  # special getter functions for them.
  .parse_icd10cm_all(
    save_data = TRUE,
    verbose = verbose,
    twentysixteen = TRUE
  )
  .icd10cm_extract_sub_chapters(save_data = TRUE)
  icd9cm_billable <- list()
  icd9cm_billable[["32"]] <- get_icd9cm2014_leaf(must_work = TRUE)
  .save_in_data_dir(icd9cm_billable)
}
