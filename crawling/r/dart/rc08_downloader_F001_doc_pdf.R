source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

list_f001 <- list.files(path = audit_report_list_csv_Dir,
                        full.names = TRUE)

url_base <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_f001 <- 2014
value_filter_year_max_f001 <- as.numeric(substr(Sys.Date(), start = 1, stop = 4))

start_f001 <- 1
end_f001 <- length(list_f001)
time_delay_f001 <- 1

for(n_file in start_f001:end_f001){
  df_code <- read.csv(list_f001[n_file])
  df_code[, "year"] <- as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  df_code <- df_code[(df_code$year <= value_filter_year_max_f001) & (df_code$year >= value_filter_year_min_f001), ]
  print(n_file)
  
  if(nrow(df_code) > 0){
    corp_code <- sprintf(fmt = "%08d", df_code[1, "corp_code"])
    
    path_dir <- paste0(biz_report_pdf, "corp_no_", corp_code)
    dir.create(path <- path_dir, showWarnings = FALSE)
    
    for(n_row in 1:nrow(df_code)){
      doc_no <- as.character(df_code[n_row, "rcept_no"])
      url <- paste0(url_base, doc_no)
      
      doc <- read_html(url, encoding = "UTF-8")
      doc %>% 
        html_nodes(xpath = "//*/a[@href='#download']") %>% 
        html_attr(name = "onclick") %>%
        stri_extract(regex = "\\'[0-9]{6,8}\\'") %>% 
        gsub(pattern = "[^0-9]", replacement = "") -> dcm_no
      
      url_doc <- paste0(url_base_pdf, "rcp_no=", doc_no, "&dcm_no=", dcm_no)
      
      download.file(url = url_doc, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", doc_no, "_", dcm_no, ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(time_delay_f001 + runif(1) * 2)
    } 
  }
}
