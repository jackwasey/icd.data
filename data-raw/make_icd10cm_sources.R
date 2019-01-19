#' Generate list of data source information for ICD-10-CM diagnosis and
#' procedure codes
#'
#' @seealso \url{https://www.cms.gov/Medicare/Coding/ICD10/}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2018-ICD-10-PCS-Tables-And-Index.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2018-ICD-10-PCS-Order-File.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2017-PCS-Code-Tables.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2017-PCS-Long-Abbrev-Titles.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2016-Code-Descriptions-in-Tabular-Order.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2015-code-descriptions.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2015-tables-index.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2015-Code_Tables-and-Index.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2015-PCS-long-and-abbreviated-titles.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2014-ICD10-Code-Descriptions.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2014-ICD10-Code-Tables-and-Index.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2014-Code-Tables-and-Index.zip}
#' \url{https://www.cms.gov/Medicare/Coding/ICD10/Downloads/2014-PCS-long-and-abbreviated-titles.zip}
#' @keywords internal
make_icd_sources <- function(do_save = TRUE) {
  base_url <- "https://www.cms.gov/Medicare/Coding/ICD10/Downloads/"
  icd10cm_sources <- list(
    "2018" = list(
      base_url = base_url,
      dx_zip = "2018-ICD-10-Code-Descriptions.zip",
      dx_xml_zip = "2018-ICD-10-Code-Tables-Index.zip",
      dx_flat = "icd10cm_codes_2018.txt",
      pcs_zip = "2018-ICD-10-PCS-Order-File.zip",
      pcs_xml_zip = "2018-ICD-10-PCS-Tables-And-Index.zip",
      pcs_flat = "icd10pcs_order_2018.txt"),
    "2017" = list(
      base_url = base_url,
      dx_zip = "2017-ICD10-Code-Descriptions.zip",
      pcs_zip = "2017-PCS-Long-Abbrev-Titles.zip",
      pcs_xml_zip = "2017-PCS-Code-Tables.zip",
      dx_xml_zip = "2017-ICD10-Code-Tables-Index.zip",
      dx_flat = "icd10cm_codes_2017.txt",
      pcs_flat = "icd10pcs_order_2017.txt"),
    "2016" = list(
      base_url = base_url,
      dx_zip = "2016-Code-Descriptions-in-Tabular-Order.zip",
      dx_xml_zip = "2016-ICD10-Code-Tables-Index.zip",
      dx_flat = "icd10cm_codes_2016.txt",
      pcs_zip = "2016-PCS-Long-Abbrev-Titles.zip",
      pcs_xml_zip = "2016-PCS-Code-Tables.zip",
      pcs_flat = "icd10pcs_order_2016.txt"),
    "2015" = list(
      base_url = base_url,
      dx_zip = "2015-code-descriptions.zip",
      dx_xml_zip = "2015-tables-index.zip",
      dx_flat = "icd10cm_order_2015.txt",
      pcs_zip = "2015-PCS-long-and-abbreviated-titles.zip",
      pcs_xml_zip = "2015-Code_Tables-and-Index.zip",
      pcs_flat = "icd10pcs_order_2015.txt"),
    "2014" = list(
      base_url = base_url,
      dx_zip = "2014-ICD10-Code-Descriptions.zip",
      dx_xml_zip = "2014-ICD10-Code-Tables-and-Index.zip",
      dx_flat = "icd10cm_order_2014.txt",
      pcs_zip = "2014-PCS-long-and-abbreviated-titles.zip",
      pcs_xml_zip = "2014-Code-Tables-and-Index.zip",
      pcs_flat = "icd10pcs_order_2014.txt")
  )
  if (do_save)
    save(icd10cm_sources, file = file.path("data", "icd10cm_sources"))
  invisible(icd10cm_sources)
}

make_icd_sources(do_save = TRUE)
