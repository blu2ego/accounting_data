exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(mainDir + corps_code_parsed_csv_Dir)

# loading required libraries
import pandas as pd
from numpy import arange
import requests
import random

corps_code_a001 = pd.read_csv("corps_code_parsed_" + base_date + ".csv")

os.chdir("../../..")

date_begin_a001 = "19800101"
date_end_a001 = base_date.replace("-", "")
last_reprt_at_a001 = "Y"
pblntf_ty_a001 = "A"
pblntf_detail_ty_a001 = "A001"
page_count_a001 = 100

# start_a001 = 0
# end_a001 = len(corps_code_a001) - 1
start_a001 = 30000
end_a001 = 30010
time_delay_a001 = 1

for i in arange(start_a001, end_a001):
  print(i)
  corp_code_a001 = "{:08}".format(corps_code_a001.loc[i, "corp_code"])
  corp_name_a001 = corps_code_a001.loc[i, "corp_name"]
  
  request_url_a001 = "".join(["https://opendart.fss.or.kr/api/list.xml?", 
                              "&crtfc_key=", key_dart,
                              "&corp_code=", corp_code_a001,
                              "&bgn_de=", date_begin_a001,
                              "&end_de=", date_end_a001,
                              "&last_reprt_at", last_reprt_at_a001,
                              "&pblntf_ty=", pblntf_ty_a001,
                              "&pblntf_detail_ty=", pblntf_detail_ty_a001,
                              "&page_count=", str(page_count_a001)])
  
  report_a001 = requests.get(request_url_a001)
  
  xml_file_name = mainDir + biz_report_list_xml_Dir + "a001_" + corp_code_a001 + ".xml"
  
  with open(xml_file_name, "wb") as file:
      file.write(report_a001.content)
  
  time.sleep(time_delay_a001 + random.uniform(0, 1) * 2)
