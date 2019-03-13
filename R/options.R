.show_options <- function() {
  o <- options()
  o[grepl("^icd\\.data", names(o))]
}

# options are:
#
# icd.data.offline - default is TRUE, unless ICD_DATA_OFFLINE is false/no
#
# icd.data.resource - default is ~/.icd.data but won't write unless user gives
# permission
#
# icd.data.absent_action - what to do if data is missing, "stop" or "message"
# consider removing this. Need to automate the hell out of this, but might be
# useful for testing.
#
# icd.data.icd10cm_active_ver - which ICD-10-CM version is currently active.
# Default is 2019.
#
# See also .show_options() .clear_options() .set_dev_options()
.set_init_options <- function() {
  if (!("icd.data.offline" %in% names(options())))
    options("icd.data.offline" = !.env_var_is_false("ICD_DATA_OFFLINE"))
  if (!("icd.data.interact" %in% names(options())))
    options("icd.data.interact" = .env_var_is_true("ICD_DATA_INTERACT"))
  # stop or message, anything else will silently continue
  if ("icd.data.absent_action" %nin% names(options())) {
    ev <- tolower(Sys.getenv("ICD_DATA_ABSENT_ACTION"))
    stopifnot(ev %in% c("stop", "message", ""))
    if (ev == "" && interactive()) ev <- "stop"
    options("icd.data.absent_action" = ev)
  }
  # Which version of ICD-10-CM to use by default?
  if (!("icd.data.icd10cm_active_ver" %in% names(options()))) {
    set_icd10cm_active_ver(2019, check_exists = FALSE)
  }
}

.set_test_options <- function() {
  options(icd.data.offline = TRUE)
  options(icd.data.absent_action = "stop")
  options(icd.data.icd10cm_active_ver = "2019")
  options(icd.data.resource = icd_get_data_dir(force = TRUE))
  options(icd.data.interact = FALSE)
}

.set_dev_options <- function() {
  options(icd.data.offline = FALSE)
  options(icd.data.absent_action = "stop")
  options(icd.data.icd10cm_active_ver = "2019")
  options(icd.data.resource = path.expand(file.path("~", ".icd.data")))
  options(icd.data.interact = TRUE)
}

.env_var_is_false <- function(x) {
  ev <- Sys.getenv(x, unset = "")
  tolower(ev) %in% c(
    "n",
    "no",
    "false",
    "0"
  )
}

.env_var_is_true <- function(x) {
  ev <- Sys.getenv(x, unset = "")
  tolower(ev) %in% c(
    "y",
    "yes",
    "true",
    "1"
  )
}

.unset_options <- function() {
  icd_data_opts <- .show_options()
  icd_data_opts <- sapply(
    icd_data_opts,
    simplify = FALSE, USE.NAMES = TRUE,
    FUN = function(x) NULL
  )
  options(icd_data_opts)
}
