exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())  

# set working directory
os.chdir(mainDir + corps_code_unzip_Dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

file_name_unzip = "corps_code_" + base_date + ".xml"

corps_code = open(file = file_name_unzip, mode = "r", encoding = "UTF-8")
corps_code = BeautifulSoup(corps_code)

corps_code_list = corps_code.find_all("list")

df_corps_code = pd.DataFrame()
for corps_code_element in fun_code_list:
  df_corps_code_sub = pd.DataFrame([corps_code_element.text.split("\n")[1:-1]])  
  df_corps_code = pd.concat([df_corps_code, df_corps_code_sub])
  
df_corps_code.columns = ["corp_code", "corp_name", "stock_code", "modify_date"]
df_corps_code.to_csv("../csv/corps_code_parsed_" + base_date + ".csv", index = False)
