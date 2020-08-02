# loading required libraries
import pandas as pd
import os
import zipfile

# UDF - dir_maker
def dir_maker(path):
    if not os.path.exists(path):
        os.makedirs(path)
        print("True")
    else:
        print("False")

# base date
base_date = time.strftime('%Y-%m-%d', time.localtime(time.time()))

# A001
audit_report_parsed_rds_biz  = "results/dart/audit_report/rds/biz"  + base_date + "/"
audit_report_parsed_json_biz = "results/dart/audit_report/json/biz" + base_date + "/"

dir_maker(main_dir + audit_report_parsed_rds_biz)
dir_maker(main_dir + audit_report_parsed_json_biz)

# F001
audit_report_parsed_rds_aud  = "results/dart/audit_report/rds/aud"  + base_date + "/"
audit_report_parsed_json_aud = "results/dart/audit_report/json/aud" + base_date + "/"

dir_maker(main_dir + audit_report_parsed_rds_aud)
dir_maker(main_dir + audit_report_parsed_json_aud)
