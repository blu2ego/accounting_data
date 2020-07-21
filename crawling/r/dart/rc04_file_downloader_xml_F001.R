source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corps_code <- read.csv("~/projects/wrangling_accounting_related_data/results/corp_code/corps_code_parsed_2020-07-21.csv", header = T)

date_begin <- "19800101"
date_end <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt_at <- "Y"
doc_type <- "F"
doc_type_detail <- "F001"

start <- 3904
time_delay <- 5

df_report <- data.frame()
for(i in start:nrow(corps_code)){
  print(i)
  corp_code <- sprintf(fmt = "%08d", corps_code[i, "corp_code"])
  corp_name <- corps_code[i, "corp_name"]
  
  url <- paste0("https://opendart.fss.or.kr/api/list.xml?",
               "&crtfc_key=", key_dart,
               "&corp_code=", corp_code,
               "&bgn_de=", date_begin,
               "&end_de=", date_end,
               "&last_reprt_at", last_reprt_at,
               "&pblntf_ty=", doc_type,
               "&pblntf_detail_ty=", doc_type_detail,
               "&page_count=", 100)
  
  report <- read_html(url, encoding = "UTF-8")
  write_xml(report, paste0(mainDir, xmls_download_Dir, "/", corp_code, ".xml"), encoding = "UTF-8")
  
  Sys.sleep(time_delay + runif(1) * 2)
}

