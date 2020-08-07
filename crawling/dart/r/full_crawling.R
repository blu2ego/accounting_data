###############################################
## ward/crawling/dart/r/cdr01_environments.R ##
###############################################

# Setting Global environmentss

# importing dart's key
key_dart <- readLines("~/projects/ward/crawling/sources/key_dart.txt", warn = FALSE)

# loading required libraries
library(rvest)
library(stringi)
library(tidyverse)

# set base date
base_date <- Sys.Date()
base_date <- "2020-07-30"

# set main path
main_dir <- "~/projects/ward/"

# set addtional path and create directories related to corp_code
corps_code_zip_dir        <- "results/dart/corps_code/zip"  
corps_code_unzip_dir      <- "results/dart/corps_code/xml/" 
corps_code_parsed_csv_dir <- "results/dart/corps_code/csv/" 

ifelse(!dir.exists(file.path(main_dir, corps_code_zip_dir)),        dir.create(file.path(main_dir, corps_code_zip_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, corps_code_unzip_dir)),      dir.create(file.path(main_dir, corps_code_unzip_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, corps_code_parsed_csv_dir)), dir.create(file.path(main_dir, corps_code_parsed_csv_dir)), FALSE)

# set addtional path and create directories related to a001
biz_report_list_xml_dir <- file.path("results/dart/biz_report_list/xml/", base_date, "/")
biz_report_list_csv_dir <- file.path("results/dart/biz_report_list/csv/", base_date, "/")
biz_report_zip          <- file.path("results/dart/biz_report/zip/", base_date, "/")

ifelse(!dir.exists(file.path(main_dir, biz_report_list_xml_dir)), dir.create(file.path(main_dir, biz_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_list_csv_dir)), dir.create(file.path(main_dir, biz_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, biz_report_zip)),          dir.create(file.path(main_dir, biz_report_zip)), FALSE)

# set addtional path and create directories related to F001
audit_report_list_xml_dir <- file.path("results/dart/audit_report_list/xml/", base_date, "/")
audit_report_list_csv_dir <- file.path("results/dart/audit_report_list/csv/", base_date, "/")
audit_report_zip          <- file.path("results/dart/audit_report/zip/")
audit_report_xml_from_biz <- file.path("results/dart/audit_report/xml/from_biz/")
audit_report_xml_from_aud <- file.path("results/dart/audit_report/xml/from_aud/")
audit_report_pdf_from_biz <- file.path("results/dart/audit_report/pdf/from_biz/")
audit_report_pdf_from_aud <- file.path("results/dart/audit_report/pdf/from_aud/") 

ifelse(!dir.exists(file.path(main_dir, audit_report_list_xml_dir)), dir.create(file.path(main_dir, audit_report_list_xml_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_list_csv_dir)), dir.create(file.path(main_dir, audit_report_list_csv_dir)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_zip)),          dir.create(file.path(main_dir, audit_report_zip)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_biz)), dir.create(file.path(main_dir, audit_report_xml_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_xml_from_aud)), dir.create(file.path(main_dir, audit_report_xml_from_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_biz)), dir.create(file.path(main_dir, audit_report_pdf_from_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_pdf_from_aud)), dir.create(file.path(main_dir, audit_report_pdf_from_aud)), FALSE)


#######################################
## cdr02_downloader_corps_code_zip.R ##
#######################################

# source("~/projects/ward/crawling/r/dart/cdr01_environments.R", encoding = "UTF-8")

# set working directory
setwd(file.path(main_dir, corps_code_zip_dir))

base_date_corps_code_zip <- paste0("corps_code_", base_date, ".zip")

request_url_corps_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart)

download.file(url = request_url_corps_code, 
              destfile = base_date_corps_code_zip,
              mode = "wb", 
              quiet = TRUE)

# Comments: When use download.file() function on Windows, should be careful as below:
# On Windows, if mode is not supplied (missing()) and url ends in one of .gz, .bz2, .xz, .tgz, .zip, .rda, .rds or 
# .RData, mode = "wb" is set such that a binary transfer is done to help unwary users.
# Code written to download binary files must use mode = "wb" (or "ab"), 
# but the problems incurred by a text transfer will only be seen on Windows.

##########################
## pdr01_environments.R ##
##########################

library(stringi)
library(jsonlite)
library(tabulizer)

# creating xml_child2df function to import and process xml
xml_child2df <- function(x){
  x_child <- html_children(x)
  x_df <- as.data.frame(matrix(html_text(x_child), 
                               byrow = TRUE, 
                               nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

# A001
audit_report_parsed_rds_biz  <- file.path("results/dart/audit_report/rds/biz",  base_date, "/")
audit_report_parsed_json_biz <- file.path("results/dart/audit_report/json/biz", base_date, "/")

ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_rds_biz)), dir.create(file.path(main_dir, audit_report_parsed_rds_biz)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_biz)), dir.create(file.path(main_dir, audit_report_parsed_json_biz)), FALSE)

# F001
audit_report_parsed_rds_aud  <- file.path("results/dart/audit_report/rds/aud",  base_date, "/")
audit_report_parsed_json_aud <- file.path("results/dart/audit_report/json/aud", base_date, "/")

ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_rds_aud)), dir.create(file.path(main_dir, audit_report_parsed_rds_aud)), FALSE)
ifelse(!dir.exists(file.path(main_dir, audit_report_parsed_json_aud)), dir.create(file.path(main_dir, audit_report_parsed_json_aud)), FALSE)

##############################
## pdr02_corps_code_unzip.R ##
##############################

# set working directory
setwd(file.path(main_dir, corps_code_zip_dir))

file_name <- paste0("corps_code_", base_date, ".zip")
file_name_unzip <- paste0("corps_code_", base_date, ".xml")

unzip(zipfile = file_name,  exdir = file.path(main_dir, corps_code_unzip_dir))

# change working directory from corps_code_zip_dir to corps_code_unzip_dir 
setwd(file.path(main_dir, corps_code_unzip_dir))

file.rename("CORPCODE.xml", to = file_name_unzip)

###################################
## pdr03_corps_code_xml_parser.R ##
###################################

# set working directory
setwd(file.path(main_dir, corps_code_unzip_dir))

read_xml(file_name_unzip) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

file_name_parsed <- paste0("corps_code_parsed_", base_date, ".csv")

write.csv(x = corps_code, 
          file = file.path(main_dir, corps_code_parsed_csv_dir, file_name_parsed), 
          row.names = FALSE)

######################################
## cdr03_downloader_a001_list_xml.R ##
######################################

# set working directory
setwd(file.path(main_dir, corps_code_parsed_csv_dir))

corps_code_a001 <- read.csv(paste0("corps_code_parsed_", base_date, ".csv"), header = T)

date_begin_a001 <- "19800101"
date_end_a001 <- gsub(pattern = "[^0-9]", replacement = "", x = base_date)
last_reprt_at_a001 <- "Y"
pblntf_ty_a001 <- "A"
pblntf_detail_ty_a001 <- "A001"
page_count_a001 <- 100

start_a001 <- 1
end_a001 <- nrow(corps_code_a001)
time_delay_a001 <- 5

for(n_corps in start_a001:end_a001){
  print(n_corps)
  corp_code_a001 <- sprintf(fmt = "%08d", corps_code_a001[n_corps, "corp_code"])
  corp_name_a001 <- corps_code_a001[n_corps, "corp_name"]
  
  request_url_a001 <- paste0("https://opendart.fss.or.kr/api/list.xml?",
                             "&crtfc_key=", key_dart,
                             "&corp_code=", corp_code_a001,
                             "&bgn_de=", date_begin_a001,
                             "&end_de=", date_end_a001,
                             "&last_reprt_at", last_reprt_at_a001,
                             "&pblntf_ty=", pblntf_ty_a001,
                             "&pblntf_detail_ty=", pblntf_detail_ty_a001,
                             "&page_count=", page_count_a001)
  
  report_a001 <- read_html(request_url_a001, encoding = "UTF-8")
  write_xml(report_a001, 
            paste0(main_dir, biz_report_list_xml_dir, "a001_", corp_code_a001, ".xml"), 
            encoding = "UTF-8")
  
  Sys.sleep(time_delay_a001 + runif(1) * 2)
}


######################################
## cdr04_downloader_f001_list_xml.R ##
######################################

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

#############################################
## pdr04_downloaded_a001_list_xml_parser.R ##
#############################################

# set working directory
setwd(file.path(main_dir, biz_report_list_xml_dir))

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
                paste0(main_dir, biz_report_list_csv_dir, "a001_parsed_", list_a001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}

#############################################
## pdr05_downloaded_f001_list_xml_parser.R ##
#############################################

# set working directory
setwd(file.path(main_dir, audit_report_list_xml_dir))

list_f001s_xml <- list.files() 

for(n_f001s in 1:length(list_f001s_xml)){
  list_f001 <- read_html(list_f001s_xml[n_f001s], encoding = "UTF-8")
  list_f001 %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> list_f001_parsed
  
  if(!is.null(list_f001_parsed[1, "rcept_no"])){
    if(nrow(list_f001_parsed) >= 1){
      print(n_f001s)
      write.csv(list_f001_parsed, 
                paste0(main_dir, audit_report_list_csv_dir, "f001_parsed_", list_f001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}

#################################
## cdr05_downloader_a001_zip.R ##
#################################

# set working directory
setwd(file.path(main_dir, biz_report_list_csv_dir))

# importing list of A001 files
list_a001s_csv <- list.files()

# download A001 files
start_a001 <- 1
end_a001 <- length(list_a001s_csv)
time_delay_a001 <- 1

for(n_a001s in start_a001:end_a001){
  list_a001 <- read.csv(list_a001s_csv[n_a001s])
  list_a001[, "year"] <- as.numeric(stri_extract(str = list_a001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_a001 <- sprintf(fmt = "%08d", list_a001[1, "corp_code"])
  
  path_dir <- paste0(main_dir, biz_report_zip, "corp_code_", corp_code_a001)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  print(n_a001s)
  
  for(n_a001 in 1:nrow(list_a001)){
    recept_no <- as.character(list_a001[n_a001, "rcept_no"])
    
    request_url_a001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", list_a001[n_a001, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = request_url_a001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_a001 + runif(1) * 2)
  }
}

###################################
## cdr06_downloader_a-f001_pdf.R ##
###################################

# set working directory
setwd(file.path(main_dir, biz_report_list_csv_dir))

# importing list of A001 files
list_a001s_csv <- list.files()

request_url_base_a001 <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_a001 <- 2014
value_filter_year_max_a001 <- as.numeric(substr(base_date, start = 1, stop = 4))

start_a001 <- 1
end_a001 <- length(list_a001s_csv)
time_delay_a001 <- 1

for(n_a001s in start_a001:end_a001){
  list_a001 <- read.csv(list_a001s_csv[n_a001s], header = T)
  list_a001[, "year"] <- as.numeric(stri_extract(str = list_a001$report_nm, regex = "[0-9]{4}"))
  list_a001 <- list_a001[(list_a001$year <= value_filter_year_max_a001) & (list_a001$year >= value_filter_year_min_a001), ]
  
  print(n_a001s)
  
  if(nrow(list_a001) > 0){
    corp_code <- sprintf(fmt = "%08d", list_a001[1, "corp_code"]) # corp_code 기준으로 디렉토리 만들기 위한 작업
    
    path_dir <- paste0(main_dir, audit_report_pdf_from_biz, "corp_code_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_a001 in 1:nrow(list_a001)){
      rcept_no_a001 <- as.character(list_a001[n_a001, "rcept_no"])
      request_url_a001 <- paste0(request_url_base_a001, rcept_no_a001)
      
      a001 <- read_html(request_url_a001, encoding = "UTF-8")
      a001 %>% 
        html_nodes(xpath = "//*/select[@id='att']") %>% 
        html_children() -> a001_sub_list
      
      a001_sub_list %>% html_attr(name = "value") -> a001_sub_list_attrs
      a001_sub_list %>% html_text() -> a001_sub_list_texts
      
      url_f001_no <- a001_sub_list_attrs[grep(pattern = "감사보고서", a001_sub_list_texts)][1]
      url_f001_no <- gsub(pattern = "No", replacement = "_no", url_f001_no)
      
      dcm_no <- gsub(pattern = "^.*?dcm_no=", replacement = "", url_f001_no)
      
      url_f001 <- paste0(request_url_base_pdf, url_f001_no) 
      download.file(url = url_f001, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", rcept_no_a001, "_", dcm_no, ".pdf"),
                    quiet = TRUE, mode = "wb")
      Sys.sleep(time_delay_a001 + runif(1) * 2)
    } 
  }
}

#################################
## cdr07_downloader_f001_zip.R ##
#################################

# set working directory
setwd(file.path(main_dir, audit_report_list_csv_dir))

# importing list of F001 files
list_f001s_csv <- list.files()

# download F001 files
start_f001 <- 1
end_f001 <- length(list_f001s_csv)
time_delay_f001 <- 1

for(n_f001s in start_f001:end_f001){
  list_f001 <- read.csv(list_f001s_csv[n_f001s], header = T) 
  list_f001[, "year"] <- as.numeric(stri_extract(str = list_f001$report_nm, regex = "[0-9]{4}"))
  
  corp_code_f001 <- sprintf(fmt = "%08d", list_f001[1, "corp_code"])
  
  path_dir <- paste0(main_dir, audit_report_zip, "corp_code_", corp_code_f001)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  print(n_f001s)
  
  for(n_f001 in 1:nrow(list_f001)){
    recept_no <- as.character(list_f001[n_f001, "rcept_no"])
    
    request_url_f001 <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                               "&crtfc_key=", key_dart,
                               "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", list_f001[n_f001, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = request_url_f001, destfile = path_zip,
                  mode = "wb", 
                  quiet = TRUE)
    
    Sys.sleep(time_delay_f001 + runif(1) * 2)
  }
}

###################################
## cdr08_downloader_f-f001_pdf.R ##
###################################

# set working directory
setwd(file.path(main_dir, audit_report_list_csv_dir))

# importing list of A001 files
list_f001s_csv <- list.files()

request_url_base_f001 <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="
request_url_base_pdf <- "http://dart.fss.or.kr/pdf/download/pdf.do?"

value_filter_year_min_f001 <- 2014
value_filter_year_max_f001 <- as.numeric(substr(base_date, start = 1, stop = 4))

start_f001 <- 1
end_f001 <- length(list_f001s_csv)
time_delay_f001 <- 1

for(n_f001s in start_f001:end_f001){
  list_f001 <- read.csv(list_f001s_csv[n_f001s], header = T)
  list_f001[, "year"] <- as.numeric(stri_extract(str = list_f001$report_nm, regex = "[0-9]{4}"))
  list_f001 <- list_f001[(list_f001$year <= value_filter_year_max_f001) & (list_f001$year >= value_filter_year_min_f001), ]
  print(n_f001s)
  
  if(nrow(list_f001) > 0){
    corp_code <- sprintf(fmt = "%08d", list_f001[1, "corp_code"]) # corp_code 기준으로 디렉토리 만들기 위한 작업
    
    path_dir <- paste0(main_dir, audit_report_pdf_from_aud, "corp_code_", corp_code)
    dir.create(path = path_dir, showWarnings = FALSE)
    
    for(n_f001 in 1:nrow(list_f001)){
      rcept_no_f001 <- as.character(list_f001[n_f001, "rcept_no"])
      request_url_f001 <- paste0(request_url_base_f001, rcept_no_f001)
      
      f001 <- read_html(request_url_f001, encoding = "UTF-8")
      f001 %>% 
        html_nodes(xpath = "//*/a[@href='#download']") %>% 
        html_attr(name = "onclick") %>%
        stri_extract(regex = "\\'[0-9]{6,8}\\'") %>% 
        gsub(pattern = "[^0-9]", replacement = "") -> dcm_no
      
      url_f001 <- paste0(request_url_base_pdf, "rcp_no=", rcept_no_f001, "&dcm_no=", dcm_no)
      
      download.file(url = url_f001, 
                    destfile = paste0(path_dir, "/f001_", corp_code, "_", rcept_no_f001, "_", dcm_no, ".pdf"),
                    quiet = TRUE, 
                    mode = "wb")
      
      Sys.sleep(time_delay_f001 + runif(1) * 2)
    } 
  }
}

###################################
## pdr06_downloaded_a001_unzip.R ##
###################################

# set working directory
setwd(file.path(main_dir, biz_report_zip))

list_a001s_zip <- list.files(recursive = TRUE, full.names = TRUE)

list_a001s <- data.frame(path = list_a001s_zip, 
                         corp_code = stri_extract(str = list_a001s_zip, regex = "(?<=corp_code_)[0-9]{6,9}")) # str = list_a001s$corp_code 원래 코드는 str = list_a001

list_a001 <- unique(list_a001s$corp_code)

start_a001 <- 1
end_a001 <- length(list_a001)

for(n_corp in start_a001:end_a001){
  corp_code <- list_a001[n_corp]
  path_dir <- paste0(main_dir, audit_report_xml_from_biz, "corp_code_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  list_a001s_sub <- list_a001s[list_a001s$corp_code == corp_code, ]  
  for(n_zip in 1:nrow(list_a001s_sub)){
    if(file.info(list_a001s_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = list_a001s_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
  list_a001s_del <- list.files(path = path_dir)
  list_a001s_del <- list_a001s_del[!grepl(pattern = "00760.xml$", x = list_a001s_del)] # 감사보고서의 고유 접미사가 00760임
  
  for(n_xml in 1:length(list_a001s_del)){
    file.remove(list_a001s_del[n_xml])
  }
}

###################################
## pdr07_downloaded_f001_unzip.R ##
###################################

# set working directory
setwd(file.path(main_dir, audit_report_zip))

list_f001s_zip <- list.files(recursive = TRUE, full.names = TRUE)

list_f001s <- data.frame(path = list_f001s_zip,
                         corp_code = stri_extract(str = list_f001s_zip, regex = "(?<=corp_code_)[0-9]{6,9}"))

list_f001 <- unique(list_f001s$corp_code)

start_f001 <- 1
end_f001 <- length(list_f001)

for(n_corp in start_f001:end_f001){
  corp_code <- list_f001[n_corp]
  path_dir <- paste0(main_dir, audit_report_xml_from_aud, "corp_code_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  list_f001s_sub <- list_f001s[list_f001s$corp_code == corp_code, ]  
  for(n_zip in 1:nrow(list_f001s_sub)){
    if(file.info(list_f001s_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = list_f001s_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
}

#########################
## pdr08_xml_handler.R ##
#########################

# A001
list_doc = list.files(path = biz_report_list_csv_dir,
                      full.names = TRUE)

list_xml = list.files(path = biz_report_doc, # 경로명 수정 필요
                      recursive = TRUE,
                      full.names = TRUE)

# F001
list_doc <- list.files(path = paste0(main_dir, audit_report_list_csv_dir), 
                       full.names = TRUE)

list_xml <- list.files(path = paste0(main_dir, audit_report_xml_from_aud),
                       full.names = TRUE,
                       recursive = TRUE)

value_filter_year_min_xml <- 2014
value_filter_year_max_xml <- as.numeric(substr(base_date, start = 1, stop = 4))

df_list_xml <- data.frame(path = list_xml,
                          year = stri_extract(str = list_xml, regex = "(?<=[0-9]/)(19[8-9][0-9]|20[0-2][0-9])"))
df_list_xml <- df_list_xml[(df_list_xml$year <= value_filter_year_max_xml) & (df_list_xml$year >= value_filter_year_min_xml), ]

start_xml <- 1
end_xml <- nrow(df_list_xml)

for(n_file in start_xml:end_xml){
  print(n_file)
  xml_doc <- tryCatch(expr = {
    read_html(df_list_xml[n_file, "path"], encoding = "CP949")
  }, error = function(x){
    return(read_html(df_list_xml[n_file, "path"], encoding = "UTF-8"))
  })
  
  xml_doc %>%
    html_nodes(xpath = "//*/company-name") -> corp_info
  
  corp_info %>% 
    html_attr("aregcik") -> corp_code
  
  corp_info %>% 
    html_text() -> corp_name
  
  xml_doc %>%
    html_nodes(xpath = "//*/document-name") %>%
    html_attr("acode") -> doc_code
  
  xml_doc %>%
    html_nodes(xpath = "//*/document-name") %>%
    html_text() -> doc_title
  
  xml_doc %>% 
    html_nodes(xpath = "//*/title[@aassocnote]/..") -> tables
  
  tables %>% 
    html_children() %>%
    html_attr(name = "aassocnote") %>% 
    .[!is.na(.)] -> table_list
  # print(table_list)
  
  xml_doc %>%
    html_nodes(xpath = '//*/tu[@aunit="SUB_PERIODTO"]') %>% 
    html_text() %>% 
    gsub(pattern = "[^0-9]", replacement = "") -> audit_date_end
  
  # audit hour table
  xml_doc %>%
    html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//title') %>%
    html_text() -> table_name
  
  xml_doc %>%
    html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//tbody') -> table_sub
  
  table_sub[1] %>%
    html_text() %>% 
    gsub(pattern = "\n", replacement = "") -> table_sub_comment
  
  table_sub[2] %>%
    html_nodes(css = "te") %>% 
    html_attr(name = "acode") -> table_sub_names
  
  table_sub[2] %>%
    html_nodes(css = "te") %>% 
    html_text() %>% 
    gsub(pattern = "[^0-9]", replacement = "") %>% 
    ifelse(test = . == "", yes = NA, no = .) %>%
    as.numeric() -> table_sub_data
  
  df_table_hour <- data.frame(var = table_sub_names,
                              value = table_sub_data)
  table_hour_name <- table_name
  table_hour_etc <- table_sub_comment
  
  # main audit
  xml_doc %>%
    html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//title') %>%
    html_text() -> table_name
  
  xml_doc %>%
    html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//tbody') -> table_sub
  
  table_sub %>%
    html_nodes(css = "te") %>% 
    html_attr(name = "acode") -> table_sub_names
  
  table_sub %>%
    html_nodes(css = "te") %>% 
    html_text() %>% 
    ifelse(test = . == "-", yes = NA, no = .) %>%
    gsub(pattern = "\\&cr;|\\n", replacement = "") -> table_sub_data
  
  df_table_main_audit <- data.frame(var = table_sub_names,
                                    value = table_sub_data)
  table_main_audit_name <- table_name
  
  # communication
  if(sum(table_list %in% "D-0-2-4-0") == 1){
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//title') %>%
      html_text() -> table_name
    
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//tbody') -> table_sub
    
    table_sub %>%
      html_nodes(css = "te") %>% 
      html_attr(name = "acode") -> table_sub_names
    
    table_sub %>%
      html_nodes(css = "te") %>% 
      html_text() %>%
      gsub(pattern = "\\&cr;", replacement = ", ") -> table_sub_data
    
    df_table_com <- data.frame(var = table_sub_names,
                               value = table_sub_data)
    
    df_table_com[, "obs"] <- rep(1:(nrow(df_table_com)/4), each = 4)
    df_table_com <- reshape2::dcast(df_table_com, formula = "obs ~ var", value.var = "value", fill = NA)
    
    table_sub_com_name <- table_name
  } else {
    df_table_com <- data.frame()
    table_sub_com_name <- NA
  }
  
  # audit opinion
  if(sum(table_list %in% "D-0-0-1-0") == 1){
    xml_doc %>%
      html_nodes(xpath = "//*/section-1/title[@aassocnote='D-0-0-1-0']/..") %>% 
      html_children() -> xml_doc_report
    
    xml_doc_report[1] %>% 
      html_text() -> xml_doc_report_title
    
    xml_doc_report[-1] %>% 
      as.character() %>% 
      strsplit(split = "\\n|&cr;|cr;|&amp") %>% 
      unlist() -> xml_doc_report_text
    
    xml_doc_report_text_pos <- grep(pattern = "usermark.{2,5}B", x = xml_doc_report_text)
    xml_doc_report_text_pos <- xml_doc_report_text_pos[nchar(xml_doc_report_text[xml_doc_report_text_pos]) < 50]
    
    xml_doc_report_text[xml_doc_report_text_pos] <- paste0("@", xml_doc_report_text[xml_doc_report_text_pos]) 
    
    xml_doc_report_text %>% 
      gsub(pattern = "<.*?>", replacement = "") %>% 
      gsub(pattern = " {2,}", replacement = " ") %>% 
      gsub(pattern = "^ | $|;$", replacement = "") -> xml_doc_report_text
    
    xml_doc_report_text <- xml_doc_report_text[!(xml_doc_report_text %in% c("", "@"))]
    
    xml_doc_report_date_pos <- grep(pattern = "^[0-9]{4}..[0-9]{1,2}", xml_doc_report_text)[1]
    if(is.na(xml_doc_report_date_pos) == FALSE){
      xml_doc_report_text <- c(xml_doc_report_text[1:(xml_doc_report_date_pos - 1)],
                               paste(xml_doc_report_text[xml_doc_report_date_pos:length(xml_doc_report_text)], collapse = " "))    
      xml_doc_report_text <- xml_doc_report_text[nchar(xml_doc_report_text) > 1]
    } 
    
    list_doc_report <- xml_doc_report_text
  } else {
    list_doc_report <- NA
  }
  
  
  df_corp_info <- read.csv(grep(pattern = corp_code, x = list_doc, value = TRUE))
  df_corp_info[, "rcept_no"] <- as.character(df_corp_info$rcept_no)
  
  recept_no <- stri_extract(str = df_list_xml[n_file, "path"], regex = "(?<=\\/)[0-9]{12,15}")
  doc_loc <- grep(pattern = recept_no, df_corp_info$rcept_no)
  
  meta_report_audit <- list("fiscal_year" = substr(audit_date_end, start = 1, stop = 4), 
                            "year_end" = substr(audit_date_end, start = 5, stop = 8), 
                            "corp_cls" = df_corp_info[1, "corp_cls"], 
                            "corp_name" = corp_name,
                            "corp_code" = corp_code, 
                            "stock_code" = df_corp_info[1, "stock_code"], 
                            "report_name" = doc_title,  
                            "rcept_no" = recept_no, 
                            "flr_name" = df_corp_info[1, "flr_nm"], 
                            "rcept_dt" = df_corp_info[doc_loc, "rcept_dt"], 
                            "rm" = df_corp_info[1, "rm"],
                            "turn" = "51") # 회기에 대한 이해는 당연히 없음
  
  # 내부회계관리제도 감사
  xml_doc %>% 
    html_nodes(xpath = "//*/section-1/image/..") %>% 
    html_children() -> xml_doc_internal
  
  xml_doc_internal[1] %>% 
    html_text() -> xml_doc_report_title
  
  xml_doc_internal[-1] %>% 
    as.character() %>% 
    strsplit(split = "\\n|&cr;|cr;|&amp") %>% 
    unlist() -> xml_doc_internal_text 
  
  xml_doc_internal_text_pos <- grep(pattern = "usermark", x = xml_doc_internal_text)
  
  xml_doc_internal_text[xml_doc_internal_text_pos] <- paste0("@", xml_doc_internal_text[xml_doc_internal_text_pos]) 
  
  xml_doc_internal_text %>% 
    gsub(pattern = "<.*?>", replacement = "") %>% 
    gsub(pattern = " {2,}", replacement = " ") %>% 
    gsub(pattern = "^ | $|;$", replacement = "") -> xml_doc_internal_text
  
  list_doc_internal <- xml_doc_internal_text
  
  if(sum(df_table_hour$var == "NUM_QLT_TH") == 1){
    auditors <- list(quality_ctrl = list("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT_TH", "value"]), 
                     cpa = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT_TH", "value"], 
                                                     "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR_TH", "value"], 
                                                     "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP_TH", "value"])), 
                     prf = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP_TH", "value"], 
                                "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "NUM_COT_TH", "value"]))
    
    # 외부감사 실시 내용 중 투입 시간 정보(분/반기)
    auditors_time_periodic <- list(quality_ctrl_time_periodic = list("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT_TH", "value"]), 
                                   cpa_time_periodic = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT_TH", "value"],
                                                                                 "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR_TH", "value"], 
                                                                                 "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP_TH", "value"])),
                                   prf_time_periodic = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP_TH", "value"], 
                                                            "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMA_COT_TH", "value"]))
    
    # 외부감사 실시 내용 중 투입 시간 정보(기말)
    auditors_time_yearend <- list(quality_ctrl_time_yearend = list("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT_TH", "value"]),
                                  cpa_time_yearend = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT_TH", "value"], 
                                                                               "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR_TH", "value"], 
                                                                               "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP_TH", "value"])),
                                  prf_time_yearend = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP_TH", "value"], 
                                                          "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMY_COT_TH", "value"]))
    
  } else {
    auditors <- list(quality_ctrl = list("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT", "value"]), 
                     cpa = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT", "value"], 
                                                     "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR", "value"], 
                                                     "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP", "value"])), 
                     prf = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP", "value"], 
                                "합계" = df_table_hour[df_table_hour$var == "NUM_TOT", "value"]))
    
    # 외부감사 실시 내용 중 투입 시간 정보(분/반기)
    auditors_time_periodic <- list(quality_ctrl_time_periodic = list("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT", "value"]), 
                                   cpa_time_periodic = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT", "value"],
                                                                                 "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR", "value"], 
                                                                                 "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP", "value"])),
                                   prf_time_periodic = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP", "value"], 
                                                            "합계" = df_table_hour[df_table_hour$var == "TMA_TOT", "value"]))
    
    # 외부감사 실시 내용 중 투입 시간 정보(기말)
    auditors_time_yearend <- list(quality_ctrl_time_yearend = list("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT", "value"]),
                                  cpa_time_yearend = list("감사업무 담당 회계사" = list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT", "value"], 
                                                                               "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR", "value"], 
                                                                               "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP", "value"])),
                                  prf_time_yearend = list("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP", "value"], 
                                                          "합계" = df_table_hour[df_table_hour$var == "TMY_TOT", "value"]))
  }
  
  # 외부 감사 실시 내용(집합)
  external_audit_contents <- list("보고서" = meta_report_audit, 
                                  "감사참여자 구분별 인원수 및 감사시간" = list("투입 인원수" = auditors, 
                                                                "분/반기검토(시간)" = auditors_time_periodic,
                                                                "감사(시간)" = auditors_time_yearend))
  
  # 외부 감사 실시 내용(집합)을 json으로 변형
  external_audit_contents <- jsonlite::toJSON(external_audit_contents, pretty = TRUE, auto_unbox = TRUE)
  external_audit_contents <- iconv(external_audit_contents, from = "UTF-8", to = "CP949")
  
  # 내부회계관리제도 감사 또는 검토 의견 중 독립된 감사인의 내부회계관리제도 감사보고서
  internal_accounting_audit <- list(list_doc_report)
  
  # 내부회계관리제도 감사 또는 검토 의견 중 회사의 내부회계관리제도 운영실태보고서
  internal_accounting_operation <- list(list_doc_internal)
  
  # 내부회계관리제도 감사 또는 검토 의견(집합)
  internal_accounting_contents <- list("보고서" = meta_report_audit, 
                                       "독립된 감사인의 내부회계관리제도 감사보고서" = internal_accounting_audit, 
                                       "내부회계관리제도 운영실태 보고" = internal_accounting_operation)
  
  
  # 내부회계관리제도 감사 또는 검토 의견(집합)을 json으로 변형
  internal_accounting_contents <- jsonlite::toJSON(internal_accounting_contents, pretty = TRUE, auto_unbox = TRUE)
  internal_accounting_contents <- iconv(internal_accounting_contents, from = "UTF-8", to = "CP949")
  
  # [[ write files ]]
  dir_corp <- paste0("corp_code_", corp_code)
  
  # write - json
  dir_path_json <- file.path(main_dir, audit_report_parsed_json_aud, dir_corp)
  dir.create(path = dir_path_json, showWarnings = FALSE, recursive = TRUE)
  
  # json writing - external
  file_name_external <- paste(corp_code,  
                              substr(audit_date_end, start = 1, stop = 4),
                              recept_no, 
                              doc_code,
                              "external_audit_contents.json", sep = "_")
  write(external_audit_contents, 
        paste(dir_path_json, file_name_external, sep = "/"))
  
  # json writing - internal
  file_name_internal <- paste(corp_code,  
                              substr(audit_date_end, start = 1, stop = 4),
                              recept_no, 
                              doc_code,
                              "internal_accounting_contents.json", sep = "_")
  
  write(internal_accounting_contents,
        paste(dir_path_json, file_name_internal, sep = "/")) 
  
  # write - rds
  dir_path_rds <- file.path(main_dir, audit_report_parsed_rds_aud, dir_corp)
  dir.create(path = dir_path_rds, showWarnings = FALSE, recursive = TRUE)
  
  file_name_rds <- paste(corp_code,  
                         substr(audit_date_end, start = 1, stop = 4),
                         recept_no, 
                         doc_code,
                         "contents_both.rds", sep = "_")
  
  saveRDS(list(internal = internal_accounting_contents,
               external = external_audit_contents),
          paste(dir_path_rds, file_name_rds, sep = "/"))
}