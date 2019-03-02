stop_binding_ro <- function() {
  stop("This active binding cannot be set", call. = FALSE)
}

# Dynamic
.icd9cm2011_active_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  icd.data::icd9cm_hierarchy
}

.icd10cm_active_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  get_icd10cm_version()
}

.icd10cm_latest_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  icd.data::icd10cm2019
}
# Belgium
.icd10be2014_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10be2014()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-BE 2014 not available.")
}
.icd10be2014_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10be2014_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-BE 2014 procedure codes not available.")
}
.icd10be2017_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10be2017()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-BE 2017 not available.")
}
.icd10be2017_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10be2017_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-BE 2017 procedure codes not available.")
}
# ICD-10-CM
.icd10cm2014_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2014()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2014 not available.")
}
.icd10cm2014_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2014_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2014 not available.")
}
.icd10cm2015_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2015()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2015 not available.")
}
.icd10cm2015_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2015_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2015 not available.")
}
.icd10cm2016_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2016()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2016 not available.")
}
.icd10cm2016_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2016_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2016 not available.")
}
.icd10cm2017_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2017()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2017 not available.")
}
.icd10cm2017_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2017_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2017 not available.")
}
.icd10cm2018_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2018()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2018 not available.")
}
.icd10cm2018_pc_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10cm2018_pc()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10-CM 2018 not available.")
}

.icd10who2016_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10who2016()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("WHO ICD-10 2016 not available.")
}

.icd10who2008fr_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  dat <- get_icd10who2008fr()
  if (!is.null(dat)) return(dat)
  message_who()
  .stop_on_absent("ICD-10 2008 France not available.",
                  "CIM-10 2008 n'est pas disponible")
}

bindings <- c("icd10be2014",
              "icd10be2017",
              "icd10be2014_pc",
              "icd10be2017_pc",
              "icd10cm2014",
              "icd10cm2014_pc",
              "icd10cm2015",
              "icd10cm2015_pc",
              "icd10cm2017",
              "icd10cm2017_pc",
              "icd10cm2018",
              "icd10cm2018_pc",
              "icd10who2016",
              "icd10who2008fr"
)

#' Localised synonym for icd10fr2019, with French column names
#' @keywords internal
#' @noRd
.cim10fr2019_active_binding <- function(x) {
  if (!missing(x)) stop_binding_ro()
  if (exists("cim10fr2019", envir = .icd_data_env))
    return(get("cim10fr2019", envir = .icd_data_env))
  cim10fr2019 <- icd.data::icd10fr2019
  names(cim10fr2019) <- c("code",
                          "desc_courte",
                          "desc_longue",
                          "majeure",
                          "trois_chiffres")
  rownames(cim10fr2019) <- NULL
  assign("cim10fr2019",
         value = cim10fr2019,
         envir = .icd_data_env)
  cim10fr2019
}

message_who <- function() {
  o <- getOption("icd.data_absent_action")
  if (!is.null(o) && o %nin% c("stop", "message"))
    message(
      "WHO ICD data must be downloaded by each user due to copyright
    concerns. This may be achieved by running either of the commands

    fetch_icd10who2016()
    fetch_icd10who2008_fr()

    The data has to be saved somewhere accessible. The
    location is given by:

    get_resource_path()

    which defaults to:

    file.path(Sys.getenv(\"HOME\"), \".icd.data\")

    See:
    get_resource_path(),
    set_resource_path(\"new/path/to/dir\")")
}
