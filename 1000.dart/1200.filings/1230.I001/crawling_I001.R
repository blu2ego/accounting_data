#########################################################
## download filings list
#########################################################

# set working directory
setwd(file.path(data_dir, corps_code_parsed_csv_dir))

corps_code <- read.csv("~/data2/ward_data/results/dart/corps_code/csv/corps_code.csv", header = T)

library(dplyr)
corps_code %>% filter(!is.na(stock_code)) -> listed_corps

bgn_de <- "19800101"
end_de <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt <- "N"
pblntf_detail_ty_I001 <- "I001"
page_no <- "n"
page_count <- 100

start <- 1
end <- nrow(listed_corps)
time_delay <- 5

for(corp in start:end){
  print(corp)
  corp_code <- sprintf(fmt = "%08d", listed_corps[corp, "corp_code"])
  corp_name <- listed_corps[corp, "corp_name"]
  
  request_url_I001 <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                             "&crtfc_key=", key_dart,
                             "&corp_code=", corp_code,
                             "&bgn_de=", bgn_de,
                             "&end_de=", end_de,
                             "&last_reprt_at", last_reprt,
                             "&pblntf_detail_ty=", pblntf_detail_ty_I001,
                             "&page_count=", page_count)
  
  filing_I001 <- read_html(request_url_I001, encoding = "UTF-8")
  write_xml(filing_I001, 
            paste0(data_dir, I001_xml_dir, "I001_", corp_code, ".xml"), 
            encoding = "UTF-8")
  
  Sys.sleep(time_delay + runif(1) * 2)
}


# set working directory
setwd(file.path(data_dir, I001_xml_dir))

list_I001s_xml <- list.files()

for(I001s in 1:length(list_I001s_xml)){
  list_I001 <- read_html(list_I001s_xml[1], encoding = "UTF-8")
  list_I001 %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> list_I001_parsed
  
  if(!is.null(list_I001_parsed[1, "rcept_no"])){
    list_I001_parsed <- list_I001_parsed[grep(pattern = "지속가능", list_I001_parsed$report_nm), ]
    
    if(nrow(list_I001_parsed) >= 1){
      print(n_I001s)
      write.csv(list_I001_parsed, 
                paste0(data_dir, I001_csv_dir, "I001_parsed_", list_I001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
