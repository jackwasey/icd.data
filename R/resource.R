#' Get or check existence of a getter function, returning the name of, or the function itself
#'
#' The getter looks first in the environment cache, then file cache for a parsed
#' \code{.rds} file. It does not try to download or parse data. For that, see
#' \code{\link{.get_parser_name}}
#' @keywords internal
.get_getter_name <- function(var_name) {
  paste0(".get_", paste0(var_name))
}

.get_getter_fun <- function(var_name) {
  match.fun(.get_getter_name(var_name))
}

#' Parse ICD data (downloading data if needed)
#' @seealso \code{\link{.get}}, \code{\link{.get_getter_name}} and \code{\link{.get_parse_icd10cm_name}}
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
.get_fetcher_name <- function(var_name) {
  paste0(".fetch_", var_name)
}

#' @rdname dot-get_fetcher_name
.get_fetcher_fun <- function(var_name) {
  match.fun(.get_fetcher_name(var_name))
}

#' @rdname dot-get_getter_name
.exists_in_cache <- function(var_name, verbose = TRUE) {
  if (verbose) {
    message("Seeing if ", sQuote(var_name), " exists in cache env or dir")
  }
  stopifnot(is.character(var_name))
  if (verbose) message("Trying icd_data_env environment")
  if (.exists(var_name)) return(TRUE)
  fp <- .rds_path(var_name)
  if (verbose) message("Trying file at: ", fp)
  return(file.exists(fp))
  if (verbose) message(var_name, " not seen in cache env or dir.")
  FALSE
}

#' @rdname .get_getter_name
.get_from_cache <- function(var_name,
                            must_work = TRUE,
                            verbose = TRUE) {
  if (verbose) {
    message(
      "Trying to get ", sQuote(var_name),
      " from cache env or dir"
    )
  }
  if (!.exists_in_cache(var_name = var_name, verbose = verbose)) {
    if (must_work) stop("Unable to get cached data for: ", var_name)
    return()
  }
  if (verbose) message("Trying icd_data_env environment")
  if (.exists(var_name)) return(.get(var_name))
  fp <- .rds_path(var_name)
  if (verbose) message("Getting file at: ", fp)
  val <- readRDS(fp)
  .assign(var_name, val)
  val
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
    unlink(get_resource_dir(), recursive = TRUE)
    return(invisible())
  }
  if (memoise) {
    message("deleting memoise directory")
    unlink(
      file.path(get_resource_dir(), "memoise"),
      recursive = TRUE
    )
  }
  if (raw) {
    raw_files <- list.files(get_resource_dir(),
                            pattern = "(\\.txt$)|(\\.xlsx$)",
                            ignore.case = TRUE,
                            full.names = TRUE
    )
    message("Deleting:")
    print(raw_files)
    unlink(raw_files, recursive = FALSE)
  }
  if (rds) {
    rds_files <- list.files(get_resource_dir(), ".*\\.rds", full.names = TRUE)
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
    if (verbose) message("Starting fetcher")
    # TODO: call the specific/generated getter instead?
    dat <- .get_from_cache(var_name,
                           must_work = FALSE,
                           verbose = verbose
    )
    if (!is.null(dat)) return(dat)
    if (verbose) message("Trying to call parse function")
    if (verbose) message("name is ", sQuote(parse_fun_name))
    fr <- environment()
    if (exists(parse_fun_name, fr, inherits = TRUE)) {
      if (verbose) message("Found parse function. Calling it.")
      out <- do.call(get(parse_fun_name,
                         envir = fr,
                         inherits = TRUE
      ),
      args = list()
      )
      .save_in_resource_dir(out, var_name = var_name)
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
                                       verbose = TRUE) {
  # for (var_name in names(.bindings)) {
  for (var_name in .binding_names) {
    # dx_pc <- .bindings[[var_name]]
    # for (x in dx_pc) {
    if (verbose) message("working on ", var_name)
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
.make_getters_and_fetchers(verbose = TRUE)

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
.fetch <- function(var_name,
                   must_work = TRUE,
                   verbose = TRUE,
                   ...) {
  if (.exists_in_cache(var_name, verbose = verbose)) {
    .get_from_cache(var_name,
                    must_work = TRUE,
                    verbose = verbose
    )
  } else {
    parser <- .get_parser_fun(var_name)
    parser(verbose = verbose,
           must_work = must_work,
           ...)
  }
}

#' @rdname dot-fetch
.available <- function(var_name, verbose = TRUE, ...) {
  with_offline(
    !is.null(
      .fetch(var_name = var_name,
             must_work = FALSE,
             verbose = verbose,
             ...)
    )
  )
}

#' Get or set the resource directory for on-demand downloads, and cached data
#'
#' For getting the path, first the option \code{icd.data.resource} is tried,
#' otherwise \code{\link{setup_resource_dir}} is called.
#'
#' For setting, \code{path} is created if it does not exist.
#' @param path Path to desired directory
#' @param interact Whether to prompt, defaults to \code{interactive()}
#' @param force Whether to set the default path of \code{~/.icd.data} regardless
#'   of user interactivity.
#' @template verbose
#' @param must_work Single logical, default is \code{FALSE}
#' @param ... Arguments passed to \code{\link{setup_resource_dir}} if this is
#'   required.
#' @return The path to the resource directory, or \code{NULL} if it could not be
#'   found.
#' @examples
#' set_data_dir(td <- tempdir())
#' get_data_dir()
#' unlink(td)
#' try(get_data_dir())
#' @export
icd_setup_data_dir <- function(path = NULL,
                           interact = getOption("icd.data.interact", FALSE),
                           force = TRUE,
                           verbose = TRUE) {
  default_path <- file.path("~", ".icd.data")
  for (trypath in c(
    path,
    getOption("icd.data.resource", default = ""),
    Sys.getenv("ICD_DATA_PATH"),
    file.path(Sys.getenv("HOME"), ".icd.data"),
    path.expand(default_path)
  )) {
    if (verbose) message("Trying path: ", trypath)
    if (!is.null(trypath) && dir.exists(trypath)) {
      options("icd.data.resource" = trypath)
      return(trypath)
    }
  }
  # ask if we can create the directory, or use temp. Don't defer this until
  # later as it causes a lot of problems with the active bindings.
  if (force) dir.create(path.expand(default_path))
  if (!interact) return(NULL)
  ok <- utils::askYesNo(
    "For use of WHO, French, Belgian, and some versions of US ICD-10-CM, icd.data needs to download and process data. The data occupies a few MB per ICD edition. Is it alright to create a directory \".icd.data\" in your home directory for this purpose?"
  ) # nolint
  if (!isTRUE(ok)) {
    temp_dir <- tempdir()
    message("Using a temporary directory: ", temp_dir)
    return(set_resource_dir(temp_dir))
  }
  options("icd.data.offline" = FALSE)
  invisible(set_resource_dir(default_path))
}

.set_data_dir <- function(path = file.path("~", ".icd.data")) {
  if (!dir.exists(path)) {
    if (!dir.create(path)) stop("Could not create directory at: ", path)
  }
  options("icd.data.resource" = path)
  invisible(path)
}

#' @rdname setup_data_dir
#' @export
icd_get_data_dir <- function(must_work = FALSE, ...) {
  o <- getOption("icd.data.resource")
  if (!is.null(o)) return(o)
  if (!dir.exists(o)) return(setup_resource_dir(...))
  if (must_work) {
    stop("The ", sQuote("icd.data.resource"), " option is not set.")
  }
  NULL
}

.confirm_download <- function(must_work = TRUE,
                              interact = getOption("icd.data.interact", FALSE)) {
  if (isFALSE(getOption("icd.data.offline"))) {
    return(TRUE)
  }
  ok <- FALSE
  if (!isTRUE(getOption("icd.data.interact")) && interact) {
    ok <- isTRUE(
      utils::askYesNo(
        "For some data, icd.data needs to download it on demand. May I download a few MB per ICD edition, as needed?" # nolint
      ) # nolint
    )
  }
  options("icd.data.offline" = !ok)
  if (must_work && !ok) {
    stop("Unable to get permission to download data")
  }
  ok
}
.rds_path <- function(var_name) {
  file.path(get_resource_dir(), paste0(var_name, ".rds"))
}

#' Check or get data from environment, not file cache
#'
#' @seealso \code{\link{.get_getter_name}}
#' @keywords internal
.exists <- function(var_name) {
  exists(x = var_name, envir = .icd_data_env)
}

#' @rdname dot-exists
.get <- function(var_name) {
  get(x = var_name, envir = .icd_data_env)
}

#' @rdname dot-exists
.assign <- function(var_name, value) {
  assign(
    x = var_name,
    value = value,
    envir = .icd_data_env
  )
}

#' @rdname dot-exists
.ls <- function() {
  ls(.icd_data_env, all.names = TRUE)
}

#' List the actual data in this package, not bindings
#' @examples
#' icd.data:::.ls_icd_data()
#' @keywords datasets internal
.ls_icd_data <- function() {
  utils::data(package = "icd.data")$results[, "Item"]
}
