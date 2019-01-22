context("icd.data::icd9cm_hierarchy was parsed as expected")
# at present, icd.data::icd9cm_hierarchy is derived from RTF parsing, a little web
# scraping, some manually entered data, and (for the short description only)
# another text file parsing.`

test_that("no NA or zero-length values", {
  expect_false(any(vapply(icd.data::icd9cm_hierarchy,
                          function(x) any(is.na(x)), FUN.VALUE = logical(1))))
  expect_false(any(nchar(unlist(icd.data::icd9cm_hierarchy)) == 0))
})

test_that("factors are in the right place", {
  expect_is(icd.data::icd9cm_hierarchy[["code"]], c("icd9cm", "icd9", "character"))
  expect_is(icd.data::icd9cm_hierarchy$short_desc, "character")
  expect_is(icd.data::icd9cm_hierarchy$long_desc, "character")
  expect_is(icd.data::icd9cm_hierarchy$three_digit, "factor")
  expect_is(icd.data::icd9cm_hierarchy$major, "factor")
  expect_is(icd.data::icd9cm_hierarchy$sub_chapter, "factor")
  expect_is(icd.data::icd9cm_hierarchy$chapter, "factor")
})

test_that("codes and descriptions are valid and unique", {
  expect_equal(anyDuplicated(icd.data::icd9cm_hierarchy[["code"]]), 0)
  expect_true(all(icd::is_valid(icd.data::icd9cm_hierarchy[["code"]])))
})

test_that("some chapters are correct", {
  chaps <- as_char_no_warn(icd.data::icd9cm_hierarchy$chapter)
  codes <- icd.data::icd9cm_hierarchy[["code"]]
  # first and last rows (E codes should be last)
  expect_equal(chaps[1], "Infectious And Parasitic Diseases")
  expect_equal(chaps[nrow(icd.data::icd9cm_hierarchy)],
               "Supplementary Classification Of External Causes Of Injury And Poisoning")

  # first and last rows of a block in the middle
  neoplasm_first_row <- which(codes == "140")
  neoplasm_last_row <- which(codes == "240") - 1
  expect_equal(chaps[neoplasm_first_row - 1], "Infectious And Parasitic Diseases")
  expect_equal(chaps[neoplasm_first_row], "Neoplasms")
  expect_equal(chaps[neoplasm_last_row], "Neoplasms")
  expect_equal(chaps[neoplasm_last_row + 1],
               "Endocrine, Nutritional And Metabolic Diseases, And Immunity Disorders")
})

test_that("some sub-chapters are correct", {
  subchaps <- as_char_no_warn(icd.data::icd9cm_hierarchy$sub_chapter)
  codes <- icd.data::icd9cm_hierarchy[["code"]]

  # first and last
  expect_equal(subchaps[1], "Intestinal Infectious Diseases")
  expect_equal(subchaps[nrow(icd.data::icd9cm_hierarchy)], "Injury Resulting From Operations Of War")

  # first and last of a block in the middle
  suicide_rows <- which(codes %in% (icd::expand_range("E950", "E959")))
  expect_equal(subchaps[suicide_rows[1] - 1],
               "Drugs, Medicinal And Biological Substances Causing Adverse Effects In Therapeutic Use")
  expect_equal(subchaps[suicide_rows[1]], "Suicide And Self-Inflicted Injury")
  expect_equal(subchaps[suicide_rows[length(suicide_rows)]], "Suicide And Self-Inflicted Injury")
  expect_equal(subchaps[suicide_rows[length(suicide_rows)] + 1],
               "Homicide And Injury Purposely Inflicted By Other Persons")
})

test_that("some randomly selected rows are correct", {
  expect_equal(
    unname(
      vapply(icd.data::icd9cm_hierarchy[icd.data::icd9cm_hierarchy[["code"]] == "5060", ],
             FUN = as_char_no_warn, FUN.VALUE = character(1))
    ),
    c("5060", "TRUE", "Fum/vapor bronc/pneumon",
      "Bronchitis and pneumonitis due to fumes and vapors",
      "506", "Respiratory conditions due to chemical fumes and vapors",
      "Pneumoconioses And Other Lung Diseases Due To External Agents",
      "Diseases Of The Respiratory System")
  )
})

test_that("tricky v91.9 works", {
  expect_equal(
    icd.data::icd9cm_hierarchy[icd.data::icd9cm_hierarchy[["code"]] == "V9192", "long_desc"],
    "Other specified multiple gestation, with two or more monoamniotic fetuses")
})