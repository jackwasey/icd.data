#' List the data in this package
#' @examples
#' icd.data:::.ls_icd_data()
#' @keywords datasets internal
.ls_icd_data <- function()
  utils::data(package = "icd.data")$results[, "Item"]
