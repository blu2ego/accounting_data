exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())  

# set working directory
os.chdir(mainDir + biz_report_list_xml_Dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

biz_reports = os.listdir()

for n in range(len(biz_reports)):
  biz_report = open(file = biz_reports[n], mode = "r", encoding = "UTF-8")
  biz_report = BeautifulSoup(biz_report).find_all("list")
  
  if len(biz_report) > 0:
    df_biz_report = pd.DataFrame()
    for biz_report_sub in biz_report:
      # biz_report_sub = biz_report[0]
      df_biz_report_sub = pd.DataFrame([[biz_report_sub.select("corp_code" )[0].text,
                                         biz_report_sub.select("corp_name" )[0].text,
                                         biz_report_sub.select("stock_code")[0].text,
                                         biz_report_sub.select("corp_cls"  )[0].text,
                                         biz_report_sub.select("report_nm" )[0].text,
                                         biz_report_sub.select("rcept_no"  )[0].text,
                                         biz_report_sub.select("flr_nm"    )[0].text,
                                         biz_report_sub.select("rcept_dt"  )[0].text,
                                         biz_report_sub.select("rm"        )[0].text]])
      df_biz_report = pd.concat([df_biz_report, df_biz_report_sub])
   
    df_biz_report.columns = ["corp_code", "corp_name", "stock_code", "corp_cls", "report_nm", "rcept_no", "flr_nm", "rcept_dt", "rm"]
    df_biz_report = df_biz_report.loc[df_biz_report["report_nm"].str.contains("사업보고서"), ]
    
    if len(df_biz_report) > 0:
      df_biz_report.to_csv("../../csv/" + base_date + "/doc_a001_list_parsed_" + df_biz_report.iloc[0, 0] + ".csv", index = False)
