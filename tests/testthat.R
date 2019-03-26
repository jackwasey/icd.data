library(testthat)
library(icd.data)
library(icd)
# Don't download data on CRAN
if (!icd.data:::.env_var_is_true("NOT_CRAN")) {
  old_offline <- options("icd.data.offline" = TRUE)
  on.exit(options(old_offline), add = TRUE)
}
if (icd.data:::.env_var_is_true("ICD_DATA_TEST_SLOW")) {
  old_test_slow <- options("icd.data.test_slow" = TRUE)
  on.exit(options(old_test_slow), add = TRUE)
}

old_interact <- options("icd.data.interact" = FALSE)
on.exit(options(old_interact), add = TRUE)
icd.data:::.show_options()
test_check("icd.data")
# if temp dir: unlink(getOption("icd.data.resource"))
