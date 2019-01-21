#' convert to character vector without warning
#' @param x vector, typically numeric or a factor
#' @return character vector
#' @keywords internal
as_char_no_warn <- function(x) {
  if (is.character(x)) return(x)
  old <- options(warn = -1)
  on.exit(options(old))
  if (is.factor(x))
    return(levels(x)[x])
  as.character(x)
}

#' create environment from vector
#'
#' create an environment by inserting the value \code{val} with names taken from
#' \code{x}
#' @noRd
#' @keywords internal
vec_to_env_true <- function(x, val = TRUE,
                            env = new.env(hash = TRUE, parent = baseenv())) {
  lapply(x, function(y) env[[y]] <- val)
  env
}

#' in/match equivalent for two \code{Environment} arguments
#'
#' \code{x} and \code{table} are identical to match. Lookup is done based on
#' environment element names; contents are ignored.
#' @noRd
#' @keywords internal
"%eine%" <- function(x, table) {
  vapply(ls(name = x),
         function(y) !is.null(table[[y]]),
         FUN.VALUE = logical(1L),
         USE.NAMES = FALSE)
}

"%ine%" <- function(x, table) {
  !is.null(table[[x]])
}
