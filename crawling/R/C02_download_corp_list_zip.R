source("~/projects/wrangling_accounting_related_data/crawling/R/C01_environment.R", encoding = "UTF-8")

file_name <- "codebook.zip"

url_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart) 

download.file(url = url_code, 
              destfile = file_name,
              mode = "wb", 
              quiet = TRUE)

# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.

# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.