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

# alt version to replace 'icd' version which uses C++
get_icd9_major <- function(y) {
  if (startsWith(y, "E")) {
    substr(trimws(y), 1L, 4L)
  } else {
    substr(trimws(y), 1L, 3L)
  }
}

get_icd10_major <- function(x) {
  substr(trimws(x), 1L, 3L)
}

#' swap names and values of a vector
#'
#' Swap names and values of a vector. Non-character values are implicitly
#' converted to names.
#' @param x named vector
#' @return vector, with values being the names of the input vector, and names
#' being the previous values.
#' @noRd
#' @keywords internal
swap_names_vals <- function(x) {
  stopifnot(is.atomic(x))
  stopifnot(!is.null(names(x)))
  new_names <- unname(x)
  x <- names(x)
  names(x) <- new_names
  x
}

#' mimic the \code{R CMD check} test
#'
#' \code{R CMD check} is quick to tell you where \code{UTF-8} characters are not
#' encoded, but gives no way of finding out which or where
#' @examples
#' \dontrun{
#' sapply(icd9cm_hierarchy, get_non_ascii)
#' get_encodings(icd9cm_hierarchy)
#' sapply(icd9cm_billable, get_non_ascii)
#' sapply(icd9cm_billable, get_encodings)
#' }
#' @noRd
#' @keywords internal
get_non_ascii <- function(x)
  x[is_non_ascii(as_char_no_warn(x))]

#' @rdname get_non_ascii
#' @noRd
#' @keywords internal
is_non_ascii <- function(x)
  is.na(iconv(as_char_no_warn(x), from = "latin1", to = "ASCII"))

#' @rdname get_non_ascii
#' @noRd
#' @keywords internal
get_encodings <- function(x) {
  vapply(x, FUN = function(y) unique(Encoding(as_char_no_warn(y))),
         FUN.VALUE = character(1))
}

#' Parse a (sub)chapter text description with parenthesised range
#'
#' @param x vector of descriptions followed by ICD code ranges
#' @return list of two-element character vectors, the elements being named
#'   'start' and 'end'.
#' @noRd
#' @keywords internal manip
.chapter_to_desc_range <- function(x, re_major) {
  stopifnot(is.character(x), is.character(re_major))
  re_code_range <- paste0("(.*)[[:space:]]?\\((",
                          re_major, ")-(",
                          re_major, ")\\)"
  )
  re_code_single <- paste0("(.*)[[:space:]]?\\((", re_major, ")\\)")
  mr <- str_match_all(x, re_code_range)
  ms <- str_match_all(x, re_code_single)
  okr <- vapply(mr, length, integer(1)) == 4L
  oks <- vapply(ms, length, integer(1)) == 3L
  if (!all(okr || oks))
    stop("Problem matching\n", x[!(okr || oks)], call. = FALSE)
  m <- ifelse(okr, mr, ms)
  out <- lapply(m, function(y) c(start = y[[3]], end = y[[length(y)]]))
  names(out) <- vapply(m, function(y) trimws(to_title_case(y[[2]])),
                       FUN.VALUE = character(1))
  out
}

chapter_to_desc_range.icd9 <- function(x) { #nolint
  .chapter_to_desc_range(x, re_major = re_icd9_major_bare)
}

chapter_to_desc_range.icd10 <- function(x) { #nolint
  .chapter_to_desc_range(x, re_major = re_icd10_major_bare)
}

get_chapter_ranges_from_flat <- function(
  flat_hier = icd10cm2019,
  field = "chapter"
) {
  u <- if (is.factor(flat_hier[[field]]))
    levels(flat_hier[[field]])
  else
    as.character(unique(flat_hier[[field]]))
  three_digits <- as.character(flat_hier[["three_digit"]])
  lapply(
    setNames(u, u),
    function(chap) {
      td <- sort(
        unique(three_digits[flat_hier[[field]] == chap])
      )
      c(
        start = td[1],
        end = td[length(td)]
      )
    })
}

#' Use the WHO ICD-10 French 'hierarchy' flat file to infer chapter ranges
#'
#' These are UTF-8 encoded. If there are no UTF-8 characters, it seems that R
#' forces the 'unknown' encoding label. This could be scraped from the web site
#' directly, which is what \code{.fetch_who_api_chapters()} does, but this is
#' at least as good.
#' @keywords internal
get_chapters_fr <- function(save_data = FALSE) {
  icd10_chapters_fr <- get_chapter_ranges_from_flat(
    flat_hier = icd10who2008fr,
    field = "chapter")
  save_in_data_dir(icd10_chapters_fr)
  invisible(icd10_chapters_fr)
}

#' @rdname get_chapters_fr
#' @keywords internal
get_sub_chapters_fr <- function(save_data = FALSE) {
  icd10_sub_chapters_fr <- get_chapter_ranges_from_flat(
    flat_hier = icd10who2008fr,
    field = "sub_chapter")
  save_in_data_dir(icd10_sub_chapters_fr)
  invisible(icd10_sub_chapters_fr)
}

to_title_case <- function(x) {
  for (split_char in c(" ", "-", "[")) {
    s <- strsplit(x, split_char, fixed = TRUE)[[1]]
    x <- paste(toupper(substring(s, 1L, 1L)), substring(s, 2L),
               sep = "", collapse = split_char)
  }
  x
}

# two functions are not exported in icd < 3.4
get_icd34fun <- function(f) {
  if (exists(f, where = asNamespace("icd"), mode = "function"))
    get(f, envir = asNamespace("icd"), mode = "function")
  else
    stop("Function ", f, " is not exported with icd < 3.4")
}

exists_in_ns <- function(name) {
  name %in% names(asNamespace("icd.data")[[".__NAMESPACE__."]][["lazydata"]])
}
