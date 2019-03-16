<!-- rmarkdown::render("README.Rmd") -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/icd.data)](https://cran.r-project.org/package=icd.data)
[![Travis-CI Build
Status](https://travis-ci.org/jackwasey/icd.data.svg?branch=master)](https://travis-ci.org/jackwasey/icd.data)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/jackwasey/icd.data?branch=master&svg=true)](https://ci.appveyor.com/project/jackwasey/icd.data)
[![CRAN
status](https://www.r-pkg.org/badges/version/icd.data)](https://cran.r-project.org/package=icd.data)
[![Dependencies](https://tinyverse.netlify.com/badge/icd.data)](https://cran.r-project.org/package=icd.data)
<!-- badges: end -->

# icd.data

ICD-9 and ICD-10 definitions from the United States Center for Medicare
and Medicaid Services (CMS) are included in this package. A function is
provided to extract the WHO ICD-10 definitions from the public
interface, but the data themselves may not currently be redistributed.
The function ‘fetch\_icd10who2016()’ and ‘fetch\_icd10who2008fr’ should
be run once after installing this package. There are diagnostic and
procedure codes, and lists of the chapter and sub-chapter headings and
the ranges of ICD codes they encompass. There are also two sets of
sample patient data with ICD-9 and ICD-10 codes representing real
patients and spanning common structures of patient data. These data are
used by the ‘icd’ package for finding comorbidities and working with ICD
codes.

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
