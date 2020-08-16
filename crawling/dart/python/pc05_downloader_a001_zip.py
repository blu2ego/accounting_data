# set working directory
os.chdir(main_dir + biz_report_list_csv_dir)

# importing list of A001 files
list_a001s_csv = os.listdir()

# download A001 files
start_a001 = 0
end_a001 = len(list_a001s_csv)
time_delay_a001 = 1

for n_a001s in arange(start_a001, end_a001):
  list_a001 = pd.read_csv(list_a001s_csv[n_a001s], na_filter = False)
  list_a001["year"] = list_a001["report_nm"].str.extract(pat = "([0-9]{4})")
  
  corp_code_a001 = "{:08}".format(list_a001.loc[0, "corp_code"]) 
   
  path_dir = "../../../../" + main_dir + biz_report_zip + "corp_code_" + corp_code_a001
  os.makedirs(path_dir)
  
  print(n_a001s)

  for n_a001 in range(len(list_a001)):
    rcept_no = list_a001.loc[n_a001, "rcept_no"].astype("str")
    
    request_url_a001 = "".join(["https://opendart.fss.or.kr/api/document.xml?",
                                "&crtfc_key=", key_dart,
                                "&rcept_no=", rcept_no])
    
    report_a001 = requests.get(request_url_a001)
     
    path_zip = path_dir + "/" + list_a001.loc[n_a001, "year"] + "_" + rcept_no + ".zip"

    with open(path_zip, "wb") as file:
      file.write(report_a001.content)

  time.sleep(time_delay_a001 + random.uniform(0, 1) * 2)
