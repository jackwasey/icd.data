context("icd10cm versions")

test_that("bindings look ok", {
  expect_true(bindingIsActive("icd10cm_latest", asNamespace("icd.data")))
  expect_true(bindingIsLocked("icd10cm_latest", asNamespace("icd.data")))
  expect_true(bindingIsActive("icd10cm_active", asNamespace("icd.data")))
  expect_true(bindingIsLocked("icd10cm_active", asNamespace("icd.data")))
})

test_that("active version set to latest version", {
  old_opt <- options("icd.data.icd10cm_active_ver")
  on.exit(options(old_opt))
  set_icd10cm_active_ver("2019")
  expect_identical(icd.data::icd10cm_active,
                   icd.data::icd10cm_latest)
})
