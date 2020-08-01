exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())  

# set working directory
os.chdir(mainDir + audit_report_list_xml_Dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

audit_reports = os.listdir()

for n in range(len(audit_reports)):
  audit_report = open(file = audit_reports[n], mode = "r", encoding = "UTF-8")
  audit_report = BeautifulSoup(audit_report).find_all("list")
  
  if len(audit_report) > 0:
    df_audit_report = pd.DataFrame()
    for audit_report_sub in audit_report:
      # audit_report_sub = audit_report[0]
      df_audit_report_sub = pd.DataFrame([[audit_report_sub.select("corp_code" )[0].text,
                                           audit_report_sub.select("corp_name" )[0].text,
                                           audit_report_sub.select("stock_code")[0].text,
                                           audit_report_sub.select("corp_cls"  )[0].text,
                                           audit_report_sub.select("report_nm" )[0].text,
                                           audit_report_sub.select("rcept_no"  )[0].text,
                                           audit_report_sub.select("flr_nm"    )[0].text,
                                           audit_report_sub.select("rcept_dt"  )[0].text,
                                           audit_report_sub.select("rm"        )[0].text]])
      df_audit_report = pd.concat([df_audit_report, df_audit_report_sub])
   
    df_audit_report.columns = ["corp_code", "corp_name", "stock_code", "corp_cls", "report_nm", "rcept_no", "flr_nm", "rcept_dt", "rm"]
    df_audit_report.to_csv("../../csv/" + base_date + "/doc_f001_list_parsed_" + df_audit_report.iloc[0, 0] + ".csv", index = False)
 
