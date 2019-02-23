#' generate all package data
#'
#' Parses (and downloads if necessary) CDC annual revisions of ICD-9-CM to get
#' the 'billable' codes. Also parses the AHRQ, Quan/Deyo, and CMS HCC
#' comorbidity mappings from the source SAS data. Elixhauser and Quan/Elixhauser
#' mappings are generated from transcribed codes.
#' @keywords internal datagen
#' @noRd
update_everything <- function(save_data = TRUE, offline = FALSE) {
  # This relies on picking up already saved files from previous steps. This is
  # only intended to be run from development tree, not as installed package
  old_opt <- options(icd.data.offline = offline)
  on.exit(options(old_opt))
  generate_sysdata()
  load(file.path("R", "sysdata.rda"))
  # plain text billable codes
  message("Parsing plain text billable codes to create icd9cm_billable list of
                       data frames with descriptions of billable codes only.
                       No dependencies on other data.")
  parse_icd9cm_leaf_desc_all(save_data = save_data)
  load(system.file("data", "icd9cm_billable.RData", package = "icd.data"))
  # reload the newly saved data before generating chapters.
  # The next step depends on icd9cm_billable
  icd9cm_gen_chap_hier(save_data = save_data, verbose = FALSE)
  icd10cm_parse_all_defined(save_data = save_data)
  icd10cm_extract_sub_chapters(save_data = save_data)
  icd10_parse_cms_pcs_all(save_data = save_data)
  parse_cim_fr(save_data = save_data)
  parse_icd10be2014(save_data = save_data)
  parse_icd10be2017(save_data = save_data)
}
