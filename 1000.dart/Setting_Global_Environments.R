################################################
## Setting Global Environments
################################################

# importing dart's key
key_dart <- readLines("~/projects/general/key_dart.txt", warn = FALSE)

# loading required libraries
library(rvest)
library(stringi)
library(tidyverse)
library(jsonlite)
# set base date(xml2)

base_date <- Sys.Date()

# set main path
code_dir <- "~/projects/ward/"
data_dir <- "~/data2/ward_data/results/"

# set additional path and create directories related to corp_code
corps_code_zip_dir        <- "/dart/corps_code/zip/"
corps_code_unzip_dir      <- "/dart/corps_code/xml/"
corps_code_parsed_csv_dir <- "/dart/corps_code/csv/"

ifelse(!dir.exists(file.path(data_dir, corps_code_zip_dir)),        dir.create(file.path(data_dir, corps_code_zip_dir)),        FALSE)
ifelse(!dir.exists(file.path(data_dir, corps_code_unzip_dir)),      dir.create(file.path(data_dir, corps_code_unzip_dir)),      FALSE)
ifelse(!dir.exists(file.path(data_dir, corps_code_parsed_csv_dir)), dir.create(file.path(data_dir, corps_code_parsed_csv_dir)), FALSE)

# set additional path and create directories related to a001
biz_report_list_xml_dir <- file.path("~/data2/ward_data/results/dart/biz_report_list/xml/")
biz_report_list_csv_dir <- file.path("~/data2/ward_data/results/dart/biz_report_list/csv/")
biz_report_zip          <- file.path("~/data2/ward_data/results/dart/biz_report/zip/")
biz_report_xml          <- file.path("~/data2/ward_data/results/dart/biz_report/xml/")

ifelse(!dir.exists(file.path(main_dir, biz_report_list_xml_dir)), dir.create(file.path(main_dir, biz_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_list_csv_dir)), dir.create(file.path(main_dir, biz_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_zip)),          dir.create(file.path(main_dir, biz_report_zip)),          FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_xml)),          dir.create(file.path(main_dir, biz_report_xml)),          FALSE)

# set additional path and create directories related to f001
audit_report_list_xml_dir <- file.path("~/data2/ward_data/results/dart/audit_report_list/xml/")
audit_report_list_csv_dir <- file.path("~/data2/ward_data/results/dart/audit_report_list/csv/")
audit_report_zip          <- file.path("~/data2/ward_data/results/dart/audit_report/zip/",          base_date, "/")
audit_report_xml_from_biz <- file.path("~/data2/ward_data/results/dart/audit_report/xml/from_biz/")
audit_report_xml_from_aud <- file.path("~/data2/ward_data/results/dart/audit_report/xml/from_aud/")
audit_report_pdf_from_biz <- file.path("~/data2/ward_data/results/dart/audit_report/pdf/from_biz/")
audit_report_pdf_from_aud <- file.path("~/data2/ward_data/results/dart/audit_report/pdf/from_aud/") 

ifelse(!dir.exists(file.path(main_dir, audit_report_list_xml_dir)), dir.create(file.path(main_dir, audit_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_list_csv_dir)), dir.create(file.path(main_dir, audit_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_zip)),          dir.create(file.path(main_dir, audit_report_zip)),          FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_biz)), dir.create(file.path(main_dir, audit_report_xml_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_aud)), dir.create(file.path(main_dir, audit_report_xml_from_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_biz)), dir.create(file.path(main_dir, audit_report_pdf_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_aud)), dir.create(file.path(main_dir, audit_report_pdf_from_aud)), FALSE)

# A001
audit_report_rds_from_biz  <- file.path("results/dart/for_accounting/rds/from_biz/")
audit_report_json_from_biz <- file.path("results/dart/for_accounting/json/from_biz/")

ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_rds_biz)), dir.create(file.path(main_dir, audit_report_parsed_rds_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_biz)), dir.create(file.path(main_dir, audit_report_parsed_json_biz)), FALSE)

# F001
audit_report_rds_from_aud  <- file.path("results/dart/for_accounting/rds/from_aud/")
audit_report_json_from_aud <- file.path("results/dart/for_accounting/json/from_aud/")

ifelse(!dir.exists(file.path(main_dir, audit_report_rds_aud)), dir.create(file.path(main_dir, audit_report_rds_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_aud)), dir.create(file.path(main_dir, audit_report_parsed_json_aud)), FALSE)

# set path and create directories related to O001
operation_report_pdf_from_biz <- file.path("~/data2/ward_data/results/dart/opeation_report/")
ifelse(!dir.exists(file.path(main_dir, operation_report_pdf_from_biz)), dir.create(file.path(main_dir, operation_report_pdf_from_biz)), FALSE)

# creating xml_child2df function to import and process xml
xml_child2df <- function(x){
  x_child <- html_children(x)
  x_df <- as.data.frame(matrix(html_text(x_child), 
                               byrow = TRUE, 
                               nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}
