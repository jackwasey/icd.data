library(testthat)
library(icd.data)
library(icd)
# Make sure we don't download data on CRAN. Might want to download on CI.
if (identical(Sys.getenv("NOT_CRAN"), "false")) {
  old_offline <- options("icd.data.offline" = TRUE)
  on.exit(options(old_offline), add = TRUE)
}
old_interact <- options("icd.data.interact" = FALSE)
on.exit(options(old_interact), add = TRUE)
icd.data:::.show_options()
test_check("icd.data")
# if temp dir: unlink(getOption("icd.data.resource"))
