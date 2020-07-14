source("~/projects/wrangling_accounting_related_data/crawling/R/rc01_environment.R", encoding = "UTF-8")

code_list <- read.csv("codelist_parsed.csv")

date_begin <- "19800101"
date_end = gsub(pattern <- "[^0-9]", replacement = "", x = Sys.Date())
last_reprt_at <- "Y"
doc_type <- "F"
doc_type_detail <- "F001"

# start = 1
# start = length(list.files(path = "html/"))
start <- 3904

df_report <- data.frame()
for(n in start:nrow(code_list)){
  print(n)
  # n = 1
  # corp_code = "00126186"
  corp_code <- sprintf(fmt = "%08d", code_list[n, "corp_code"])
  corp_name <- code_list[n, "corp_name"]
  
  url <- paste0("https://opendart.fss.or.kr/api/list.xml?",
               "&crtfc_key=", Sys.getenv("key"),
               "&corp_code=", corp_code,
               "&bgn_de=", date_begin,
               "&end_de=", date_end,
               "&last_reprt_at", last_reprt_at,
               "&pblntf_ty=", doc_type,
               # "&pblntf_detail_ty=", doc_type_detail,
               "&page_count=", 100)
  
  doc <- read_html(url, encoding = "UTF-8")
  write_xml(doc, paste0("html/doc_list_", corp_code, ".xml"), encoding = "UTF-8")
  
  closeAllConnections()
  Sys.sleep(5 + runif(1) * 2)
}
