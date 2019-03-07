#' Functions to get the WHO ICD-10 2016 data
#'
#' This is likely to be not exported in the future, as it is designed for the
#' transition to icd.data version 1.1 . The user may use the active binding
#' `icd10who2016` as if it is a variable. In some situations, it may be
#' preferable to call this function. E.g., using the active binding when the
#' cache directory has not been populated may produce messages. Auto-complete in
#' Rstudio is unfortunately considered still to be interactive, so these
#' messages may appear prematurely.
#'
#' This may be needed (in addition to icd.data::icd10who2016 active binding),
#' because lazy data and apparently active bindings are not available until the
#' package is on the search path. This is difficult or impossible to do in a
#' CRAN compatible way in the 'icd' package, so this function is just for that
#' purpose, since we can check whether this function exists and call it without
#' using ::, whereas this is not possible with lazy data or active bindings?
#' @template verbose
#' @keywords datasets
.get_icd10who2016 <- function(verbose = FALSE) {
  .get_from_cache("icd10who2016")
}

#' @rdname get_icd10who2016
.get_icd10who2008fr <- function() {
  .get_from_cache("icd10who2008fr")
}

# returns the JSON data, or fails with NULL
.fetch_who_api <- function(resource,
                           ver = "icd10",
                           year = 2016,
                           lang = "en",
                           verbose = FALSE) {
  httr_get <- httr::GET
  if (requireNamespace("memoise", quietly = TRUE)) {
    httr_get <- memoise::memoise(
      httr::GET,
      cache = memoise::cache_filesystem(
        file.path(
          getOption("icd.data.resource",
            default = stop("Option icd.data.resource not set")
          ),
          "memoise"
        )
      )
    )
  }
  ver <- match.arg(ver)
  who_base <- "https://apps.who.int/classifications"
  json_url <- paste(who_base, ver, "browse", year, lang, resource, sep = "/")
  if (verbose) message("Getting WHO data with JSON: ", json_url)
  http_response <- httr_get(json_url)
  if (http_response$status_code >= 400) {
    warning("Unable to fetch resource: ", json_url)
    return()
  }
  json_data <- rawToChar(http_response$content)
  jsonlite::fromJSON(json_data)
}

#' Use WHO API to discover chapters
#'
#' Of note, the `WHO` package does not provide access to classifications, just
#' WHO summary data.
#' @keywords internal
#' @noRd
.fetch_who_api_chapter_names <- function(ver = "icd10",
                                         year = 2016,
                                         lang = "en", verbose = TRUE) {
  .fetch_who_api_children(
    ver = ver, year = year, lang = lang,
    verbose = verbose
  )[["label"]]
}

.fetch_who_api_children <- function(concept_id = NULL, ...) {
  if (is.null(concept_id)) {
    .fetch_who_api(resource = "JsonGetRootConcepts?useHtml=false", ...)
  } else {
    .fetch_who_api(
      resource = paste0(
        "JsonGetChildrenConcepts?ConceptId=",
        concept_id,
        "&useHtml=false"
      ), ...
    )
  }
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
#' @param ... further arguments passed to self recursively, or `.fetch_who_api`
#' @keywords internal
#' @noRd
.fetch_icd10_who <- function(
                             concept_id = NULL,
                             year = 2016,
                             lang = "en",
                             verbose = FALSE,
                             hier_code = character(),
                             hier_desc = character(),
                             debug = FALSE,
                             ...) {
  if (!requireNamespace("memoise", quietly = TRUE)) {
    message(
      "Consider installing 'memoise' from CRAN using:\n",
      'install.packages("memoise")\n',
      "This will allow the WHO data download to resume if interrupted."
    )
  }
  if (verbose) print(hier_code)
  new_rows <- data.frame(
    code = character(),
    leaf = logical(),
    desc = character(),
    three_digit = character(),
    major = character(),
    sub_sub_chapter = character(),
    sub_chapter = character(),
    chapter = character()
  )
  if (verbose) message(".fetch_who_api_tree with concept_id = ", concept_id)
  tree_json <- .fetch_who_api_children(
    concept_id = concept_id,
    year = year,
    lang = lang,
    verbose = verbose,
    ...
  )
  if (is.null(tree_json)) {
    warning(
      "Unable to get results for concept_id: ", concept_id,
      ". Returning NULL. Try re-running the command."
    )
    return()
  }
  if (verbose) message("hier level = ", length(hier_code))
  new_hier <- length(hier_code) + 1
  for (branch in seq_len(nrow(tree_json))) {
    # might be looping through chapters, sub-chapters, etc.
    child_code <- tree_json[branch, "ID"]
    child_desc <- tree_json[branch, "label"]
    is_leaf <- tree_json[branch, "isLeaf"]
    # for each level, if not defined by arguments, then assign next possible
    hier_code[new_hier] <- child_code
    hier_desc[new_hier] <- child_desc
    sub_sub_chapter <- NA
    hier_three_digit_idx <- which(nchar(hier_code) == 3 &
      !grepl("[XVI-]", hier_code))
    if (length(hier_code) >= 3 && nchar(hier_code[3]) > 3) {
      sub_sub_chapter <- hier_desc[3]
    }
    this_child_up_hier <- grepl("[XVI-]", child_code)
    three_digit <- hier_code[hier_three_digit_idx]
    major <- hier_desc[hier_three_digit_idx]
    if (!this_child_up_hier && !is.na(three_digit)) {
      # TODO: consider add the chapter, subchapter codes
      new_item <- data.frame(
        code = child_code,
        leaf = is_leaf,
        desc = child_desc,
        three_digit = three_digit,
        major = major,
        sub_sub_chapter = sub_sub_chapter,
        sub_chapter = hier_desc[2],
        chapter = hier_desc[1],
        stringsAsFactors = FALSE
      )
      if (debug && child_code %in% new_rows$code) browser()
      new_rows <- rbind(new_rows, new_item)
    }
    if (!is_leaf) {
      if (verbose) message("Not a leaf, so recursing")
      recursed_rows <- .fetch_icd10_who(
        concept_id = child_code,
        year = year,
        lang = lang,
        verbose = verbose,
        hier_code = hier_code,
        hier_desc = hier_desc,
        ...
      ) # recurse
      if (debug && any(recursed_rows$code %in% new_rows$code)) browser()
      new_rows <- rbind(new_rows, recursed_rows)
    } # not leaf
  } # for
  if (verbose) {
    message(
      "leaving recursion with nrow(new_rows) = ",
      nrow(new_rows)
    )
  }
  new_rows
}

downloading_message <- function() {
  message("Downloading WHO ICD data. This will take a few minutes.
          Data is cached, so if there is a download error, re-running
          the command will pick up where it left off.")
}

#' Fetch the WHO data from online source
#'
#' This will download the latest ICD-10 codes and descriptions from the WHO, and
#' save the results in a directory given by `icd.data:::get_resource_dir()`.
#' This defaults to a subdirectory `.icd.data` of the home directory. This is
#' necessary because it is not permitted to write data back to the installed
#' package location (and this may not be allowed on a multi-user system,
#' anyway).
#' @param save_data Logical, defaults to `TRUE`
#' @param ... Arguments passed to internal functions
fetch_icd10who2016 <- function(save_data = TRUE, ...) {
  downloading_message()
  icd10who2016 <- .fetch_icd10_who(year = "2016", lang = "en", ...)
  rownames(icd10who2016) <- NULL
  icd10who2016$code <-
    sub(pattern = "\\.", replacement = "", x = icd10who2016$code)
  for (col_name in c(
    "chapter",
    "sub_chapter",
    "sub_sub_chapter",
    "major",
    "desc"
  ))
    icd10who2016[[col_name]] <- sub("[^ ]+ ", "", icd10who2016[[col_name]])
  if (save_data) .save_in_resource_dir(icd10who2016)
  invisible(icd10who2016)
}

#' @rdname fetch_icd10who2016
fetch_icd10who2008_fr <- function(save_data = FALSE, ...) {
  downloading_message()
  icd10who2008fr <- .fetch_icd10_who(year = "2008", lang = "fr", ...)
  rownames(icd10who2008fr) <- NULL
  icd10who2008fr$code <-
    sub(pattern = "\\.", replacement = "", x = icd10who2008fr$code)
  for (col_name in c(
    "chapter",
    "sub_chapter",
    "sub_sub_chapter",
    "major",
    "desc"
  ))
    icd10who2008fr[[col_name]] <- sub("[^ ]+ ", "", icd10who2008fr[[col_name]])
  if (save_data) if (save_data) .save_in_resource_dir(icd10who2008fr)
  invisible(icd10who2008fr)
}
