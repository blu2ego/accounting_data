#################################################
## /ward/processing/dart/r/pdr08_xml_handler.R ##
#################################################

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

value_filter_year_min_xml <- 2015
value_filter_year_max_xml <- as.numeric(substr(base_date, start = 1, stop = 4))

df_list_xml <- data.frame(path = list_xml,
                          year = stri_extract(str = list_xml, regex = "(?<=[0-9]/)(19[8-9][0-9]|20[0-2][0-9])"))
df_list_xml <- df_list_xml[(df_list_xml$year <= value_filter_year_max_xml) & (df_list_xml$year >= value_filter_year_min_xml), ]
# head(df_list_xml)

corp_list = unlist(unique(stri_extract_all(str = df_list_xml$path, regex = "(?<=corp_no_)[0-9]{6,10}")))

meta_report_audit_external = list()
meta_report_audit_internal = list()

start_corp = 1
end_corp = length(corp_list)
for(n_corp in start_corp:end_corp){
  # n_corp = 1
  df_list_xml_sub = df_list_xml[grep(pattern = paste0("corp_no_", corp_list[n_corp]), df_list_xml$path), ] 
  
  meta_report_audit_external_corp = list()
  meta_report_audit_internal_corp = list()
  
  for(n_file in 1:nrow(df_list_xml_sub)){
    # n_file = 6
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
    
    list_table_main_audit <- list(table_sub_data)
    names(list_table_main_audit[[1]]) = table_sub_names
    
    
    # communication
    list_table_com = list()
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
      
      for(n_row in 1:nrow(df_table_com)){
        list_table_com[[n_row]] = as.list(df_table_com[n_row, ])
        names(list_table_com)[n_row] = n_row
      }
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
    
    xml_doc %>% 
      html_nodes(xpath = '//*/td[@usermark="F-BT14"]') %>% 
      .[1] %>% 
      html_text() %>% 
      gsub(pattern = "\\n", replacement = "") -> doc_turn
    
    meta_report_audit <- list("year_end" = substr(audit_date_end, start = 5, stop = 8), 
                              "corp_cls" = df_corp_info[1, "corp_cls"], 
                              "corp_name" = corp_name,
                              "corp_code" = corp_code, 
                              "stock_code" = df_corp_info[1, "stock_code"], 
                              "report_name" = doc_title,  
                              "rcept_no" = recept_no, 
                              "flr_name" = df_corp_info[1, "flr_nm"], 
                              "rcept_dt" = ifelse(test = length(df_corp_info[doc_loc, "rcept_dt"]) == 0, yes = NA, no = df_corp_info[doc_loc, "rcept_dt"]), 
                              "rm" = ifelse(test = df_corp_info[1, "rm"] == "", yes = NA, no = df_corp_info[1, "rm"]),
                              "turn" = doc_turn)

    
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
                                                                                  "감사(시간)" = auditors_time_yearend),
                                    "주요 감사실시내용" = list_table_main_audit[[1]],
                                    "감사와의 커뮤니케이션" = list_table_com)
    
    meta_report_audit_external_corp[[n_file]] = external_audit_contents
    names(meta_report_audit_external_corp)[n_file] <- substr(audit_date_end, start = 1, stop = 4)
    
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
    
    xml_doc_internal_text <- xml_doc_internal_text[xml_doc_internal_text != ""]
    
    list_doc_internal <- xml_doc_internal_text
    
    # 내부회계관리제도 감사 또는 검토 의견 중 독립된 감사인의 내부회계관리제도 감사보고서
    internal_accounting_audit <- list(list_doc_report)
    
    # 내부회계관리제도 감사 또는 검토 의견 중 회사의 내부회계관리제도 운영실태보고서
    internal_accounting_operation <- list(list_doc_internal)
    
    # 내부회계관리제도 감사 또는 검토 의견(집합)
    internal_accounting_contents <- list("보고서" = meta_report_audit, 
                                         "독립된 감사인의 내부회계관리제도 감사보고서" = internal_accounting_audit, 
                                         "내부회계관리제도 운영실태 보고" = internal_accounting_operation)
    
    meta_report_audit_internal_corp[[n_file]] = internal_accounting_contents
    names(meta_report_audit_internal_corp)[n_file] = substr(audit_date_end, start = 1, stop = 4)
  }
  
  meta_report_audit_external[[n_corp]] = meta_report_audit_external_corp
  names(meta_report_audit_external)[n_corp] = paste(gsub(pattern = " ", replacement = "", corp_name),
                                                    corp_code, sep = "_")
  
  meta_report_audit_internal[[n_corp]] = meta_report_audit_internal_corp
  names(meta_report_audit_internal)[n_corp] = paste(gsub(pattern = " ", replacement = "", corp_name),
                                                    corp_code, sep = "_")
}

# [[ write files ]]
# json
dir_path_json <- file.path(main_dir, audit_report_parsed_json_aud)
dir.create(path = dir_path_json, showWarnings = FALSE, recursive = TRUE)

# json - external
write_json(meta_report_audit_external, 
           path = paste(dir_path_json, "external_audit_contents.json", sep = "/"),
           encoding = "UTF-8")

# json - internal
write_json(meta_report_audit_internal,
           path = paste(dir_path_json, "internal_accounting_contents.json", sep = "/"),
           encoding = "UTF-8") 

# rds
dir_path_rds <- file.path(main_dir, audit_report_parsed_rds_aud)
dir.create(path = dir_path_rds, showWarnings = FALSE, recursive = TRUE)

saveRDS(object = list(internal = meta_report_audit_external,
                      external = meta_report_audit_internal),
        file = paste(dir_path_rds, "contents_both.rds", sep = "/"))