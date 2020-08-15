# set working directory
os.chdir(main_dir + audit_report_list_csv_dir)

# importing list of F001 files
list_f001s_csv = os.listdir()

# download F001 files
start_f001 = 1
end_f001 = len(list_f001s_csv)
time_delay_f001 = 1

for n_f001s in arange(start_f001, end_f001):
  list_f001 = pd.read_csv(lists_f001[n_f001s], na_filter = False)
  list_f001["year"] = list_f001["report_nm"].str.extract(pat = "([0-9]{4})")
  
  corp_code_f001 = "{:08}".format(list_f001.loc[0, "corp_code"]) 
   
  path_dir = "../../../../" + main_dir + audit_report_zip + "corp_code_" + corp_code_f001
  os.makedirs(path_dir)
  
  print(n_f001s)

  for n_f001 in range(len(list_f001)):
    rcept_no = list_f001.loc[n_f001, "rcept_no"].astype("str")
    request_url_f001 = "".join(["https://opendart.fss.or.kr/api/document.xml?",
                                "&crtfc_key=", key_dart,
                                "&rcept_no=", rcept_no])
    
    report_f001 = requests.get(request_url_f001)
     
    path_zip = path_dir + "/" + list_f001.loc[n_f001, "year"] + "_" + rcept_no + ".zip"

    with open(path_zip, "wb") as file:
      file.write(report_f001.content)

  time.sleep(time_delay_f001 + random.uniform(0, 1) * 2)
