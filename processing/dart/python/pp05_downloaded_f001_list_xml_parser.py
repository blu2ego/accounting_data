# set working directory
os.chdir(main_dir + audit_report_list_xml_dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

list_f001s_xml = os.listdir()

for n_f001s in range(len(list_f001s_xml)):
  list_f001 = open(file = list_f001s_xml[n_f001s], mode = "r", encoding = "UTF-8")
  list_f001 = BeautifulSoup(list_f001).find_all("list")
  
  if len(list_f001) > 0:
    df_list_f001 = pd.DataFrame()
    for list_f001_sub in list_f001:
      df_list_f001_sub = pd.DataFrame([[list_f001_sub.select("corp_code" )[0].text,
                                        list_f001_sub.select("corp_name" )[0].text,
                                        list_f001_sub.select("stock_code")[0].text,
                                        list_f001_sub.select("corp_cls"  )[0].text,
                                        list_f001_sub.select("report_nm" )[0].text,
                                        list_f001_sub.select("rcept_no"  )[0].text,
                                        list_f001_sub.select("flr_nm"    )[0].text,
                                        list_f001_sub.select("rcept_dt"  )[0].text,
                                        list_f001_sub.select("rm"        )[0].text]])
      df_list_f001 = pd.concat([df_list_f001, df_list_f001_sub])
   
    df_list_f001.columns = ["corp_code", "corp_name", "stock_code", "corp_cls", "report_nm", "rcept_no", "flr_nm", "rcept_dt", "rm"]
    df_list_f001.to_csv("../../csv/" + base_date + "/doc_f001_list_parsed_" + df_list_f001.iloc[0, 0] + ".csv", index = False)
 
