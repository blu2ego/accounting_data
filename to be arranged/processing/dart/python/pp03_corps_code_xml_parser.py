# set working directory
os.chdir(main_dir + corps_code_unzip_dir)

# loading required libraries
from bs4 import BeautifulSoup
import pandas as pd

file_name_unzip = "corps_code_" + base_date + ".xml"

corps_code = open(file = file_name_unzip, mode = "r", encoding = "UTF-8")
corps_code = BeautifulSoup(corps_code)

corps_code_list = corps_code.find_all("list")

df_corps_code = pd.DataFrame()
for corps_code_element in corps_code_list:
  df_corps_code_sub = pd.DataFrame([corps_code_element.text.split("\n")[1:-1]])  
  df_corps_code = pd.concat([df_corps_code, df_corps_code_sub])
  
df_corps_code.columns = ["corp_code", "corp_name", "stock_code", "modify_date"]

file_name_parsed = "corps_code_parsed_" + base_date + ".csv"
df_corps_code.to_csv("../csv/" + file_name_parsed, index = False)
