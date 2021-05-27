#######################################################
## /ward/crawling/dart/r/cdr07_downloader_f001_zip.R ##
#######################################################

# set working directory
setwd(file.path(main_dir, audit_report_list_csv_dir))

# importing list of F001 files
list_f001s_csv <- list.files()

# download F001 files
start_f001 <- 1
end_f001 <- length(list_f001s_csv)
time_delay_f001 <- 1

for(n_f001s in start_f001:end_f001){
  list_f001 <- read.csv(list_f001s_csv[n_f001s], header = T) 
  list_f001[, "year"] <- as.numeric(stri_extract(str = list_f001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_f001 <- sprintf(fmt = "%08d", list_f001[1, "corp_code"])
  
  path_dir <- paste0(main_dir, audit_report_zip, "corp_code_", corp_code_f001)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  print(n_f001s)
  
  for(n_f001 in 1:nrow(list_f001)){
    recept_no <- as.character(list_f001[n_f001, "rcept_no"])
    
    request_url_f001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", list_f001[n_f001, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = request_url_f001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_f001 + runif(1) * 2)
  }
}