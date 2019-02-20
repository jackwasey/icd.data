#' @param offline single logical, if \code{TRUE} then don't pull the file from
#'   internet, only return path and file name if the file already exists in the
#'   raw data directory. This is helpful for testing without using the internet.
#'   Setting the option `icd.data.offline` will set this globally. For anyone
#'   with an unmetered internet connection, setting this to `TRUE` is a good
#'   idea, and the default. It may be set to `FALSE`, which is useful for
#'   automated testing when downloads are not desirable. N.b., most people do
#'   not need to download or parse any raw ICD data themselves, so really this
#'   is just for developers.
