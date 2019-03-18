
.icd10_generate_subchap_lookup <- function(year, verbose = FALSE) {
  .icd10_generate_chap_lookup(
    year = year,
    chapters = icd10_sub_chapters,
    prefix = "sc",
    verbose = verbose
  )
}

.icd10_generate_chap_lookup <- function(year,
                                        chapters = icd10_chapters,
                                        prefix = "chap",
                                        verbose = FALSE) {
  stopifnot(is.list(chapters), is.character(prefix))
  erm <- if (.have_memoise()) {
    memoise::memoise(
      icd::expand_range_major,
      cache = memoise::cache_filesystem(
        file.path(icd_data_dir(), "memoise")
      )
    )
  } else {
    icd::expand_range_major
  }
  df_rows <- lapply(
    names(chapters),
    function(nm) {
      chap <- chapters[[nm]]
      data.frame(
        erm(
          icd::as.icd10cm(chap["start"]),
          icd::as.icd10cm(chap["end"]),
          defined = FALSE
        ),
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
