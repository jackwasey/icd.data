#' Get or set the annual version of ICD-10-CM to use
#' @param ver Four digit year (may be a version string in future, e.g., "2021b")
#' @param check_exists \code{TRUE} by default, which forces a check that the
#'   requested version is actually available in this R session.
#' @export
set_icd10cm_active_ver <- function(ver, check_exists = TRUE) {
  ver <- as.character(ver)
  stopifnot(nchar(ver) == 4L)
  stopifnot(ver %in% names(icd10cm_sources))
  if (check_exists)
    stopifnot(exists(paste0("icd10cm", ver), inherits = TRUE))
  options("icd.data.icd10cm_active_ver" = ver)
  invisible(ver)
}

#' @rdname set_icd10cm_active_ver
#' @export
get_icd10cm_active_ver <- function() {
  ver <- getOption("icd.data.icd10cm_active_ver")
  if (!is.character(ver) && length(ver) == 1)
    stop("Option \"icd.data.icd10cm_active_ver\" is not valid.\n",
         "Reset it with set_icd10cm_active_ver(\"2019\") ",
         "or other year version.")
  ver
}

#' Get the data for a given version (four-digit year) of ICD-10-CM
#' @param ver Version, currently this is always four-digit year
#' @examples
#' \dontrun{
#' get_icd10cm_version("2018")
#' }
#' @export
get_icd10cm_version <- function(ver = get_icd10cm_active_ver()) {
  list(
    "2014" = icd.data::icd10cm2014,
    "2015" = icd.data::icd10cm2015,
    "2016" = icd.data::icd10cm2016,
    "2017" = icd.data::icd10cm2017,
    "2018" = icd.data::icd10cm2018,
    "2019" = icd.data::icd10cm2019
  )[[ver]]
}

#' Get the data for the latest ICD-10-CM version in this package.
#'
#' Usually, the `icd.data` package should be attached, and therefore appear on
#' the search list, using `library(icd.data)` or `require(icd.data)`. If it is
#' not attached, the active binding `icd10cm_latest` cannot find the packages
#' own data! This function is a possible work-around to get the data without
#' having to attach the package.
#' @examples
#' \dontrun{
#' # if icd.data not attached:
#' get_icd10cm_latest()
#' # preferred:
#' library(icd.data)
#' head(icd10cm_latest)
#'
#' }
#' @keywords internal
#' @noRd
#' @keywords datasets
get_icd10cm_latest <- function() {
  var_name <- "icd10cm2019"
  if (exists(var_name)) return(get(var_name))
  eval(parse(text = paste0("icd.data::", var_name)))
}

.icd10cm_active_binding <- function(x) {
  if (!missing(x)) stop("This binding returns the active ICD-10-CM data.\n",
                        "Use `set_icd10cm_active_ver(\"2019\") instead.")
  # for now, hard code this to avoid complicated namespace issues, even if
  # icd.data is in "Imports" of another package.
  list(
    "2014" = icd.data::icd10cm2014,
    "2015" = icd.data::icd10cm2015,
    "2016" = icd.data::icd10cm2016,
    "2017" = icd.data::icd10cm2017,
    "2018" = icd.data::icd10cm2018,
    "2019" = icd.data::icd10cm2019
  )[[get_icd10cm_active_ver()]]
}

.icd10cm_latest_binding <- function(x) {
  if (!missing(x)) stop("This binding returns the latest ICD-10-CM data.\n")
  icd.data::icd10cm2019
}

#' Latest ICD-9-CM edition
#'
#' Returns a single character value with the number of the latest edition,
#' currently \strong{32}.
#'
#' Implemented as a function to give flexibility to calculate this, or use an
#' option override. Duplicated in \code{icd.data} package.
#'
#' @keywords internal
icd9cm_latest_edition <- function() "32"
