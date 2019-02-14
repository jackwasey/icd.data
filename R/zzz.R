.icd_data_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  if (!("icd.data.resource" %in% names(options()))) {
    if (interactive())
      path <- file.path(Sys.getenv("HOME"), ".icd.data")
    else
      path <- tempdir()
    set_resource_path(path = path, verbose = FALSE)
    }
  makeActiveBinding(sym = "icd10who2016",
                    fun = .icd10who2016_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2016", env = parent.env(environment()))
  makeActiveBinding(sym = "icd10who2008fr",
                    fun = .icd10who2008fr_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2008fr", env = parent.env(environment()))
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
  if (!("icd.data.icd10cm_active_lang" %in% names(options()))) {
    set_icd10cm_active_lang("en")
  }
  makeActiveBinding(sym = "icd10cm_latest",
                    fun = .icd10cm_latest_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10cm_latest", env = parent.env(environment()))
  makeActiveBinding(sym = "icd10cm_active",
                    fun = .icd10cm_active_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10cm_active", env = parent.env(environment()))
  invisible()
}

release_questions <- function() {
  c("codetools::checkUsagePackage('icd.data', all = TRUE)")
}
