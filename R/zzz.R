.icd.data.env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  if (!("icd.data.resource" %in% names(options())))
    set_resource_path(verbose = FALSE)
  makeActiveBinding(sym = "icd10who2016",
                    fun = .icd10who2016_binding,
                    env = parent.env(environment()))
  lockBinding(sym = "icd10who2016", env = parent.env(environment()))
  #assignInMyNamespace("icd10who2016c2", .icd.data.env$icd10who2016c)
  invisible()
}
