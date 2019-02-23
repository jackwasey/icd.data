#' Get or set the annual version of ICD-10-CM to use
#' @template ver
#' @param check_exists \code{TRUE} by default, which forces a check that the
#'   requested version is actually available in this R session.
#' @export
set_icd10cm_active_ver <- function(ver, check_exists = TRUE) {
  old_v <- get_icd10cm_active_ver()
  v <- as.character(ver)
  stopifnot(grepl("^[[:digit:]]{4}$", as.character(v)))
  stopifnot(v %in% names(icd10cm_sources))
  v_name <- paste0("icd10cm", v)
  if (check_exists &&
      !exists(v_name, envir = asNamespace("icd.data"))) {
    stopifnot(exists_in_ns(v_name))
  }
  options("icd.data.icd10cm_active_ver" = v)
  invisible(old_v)
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
#'
#' When called without an argument, it returns the curerntly active version as
#' set by \code{set_icd10cm_active_ver()}
#' @template ver
#' @examples
#' \dontrun{
#' get_icd10cm_version("2018")
#' }
#' @export
get_icd10cm_version <- function(ver = get_icd10cm_active_ver()) {
  ver <- as.character(ver)
  stopifnot(grepl("^[[:digit:]]{4}$", ver))
  switch(ver,
         "2014" = icd.data::icd10cm2014,
         "2015" = icd.data::icd10cm2015,
         "2016" = icd.data::icd10cm2016,
         "2017" = icd.data::icd10cm2017,
         "2018" = icd.data::icd10cm2018,
         "2019" = icd.data::icd10cm2019
  )
}

#' Get the ICD-10-CM versions available in this package
#' @template pc
#' @param return_year Logical, which, if `TRUE`, will result in only a character
#'   vector of year (or year-like version) being returned.
#' @examples
#'   # Diagnostic codes:
#'   get_icd10cm_available()
#'   # Just get the years avaiable for English language procedure codes
#'   get_icd10cm_available(pc = TRUE, return_year = TRUE)
#' @export
get_icd10cm_available <- function(
  pc = FALSE,
  return_year = FALSE
) {
  stopifnot(is.logical(pc), length(pc) == 1)
  pc_str <- ifelse(pc, "_pc", "")
  res <- as.character(2014:2019)
  if (return_year)
    res
  else
    paste0("icd10cm", res, pc_str)
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
#' @keywords internal datasets
get_icd10cm_latest <- function() {
  var_name <- "icd10cm2019"
  if (exists(var_name)) return(get(var_name))
  getExportedValue(asNamespace("icd.data"), var_name)
  eval(parse(text = paste0("icd.data::", var_name)))
}

.icd10cm_active_binding <- function(x) {
  if (!missing(x)) stop("This binding returns the active ICD-10-CM data.\n",
                        "Use `set_icd10cm_active_ver(\"2019\") instead.")
  get_icd10cm_version()
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
#' @keywords internal
icd9cm_latest_edition <- function() "32"

#' Evaluate code with a particular version of ICD-10-CM
#' @template ver
#' @param code Code block to execute
#' @export
with_icd10cm_version <- function(ver, code) {
  stopifnot(is.character(ver), length(ver) == 1)
  old <- options("icd.data.icd10cm_active_ver" = ver)
  on.exit(options(old))
  force(code)
}
