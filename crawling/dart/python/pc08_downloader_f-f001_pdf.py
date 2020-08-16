# set working directory
os.chdir(main_dir + audit_report_list_csv_dir)

# loading required libraries
from bs4 import BeautifulSoup

# importing list of F001 files
list_f001s_csv = os.listdir()

request_url_base_f001 = "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf = "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_f001 = 2015
value_filter_year_max_f001 = int(base_date[:4])

start_f001 = 0
end_f001 = len(list_f001s_csv)
time_delay_f001 = 1

for n_f001s in arange(start_f001, end_f001):
  # n_f001s = 0
  list_f001 = pd.read_csv(list_f001s_csv[n_f001s], encoding = "CP949")
  list_f001["year"] = list_f001["rcept_dt"].astype("str").str.slice(start = 0, stop = 4).astype("int")
  list_f001 = list_f001.loc[(list_f001["year"] <= value_filter_year_max_f001) & (list_f001["year"] >= value_filter_year_min_f001), ]
  print(n_f001s)

  if len(list_f001) > 0:
    corp_code_f001 = "{:08}".format(list_f001.loc[0, "corp_code"]) 
    
    path_dir = main_dir + audit_report_pdf_from_aud + "corp_code_" + corp_code_f001 + "/"
    os.makedirs(path_dir)
    
    for n_f001 in 0:len(list_f001):
      # print(n_f001)
      rcept_no_f001 = list_f001.loc[n_f001, "rcept_no"].astype("str")
      request_url_f001 = request_url_base_f001 + rcept_no_f001
      
      f001 = requests.get(request_url_f001)
      f001 = BeautifulSoup(f001.content, from_encoding = "UTF-8")
      
      dcm_no = f001.select("a[href='#download']")[0].attrs["onclick"].split(sep = ", \'")[1][:7]
      
      url_f001 = request_url_base_pdf + "rcp_no=" + rcept_no_f001 + "&dcm_no=" + dcm_no
      
      path_pdf = path_dir + "/f001_" + corp_code_f001 + "_" + rcept_no_f001 + "_" + dcm_no + ".pdf"
      
      downloaded_file_path = download(url_f001, path_pdf)
      
      time.sleep(time_delay_f001 + random.uniform(0, 1) * 2)
