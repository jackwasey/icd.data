#' Get all ICD-10-CM codes
#'
#' Gets all ICD-10-CM codes from an archive on the CDC web site.
#'
#' The factor generation uses \code{sort.default} which is locale dependent.
#' This meant a lot of time debugging a problem when white space was ignored for
#' sorting on some platforms, but not others.
#' @source \url{https://www.cms.gov/Medicare/Coding/ICD10} also available from
#'   \url{http://www.cdc.gov/nchs/data/icd/icd10cm/2016/ICD10CM_FY2016_code_descriptions.zip}.
#' @references
#'   \href{https://www.cms.gov/Medicare/Coding/ICD10/downloads/icd-10quickrefer.pdf}{CMS ICD-10 Quick Reference}
#'   \href{https://www.cdc.gov/nchs/icd/icd10cm.htm#FY\%202019\%20release\%20of\%20ICD-10-CM}{CDC copy of ICD-10-CM for 2019}
#' @keywords internal
.icd10cm_parse_all <- function(save_data = FALSE,
                               offline = getOption("icd.data.offline"),
                               verbose = TRUE,
                               twentysixteen = FALSE,
                               ...) {
  if (verbose) message("Parsing all ICD-10-CM diagnostic codes.")
  yrs <- names(icd10cm_sources)
  yrs <- if (twentysixteen) {
    "2016"
  } else {
    yrs[yrs %nin% "2016"]
  }
  out <- lapply(
    yrs,
    .icd10cm_parse_year,
    save_data = save_data,
    offline = offline,
    verbose = verbose,
    ...
  )
  names(out) <- yrs
  invisible(out)
}

.icd10cm_parse_year <- function(year = 2019,
                                save_data = TRUE,
                                verbose = TRUE,
                                ...) {
  message("Please wait a few moments to parse data...")
  stopifnot(is.numeric(year) || is.character(year))
  year <- as.character(year)
  stopifnot(is.logical(save_data) && length(save_data) == 1L)
  stopifnot(is.logical(verbose) && length(verbose) == 1L)
  stopifnot(as.character(year) %in% names(icd10cm_sources))
  if (verbose) message("Getting flat file for year: ", year)
  f_info <- .icd10cm_get_flat_file(year = year, verbose = verbose, ...)
  stopifnot(!is.null(f_info))
  # readLines may muck up encoding, resulting in weird factor order generation
  # later?
  x <- readLines(con = f_info$file_path, encoding = "ASCII")
  if (verbose) message("Got flat file for year: ", year)
  stopifnot(all(Encoding(x) == "unknown"))
  # Beware: stringr::str_trim may do some encoding tricks which result in
  # different factor order on different platforms. Seems to affect "major" which
  # comes from "short_desc"
  dat <- data.frame(
    # id = substr(x, 1, 5),
    code = trimws(substr(x, 7, 13)),
    billable = trimws(substr(x, 14, 15)) == "1",
    short_desc = trimws(substr(x, 16, 76)),
    long_desc = trimws(substr(x, 77, stop = 1e5)),
    stringsAsFactors = FALSE
  )
  dat[["code"]] <-
    icd::as.short_diag(
      icd::as.icd10cm(dat[["code"]])
    )
  dat[["three_digit"]] <- factor(.get_icd10_major(dat[["code"]]))
  # here we must re-factor so we don't have un-used levels in major
  dat[["major"]] <- factor(
    merge(
      x = dat["three_digit"],
      y = dat[c("code", "short_desc")],
      by.x = "three_digit", by.y = "code",
      all.x = TRUE
    )[["short_desc"]]
  )
  dat[["major"]] <- icd::as.short_diag(icd::as.icd10cm(dat[["major"]]))
  if (verbose) message("Generating sub-chapter lookup for year: ", year)
  sc_lookup <- .icd10_generate_subchap_lookup(year = year, verbose = verbose)
  mismatch_sub_chap <-
    dat$three_digit[which(dat$three_digit %nin% sc_lookup$sc_major)]
  stopifnot(
    length(
      mismatch_sub_chap
    ) == 0L
  )
  dat[["sub_chapter"]] <-
    merge(
      x = dat["three_digit"],
      y = sc_lookup,
      by.x = "three_digit",
      by.y = "sc_major",
      all.x = TRUE
    )[["sc_desc"]]
  if (verbose) message("Generating chap lookup for year: ", year)
  chap_lookup <- .icd10_generate_chap_lookup(year = year, verbose = verbose)
  dat[["chapter"]] <-
    merge(dat["three_digit"], chap_lookup,
          by.x = "three_digit", by.y = "chap_major",
          all.x = TRUE
    )[["chap_desc"]]
  dat <- dat[.get_icd34fun("order.icd10cm")(dat$code), ]
  class(dat$code) <- c("icd10cm", "icd10", "character")
  row.names(dat) <- NULL
  assign(paste0("icd10cm", year), value = dat)
  if (save_data) {
    .save_in_resource_dir(paste0("icd10cm", year))
    if (year == "2016") .save_in_data_dir("icd10cm2016")
  }
  invisible(dat)
}

.icd10_generate_subchap_lookup <- function(year, verbose = FALSE) {
  .icd10_generate_chap_lookup(
    year = year,
    chapters = icd.data::icd10_sub_chapters,
    prefix = "sc",
    verbose = verbose
  )
}

.icd10_generate_chap_lookup <- function(year,
                                        chapters = icd.data::icd10_chapters,
                                        prefix = "chap",
                                        verbose = FALSE) {
  stopifnot(is.list(chapters), is.character(prefix))
  erm <- if (.have_memoise())
    memoise::memoise(
      icd.data:::.get_icd34fun("expand_range_major"),
      cache = memoise::cache_filesystem(
        file.path(get_resource_dir(), "memoise")))
  else
    icd.data:::.get_icd34fun("expand_range_major")
  df_rows <- lapply(
    names(chapters),
    function(nm) {
      chap <- chapters[[nm]]
      out <- data.frame(
        erm(
          icd::as.icd10cm(chap["start"]),
          icd::as.icd10cm(chap["end"]),
          defined = FALSE),
        nm
      )
      # ICD-10 is not in leixcographic order. E.g., C7A is not in the same group
      # as C76-C80
    }
  )
  chap_lookup <- do.call(rbind, df_rows)
  names(chap_lookup) <- c(
    paste0(prefix, "_major"),
    paste0(prefix, "_desc")
  )
  chap_lookup
}
