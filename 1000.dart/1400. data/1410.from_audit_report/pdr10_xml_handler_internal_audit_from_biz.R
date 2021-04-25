#########################################################################
## /ward/processing/dart/r/pdr10_xml_handler_internal_audit_from_biz.R ##
#########################################################################

# list up audit report from biz report(A001)
list_doc <- list.files(path = file.path(main_dir, biz_report_list_csv_dir),
                       full.names = TRUE,
                       recursive = TRUE)

list_xml <- list.files(path = file.path(main_dir, audit_report_xml_from_biz), # 경로명 수정 필요
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
gross_audit_internal_from_biz <- list()
indv_audit_internal_from_biz <- list()


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
    

##### 내부회계관리제도에 대한 감사의견 ######
    xml_doc %>% 
      html_nodes(xpath = "//*/section-1/image/..") %>% 
      html_children() -> xml_doc_internal
    
    if(length(xml_doc_internal) > 0){
      xml_doc_internal[1] %>% 
        html_text() -> xml_doc_report_title
      
      xml_doc_internal[2:(grep(pattern = "<img", x = xml_doc_internal)[1] - 1)] %>% 
        as.character() %>% 
        strsplit(split = "\\n|&cr;|cr;|&amp") %>% 
        unlist() -> xml_doc_internal_text 
      
      xml_doc_internal_text_pos <- grep(pattern = "usermark", x = xml_doc_internal_text)
      
      xml_doc_internal_text[xml_doc_internal_text_pos] <- paste0("@", xml_doc_internal_text[xml_doc_internal_text_pos]) 
      
      xml_doc_internal_text %>% 
        gsub(pattern = "<.*?>", replacement = "") %>% 
        gsub(pattern = " {2,}", replacement = " ") %>% 
        gsub(pattern = "^ | $|;$", replacement = "") -> xml_doc_internal_text
      
      list_doc_internal <- xml_doc_internal_text[xml_doc_internal_text != ""]
    } else {
      list_doc_internal <- NA
    }

    
##### 내부회계관리제도 감사 또는 검토 의견 중 회사의 내부회계관리제도 운영실태보고서 #####
    internal_accounting_operation <- c("운영실태보고서" = "추가 예정")
    
##### 내부회계관리제도 감사 또는 검토의견(집합) #####
    internal_audit_report <- list("year_end" = year_end, 
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
                                  "내부회계관리제도 감사보고서" = paste(list_doc_internal, collapse = " "))
    
    indv_audit_internal_from_biz[[n_file]] <- internal_audit_report
    names(indv_audit_internal_from_biz)[n_file] <- fiscal_year
  }
    
  gross_audit_internal_from_biz[[n_corp]] <- indv_audit_internal_from_biz
  names(gross_audit_internal_from_biz)[n_corp] <- corp_code
  indv_audit_internal_from_biz <- list()
  closeAllConnections()
}

#### write for rds #####
saveRDS(gross_audit_internal_from_biz, file = paste0(main_dir, audit_report_from_rds_biz, "internal_audit_from_biz.rds"))

##### write for json #####
gross_audit_internal_json <- jsonlite::toJSON(gross_audit_internal_from_biz, pretty = TRUE, auto_unbox = TRUE, encoding = "UTF-8")
write(gross_audit_internal_json, file = paste0(main_dir, audit_report_json_biz, "internal_audit_biz.json"))