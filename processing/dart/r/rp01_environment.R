library(rvest)
library(stringi)
library(jsonlite)
library(tabulizer)

base_date <- Sys.Date()

# A001
biz_report_doc             <- paste0("results/biz_report/doc/",  base_date, "/")
biz_report_pdf             <- paste0("results/biz_report/pdf/",  base_date, "/")
biz_report_list_csv_Dir    <- paste0("results/biz_report/csv/",  base_date, "/")
biz_report_parsed_rds_Dir  <- paste0("results/biz_report/rds/",  base_date, "/")
biz_report_parsed_json_Dir <- paste0("results/biz_report/json/", base_date, "/")


# F001
audit_report_doc             <- paste0("results/audit_report/doc/",  base_date, "/")
audit_report_pdf             <- paste0("results/audit_report/pdf/", base_date, "/")
audit_report_list_csv_Dir    <- paste0("results/audit_report/csv/",  base_date, "/")
audit_report_parsed_rds_Dir  <- paste0("results/audit_report/rds/",  base_date, "/")
audit_report_parsed_json_Dir <- paste0("results/audit_report/json/", base_date, "/")

