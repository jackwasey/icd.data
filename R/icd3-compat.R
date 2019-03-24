.icd10cm_get_majors_possible <- function(s, e) {
  ss <- substr(s, 1L, 1L)
  es <- substr(e, 1L, 1L)
  lets <- LETTERS[which(LETTERS == ss):which(LETTERS == es)]
  o <- sort(
    icd::as.icd10cm(
      apply(
        expand.grid(lets, 0:9, c(0:9, "A", "B")),
        MARGIN = 1,
        FUN = paste0,
        collapse = ""
      )
    )
  )
  stopifnot(all(c(s, e) %in% o))
  o[seq.int(
    from = which(o == s),
    to = which(o == e)
  )]
}

.expand_range_major.icd10cm <- function(start, end, defined = TRUE) {
  # codes may have alphabetic characters in 3rd position, so can't just do
  # numeric. This may make ICD-10-CM different from ICD-10 WHO. It also makes
  # generating the lookup table of ICD-10-CM codes potentially circular, since
  # we expand the start to end range of chapter and sub-chapter definitions.
  se <- toupper(trimws(as.character(c(start, end))))
  unique_mjrs <- if (defined) {
    unique(icd10cm2016$three_digit)
  } else {
    .icd10cm_get_majors_possible("A00", "Z99")
  }
  pos <- match(se, unique_mjrs)
  if (is.na(pos[[1]])) {
    stop(se[[1]], " as start not found")
  }
  if (is.na(pos[[2]])) {
    stop(se[[2]], " as end not found")
  }
  icd::as.icd10cm(as.character(unique_mjrs[pos[[1]]:pos[[2]]]))
}

.expand_range_major.icd9 <- function(start, end, defined = TRUE) {
  c <- icd9_extract_alpha_numeric(start)
  d <- icd9_extract_alpha_numeric(end)
  # cannot range between numeric, V and E codes, so ensure same type.
  stopifnot(toupper(c[1]) == toupper(d[1]))
  fmt <- if (startsWith(start, "V")) "%02d" else "%03d"
  majors <- icd::as.icd9(paste(c[, 1], sprintf(fmt = fmt, c[, 2]:d[, 2]), sep = ""))
  if (defined) {
    icd::get_defined(majors, short_code = TRUE, billable = FALSE)
  } else {
    majors
  }
}

order.icd10cm <- function(x) {
  icd10cm_order_rcpp(x)
}

order.icd10be <- function(x) {
  order.icd10cm(x)
}

icd9_extract_alpha_numeric <- function(x) {
  t(
    vapply(
      str_match_all(.as_char_no_warn(x),
        pattern = "([VvEe]?)([[:digit:].]+)"
      ),
      FUN = function(y) matrix(data = y[2:3], nrow = 1, ncol = 2),
      FUN.VALUE = c(NA_character_, NA_character_)
    )
  )
}

str_match_all <- function(string, pattern, ...) {
  string <- as.character(string)
  regmatches(x = string, m = regexec(pattern = pattern, text = string, ...))
}

order.icd9 <- function(x) {
  if (anyNA(x)) {
    warning("Dropping NA values")
    x <- x[!is.na(x)]
    if (length(x) == 0) return(integer())
  }
  icd9_order_rcpp(x)
}
