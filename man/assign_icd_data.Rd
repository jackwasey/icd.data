% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assign.R
\name{assign_icd_data}
\alias{assign_icd_data}
\title{Assign all the data in the package to the calling environment}
\usage{
assign_icd_data(env = parent.frame())
}
\description{
Used by \pkg{icd} to load all the data into its environment. This should not
be needed by most users, who can simply refer to the data objects normally
after calling \code{library(icd.data)}.
}
\examples{
\dontrun{
assign_icd_data()
# but most users just need to:
library(icd.data)
# then refer to the data in the package in the normal way:
print(icd10_chapters)
# or even simpler:
library(icd)
# which will attach icd.data
}
}
\keyword{internal}
