exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(mainDir + audit_report_list_csv_dir)

# loading required libraries
import pandas as pd
from numpy import arange
import requests
import random

# importing list of F001 files
lists_f001 = os.listdir()

# download F001 files
start_f001 = 30000
end_f001 = 30010
time_delay_f001 = 1

for n_file in arange(start_f001, end_f001):
  list_f001 = pd.read_csv(lists_f001[n_file], na_filter = False)
  list_f001["year"] = list_f001["report_nm"].str.extract(pat = "([0-9]{4})")
  
  corp_code_f001 = "{:08}".format(list_f001.loc[0, "corp_code"]) 
   
  path_dir = "../../../../" + mainDir + audit_report_zip + "corp_code_" + corp_code_f001
  os.makedirs(path_dir)
  
  print(n_file)

  for n_row in range(len(list_f001)):
    rcept_no = list_f001.loc[n_row, "rcept_no"].astype("str")
    request_url_f001 = "".join(["https://opendart.fss.or.kr/api/document.xml?",
                                "&crtfc_key=", key_dart,
                                "&rcept_no=", rcept_no])
    
    report_f001 = requests.get(request_url_f001)
     
    path_zip = path_dir + "/" + list_f001.loc[n_row, "year"] + "_" + rcept_no + ".zip"

    with open(path_zip, "wb") as file:
      file.write(report_f001.content)

  time.sleep(time_delay_f001 + random.uniform(0, 1) * 2)
