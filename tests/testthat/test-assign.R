context("assign")

test_that("assigned", {
  skip_on_cran()
  e <- new.env()
  assign_icd_data(e)
  expect_true("icd10_sub_chapters" %in% ls(envir = e))
})
