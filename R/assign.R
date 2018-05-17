#' Assign all the data in the package to the calling environment
#'
#' Used by \pkg{icd} to load all the data into its environment. This should not
#' be needed by most users, who can simply refer to the data objects normally
#' after calling \code{library(icd.data)}.
#' @examples
#' assign_icd_data()
#'
#' # but really all most users need to do is:
#' library(icd.data)
#' # then refer to the data in the package in the normal way:
#' print(icd10_chapters)
#' @export
#' @keywords internal
assign_icd_data <- function(env = parent.frame()) {
  data_names <- data(package = "icd.data")$results[, "Item"]
  lapply(data_names,
         function(x) {
           assign(x, get(x), envir = env)
         })
}
