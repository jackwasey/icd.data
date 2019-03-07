
# Set up an environemnt to cache ICD data
.icd_data_env <- new.env(parent = emptyenv())

# Generate getter functions for all bound data
.binding_names <- c(
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
  # not 16 dx
  "icd10cm2016_pc",
  "icd10cm2017",
  "icd10cm2017_pc",
  "icd10cm2018",
  "icd10cm2018_pc",
  # not 19 dx
  "icd10cm2019_pc"
)

.make_active_bindings <- function(final_env, verbose = TRUE) {
  # This looks hairy, but we just generate the getters and binding functions
  for (var_name in .binding_names) {
    if (verbose) message("working on ", var_name)
    # TODO: would like to substitute symbol, not string
    f <- substitute(
      env = list(
        var_name = var_name,
        dl_fun_name = paste0(".fetch_", var_name)
      ),
      function(alt = NULL,
                     must_work = TRUE,
                     msg = paste("Unable to find", var_name),
                     verbose = TRUE) {
        if (verbose) message("Starting getter")
        stopifnot(is.character(var_name))
        dat <- .get_from_cache(var_name,
          must_work = FALSE,
          verbose = verbose
        )
        if (!is.null(dat)) return(dat)
        if (verbose) message("Trying to call fetch function")
        if (verbose) message("name is ", dl_fun_name)
        # for (fr in list(parent.frame(), asNamespace("icd.data"))) {
        fr <- environment()
        if (exists(dl_fun_name, fr, inherits = TRUE)) {
          if (verbose) message("Found!")
          return(do.call(get(dl_fun_name,
            envir = fr,
            inherits = TRUE
          ),
          args = list() # parse = TRUE,
          # save_data = TRUE,
          # verbose = verbose)
          ))
        } else {
          stop("No fetch function: ", dl_fun_name)
        }
        dat <- .get_from_cache(var_name,
          must_work = FALSE,
          verbose = verbose
        )
        if (!is.null(dat)) return(dat)
        if (must_work) {
          stop(
            "Cannot find or fetch that data using ",
            dl_fun_name, ", and it must work."
          )
        }
        if (is.null(alt)) {
          warning(msg)
        }
        message("Returning 'alt' as ", dl_fun_name, " not available")
        alt
      }
    ) # end of function substitution
    getter_name <- paste0(".get_", var_name)
    message("assigning ", getter_name)
    assign(getter_name, eval(f), final_env)
    # now the active binding functions themselves
    if (verbose) message("getter done, now active binding")
    # environment just for the getter name substitution
    binding_fun <- substitute(
      env = list(getter_name = getter_name),
      function(x) {
        if (!missing(x)) .stop_binding_ro()
        dat <- do.call(getter_name, args = list())
        if (!is.null(dat)) return(dat)
        .message_who()
        .stop_on_absent(paste(var_name, "not available."))
      }
    )
    bound_name <- paste0(".", var_name, "_binding")
    assign(bound_name, eval(binding_fun), final_env)
    message("Trying to create active binding itself")
    ff <- get(bound_name, final_env)
    message("class of ff is: ", class(ff))
    if (is.function(ff)) {
      makeActiveBinding(
        sym = var_name,
        ff,
        env = final_env
      )
    } else {
      message("not a function! Skipping")
    }
    # set environment of the binding? environment(get())
  } # end loop through bindings
}
.make_active_bindings(environment())

.mkmkabfun <- function(env) {
  .mkabfun <- function(getter) {
    force(getter)
    substitute(
      env = list(getter = as.name(getter)),
      function(x) {
        if (!missing(x)) .stop_binding_ro()
        dat <- getter()
        if (!is.null(dat)) return(dat)
        .message_who()
        .stop_on_absent("ICD-10-BE 2014 not available.")
      }
    )
  }
  environment(.mkabfun) <- env
  .mkabfun
}

# Dynamic
.icd9cm2011_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  icd.data::icd9cm_hierarchy
}

.icd10cm_active_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  get_icd10cm_version()
}

.icd10cm_latest_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  icd.data::icd10cm2019
}

#' Localised synonym for icd10fr2019, with French column names
#' @keywords internal
#' @noRd
.cim10fr2019_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  if (exists("cim10fr2019", envir = .icd_data_env)) {
    return(get("cim10fr2019", envir = .icd_data_env))
  }
  cim10fr2019 <- icd.data::icd10fr2019
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

    get_resource_dir()

    which defaults to:

    file.path(\"~/.icd.data\")

    See:
    get_resource_dir(),
    set_resource_dir(\"new/path/to/dir\")"
    )
  }
}

.stop_binding_ro <- function() {
  stop("This active binding cannot be set.", call. = FALSE)
}
