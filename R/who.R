
#' Function to get WHO ICD-10 data directly
#'
#' The user may use the active binding `icd10who2016` as if it is a variable. In
#' some situations, it may be preferable to call this function. E.g., using the
#' active binding when the cache directory has not been populated may produce
#' messages. Auto-complete in Rstudio is unfortunately considered still to be
#' interactive, so these messages may appear prematurely.
#'
#' This was thought to be needed (in addition to icd.data::icd10who2016 active
#' binding), because lazy data and apparently active bindings are not available
#' until the package is on the search path. However, `base::getFromNamespace`
#' can overcome this problem. This is difficult or impossible to do in a CRAN
#' compatible way in the 'icd' package, so this function is just for that
#' purpose, since we can check whether this function exists and call it without
#' using ::, whereas this is not possible with lazy data or active bindings.
#' @keywords internal datasets
get_icd10who2016 <- function() {
  icd10who2016_path <- file.path(get_resource_path(), "icd10who2016.rds")
  if (exists("icd10who2016", envir = .icd_data_env))
    return(get("icd10who2016", envir = .icd_data_env))
  if (file.exists(icd10who2016_path)) {
    icd10who2016 <- readRDS(icd10who2016_path)
    assign("icd10who2016", icd10who2016, envir = .icd_data_env)
    return(icd10who2016)
  }
  NULL
}

#' @rdname get_icd10who2016
#' @keywords internal datasets
get_icd10who2008fr <- function() {
  icd10who2008fr_path <- file.path(get_resource_path(), "icd10who2008fr.rds")
  if (exists("icd10who2008fr", envir = .icd_data_env))
    return(get("icd10who2008fr", envir = .icd_data_env))
  if (file.exists(icd10who2008fr_path)) {
    icd10who2008fr <- readRDS(icd10who2008fr_path)
    assign("icd10who2008fr", icd10who2008fr, envir = .icd_data_env)
    return(icd10who2008fr)
  }
  NULL
}

get_chapter_ranges_from_flat <- function(
  flat_hier = icd10cm2019,
  field = "chapter"
) {
  u <- if (is.factor(flat_hier[[field]]))
    levels(flat_hier[[field]])
  else
    as.character(unique(flat_hier[[field]]))
  three_digits <- as.character(flat_hier[["three_digit"]])
  lapply(
    setNames(u, u),
    function(chap) {
      three_digits <- sort(
        unique(three_digits[flat_hier[[field]] == chap])
      )
      c(
        start = three_digits[1],
        end = three_digits[length(three_digits)]
      )
    })
}

#' Use the WHO ICD-10 French 'hierarchy' flat file to infer chapter ranges
#'
#' These are UTF-8 encoded. If there are no UTF-8 characters, it seems that R
#' forces the 'unknown' encoding label. This could be scraped from the web site
#' directly, which is what \code{.fetch_who_api_chapters()} does, but this is
#' at least as good.
#' @keywords internal
get_chapters_fr <- function(save_data = FALSE) {
  icd10_chapters_fr <- get_chapter_ranges_from_flat(
    flat_hier = icd10who2008fr,
    field = "chapter")
  save_in_data_dir(icd10_chapters_fr)
  invisible(icd10_chapters_fr)
}

#' @rdname get_chapters_fr
#' @keywords internal
get_sub_chapters_fr <- function(save_data = FALSE) {
  icd10_sub_chapters_fr <- get_chapter_ranges_from_flat(
    flat_hier = icd10who2008fr,
    field = "sub_chapter")
  save_in_data_dir(icd10_sub_chapters_fr)
  invisible(icd10_sub_chapters_fr)
}

