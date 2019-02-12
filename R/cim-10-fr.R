#' Read the definitions of the French edition of ICD-10
#'
#' The data are encoded, as far as R allows, in UTF-8 for the descriptions, and
#' without an encoding for the (ASCII) ICD codes themselves.
#' @param save Logical, default is \code{FALSE}, whether to save results in
#'   package source directory
#' @keywords internal
parse_cim_fr <- function(save = FALSE) {
  # the data is stored as ISO-8859-1 (Latin1)
  cim_raw <- utils::read.delim(
    bzfile(file.path("data-raw", "CIM-10-FR.txt.bz2"),
           encoding = "Latin1"),
    fileEncoding = "Latin1",
    encoding = "UTF-8",
    header = FALSE,
    sep = "|",
    as.is = TRUE)
  icd10fr2018 <- cim_raw[c(1, 5, 6)]
  names(icd10fr2018) <- c("code", "desc_short", "desc_long")
  icd10fr2018[["code"]] <- trimws(icd10fr2018[["code"]])
  # construct major and three digit columns
  icd10fr2018$major <- ""
  icd10fr2018$three_digit <- ""
  current_major <- NULL
  current_three_digit <- NULL
  for (i in seq_along(icd10fr2018$code)) {
    icd <- icd10fr2018[i, "code"]
    if (nchar(icd) == 3L) {
      current_major <- icd10fr2018[i, "desc_long"]
      current_three_digit <- icd
    }
    icd10fr2018[i, "major"] <- current_major
    icd10fr2018[i, "three_digit"] <- current_three_digit
  }

  if (save) save_in_data_dir(icd10fr2018)
  invisible(icd10fr2018)
}

#' Get French and Dutch translations of ICD-10-CM for Beglian coding
#' @references \url{https://www.health.belgium.be/fr/sante/organisation-des-soins-de-sante/hopitaux/systemes-denregistrement/icd-10-be}
#' \url{https://www.health.belgium.be/fr/fy2014reflisticd-10-bexlsx}
#' @param ... passed to `download_to_data_raw`, e.g., `offline = FALSE`.
#' @keywords internal
parse_icd10cm_be <- function(save_data = FALSE, ...) {
  # It is actually in English! Seems to just be a copy of the US version.
  # There is currently nothing later than 2014.
  #
  #https://www.health.belgium.be/sites/default/files/uploads/fields/fpshealth_theme_file/fy2014_icd-10-cm.txt

  # this however is an excel sheet with French English and Dutch translations of ICD-10-CM. Not sure yet whether they also modified the codes themselves.
  url <- "https://www.health.belgium.be/sites/default/files/uploads/fields/fpshealth_theme_file/fy2014_reflist_icd-10-be.xlsx"
  fnp <- download_to_data_raw(url, ...)
  raw <- readxl::read_xlsx(fnp$file_path,
                           sheet = "FY2014_ICD10BE",
                           col_names = TRUE,
                           guess_max = 1e6,
                           progress = FALSE)
  raw <- raw[c("ICDCODE",
               "ICDDORO", # O for procedure, D for diagnostic
               "ICDPREC", # this if flag for NOT leaf node
               "ICDFLSEX", # M/F specific, or empty for either
               "ICDFLAGE", # FLAG AGE (A=Adult 15-124y; M=Maternity 12-55y; N=Newborn and Neonates 0y; P=Pediatric 0-17y)
               "ICDNOPOA", # effectively this is flag for leaf node
               "ICDTXTFR",
               "ICDTXTNL",
               "ICDTXTEN",
               "SHORT_TXTFR",
               "SHORT_TXTNL",
               "SHORT_TXTEN")]
  raw_dx <- as.data.frame(raw[raw$ICDDORO == "D", -2])
  raw_pc <- as.data.frame(raw[raw$ICDDORO == "O", -2])
  common_names <- c("code", "not_leaf", "sex", "age_group", "leaf")
  names(raw_dx)[1:5] <- common_names
  names(raw_pc)[1:5] <- common_names
  icd10cm2014_fr <- raw_dx[c(common_names, "ICDTXTFR", "SHORT_TXTFR")]
  icd10cm2014_nl <- raw_dx[c(common_names, "ICDTXTNL", "SHORT_TXTNL")]
  #icd10cm2014_en <- raw_dx[c(common_names, "ICDTXTEN", "SHORT_TXTEN")]
  icd10cm2014_pc_fr <- raw_pc[c(common_names, "ICDTXTFR", "SHORT_TXTFR")]
  icd10cm2014_pc_nl <- raw_pc[c(common_names, "ICDTXTNL", "SHORT_TXTNL")]
  #icd10cm2014_pc_en <- raw_pc[c(common_names, "ICDTXTEN", "SHORT_TXTEN")]
  names(icd10cm2014_fr)[6:7] <- c("long_desc", "short_desc")
  names(icd10cm2014_nl)[6:7] <- c("long_desc", "short_desc")
  #names(icd10cm2014_en)[6:7] <- c("long_desc", "short_desc")
  names(icd10cm2014_pc_fr)[6:7] <- c("long_desc", "short_desc")
  names(icd10cm2014_pc_nl)[6:7] <- c("long_desc", "short_desc")
  #names(icd10cm2014_pc_en)[6:7] <- c("long_desc", "short_desc")
  icd10cm2014_fr <- icd10cm2014_fr[order(raw_dx$code), c(1:5, 7, 6)]
  icd10cm2014_nl <- icd10cm2014_nl[order(raw_dx$code), c(1:5, 7, 6)]
  #icd10cm2014_en <- icd10cm2014_en[order(raw_dx$code), c(1:5, 7, 6)]
  icd10cm2014_pc_fr <- icd10cm2014_pc_fr[order(raw_pc$code), c(1:5, 7, 6)]
  icd10cm2014_pc_nl <- icd10cm2014_pc_nl[order(raw_pc$code), c(1:5, 7, 6)]
  #icd10cm2014_pc_en <- icd10cm2014_pc_en[order(raw_dx$code), c(1:5, 7, 6)]
  if (save_data) {
    save_in_data_dir(icd10cm2014_fr)
    save_in_data_dir(icd10cm2014_nl)
    #    save_in_data_dir(icd10cm2014_en)
    save_in_data_dir(icd10cm2014_pc_fr)
    save_in_data_dir(icd10cm2014_pc_nl)
    #    save_in_data_dir(icd10cm2014_pc_en)
  }
  invisible(list(icd10cm2014_fr,
                 icd10cm2014_nl,
                 #                 icd10cm2014_en,
                 icd10cm2014_pc_fr,
                 icd10cm2014_pc_nl
                 #                 icd10cm2014_pc_en
  ))
}

# internal analysis
compare_cm_to_be_cm <- function() {
  # BE version is identical to ICD-10-CM frmo 2014, across all languages
  stopifnot(nrow(icd10cm2014) == nrow(icd10cm2014_fr))
  #stopifnot(length(setdiff(icd10cm2014$code, icd10cm2014_en$code)) == 0) # just in CM
  #stopifnot(length(setdiff(icd10cm2014_en$code, icd10cm2014$code)) == 0) # just in BE
  stopifnot(length(setdiff(icd10cm2014$code, icd10cm2014_fr$code)) == 0) # just in CM
  stopifnot(length(setdiff(icd10cm2014_fr$code, icd10cm2014$code)) == 0) # just in BE
  stopifnot(length(setdiff(icd10cm2014$code, icd10cm2014_nl$code)) == 0) # just in CM
  stopifnot(length(setdiff(icd10cm2014_nl$code, icd10cm2014$code)) == 0) # just in BE
  stopifnot(nrow(icd10cm2014_pc) == nrow(icd10cm2014_pc_fr))
  stopifnot(length(setdiff(as.character(trimws(icd10cm2014_pc$pcs)),
                           icd10cm2014_pc_fr$code)) == 0) # just in CM
  stopifnot(length(setdiff(icd10cm2014_pc_fr$code,
                           as.character(trimws(icd10cm2014_pc$pcs)))) == 0) # just in BE
  stopifnot(length(setdiff(as.character(trimws(icd10cm2014_pc$pcs)),
                           icd10cm2014_pc_nl$code)) == 0) # just in CM
  stopifnot(length(setdiff(icd10cm2014_pc_nl$code,
                           as.character(trimws(icd10cm2014_pc$pcs)))) == 0) # just in BE
}
compare_cm_to_be_cm <- NULL
