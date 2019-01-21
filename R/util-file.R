#nocov start
icd10_url_cdc <- "http://www.cdc.gov/nchs/data/icd/icd10cm/"

icd10cm_get_flat_file <- function(...) {
  unzip_to_data_raw(
    url = paste0(icd10_url_cdc, "2016/ICD10CM_FY2016_code_descriptions.zip"),
    file_name = "icd10cm_order_2016.txt", ...)
}

#' Fetch ICD-10-CM data from the CMS web site
#'
#' YEAR-ICD10-Code-Descriptions has flat files, YEAR-ICD10-Code-Tables-Index has
#' XML
#' @keywords internal
fetch_icd10cm_all <- function(verbose = FALSE, ...) {
  for (year in as.character(2014:2018)) {
    for (dx in c(TRUE, FALSE)) {
      if (verbose) message("Working on year: ", year, " and dx is ", dx)
      fetch_icd10cm_year(year, dx = dx, verbose = verbose, ...)
    }
  }
}

#' @rdname fetch_icd10cm_all
#' @keywords internal
#' @noRd
fetch_icd10cm_year <- function(year = "2018", dx = TRUE,
                               verbose = FALSE, offline = FALSE, ...) {
  stopifnot(is.character(year), length(year) == 1)
  stopifnot(is.logical(dx), length(dx) == 1)
  stopifnot(is.logical(verbose), length(verbose) == 1)
  stopifnot(is.logical(offline), length(offline) == 1)
  stopifnot(year %in% names(icd::icd10_sources))
  if (verbose) message(ifelse(dx, "dx", "pcs"))
  s <- icd::icd10_sources[[year]]
  url <- paste0(s$base_url, s$dx_zip)
  file_name <- s$dx_flat
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
  if (verbose) message("url = ", url, " and file_name = ", file_name)
  unzip_to_data_raw(url = url,
                    file_name = file_name,
                    verbose = verbose,
                    offline = offline, ...)
}

#' Get the raw data directory
#'
#' Following Hadley Wickham recommendations in R Packages, this should be in
#' \code{inst/extdata}. \pkg{devtools} overrides \code{system.file}.
#' @noRd
#' @keywords internal
get_raw_data_dir <- function()
  system.file("extdata", package = "icd")


#' Save given variable in package data directory
#'
#' File is named \code{varname.RData} with an optional suffix before
#' \code{.RData}
#'
#' @param var_name character name of variable or its symbol either of which
#'   would find \code{myvar} in the parent environment, and save it as
#'   \code{myvar.RData} in \code{package_root/data}.
#' @param suffix character scalar
#' @param data_path path to data directory, default is data in current
#'   directory.
#' @param package_dir character containing the directory root of the package
#'   tree in which to save the data. Default is the current working directory.
#' @param envir environment in which to look for the variable to save
#' @return invisibly returns the data
#' @keywords internal
#' @noRd
save_in_data_dir <- function(var_name, suffix = "", data_path = "data",
                             package_dir = getwd(), envir = parent.frame()) {
  stopifnot(is.character("suffix"))
  if (!is.character(var_name))
    var_name <- as.character(substitute(var_name))
  stopifnot(exists(var_name, envir = envir))
  stopifnot(is.character(var_name))
  stopifnot(exists(var_name, envir = envir))
  save(list = var_name,
       envir = envir,
       file = file.path(package_dir, data_path,
                        strip(paste0(var_name, suffix, ".rda"))),
       compress = "xz")
  message("Now reload package to enable updated/new data: ", var_name)
  invisible(get(var_name, envir = envir))
}
#nocov end
