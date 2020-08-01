source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, corps_code_zip_Dir))

file_name <- paste0("corps_code_", base_date, ".zip")
file_name_unzip <- paste0("corps_code_", base_date, ".xml")

unzip(zipfile = file_name,  exdir = file.path(mainDir, corps_code_unzip_Dir))

# change working directory from corps_code_zip_Dir to corps_code_unzip_Dir 
setwd(file.path(mainDir, corps_code_unzip_Dir))

file.rename("CORPCODE.xml", to = file_name_unzip)
