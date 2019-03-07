context("active bindings")

test_that("download and parse all active bindings", {
  old_opt <- options(icd.data.offline = FALSE)
  on.exit(old_opt, add = TRUE)
  for (b in .binding_names) {
    expect_is(get(x = b, envir = asNamespace("icd.data")),
              "data.frame")
  }
})
