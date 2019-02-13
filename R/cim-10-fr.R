#' Read the definitions of the French edition of ICD-10
#' @template save_data
#' @keywords internal
parse_cim_fr <- function(save_data = TRUE) {
  cim_raw <- read.delim(
    bzfile(file.path("data-raw", "CIM-10-FR.txt.bz2"),
           encoding = "Latin1"),
    header = FALSE,
    sep = "|",
    as.is = TRUE)
  cim <- cim_raw[c(1, 5, 6)]
  names(cim) <- c("code", "desc_short", "desc_long")
  cim[["code"]] <- trimws(cim[["icd10"]])
}
