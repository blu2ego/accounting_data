source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# working directory를 코드별로 변경하자.

corps_code_raw <- paste0("corps_code_", base_date, ".zip")
corps_code_raw

corps_code_request_url <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", "680d964f06e9a576942d805ad2ba2a38d7e5e378")

# Comments: When use download.file() function on Windows, should be careful as below:
# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.
# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.

# zip 파일 다운로드 받는 건 tempfile()로 처리하는 방식으로 변경하는 게 좋을 듯 
download.file(url = corps_code_request_url, 
              destfile = paste0(mainDir, corps_code_download_Dir_zip, corps_code_raw),
              mode = "wb", 
              quiet = TRUE)

