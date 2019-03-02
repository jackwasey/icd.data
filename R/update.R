#' generate all package data
#'
#' Parses (and downloads if necessary) CDC annual revisions of ICD-9-CM to get
#' the 'billable' codes. Also parses the AHRQ, Quan/Deyo, and CMS HCC
#' comorbidity mappings from the source SAS data. Elixhauser and Quan/Elixhauser
#' mappings are generated from transcribed codes.
#' @keywords internal datagen
#' @noRd
update_everything <- function(
  save_data = TRUE,
  offline = FALSE,
  verbose = TRUE
) {
  old_opt <- options(icd.data.offline = offline)
  on.exit(options(old_opt))
  generate_sysdata()
  load(file.path("R", "sysdata.rda"))
  icd9cm_gen_chap_hier(save_data = save_data, verbose = verbose)
  icd10cm_parse_all_defined(save_data = save_data,
                            verbose = verbose,
                            twentysixteen = TRUE)
  icd10cm_extract_sub_chapters(save_data = save_data)
}

fetch_all_to_resource_dir <- function(offline = FALSE, verbose = TRUE) {
  icd10cm_parse_all_defined(save_data = TRUE,
                            verbose = verbose,
                            twentysixteen = FALSE)
  icd10_parse_cms_pcs_all(save_data = TRUE)
  parse_cim_fr(save_data = TRUE)
  parse_icd10be2014(save_data = TRUE)
  parse_icd10be2017(save_data = TRUE)
}
