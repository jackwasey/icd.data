#' Assign all the data in the package to the calling environment
#'
#' Used by \pkg{icd} to load all the data into its environment. This should not
#' be needed by most users, who can simply refer to the data objects normally
#' after calling \code{library(icd.data)}.
#' @examples
#' \dontrun{
#' assign_icd_data()
#'
#' # but most users just need to:
#' library(icd.data)
#' # then refer to the data in the package in the normal way:
#' print(icd10_chapters)
#'
#' # or even simpler:
#' library(icd)
#' # which will attach icd.data
#' }
#' @keywords internal
#' @export
assign_icd_data <- function(env = parent.frame()) {
  data_names <- ls_icd_data()
  lapply(
    data_names,
    function(x) {
      assign(x, get(x), envir = env)
    }
  )
}

#' List the data in this package
#' @examples
#' \dontrun{
#' ls_icd_data()
#' }
#' @keywords datasets
ls_icd_data <- function()
  utils::data(package = "icd.data")$results[, "Item"]
