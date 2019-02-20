# nocov start
utils::globalVariables(c("icd10cm2019",
                         "icd10cm_sources",
                         "icd10_chapters",
                         "icd10_sub_chapters"))
#' get all ICD-10-CM codes
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
icd10cm_parse_all_defined <- function(
  save_data = FALSE,
  offline = getOption("icd.data.offline")
) {
  out <- lapply(
    names(icd10cm_sources),
    icd10cm_parse_all_defined_year,
    save_data = save_data,
    offline = offline)
  names(out) <- names(icd10cm_sources)
  invisible(out)
}

icd10cm_parse_all_defined_year <- function(
  year = 2019,
  save_data = FALSE,
  ...
) {
  stopifnot(is.numeric(year) || is.character(year))
  stopifnot(is.logical(save_data) && length(save_data) == 1L)
  stopifnot(as.character(year) %in% names(icd10cm_sources))
  f_info <- icd10cm_get_flat_file(year = year, ...)
  stopifnot(!is.null(f_info))
  # readLines may muck up encoding, resulting in weird factor order generation
  # later?
  x <- readLines(con = f_info$file_path, encoding = "ASCII")
  stopifnot(all(Encoding(x) == "unknown"))
  # Beware: stringr::str_trim may do some encoding tricks which result in
  # different factor order on different platforms. Seems to affect "major" which
  # comes from "short_desc"
  dat <- data.frame(
    #id = substr(x, 1, 5),
    code = trimws(substr(x, 7, 13)),
    billable = trimws(substr(x, 14, 15)) == "1",
    short_desc = trimws(substr(x, 16, 76)),
    long_desc = trimws(substr(x, 77, stop = 1e5)),
    stringsAsFactors = FALSE
  )
  dat[["code"]] <-
    icd::as.short_diag(
      icd::as.icd10cm(dat[["code"]]))
  dat[["three_digit"]] <- factor(get_icd10_major(dat[["code"]]))
  # here we must re-factor so we don't have un-used levels in major
  dat[["major"]] <- factor(
    merge(x = dat["three_digit"],
          y = dat[c("code", "short_desc")],
          by.x = "three_digit", by.y = "code",
          all.x = TRUE)[["short_desc"]]
  )
  dat[["major"]] <- icd::as.short_diag(icd::as.icd10cm(dat[["major"]]))
  sc_lookup <- icd10_generate_subchap_lookup(year = year)
  mismatch_sub_chap <- dat$three_digit[which(dat$three_digit %nin% sc_lookup$sc_major)]
  stopifnot(
    length(
      mismatch_sub_chap
    ) == 0L
  )
  dat[["sub_chapter"]] <-
    merge(x = dat["three_digit"], y = sc_lookup,
          by.x = "three_digit", by.y = "sc_major", all.x = TRUE)[["sc_desc"]]
  chap_lookup <- icd10_generate_chap_lookup(year = year)
  dat[["chapter"]] <-
    merge(dat["three_digit"], chap_lookup,
          by.x = "three_digit", by.y = "chap_major",
          all.x = TRUE)[["chap_desc"]]
  dat <- dat[get_icd34fun("order.icd10cm")(dat$code), ]
  class(dat$code) <- c("icd10cm", "icd10", "character")
  assign(paste0("icd10cm", year), value = dat)
  if (save_data)
    save_in_data_dir(paste0("icd10cm", year))
  invisible(dat)
}

icd10_generate_subchap_lookup <- function(year) {
  icd10_generate_chap_lookup(
    year = year,
    chapters = icd.data::icd10_sub_chapters,
    prefix = "sc"
  )
}

icd10_generate_chap_lookup <- function(
  year,
  chapters = icd.data::icd10_chapters,
  prefix = "chap"
) {
  stopifnot(is.list(chapters), is.character(prefix))
  df_rows <- lapply(
    names(chapters),
    function(nm) {
      chap <- chapters[[nm]]
      out <- data.frame(
        # expand undefined to avoid circular dependency on the ICD-10-CM data we
        # are making now.
        icd::expand_range_major(
          icd::as.icd10cm(chap["start"]),
          icd::as.icd10cm(chap["end"]),
          defined = FALSE),
        nm)
      # ICD-10 is not in leixcographic order. C7A is not in the same group as C76-C80
    }
  )
  chap_lookup <- do.call(rbind, df_rows)
  names(chap_lookup) <- c(paste0(prefix, "_major"),
                          paste0(prefix, "_desc"))
  chap_lookup
}
# nocov end
