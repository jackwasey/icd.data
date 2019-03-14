.show_options <- function() {
  o <- options()
  o[grepl("^icd\\.data", names(o))]
}

#' Set initial options for the package
#'
#' \code{icd.data.offline} - default is TRUE, unless ICD_DATA_OFFLINE is false/no. This will only ever be turned on with explicit user authorization (or by directly setting it). Turning this on also results in data being saved in the data directory. See below.
#'
#' \code{icd.data.interact} - default is based on interactive mode of R, as given by \code{base::interactive()}.
#'
#' \code{icd.data.resource} - default is ~/.icd.data but won't write unless user gives
#' permission
#'
#' \code{icd.data.absent_action} - what to do if data is missing, "stop" or "message"
#' consider removing this. Need to automate the hell out of this, but might be
#' useful for testing.
#'
#' \code{icd.data.icd10cm_active_ver} - which ICD-10-CM version is currently active.
#' Default is 2019.
#'
#' See also \code{.show_options()} \code{.clear_options()} \code{.set_dev_options()}
#' @keywords internal
.set_init_options <- function() {
  if (!("icd.data.verbose" %in% names(options()))) {
    options(icd.data.verbose = FALSE)
  }
  if (!("icd.data.offline" %in% names(options()))) {
    options("icd.data.offline" = !.env_var_is_false("ICD_DATA_OFFLINE"))
  }
  if (!("icd.data.interact" %in% names(options()))) {
    options("icd.data.interact" =
              !.env_var_is_false("ICD_DATA_INTERACT") ||
              interactive())
  }
  # stop or message, anything else will silently continue
  if ("icd.data.absent_action" %nin% names(options())) {
    ev <- tolower(Sys.getenv("ICD_DATA_ABSENT_ACTION", unset = "message"))
    stopifnot(ev %in% c("message",
                        "stop",
                        "warning",
                        "warn",
                        "silent"))
    options("icd.data.absent_action" = ev)
  }
  # Which version of ICD-10-CM to use by default?
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
}

.set <- function(..., overwrite = FALSE) {
  f <- list(...)
  invisible(
    lapply(names(f),
           function(o) {
             if (overwrite || is.null(getOption(o))) {
               args <- list(f[[o]])
               names(args) <- paste0("icd.data.", o)
               do.call(options, args = args)
             }
           })
  )
}

.set_hard <- function(...) {
  .set(..., overwrite = TRUE)
}

.set_default_options <- function(hard) {
  f <- if (hard) .set_hard else .set
  f(offline = TRUE,
    absent_action = "stop",
    icd10cm_active_ver = "2019",
    resource = .icd_data_default,
    interact = interactive(),
    verbose = TRUE)
}

.set_test_options <- function() {
  .set_hard(interact = FALSE,
            verbose = TRUE)
}

# Simulate the empty world of CRAN and R CMD check
.set_check_options <- function() {
  .set_hard(interact = FALSE,
            absent_action = "silent",
            resource = tempdir(),
            verbose = FALSE)
}

.set_attached_options <- function() {
  .set_default_options(hard = FALSE)
  .set(offline = TRUE,
       absent_action = "stop",
       resource = .icd_data_default,
       interact = interactive())
}

.set_dev_options <- function() {
  .set_default_options(hard = TRUE)
  .set(offline = FALSE,
       absent_action = TRUE,
       resource = .icd_data_default)
}

.verbose <- function() {
  isTRUE(getOption("icd.data.verbose"))
  # FALSE
}

.interactive <- function() {
  isTRUE(getOption("icd.data.interact"))
}

.offline <- function() {
  !isFALSE(getOption("icd.data.offline"))
}

.absent_action <- function() {
  a <- getOption("icd.data.absent_action")
  # default to silent, as I think R check uses empty options for various parts of check, which ignore anything I might have wanted to set in .onLoad .
  if (is.null(a))
    "silent"
  else
    a
}

.absent_action_switch <- function(msg, must_work = TRUE) {
  switch(.absent_action(),
         "stop" = {
           if (must_work)
             stop(msg, call. = FALSE)
           else
             warning(msg, call. = FALSE)
         },
         "warning" = warning(msg, call. = FALSE),
         "warn" = warning(msg, call. = FALSE),
         "message" = message(msg))
}

.env_var_is_false <- function(x) {
  ev <- Sys.getenv(x, unset = "")
  tolower(ev) %in% c(
    "n",
    "no",
    "false",
    "0"
  )
}

.env_var_is_true <- function(x) {
  ev <- Sys.getenv(x, unset = "")
  tolower(ev) %in% c(
    "y",
    "yes",
    "true",
    "1"
  )
}

.clear_options <- function() {
  icd_data_opts <- names(.show_options())
  icd_data_opts <- sapply(
    icd_data_opts,
    simplify = FALSE,
    USE.NAMES = TRUE,
    FUN = function(x) NULL
  )
  options(icd_data_opts)
}

with_offline <- function(offline, code) {
  old <- options("icd.data.offline" = offline)
  on.exit(options(old))
  force(code)
}

with_absent_action <- function(absent_action = c("message",
                                                 "stop",
                                                 "warning",
                                                 "warn",
                                                 "silent"),
                               code) {
  absent_action <- match.arg(absent_action)
  old <- options("icd.data.absent_action" = absent_action)
  on.exit(options(old))
  force(code)
}

#' Set up the data download cache, give permission to download data
#'
#' This must be called by the user, as prompted on package attach with \code{library(icd.data)}. \code{icd.data} is a dependency (not an import) of \code{icd}, so that \code{icd} can function more smoothly, avoiding prompting during commands, although this should still be possible, and will happen if the user initially declines permission to download and cache data.
#' @param path Path to a directory where cached online raw and parsed data will be cached. It will be created if it doesn't exist.
#' @examples
#' \dontrun{
#' icd_data_setup()
#' icd_data_setup("/var/cache/icd.data")
#' icd_data_setup(path = ".local/icd.data")
#' }
#' # or use an unexported function to set or reset:
#' icd.data:::.set_data_dir(td <- tempdir())
#' # what is the currently set directory?
#' icd_data_dir()
#' unlink(td)
#' try(icd_data_dir())
#' @return The path to the resource directory, or \code{NULL} if it could not be
#'   found.
#' @return Invisiblly returns the data path which was set, or NULL if not done.
#' @export
icd_data_setup <- function(path = .icd_data_default) {
  if (.offline() || !.interactive()) return(invisible())
  ok <- utils::askYesNo(
    paste("For use of WHO, French, Belgian, and some versions of US ICD-10-CM, icd.data needs to download and process data. The data occupies a few MB per ICD edition. Is it alright to create a directory data cache directory for this purpose? You may customize the location using 'icd_data_setup(\"/path/to/dir/\")'. Currently selected path is: ", path)
  ) # nolint
  if (!isTRUE(ok)) return(invisible())
  options("icd.data.offline" = FALSE)
  if (!.confirm_download(absent_action = "silent")) {
  } else {
    message("Using the data cache directory: ", path)
    if (!dir.exists(path)) {
      stopifnot(dir.create(path))
    }
  }
  path
}
