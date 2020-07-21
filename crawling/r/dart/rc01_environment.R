# Setting Global Environments

# importing dart's key
key_dart <- readLines("~/projects/wrangling_accounting_related_data/crawling/sources/key_dart.txt")

# creating xml_child2df function to import and process xml
library(rvest)
xml_child2df <- function(x){
  x_child <- html_children(x)
  
  x_df <- as.data.frame(matrix(html_text(x_child), 
                              byrow = TRUE, 
                              nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

base_date <- Sys.Date()

mainDir <- "~/projects/wrangling_accounting_related_data/"

corps_code_download_Dir_zip <- paste0("results/corp_code/zip/")
corps_code_unzip_Dir_xml <- paste0("results/corp_code/xml/")
corps_code_parsed_Dir_csv <- paste0("results/corp_code/csv/")
report_download_Dir_xml <- paste0("results/xmls/xmls_", base_date, "/")

ifelse(!dir.exists(file.path(mainDir, corps_code_download_Dir_zip)), dir.create(file.path(mainDir, corps_code_download_Dir_zip)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_unzip_Dir_xml)), dir.create(file.path(mainDir, corps_code_unzip_Dir_xml)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_parsed_Dir_csv)), dir.create(file.path(mainDir, corps_code_parsed_Dir_csv)), FALSE)
ifelse(!dir.exists(file.path(mainDir, report_download_Dir_xml)), dir.create(file.path(mainDir, report_download_Dir_xml)), FALSE)
