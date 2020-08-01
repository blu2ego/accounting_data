############################################################
## /ward/crawling/dart/r/cdr04_downloader_f001_list_xml.R ##
############################################################

# set working directory
setwd(file.path(main_dir, corps_code_parsed_csv_dir))

corps_code_f001 <- read.csv(paste0("corps_code_parsed_", base_date, ".csv"), header = T)

date_begin_f001 <- "19800101"
date_end_f001 <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt_at_f001 <- "Y"
pblntf_ty_f001 <- "F"
pblntf_detail_ty_f001 <- "F001"
page_count_f001 <- 100

start_f001 <- 1
end_f001 <- nrow(corps_code_f001)
time_delay_f001 <- 5

for(n_corps in start_f001:end_f001){
  print(n_corps)
  corp_code_f001 <- sprintf(fmt = "%08d", corps_code_f001[n_corps, "corp_code"])
  corp_name_f001 <- corps_code_f001[n_corps, "corp_name"]
  
  request_url_f001 <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                             "&crtfc_key=", key_dart,
                             "&corp_code=", corp_code_f001,
                             "&bgn_de=", date_begin_f001,
                             "&end_de=", date_end_f001,
                             "&last_reprt_at", last_reprt_at_f001,
                             "&pblntf_ty=", pblntf_ty_f001,
                             "&pblntf_detail_ty=", pblntf_detail_ty_f001,
                             "&page_count=", page_count_f001)
  
  report_f001 <- read_html(request_url_f001, encoding = "UTF-8")
  write_xml(report_f001, 
            paste0(main_dir, audit_report_list_xml_dir, "f001_", corp_code_f001, ".xml"), 
            encoding = "UTF-8")
  
  Sys.sleep(time_delay_f001 + runif(1) * 2)
}
