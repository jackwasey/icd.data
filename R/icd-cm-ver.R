#' Get or set the annual version or language of ICD-10-CM to use
#' @template ver
#' @examples
#'   set_icd10cm_active_ver(2019)
#' @export
set_icd10cm_active_ver <- function(ver) {
  v <- as.character(ver)
  stopifnot(grepl("^[[:digit:]]{4}$", as.character(v)))
  stopifnot(v %in% names(icd10cm_sources))
  options("icd.data.icd10cm_active_ver" = v)
  invisible(v)
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

#' @rdname set_icd10cm_active_ver
#' @template lang
#' @export
set_icd10cm_active_lang <- function(lang) {
  assert_icd10cm_lang_avail(lang)
  options(icd.data.icd10cm_active_lang = lang)
  invisible(lang)
}

#' @rdname set_icd10cm_active_ver
#' @export
get_icd10cm_active_lang <- function() {
  ver <- getOption("icd.data.icd10cm_active_lang")
  assert_icd10cm_lang_avail(ver)
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
  stopifnot(grepl("^[[:digit:]]{4}$", as.character(ver)))
  lang = get_icd10cm_active_lang()
  if (lang %in% c("fr", "nl")) {
    if (ver != "2014") {
      warning("Requested year for ICD-10-CM is ", ver,
              " but language '", lang, "' was requested, ",
              "which is only available for 2014. Returning 2014 data. Use
            set_icd10cm_active_ver(\"2014\")
              to default to 2014 for this R session.")
      ver = "2014"
    }
    return(
      switch(lang,
             "fr" = icd.data::icd10cm2014_fr,
             "nl" = icd.data::icd10cm2014_nl)
    )
  }
  switch(ver,
         "2014" = icd.data::icd10cm2014,
         "2015" = icd.data::icd10cm2015,
         "2016" = icd.data::icd10cm2016,
         "2017" = icd.data::icd10cm2017,
         "2018" = icd.data::icd10cm2018,
         "2019" = icd.data::icd10cm2019
  )
}

get_lang_str <- function(lang) {
  ifelse(lang == "en", "", paste0("_", lang))
}

#' Get the ICD-10-CM versions available in this package
#' @template lang
#' @template pc
#' @param return_year Logical, which, if `TRUE`, will result in only a character
#'   vector of year (or year-like version) being returned.
#' @examples
#'   # English language diagnostic codes:
#'   get_icd10cm_available()
#'   # French procedure codes
#'   get_icd10cm_available("fr", pc = TRUE)
#'   # Dutch diagnostic and procedure codes
#'   get_icd10cm_available("nl")
#'   get_icd10cm_available("nl", TRUE)
#'   # Just get the years avaiable for English language procedure codes
#'   get_icd10cm_available(pc = TRUE, return_year = TRUE)
#' @export
get_icd10cm_available <- function(
  lang = c("en", "fr", "nl"),
  pc = FALSE,
  return_year = FALSE
) {
  stopifnot(is.logical(pc), length(pc) == 1)
  lang = match.arg(lang)
  pc_str = ifelse(pc, "_pc", "")
  res <- switch(lang,
                "en" = as.character(2014:2019),
                "fr" = "2014",
                "nl" = "2014")
  if (return_year)
    res
  else
    paste0("icd10cm", res, pc_str, get_lang_str(lang))
}

#' Get or check available language choices
#' @keywords internal
get_icd10cm_avail_lang <- function(lang) {
  c("en", "fr", "nl")
}

#' @rdname get_icd10cm_avail_lang
#' @keywords internal
assert_icd10cm_lang_avail <- function(lang) {
  if (!is.character(lang) ||
      length(lang) != 1L ||
      !(lang %in% get_icd10cm_avail_lang()))
    stop("Option \"icd.data.icd10cm_active_lang\" is not valid.\n",
         "Reset it with set_icd10cm_active_ver(\"2019\") ",
         "or other year version.")
}

#' Get the data for the latest ICD-10-CM version in this package.
#'
#' Language handling is incomplete, as there is only data for 2014 for French
#' and Dutch. These functions are beta status, and will likely need updating as
#' more national ICD versions, years, sub-versions, and languages are added.
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

#' @rdname get_icd10cm_latest
#' @examples
#' # For the latest data, regardless of active settings:
#' identical(icd10cm_latest, icd10cm_active)
#' identical(icd10cm_latest, icd10cm2019)
#' # note a change between 2018 and 2019
#' icd10cm_latest[icd10cm_latest$code == "C4311", "billable"]
#' icd10cm2018[icd10cm2018$code == "C4311", "billable"]
#' "C43111" %in% icd10cm2018$code
#' icd10cm2019[icd10cm2019$code == "C43111", ]
#' @export
get_icd10cm_latest <- function() {
  var_name <- paste0("icd10cm", get_icd10cm_active_ver())
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
#'
#' @keywords internal
icd9cm_latest_edition <- function() "32"

#' Check whether a given combination of version/year, language, and diagnostic
#' versus procedure codes is available. Beta.
#' @template ver
#' @template lang
#' @template pc
#' @examples
#' # test active option settings by default
#' icd10cm_ver_lang_ok()
#' # French is availabile for 2014 diagnostic codes
#' icd10cm_ver_lang_ok(2014, "fr")
#' # Arabic is not available for active year (or any other)
#' icd10cm_ver_lang_ok(lang = "ar")
#' @export
icd10cm_ver_lang_ok <- function(
  ver = get_icd10cm_active_ver(),
  lang = get_icd10cm_active_lang(),
  pc = FALSE
) {
  var_name <- paste0("icd10cm",
                     ver,
                     ifelse(pc, "_pc", ""),
                     get_lang_str(lang)
  )
  exists(var_name, envir = asNamespace("icd.data"))
}

#' Evaluate code with a particular version of ICD-10-CM
#' @template ver
#' @template lang
#' @param code Code block to execute
#' @export
with_icd10cm_version <- function(ver, lang, code)
{
  stopifnot(icd10cm_ver_lang_ok(ver, lang, pc = FALSE))
  stopifnot(is.character(ver), length(ver) == 1)
  old <- options("icd.data.icd10cm_active_ver" = ver,
                 "icd.data.icd10cm_active_lang" = lang)
  on.exit(options(old))
  force(code)
}
