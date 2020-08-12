###############################################
## /ward/crawling/dart/r/cdr01_environments.R ##
###############################################

# Setting Global Environments

# importing dart's key
key_dart <- readLines("~/projects/ward/crawling/sources/key_dart.txt", warn = FALSE)

# loading required libraries
library(rvest)
library(stringi)
library(tidyverse)

# set base date
base_date <- Sys.Date()
base_date <- "2020-07-30"

# set main path
main_dir <- "~/projects/ward/"

# set addtional path and create directories related to corp_code
corps_code_zip_dir        <- "results/dart/corps_code/zip/"
corps_code_unzip_dir      <- "results/dart/corps_code/xml/"
corps_code_parsed_csv_dir <- "results/dart/corps_code/csv/"

ifelse(!dir.exists(file.path(main_dir, corps_code_zip_dir)),        dir.create(file.path(main_dir, corps_code_zip_dir)),        FALSE)
ifelse(!dir.exists(file.path(main_dir, corps_code_unzip_dir)),      dir.create(file.path(main_dir, corps_code_unzip_dir)),      FALSE)
ifelse(!dir.exists(file.path(main_dir, corps_code_parsed_csv_dir)), dir.create(file.path(main_dir, corps_code_parsed_csv_dir)), FALSE)

# set addtional path and create directories related to a001
biz_report_list_xml_dir <- file.path("results/dart/biz_report_list/xml/")
biz_report_list_csv_dir <- file.path("results/dart/biz_report_list/csv/")
biz_report_zip          <- file.path("results/dart/biz_report/zip/")

ifelse(!dir.exists(file.path(main_dir, biz_report_list_xml_dir)), dir.create(file.path(main_dir, biz_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_list_csv_dir)), dir.create(file.path(main_dir, biz_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_zip)),          dir.create(file.path(main_dir, biz_report_zip)),          FALSE)

# set addtional path and create directories related to f001
audit_report_list_xml_dir <- file.path("results/dart/audit_report_list/xml/",     base_date, "/")
audit_report_list_csv_dir <- file.path("results/dart/audit_report_list/csv/",     base_date, "/")
audit_report_zip          <- file.path("results/dart/audit_report/zip/",          base_date, "/")
audit_report_xml_from_biz <- file.path("results/dart/audit_report/xml/from_biz/", base_date, "/")
audit_report_xml_from_aud <- file.path("results/dart/audit_report/xml/from_aud/", base_date, "/")
audit_report_pdf_from_biz <- file.path("results/dart/audit_report/pdf/from_biz/", base_date, "/")
audit_report_pdf_from_aud <- file.path("results/dart/audit_report/pdf/from_aud/", base_date, "/") 

ifelse(!dir.exists(file.path(main_dir, audit_report_list_xml_dir)), dir.create(file.path(main_dir, audit_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_list_csv_dir)), dir.create(file.path(main_dir, audit_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_zip)),          dir.create(file.path(main_dir, audit_report_zip)),          FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_biz)), dir.create(file.path(main_dir, audit_report_xml_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_aud)), dir.create(file.path(main_dir, audit_report_xml_from_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_biz)), dir.create(file.path(main_dir, audit_report_pdf_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_aud)), dir.create(file.path(main_dir, audit_report_pdf_from_aud)), FALSE)
