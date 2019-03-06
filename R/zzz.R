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

  # # Belgium
  # makeActiveBinding(sym = "icd10be2014",
  #                   fun = .icd10be2014_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10be2014_pc",
  #                   fun = .icd10be2014_pc_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10be2017",
  #                   fun = .icd10be2017_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10be2017_pc",
  #                   fun = .icd10be2017_pc_binding,
  #                   env = parent.env(environment()))
  # # ICD-10-CM
  # makeActiveBinding(sym = "icd10cm2014",
  #                   fun = .icd10cm2014_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2014_pc",
  #                   fun = .icd10cm2014_pc_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2015",
  #                   fun = .icd10cm2015_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2015_pc",
  #                   fun = .icd10cm2015_pc_binding,
  #                   env = parent.env(environment()))
  # # makeActiveBinding(sym = "icd10cm2016",
  # #                   fun = .icd10cm2016_binding,
  # #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2016_pc",
  #                   fun = .icd10cm2016_pc_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2017",
  #                   fun = .icd10cm2017_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2017_pc",
  #                   fun = .icd10cm2017_pc_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2018",
  #                   fun = .icd10cm2018_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2018_pc",
  #                   fun = .icd10cm2018_pc_binding,
  #                   env = parent.env(environment()))
  # # makeActiveBinding(sym = "icd10cm2019",
  # #                   fun = .icd10cm2019_binding,
  # #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2019_pc",
  #                   fun = .icd10cm2019_pc_binding,
  #                   env = parent.env(environment()))
  # # WHO
  # makeActiveBinding(sym = "icd10who2016",
  #                   fun = .icd10who2016_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10who2008fr",
  #                   fun = .icd10who2008fr_binding,
  #                   env = parent.env(environment()))
  # # Dynamic aliases
  # makeActiveBinding(sym = "icd10cm_latest",
  #                   fun = .icd10cm_latest_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm_active",
  #                   fun = .icd10cm_active_binding,
  #                   env = parent.env(environment()))
  # # TODO: make this download on demand
  # makeActiveBinding(sym = "icd10fr2019",
  #                   fun = .icd10fr2019_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "cim10fr2019",
  #                   fun = .cim10fr2019_binding,
  #                   env = parent.env(environment()))
  # makeActiveBinding(sym = "icd9cm2011",
  #                   fun = .icd9cm2011_binding,
  #                   env = parent.env(environment()))
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
  c("codetools::checkUsagePackage('icd.data', all = TRUE)",
    "styler::style_pkg()")
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
