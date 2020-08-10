#################################################
## /ward/processing/dart/r/pdr08_xml_handler.R ##
#################################################

library(stringr)
library(stringi)
library(xml2)

# A001
# list_doc <- list.files(path = biz_report_list_csv_dir,
#                        recursive = TRUE,
#                        full.names = TRUE)

list_xml = list.files(path = biz_report_doc, # 경로명 수정 필요
                      recursive = TRUE,
                      full.names = TRUE)

# F001
list_doc <- list.files(path = paste0(main_dir, audit_report_list_csv_dir), 
                       recursive = TRUE,
                       full.names = TRUE)

list_xml <- list.files(path = paste0(main_dir, audit_report_xml_from_aud),
                       recursive = TRUE,
                       full.names = TRUE)


value_filter_year_min_xml <- 2015
value_filter_year_max_xml <- as.numeric(substr(base_date, start = 1, stop = 4))

df_list_xml <- data.frame(path = list_xml,
                          year = stri_extract(str = list_xml, regex = "(?<=[0-9]/)(19[8-9][0-9]|20[0-2][0-9])"))
df_list_xml <- df_list_xml[(df_list_xml$year <= value_filter_year_max_xml) & (df_list_xml$year >= value_filter_year_min_xml), ]

corp_list <- unlist(unique(stri_extract_all(str = df_list_xml$path, regex = "(?<=corp_no_)[0-9]{6,10}")))

gross_audit_external <- list()
indv_audit_external <- list()

start_corp <- 1
end_corp <- length(corp_list)
for(n_corp in start_corp:end_corp){
  df_list_xml_sub <- df_list_xml[grep(pattern = paste0("corp_no_", corp_list[n_corp]), df_list_xml$path), ] 
  
  for(n_file in 1:nrow(df_list_xml_sub)){
    
    print(n_file)
    
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
      html_nodes(xpath = '//*/tu[@aunit="SUB_PERIODTO"]') %>% 
      html_text() %>% 
      gsub(pattern = "[^0-9]", replacement = "") -> audit_date_end
    
    xml_doc %>% 
      html_nodes(xpath = '//*/td[@usermark="F-BT14"]') %>% 
      .[1] %>% 
      html_text() %>% 
      gsub(pattern = "\\n", replacement = "") -> doc_turn
    
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
    
    table_hour_etc <- table_sub_comment
    
    df_corp_info <- read.csv(grep(pattern = corp_code, x = list_doc, value = TRUE))
    df_corp_info[, "rcept_no"] <- as.character(df_corp_info$rcept_no)
    
    recept_no <- stri_extract(str = df_list_xml[n_file, "path"], regex = "(?<=\\/)[0-9]{12,15}")
    doc_loc <- grep(pattern = recept_no, df_corp_info$rcept_no)
    
    fiscal_year <- substr(audit_date_end, start = 1, stop = 4)
    year_end <- substr(audit_date_end, start = 5, stop = 8)
    
    if(sum(df_table_hour$var == "NUM_QLT_TH") == 1){ # why this condition?
      
      # 외부감사 실시 내용 준 투입 인력 정보
      quality_ctrl <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT_TH", "value"])
      
      cpa <- list("감사업무 담당 회계사" = 
                    list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT_TH", "value"], 
                         "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR_TH", "value"], 
                         "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP_TH", "value"]))
      
      prf <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP_TH", "value"], 
               "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "NUM_COT_TH", "value"])
      
      # 외부감사 실시 내용 중 투입 시간 정보(분/반기)
      quality_ctrl_time_periodic <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT_TH", "value"])
      
      cpa_time_periodic <- list("감사업무 담당 회계사" = 
                                  list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT_TH", "value"],
                                       "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR_TH", "value"], 
                                       "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP_TH", "value"]))
      
      prf_time_periodic <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP_TH", "value"], 
                             "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMA_COT_TH", "value"])
      
      
      # 외부감사 실시 내용 중 투입 시간 정보(기말)
      quality_ctrl_time_yearend <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT_TH", "value"])
      
      cpa_time_yearend <- list("감사업무 담당 회계사" = 
                                 list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT_TH", "value"], 
                                      "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR_TH", "value"], 
                                      "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP_TH", "value"]))
      
      prf_time_yearend = c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP_TH", "value"], 
                           "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMY_COT_TH", "value"])
      
    } else {
      
      # 외부감사 실시 내용 준 투입 인력 정보
      quality_ctrl <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "NUM_QLT", "value"])
      
      cpa <- list("감사업무 담당 회계사" = 
                    list("담당이사" = df_table_hour[df_table_hour$var == "NUM_ACT", "value"], 
                         "등록 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACR", "value"], 
                         "수습 공인회계사" = df_table_hour[df_table_hour$var == "NUM_ACP", "value"]))
      
      prf <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "NUM_EXP", "value"], 
               "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "NUM_COT", "value"])
      
      # 외부감사 실시 내용 중 투입 시간 정보(분/반기)
      quality_ctrl_time_periodic <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMA_QLT", "value"])
      
      cpa_time_periodic <- list("감사업무 담당 회계사" = 
                                  list("담당이사" = df_table_hour[df_table_hour$var == "TMA_ACT", "value"],
                                       "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACR", "value"], 
                                       "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMA_ACP", "value"]))
      
      prf_time_periodic <- c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMA_EXP", "value"], 
                             "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMA_COT", "value"])
      
      # 외부감사 실시 내용 중 투입 시간 정보(기말)
      quality_ctrl_time_yearend <- c("품질관리검토자" = df_table_hour[df_table_hour$var == "TMY_QLT", "value"])
      
      cpa_time_yearend <- list("감사업무 담당 회계사" = 
                                 list("담당이사" = df_table_hour[df_table_hour$var == "TMY_ACT", "value"], 
                                      "등록 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACR", "value"], 
                                      "수습 공인회계사" = df_table_hour[df_table_hour$var == "TMY_ACP", "value"]))
      
      prf_time_yearend = c("전산감사 등 전문가" = df_table_hour[df_table_hour$var == "TMY_EXP", "value"], 
                           "수주산업 등 전문가" = df_table_hour[df_table_hour$var == "TMY_COT", "value"])
    }
    
    auditors <- c(quality_ctrl, cpa, prf)
    auditors_time_periodic <- c(quality_ctrl_time_periodic, cpa_time_periodic, prf_time_periodic)
    auditors_time_yearend <- c(quality_ctrl_time_yearend, cpa_time_yearend, prf_time_yearend)
    
    # 외부 감사 실시 내용(집합)
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
                           "감사참여자 구분별 인원수 및 감사시간" = 
                             list("투입 인원수" = auditors, 
                                  "분/반기검토(시간)" = auditors_time_periodic,
                                  "감사(시간)" = auditors_time_yearend))
    
    indv_audit_external[[n_file]] <- external_audit
    names(indv_audit_external)[n_file] <- fiscal_year
  }
  
  gross_audit_external[[n_corp]] <- indv_audit_external
  names(gross_audit_external)[n_corp] <- corp_code
  
}

# [[ write files ]]
# json
dir_path_json <- file.path(main_dir, audit_report_parsed_json_aud)
dir.create(path = dir_path_json, showWarnings = FALSE, recursive = TRUE)

gross_audit_external <- jsonlite::toJSON(gross_audit_external, pretty = TRUE, auto_unbox = TRUE, encoding = "UTF-8")
write(gross_audit_external, "external_audit.json")

# rds
dir_path_rds <- file.path(main_dir, audit_report_parsed_rds_aud)
dir.create(path = dir_path_rds, showWarnings = FALSE, recursive = TRUE)

saveRDS(object = list(internal = meta_report_audit_external,
                      external = meta_report_audit_internal),
        file = paste(dir_path_rds, "contents_both.rds", sep = "/"))