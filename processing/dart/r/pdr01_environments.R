##################################################
## /ward/processing/dart/r/pdr01_environments.R ##
##################################################

library(stringi)
library(jsonlite)
library(tabulizer)

# creating xml_child2df function to import and process xml
xml_child2df <- function(x){
  x_child <- html_children(x)
  x_df <- as.data.frame(matrix(html_text(x_child), 
                               byrow = TRUE, 
                               nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

# A001
audit_report_parsed_rds_biz  <- file.path("results/dart/audit_report/rds/biz",  base_date, "/")
audit_report_parsed_json_biz <- file.path("results/dart/audit_report/json/biz", base_date, "/")

ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_rds_biz)), dir.create(file.path(main_dir, audit_report_parsed_rds_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_biz)), dir.create(file.path(main_dir, audit_report_parsed_json_biz)), FALSE)

# F001
audit_report_parsed_rds_aud  <- file.path("results/dart/audit_report/rds/aud",  base_date, "/")
audit_report_parsed_json_aud <- file.path("results/dart/audit_report/json/aud", base_date, "/")

ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_rds_aud)), dir.create(file.path(main_dir, audit_report_parsed_rds_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_aud)), dir.create(file.path(main_dir, audit_report_parsed_json_aud)), FALSE)
