# 혹시 몰라서 같이 업로드 합니다.


#### 파일 정제 ####
#### ___ 1) A001 ####
listt = list.files(path = "doc_list_A001/",
                   full.names = TRUE)

head(listt)

dir.create(path = "doc_list_A001_codes",
           showWarnings = FALSE)
for(n in 1:length(listt)){
  # n = 272
  doc = read_html(listt[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_codelist
  if(!is.null(df_codelist[1, "rcept_no"])){
    df_codelist = df_codelist[grep(pattern = "사업보고서", df_codelist$report_nm), ]
    
    if(nrow(df_codelist) >= 1){
      print(n)
      print(df_codelist[1, ])
      write.csv(df_codelist, paste0("doc_list_A001_codes/doc_list_parsed_", df_codelist[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}

#### ___ 2) F001 ####
listt = list.files(path = "doc_list_F001/",
                   full.names = TRUE)

head(listt)

dir.create(path = "doc_list_F001_codes",
           showWarnings = FALSE)
for(n in 1:length(listt)){
  # n = 1
  doc = read_html(listt[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_codelist
  if(!is.null(df_codelist[1, "rcept_no"])){
    if(nrow(df_codelist) >= 1){
      print(n)
      print(df_codelist[1, ])
      write.csv(df_codelist, paste0("doc_list_F001_codes/doc_list_parsed_", df_codelist[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}



#### 다운받기 A001 ####
source("00_environment.R", encoding = "UTF-8")
code_list = read.csv("codelist_parsed.csv")
head(code_list)

# code_list[grep(pattern = "삼성", code_list$corp_name), ]

date_begin = "19800101"
date_end = gsub(pattern = "[^0-9]", replacement = "", x = Sys.Date())
last_reprt_at = "Y"
doc_type = "A"
doc_type_detail = "A001"

start = 1

for(n in start:39999){
  print(n)
  # n = 1
  # corp_code = "00126186"
  corp_code = sprintf(fmt = "%08d", code_list[n, "corp_code"])
  corp_name = code_list[n, "corp_name"]
  
  url = paste0("https://opendart.fss.or.kr/api/list.xml?",
               "&crtfc_key=", Sys.getenv("key"),
               "&corp_code=", corp_code,
               "&bgn_de=", date_begin,
               "&end_de=", date_end,
               "&last_reprt_at", last_reprt_at,
               "&pblntf_ty=", doc_type,
               "&pblntf_detail_ty=", doc_type_detail,
               "&page_count=", 100)
  
  doc = read_html(url, encoding = "UTF-8")
  write_xml(doc, paste0("doc_list_A001/doc_list_A001_", corp_code, ".xml"), encoding = "UTF-8")
  closeAllConnections()
  Sys.sleep(5 + runif(1) * 2)
}

#### 다운받기 F001 ####
source("00_environment.R", encoding = "UTF-8")
code_list = read.csv("codelist_parsed.csv")
head(code_list)

date_begin = "19800101"
date_end = gsub(pattern = "[^0-9]", replacement = "", x = Sys.Date())
last_reprt_at = "Y"
doc_type = "F"
doc_type_detail = "F001"


for(n in 1:39999){
  print(n)
  # n = 1
  # corp_code = "00126186"
  corp_code = sprintf(fmt = "%08d", code_list[n, "corp_code"])
  corp_name = code_list[n, "corp_name"]
  
  url = paste0("https://opendart.fss.or.kr/api/list.xml?",
               "&crtfc_key=", Sys.getenv("key"),
               "&corp_code=", corp_code,
               "&bgn_de=", date_begin,
               "&end_de=", date_end,
               "&last_reprt_at", last_reprt_at,
               "&pblntf_ty=", doc_type,
               "&pblntf_detail_ty=", doc_type_detail,
               "&page_count=", 100)
  
  doc = read_html(url, encoding = "UTF-8")
  write_xml(doc, paste0("doc_list_F001/doc_list_F001_", corp_code, ".xml"), encoding = "UTF-8")
  closeAllConnections()
  Sys.sleep(5 + runif(1) * 2)
}



#### 5. 사업보고서의 감사보고서 ####
#### ___ 1) pdf ####
source("00_environment.R", encoding = "UTF-8")
listt = list.files(path = "doc_list_A001_codes/",
                   full.names = TRUE)
head(listt)

url_base = "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
url_base_pdf = "http://dart.fss.or.kr/pdf/download/pdf.do?"

for(n_file in 1:10000){
  # n_file = 1
  df_code = read.csv(listt[n_file])
  df_code[, "year"] = as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  df_code = df_code[df_code$year >= 2014, ]
  print(n_file)
  
  if(nrow(df_code) > 0){
    corp_code = sprintf(fmt = "%08d", df_code[1, "corp_code"])
    
    path_dir = paste0("doc_list_F001_pdf_download/corp_no_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_row in 1:nrow(df_code)){
      # n_row = 1
      doc_no = as.character(df_code[n_row, "rcept_no"])
      url = paste0(url_base, doc_no)
      
      doc = read_html(url, encoding = "UTF-8")
      doc %>% 
        html_nodes(xpath = "//*/select[@id='att']") %>% 
        html_children() -> doc_sub_list
      
      doc_sub_list %>% html_attr(name = "value") -> doc_sub_list_attrs
      doc_sub_list %>% html_text() -> doc_sub_list_texts
      
      url_doc_no = doc_sub_list_attrs[grep(pattern = "감사보고서", doc_sub_list_texts)][1]
      url_doc_no = gsub(pattern = "No", replacement = "_no", url_doc_no)
      url_doc = paste0(url_base_pdf, url_doc_no)
      download.file(url = url_doc, 
                    destfile =  paste0(path_dir, "/doc_A001_", corp_code, "_", df_code[n_row, "year"], ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(1 + runif(1) * 2)
    } 
  }
}
#### ___ 2) xml ####
source("00_environment.R", encoding = "UTF-8")
listt = list.files(path = "doc_list_A001_codes/",
                   full.names = TRUE)
head(listt)

for(n_file in 1:length(listt)){
  # n_file = 1
  df_code = read.csv(listt[n_file])
  df_code[, "year"] = as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  # df_code = df_code[df_code$year >= 2014, ]
  print(df_code[1, ])
  
  corp_code = sprintf(fmt = "%08d", df_code[1, "corp_code"])
  
  path_dir = paste0("doc_list_A001_xml_download/corp_no_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  for(n_row in 1:nrow(df_code)){
    # n_row = 1
    recept_no = as.character(df_code[n_row, "rcept_no"])
    
    url_doc = paste0("https://opendart.fss.or.kr/api/document.xml?",
                     "&crtfc_key=", key1,
                     "&rcept_no=", recept_no)
    # url_doc
    dir_name = paste0("doc_", recept_no)
    dir_path = paste("doc_list", dir_name, sep = "/")
    dir.create(path = dir_path,
               showWarnings = FALSE)
    
    zip_path = paste(dir_path, "doc.zip", sep = "/")
    download.file(url = url_doc, destfile = zip_path,
                  mode = "wb", quiet = TRUE)
    unzip(zipfile = zip_path, exdir = dir_path, overwrite = TRUE)
    file.remove(zip_path)
    
    Sys.sleep(0.5 + runif(1))
    Sys.sleep(1 + runif(1) * 2)
  }
}



#### 6. 감사보고서 ####
#### ___ 1) pdf ####
source("00_environment.R", encoding = "UTF-8")

library(rvest)
library(stringi)
listt = list.files(path = "doc_list_F001_codes/",
                   full.names = TRUE)
head(listt)

url_base = "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
url_base_pdf = "http://dart.fss.or.kr/pdf/download/pdf.do?"

for(n_file in 35202:40000){
  # n_file = 1
  df_code = read.csv(listt[n_file])
  df_code[, "year"] = as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  df_code = df_code[df_code$year >= 2014, ]
  print(n_file)
  
  if(nrow(df_code) > 0){
    corp_code = sprintf(fmt = "%08d", df_code[1, "corp_code"])
    
    path_dir = paste0("doc_list_F001_pdf_download/corp_no_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_row in 1:nrow(df_code)){
      # n_row = 1
      doc_no = as.character(df_code[n_row, "rcept_no"])
      url = paste0(url_base, doc_no)
      
      doc = read_html(url, encoding = "UTF-8")
      doc %>% 
        html_nodes(xpath = "//*/a[@href='#download']") %>% 
        html_attr(name = "onclick") %>%
        stri_extract(regex = "\\'[0-9]{6,8}\\'") %>% 
        gsub(pattern = "[^0-9]", replacement = "") -> doc_dcm_no
      
      url_pdf = paste0(url_base_pdf, "rcp_no=", doc_no, "&dcm_no=", doc_dcm_no)
      download.file(url = url_pdf,
                    destfile =  paste0(path_dir, "/doc_F001_", corp_code, "_", df_code[n_row, "year"], ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(1.2 + runif(1) * 2)
    } 
  }
}
#### ___ 2) xml ####
source("00_environment.R", encoding = "UTF-8")
# setwd("~/06_outsourcing/crawling_woojune")
# getwd()
# library(stringi)
listt = list.files(path = "doc_list_F001_codes/",
                   full.names = TRUE)
head(listt)
length(listt)

for(n_file in 1:10000){
  # n_file = 1
  df_code = read.csv(listt[n_file])
  df_code[, "year"] = as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  print(n_file)
  
  corp_code = sprintf(fmt = "%08d", df_code[1, "corp_code"])
  
  path_dir = paste0("doc_list_F001_xml_download/corp_no_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  for(n_row in 1:nrow(df_code)){
    # n_row = 1
    recept_no = as.character(df_code[n_row, "rcept_no"])
    
    url_doc = paste0("https://opendart.fss.or.kr/api/document.xml?",
                     "&crtfc_key=", key8,
                     "&rcept_no=", recept_no)
    
    zip_path = paste(path_dir, "doc.zip", sep = "/")
    download.file(url = url_doc, destfile = zip_path,
                  mode = "wb", quiet = TRUE)
    unzip(zipfile = zip_path, exdir = path_dir, overwrite = TRUE)
    file.remove(zip_path)
    
    Sys.sleep(0.5 + runif(1))
  }
}