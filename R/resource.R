.rds_path <- function(var_name) {
  file.path(get_resource_dir(), paste0(var_name, ".rds"))
}

.exists <- function(var_name) {
  exists(x = var_name, envir = .icd_data_env)
}

.get <- function(var_name) {
  get(x = var_name, envir = .icd_data_env)
}

.get_from_cache <- function(var_name, must_work = TRUE, verbose = TRUE) {
  if (verbose) {
    message(
      "Trying to get ", sQuote(var_name),
      " from cache env or dir"
    )
  }
  stopifnot(is.character(var_name))
  if (verbose) message("Trying icd_data_env environment")
  if (.exists(var_name)) return(.get(var_name))
  fp <- .rds_path(var_name)
  if (verbose) message("Trying file at: ", fp)
  if (file.exists(fp)) {
    val <- readRDS(fp)
    .assign(var_name, val)
    return(val)
  }
  if (must_work) {
    stop("Unable to get cached data for: ", var_name)
  }
  if (verbose) message(var_name, " not found in cache env or dir.")
  invisible()
}

.assign <- function(var_name, value) {
  assign(
    x = var_name,
    value = value,
    envir = .icd_data_env
  )
}
#' This directory is created only at user's permission. Default is \code{~/.icd.data}.

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
#' set_resource_dir(td <- tempdir())
#' get_resource_dir()
#' unlink(td)
#' try(get_resource_dir())
#' @export
setup_resource_dir <- function(path = NULL,
                               interact = interactive(),
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
  if (force) dir.create(path.expand(file.path("~", ".icd.data")))
  if (!interact) return(NULL)
  ok <- utils::askYesNo(
    "For use of WHO, French, Belgian, and some versions of US ICD-10-CM,
icd.data needs to download and process data.
The data occupies a few MB per ICD edition.
Is it alright to create a directory \".icd.data\" in your
home directory for this purpose?"
  ) # nolint
  if (!isTRUE(ok)) {
    temp_dir <- tempdir()
    message("Using a temporary directory: ", temp_dir)
    return(set_resource_dir(temp_dir))
  }
  options("icd.data.offline" = FALSE)
  invisible(set_resource_dir(default_path))
}

#' @rdname setup_resource_dir
#' @export
set_resource_dir <- function(path) {
  if (!dir.exists(path)) {
    if (!dir.create(path)) stop("Could not create directory at: ", path)
  }
  options("icd.data.resource" = path)
  invisible(path)
}

#' @rdname setup_resource_dir
#' @export
get_resource_dir <- function(must_work = FALSE, ...) {
  o <- getOption("icd.data.resource")
  if (!is.null(o)) return(o)
  if (!dir.exists(o)) return(setup_resource_dir(...))
  if (must_work) {
    stop("The ", sQuote("icd.data.resource"), " option is not set.")
  }
  NULL
}

.clean_resource_dir <- function(rds = TRUE,
                                memoise = FALSE,
                                raw = FALSE,
                                destroy = FALSE) {
  if (destroy) {
    utils::askYesNo("Destroy entire resource directory?")
    unlink(get_resource_dir(), recursive = TRUE)
    return(invisible())
  }
  if (memoise) {
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

.confirm_download <- function(must_work = TRUE) {
  if (isFALSE(getOption("icd.data.offline"))) {
    return(TRUE)
  }
  ok <- FALSE
  if (interactive()) {
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
