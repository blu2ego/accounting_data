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

corps_code_zip_Dir <- paste0("results/corps_code/zip/")
corps_code_unzip_Dir <- paste0("results/corps_code/xml/")
corps_code_parsed_csv_Dir <- paste0("results/corps_code/csv/")

ifelse(!dir.exists(file.path(mainDir, corps_code_zip_Dir)), dir.create(file.path(mainDir, corps_code_zip_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_unzip_Dir)), dir.create(file.path(mainDir, corps_code_unzip_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_parsed_csv_Dir)), dir.create(file.path(mainDir, corps_code_parsed_csv_Dir)), FALSE)


audit_report_list_xml_Dir <- paste0("results/audit_report/audit_report_list/", base_date)
audit_report_zip <- paste0("results/audit_report/zip/", base_date)

ifelse(!dir.exists(file.path(mainDir, audit_report_list_xml_Dir)), dir.create(file.path(mainDir, audit_report_list_xml_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, audit_report_zip)), dir.create(file.path(mainDir, audit_report_zip)), FALSE)
