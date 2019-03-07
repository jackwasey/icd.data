# Prefer CMS? NCHS actually generates the ICD-10-CM codes, at least the
# diagnostic ones. http://www.cdc.gov/nchs/data/icd/icd10cm/

# .icd10cm_get_flat_file_cdc <- function(...) {
#   icd10_url_cdc <- "http://www.cdc.gov/nchs/data/icd/icd10cm/"
#   .unzip_to_data_raw(
#     url = paste0(icd10_url_cdc, "2016/ICD10CM_FY2016_code_descriptions.zip"),
#     file_name = "icd10cm_order_2016.txt", ...
#   )
# }

# #' Get annual version of ICD-10-CM
# #' @param year four-digit
# #' @param ... passed through, e.g., `offline = FALSE`
# .icd10cm_get_flat_file <- function(year, verbose = TRUE, ...) {
#   if (verbose) message("Getting flat file for year: ", year)
#   y <- icd10cm_sources[[as.character(year)]]
#   .unzip_to_data_raw(
#     url = paste0(y$base_url, y$dx_zip),
#     # dx_leaf is same, just leaves
#     file_name = y$dx_hier,
#     save_name = .get_versioned_raw_file_name(y$dx_hier, year),
#     ...
#   )
# }

#' Fetch ICD-10-CM data from the CMS web site
#'
#' YEAR-ICD10-Code-Descriptions has flat files, YEAR-ICD10-Code-Tables-Index has
#' XML
#' @keywords internal
.fetch_icd10cm_all <- function(verbose = FALSE, ...) {
  for (year in names(icd10cm_sources)) {
    for (dx in c(TRUE, FALSE)) {
      if (verbose) {
        message(
          "Working on year ", year,
          ifelse(dx, "diagnostic", "procedure"),
          "codes"
        )
      }
      .fetch_icd10cm_ver(year,
        dx = dx,
        verbose = verbose,
        ...
      )
    }
  }
}

#' @rdname .fetch_icd10cm_all
#' @keywords internal
#' @noRd
.fetch_icd10cm_ver <- function(ver,
                               dx,
                               save_data = TRUE,
                               parse = FALSE,
                               raw_data_dir = get_resource_dir(),
                               verbose = TRUE,
                               ...) {
  message("Please wait a moment to download (or use cached) ~1-10MB of data...")
  stopifnot(is.numeric(ver) || is.character(ver), length(ver) == 1)
  ver <- as.character(ver)
  stopifnot(is.logical(dx), length(dx) == 1)
  stopifnot(is.logical(verbose), length(verbose) == 1)
  stopifnot(as.character(ver) %in% names(icd10cm_sources))
  if (verbose) message(ifelse(dx, "dx", "pcs"))
  s <- icd10cm_sources[[ver]]
  url <- paste0(s$base_url, s$dx_zip)
  # fox dx codes, get either the hier or just leaf flat file here:
  file_name <- s$dx_hier
  if (!dx) {
    if ("pcs_zip" %nin% names(s) || is.na(s$pcs_zip)) {
      if (verbose) message("No PCS flat file zip name.")
      return()
    }
    url <- paste0(s$base_url, s$pcs_zip)
    file_name <- s$pcs_flat
  }
  stopifnot(!is.null(file_name))
  if (is.na(file_name)) {
    if (verbose) message("No PCS file name.")
    return()
  }
  save_name <- .get_versioned_raw_file_name(file_name, ver)
  if (verbose) {
    message(
      "url = ", url,
      "\nfile_name = ", file_name,
      "\nsave_name = ", save_name
    )
  }
  if (getOption("icd.data.offline")) {
    .confirm_download(must_work = FALSE)
  }
  if (save_data) {
    fp <- .unzip_to_data_raw(
      url = url,
      file_name = file_name,
      verbose = verbose,
      save_name = save_name,
      data_raw_path = raw_data_dir,
      ...
    )
  }
  if (!parse) return(fp)
  if (dx) {
    .icd10cm_parse_year(
      year = ver,
      save_data = save_data,
      verbose = verbose
    )
  } else {
    .icd10cm_parse_cms_pcs_year(
      year = ver,
      save_data = save_data,
      verbose = verbose
    )
  }
}

.fetch_icd10cm2014 <- function() {
  .fetch_icd10cm_ver(ver = 2014, dx = TRUE, parse = TRUE)
}

.fetch_icd10cm2015 <- function() {
  .fetch_icd10cm_ver(ver = 2015, dx = TRUE, parse = TRUE)
}
# 2016 dx is currently built into package for compatibility with icd < 4.0
.fetch_icd10cm2016_pc <- function() {
  .fetch_icd10cm_ver(ver = 2016, dx = FALSE, parse = TRUE)
}

.fetch_icd10cm2017 <- function() {
  .fetch_icd10cm_ver(ver = 2017, dx = TRUE, parse = TRUE)
}

.fetch_icd10cm2018 <- function() {
  .fetch_icd10cm_ver(ver = 2018, dx = TRUE, parse = TRUE)
}

.fetch_icd10cm2014_pc <- function() {
  .fetch_icd10cm_ver(ver = 2014, dx = FALSE, parse = TRUE)
}

.fetch_icd10cm2015_pc <- function() {
  .fetch_icd10cm_ver(ver = 2015, dx = FALSE, parse = TRUE)
}

.fetch_icd10cm2017_pc <- function() {
  .fetch_icd10cm_ver(ver = 2017, dx = FALSE, parse = TRUE)
}

.fetch_icd10cm2018_pc <- function() {
  .fetch_icd10cm_ver(ver = 2018, dx = FALSE, parse = TRUE)
}
# The latest version (2019) is currently built into package
.fetch_icd10cm2019_pc <- function() {
  .fetch_icd10cm_ver(ver = 2019, dx = FALSE, parse = TRUE)
}
