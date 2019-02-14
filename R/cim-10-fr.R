#' Read the definitions of the French edition of ICD-10
#' @template save_data
#' @keywords internal
parse_cim_fr <- function(save_data = FALSE, offline = TRUE) {
  fp <- unzip_to_data_raw(
    url = paste(sep = "/",
                "https://www.atih.sante.fr",
                "plateformes-de-transmission-et-logiciels",
                "logiciels-espace-de-telechargement",
                "telecharger/gratuit/11616/456"),
    file_name = "LIBCIM10MULTI.TXT",
    offline = offline)
  cim_raw <- read.delim(
    fileEncoding = "Latin1",
    fp$file_path,
    header = FALSE,
    sep = "|",
    as.is = TRUE)
  icd10fr2019 <- cim_raw[c(1, 5, 6)]
  names(icd10fr2019) <- c("code", "desc_short", "desc_long")
  icd10fr2019$desc_short <- enc2utf8(icd10fr2019$desc_short)
  icd10fr2019$desc_long <- enc2utf8(icd10fr2019$desc_long)
  icd10fr2019[["code"]] <- trimws(icd10fr2019[["code"]])
  if (save_data)
    save_in_data_dir(icd10fr2019)
  invisible(icd10fr2019)
}
