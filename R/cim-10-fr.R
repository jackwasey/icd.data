#' Read the definitions of the French edition of ICD-10
#'
#' The short descriptions are capitalized, with accented characters, so leaving as is.
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
  names(icd10fr2019) <- c("code", "short_desc", "long_desc")
  icd10fr2019$desc_short <- enc2utf8(icd10fr2019$desc_short)
  icd10fr2019$desc_long <- enc2utf8(icd10fr2019$desc_long)
  icd10fr2019[["code"]] <- trimws(icd10fr2019[["code"]])
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
  # TODO: chapters and sub-chapters as factors
  if (save_data)
    save_in_data_dir(icd10fr2019)
  invisible(icd10fr2019)
}

#' Get French and Dutch translations of ICD-10-CM for Beglian coding
#' @references \url{https://www.health.belgium.be/fr/sante/organisation-des-soins-de-sante/hopitaux/systemes-denregistrement/icd-10-be}
#' \url{https://www.health.belgium.be/fr/fy2014reflisticd-10-bexlsx}
#' @param ... passed to `download_to_data_raw`, e.g., `offline = FALSE`.
#' @keywords internal
parse_icd10cm_be <- function(save_data = FALSE, ...) {
  # MS Excel sheet with French English and Dutch translations of ICD-10-CM. Not
  # sure yet whether they also modified the codes themselves.
  site <- "https://www.health.belgium.be"
  site_path <- "sites/default/files/uploads/fields/fpshealth_theme_file"
  site_file <- "fy2014_reflist_icd-10-be.xlsx"
  fnp <- download_to_data_raw(paste(site, site_path, site_file, sep = "/"), ...)
  raw <- readxl::read_xlsx(fnp$file_path,
                           sheet = "FY2014_ICD10BE",
                           col_names = TRUE,
                           guess_max = 1e6,
                           progress = FALSE)
  raw <- raw[c("ICDCODE",
               "ICDDORO", # O for procedure, D for diagnostic
               "ICDPREC", # this if flag for NOT leaf node
               "ICDFLSEX", # M/F specific, or empty for either
               # FLAG AGE
               # A=Adult 15-124y;
               # M=Maternity 12-55y;
               # N=Newborn and Neonates 0y;
               # P=Pediatric 0-17y)
               "ICDFLAGE",
               # effectively NOPOA is flag for leaf node
               "ICDNOPOA",
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
