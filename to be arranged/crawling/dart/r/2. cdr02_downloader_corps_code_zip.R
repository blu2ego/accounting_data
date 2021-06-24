############################################################
## /ward/crawling/dar/r/cdr02_downloader_corps_code_zip.R ##
############################################################

# set working directory
setwd(file.path(main_dir, corps_code_zip_dir))

base_date_corps_code_zip <- paste0("corps_code_", base_date, ".zip")

request_url_corps_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart)

download.file(url = request_url_corps_code, 
              destfile = base_date_corps_code_zip,
              mode = "wb", 
              quiet = TRUE)

# Comments: When use download.file() function on Windows, should be careful as below:
# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.
# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.