context("WHO")

test_that("No ranges in code section of WHO data", {
  skip_missing_icd10who2016()
  expect_false(any(grep("-", icd10who2016$code)))
  lapply(icd10who2016, function(x) expect_false(any(is.na(x))))
})
