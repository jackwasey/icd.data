context("active bindings")

test_that("download and parse all active bindings", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  ns <- asNamespace("icd.data")
  for (b in c(
    .binding_names,
    "icd10cm_latest"
  )) {
    inf <- paste("Binding:", b)
    expect_true(b %in% ls(ns), info = inf)
    expect_true(.exists_in_ns(b), info = inf)
    expect_true(bindingIsActive(b, ns), info = inf)
    expect_true(bindingIsLocked(b, ns), info = inf)
    dat <- get(b, ns)
    expect_is(dat, "data.frame", info = inf)
  }
})
