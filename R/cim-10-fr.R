.dl_icd10fr2019 <- function(save_data = TRUE, ...) {
  fp <- .unzip_to_data_raw(
    url = paste(
      sep = "/",
      "https://www.atih.sante.fr",
      "plateformes-de-transmission-et-logiciels",
      "logiciels-espace-de-telechargement",
      "telecharger/gratuit/11616/456"
    ),
    file_name = "LIBCIM10MULTI.TXT",
    ...
  )
}

#' Read the definitions of the French edition of ICD-10
#'
#' The short descriptions are capitalized, with accented characters, so leaving as is.
#' @template save_data
#' @keywords internal
.parse_cim_fr <- function(save_data = FALSE, ...) {
  fp <- .dl_icd10fr2019(save_data = save_data, ...)
  cim_raw <- read.delim(
    fileEncoding = "Latin1",
    fp$file_path,
    header = FALSE,
    sep = "|",
    as.is = TRUE
  )
  icd10fr2019 <- cim_raw[c(1, 5, 6)]
  names(icd10fr2019) <- c("code", "short_desc", "long_desc")
  icd10fr2019$short_desc <- enc2utf8(icd10fr2019$short_desc)
  icd10fr2019$long_desc <- enc2utf8(icd10fr2019$long_desc)
  icd10fr2019[["code"]] <- trimws(icd10fr2019[["code"]])
  icd10fr2019$major <- ""
  icd10fr2019$three_digit <- ""
  current_major <- NULL
  current_three_digit <- NULL
  for (i in seq_along(icd10fr2019$code)) {
    icd <- icd10fr2019[i, "code"]
    if (nchar(icd) == 3L) {
      current_major <- icd10fr2019[i, "long_desc"]
      current_three_digit <- icd
    }
    icd10fr2019[i, "major"] <- current_major
    icd10fr2019[i, "three_digit"] <- current_three_digit
  }
  icd10fr2019$major <- factor(icd10fr2019$major)
  # TODO: chapitres
  class(icd10fr2019$code) <- c("icd10fr", "icd10", "character")
  class(icd10fr2019$three_digit) <- c("icd10fr", "icd10", "character")
  if (save_data) {
    .save_in_resource_dir(icd10fr2019)
  }
  invisible(icd10fr2019)
}
