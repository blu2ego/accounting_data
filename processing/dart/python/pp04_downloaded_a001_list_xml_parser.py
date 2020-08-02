exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())  

# set working directory
os.chdir(main_dir + biz_report_list_xml_dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

list_a001s_xml = os.listdir()

for n in range(len(list_a001s_xml)):
  list_a001 = open(file = list_a001s_xml[n], mode = "r", encoding = "UTF-8")
  list_a001 = BeautifulSoup(list_a001).find_all("list")
  
  if len(list_a001) > 0:
    df_list_a001 = pd.DataFrame()
    for list_a001_sub in list_a001:
      df_list_a001_sub = pd.DataFrame([[list_a001_sub.select("corp_code" )[0].text,
                                        list_a001_sub.select("corp_name" )[0].text,
                                        list_a001_sub.select("stock_code")[0].text,
                                        list_a001_sub.select("corp_cls"  )[0].text,
                                        list_a001_sub.select("report_nm" )[0].text,
                                        list_a001_sub.select("rcept_no"  )[0].text,
                                        list_a001_sub.select("flr_nm"    )[0].text,
                                        list_a001_sub.select("rcept_dt"  )[0].text,
                                        list_a001_sub.select("rm"        )[0].text]])
      df_list_a001 = pd.concat([df_list_a001, df_list_a001_sub])
   
    df_list_a001.columns = ["corp_code", "corp_name", "stock_code", "corp_cls", "report_nm", "rcept_no", "flr_nm", "rcept_dt", "rm"]
    df_list_a001 = df_list_a001.loc[df_list_a001["report_nm"].str.contains("사업보고서"), ]
    
    if len(df_list_a001) > 0:
      df_list_a001.to_csv("../../csv/" + base_date + "/doc_a001_list_parsed_" + df_list_a001.iloc[0, 0] + ".csv", index = False)
