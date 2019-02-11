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
  offline = TRUE
) {
  out <- lapply(
    names(icd10cm_sources),
    icd10cm_parse_all_defined_year,
    save_data = save_data,
    offline = offline)
  names(out) <- names(icd10cm_sources)
  out
}

icd10cm_parse_all_defined_year <- function(
  year = 2019,
  save_data = FALSE,
  offline = TRUE
) {
  stopifnot(is.numeric(year) || is.character(year))
  stopifnot(is.logical(save_data), is.logical(offline))
  stopifnot(as.character(year) %in% names(icd10cm_sources))
  f_info <- icd10cm_get_flat_file(year = year, offline = offline)
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
  dat[["three_digit"]] <-
    factor(get_icd10_major(dat[["code"]]))
  # here we must re-factor so we don't have un-used levels in major
  dat[["major"]] <- factor(
    merge(x = dat["three_digit"],
          y = dat[c("code", "short_desc")],
          by.x = "three_digit", by.y = "code",
          all.x = TRUE)[["short_desc"]]
  )
  # can't use expand_range_major here for ICD-10-CM, because it would use
  # the output of this function (and it can't just do numeric ranges because
  # there are some non-numeric characters scattered around)
  sc_lookup <- icd10_generate_subchap_lookup()
  dat[["sub_chapter"]] <-
    merge(x = dat["three_digit"], y = sc_lookup,
          by.x = "three_digit", by.y = "sc_major", all.x = TRUE)[["sc_desc"]]
  chap_lookup <- icd10_generate_chap_lookup()
  dat[["chapter"]] <-
    merge(dat["three_digit"], chap_lookup,
          by.x = "three_digit", by.y = "chap_major",
          all.x = TRUE)[["chap_desc"]]
  assign(paste0("icd10cm", year), value = dat)
  if (save_data)
    save_in_data_dir(paste0("icd10cm", year))
  invisible(dat)
}

icd10_generate_subchap_lookup <- function() {
  icd10_generate_chap_lookup(
    chapters = icd.data::icd10_sub_chapters,
    prefix = "sc"
  )
}

icd10_generate_chap_lookup <- function(
  chapters = icd.data::icd10_chapters,
  prefix = "chap"
) {
  lk_majors <- unique(icd10cm_latest[["three_digit"]])
  df_rows <- lapply(
    names(chapters),
    function(nm) {
      chap <- chapters[[nm]]
      si <- grep(chap["start"], lk_majors)
      se <- grep(chap["end"], lk_majors)
      data.frame(lk_majors[si:se], nm)
    }
  )
  chap_lookup <- do.call(rbind, df_rows)
  names(chap_lookup) <- c(paste0(prefix, "_major"),
                          paste0(prefix, "_desc"))
  chap_lookup
}

# duplicated with same function in 'icd'
icd10_parse_ahrq_pcs <- function(save_data = TRUE) {
  f <- unzip_to_data_raw(
    url = paste0("https://www.hcup-us.ahrq.gov/toolssoftware/",
                 "procedureicd10/pc_icd10pcs_2018_1.zip"),
    file_name = "pc_icd10pcs_2018.csv", offline = !save_data)
  dat <- read.csv(file = f$file_path, skip = 1, stringsAsFactors = FALSE,
                  colClasses = "character", encoding = "latin1")
  names(dat) <- c("code", "desc", "class_number", "class")
  dat$class <- factor(dat$class,
                      levels = c("Minor Diagnostic", "Minor Therapeutic",
                                 "Major Diagnostic", "Major Therapeutic"))
  dat$class_number <- NULL
  dat$code <- gsub(dat$code, pattern = "'", replacement = "")
  icd10_pcs <- list("2018" = dat[c("code", "desc")])
  if (save_data)
    save_in_data_dir(icd10_pcs)
}

icd10_parse_cms_pcs_all <- function(save_data = TRUE) {
  for (year in names(icd10cm_sources)) {
    var_name <- paste0("icd10_pcs_", year)
    assign(var_name, icd10_parse_cms_pcs_year(year))
    save_in_data_dir(var_name)
  }
}

icd10_parse_cms_pcs_year <- function(year = "2018") {
  pcs_file <- icd10cm_sources[[year]][["pcs_flat"]]
  pcs_path <- file.path(get_raw_data_dir(), pcs_file)
  read.fwf(pcs_path, c(5, 8, 2, 62, 120), header = FALSE,
           col.names = c("count", "pcs", "billable", "short_desc", "long_desc"))
}
# nocov end
