context("WHO")

test_that("No ranges or NA in code section of WHO data", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  skip_missing_icd10who("2016")
  # assign somehow forces binding to work when doing R CMD check, otherwise it
  # tries to subset the function
  i <- icd10who2016
  if (!is.data.frame(i)) {
    skip("icd10who2016 binding is not usable during check")
  }
  expect_false(any(grepl("-", i$code)))
  expect_false(any(is.na(i$code)))
  expect_false(any(is.na(i$leaf)))
  expect_false(any(is.na(i$desc)))
  expect_false(any(is.na(i$three_digit)))
  expect_false(any(is.na(i$major)))
  # sub_sub_chapter may be NA
  expect_false(any(is.na(i$sub_chapter)))
  expect_false(any(is.na(i$chapter)))
})

test_that("no duplicated codes or descriptions", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  skip_missing_icd10who("2016")
  i <- icd10who2016
  if (!is.data.frame(i)) {
    skip("icd10who2016 binding is not usable during check")
  }
  expect_true(!anyDuplicated(i$code))
})
