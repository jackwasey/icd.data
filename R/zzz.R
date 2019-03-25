.debug <- FALSE
.verbose(.debug)
.make_icd10cm_parsers(verbose = .debug)
.make_getters_and_fetchers(verbose = .debug)

.onLoad <- function(libname, pkgname) {
  .set_init_options()
  # on CRAN, travis etc, ~/.icd.data doesn't exist and isn't created, so leave option unset
  # For R CMD check, there is no (nice) way of telling if we are running on CRAN/R-hub/travis/appveyor, so need to not fail when R CMD check evaulates the whole namespace at multiple steps of the check:
  # .set_hard(absent_action = "silent")
  # and this should be reset later. On attach. And/or ignore when we are interactive.

  # must make bindings on load, not attach (when namespace is sealed)
  #
  # The verbosity option can't be used downstream because the value is realized rather than the option being re-queried, so for testing, just setting to TRUE now.
  .make_data_funs(asNamespace(pkgname), verbose = .verbose())
  icd9cm_billable <- list()
  # just for R CMD check, with the circular dep and R-devel
  lazyenv <- asNamespace("icd.data")$.__NAMESPACE__.$lazydata
  # work around the fact that R CMD check gets all the bindings before lazy data is put in the package namespace
  # if (exists("icd9cm_leaf_v32", lazyenv))
  icd9cm_billable[["32"]] <- get("icd9cm_leaf_v32", envir = lazyenv)
  assign("icd9cm_billable", icd9cm_billable, asNamespace(pkgname))
}

.onAttach <- function(libname, pkgname) {
  if (interactive() && !.all_cached()) {
    packageStartupMessage(
      "icd.data downloads and caches data when requested. Use
setup_icd_data()
    to initialize the cache and enable automated downloads. Use:
download_icd_data()
    to cache everything at once, or complete an interrupted download."
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
  "icd9_sub_chapters",
  "icd9_chapters",
  "icd9_majors",
  "icd10_sub_chapters",
  "icd10_chapters",
  "icd10cm2016",
  "icd10cm2019",
  "icd9cm_hierarchy"
))
