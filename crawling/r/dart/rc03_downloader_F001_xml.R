source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corps_code <- read.csv(paste0(mainDir, corps_code_parsed_Dir_csv, "corps_code_parsed_", base_date, ".csv"), header = T)

date_begin <- "19800101"
date_end <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt_at <- "Y"
pblntf_ty <- "F"
pblntf_detail_ty <- "F001"

start <- 3904 # 왜 3904부터 시작?
time_delay <- 5

for(i in start:nrow(corps_code)){
  print(i)
  corp_code <- sprintf(fmt = "%08d", corps_code[i, "corp_code"])
  corp_name <- corps_code[i, "corp_name"]
  
  request_url <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                        "&crtfc_key=", "680d964f06e9a576942d805ad2ba2a38d7e5e378",
                        "&corp_code=", corp_code,
                        "&bgn_de=", date_begin,
                        "&end_de=", date_end,
                        "&last_reprt_at", last_reprt_at,
                        "&pblntf_ty=", pblntf_ty,
                        "&pblntf_detail_ty=", pblntf_detail_ty,
                        "&page_count=", 100)
  
  report <- read_html(request_url, encoding = "UTF-8")
  write_xml(report, paste0(mainDir, report_download_Dir_xml, "audit_report_", corp_code, ".xml"), encoding = "UTF-8")
  
  Sys.sleep(time_delay + runif(1) * 2)
}
