utils::globalVariables(".icd_data_env")

#' Get the filesystem path used to save downloaded data
#'
#' Currently this is only needed for WHO ICD-10 data, which is downloaded on
#' demand. The default path attempted is `file.path(Sys.getenv("HOME"),
#' ".icd.data")`. This may be overridden by setting the option
#' `icd.data.resource` to the path of your choice. E.g.,
#' `set_resource_path('/tmp/icd.data.resource')` or by setting the option itself
#' using `options(icd.data.resource = '/tmp/icd.data.resource')`.
#' @param set_if_missing Logical, if `TRUE`, \link{set_resource_path} is called
#' @param must_work Logical, if `TRUE`, the default, failure to get a valid path
#'   will stop execution.
#' @param verbose Logical, default `FALSE`
#' @seealso \link{set_resource_path}
#' @export
get_resource_path <- function(
  set_if_missing = FALSE,
  must_work = TRUE,
  verbose = FALSE
) {
  path <- normalizePath(getOption("icd.data.resource"), mustWork = TRUE)
  if (dir.exists(path)) {
    if (verbose) message("Found icd.data resource path exists at: ", path)
    return(path)
  }
  if (is.null(path))
    warning("icd.data.resource option is not set")
  else
    warning("icd.data.resource option has non-existent path: ", path)
  if (set_if_missing)
    return(set_resource_path(path = path, verbose = verbose))
  if (must_work) stop("Use:\nset_resource_path()\npr:\n",
                      "set_resource_path(path = '/dir/you/want')\n",
                      " to set-up cache for downloading WHO ICD-10 data.",
                      call. = FALSE)
  invisible()
}

#' Set the filesystem path used to save downloaded data
#'
#' If the directory exists, the directory is used by `icd.data`. If the
#' directory does not exist, and R is in `interactive()` mode, then the user is
#' asked whether a directory may be created. The default path of this directory
#' is given by `file.path(Sys.getenv("HOME"), ".icd.data")`, which is
#' `~/.icd.data` on Linux, MacOS, UNIX. Something like
#' `options(icd.data.resource = "/tmp/icd.data.resource")` may be used to change
#' the default directory attempted, or to avoid a prompt by using that directory
#' automatically. This may be set in `.Rprofile`. The simplest way is just to
#' let `icd.data` use the default directory.
#' @section Non-interactive mode: If R is running non-interactively, e.g. CRAN
#'   testing, Travis, package building, or in an automated user script, no
#'   directories are created and a temporary directory is created. The
#'   session-wide R option `icd.data.resource` is set to the temporary
#'   directory's path.
#' @param path Path to a writable directory, default is given by:
#'   `file.path(Sys.getenv("HOME"), ".icd.data")`
#' @param verbose Logical
#' @return The final path, which may be temporary directory if user denied
#'   creation of home directory hidden directory.
#' @seealso \link{get_resource_path}
#' @export
set_resource_path <- function(
  path = getOption("icd.resource.path"),
  verbose = FALSE
) {
  if (verbose) {
    message("Changing icd.data resource path from:")
    print(get_resource_path())
    message("to:")
    print(path)
  }
  if (!dir.exists(path)) {
    if (verbose) message("icd.data.resource path: ", path, "does not exist.")
    inp <- readline(paste("May I create the directory: ", path,
                          "to cache WHO ICD data? (Y/N): "))

    if (startsWith(tolower(inp), "y")) {
      dir.create(path)
    } else {
      path <- tempdir()
      if (verbose)
        message("Cannot get user confirmation. Using temporary directory:\n",
                path)
    }
  }
  options("icd.data.resource" = path)
  path
}

.icd10who2016_in_env <- function() {
  exists("icd10who2016", envir = .icd_data_env)
}

.icd10who2016_clean_env <- function() {
  if (.icd10who2016_in_env())
    rm("icd10who2016", envir = .icd_data_env)
}

#' Function to get the WHO ICD-10 2016 data
#' @description The user may use the active binding `icd10who2016` as if it is a
#'   variable. In some situations, it may be preferable to call this function.
#'   E.g., using the active binding when the cache directory has not been
#'   populated may produce messages. Auto-complete in Rstudio is unfortunately
#'   considered still to be interactive, so these messages may appear
#'   prematurely.
#' @details This is needed (in addition to icd.data::icd10who2016 active
#'   binding), because lazy data and apparently active bindings are not
#'   available until the package is on the search path. This is difficult or
#'   impossible to do in a CRAN compatible way in the 'icd' package, so this
#'   function is just for that purpose, since we can check whether this function
#'   exists and call it without using ::, whereas this is not possible with lazy
#'   data or active bindings.
#' @export
#' @keywords datasets
get_icd10who2016 <- function() {
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
    dat <- get_icd10who2016()
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
    stop("This binding is read-only. Use fetch_icd10who2016() to populate.")
  }
}

# returns the JSON data, or fails with NULL
.fetch_who_api <- function(resource,
                           ver = "icd10",
                           year = 2016,
                           lang = "en",
                           verbose = FALSE) {
  if (requireNamespace("memoise", quietly = TRUE))
    httr_get <- memoise::memoise(
      httr::GET,
      cache = memoise::cache_filesystem(
        file.path(
          getOption("icd.data.resource",
                    default = stop("Option icd.data.resource not set")),
          "memoise")
      )
    )
  else
    httr_get <- httr::GET
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
  .fetch_who_api_children(ver = ver, year = year, lang = lang,
                          verbose = verbose)[["label"]]
}

.fetch_who_api_children <- function(concept_id = NULL, ...) {
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
                             verbose = FALSE,
                             hier_code = character(),
                             hier_desc = character(),
                             debug = FALSE,
                             ...) {
  if (!requireNamespace("memoise", quietly = TRUE))
    message("Consider installing 'memoise' from CRAN using:\n",
            'install.packages("memoise")\n',
            "This will allow the WHO data download to resume if interrupted.")
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
  tree_json <- .fetch_who_api_children(concept_id = concept_id,
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
    if (length(hier_code) >= 3 && nchar(hier_code[3]) > 3)
      sub_sub_chapter <- hier_desc[3]
    this_child_up_hier <- grepl("[XVI-]", child_code)
    three_digit <- hier_code[hier_three_digit_idx]
    major <- hier_desc[hier_three_digit_idx]
    if (!this_child_up_hier && !is.na(three_digit)) {
      # TODO: consider add the chapter, subchapter codes
      new_item <- data.frame(code = child_code,
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
      recursed_rows <- .fetch_icd10_who(concept_id = child_code,
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
  if (verbose) message("leaving recursion with nrow(new_rows) = ",
                       nrow(new_rows))
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
#' @param ... Arguments passed to internal functions
#' @export
fetch_icd10who2016 <- function(do_save = TRUE, ...) {
  message("Downloading WHO ICD data. This will take a few minutes. ",
          "Data is cached, so if there is a download error, re-running the ",
          "command will pick up where it left off.")
  icd10who2016 <- .fetch_icd10_who(...)
  rownames(icd10who2016) <- NULL
  icd10who2016$code <-
    sub(pattern = "\\.", replacement = "", x = icd10who2016$code)
  for (col_name in c("chapter",
                     "sub_chapter",
                     "sub_sub_chapter",
                     "major",
                     "desc"))
    icd10who2016[[col_name]] <- sub("[^ ]+ ", "", icd10who2016[[col_name]])
  if (do_save)
    saveRDS(icd10who2016, file.path(get_resource_path(), "icd10who2016.rds"))
  invisible(icd10who2016)
}
