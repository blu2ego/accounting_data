source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, audit_report_list_csv_Dir))

lists_f001 <- list.files()

# download F001 files
start_f001 <- 1
end_f001 <- length(lists_f001)
time_delay_f001 <- 1

for(r in start_f001:end_f001){
  list_f001 <- read.csv(list_f001[r])
  list_f001[, "year"] <- as.numeric(stri_extract(str = list_f001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_f001 <- sprintf(fmt = "%08d", list_f001[1, "corp_code"])
  
  path_dir <- paste0(mainDir, audit_report_zip, "corp_code_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  for(s in 1:nrow(list_f001)){
    recept_no <- as.character(list_f001[s, "rcept_no"])
    
    request_url_f001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", list_f001[s, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = request_url_f001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_f001 + runif(1) * 2)
  }
}
