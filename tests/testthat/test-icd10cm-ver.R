context("icd10cm versions")

test_that("active version set to latest version", {
  with_icd10cm_version(
    ver = "2019",
    expect_identical(
      get_icd10cm_active(),
      icd10cm_latest
    )
  )
})

test_that("all available data is reported", {
  for (pc in c(TRUE, FALSE)) {
    res <- get_icd10cm_available(pc)
    expect_true(exists(res, envir = asNamespace("icd.data")),
      info = paste(pc)
    )
  }
})

test_that("temporarily set active version", {
  skip_icd10cm_flat_avail("2014")
  with_icd10cm_version("2014", code = {
    expect_identical(nrow(icd.data::icd10cm_active), nrow(icd10cm2014))
  })
})

test_that("basic Belgian", {
  skip_missing_dat("icd10be2014")
  skip_missing_dat("icd10be2017")
  expect_true(inherits(icd10be2014$code, "icd10be"))
  expect_true(inherits(icd10be2017$code, "icd10be"))
  skip("further Belgian code checks/comparisons")
  # how different is Belgian 2017 set from ICD-10-CM in different years?
  length(setdiff(icd10be2017$code, icd10cm2018$code)) # 334 Belgian only
  length(setdiff(icd10cm2018$code, icd10be2017$code)) # 751 CM only
  length(setdiff(icd10be2017$code, icd10cm2017$code)) # 212 Belgian only
  length(setdiff(icd10cm2017$code, icd10be2017$code)) # 332 CM only
  length(setdiff(icd10be2017$code, icd10cm2016$code)) # 1973 Belgian only
  length(setdiff(icd10cm2016$code, icd10be2017$code)) # 0 CM only
})
