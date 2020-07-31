# loading required libraries
import pandas as pd

# base date
base_date = time.strftime('%Y-%m-%d', time.localtime(time.time()))

# A001
biz_report_doc             = "results/biz_report/doc/" + base_date + "/"
biz_report_pdf             = "results/biz_report/pdf/" + base_date + "/"
biz_report_list_csv_Dir    = "results/biz_report/csv/" + base_date + "/"
biz_report_parsed_rds_Dir  = "results/biz_report/rds/" + base_date + "/"
biz_report_parsed_json_Dir = "results/biz_report/json/" + base_date + "/"

# F001
audit_report_doc             = "results/audit_report/doc/" + base_date + "/"
audit_report_pdf             = "results/audit_report/pdf/" + base_date + "/"
audit_report_list_csv_Dir    = "results/audit_report/csv/" + base_date + "/"
audit_report_parsed_rds_Dir  = "results/audit_report/rds/" + base_date + "/"
audit_report_parsed_json_Dir = "results/audit_report/json/" + base_date + "/"
