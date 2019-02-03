#' Set the annual version of ICD-10-CM to use
#' @param year Four digit year
#' @export
set_icd10cm_ver <- function(year, check_exists = TRUE) {
  year <- as.character(year)
  stopifnot(nchar(year) == 4L)
  stopifnot(year %in% names(icd10cm_sources))
  if (check_exists)
    stopifnot(exists(paste0("icd10cm", year), inherits = TRUE))
  options("icd.data.icd10cm_ver" = year)
}

.icd10cm_latest_binding <- function(x) {
  if (!missing(x)) stop("This binding returns the latest ICD-10-CM data.\n",
                        "Use `set_icd10cm_ver(\"2019\") instead.")
  get(paste0("icd10cm", getOption("icd.data.icd10cm_ver")))
}
