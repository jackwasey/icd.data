#' Read the definitions of the French edition of ICD-10
#'
#' The short descriptions are capitalized, with accented characters, so leaving as is.
#' @template save_data
#' @keywords internal
parse_cim_fr <- function(save_data = FALSE, ...) {
  fp <- unzip_to_data_raw(
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

#' Get French and Dutch translations of ICD-10-CM for Beglian coding
#'
#' There are public domain publications for 2014 and 2017. Not all items are
#' translated from English. Between 2014 and 2017, ICDLST and ICDLSTR fields 13
#' and 14 were removed.
#' @references
#' \url{https://www.health.belgium.be/fr/sante/organisation-des-soins-de-sante/hopitaux/systemes-denregistrement/icd-10-be}
#' \url{https://www.health.belgium.be/sites/default/files/uploads/fields/fpshealth_theme_file/fy2017_reflist_icd-10-be.xlsx_last_updatet_28-07-2017_1.xlsx}
#' \url{https://www.health.belgium.be/fr/fy2014reflisticd-10-bexlsx}
#' @param ... passed to `download_to_data_raw`, e.g., `offline = FALSE`.
#' @seealso \code{link{parse_icd10be2014_be}}
#' @keywords internal
parse_icd10be2017 <- function(save_data = FALSE, ...) {
  # MS Excel sheet with French English and Dutch translations of ICD-10-CM.
  # Currently all the codes are identical to ICD-10-CM US version.
  site <- "https://www.health.belgium.be"
  site_path <- "sites/default/files/uploads/fields/fpshealth_theme_file"
  site_file_2017 <-
    "fy2017_reflist_icd-10-be.xlsx_last_updatet_28-07-2017_1.xlsx"
  sheet_2017 <- "FY2017"
  fnp <- .download_to_data_raw(
    paste(site,
      site_path,
      site_file_2017,
      sep = "/"
    ),
    ...
  )
  raw_dat <- readxl::read_xlsx(fnp$file_path,
    sheet = sheet_2017,
    col_names = TRUE,
    guess_max = 1e6,
    progress = FALSE
  )
  raw_dat <- raw_dat[c(
    "ICDCODE",
    # O for procedure, D for diagnostic
    "ICDDORO",
    # this if flag for NOT leaf node, * or blank.
    "ICDPREC",
    # FLAG AGE
    # A=Adult 15-124y;
    # M=Maternity 12-55y;
    # N=Newborn and Neonates 0y;
    # P=Pediatric 0-17y)
    "ICDTXTFR",
    "ICDTXTNL",
    "ICDTXTEN",
    "SHORT_TXTFR",
    "SHORT_TXTNL",
    "SHORT_TXTEN"
  )]
  raw_dat[["ICDPREC"]] <- raw_dat[["ICDPREC"]] != "*"
  icd10be2017 <- as.data.frame(raw_dat[raw_dat$ICDDORO == "D", -2])
  icd10be2017_pc <- as.data.frame(raw_dat[raw_dat$ICDDORO == "O", -2])
  names <- c(
    "code",
    "leaf",
    "long_desc_fr",
    "long_desc_nl",
    "long_desc_en",
    "short_desc_fr",
    "short_desc_nl",
    "short_desc_en"
  )
  names(icd10be2017) <- names
  names(icd10be2017_pc) <- names
  icd10be2017 <- icd10be2017[.get_icd34fun("order.icd10be")(icd10be2017$code), ]
  icd10be2017_pc <- icd10be2017_pc[order(icd10be2017_pc$code), ]
  class(icd10be2017$code) <- c("icd10be", "icd10", "character")
  class(icd10be2017_pc$code) <- c("icd10be_pc", "character")
  row.names(icd10be2017) <- NULL
  row.names(icd10be2017_pc) <- NULL
  if (save_data) {
    .save_in_resource_dir(icd10be2017)
    .save_in_resource_dir(icd10be2017_pc)
  }
  invisible(list(icd10be2017, icd10be2017_pc))
}

#' Get 2014 French and Dutch translations of ICD-10-CM for Beglian coding
#' @references \url{https://www.health.belgium.be/fr/sante/organisation-des-soins-de-sante/hopitaux/systemes-denregistrement/icd-10-be}
#' \url{https://www.health.belgium.be/fr/fy2014reflisticd-10-bexlsx}
#' @param ... passed to `.download_to_data_raw`, e.g., `offline = FALSE`.
#' @seealso \code{link{parse_icd10be2014_be}}
#' @keywords internal
parse_icd10be2014 <- function(save_data = FALSE, ...) {
  # MS Excel sheet with French English and Dutch translations of ICD-10-CM. Not
  # sure yet whether they also modified the codes themselves.
  site <- "https://www.health.belgium.be"
  site_path <- "sites/default/files/uploads/fields/fpshealth_theme_file"
  site_file <- "fy2014_reflist_icd-10-be.xlsx"
  fnp <- .download_to_data_raw(
    paste(site, site_path, site_file, sep = "/"),
    ...
  )
  raw_dat <- readxl::read_xlsx(fnp$file_path,
    sheet = "FY2014_ICD10BE",
    col_names = TRUE,
    guess_max = 1e6,
    progress = FALSE
  )
  raw_dat <- raw_dat[c(
    "ICDCODE",
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
    "SHORT_TXTEN"
  )]
  raw_dat[["ICDPREC"]] <- raw_dat[["ICDPREC"]] != "*"
  icd10be2014 <- as.data.frame(raw_dat[raw_dat$ICDDORO == "D", -2])
  icd10be2014_pc <- as.data.frame(raw_dat[raw_dat$ICDDORO == "O", -2])
  names <- c(
    "code",
    "leaf",
    "sex",
    "age_group",
    "not_poa",
    "long_desc_fr",
    "long_desc_nl",
    "long_desc_en",
    "short_desc_fr",
    "short_desc_nl",
    "short_desc_en"
  )
  names(icd10be2014) <- names
  names(icd10be2014_pc) <- names
  icd10be2014 <- icd10be2014[.get_icd34fun("order.icd10be")(icd10be2014$code), ]
  icd10be2014_pc <- icd10be2014_pc[order(icd10be2014_pc$code), ]
  class(icd10be2014$code) <- c("icd10be", "icd10", "character")
  class(icd10be2014_pc$code) <- c("icd10be_pc", "character")
  row.names(icd10be2014) <- NULL
  row.names(icd10be2014_pc) <- NULL
  if (save_data) {
    .save_in_resource_dir(icd10be2014)
    .save_in_resource_dir(icd10be2014_pc)
  }
  invisible(list(icd10be2014, icd10be2014_pc))
}
