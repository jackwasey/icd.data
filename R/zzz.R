.make_icd10cm_parsers()

.onLoad <- function(libname, pkgname) {
  .set_init_options()
  # be silent for package loading, which CRAN check does multiple times
  .set_check_options()
  for (trypath in c(
    getOption("icd.data.resource", default = ""),
    Sys.getenv("ICD_DATA_PATH"),
    file.path(Sys.getenv("HOME"), ".icd.data"),
    path.expand(.icd_data_default)
  )) {
    if (!is.null(trypath) && dir.exists(trypath)) {
      options("icd.data.resource" = trypath)
    }
  }
  # must make bindings on load, not attach (when namespace is sealed)
  .make_active_bindings(asNamespace(pkgname), verbose = .verbose())
}

.onAttach <- function(libname, pkgname) {
  if (interactive() && !.all_cached()) {
    packageStartupMessage(
      "    icd.data downloads and caches data when requested.
setup_icd_data()
    will set up the cache and enable automated downloads. Use:
download_icd_data()
    to cache everything at once."
    )
  }
  .set_init_options()
}

release_questions <- function() {
  c(
    "codetools::checkUsagePackage('icd.data', all = TRUE)",
    "styler::style_pkg()",
    "r-hub, travis, appveyor (all should pass tests without downloading data",
    "local install, all tests pass with data all downloaded and parsed"
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
  "icd10_sub_chapters",
  "dl_fun_name",
  ".binding_namess",
  ".icd_data_default",
  # names(.bindings)
  .binding_names
))
