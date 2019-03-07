
# duplicated with same function in 'icd', just saving the procedure codes here
.icd10_parse_ahrq_pcs <- function(save_data = TRUE) {
  .Defunct("Don't use this. Use icd10cm_parse_cms_pcs_all")
  # potentially useful for testing
  f <- .unzip_to_data_raw(
    url = paste0(
      "https://www.hcup-us.ahrq.gov/toolssoftware/",
      "procedureicd10/pc_icd10pcs_2018_1.zip"
    ),
    file_name = "pc_icd10pcs_2018.csv", offline = !save_data
  )
  dat <- read.csv(
    file = f$file_path, skip = 1, stringsAsFactors = FALSE,
    colClasses = "character", encoding = "latin1"
  )
  names(dat) <- c("code", "desc", "class_number", "class")
  dat$class <- factor(dat$class,
    levels = c(
      "Minor Diagnostic", "Minor Therapeutic",
      "Major Diagnostic", "Major Therapeutic"
    )
  )
  dat$class_number <- NULL
  dat$code <- gsub(dat$code, pattern = "'", replacement = "")
  icd10_pcs <- list("2018" = dat[c("code", "desc")])
  if (save_data) {
    .save_in_data_dir(icd10_pcs)
  }
}

.icd10cm_parse_cms_pcs_all <- function(save_data = FALSE, verbose = TRUE) {
  if (verbose) message("Parsing all ICD-10-CM procedure codes")
  lapply(names(icd10cm_sources),
    .icd10cm_parse_cms_pcs_year,
    save_data = save_data,
    verbose = verbose
  )
  invisible()
}

.icd10cm_parse_cms_pcs_year <- function(year,
                                        save_data = FALSE,
                                        verbose = TRUE) {
  message("Please wait a few moments to parse data...")
  year <- as.character(year)
  fp <- .fetch_icd10cm_ver(
    ver = year,
    dx = FALSE,
    verbose = verbose,
    offline = FALSE
  )
  if (verbose) print(fp)
  pcs_file <- icd10cm_sources[[year]][["pcs_flat"]]
  pcs_path <- file.path(
    get_resource_dir(),
    .get_versioned_raw_file_name(pcs_file, ver = year)
    )
  out <- read.fwf(pcs_path, c(5, 8, 2, 62, 120),
    header = FALSE,
    col.names = c(
      "count",
      "code",
      "leaf",
      "short_desc",
      "long_desc"
    )
  )
  out$count <- NULL
  out$code <- trimws(as.character(out$code))
  out$leaf <- as.logical(out$leaf)
  out$short_desc <- trimws(as.character(out$short_desc))
  out$long_desc <- trimws(as.character(out$long_desc))
  out <- out[order(out$code), ]
  var_name <- paste0("icd10cm", year, "_pc")
  if (save_data) {
    .assign(var_name, out)
    .save_in_resource_dir(var_name)
  }
  invisible(out)
}
