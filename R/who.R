fetch_who_api <- function(ver = c("icd10", "icd9"),
                          year = 2016,
                          lang = "en",
                          resource = "JsonGetRootConcepts?useHtml=false",
                          verbose = TRUE) {
  ver = match.arg(ver)
  who_base <- "https://apps.who.int/classifications"
  json_url <- paste(who_base, ver, "browse", year, lang, resource, sep = "/")
  if (verbose) message("Getting WHO data with JSON: ", json_url)
  json_data <- rawToChar(httr::GET(json_url)$content)
  jsonlite::fromJSON(json_data)
}

#' Use WHO API to discover chapters
#'
#' Of note, the `WHO` package does not provide access to classifications, just
#' WHO summary data.
#' @keywords internal
fetch_who_api_chapters <- function(ver = c("icd10", "icd9"),
                                   year = 2016,
                                   lang = "en", verbose = TRUE) {
  fetch_who_api(ver = ver, year = year, lang = lang,
                resource = "JsonGetRootConcepts?useHtml=false",
                verbose = verbose)[["label"]]
}

fetch_who_api_concept_children <- function(concept_id, ...) {
  fetch_who_api(resource = paste0("JsonGetChildrenConcepts?ConceptId=",
                                  concept_id,
                                  "&useHtml=false"), ...)
}

#' Use public interface to fetch ICD-10 WHO version
#'
#' The user may call this function to install the full WHO ICD-10 definition on
#' their machine, after which it will be available to `icd`. TODO: determine the
#' best place to save this data.
#' @param concept_id This is the id for the code or code group, e.g. "XI"
#'   (Chapter 6), "T90-T98" (A sub-chapter), "E01" (A sub-sub-chapter). You
#'   cannot query a single code with this interface.
#' @param year integer 4-digit year
#' @param lang Currently it seems only 'en' works
#' @param verbose logical
#' @param ... further arguments passed to self recursively, or `fetch_who_api`
#' @export
fetch_icd10_who <- function(concept_id = NULL,
                            year = 2016,
                            lang = "en",
                            verbose = TRUE, ...) {
  if (verbose) message("fetch_who_api_tree with concept_id = ", concept_id)
  tree_list <- list()
  tree_json <- if (is.null(concept_id))
    fetch_who_api(year = year, lang = lang, verbose = verbose, ...)
  else
    fetch_who_api_concept_children(concept_id = concept_id,
                                   year = year,
                                   lang = lang,
                                   verbose = verbose,
                                   ...)
  for (branch in seq_len(nrow(tree_json))) {
    child_id <- tree_json[branch, "ID"]
    tree_list[[child_id]] <-
      if (tree_json[branch, "isLeaf"]) {
        tree_json[branch, "label"]
      } else {
        fetch_icd10_who(child_id)
      }
  }
  tree_list
}
