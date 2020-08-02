exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(main_dir + biz_report_list_csv_dir)

# loading required libraries
import pandas as pd
from numpy import arange
import requests
import random

# importing list of A001 files
lists_a001 = os.listdir()

# download A001 files
start_a001 = 30000
end_a001 = 30010
time_delay_a001 = 1

for n_file in arange(start_a001, end_a001):
  list_a001 = pd.read_csv(lists_a001[n_file], na_filter = False)
  list_a001["year"] = list_a001["report_nm"].str.extract(pat = "([0-9]{4})")
  
  corp_code_a001 = "{:08}".format(list_a001.loc[0, "corp_code"]) 
   
  path_dir = "../../../../" + main_dir + biz_report_zip + "corp_code_" + corp_code_a001
  os.makedirs(path_dir)
  
  print(n_file)

  for n_row in range(len(list_a001)):
    rcept_no = list_a001.loc[n_row, "rcept_no"].astype("str")
    request_url_a001 = "".join(["https://opendart.fss.or.kr/api/document.xml?",
                                "&crtfc_key=", key_dart,
                                "&rcept_no=", rcept_no])
    
    report_a001 = requests.get(request_url_a001)
     
    path_zip = path_dir + "/" + list_a001.loc[n_row, "year"] + "_" + rcept_no + ".zip"

    with open(path_zip, "wb") as file:
      file.write(report_a001.content)

  time.sleep(time_delay_a001 + random.uniform(0, 1) * 2)
