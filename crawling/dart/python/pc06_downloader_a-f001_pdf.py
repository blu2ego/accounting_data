# set working directory
os.chdir(main_dir + biz_report_list_csv_dir)

# loading required libraries
from bs4 import BeautifulSoup

# importing list of A001 files
list_a001s_csv = os.listdir()

request_url_base_a001 = "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf = "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_a001 = 2014
value_filter_year_max_a001 = int(base_date[:4])

start_a001 = 0
end_a001 = len(list_a001s_csv)
time_delay_a001 = 1

for n_a001s in start_a001:end_a001:
  list_a001 = pd.read_csv(list_a001s_csv[n_a001s], encoding = "euc-kr")
  # list_a001 = pd.read_csv("doc_list_parsed_00100939.csv", encoding = "euc-kr")
  list_a001["year"] = list_a001["report_nm"].str.extract(pat = "([0-9]{4})").astype("int")
  list_a001 = list_a001.loc[(list_a001["year"] <= value_filter_year_max_a001) & (list_a001["year"] >= value_filter_year_min_a001), ]
  print(n_a001s)
  
  if len(list_a001) > 0:
    corp_code_a001 = "{:08}".format(list_a001.loc[0, "corp_code"])
    
    path_dir = main_dir + audit_report_pdf_from_biz + "corp_code_" + corp_code_a001 + "/"
    os.makedirs(path_dir)
    
    for n_a001 in arange(0, len(list_a001)):
      rcept_no_a001 = list_a001.loc[n_a001, "rcept_no"].astype("str")
      request_url_a001 = request_url_base_a001 + rcept_no_a001
      a001 = requests.get(request_url_a001)
      a001 = BeautifulSoup(a001.content, from_encoding = "UTF-8")
      url_f001_no = a001.select("#att > option:contains('감사보고서')")[0].attrs["value"].replace("No", "_no")
      
      url_f001 = request_url_base_pdf + url_f001_no
      rcept_no_a001 = url_f001_no.split("&")[0].split("=")[1]
      dcm_no = url_f001_no.split("&")[1].split("=")[1]
      
      path_pdf = path_dir + "f001_" + corp_code_a001 + "_" + rcept_no_a001 + "_" + dcm_no + ".pdf"

      downloaded_file_path = download(url_f001, path_pdf)
      
      Sys.sleep(time_delay_a001 + runif(1) * 2)
    } 
  }
}
