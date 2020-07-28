source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, biz_report_list_csv_Dir))

# importing list of A001 files
lists_a001 <- list.files()

request_url_base_a001 <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_a001 <- 2014
value_filter_year_max_a001 <- as.numeric(substr(base_date, start = 1, stop = 4))

start_a001 <- 1
end_a001 <- length(lists_a001)
time_delay_a001 <- 1

for(n_file in start_a001:end_a001){
  list_a001 <- read.csv(lists_a001[n_file], header = T)
  list_a001[, "year"] <- as.numeric(stri_extract(str = list_a001$report_nm, regex = "[0-9]{4}"))
  list_a001 <- list_a001[(list_a001$year <= value_filter_year_max_a001) & (list_a001$year >= value_filter_year_min_a001), ]
  print(n_file)
  
  if(nrow(list_a001) > 0){
    corp_code <- sprintf(fmt = "%08d", list_a001[1, "corp_code"]) # corp_code 기준으로 디렉토리 만들기 위한 작업
    
    path_dir <- paste0(mainDir, biz_report_pdf, "corp_code_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_row in 1:nrow(list_a001)){
      rcept_no_a001 <- as.character(list_a001[n_row, "rcept_no"])
      request_url_a001 <- paste0(request_url_base_a001, rcept_no_a001)
      
      a001 <- read_html(request_url_a001, encoding = "UTF-8")
      a001 %>% 
        html_nodes(xpath = "//*/select[@id='att']") %>% 
        html_children() -> a001_sub_list
      
      a001_sub_list %>% html_attr(name = "value") -> a001_sub_list_attrs
      a001_sub_list %>% html_text() -> a001_sub_list_texts
      
      url_f001_no <- a001_sub_list_attrs[grep(pattern = "감사보고서", a001_sub_list_texts)][1]
      url_f001_no <- gsub(pattern = "No", replacement = "_no", url_f001_no)
      
      dcm_no <- gsub(pattern = "^.*?dcm_no=", replacement = "", url_f001_no)
      
      url_f001 <- paste0(request_url_base_pdf, url_f001_no)
      download.file(url = url_f001, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", rcept_no_a001, "_", dcm_no, ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(time_delay_a001 + runif(1) * 2)
    } 
  }
}
