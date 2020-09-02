################################################
## /ward/crawling/dart/r/cdr01_environments.R ##
################################################

# Setting Global Environments

# loading required libraries
library(rvest)
library(stringi)
library(tidyverse)
library(xml2)
library(jsonlite)

# set base date
base_date <- Sys.Date()

# set main path
main_dir <- "~/projects/ward/"

# set additional path and create directories related to corp_code
corps_code_zip_dir        <- "results/dart/corps_code/zip/"
corps_code_unzip_dir      <- "results/dart/corps_code/xml/"
corps_code_parsed_csv_dir <- "results/dart/corps_code/csv/"

# set additional path and create directories related to a001
biz_report_list_xml_dir <- file.path("results/dart/biz_report_list/xml/")
biz_report_list_csv_dir <- file.path("results/dart/biz_report_list/csv/")
biz_report_zip          <- file.path("results/dart/biz_report/zip/")
biz_report_xml          <- file.path("results/dart/biz_report/xml/")

# set additional path and create directories related to f001
audit_report_list_xml_dir <- file.path("results/dart/audit_report_list/xml/")
audit_report_list_csv_dir <- file.path("results/dart/audit_report_list/csv/")
audit_report_zip          <- file.path("results/dart/audit_report/zip/")
audit_report_xml_from_biz <- file.path("results/dart/audit_report/xml/from_biz/")
audit_report_xml_from_aud <- file.path("results/dart/audit_report/xml/from_aud/")
audit_report_pdf_from_biz <- file.path("results/dart/audit_report/pdf/from_biz/")
audit_report_pdf_from_aud <- file.path("results/dart/audit_report/pdf/from_aud/") 


##################################################
## /ward/processing/dart/r/pdr01_environments.R ##
##################################################

# creating xml_child2df function to import and process xml
xml_child2df <- function(x){
  x_child <- html_children(x)
  x_df <- as.data.frame(matrix(html_text(x_child), 
                               byrow = TRUE, 
                               nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

# creating to choose the most recent file
recent_doc <- function(x){
  aggregate(data = x, . ~ year, FUN = "max")
}


#################################################
## /ward/processing/dart/r/pdr08_xml_handler.R ##
#################################################

# list up audit report from biz report(A001)
list_doc <- list.files(path = file.path(main_dir, biz_report_list_csv_dir),
                       full.names = TRUE,
                       recursive = TRUE)

list_xml <- list.files(path = file.path(main_dir, audit_report_xml_from_biz),
                       full.names = TRUE, 
                       recursive = TRUE)


##### filtering xml list #####
df_list_xml <- data.frame(path = list_xml,
                          corp_code = unlist(stri_extract_all(str = list_xml, regex = "(?<=corp_code_)[0-9]{6,8}")),
                          doc_no = unlist(stri_extract_all(str = list_xml, regex = "(?<=[0-9]/)[0-9]{9,14}")))
df_list_xml[, "year"] <- substr(x = df_list_xml$doc_no, start = 1, stop = 4)


##### choose most recent document #####
df_list_xml_split <- split(x = df_list_xml, f = df_list_xml$corp_code)
df_list_xml <- lapply(df_list_xml_split, FUN = "recent_doc")
df_list_xml <- do.call(what = "rbind", args = df_list_xml)
rownames(df_list_xml) <- NULL


##### select time window to process document #####
value_filter_year_min_xml <- 2015
value_filter_year_max_xml <- as.numeric(substr(base_date, start = 1, stop = 4))
df_list_xml <- df_list_xml[(df_list_xml$year <= value_filter_year_max_xml) & (df_list_xml$year >= value_filter_year_min_xml), ]
corp_list <- unique(df_list_xml$corp_code)


##### set an empty object to store data #####
gross_audit_external_from_biz <- list()
indv_audit_external_from_biz <- list()


##### global processing #####
start_corp <- 1
end_corp <- length(corp_list)

for(n_corp in start_corp:end_corp){
  print(n_corp)
  df_list_xml_sub <- df_list_xml[df_list_xml$corp_code == corp_list[n_corp], ] 
  
  for(n_file in 1:nrow(df_list_xml_sub)){

    
##### extracting document information #####
    xml_doc <- tryCatch(expr = {
      read_html(df_list_xml_sub[n_file, "path"], encoding = "CP949")
    }, error = function(x){
      return(read_html(df_list_xml_sub[n_file, "path"], encoding = "UTF-8"))
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
    
    xml_doc %>%
      html_nodes(xpath = '//*/tu[@aunit="SUB_PERIODTO"]|//*/tu[@aunit="PERIODTO2"]') %>% 
      html_text() %>% 
      gsub(pattern = "[^0-9]", replacement = "") -> audit_date_end
    
    xml_doc %>% 
      html_nodes(xpath = '//*/td[@usermark="F-BT14"]') %>% 
      .[1] %>% 
      html_text() %>% 
      gsub(pattern = "\\n", replacement = "") -> doc_turn
  
    fiscal_year <- substr(audit_date_end, start = 1, stop = 4)[1]
    
    year_end <- substr(audit_date_end, start = 5, stop = 8)[1]    

    df_corp_info <- read.csv(grep(pattern = corp_code, x = list_doc, value = TRUE), fileEncoding = "CP949")
    df_corp_info[, "rcept_no"] <- as.character(df_corp_info$rcept_no)
    
    recept_no <- stri_extract(str = df_list_xml[n_file, "path"], regex = "(?<=\\/)[0-9]{12,15}")
    doc_loc <- grep(pattern = recept_no, df_corp_info$rcept_no)
    

##### time table of audit #####
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//title') %>%
      html_text() -> table_name
    
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//tbody') -> table_sub
    
    # table_sub[1] %>%
    #   html_text() %>% 
    #   gsub(pattern = "\n", replacement = "") -> table_sub_comment
    
    table_sub[2] %>%
      html_nodes(css = "te") %>% 
      html_attr(name = "acode") -> table_sub_names
    
    table_sub[2] %>%
      html_nodes(css = "te") %>% 
      html_text() %>% 
      gsub(pattern = "[^0-9]", replacement = "") %>% 
      ifelse(test = . == "", yes = NA, no = .) %>%
      as.numeric() -> table_sub_data

    df_table_hour <- data.frame(var = table_sub_names, value = table_sub_data)
    
    
##### main audit #####
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//title') %>%
      html_text() -> table_name
    
    xml_doc %>%
      html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//tbody') -> table_sub
    
    table_sub %>%
      html_nodes(css = "te") %>% 
      html_attr(name = "acode") -> table_sub_names
    
    names_loc = grep(pattern = "^PLC", table_sub_names)
    names_cnt = length(names_loc) / 5
    table_sub_names[names_loc] = paste(table_sub_names[names_loc],
                                       rep(1:names_cnt, each = 5),
                                       sep = "_")
    
    table_sub %>%
      html_nodes(css = "te") %>% 
      html_text() %>% 
      ifelse(test = . == "-", yes = NA, no = .) %>%
      gsub(pattern = "\\&cr;|\\n", replacement = " ") %>% 
      gsub(pattern = "^ | $| {2,}", replacement = "") -> table_sub_data
    
    list_table_main_audit <- list(table_sub_data)
    names(list_table_main_audit[[1]]) <- table_sub_names
    

##### audit opinion for financial statements #####
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
    
    
##### communication with audit #####
    list_table_com <- list()
    
    if(sum(table_list %in% "D-0-2-4-0") == 1){
      xml_doc %>%
        html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//title') %>%
        html_text() -> table_name
      
      xml_doc %>%
        html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//tbody') -> table_sub
      
      table_sub %>%
        html_nodes(xpath = "tr/te|tr/tu") %>% 
        html_attr(name = "acode") %>% 
        ifelse(test = is.na(.), yes = "COMM_DATE", no = .) -> table_sub_names
      
      table_sub %>%
        html_nodes(xpath = "tr/te|tr/tu") %>% 
        html_text() %>%
        gsub(pattern = "\\&cr;", replacement = ", ") -> table_sub_data
      
      df_table_com <- data.frame(var = table_sub_names, value = table_sub_data)
      df_table_com[, "회차"] <- rep(1:(nrow(df_table_com)/5), each = 5)
      df_table_com <- reshape2::dcast(df_table_com, formula = "회차 ~ var", value.var = "value", fill = NA)
      
      for(n_row in 1:nrow(df_table_com)){
        list_table_com[[n_row]] <- as.list(df_table_com[n_row, ])
        names(list_table_com)[n_row] <- n_row
      }
    } else {
      list_table_com <- NA
    }
    
    
##### contents of audit #####
    if(sum(df_table_hour$var == "NUM_QLT_TH") == 1){

      
#### input human resources of external audit #####
    quality_ctrl <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT_TH", "value"])
      
    cpa <- list("감사업무 담당 회계사" = 
                  list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT_TH", "value"], 
                       "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR_TH", "value"], 
                       "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP_TH", "value"]))
      
    prf <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP_TH", "value"], 
             "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "NUM_COT_TH", "value"])
   
       
##### input human time of external audit (half/quarter) #####
    quality_ctrl_time_periodic <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT_TH", "value"])
      
    cpa_time_periodic <- list("감사업무 담당 회계사" = 
                                list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT_TH", "value"],
                                     "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR_TH", "value"], 
                                     "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP_TH", "value"]))
      
    prf_time_periodic <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP_TH", "value"], 
                           "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMA_COT_TH", "value"])
      
      
##### input human time of external audit (year end) #####
    quality_ctrl_time_yearend <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT_TH", "value"])
      
    cpa_time_yearend <- list("감사업무 담당 회계사" = 
                               list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT_TH", "value"], 
                                    "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR_TH", "value"], 
                                    "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP_TH", "value"]))
      
    prf_time_yearend = c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP_TH", "value"], 
                         "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMY_COT_TH", "value"])
      
    } else {
      
      
##### 외부감사 실시 내용 준 투입 인력 정보 #####
    quality_ctrl <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT", "value"])
      
    cpa <- list("감사업무 담당 회계사" = 
                  list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT", "value"], 
                       "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR", "value"], 
                       "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP", "value"]))
      
    prf <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP", "value"], 
             "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "NUM_COT", "value"])
      
    
##### 외부감사 실시 내용 중 투입 시간 정보(분/반기) ######
    quality_ctrl_time_periodic <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT", "value"])
      
    cpa_time_periodic <- list("감사업무 담당 회계사" = 
                                list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT", "value"],
                                     "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR", "value"], 
                                     "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP", "value"]))
      
    prf_time_periodic <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP", "value"], 
                           "수주산업 등 전문가" = NA)
   
       
##### 외부감사 실시 내용 중 투입 시간 정보(기말) #####
    quality_ctrl_time_yearend <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT", "value"])
      
    cpa_time_yearend <- list("감사업무 담당 회계사" = 
                               list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT", "value"], 
                                    "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR", "value"], 
                                    "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP", "value"]))
      
    prf_time_yearend <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP", "value"], 
                          "수주산업 등 전문가" = NA)
    }

    auditors <- c(quality_ctrl, cpa, prf)
    auditors_time_periodic <- c(quality_ctrl_time_periodic, cpa_time_periodic, prf_time_periodic)
    auditors_time_yearend <- c(quality_ctrl_time_yearend, cpa_time_yearend, prf_time_yearend)
   
     
##### 외부 감사 실시 내용(집합) #####
    external_audit <- list("year_end" = year_end, 
                           "corp_cls" = df_corp_info[1, "corp_cls"], 
                           "corp_name" = corp_name,
                           "corp_code" = corp_code, 
                           "stock_code" = df_corp_info[1, "stock_code"], 
                           "report_name" = doc_title,  
                           "rcept_no" = recept_no, 
                           "flr_name" = df_corp_info[1, "flr_nm"], 
                           "rcept_dt" = ifelse(test = length(df_corp_info[doc_loc, "rcept_dt"]) == 0, yes = NA, no = df_corp_info[doc_loc, "rcept_dt"]), 
                           "rm" = ifelse(test = df_corp_info[1, "rm"] == "", yes = NA, no = df_corp_info[1, "rm"]),
                           "turn" = doc_turn,
                           "재무제표에 대한 감사 보고서" = paste(list_doc_report, collapse = " "),
                           "감사참여자 구분별 인원수 및 감사시간" = 
                             list("투입 인원수" = auditors, 
                                  "분/반기검토(시간)" = auditors_time_periodic,
                                  "감사(시간)" = auditors_time_yearend),
                           "주요 감사실시내용" = as.list(list_table_main_audit[[1]]),
                           "감사와의 커뮤니케이션" = list_table_com)
    
    indv_audit_external_from_biz[[n_file]] <- external_audit
    names(indv_audit_external_from_biz)[n_file] <- fiscal_year
  }
  
  gross_audit_external_from_biz[[n_corp]] <- indv_audit_external_from_biz
  names(gross_audit_external_from_biz)[n_corp] <- corp_code
  indv_audit_external_from_biz <- list()
}


#### write for rds #####
saveRDS(gross_audit_external_from_biz, file = paste0(main_dir, audit_report_rds_from_biz, "external_audit_from_biz.rds"))


##### write for json #####
gross_audit_external_json <- jsonlite::toJSON(gross_audit_external_from_biz, pretty = TRUE, auto_unbox = TRUE, encoding = "UTF-8")
write(gross_audit_external_json, file = paste0(main_dir, audit_report_json_biz, "external_audit_biz.json"))