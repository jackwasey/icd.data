<!-- rmarkdown::render("README.Rmd") -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/icd.data)](https://cran.r-project.org/package=icd.data)
[![Travis-CI Build
Status](https://travis-ci.org/jackwasey/icd.data.svg?branch=master)](https://travis-ci.org/jackwasey/icd.data)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/jackwasey/icd.data?branch=master&svg=true)](https://ci.appveyor.com/project/jackwasey/icd.data)
[![Dependencies](https://tinyverse.netlify.com/badge/icd.data)](https://cran.r-project.org/package=icd.data)
<!-- badges: end -->

# icd.data

ICD-9 and ICD-10 definitions from the World Health Organization, the
United States Center for Medicare and Medicaid Services (CMS), France,
and Belgium are made available by this package. There are diagnostic and
procedure codes, and lists of the chapter and sub-chapter headings and
the ranges of ICD codes they encompass. There are also two sets of
sample patient data with ICD-9 and ICD-10 codes representing real
patients. Much of the data is downloaded and parsed on demand. Use
`setup_icd_data()` to initialize the cache, and optionally
`download_icd_data()` to download all data in one go. This can all be
done at once, or piecemeal as data is used. These data are used by the
`icd` package, which finds comorbidities and has tools for working with
ICD codes.

See documentation for the [R CRAN package:
icd](https://jackwasey.github.io/icd/) for how to use this data.

## Installation

``` r
install.packages("icd.data")
```

You can install icd.data from github with:

``` r
# install.packages("devtools")
devtools::install_github("jackwasey/icd.data")
```
