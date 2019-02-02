.icd_data_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  if (!("icd.data.resource" %in% names(options()))) {
    if (interactive())
      path <- file.path(Sys.getenv("HOME"), ".icd.data")
    else
      path <- tempdir()
    set_resource_path(path = path,
                      verbose = FALSE)
    }
  makeActiveBinding(sym = "icd10who2016",
                    fun = .icd10who2016_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2016", env = parent.env(environment()))
  invisible()
}
