.make_icd10cm_parsers()

.onLoad <- function(libname, pkgname) {
  .set_init_options()
  # ask user if possible, and set offline option to false if user agrees
  setup_resource_dir()
  # must make bindings on load, not attach (when namespace is sealed)
  .make_active_bindings(asNamespace(pkgname), verbose = TRUE)
}

.onAttach <- function(libname, pkgname) {
  # might be done already, but try again, as we may now be interactive
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
  "icd10_sub_chapters",
  "dl_fun_name",
  ".binding_namess",
  # names(.bindings)
  .binding_names
))
