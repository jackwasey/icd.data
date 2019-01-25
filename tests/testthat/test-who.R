context("WHO")

test_that("No ranges in code section of WHO data", {
  skip_missing_icd10who2016()
  expect_false(any(grep("-", icd10who2016$code)))
  expect_false(any(is.na(icd10who2016$code)))
  expect_false(any(is.na(icd10who2016$leaf)))
  expect_false(any(is.na(icd10who2016$desc)))
  expect_false(any(is.na(icd10who2016$three_digit)))
  expect_false(any(is.na(icd10who2016$major)))
  # sub_sub_chapter may be NA
  expect_false(any(is.na(icd10who2016$sub_chapter)))
  expect_false(any(is.na(icd10who2016$chapter)))
})
