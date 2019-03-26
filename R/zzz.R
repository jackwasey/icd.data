.debug <- FALSE
.verbose(.debug || getOption("icd.data.verbose", default = FALSE))
.make_icd9cm_leaf_parsers(verbose = .debug)
.make_icd9cm_rtf_parsers(verbose = .debug)
.make_icd10cm_parsers(verbose = .debug)
# get_ and .get_ functions only depend  on the data name
.make_getters_and_fetchers(verbose = .debug)

.onLoad <- function(libname, pkgname) {
  .set_init_options()
}

.onAttach <- function(libname, pkgname) {
  if (interactive() && .interact()) {
    packageStartupMessage(
      "icd.data downloads and caches data when requested. Use
setup_icd_data()
    to initialize the cache and enable automated downloads. Use:
download_icd_data()
    to cache everything at once, or complete an interrupted download."
    )
  }
  if (.interact() && !.all_cached()) {
    packageStartupMessage(
      "Not all the available ICD-9-CM data has been downloaded. To complete the download and parsing process use:
download_icd_data()"
    )
  }
}

release_questions <- function() {
  c(
    "codetools::checkUsagePackage('icd.data', all = TRUE, suppressLocal = TRUE)",
    "styler::style_pkg()",
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
