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

test_that("all available data is reported", {
  for (lang in c("en", "fr", "nl")) {
    for (pc in c(TRUE, FALSE)) {
      res <- get_icd10cm_available(lang, pc)
      expect_true(exists(res, envir = asNamespace("icd.data")),
                  info = paste(lang, pc))
    }
  }
})

test_that("temporarily set active version", {
  with_icd10cm_version("2014", lang = "fr", {
    expect_identical(nrow(icd.data::icd10cm_active), nrow(icd10cm2014_fr))
  })
  expect_false(nrow(icd.data::icd10cm_latest) == nrow(icd10cm2014_fr))
})
