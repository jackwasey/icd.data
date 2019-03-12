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

context("icd10 XML parse")

test_that("icd10 sub-chapters are recreated exactly", {
  skip_icd10cm_xml_avail()
  expect_identical(
    icd10cm_extract_sub_chapters(save_data = FALSE),
    icd10_sub_chapters
  )
})

test_that("icd10 sub_chapters were parsed correctly", {
  expect_icd10_sub_chap_equal(
    paste(
      "Persons with potential health hazards related",
      "to family and personal history and certain",
      "conditions influencing health status"
    ),
    start = "Z77", end = "Z99"
  )
  expect_icd10_sub_chap_equal(
    "Persons encountering health services for examinations",
    "Z00", "Z13"
  )
  expect_icd10_sub_chap_equal(
    "Occupant of three-wheeled motor vehicle injured in transport accident",
    "V30", "V39"
  )
  expect_icd10_sub_chap_equal(
    "Malignant neuroendocrine tumors", "C7A", "C7A"
  )
  expect_icd10_sub_chap_equal(
    "Other human herpesviruses", "B10", "B10"
  )
})

test_that("ICD-10 chapters and sub-chapters are distinct", {
  # and for good measure, make sure that sub-chapters and chapters are not
  # confused. This was really just a problem with RTF parsing for ICD-9, but
  # there are possible similiar problems with some of the XML hierarchy.
  for (chap in names(icd10_chapters))
    expect_icd10_only_chap(chap)
  for (subchap in names(icd10_sub_chapters))
    expect_icd10_only_sub_chap(subchap)
})

test_that("Y09 got picked up in sub-chapter parsing", {
  # this is actually an error in the 2016 CMS XML which declares a range for
  # Assult from X92-Y08, but has a hanging definition for Y09 with no enclosing
  # chapter. Will have to manually correct for this until fixed.
  expect_icd10_sub_chap_equal("Assault", "X92", "Y09")
})

test_that("chapter parsing for ICD-10 went okay", {
  skip_if_not_installed("icd", "3.4")
  for (y in 2014:2019) {
    chap_lookup <- .icd10_generate_chap_lookup(year = y)
    expect_false(any(duplicated(chap_lookup$chap_major)), info = y)
  }
})

test_that("sub-chapter parsing for ICD-10 went okay", {
  skip_if_not_installed("icd", "3.4")
  for (y in 2014:2019) {
    sc_lookup <- .icd10_generate_subchap_lookup(year = y)
    expect_equal(anyDuplicated(sc_lookup$sc_major), 0, info = y)
    # 2019 duplicated/parse errors?
    sc_lookup[sc_lookup$sc_major %in% c("C7A", "C7B", "D3A"), ]
  }
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
