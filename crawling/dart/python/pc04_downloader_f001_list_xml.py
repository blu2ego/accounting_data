exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(mainDir + corps_code_parsed_csv_dir)

# loading required libraries
import pandas as pd
from numpy import arange
import requests
import random

corps_code_f001 = pd.read_csv("corps_code_parsed_" + base_date + ".csv")

os.chdir("../../..")

date_begin_f001 = "19800101"
date_end_f001 = base_date.replace("-", "")
last_reprt_at_f001 = "Y"
pblntf_ty_f001 = "A"
pblntf_detail_ty_f001 = "f001"
page_count_f001 = 100

start_f001 = 0
end_f001 = len(corps_code_f001)
time_delay_f001 = 1

for i in arange(start_f001, end_f001):
  print(i)
  corp_code_f001 = "{:08}".format(corps_code_f001.loc[i, "corp_code"])
  corp_name_f001 = corps_code_f001.loc[i, "corp_name"]
  
  request_url_f001 = "".join(["https://opendart.fss.or.kr/api/list.xml?", 
                              "&crtfc_key=", key_dart,
                              "&corp_code=", corp_code_f001,
                              "&bgn_de=", date_begin_f001,
                              "&end_de=", date_end_f001,
                              "&last_reprt_at", last_reprt_at_f001,
                              "&pblntf_ty=", pblntf_ty_f001,
                              "&pblntf_detail_ty=", pblntf_detail_ty_f001,
                              "&page_count=", str(page_count_f001)])
  
  report_f001 = requests.get(request_url_f001)
  
  xml_file_name = mainDir + audit_report_list_xml_dir + "f001_" + corp_code_f001 + ".xml"
  
  with open(xml_file_name, "wb") as file:
      file.write(report_f001.content)
  
  time.sleep(time_delay_f001 + random.uniform(0, 1) * 2)

