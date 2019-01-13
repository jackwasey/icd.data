who_base <- "http://apps.who.int/classifications/"

#' Use WHO API to discover chapters
#'
#' Of note, the `WHO` package does not provide access to classifications, just
#' WHO summary data.
#' @keywords internal
WHO_chapters <- function(ver = c("icd10", "icd9"),
                                  year = 2016,
                                  lang = "en") {
  ver = match.arg(ver)
  json_url <- paste(who_base, ver, "browse", year, lang,
                    "JsonGetRootConcepts?useHtml=false",
                    sep = "/")
  json_data <- rawToChar(httr::GET(json_url)$content)
  jsonlite::fromJSON(json_data)[["label"]]
}
