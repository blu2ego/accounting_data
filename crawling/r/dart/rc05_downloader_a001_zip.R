source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, biz_report_list_csv_Dir))

# importing list of A001 files
lists_a001 <- list.files()

# download A001 files
start_a001 <- 1
end_a001 <- length(lists_a001)
time_delay_a001 <- 1

for(n_file in start_a001:end_a001){
  list_a001 <- read.csv(lists_a001[n_file])
  list_a001[, "year"] <- as.numeric(stri_extract(str = list_a001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_a001 <- sprintf(fmt = "%08d", list_a001[1, "corp_code"])
  
  path_dir <- paste0(mainDir, biz_report_zip, "corp_code_", corp_code_a001)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  print(n_file)
  
  for(n_row in 1:nrow(list_a001)){
    rcept_no <- as.character(list_a001[n_row, "rcept_no"])
    
    request_url_a001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", rcept_no)
    
    path_zip <- paste(path_dir, "/", list_a001[n_row, "year"], "_", rcept_no, ".zip", sep = "")
    
    download.file(url = request_url_a001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_a001 + runif(1) * 2)
  }
}

