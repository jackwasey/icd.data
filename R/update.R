#nocov start
utils::globalVariables(c("icd9_sub_chapters",
                         "icd9_chapters",
                         "icd9cm_latest_edition",
                         "icd9cm_billable",
                         "icd9cm_sources",
                         "icd9_majors"))

#' generate all package data
#'
#' Parses (and downloads if necessary) CDC annual revisions of ICD-9-CM to get
#' the 'billable' codes. Also parses the AHRQ, Quan/Deyo, and CMS HCC
#' comorbidity mappings from the source SAS data. Elixhauser and Quan/Elixhauser
#' mappings are generated from transcribed codes.
#' @keywords internal datagen
#' @noRd
update_everything <- function() {
  # this is not strictly a parsing step, but is quite slow. It relies on picking
  # up already saved files from previous steps. It can take hours to complete,
  # but only needs to be done rarely. This is only intended to be run from
  # development tree, not as installed package
  generate_sysdata()
  load(file.path("R", "sysdata.rda"))
  # plain text billable codes
  message("Parsing plain text billable codes to create icd9cm_billable list of
                       data frames with descriptions of billable codes only.
                       No dependencies on other data.")
  parse_leaf_descriptions_all(save_data = TRUE, offline = FALSE)
  load(system.file("data", "icd9cm_billable.RData", package = "icd.data"))
  icd10cm_parse_all_defined(save_data = TRUE, offline = FALSE)
  icd10cm_extract_sub_chapters(save_data = TRUE, offline = FALSE)
  # reload the newly saved data before generating chapters.
  # The next step depends on icd9cm_billable
  icd9cm_gen_chap_hier(save_data = TRUE, offline = FALSE,
                       verbose = FALSE)
  icd10_parse_ahrq_pcs(save_data = TRUE)
  get_chapters_fr(save_data = TRUE)
  get_sub_chapters_fr(save_data = TRUE)
}
# nocov end
