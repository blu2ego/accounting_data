#######################################################
## /ward/crawling/dart/r/cdr05_downloader_a001_zip.R ##
#######################################################

# set working directory
setwd(file.path(main_dir, biz_report_list_csv_dir, "init_date"))

# importing list of A001 files
list_a001s_csv <- list.files()

# download A001 files
start_a001 <- 1
end_a001 <- length(list_a001s_csv)
time_delay_a001 <- 1

for(n_a001s in start_a001:end_a001){
  list_a001 <- read.csv(list_a001s_csv[n_a001s])
  list_a001[, "year"] <- as.numeric(stri_extract(str = list_a001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_a001 <- sprintf(fmt = "%08d", list_a001[1, "corp_code"])
  
  path_dir <- paste0(main_dir, biz_report_zip, "corp_code_", corp_code_a001)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  print(n_a001s)
  
  for(n_a001 in 1:nrow(list_a001)){
    recept_no <- as.character(list_a001[n_a001, "rcept_no"])
    
    request_url_a001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", list_a001[n_a001, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = request_url_a001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_a001 + runif(1) * 2)
  }
}
