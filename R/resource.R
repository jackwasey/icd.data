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
  if (verbose) message("Trying to get from cache env or dir")
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

setup_resource_dir <- function(path = NULL, verbose = TRUE) {
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
  if (!interactive()) return(NULL)
  ok <- askYesNo(
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

set_resource_dir <- function(path) {
  if (!dir.exists(path)) {
    if (!dir.create(path)) stop("Could not create directory at: ", path)
  }
  options("icd.data.resource" = path)
  invisible(path)
}

get_resource_dir <- function() {
  o <- getOption("icd.data.resource")
  if (is.null(o)) {
    return((setup_resource_dir()))
  } # double bracket to show invisible
  if (!dir.exists(o)) {
    return((setup_resource_dir()))
  }
  o
}

.confirm_download <- function(must_work = TRUE) {
  if (isFALSE(getOption("icd.data.offline"))) {
    return(TRUE)
  }
  ok <- FALSE
  if (interactive()) {
    ok <- isTRUE(
      askYesNo(
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
