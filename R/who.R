#' Function to get the WHO ICD-10 2016 data
#'
#' This is likely to be removed in the future, as it is designed for the
#' transition to icd.data version 1.1 . The user may use the active binding
#' `icd10who2016` as if it is a variable. In some situations, it may be
#' preferable to call this function. E.g., using the active binding when the
#' cache directory has not been populated may produce messages. Auto-complete in
#' Rstudio is unfortunately considered still to be interactive, so these
#' messages may appear prematurely.
#'
#' This is needed (in addition to icd.data::icd10who2016 active binding),
#' because lazy data and apparently active bindings are not available until the
#' package is on the search path. This is difficult or impossible to do in a
#' CRAN compatible way in the 'icd' package, so this function is just for that
#' purpose, since we can check whether this function exists and call it without
#' using ::, whereas this is not possible with lazy data or active bindings.
#' @export
#' @keywords datasets
get_icd10who2016 <- function() {
  icd10who2016_path <- file.path(get_resource_path(), "icd10who2016.rds")
  if (.icd10who2016_in_env())
    return(get("icd10who2016", envir = .icd_data_env))
  if (file.exists(icd10who2016_path)) {
    icd10who2016 <- readRDS(icd10who2016_path)
    assign("icd10who2016", icd10who2016, envir = .icd_data_env)
    return(icd10who2016)
  }
  NULL
}

#' @rdname get_icd10who2016
#' @export
get_icd10who2008fr <- function() {
  icd10who2008fr_path <- file.path(get_resource_path(), "icd10who2008fr.rds")
  if (.icd10who2008fr_in_env())
    return(get("icd10who2008fr", envir = .icd_data_env))
  if (file.exists(icd10who2008fr_path)) {
    icd10who2008fr <- readRDS(icd10who2008fr_path)
    assign("icd10who2008fr", icd10who2008fr, envir = .icd_data_env)
    return(icd10who2008fr)
  }
  NULL
}
