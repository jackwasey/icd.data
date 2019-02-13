#' Read the definitions of the French edition of ICD-10
#' @template save_data
#' @keywords internal
parse_cim_fr <- function(save_data = FALSE) {
  cim_raw <- read.delim(
    bzfile(file.path("data-raw", "CIM-10-FR.txt.bz2"),
           encoding = "Latin1"),
    header = FALSE,
    sep = "|",
    as.is = TRUE)
  icd10fr2008 <- cim_raw[c(1, 5, 6)]
  names(icd10fr2008) <- c("code", "desc_short", "desc_long")
  icd10fr2008[["code"]] <- trimws(icd10fr2008[["code"]])
  if (save_data)
    save_in_data_dir(icd10fr2008)
  invisible(icd10fr2008)
}
