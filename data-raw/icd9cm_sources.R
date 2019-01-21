cms_base <- "http://www.cms.gov/Medicare/Coding/ICD9ProviderDiagnosticCodes/Downloads/"
cdc_base <- "http://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/"
icd9cm_sources <- data.frame(
  version = as.character(c(32, 31, 30, 29, 28, 27, 26, 25, 24, 23)),
  f_year = c(as.character(seq(2014, 2005))),
  start_date = c("2014-10-01", "2013-10-01", "2012-10-01", "2011-10-01", "2010-10-01",
                 "2009-10-01", "2008-10-01", "2007-10-01", "2006-10-01", "2005-10-01"),
  long_filename = c(
    "CMS32_DESC_LONG_DX.txt",
    "CMS31_DESC_LONG_DX.txt",
    "CMS30_DESC_LONG_DX 080612.txt",
    "CMS29_DESC_LONG_DX.101111.txt",
    "CMS28_DESC_LONG_DX.txt",
    NA, # see other filename
    NA, # no long descriptions available for these years
    NA,
    NA,
    NA),
  short_filename = c(
    "CMS32_DESC_SHORT_DX.txt",
    "CMS31_DESC_SHORT_DX.txt",
    "CMS30_DESC_SHORT_DX.txt",
    "CMS29_DESC_SHORT_DX.txt",
    "CMS28_DESC_SHORT_DX.txt",
    NA,
    "V26 I-9 Diagnosis.txt", # nolint
    "I9diagnosesV25.txt",
    "I9diagnosis.txt",
    "I9DX_DESC.txt"),
  other_filename = c(NA, NA, NA, NA, NA,
                     "V27LONG_SHORT_DX_110909.csv",
                     # "V27LONG_SHORT_DX_110909u021012.csv" is 'updated' but
                     # hasn't got correctly formatted <3digit codes.
                     NA, NA, NA, NA),
  long_encoding = c("latin1", "latin1", "latin1",
                    "latin1", "latin1", "latin1",
                    NA, NA, NA, NA),
  short_encoding = rep_len("ASCII", 10),
  url = c(
    paste0(cms_base, "ICD-9-CM-v32-master-descriptions.zip"),
    paste0(cms_base, "cmsv31-master-descriptions.zip"),
    paste0(cms_base, "cmsv30_master_descriptions.zip"),
    paste0(cms_base, "cmsv29_master_descriptions.zip"),
    paste0(cms_base, "cmsv28_master_descriptions.zip"),
    paste0(cms_base, "FY2010Diagnosis-ProcedureCodesFullTitles.zip"),
    # but this one is in a different format! only contains short descs:
    # paste0(cms_base, "v27_icd9.zip",
    paste0(cms_base, "v26_icd9.zip"),
    paste0(cms_base, "v25_icd9.zip"),
    paste0(cms_base, "v24_icd9.zip"),
    paste0(cms_base, "v23_icd9.zip")),
  # FY11,12,13,14 are the same?
  rtf_url = c(
    rep_len(paste0(cdc_base, "ICD9-CM/2011/Dtab12.zip"), 4),
    paste0(cdc_base, "ICD9-CM/2010/DTAB11.zip"),
    paste0(cdc_base, "ICD9-CM/2009/Dtab10.zip"),
    paste0(cdc_base, "ICD9-CM/2008/Dtab09.zip"),
    paste0(cdc_base, "ICD9-CM/2007/Dtab08.zip"),
    paste0(cdc_base, "ICD9-CM/2006/Dtab07.zip"),
    paste0(cdc_base, "ICD9-CM/2005/Dtab06.zip")),
  # there are more RTF files, but not with corresponding CMS, back to 1990s
  rtf_filename = c(
    rep_len("Dtab12.rtf", 4),
    "DTAB11.RTF", "Dtab10.RTF", "Dtab09.RTF", "Dtab08.RTF",
    "Dtab07.RTF", "Dtab06.rtf"),
  stringsAsFactors = FALSE
)
rm(list = c("cms_base", "cdc_base"))
save(icd9cm_sources, file = file.path("data", "icd9cm_sources.rda"))

