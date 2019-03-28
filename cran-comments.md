I am submitting icd 4.0.2, icd.data 1.1.2 and a new pacakge nhds 1.0.2 simultaneously, although they no longer have version inter-dependencies, and will each pass check without the new versions of the other packages. The UTF-8 strings are due to accented characters in some disease names.

## Test environments
* local OS X install, R 3.5.2
* Ubuntu 14.04 (on travis-ci), R 3.5.2
* Windows (on appveyor-ci) R devel
* R-hub

## R CMD check results

0 errors | 0 warnings | 1 note

* checking installed package size ...
     installed size is 21.5Mb
     sub-directories of 1Mb or more:
       data  21.2Mb

