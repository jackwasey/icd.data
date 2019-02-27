# nocov start
#
# Prefer CMS? NCHS actually generates the ICD-10-CM codes, at least the
# diagnostic ones. http://www.cdc.gov/nchs/data/icd/icd10cm/

icd10cm_get_flat_file_cdc <- function(...) {
  icd10_url_cdc <- "http://www.cdc.gov/nchs/data/icd/icd10cm/"
  unzip_to_data_raw(
    url = paste0(icd10_url_cdc, "2016/ICD10CM_FY2016_code_descriptions.zip"),
    file_name = "icd10cm_order_2016.txt", ...)
}

#' Get annual version of ICD-10-CM
#' @param year four-digit
#' @param ... passed through, e.g., `offline = FALSE`
icd10cm_get_flat_file <- function(year, ...) {
  y <- icd10cm_sources[[as.character(year)]]
  unzip_to_data_raw(
    paste0(y$base_url, y$dx_zip),
    # dx_leaf is same, just leaves
    file_name = y$dx_hier,
    ...)
}

#' Fetch ICD-10-CM data from the CMS web site
#'
#' YEAR-ICD10-Code-Descriptions has flat files, YEAR-ICD10-Code-Tables-Index has
#' XML
#' @keywords internal
fetch_icd10cm_all <- function(verbose = FALSE, ...) {
  for (year in as.character(2014:2019)) {
    for (dx in c(TRUE, FALSE)) {
      if (verbose) message("Working on year: ", year, " and dx is ", dx)
      fetch_icd10cm_year(year, dx = dx, verbose = verbose, ...)
    }
  }
}

#' @rdname fetch_icd10cm_all
#' @keywords internal
#' @noRd
fetch_icd10cm_year <- function(
  year = 2019,
  dx = TRUE,
  verbose = FALSE,
  ...
) {
  stopifnot(is.numeric(year) || is.character(year), length(year) == 1)
  year <- as.character(year)
  stopifnot(is.logical(dx), length(dx) == 1)
  stopifnot(is.logical(verbose), length(verbose) == 1)
  stopifnot(as.character(year) %in% names(icd10cm_sources))
  if (verbose) message(ifelse(dx, "dx", "pcs"))
  s <- icd10cm_sources[[year]]
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
  if (verbose) message("url = ", url, " and file_name = ", file_name)
  unzip_to_data_raw(url = url,
                    file_name = file_name,
                    verbose = verbose,
                    save_name = get_annual_data_path(file_name,
                                                     year,
                                                     full_path = FALSE),
                    ...)
}

#' Get the raw data directory
#'
#' Following Hadley Wickham recommendations in R Packages, this should be in
#' \code{inst/extdata}. \pkg{devtools} overrides \code{system.file}.
#' @noRd
#' @keywords internal
get_raw_data_dir <- function() {
  system.file("data-raw", package = "icd.data")
}

get_annual_data_path <- function(base_name, year, full_path = TRUE) {
  if (full_path)
    file.path(get_raw_data_dir(),
              paste0("yr", year, "_", base_name))
  else
    file.path(paste0("yr", year, "_", base_name))
}

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
save_in_data_dir <- function(
  var_name,
  suffix = "",
  data_path = "data",
  package_dir = getwd(),
  envir = parent.frame()
) {
  stopifnot(is.character("suffix"))
  if (!is.character(var_name))
    var_name <- as.character(substitute(var_name))
  stopifnot(exists(var_name, envir = envir))
  stopifnot(is.character(var_name))
  stopifnot(exists(var_name, envir = envir))
  save(list = var_name,
       envir = envir,
       file = file.path(package_dir, data_path,
                        strip(paste0(var_name, suffix, ".RData"))),
       compress = "xz")
  message("Now reload package to enable updated/new data: ", var_name)
  invisible(get(var_name, envir = envir))
}

#' unzip a single file from URL
#'
#' take a single file from zip located at a given URL, unzip into temporary
#' directory, and copy to the given \code{save_path}
#' @param url URL of a zip file
#' @param file_name file name of the resource within the zip file
#' @param save_path file path to save the first file from the zip
#' @param insecure Logical value, wil disable certificate check which fails on
#'   some platforms for some ICD data from CDC and CMS, probably because of TLS
#'   version or certificate key length issues. Default is \code{TRUE}.
#' @template verbose
#' @param ... additional arguments passed to \code{utils::download.file}
#' @keywords internal
#' @noRd
unzip_single <- function(
  url,
  file_name,
  save_path,
  insecure = TRUE,
  verbose = FALSE,
  ...
) {
  stopifnot(is.character(url))
  stopifnot(is.character(file_name))
  stopifnot(is.character(save_path))
  zipfile <- tempfile(fileext = ".zip")
  on.exit(unlink(zipfile), add = TRUE)
  extra <- ifelse(insecure, "--insecure --silent", NULL)
  dl_code <- utils::download.file(url = url,
                                  destfile = zipfile,
                                  quiet = !verbose,
                                  method = "curl",
                                  #mode = "wb", # not used for method curl
                                  extra = extra,
                                  ...)
  stopifnot(dl_code == 0)
  # I do want tempfile, so I get an empty new directory
  zipdir <- tempfile()
  on.exit(unlink(zipdir), add = TRUE)
  dir.create(zipdir)
  file_paths <- utils::unzip(zipfile, exdir = zipdir)
  if (length(file_paths) == 0) stop("No files found in zip")
  files <- list.files(zipdir)
  if (length(files) == 0) stop("No files in unzipped directory")
  if (missing(file_name)) {
    if (length(files) == 1) {
      file_name <- files
    } else {
      stop("multiple files in zip, but no file name specified: ",
           paste(files, collapse = ", "))
    }
  } else {
    if (!file_name %in% files) {
      message("files")
      print(files)
      message("file_name")
      print(file_name)
      stop(paste(file_name, " not found in ", paste(files, collapse = ", ")))
    }
  }
  ret <- file.copy(file.path(zipdir, file_name), save_path, overwrite = TRUE)
  unlink(zipdir, recursive = TRUE)
  ret
}

# nocov end
