#########################################################
## /ward/crawling/dart/r/cdr08_downloader_f-f001_pdf.R ##
#########################################################

# set working directory
setwd(file.path(main_dir, audit_report_list_csv_dir))

# importing list of A001 files
list_f001s_csv <- list.files()

request_url_base_f001 <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_f001 <- 2014
value_filter_year_max_f001 <- as.numeric(substr(base_date, start = 1, stop = 4))

start_f001 <- 1
end_f001 <- length(list_f001s_csv)
time_delay_f001 <- 1

for(n_f001s in start_f001:end_f001){
  list_f001 <- read.csv(list_f001s_csv[n_f001s], header = T)
  list_f001[, "year"] <- as.numeric(stri_extract(str = list_f001$report_nm, regex = "[0-9]{4}"))
  list_f001 <- list_f001[(list_f001$year <= value_filter_year_max_f001) & (list_f001$year >= value_filter_year_min_f001), ]
  print(n_f001s)
  
  if(nrow(list_f001) > 0){
    corp_code <- sprintf(fmt = "%08d", list_f001[1, "corp_code"]) # corp_code 기준으로 디렉토리 만들기 위한 작업
    
    path_dir <- paste0(main_dir, audit_report_pdf_from_aud, "corp_code_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_f001 in 1:nrow(list_f001)){
      rcept_no_f001 <- as.character(list_f001[n_f001, "rcept_no"])
      request_url_f001 <- paste0(request_url_base_f001, rcept_no_f001)
      
      f001 <- read_html(request_url_f001, encoding = "UTF-8")
      f001 %>% 
        html_nodes(xpath = "//*/a[@href='#download']") %>% 
        html_attr(name = "onclick") %>%
        stri_extract(regex = "\\'[0-9]{6,8}\\'") %>% 
        gsub(pattern = "[^0-9]", replacement = "") -> dcm_no
      
      url_f001 <- paste0(request_url_base_pdf, "rcp_no=", rcept_no_f001, "&dcm_no=", dcm_no)
      
      download.file(url = url_f001, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", rcept_no_f001, "_", dcm_no, ".pdf"),
                    quiet = TRUE, 
                    mode = "wb")
      
      Sys.sleep(time_delay_f001 + runif(1) * 2)
    } 
  }
}