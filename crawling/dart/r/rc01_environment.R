# Setting Global Environments

# importing dart's key
key_dart <- readLines("~/projects/wrangling_accounting_related_data/crawling/sources/key_dart.txt", warn = FALSE)

# loading required libraries
library(rvest)
library(stringi)
library(tidyverse)

# creating xml_child2df function to import and process xml
xml_child2df <- function(x){
  x_child <- html_children(x)
  x_df <- as.data.frame(matrix(html_text(x_child), 
                               byrow = TRUE, 
                               nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

# 기준일 설정
base_date <- Sys.Date()

# 기본 경로 설정
mainDir <- "~/projects/wrangling_accounting_related_data/"

# 추가 경로 설정 및 디렉토리 생성
corps_code_zip_Dir <- "results/corps_code/zip/"
corps_code_unzip_Dir <- "results/corps_code/xml/"
corps_code_parsed_csv_Dir <- "results/corps_code/csv/"

ifelse(!dir.exists(file.path(mainDir, corps_code_zip_Dir)), 
       dir.create(file.path(mainDir, corps_code_zip_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_unzip_Dir)), 
       dir.create(file.path(mainDir, corps_code_unzip_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, corps_code_parsed_csv_Dir)), 
       dir.create(file.path(mainDir, corps_code_parsed_csv_Dir)), FALSE)

# A001 관련 경로 설정 및 디렉토리 생성
biz_report_list_xml_Dir <- file.path("results/biz_report/xml/", base_date, "/")
biz_report_list_csv_Dir <- file.path("results/biz_report/csv/", base_date, "/")
biz_report_zip <- file.path("results/biz_report/zip/", base_date, "/")
biz_report_pdf <- file.path("results/biz_report/pdf/", base_date, "/")
biz_report_doc <- file.path("results/biz_report/doc/", base_date, "/")

ifelse(!dir.exists(file.path(mainDir, biz_report_list_xml_Dir)), 
       dir.create(file.path(mainDir, biz_report_list_xml_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, biz_report_list_csv_Dir)), 
       dir.create(file.path(mainDir, biz_report_list_csv_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, biz_report_zip)), 
       dir.create(file.path(mainDir, biz_report_zip)), FALSE)
ifelse(!dir.exists(file.path(mainDir, biz_report_pdf)), 
       dir.create(file.path(mainDir, biz_report_pdf)), FALSE)
ifelse(!dir.exists(file.path(mainDir, biz_report_doc)), 
       dir.create(file.path(mainDir, biz_report_doc)), FALSE)

# F001 관련 경로 설정 및 디렉토리 생성
audit_report_list_xml_Dir <- file.path("results/audit_report/xml/", base_date, "/")
audit_report_list_csv_Dir <- file.path("results/audit_report/csv/", base_date, "/")
audit_report_zip <- file.path("results/audit_report/zip/", base_date, "/")
audit_report_pdf <- file.path("results/audit_report/pdf/", base_date, "/")
audit_report_doc <- file.path("results/audit_report/doc/", base_date, "/")

ifelse(!dir.exists(file.path(mainDir, audit_report_list_xml_Dir)), 
       dir.create(file.path(mainDir, audit_report_list_xml_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, audit_report_list_csv_Dir)), 
       dir.create(file.path(mainDir, audit_report_list_csv_Dir)), FALSE)
ifelse(!dir.exists(file.path(mainDir, audit_report_zip)), 
       dir.create(file.path(mainDir, audit_report_zip)), FALSE)
ifelse(!dir.exists(file.path(mainDir, audit_report_pdf)), 
       dir.create(file.path(mainDir, audit_report_pdf)), FALSE)
ifelse(!dir.exists(file.path(mainDir, audit_report_doc)), 
       dir.create(file.path(mainDir, audit_report_doc)), FALSE)
