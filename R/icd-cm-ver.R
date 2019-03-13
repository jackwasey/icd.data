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
    stopifnot(.exists_in_ns(v_name))
  }
  options("icd.data.icd10cm_active_ver" = v)
  invisible(old_v)
}

#' @rdname set_icd10cm_active_ver
#' @export
get_icd10cm_active_ver <- function() {
  ver <- getOption("icd.data.icd10cm_active_ver", default = "2019")
  ver <- as.character(ver)
  if (!grepl("^[[:digit:]]+$", ver)) {
    stop(
      "Option \"icd.data.icd10cm_active_ver\" is not valid.\n",
      "Reset it with set_icd10cm_active_ver(\"2019\") ",
      "or other year version."
    )
  }
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
  # don't use :: so we don't trigger every active binding at once!
  var_name <- paste0("icd10cm", ver)
  if (exists(var_name, envir = .icd_data_env)) {
    return(get(var_name, envir = .icd_data_env))
  }
  getExportedValue("icd.data", var_name)
}

#' Get the ICD-10-CM versions available in this package
#' @template pc
#' @param return_year Logical, which, if `TRUE`, will result in only a character
#'   vector of year (or year-like version) being returned.
#' @examples
#' # Diagnostic codes:
#' get_icd10cm_available()
#' # Just get the years avaiable for English language procedure codes
#' get_icd10cm_available(pc = TRUE, return_year = TRUE)
#' @export
get_icd10cm_available <- function(
                                  pc = FALSE,
                                  return_year = FALSE) {
  stopifnot(is.logical(pc), length(pc) == 1)
  pc_str <- ifelse(pc, "_pc", "")
  res <- as.character(2014:2019)
  if (return_year) {
    res
  } else {
    paste0("icd10cm", res, pc_str)
  }
}

#' Get the data for the latest ICD-10-CM version in this package.
#'
#' Usually, the `icd.data` package should be attached, and therefore appear on
#' the search list, using `library(icd.data)` or `require(icd.data)`. If it is
#' not attached, the active binding `icd10cm_latest` cannot find the packages
#' own data! This function is a possible work-around to get the data without
#' having to attach the package.
#' @examples
#' # if icd.data not attached:
#' a <- icd.data::icd10cm_latest
#' b <- icd.data:::.get_icd10cm_latest()
#' stopifnot(identical(a, b))
#' # Preferred:
#' \dontrun{
#' library(icd.data)
#' head(icd10cm_latest)
#' }
#' @keywords internal datasets
.get_icd10cm_latest <- function() {
  var_name <- "icd10cm2019"
  if (exists(var_name)) return(get(var_name))
  getExportedValue(asNamespace("icd.data"), var_name)
  # needed?
  # eval(parse(text = paste0("icd.data::", var_name)))
}

#' Evaluate code with a particular version of ICD-10-CM
#'
#' Temporarily sets and restores the option \code{icd.data.icd10cm_active_ver}
#' @template ver
#' @param code Code block to execute
#' @export
with_icd10cm_version <- function(ver, code) {
  stopifnot(is.character(ver), length(ver) == 1)
  old <- options("icd.data.icd10cm_active_ver" = ver)
  on.exit(options(old))
  force(code)
}

with_offline <- function(code) {
  old <- options("icd.data.offline" = TRUE)
  on.exit(options(old))
  force(code)
}

#' Internal function used to search and maybe prompt when active binding used.
#'
#' Tries to get from the local environment first, then from resource directory,
#' and failing that, if interactive, prompts user to download and parse.
#' @param interact Control whether functions thinks it is in interactive mode,
#'   for testing.
#' @keywords internal
.get_icd10cm_ver <- function(
                             ver,
                             dx,
#                             must_work = FALSE,
                             interact = .interactive()) {
  ver <- as.character(ver)
  stopifnot(grepl("^[[:digit:]]{4}$", ver))
  var_name <- paste0("icd10cm", ver)
  dat_path <- .rds_path(var_name)
  if (exists(var_name, envir = .icd_data_env)) {
    return(get(var_name, envir = .icd_data_env))
  }
  if (file.exists(dat_path)) {
    dat <- readRDS(dat_path)
    assign(var_name, dat, envir = .icd_data_env)
    return(dat)
  }
#   if (!can_download) {
#     if (must_work) {
#       stop("No consent to download data. Declined, or not interactive mode.
# You may wish to use:
# set_resource_path(\"/path/you/desire/\")
# to control where data is downloaded.")
#     } else {
#       return(invisible())
#     }
#  }
  if (dx) {
    dat <- .icd10cm_parse_year(
      year = ver,
      save_data = TRUE,
      verbose = FALSE
    )
  } else {
    dat <- .icd10cm_parse_cms_pcs_year(ver, verbose = FALSE)
  }
  assign(var_name, dat, envir = .icd_data_env)
  return(dat)
}
