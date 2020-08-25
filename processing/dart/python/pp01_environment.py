# loading required libraries
import pandas as pd
import os
import zipfile
import glob

# A001
audit_report_rds_biz  = "results/dart/for_accounting/rds/from_biz/"
audit_report_json_biz = "results/dart/for_accounting/json/from_biz/"

dir_maker(main_dir + audit_report_rds_biz)
dir_maker(main_dir + audit_report_json_biz)

# F001
audit_report_rds_aud  = "results/dart/for_accounting/rds/from_aud/"
audit_report_json_aud = "results/dart/for_accounting/json/from_aud/"

dir_maker(main_dir + audit_report_rds_aud)
dir_maker(main_dir + audit_report_json_aud)
