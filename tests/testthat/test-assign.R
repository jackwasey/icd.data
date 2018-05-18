context("assign")

test_that("assigned", {
  e <- new.env()
  assign_icd_data(e)
  expect_true("icd10_sub_chapters" %in% ls(envir = e))
})
