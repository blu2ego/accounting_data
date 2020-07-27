source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

list_a001 <- list.files(path = biz_report_list_csv_Dir,
                        full.names = TRUE)

url_base <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_a001 <- 2014
value_filter_year_max_a001 <- as.numeric(substr(Sys.Date(), start = 1, stop = 4))

start_a001 <- 1
end_a001 <- length(list_a001)
time_delay_a001 <- 1

for(n_file in start_a001:end_a001){
  df_code <- read.csv(list_a001[n_file])
  df_code[, "year"] <- as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  df_code <- df_code[(df_code$year <= value_filter_year_max_a001) & (df_code$year >= value_filter_year_min_a001), ]
  print(n_file)
  
  if(nrow(df_code) > 0){
    corp_code <- sprintf(fmt = "%08d", df_code[1, "corp_code"])
    
    path_dir <- paste0(audit_report_pdf, "corp_no_", corp_code)
    dir.create(path <- path_dir, showWarnings = FALSE)
    
    for(n_row in 1:nrow(df_code)){
      doc_no <- as.character(df_code[n_row, "rcept_no"])
      url <- paste0(url_base, doc_no)
      
      doc <- read_html(url, encoding = "UTF-8")
      doc %>% 
        html_nodes(xpath = "//*/select[@id='att']") %>% 
        html_children() -> doc_sub_list
      
      doc_sub_list %>% html_attr(name = "value") -> doc_sub_list_attrs
      doc_sub_list %>% html_text() -> doc_sub_list_texts
      
      url_doc_no <- doc_sub_list_attrs[grep(pattern = "감사보고서", doc_sub_list_texts)][1]
      url_doc_no <- gsub(pattern = "No", replacement = "_no", url_doc_no)
      
      dcm_no = gsub(pattern = "^.*?dcm_no=", replacement = "", url_doc_no)
      
      url_doc <- paste0(url_base_pdf, url_doc_no)
      download.file(url = url_doc, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", doc_no, "_", dcm_no, ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(time_delay_a001 + runif(1) * 2)
    } 
  }
}
