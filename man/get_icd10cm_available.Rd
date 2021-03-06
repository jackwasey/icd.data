% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/icd-cm-ver.R
\name{get_icd10cm_available}
\alias{get_icd10cm_available}
\title{Get the ICD-10-CM versions available in this package}
\usage{
get_icd10cm_available(pc = FALSE, return_year = FALSE)
}
\arguments{
\item{pc}{Logical, if \code{TRUE}, will return names of procedure code data
frames. Default is \code{FALSE} which will return the names of the
diagnostic code data frames.}

\item{return_year}{Logical, which, if \code{TRUE}, will result in only a
character vector of year (or year-like version) being returned.}
}
\description{
Get the ICD-10-CM versions available in this package
}
\examples{
# Diagnostic codes:
get_icd10cm_available()
# Just get the years avaiable for English language procedure codes
get_icd10cm_available(pc = TRUE, return_year = TRUE)
}
