############################################################
## download corporate unique code as zip
############################################################

base_date_corps_code_zip <- paste0("corps_code_", base_date, ".zip")

request_url_corps_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart)

download.file(url = request_url_corps_code, 
              destfile = base_date_corps_code_zip,
              # mode = "wb", 
              quiet = TRUE)

# Comments: When use download.file() function on Windows, should be careful as below:
# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.
# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.

######################################################
## unzip the downloaded corps code zip file
######################################################

# set working directory
setwd(file.path(data_dir, corps_code_zip_dir))

# unzip
file_name <- "corps_codezip"
unzip(zipfile = file_name, exdir = file.path(data_dir, corps_code_unzip_dir))

# set working directory
setwd(file.path(data_dir, corps_code_unzip_dir))
file_name_unzip <- "corps_code.xml"
file.rename("CORPCODE.xml", to = file_name_unzip)

###########################################################
## parsing xml to csv
###########################################################

read_xml(file_name_unzip) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

write.csv(x = corps_code, 
          file = "~/data2/ward_data/results/dart/corps_code/csv/corps_code.csv", 
          row.names = FALSE)