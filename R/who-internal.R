utils::globalVariables(".icd_data_env")

#' Get the filesystem path used to save downloaded data
#'
#' Currently this is only needed for WHO ICD-10 data, which is downloaded on
#' demand. The default path attempted is `file.path(Sys.getenv("HOME"),
#' ".icd.data")`. This may be overridden by setting the option
#' `icd.data.resource` to the path of your choice. E.g.,
#' `set_resource_path('/tmp/icd.data.resource')` or by setting the option itself
#' using `options(icd.data.resource = '/tmp/icd.data.resource')`.
#' @param set_if_missing Logical, if `TRUE`, \link{set_resource_path} is called
#' @param must_work Logical, if `TRUE`, the default, failure to get a valid path
#'   will stop execution.
#' @param verbose Logical, default `FALSE`
#' @seealso \link{set_resource_path}
#' @export
get_resource_path <- function(
  set_if_missing = FALSE,
  must_work = TRUE,
  verbose = FALSE
) {
  path <- normalizePath(getOption("icd.data.resource"), mustWork = TRUE)
  if (dir.exists(path)) {
    if (verbose) message("Found icd.data resource path exists at: ", path)
    return(path)
  }
  if (is.null(path))
    warning("icd.data.resource option is not set")
  else
    warning("icd.data.resource option has non-existent path: ", path)
  if (set_if_missing)
    return(set_resource_path(path = path, verbose = verbose))
  if (must_work) stop("Use:\nset_resource_path()\npr:\n",
                      "set_resource_path(path = '/dir/you/want')\n",
                      " to set-up cache for downloading WHO ICD-10 data.",
                      call. = FALSE)
  invisible()
}

#' Set the filesystem path used to save downloaded data
#'
#' If the directory exists, the directory is used by `icd.data`. If the
#' directory does not exist, and R is in `interactive()` mode, then the user is
#' asked whether a directory may be created. The default path of this directory
#' is given by `file.path(Sys.getenv("HOME"), ".icd.data")`, which is
#' `~/.icd.data` on Linux, MacOS, UNIX. Something like
#' `options(icd.data.resource = "/tmp/icd.data.resource")` may be used to change
#' the default directory attempted, or to avoid a prompt by using that directory
#' automatically. This may be set in `.Rprofile`. The simplest way is just to
#' let `icd.data` use the default directory.
#' @section Non-interactive mode: If R is running non-interactively, e.g. CRAN
#'   testing, Travis, package building, or in an automated user script, no
#'   directories are created and a temporary directory is created. The
#'   session-wide R option `icd.data.resource` is set to the temporary
#'   directory's path.
#' @param path Path to a writable directory, default is given by:
#'   `file.path(Sys.getenv("HOME"), ".icd.data")`
#' @param verbose Logical
#' @return The final path, which may be temporary directory if user denied
#'   creation of home directory hidden directory.
#' @seealso \link{get_resource_path}
#' @export
set_resource_path <- function(
  path = getOption("icd.resource.path"),
  verbose = FALSE
) {
  if (verbose) {
    message("Changing icd.data resource path from:")
    print(get_resource_path())
    message("to:")
    print(path)
  }
  if (!dir.exists(path)) {
    if (verbose) message("icd.data.resource path: ", path, "does not exist.")
    inp <- readline(paste("May I create the directory: ", path,
                          "to cache WHO ICD data? (Y/N): "))

    if (startsWith(tolower(inp), "y")) {
      dir.create(path)
    } else {
      path <- tempdir()
      if (verbose)
        message("Cannot get user confirmation. Using temporary directory:\n",
                path)
    }
  }
  options("icd.data.resource" = path)
  path
}

.icd10who2016_in_env <- function() {
  exists("icd10who2016", envir = .icd_data_env)
}

.icd10who2008fr_in_env <- function() {
  exists("icd10who2008fr", envir = .icd_data_env)
}

.icd10who2016_clean_env <- function() {
  if (.icd10who2016_in_env())
    rm("icd10who2016", envir = .icd_data_env)
}

message_who <- function() {
  o <- getOption("icd.data_absent_action")
  if (!is.null(o) && o %nin% c("stop", "message"))
    message(
    "WHO ICD data must be downloaded by each user due to copyright
    concerns. This may be achieved by running either of the commands

    fetch_icd10who2016()
    fetch_icd10who2008_fr()

    The data has to be saved somewhere accessible. The
    location is given by:

    get_resource_path()

    which defaults to:

    file.path(Sys.getenv(\"HOME\"), \".icd.data\")

    See:
    get_resource_path(),
    set_resource_path(\"new/path/to/dir\")")
}

# see zzz.R
.icd10who2016_binding <- function(x) {
  if (!missing(x))
    stop("This binding is read-only. Use fetch_icd10who2016() to populate.")
  dat <- get_icd10who2016()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("WHO ICD-10 2016 not available.")
}

.icd10who2008fr_binding <- function(x) {
  if (!missing(x))
    stop("This binding is read-only. Use fetch_icd10who2008fr() to populate.")
  dat <- get_icd10who2008fr()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10 2008 France not available.",
                  "CIM-10 2008 n'est pas disponible")
}
