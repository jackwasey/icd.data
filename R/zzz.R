.icd_data_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  if (!("icd.data.resource" %in% names(options()))) {
    path <- Sys.getenv("ICD_DATA_PATH")
    if (path == "") {
      for (trypath in c(
        file.path(Sys.getenv("HOME"), ".icd.data"),
        path.expand("~/.icd.data")
      )) {
        if (dir.exists(trypath)) {
          path <- trypath
          break
        }
      }
    }
    if (!dir.exists(path)) path <- tempdir()
    set_resource_path(path = path, verbose = FALSE)
  }
  if (!("icd.data.offline" %in% names(options()))) {
    ev <- Sys.getenv("ICD_DATA_OFFLINE")
    options(
      "icd.data.offline" =
        tolower(ev) %nin% c("n",
                            "no",
                            "false",
                            "0")
    )
  }
  # stop or message, anything else will silently continue
  if ("icd.data.absent_action" %nin% names(options())) {
    ev <- tolower(Sys.getenv("ICD_DATA_ABSENT_ACTION"))
    stopifnot(ev %in% c("stop", "message", ""))
    if (ev == "" && interactive()) ev <- "stop"
    options("icd.data.absent_action" = ev)
  }
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
# Belgium
  makeActiveBinding(sym = "icd10be2014",
                    fun = .icd10be2014_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10be2014_pc",
                    fun = .icd10be2014_pc_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10be2017",
                    fun = .icd10be2017_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10be2017_pc",
                    fun = .icd10be2017_pc_binding,
                    env = parent.env(environment()))
  # ICD-10-CM
  makeActiveBinding(sym = "icd10cm2014",
                    fun = .icd10cm2014_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2014_pc",
                    fun = .icd10cm2014_pc_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2015",
                    fun = .icd10cm2015_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2015_pc",
                    fun = .icd10cm2015_pc_binding,
                    env = parent.env(environment()))
  # makeActiveBinding(sym = "icd10cm2016",
  #                   fun = .icd10cm2016_binding,
  #                   env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2016_pc",
                    fun = .icd10cm2016_pc_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2017",
                    fun = .icd10cm2017_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2017_pc",
                    fun = .icd10cm2017_pc_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2018",
                    fun = .icd10cm2018_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm2018_pc",
                    fun = .icd10cm2018_pc_binding,
                    env = parent.env(environment()))
  # WHO
  makeActiveBinding(sym = "icd10who2016",
                    fun = .icd10who2016_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10who2008fr",
                    fun = .icd10who2008fr_binding,
                    env = parent.env(environment()))
  # Dynamic aliases
  makeActiveBinding(sym = "icd10cm_latest",
                    fun = .icd10cm_latest_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm_active",
                    fun = .icd10cm_active_binding,
                    env = parent.env(environment()))
  # TODO: make this download on demand
  makeActiveBinding(sym = "cim10fr2019",
                    fun = .cim10fr2019_active_binding,
                    env = parent.env(environment()))
  makeActiveBinding(sym = "icd9cm2011",
                    fun = .icd9cm2011_active_binding,
                    env = parent.env(environment()))
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
  invisible()
}

.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("ICD_DATA_PATH") == "" &&
      is.null(getOption("icd.data.resource")))
    packageStartupMessage(
      "icd.data is using a temporary folder for downloading data when needed.
      Use 'icd.data::set_resource_path(\"/path/you/want\")'.
      Or set: options(\"icd.data.resource\" = \"/path/you/want\")
      or
      Sys.setenv(\"ICD_DATA_RESOURCE\" = \"/path/you/want\")
      before loading the package.
      ")
}
release_questions <- function() {
  c("codetools::checkUsagePackage('icd.data', all = TRUE)")
}
