utils::globalVariables(".icd_data_env")
.default_path <- file.path(Sys.getenv("HOME"), ".icd.data")

#' Get or set the filesystem path used to save downloaded data
#'
#' Currently this applies only to WHO ICD-10 data, which is downloaded on demand.
#' The default path is given by `file.path(Sys.getenv("HOME"), ".icd.data")`
#' @export
get_resource_path <- function() {
  path <- getOption("icd.data.resource")
  if (!dir.exists(path))
    stop("icd.data resource path: ", path, " doesn't exist.",
         "Use set_who_resource_path() to initialize, or create it manually.")
  path
}

#' @rdname get_resource_path
#' @param path Path to a writable directory
#' @param verbose Logical
#' @export
set_resource_path <- function(path = .default_path, verbose = TRUE) {
  if (verbose) {
    message("Changing icd.data resource path from:")
    print(get_resource_path())
    message("to:")
    print(path)
  }
  options("icd.data.resource" = path)
  if (!dir.exists(path)) {
    if (verbose) message("icd.data.resource path: ", path,
                         "does not exist. Creating it now.")
    dir.create(path)
  }
}

.icd10who2016_in_env <- function() {
  exists("icd10who2016", envir = .icd_data_env)
}

.icd10who2016_clean_env <- function() {
  if (.icd10who2016_in_env())
    rm("icd10who2016", envir = .icd_data_env)
}

.get_local_icd10who2016 <- function() {
  icd10who2016_path <- file.path(get_resource_path(), "icd10who2016.rds")
  if (.icd10who2016_in_env())
    return(get("icd10who2016", envir = .icd_data_env))
  if (file.exists(icd10who2016_path)) {
    icd10who2016 <- readRDS(icd10who2016_path)
    assign("icd10who2016", icd10who2016, envir = .icd_data_env)
    return(icd10who2016)
  }
  NULL
}

# see zzz.R
.icd10who2016_binding <- function(x) {
  if (missing(x)) {
    dat <- .get_local_icd10who2016()
    if (!is.null(dat)) return(dat)
    if (interactive())
      message(
        "WHO ICD data must be downloaded by each user due to copyright ",
        "concerns. This may be achieved by running the command:\n\n",
        "fetch_icd10who2016()\n\n",
        "The data has to be saved somewhere accessible. The ",
        "location is given by:\n\n",
        "get_resource_path()\nwhich defaults to:\n\n",
        "file.path(Sys.getenv(\"HOME\"), \".icd.data\")\n\n",
        "set_resource_path(\"new/path/to/dir\") can be used to change this.")
  } else {
    stop("This binding should be read-only.",
         " Use fetch_icd10who2016() to populate.")
  }
}

# returns the JSON data, or fails with NULL
.fetch_who_api <- function(resource,
                           ver = "icd10",
                           year = 2016,
                           lang = "en",
                           verbose = FALSE) {
  httr_get <- memoise::memoise(
    httr::GET,
    cache = memoise::cache_filesystem(
      file.path(
        getOption("icd.data.resource", default = .default_path),
        "memoise")
    )
  )
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
  .fetch_who_api_concept_children(ver = ver, year = year, lang = lang,
                                  verbose = verbose)[["label"]]
}

.fetch_who_api_concept_children <- function(concept_id = NULL, ...) {
  if (is.null(concept_id))
    .fetch_who_api(resource = "JsonGetRootConcepts?useHtml=false", ...)
  else
    .fetch_who_api(
      resource = paste0("JsonGetChildrenConcepts?ConceptId=",
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
#' @param ... further arguments passed to self recursively, or `.fetch_who_api`
#' @keywords internal
#' @noRd
.fetch_icd10_who <- function(concept_id = NULL,
                             year = 2016,
                             lang = "en",
                             verbose = TRUE,
                             hier_code = character(),
                             hier_desc = character(),
                             ...) {
  if (verbose) print(hier_code)
  new_rows <- data.frame(code = character(),
                         leaf = logical(),
                         desc = character(),
                         three_digit = character(),
                         major = character(),
                         sub_sub_chapter = character(),
                         sub_chapter = character(),
                         chapter = character())
  if (verbose) message(".fetch_who_api_tree with concept_id = ", concept_id)
  tree_json <- .fetch_who_api_concept_children(concept_id = concept_id,
                                               year = year,
                                               lang = lang,
                                               verbose = verbose,
                                               ...)
  if (is.null(tree_json)) {
    warning("Unable to get results for concept_id: ", concept_id,
            ". Returning NULL. Try re-running the command.")
    return()
  }
  if (verbose) message("hier level = ", length(hier_code))
  for (branch in seq_len(nrow(tree_json))) {
    # might be looping through chapters, sub-chapters, etc.
    child_code <- tree_json[branch, "ID"]
    child_desc <- tree_json[branch, "label"]
    is_leaf <- tree_json[branch, "isLeaf"]
    # for each level, if not defined by arguments, then assign next possible
    hier_code[length(hier_code) + 1] <- child_code
    hier_desc[length(hier_desc) + 1] <- child_desc
    sub_sub_chapter <- NA
    if (length(hier_code) >= 3 && nchar(hier_code[3]) > 3)
      sub_sub_chapter <- hier_desc[3]
    three_digit <- hier_code[nchar(hier_code) == 3]
    major <- hier_desc[nchar(hier_code) == 3]
    is_hier <- grepl("[XVI-]", child_code)
    if (!is_hier) {
      new_rows <- rbind(
        new_rows,
        data.frame(code = child_code,
                   leaf = is_leaf,
                   desc = child_desc,
                   three_digit = three_digit,
                   major = major,
                   sub_sub_chapter = sub_sub_chapter,
                   sub_chapter = hier_desc[2],
                   chapter = hier_desc[1],
                   stringsAsFactors = FALSE
        )
        # TODO: consider add the chapter, subchapter codes
      )
    }
    if (!is_leaf) {
      if (verbose) message("Not a leaf, so recursing")
      new_rows <- rbind(
        new_rows,
        .fetch_icd10_who(concept_id = child_code,
                         year = year,
                         lang = lang,
                         verbose = verbose,
                         hier_code = hier_code,
                         hier_desc = hier_desc,
                         ...
        ) # recurse
      ) #rbind
    } # not leaf
  } # for
  if (verbose) message("leaving recursion@")
  new_rows
}

#' Fetch the WHO data from online source
#'
#' This will download the latest ICD-10 codes and descriptions from the WHO, and
#' save the results in a directory given by `icd.data:::get_resource_path()`.
#' This defaults to a subdirectory `.icd.data` of the home directory. This is
#' necessary because it is not permitted to write data back to the installed
#' package location (and this may not be allowed on a multi-user system,
#' anyway).
#' @param do_save Logical, defaults to `TRUE`
#' @param verbose Logical
#' @export
fetch_icd10who2016 <- function(do_save = TRUE, verbose = FALSE) {
  message("Downloading WHO ICD data. This will take a few minutes. ",
          "Data is cached, so if there is a download error, re-running the ",
          "command will pick up where it left off.")
  icd10who2016 <- .fetch_icd10_who(verbose = verbose)
  rownames(icd10who2016) <- NULL
  icd10who2016$code <- sub(pattern = "\\.", replacement = "",
                           x = icd10who2016$code)
  icd10who2016$chapter <- sub("[^ ]+ ", "", icd10who2016$chapter)
  icd10who2016$sub_chapter <- sub("[^ ]+ ", "", icd10who2016$sub_chapter)
  icd10who2016$major <- sub("[^ ]+ ", "", icd10who2016$major)
  icd10who2016$desc <- sub("[^ ]+ ", "", icd10who2016$desc)
  if (do_save)
    saveRDS(icd10who2016, file.path(get_resource_path(), "icd10who2016.rds"))
  invisible(icd10who2016)
}
