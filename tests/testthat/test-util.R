context("util")
test_that("string pair match extraction", {
  expect_equal(str_pair_match(pattern = "(a*)b(c*)", string = "abc"), c(a = "c"))
  expect_equal(str_pair_match(pattern = "([^mackarel]*)(spain)",
                              string = "togospain"),
               c(togo = "spain"))
  expect_equal(str_pair_match(pattern = "([^mackarel]*)(spain)",
                              string = c("togospain", "djiboutispain")),
               c(togo = "spain", djibouti = "spain"))
  expect_equal(str_pair_match(pattern = "(a*)b(c*)", string = c("abc", "aabcc")),
               c(a = "c", aa = "cc"))
})

test_that("str_pair_match error if more than two outputs", {
  expect_error(str_pair_match(string = "hadoop", pattern = "(ha)(do)(op)"))
  # no error if explicit
  str_pair_match(string = "hadoop", pattern = "(ha)(do)(op)", pos = c(1, 2))
})
