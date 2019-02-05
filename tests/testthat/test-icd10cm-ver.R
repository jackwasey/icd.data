context("icd10cm versions")

test_that("active version set to latest version", {
  old_opt <- options("icd.data.icd10cm_active_ver")
  on.exit(options(old_opt))
  set_icd10cm_active_ver("2019")
  expect_identical(icd.data::icd10cm_active,
                   icd.data::icd10cm_latest)
})
