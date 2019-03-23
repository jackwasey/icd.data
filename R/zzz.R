.debug <- FALSE
.verbose(.debug)
.make_icd10cm_parsers(verbose = .debug)
.make_getters_and_fetchers(verbose = .debug)

.onLoad <- function(libname, pkgname) {
  .set_init_options()
  # on CRAN, travis etc, ~/.icd.data doesn't exist and isn't created, so leave option unset
  # For R CMD check, there is no (nice) way of telling if we are running on CRAN/R-hub/travis/appveyor, so need to not fail when R CMD check evaulates the whole namespace at multiple steps of the check:
  .set_hard(absent_action = "silent")
  # and this should be reset later. On attach. And/or ignore when we are interactive.
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
  #
  # The verbosity option can't be used downstream because the value is realized rather than the option being re-queried, so for testing, just setting to TRUE now.
  .make_active_bindings(asNamespace(pkgname), verbose = .verbose())
}

.onAttach <- function(libname, pkgname) {
  .set_init_options()
  if (interactive() && !.all_cached()) {
    packageStartupMessage(
      "    icd.data downloads and caches data when requested.
setup_icd_data()
    will set up the cache and enable automated downloads. Use:
download_icd_data()
    to cache everything at once."
    )
  }
}

release_questions <- function() {
  c(
    "codetools::checkUsagePackage('icd.data', all = TRUE, suppressLocal = TRUE)",
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
  "icd9cm_leaf_v32",
  "icd9_majors",
  "icd10cm_sources",
  "icd10cm2019",
  "icd10_chapters",
  "icd10_sub_chapters",
  "dl_fun_name",
  ".binding_namess",
  ".icd_data_default",
  .binding_names
))
