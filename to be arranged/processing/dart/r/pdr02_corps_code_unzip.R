######################################################
## /ward/processing/dart/r/pdr02_corps_code_unzip.R ##
######################################################

# set working directory
setwd(file.path(main_dir, corps_code_zip_dir))

file_name       <- paste0("corps_code_", base_date, ".zip")
file_name_unzip <- paste0("corps_code_", base_date, ".xml")

unzip(zipfile = file_name, exdir = file.path(main_dir, corps_code_unzip_dir))

# change working directory from corps_code_zip_dir to corps_code_unzip_dir 
setwd(file.path(main_dir, corps_code_unzip_dir))

file.rename("CORPCODE.xml", to = file_name_unzip)
