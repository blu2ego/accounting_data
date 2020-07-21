source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corp_code_raw <- paste0("corp_code_", Sys.Date(), ".zip")

url_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart)

# Comments: When use download.file() function on Windows, should be careful as below:
# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.
# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.

download.file(url = url_code, 
              destfile = corp_code_raw,
              mode = "wb", 
              quiet = TRUE)

