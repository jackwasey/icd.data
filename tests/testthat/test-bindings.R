context("active bindings")

test_that("download and parse all active bindings", {
  # old_opt <- options(icd.data.offline = TRUE)
  # on.exit(old_opt, add = TRUE)
  ns <- asNamespace("icd.data")
  for (b in c(.binding_names, "icd10cm_latest", "icd10cm_active")) {
    inf <- paste("Binding: ", b)
    expect_true(bindingIsActive(b, ns), info = inf)
    expect_true(bindingIsLocked(b, ns), info = inf)
    expect_is(.get(var_name = b), "data.frame", info = inf)
  }
})
