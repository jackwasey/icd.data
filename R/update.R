#' Generate all package data
#'
#' Parses (and downloads if necessary) CDC annual revisions of ICD-9-CM to get
#' the 'billable' codes. Also parses the AHRQ, Quan/Deyo, and CMS HCC
#' comorbidity mappings from the source SAS data. Elixhauser and Quan/Elixhauser
#' mappings are generated from transcribed codes.
#' @keywords internal datagen
#' @noRd
.update_everything <- function(save_data = TRUE,
                               offline = FALSE,
                               verbose = .verbose()) {
  old_opt <- options(icd.data.offline = offline)
  on.exit(options(old_opt))
  .generate_sysdata(save_data = save_data, verbose = verbose)
  load(file.path("R", "sysdata.rda"))
  .icd9cm_parse_leaf_desc_ver(
    ver = "32",
    save_data = save_data,
    verbose = verbose
  )
  .icd9cm_gen_chap_hier(
    save_data = save_data,
    verbose = verbose
  )
  .parse_icd10cm_all(
    save_data = save_data,
    verbose = verbose,
    twentysixteen = TRUE
  )
  .icd10cm_extract_sub_chapters(save_data = save_data)
}
