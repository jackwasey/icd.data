.icd_data_env <- new.env(parent = emptyenv())

# options are:
#
# icd.data.offline - default is TRUE, unless ICD_DATA_OFFLINE is false/no
#
# icd.data.resource - default is ~/.icd.data but won't write unless user gives
# permission
#
# icd.data.absent_action - what to do if data is missing, "stop" or "message"
# consider removing this. Need to automate the hell out of this, but might be
# useful for testing.
#
# icd.data.icd10cm_active_ver - which ICD-10-CM version is currently active.
# Default is 2019.
#
# use .show_options() and .clear_options()
.onLoad <- function(libname, pkgname) {
  # ask user if possible, and set offline option if user agrees
  setup_resource_dir()
  # if offline not set somehow, then work offline
  if (!("icd.data.offline" %in% names(options()))) {
    ev <- Sys.getenv("ICD_DATA_OFFLINE")
    options(
      "icd.data.offline" =
        tolower(ev) %nin% c(
          "n",
          "no",
          "false",
          "0"
        )
    )
  }
  # stop or message, anything else will silently continue
  if ("icd.data.absent_action" %nin% names(options())) {
    ev <- tolower(Sys.getenv("ICD_DATA_ABSENT_ACTION"))
    stopifnot(ev %in% c("stop", "message", ""))
    if (ev == "" && interactive()) ev <- "stop"
    options("icd.data.absent_action" = ev)
  }
  # Which version of ICD-10-CM to use by default?
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
  invisible()
}

.onAttach <- function(libname, pkgname) {
  # should be done already, but try again, as we may now be interactive
  setup_resource_dir()
}

release_questions <- function() {
  c(
    "codetools::checkUsagePackage('icd.data', all = TRUE)",
    "styler::style_pkg()"
  )
}

utils::globalVariables(c(
  ".icd_data_env",
  "icd9_sub_chapters",
  "icd9_chapters",
  "icd9cm_sources",
  "icd9_majors",
  "icd10cm2019",
  "icd10cm_sources",
  "icd10_chapters",
  "icd10_sub_chapters"
))
