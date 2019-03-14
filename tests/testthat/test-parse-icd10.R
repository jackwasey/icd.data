context("icd10 fixed width parse")

test_icd10_most_majors <- outer(LETTERS, sprintf(0:99, fmt = "%02i"), paste0)

test_that("icd10 flat file details are okay", {
  skip("this test is very slow, but important to run manually")
  # check cols at a time, so I get better error feedback:
  col_names <- c(
    "code",
    "billable",
    "short_desc",
    "long_desc",
    "three_digit",
    "major",
    "sub_chapter",
    "chapter"
  )
  all_res <- icd10cm_parse_all(save_data = FALSE)
  for (v in as.character(2014:2019)) {
    skip_icd10cm_flat_avail(v)
    res <- all_res[[v]]
    expect_identical(colnames(res), col_names)
    expect_is(res$code, "character")
    expect_is(res$billable, "logical")
    expect_is(res$short_desc, "character")
    expect_is(res$long_desc, "character")
    for (n in c(
      "three_digit",
      "major",
      "sub_chapter",
      "chapter"
    )) {
      expect_true(is.factor(res[[n]]))
      expect_identical(res, get_icd10cm_version(v))
    }
  } # for all versions
})

# github issue #116
test_that("W02 is correctly parsed", {
  expect_equal_no_icd(icd::explain_code(icd::as.icd10cm("W02")), character(0))
})

test_that("explain icd9GetChapters simple input", {
  skip_if_not_installed("icd", "3.4")
  chaps1 <- .icd9_get_chapters(c("410", "411", "412"), short_code = TRUE)
  expect_equal(nrow(chaps1), 3)

  chaps2 <- .icd9_get_chapters("418", short_code = TRUE) # no such code 418
  expect_is(chaps2, "data.frame")
  expect_is(chaps2$three_digit, "factor")
  expect_is(chaps2$major, "factor")
  expect_is(chaps2$sub_chapter, "factor")
  expect_is(chaps2$chapter, "factor")
  expect_equal(.as_char_no_warn(chaps2$three_digit), NA_character_)
  expect_equal(.as_char_no_warn(chaps2$major), NA_character_)
  expect_equal(.as_char_no_warn(chaps2$sub_chapter), NA_character_)
  expect_equal(.as_char_no_warn(chaps2$chapter), NA_character_)

  chaps3 <- .icd9_get_chapters("417", short_code = FALSE)
  expect_equal(.as_char_no_warn(chaps3$three_digit), "417")
  expect_equal(
    .as_char_no_warn(chaps3$major),
    "Other diseases of pulmonary circulation"
  )
  expect_equal(
    .as_char_no_warn(chaps3$sub_chapter),
    "Diseases Of Pulmonary Circulation"
  )
  expect_equal(
    .as_char_no_warn(chaps3$chapter),
    "Diseases Of The Circulatory System"
  )

  chaps4 <- .icd9_get_chapters("417", short_code = TRUE)
  chaps5 <- .icd9_get_chapters("417.1", short_code = FALSE)
  chaps6 <- .icd9_get_chapters("4171", short_code = TRUE)
  chaps7 <- .icd9_get_chapters("417.1", short_code = FALSE)
  chaps8 <- .icd9_get_chapters("4171", short_code = TRUE)
  expect_equal(chaps3, chaps4)
  expect_equal(chaps3, chaps5)
  expect_equal(chaps3, chaps6)
  expect_equal(chaps3, chaps7)
  expect_equal(chaps3, chaps8)
})
