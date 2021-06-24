############################################################
## download A001(정기공시, 사업보고서) filings as XMLs
############################################################

# set working directory
setwd(file.path(data_dir, corps_code_parsed_csv_dir))

corps_code <- read.csv(paste0("corps_code_", date, ".csv"), header = T)

listed_corps_idx <- !is.na(corps_code$stock_code)
listed_corps <- corps_code[listed_corps_idx, ]

date_begin_a001 <- "19800101"
date_end_a001 <- gsub(pattern = "[^0-9]", replacement = "", x = date)
last_reprt_at_a001 <- "Y"
pblntf_ty_a001 <- "A"
pblntf_detail_ty_a001 <- "A001"
page_count_a001 <- 100
corp_cls <- "Y"

start_a001 <- 1
end_a001 <- nrow(listed_corps)
time_delay_a001 <- 5

for(n_corps in start_a001:end_a001){
  print(n_corps)
  corp_code_a001 <- sprintf(fmt = "%08d", listed_corps[n_corps, "corp_code"])
  corp_name_a001 <- listed_corps[n_corps, "corp_name"]
  
  request_url_a001 <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                             "&crtfc_key=", key_dart,
                             "&corp_code=", corp_code_a001,
                             "&bgn_de=", date_begin_a001,
                             "&end_de=", date_end_a001,
                             "&last_reprt_at", last_reprt_at_a001,
                             "&pblntf_ty=", pblntf_ty_a001,
                             "&pblntf_detail_ty=", pblntf_detail_ty_a001,
                             "&page_count=", page_count_a001,
                             "corp_cls=", corp_cls)
  
  a001 <- read_html(request_url_a001, encoding = "UTF-8")
  write_xml(a001, 
            paste0(data_dir, filing_A001_xml_dir, corp_code_a001, "_", date, ".xml"), 
            encoding = "UTF-8")
  
  Sys.sleep(time_delay_a001 + runif(1) * 2)
}

############################################################
## parse A001 filings as CSVs
############################################################


# set working directory
setwd(file.path(data_dir, filing_A001_xml_dir))

list_a001s_xml <- list.files()

for(n_a001s in 1:length(list_a001s_xml)){
  list_a001 <- read_html(list_a001s_xml[n_a001s], encoding = "UTF-8")
  list_a001 %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> list_a001_parsed
  
  if(!is.null(list_a001_parsed[1, "rcept_no"])){
    list_a001_parsed <- list_a001_parsed[grep(pattern = "사업보고서", list_a001_parsed$report_nm), ]
    
    if(nrow(list_a001_parsed) >= 1){
      print(n_a001s)
      write.csv(list_a001_parsed, 
                paste0(main_dir, biz_report_list_csv_dir, "init_date/a001_parsed_", list_a001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
