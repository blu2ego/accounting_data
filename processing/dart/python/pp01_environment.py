# loading required libraries
from numpy import arange
import pandas as pd
import zipfile
import requests
import random

# A001
audit_report_parsed_rds_biz  = "results/dart/audit_report/rds/biz/"  + base_date + "/"
audit_report_parsed_json_biz = "results/dart/audit_report/json/biz/" + base_date + "/"

dir_maker(main_dir + audit_report_parsed_rds_biz)
dir_maker(main_dir + audit_report_parsed_json_biz)

# F001
audit_report_parsed_rds_aud  = "results/dart/audit_report/rds/aud/"  + base_date + "/"
audit_report_parsed_json_aud = "results/dart/audit_report/json/aud/" + base_date + "/"

dir_maker(main_dir + audit_report_parsed_rds_aud)
dir_maker(main_dir + audit_report_parsed_json_aud)
