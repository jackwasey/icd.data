context("active bindings")

test_that("download and parse all active bindings", {
  ns <- asNamespace("icd.data")
  for (b in c(
    .binding_names,
    "icd10cm_latest",
    "icd10cm_active"
  )) {
    inf <- paste("Binding:", b)
    expect_true(b %in% ls(ns), info = inf)
    expect_true(.exists_in_ns(b), info = inf)
    expect_true(bindingIsActive(b, ns), info = inf)
    expect_true(bindingIsLocked(b, ns), info = inf)
    skip_if_offline()
    dat <- get(b, ns)
    expect_is(dat, "data.frame", info = inf)
  }
})
