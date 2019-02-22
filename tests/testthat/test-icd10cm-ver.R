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
  for (pc in c(TRUE, FALSE)) {
    res <- get_icd10cm_available(pc)
    expect_true(exists(res, envir = asNamespace("icd.data")),
                info = paste(pc))
  }
})

test_that("temporarily set active version", {
  with_icd10cm_version("2014", code = {
    expect_identical(nrow(icd.data::icd10cm_active), nrow(icd10cm2014))
  })
})

test_that("basic Belgian", {
  expect_true(inherits(icd10be2014$code, "icd10be"))
  expect_true(inherits(icd10be2017$code, "icd10be"))
  # True for 2014, but not 2017:
  expect_true(all(icd10cm2014$code %in% icd10be2014$code))
  expect_setequal(as.character(icd10cm2014$code),
                  as.character(icd10be2014$code))
})

test_that("detail Belgian", {
  # Is BE version is identical to ICD-10-CM for 2014?
  expect_equal(nrow(icd10cm2014), nrow(icd10be2014))
  expect_setequal(icd10cm2014$code, icd10be2014$code)
  # how different is Belgian 2017 set from ICD-10-CM in different years?
  length(setdiff(icd10be2017$code, icd10cm2018$code)) #334 Belgian only
  length(setdiff(icd10cm2018$code, icd10be2017$code)) # 751 CM only
  length(setdiff(icd10be2017$code, icd10cm2017$code)) # 212 Belgian only
  length(setdiff(icd10cm2017$code, icd10be2017$code)) # 332 CM only
  length(setdiff(icd10be2017$code, icd10cm2016$code)) # 1973 Belgian only
  length(setdiff(icd10cm2016$code, icd10be2017$code)) # 0 CM only
  j <- setdiff(icd10be2017$code, icd10cm2016$code)
  # the following demonstrates that ICD-10-BE has same codes as ICD-10-CM 2016
  # with 1973 cherry-pickede from 2017.
  expect_length(setdiff(j, icd10cm2017$code), 0)
  #stopifnot(length(setdiff(icd10cm2014$code, icd10be2014_en$code)) == 0) # just in CM
  #stopifnot(length(setdiff(icd10be2014_en$code, icd10cm2014$code)) == 0) # just in BE
  stopifnot(length(setdiff(icd10cm2014$code, icd10be2014$code)) == 0) # just in CM
  stopifnot(length(setdiff(icd10be2014$code, icd10cm2014$code)) == 0) # just in BE
})
