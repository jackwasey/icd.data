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
    if (!dir.exists(path)) {
      message("icd.data resource directory not set, and not in interactive mode.
              Using a temporary directory.")
      path <- tempdir()
    }
    set_resource_path(path = path, verbose = FALSE)
  }
  if (!("icd.data.offline" %in% names(options()))) {
    options(
      "icd.data.offline" =
        tolower(Sys.getenv("ICD_DATA_OFFLINE")) %in% c("n",
                                                       "no",
                                                       "false",
                                                       "0")
    )
  }
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
  makeActiveBinding(sym = "icd10who2016",
                    fun = .icd10who2016_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2016", env = parent.env(environment()))
  makeActiveBinding(sym = "icd10who2008fr",
                    fun = .icd10who2008fr_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2008fr", env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm_latest",
                    fun = .icd10cm_latest_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10cm_latest", env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm_active",
                    fun = .icd10cm_active_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10cm_active", env = parent.env(environment()))
  makeActiveBinding(sym = "cim10fr2019",
                    fun = .cim10fr2019_active_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "cim10fr2019", env = parent.env(environment()))
  makeActiveBinding(sym = "icd9cm2011",
                    fun = .icd9cm2011_active_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd9cm2011", env = parent.env(environment()))
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }

  invisible()
}

release_questions <- function() {
  c("codetools::checkUsagePackage('icd.data', all = TRUE)")
}
