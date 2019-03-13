# Set up an environemnt to cache ICD data
.icd_data_env <- new.env(parent = emptyenv())

# Generate getter functions for all bound data
.bindings <- list(
  # WHO
  "icd10who2016" = c("dx"),
  "icd10who2008fr" = c("dx"),
  # FR
  "icd10fr2019" = c("dx"),
  # BE
  "icd10be2014" = c("dx", "pc"),
  "icd10be2017" = c("dx", "pc"),
  # ICD-10-CM
  "icd10cm2014" = c("dx", "pc"),
  "icd10cm2015" = c("dx", "pc"),
  "icd10cm2016" = c("pc"),
  "icd10cm2017" = c("dx", "pc"),
  "icd10cm2018" = c("dx", "pc"),
  "icd10cm2019" = c("pc")
)

.binding_names <- list(
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
  "icd10cm2016_pc",
  "icd10cm2017",
  "icd10cm2017_pc",
  "icd10cm2018",
  "icd10cm2018_pc",
  "icd10cm2019_pc"
)

.make_active_bindings <- function(final_env, verbose = TRUE) {
  for (var_name in .binding_names) {
    if (verbose) message("Making active binding(s) for: ", var_name)
    binding_fun <- .make_binding_fun(var_name = var_name, verbose = verbose)
    bound_name <- paste0(".", var_name, "_binding")
    assign(bound_name, eval(binding_fun), final_env)
    if (verbose) message("Trying to create active binding itself")
    ff <- get(bound_name, final_env)
    if (is.function(ff)) {
      if (exists(var_name, final_env)) {
        stop(var_name, " already exists.")
      }
      makeActiveBinding(
        sym = var_name,
        ff,
        env = final_env
      )
      lockBinding(var_name, final_env)
    } else {
      if (verbose) message(var_name, " is not a function! Skipping")
    }
    # set environment of the binding? environment(get())
  } # end loop through bindings
}

.make_binding_fun <- function(var_name, verbose = TRUE) {
  # TODO: ideally don't use do.call, but the actual function (or it's symbol?)
  if (verbose) message("Making binding fun for: ", var_name)
  fetcher_name <- .get_fetcher_name(var_name)
  binding_fun <- function(x) {
    if (verbose) message("Running binding for ", var_name)
    if (!missing(x)) .stop_binding_ro()
    dat <- do.call(fetcher_name, args = list())
    if (!is.null(dat)) return(dat)
    .message_who()
    .stop_on_absent(paste(var_name, "not available."))
  }
  f_env <- environment(binding_fun)
  f_env$fetcher_name <- fetcher_name
  f_env$var_name <- var_name
  f_env$verbose <- verbose
  binding_fun
}

skip_if_no_dat <- function() {
  # testthat::skip
}

# Dynamic
.icd9cm2011_binding <- function(x) {
  if (!missing(x)) .stop_binding_ro()
  icd9cm_hierarchy
}
makeActiveBinding("icd9cm2011", .icd9cm2011_binding, environment())
lockBinding("icd9cm2011", environment())

.icd10cm_active_binding <- function(x) {
  if (!missing(x)) .stop_binding_ro()
  get_icd10cm_version()
}
makeActiveBinding("icd10cm_active", .icd10cm_active_binding, environment())
lockBinding("icd10cm_active", environment())

.icd10cm_latest_binding <- function(x) {
  if (!missing(x)) .stop_binding_ro()
  icd10cm2019
}
makeActiveBinding("icd10cm_latest", .icd10cm_latest_binding, environment())
lockBinding("icd10cm_latest", environment())

#' Localised synonym for icd10fr2019, with French column names
#' @keywords internal
#' @noRd
.cim10fr2019_binding <- function(x) {
  if (!missing(x)) .stop_binding_ro()
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

.icd9cm_leaf_v32_binding <- function(x) {
  stopifnot(missing(x))
  icd9cm_billable[["32"]]
}
makeActiveBinding("icd9cm_leaf_v32", .icd9cm_leaf_v32_binding, environment())
lockBinding("icd9cm_leaf_v32", environment())

.message_who <- function() {
  o <- getOption("icd.data_absent_action")
  if (!is.null(o) && o %nin% c("stop", "message")) {
    # TODO: update this message, as we now automate.
    message(
      "WHO ICD data must be downloaded by each user due to copyright
    concerns. This may be achieved by running either of the commands

    icd.data:::.fetch_icd10who2016()
    icd.data:::.fetch_icd10who2008_fr()

    The data has to be saved somewhere accessible. The
    location is given by:

    icd_data_dir()

    which defaults to:

    file.path(\"~/.icd.data\")

    See:
    icd_data_dir(),
    icd_setup_data_dir(\"new/path/to/dir\")"
    )
  }
}

.stop_binding_ro <- function() {
  stop("This active binding cannot be set.", call. = FALSE)
}
