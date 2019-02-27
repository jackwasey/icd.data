#nocov start

#' Unzip file to raw data directory
#'
#' Get a zip file from a URL, extract contents, and save file in the raw data
#' directory. If the file already exists there, it is only retrieved if
#' \code{force} is set to \code{TRUE}. If \code{offline} is \code{FALSE}, then
#' \code{NULL} is returned if the file isn't already downloaded.
#'
#' The file name is changed to a conservative cross platform name using
#' \code{make.names}
#'
#' @param url URL of a zip file
#' @param file_name file name of a single file in that zip
#' @param force logical, if TRUE, then download even if already in the raw data
#'   directory
#' @template verbose
#' @template offline
#' @param data_raw_path path where the raw directory is
#' @param save_name file name to save as, default is \code{file_name}
#' @param ... additional arguments passed to \code{utils::download.file}
#' @return path of unzipped file in the raw data directory
#' @keywords internal
unzip_to_data_raw <- function(
  url,
  file_name,
  force = FALSE,
  verbose = FALSE,
  offline = getOption("icd.data.offline"),
  data_raw_path = get_raw_data_dir(),
  save_name = file_name,
  ...
) {
  stopifnot(is.character(url), length(url) == 1)
  stopifnot(is.character(file_name), length(file_name) == 1)
  stopifnot(is.logical(force), length(force) == 1)
  stopifnot(is.logical(verbose), length(verbose) == 1)
  stopifnot(is.logical(offline), length(offline) == 1)
  if (verbose) message(url)
  if (!dir.exists(data_raw_path)) {
    if (verbose) message("Setting download path to a new temporary directory")
      data_raw_path <- tempdir()
  }
  file_path <- file.path(data_raw_path, make.names(save_name))
  if (verbose) sprintf("file path = %s\nfile name = %s\nsave name = %s",
                       file_path, file_name, save_name)
  if (force || !file.exists(file_path)) {
    if (offline) return()
    stopifnot(
      unzip_single(url = url,
                   file_name = file_name,
                   save_path = file_path,
                   ...)
    )
  }
  list(file_path = file_path, save_name = make.names(save_name))
}

#' @rdname unzip_to_data_raw
#' @keywords internal
download_to_data_raw <- function(
  url,
  file_name = regmatches(url, regexpr("[^/]*$", url)),
  offline = getOption("icd.data.offline"),
  data_raw_path = get_raw_data_dir(),
  ...
) {
  stopifnot(is.character(url), length(url) == 1)
  stopifnot(is.character(file_name), length(file_name) == 1)
  stopifnot(is.logical(offline), length(offline) == 1)
  if (!dir.exists(data_raw_path)) data_raw_path <- tempdir()
  save_path <- file.path(data_raw_path,
                         file_name)
  f_info <- list(file_path = save_path,
                 file_name = file_name)
  if (file.exists(save_path)) return(f_info)
  if (offline) return()
  curl_res <- try(
    utils::download.file(url = url,
                         destfile = save_path,
                         quiet = TRUE,
                         method = "curl",
                         extras = "--insecure --silent",
                         ...)
  )
  if (curl_res != 0) {
    # Windows, maybe some users, do no have curl, maybe not even libcurl. Cannot
    # set libcurl to avoid certificate verification without using RCurl, and I
    # want to avoid another dependency.
    curl_res <- utils::download.file(url = url,
                                     destfile = save_path,
                                     quiet = TRUE,
                                     ...)
  }
  if (curl_res != 0) stop(paste(url, " not downloaded successfully."))
  f_info
}
#nocov end
