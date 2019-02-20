library(testthat)
library(icd.data)
library(icd)
old_opt <- options("icd.data.resource" = tempdir())
if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  options("icd.data.offline" = FALSE)
}
on.exit(options(old_opt))
test_check("icd.data")
unlink(getOption("icd.data.resource"))
