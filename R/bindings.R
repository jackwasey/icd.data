# Set up an environemnt to cache ICD data
.icd_data_env <- new.env(parent = emptyenv())

.data_names <- list(
  # WHO
  "icd10who2016",
  "icd10who2008fr",
  # FR
  "icd10fr2019",
  # BE
  "icd10be2014",
  "icd10be2014_pc",
  "icd10be2017",
  "icd10be2017_pc",
  # ICD-10-CM
  "icd10cm2014",
  "icd10cm2014_pc",
  "icd10cm2015",
  "icd10cm2015_pc",
  # icd10cm2016 included (but will migrate to 2019 once all is on CRAN)
  "icd10cm2016_pc",
  "icd10cm2017",
  "icd10cm2017_pc",
  "icd10cm2018",
  "icd10cm2018_pc",
  # icd10cm2019 included already
  "icd10cm2019_pc"
)

# called in .onLoad in zzz.R
#
# Actually just makes the data retrieval functions
.make_data_funs <- function(final_env = parent.frame(),
                            verbose = FALSE) {
  for (var_name in .data_names) {
    if (verbose) message("Making data function for: ", var_name)
    data_fun <- .make_data_fun(var_name = var_name, verbose = verbose)
    assign(var_name, data_fun, final_env)
  }
}

.make_data_fun <- function(var_name, verbose = FALSE) {
  # TODO: ideally don't use do.call, but the actual function (or it's symbol?)
  if (verbose) message("Making data function for: ", var_name)
  fetcher_name <- .get_fetcher_name(var_name)
  data_fun <- function() {
    if (verbose) message("Running data function for ", var_name)
    dat <- do.call(fetcher_name, args = list())
    if (!is.null(dat)) return(dat)
    .absent_action_switch(
      paste(
        var_name, "not available.",
        "WHO ICD data must be downloaded by each user due to copyright
    concerns. This may be achieved by running either of the commands
    setup_icd_data() # if you haven't already done this
    download_icd_data() # downloads WHO and all other external data
    or more specifically:
    icd.data:::.fetch_icd10who2016()
    icd.data:::.fetch_icd10who2008_fr()"
      )
    )
  }
  f_env <- environment(data_fun)
  f_env$fetcher_name <- fetcher_name
  f_env$var_name <- var_name
  f_env$verbose <- verbose
  data_fun
}

.icd9cm_billable_binding <- function(x) {
  if (.verbose() && .interact()) {
    message("Use icd9cm_leaf_v32 instead of icd9cm_billable.")
  }
  icd9cm_billable <- list()
  # just for R CMD check, with the circular dep and R-devel
  if (!requireNamespace("icd.data", quietly = TRUE)) return()
  lazyenv <- asNamespace("icd.data")$.__NAMESPACE__.$lazydata
  # work around the fact that R CMD check gets all the bindings before lazy data is put in the package namespace
  # if (!exists("icd9cm_leaf_v32", lazyenv)) return()
  icd9cm_billable[["32"]] <- get("icd9cm_leaf_v32", envir = lazyenv)
  icd9cm_billable
}
makeActiveBinding("icd9cm_billable", .icd9cm_billable_binding, environment())
lockBinding("icd9cm_billable", environment())

#' Synonym for \code{\link{icd10fr2019}}, with column names in the French language
#' @docType data
#' @keywords datasets
#' @export
cim10fr2019 <- function() {
  if (exists("cim10fr2019", envir = .icd_data_env)) {
    return(get("cim10fr2019", envir = .icd_data_env))
  }
  cim10fr2019 <- icd10fr2019
  names(cim10fr2019) <- c(
    "code",
    "desc_courte",
    "desc_longue",
    "majeure",
    "trois_chiffres"
  )
  rownames(cim10fr2019) <- NULL
  assign("cim10fr2019",
    value = cim10fr2019,
    envir = .icd_data_env
  )
  cim10fr2019
}

.message_who <- function() {

}
