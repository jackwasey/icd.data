#' Get or check existence of a getter function, returning the name of, or the function itself
#'
#' The getter looks first in the environment cache, then file cache for a parsed
#' \code{.rds} file. It does not try to download or parse data. For that, see
#' \code{\link{.get_parser_name}}
#' @keywords internal
#' @noRd
.get_getter_name <- function(var_name) {
  paste0(".get_", paste0(var_name))
}

.get_getter_fun <- function(var_name) {
  match.fun(.get_getter_name(var_name))
}

#' Parse ICD data (downloading data if needed)
#' @seealso \code{\link{.get}}, \code{.get_getter_name} and \code{.get_parser_icd10cm_name}
#' @keywords internal
#' @noRd
.get_parser_name <- function(var_name) {
  paste0(".parse_", var_name)
}

.get_parser_fun <- function(var_name) {
  match.fun(.get_parser_name(var_name))
}

.get_parser_icd10cm_name <- function(ver, dx) {
  paste0(".parse_", paste0("icd10cm", ver, ifelse(dx, "", "_pc")))
}

#' Get name or function for fetching a specific ICD data set
#' @seealso \code{\link{.fetch}}
#' @keywords internal
#' @noRd
.get_fetcher_name <- function(var_name) {
  paste0(".fetch_", var_name)
}

.get_fetcher_fun <- function(var_name) {
  match.fun(.get_fetcher_name(var_name))
}

.exists_in_cache <- function(var_name, verbose = .verbose()) {
  if (verbose > 1) {
    message("Seeing if ", sQuote(var_name), " exists in cache env or dir")
  }
  stopifnot(is.character(var_name))
  if (verbose > 1) message("Trying icd_data_env environment")
  if (.exists(var_name)) {
    if (verbose) message(sQuote(var_name), " found in cache.")
    return(TRUE)
  }
  fp <- .rds_path(var_name)
  if (verbose > 1) message("Checking if we have file path for exists")
  if (is.null(fp)) return(FALSE)
  if (verbose > 1) message("Trying file at: ", fp)
  return(file.exists(fp))
  if (verbose > 1) message(var_name, " not seen in cache env or dir.")
  FALSE
}

.get_from_cache <- function(var_name,
                            must_work = TRUE,
                            verbose = .verbose()) {
  if (verbose) {
    message(
      "Trying to get ", sQuote(var_name), " from cache env or dir"
    )
  }
  if (!.exists_in_cache(var_name = var_name, verbose = verbose)) {
    msg <- paste("Unable to get cached data for:", var_name)
    .absent_action_switch(msg, must_work = must_work)
    return()
  }
  if (verbose) message("Trying icd_data_env environment")
  if (.exists(var_name)) return(.get(var_name))
  fp <- .rds_path(var_name)
  if (verbose) message("Checking if we have file path for get")
  if (is.null(fp)) return()
  if (verbose) message("Getting file at: ", fp)
  val <- readRDS(fp)
  .assign(var_name, val)
  val
}

.all_cached <- function() {
  all(
    vapply(.binding_names, .exists_in_cache, logical(1))
  )
}

.clean_env <- function() {
  rm(list = ls(.icd_data_env, all.names = TRUE), envir = .icd_data_env)
}

.clean_resource_dir <- function(rds = FALSE,
                                memoise = FALSE,
                                raw = FALSE,
                                destroy = FALSE) {
  if (destroy) {
    utils::askYesNo("Destroy entire resource directory?")
    unlink(icd_data_dir(), recursive = TRUE)
    return(invisible())
  }
  if (memoise) {
    message("deleting memoise directory")
    unlink(
      file.path(icd_data_dir(), "memoise"),
      recursive = TRUE
    )
  }
  if (raw) {
    raw_files <- list.files(icd_data_dir(),
                            pattern = "(\\.txt$)|(\\.xlsx$)",
                            ignore.case = TRUE,
                            full.names = TRUE
    )
    message("Deleting:")
    print(raw_files)
    unlink(raw_files, recursive = FALSE)
  }
  if (rds) {
    rds_files <- list.files(icd_data_dir(), ".*\\.rds", full.names = TRUE)
    message("Deleting:")
    print(rds_files)
    unlink(rds_files,
           recursive = FALSE
    )
  }
}

.make_getter <- function(var_name, verbose) {
  force(var_name)
  force(verbose)
  getter_fun <- function(alt = NULL,
                         must_work = TRUE,
                         msg = paste("Unable to find", var_name)) {
    if (verbose) message("Starting getter")
    stopifnot(is.character(var_name))
    dat <- .get_from_cache(var_name,
                           must_work = FALSE,
                           verbose = verbose
    )
    if (!is.null(dat)) return(dat)
    if (must_work) {
      stop("Cannot get ", sQuote(var_name), " from caches and it must work.")
    }
    if (is.null(alt)) {
      message("Returning NULL as alternative data are not specified")
      return()
    }
    if (verbose) message("Returning 'alt' as ", var_name, " not available")
    alt
  }
  f_env <- environment(getter_fun)
  f_env$verbose <- verbose
  f_env$var_name <- var_name
  getter_fun
}

.make_fetcher <- function(var_name, verbose) {
  force(var_name)
  force(verbose)
  parse_fun_name <- .get_parser_name(var_name)
  fetcher_fun <- function(alt = NULL,
                          must_work = TRUE,
                          msg = paste("Unable to find", var_name)) {
    if (verbose) message("Starting fetcher for ", var_name)
    # TODO: call the specific/generated getter instead?
    dat <- .get_from_cache(var_name = var_name,
                           must_work = FALSE,
                           verbose = verbose
    )
    if (!is.null(dat)) return(dat)
    if (verbose) message("Trying to find parse function: ",
                         sQuote(parse_fun_name))
    fr <- environment()
    if (exists(parse_fun_name, fr, inherits = TRUE)) {
      if (verbose) message("Found parse function. Calling it.")
      out <- do.call(get(parse_fun_name,
                         envir = fr,
                         inherits = TRUE
      ),
      args = list()
      )
      if (verbose && is.null(out)) message("Returning NULL")
      if (!is.null(out) && !.offline()) {
        .save_in_resource_dir(x = out, var_name = var_name)
      }
      return(out)
    } else {
      stop("No parse function: ", parse_fun_name)
    }
    # Parse function should have saved the data in env and file caches
    dat <- .get_from_cache(var_name,
                           must_work = FALSE,
                           verbose = verbose
    )
    if (!is.null(dat)) return(dat)
    if (must_work) {
      stop(
        "Cannot fetch (download/parse/get from cache) that data using ",
        parse_fun_name, ", and it must work."
      )
    }
    if (is.null(alt)) {
      if (verbose) message("Returning NULL, as alternative data are not set")
      return()
    }
    if (verbose) {
      message(
        "Returning alternative data because ", parse_fun_name,
        " not available"
      )
    }
    alt
  }
  f_env <- environment(fetcher_fun)
  f_env$verbose <- verbose
  f_env$parse_fun_name <- parse_fun_name
  f_env$var_name <- var_name
  fetcher_fun
}

.make_getters_and_fetchers <- function(final_env = parent.frame(),
                                       verbose = .verbose()) {
  # for (var_name in names(.bindings)) {
  for (var_name in .binding_names) {
    if (verbose) message("Making getters and fetchers for ", var_name)
    getter_name <- .get_getter_name(var_name)
    if (verbose) message("assigning: ", getter_name)
    assign(getter_name,
           .make_getter(var_name, verbose),
           envir = final_env
    )
    fetcher_name <- .get_fetcher_name(var_name)
    if (verbose) message("assigning: ", fetcher_name)
    assign(fetcher_name,
           .make_fetcher(var_name, verbose),
           envir = final_env
    )
  }
}
.make_getters_and_fetchers(verbose = .verbose())

#' Gets data, from env cache, file cache, the downloading and parsing if
#' necessary and possible.
#'
#' Fetch functions are of the form \code{.fetch_icd10cm2015}. This is generic
#' for all datasets, and calls the data specific \code{parse} function, which
#' itself will call (if necessary) the data-specific \code{dl} download
#' function.
#' @param var_name Character, e.g., \code{"icd10cm2015"}
#' @param must_work Single logical
#' @template verbose
#' @param ... E.g., \code{dx = FALSE} or \code{offline = TRUE}
#' @keywords internal
#' @noRd
.fetch <- function(var_name,
                   must_work = TRUE,
                   verbose = .verbose(),
                   ...) {
  if (.exists_in_cache(var_name, verbose = verbose)) {
    .get_from_cache(var_name,
                    must_work = TRUE,
                    verbose = verbose
    )
  } else {
    parser <- .get_parser_fun(var_name)
    parser(
      verbose = verbose,
      must_work = must_work,
      ...
    )
  }
}

.available <- function(var_name, verbose = .verbose(), ...) {
  with_offline(offline = TRUE, {
    !is.null(
      .fetch(
        var_name = var_name,
        must_work = FALSE,
        verbose = verbose,
        ...
      )
    )
  }
  )
}

.icd_data_default <- file.path("~", ".icd.data")

.set_data_dir <- function(path = .icd_data_default) {
  if (!dir.exists(path)) {
    if (!dir.create(path)) stop("Could not create directory at: ", path)
  }
  options("icd.data.resource" = path)
  invisible(path)
}

#' @describeIn setup_icd_data Return the currently active data directory. If missing, it will return \code{NULL} and, depending on \code{getOption("icd.data.absent_action")}, will stop, give a message, or do nothing.
#' @export
icd_data_dir <- function() {
  o <- getOption("icd.data.resource")
  if (!is.null(o)) return(o)
  icd_data_setup()
  o <- getOption("icd.data.resource")
  if (!is.null(o)) return(o)
  msg <- paste("The", sQuote("icd.data.resource"), "option is not set.")
  if (.verbose()) message(msg)
  #.absent_action_switch(msg)
  #warning(msg)
  #TODO: argh!! .absent_action_switch(msg)
  NULL
}

.confirm_download <- function(absent_action = .absent_action(),
                              interact = .interactive()) {
  if (!.offline()) return(TRUE)
  ok <- FALSE
  if (interact) {
    message("icd.data needs to download and/or parse data.")
    ok <- isTRUE(
      utils::askYesNo(
        "May I download and cache a few MB per ICD edition as needed?" # nolint
      ) # nolint
    )
  }
  options("icd.data.offline" = !ok)
  msg <- "Unable to get permission to download data."
  .absent_action_switch(msg)
  ok
}

.rds_path <- function(var_name) {
  fp <- file.path(icd_data_dir(), paste0(var_name, ".rds"))
  if (length(fp) == 0)
    NULL
  else
    fp
}

#' Check or get data from environment, not file cache
#'
#' @seealso \code{\link{.get_getter_name}} .assign and .ls
#' @keywords internal
#' @noRd
.exists <- function(var_name) {
  exists(x = var_name, envir = .icd_data_env)
}

.get <- function(var_name) {
  get(x = var_name, envir = .icd_data_env)
}

.assign <- function(var_name, value) {
  assign(
    x = var_name,
    value = value,
    envir = .icd_data_env
  )
}

.ls <- function() {
  ls(.icd_data_env, all.names = TRUE)
}

#' List the actual data in this package, not bindings
#' @examples
#' icd.data:::.ls_icd_data()
#' @keywords datasets internal
#' @noRd
.ls_icd_data <- function() {
  utils::data(package = "icd.data")$results[, "Item"]
}
