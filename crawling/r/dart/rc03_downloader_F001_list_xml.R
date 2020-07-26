source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corps_code_f001 <- read.csv(paste0(mainDir, corps_code_parsed_csv_Dir, "corps_code_parsed_", base_date, ".csv"), 
                            header = T)

date_begin_f001 <- "19800101"
date_end_f001 <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt_at_f001 <- "Y"
pblntf_ty_f001 <- "F"
pblntf_detail_ty_f001 <- "F001"

start_f001 <- 1
time_delay_f001 <- 5

for(j in start_f001:nrow(corps_code_f001)){
  print(j)
  corp_code_f001 <- sprintf(fmt = "%08d", corps_code_f001[j, "corp_code"])
  corp_name_f001 <- corps_code_f001[j, "corp_name"]
  
  request_url_f001 <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                             "&crtfc_key=", "680d964f06e9a576942d805ad2ba2a38d7e5e378",
                             "&corp_code=", corp_code_f001,
                             "&bgn_de=", date_begin_f001,
                             "&end_de=", date_end_f001,
                             "&last_reprt_at", last_reprt_at_f001,
                             "&pblntf_ty=", pblntf_ty_f001,
                             "&pblntf_detail_ty=", pblntf_detail_ty_f001,
                             "&page_count=", 100)
  
  report_f001 <- read_html(request_url_f001, encoding = "UTF-8")
  write_xml(report_f001, paste0(mainDir, audit_report_list_xml_Dir, "f001_", corp_code_f001, ".xml"), 
            encoding = "UTF-8")
  
  Sys.sleep(time_delay_f001 + runif(1) * 2)
}
