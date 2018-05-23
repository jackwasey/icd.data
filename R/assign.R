# Copyright (C) 2014 - 2018  Jack O. Wasey
#
# This file is part of icd.data.
#
# icd.data is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or. (at your option) any later
# version.
#
# icd.data is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# icd.data. If not, see <http:#www.gnu.org/licenses/>.

#' Assign all the data in the package to the calling environment
#'
#' Used by \pkg{icd} to load all the data into its environment. This should not
#' be needed by most users, who can simply refer to the data objects normally
#' after calling \code{library(icd.data)}.
#' @examples
#' \dontrun{
#' assign_icd_data()
#'
#' # but really all most users need to do is:
#' library(icd.data)
#' # then refer to the data in the package in the normal way:
#' print(icd10_chapters)
#' }
#' @export
#' @keywords internal
assign_icd_data <- function(env = parent.frame()) {
  data_names <- ls_icd_data()
  lapply(data_names,
         function(x) {
           assign(x, get(x), envir = env)
         })
}

#' @name icd.data
#' @aliases icd.data-package
#' @concept ICD-9 ICD-10 ICD
#' @author Jack O. Wasey \email{jack@@jackwasey.com}
"_PACKAGE"

#' List the data in this package
#' @examples
#' \dontrun{
#' ls_icd_data()
#' }
#' @keywords datasets
#' @export
ls_icd_data <- function()
  utils::data(package = "icd.data")$results[, "Item"]
