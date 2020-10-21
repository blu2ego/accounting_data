setwd("/home/woojune/projects/ward/results/dart/ia_ops_reports/ia_ops_reports_part_5/")

library(tabulizer)
library(stringi)
library(plyr)
library(SOAR)

ia_ops_reports_part_5 <- list.files(recursive = TRUE)
SOAR::Store(ia_ops_reports_part_5)

ia_ops_reports_part_5 <- ia_ops_reports_part_5[file.info(ia_ops_reports_part_5)[1]$size > 0]
SOAR::Store(ia_ops_reports_part_5)

smry_ia_ops_reports_part_5 <- data.frame(path_part_5 = ia_ops_reports_part_5,
                                     corp_code_part_5 = unlist(stri_extract_all(str = ia_ops_reports_part_5, regex = "(?<=corp_code_)[0-9]{6,8}")),
                                     doc_no_part_5 = unlist(stri_extract_all(str = ia_ops_reports_part_5, regex = "(?<=[0-9]_)[0-9]{9,14}")))
SOAR::Store(smry_ia_ops_reports_part_5)

smry_ia_ops_reports_part_5[, "year_part_5"] <- substr(x = smry_ia_ops_reports_part_5$doc_no_part_5, start = 1, stop = 4)
SOAR::Store(smry_ia_ops_reports_part_5)

recent_doc <- function(x){
  aggregate(data = x, . ~ year_part_5, FUN = "max")   
}

smry_ia_ops_reports_split_part_5 <- split(x = smry_ia_ops_reports_part_5, f = smry_ia_ops_reports_part_5$corp_code_part_5)
SOAR::Store(smry_ia_ops_reports_split_part_5)
smry_ia_ops_reports_part_5 <- lapply(smry_ia_ops_reports_split_part_5, FUN = "recent_doc")
smry_ia_ops_reports_part_5 <- do.call(rbind, smry_ia_ops_reports_part_5)
rownames(smry_ia_ops_reports_part_5) <- NULL
SOAR::Store(smry_ia_ops_reports_part_5)

gross_ia_ops_report_part_5 <- list()
SOAR::Store(gross_ia_ops_report_part_5)

indv_ia_ops_report_part_5 <- list()
SOAR::Store(indv_ia_ops_report_part_5)

gross_ia_locations_part_5 <- list()
SOAR::Store(gross_ia_locations_part_5)

indv_ia_locations_part_5 <- list()
SOAR::Store(indv_ia_locations_part_5)

unq_corp_corps_part_5 <- unique(smry_ia_ops_reports_part_5$corp_code_part_5)
SOAR::Store(unq_corp_corps_part_5)

no_unq_corp_codes_part_5 <- length(unq_corp_corps_part_5)
SOAR::Store(no_unq_corp_codes_part_5)

file_logs_part_5 <- file("/home/woojune/projects/ward/processing/dart/r/dstrb_ia_ops_report/ia_ops_logs_part_5.txt")
sink("/home/woojune/projects/ward/processing/dart/r/dstrb_ia_ops_report/ia_ops_logs_part_5.txt")
for(code_part_5 in 1:no_unq_corp_codes_part_5) {
  
  cat("===================================================================", sep = "\n")
  cat(paste(code_part_5, "번째 기업 시행: 기업코드 = ", unq_corp_corps_part_5[code_part_5], "시작 시각:", Sys.time()), sep = "\n")
  cat("===================================================================", sep = "\n")
  
  ia_ops_reports_by_code_part_5 <- smry_ia_ops_reports_part_5[smry_ia_ops_reports_part_5$corp_code_part_5 == unq_corp_corps_part_5[code_part_5], ]
  SOAR::Store(ia_ops_reports_by_code_part_5)
  
  for (report_part_5 in 1:nrow(ia_ops_reports_by_code_part_5)) {
  
    pages_part_5 <- tryCatch(tabulizer::get_n_pages(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"]),
                      error = function(e_part_5) cat(paste("tabulizer::get_n_page 에러 - 문서 = ", ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], 
                                                    "/error message:", as.character(e_part_5)), sep = "\n"),
                      warning = function(w_part_5) cat("warning message:", as.character(w_part_5)))
  
    SOAR::Store(pages_part_5)  
    
  tables_part_5 <- c()
  
  for (page_part_5 in 1:pages_part_5) {
    
    page_tables_stream_part_5 <- tryCatch(tabulizer::extract_tables(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], 
                                                                    pages = page_part_5, method = "stream"), 
                                   error = function(e_part_5) page_tables_stream_part_5 <- NULL,
                                   warning = function(w_part_5) cat("warning message:", as.character(w_part_5)))
    
    SOAR::Store(page_tables_stream_part_5)
    
    page_tables_decide_part_5 <- tryCatch(tabulizer::extract_tables(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], 
                                                                    pages = page_part_5, method = "decide"),
                                   error = function(e_part_5) page_tables_decide_part_5 <- NULL,
                                   warning = function(w_part_5) cat("warning message:", as.character(w_part_5)))
    
    SOAR::Store(page_tables_decide_part_5)
    
    if (length(page_tables_stream_part_5) != 0 & length(page_tables_decide_part_5) != 0) {
      if (length(page_tables_stream_part_5) > length(page_tables_decide_part_5)) {
        tables_part_5 <- c(tables_part_5, page_tables_stream_part_5)
      } else tables_part_5 <- c(tables_part_5, page_tables_decide_part_5)
    } 
    cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ", pages_part_5, " 페이지 중 ", page_part_5, "번째 페이지의 표 추출"), "\n")
  }
  
  SOAR::Store(tables_part_5)
  
  ##### meta information #####
  
  corp_code_part_5 <- ia_ops_reports_by_code_part_5[report_part_5, ]$corp_code_part_5
  SOAR::Store(corp_code_part_5)
  
  fiscal_year_part_5 <- as.character(as.numeric(ia_ops_reports_by_code_part_5[report_part_5, ]$year_part_5) - 1)
  SOAR::Store(fiscal_year_part_5)
  
  ##### extract tables from internal accounting operation report #####
  
  location_ia_ipv_part_5 <- grep(pattern = "개선일자", tables_part_5)
  SOAR::Store(location_ia_ipv_part_5)
  
  location_ia_mgr_part_5 <- grep(pattern = "담당업무", tables_part_5)
  SOAR::Store(location_ia_mgr_part_5)
  
  location_ia_staff_part_5 <- grep(pattern = "보유비율", tables_part_5)
  SOAR::Store(location_ia_staff_part_5)
  
  location_ia_staff_carrier_part_5 <- grep(pattern = "등록여부", tables_part_5)
  SOAR::Store(location_ia_staff_carrier_part_5)
  
  tmp_locations_1_part_5 <- grep(pattern = "보고대상", tables_part_5)
  SOAR::Store(tmp_locations_1_part_5)
  
  tmp_locations_2_part_5 <- grep(pattern = "보고내용", tables_part_5)
  SOAR::Store(tmp_locations_2_part_5)
  
  if (length(tmp_locations_1_part_5) == 0){
    if (length(tmp_locations_2_part_5) == 0) {
      location_ia_report_mgr_part_5 <- location_ia_report_auditor_part_5 <- NULL
    } else {location_ia_report_auditor_part_5 <- tmp_locations_2_part_5[1]
            location_ia_report_mgr_part_5 <- NULL}
  } else if (length(tmp_locations_2_part_5) == 0) {
    location_ia_report_mgr_part_5 <- tmp_locations_1_part_5
    location_ia_report_auditor_part_5 <- NULL 
  } else {location_ia_report_mgr_part_5 <- tmp_locations_1_part_5
          location_ia_report_auditor_part_5 <- tmp_locations_2_part_5[2]}
  
  SOAR::Store(location_ia_report_mgr_part_5)
  SOAR::Store(location_ia_report_auditor_part_5)
  
  location_ia_report_3rd_part_5 <- grep(pattern = "의견내용", tables_part_5)
  SOAR::Store(location_ia_report_3rd_part_5)
  
  location_ia_violation_part_5 <- grep(pattern = "위반내용", tables_part_5)
  SOAR::Store(location_ia_violation_part_5)
  
  lag_location_ia_mgr_part_5            <- location_ia_mgr_part_5 - 1
  SOAR::Store(lag_location_ia_mgr_part_5)
  
  lag_location_ia_staff_part_5          <- location_ia_staff_part_5 - 1 
  SOAR::Store(lag_location_ia_staff_part_5)
  
  lag_location_ia_staff_carrier_part_5  <- location_ia_staff_carrier_part_5 - 1
  SOAR::Store(lag_location_ia_staff_carrier_part_5)
  
  lag_location_ia_report_mgr_part_5     <- location_ia_report_mgr_part_5 - 1
  SOAR::Store(lag_location_ia_report_mgr_part_5)
  
  lag_location_ia_report_auditor_part_5 <- location_ia_report_auditor_part_5 - 1
  SOAR::Store(lag_location_ia_report_auditor_part_5)
  
  lag_location_ia_report_3rd_part_5     <- location_ia_report_3rd_part_5 - 1
  SOAR::Store(lag_location_ia_report_3rd_part_5)
  
  lag_location_ia_violation_part_5      <- location_ia_violation_part_5 - 1
  SOAR::Store(lag_location_ia_violation_part_5)
  
  ###### ia_ipv_part_5 #####
  tryCatch({  
  if (length(location_ia_ipv_part_5) > 0) { 
    if (length(location_ia_mgr_part_5) > 0){
      if (location_ia_mgr_part_5 - location_ia_ipv_part_5 == 1) {
        ia_ipv_part_5 <- tryCatch(tables_part_5[[location_ia_ipv_part_5]],
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_mgr_part_5]), 
                                error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_staff_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_staff_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_staff_carrier_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_staff_carrier_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_mgr_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_report_mgr_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 다섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 다섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_auditor_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_report_auditor_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 여섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 여섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_3rd_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_report_3rd_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 일곱 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 일곱 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:lag_location_ia_violation_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 여덟 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 여덟 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_ipv_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_ipv_part_5:length(tables_part_5)]),
                              error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 아홉 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                              warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 아홉 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_ipv_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_ipv_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_ipv_part_5)
  
  ##### ia_mgr_part_5 #####
  tryCatch({    
  if (length(location_ia_mgr_part_5) > 0) { 
   if (length(location_ia_staff_part_5) > 0){
      if (location_ia_staff_part_5 - location_ia_mgr_part_5 == 1) {
        ia_mgr_part_5 <- tryCatch(tables_part_5[[location_ia_mgr_part_5]],
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_staff_part_5]),
                                error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_staff_carrier_part_5) > 0) {
      ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_staff_carrier_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_mgr_part_5) > 0) {
      ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_report_mgr_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_auditor_part_5) > 0) {
      ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_report_auditor_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 다섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 다섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_3rd_part_5) > 0) {
      ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_report_3rd_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 여섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 여섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:lag_location_ia_violation_part_5]),
                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 일곱 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 일곱 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_mgr_part_5:length(tables_part_5)]),
                              error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 여덟 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                              warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 여덟 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_mgr_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_mgr_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_mgr_part_5)
  
  ##### ia_staff_part_5 #####
  tryCatch({  
  if (length(location_ia_staff_part_5) > 0) { 
    if (length(location_ia_staff_carrier_part_5) > 0){
      if (location_ia_staff_carrier_part_5 - location_ia_staff_part_5 == 1) {
        ia_staff_part_5 <- tryCatch(tables_part_5[[location_ia_staff_part_5]], 
                             error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                             warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:lag_location_ia_staff_carrier_part_5]),
                                  error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                  warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_mgr_part_5) > 0) {
      ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:lag_location_ia_report_mgr_part_5]), 
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_auditor_part_5) > 0) {
      ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:lag_location_ia_report_auditor_part_5]),
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_3rd_part_5) > 0) {
      ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:lag_location_ia_report_3rd_part_5]),
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 다섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 다섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:lag_location_ia_violation_part_5]),
                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 여섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 여섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_staff_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_part_5:length(tables_part_5)]),
                                error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 일곱 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 일곱 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_staff_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_staff_part_5)
  
  ##### ia_staff_carrier_part_5 #####
  tryCatch({    
  if (length(location_ia_staff_carrier_part_5) > 0) { 
    if (length(location_ia_report_mgr_part_5) > 0){
      if (location_ia_report_mgr_part_5 - location_ia_staff_carrier_part_5 == 1) {
        ia_staff_carrier_part_5 <- tryCatch(tables_part_5[[location_ia_staff_carrier_part_5]],
                                     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_staff_carrier_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_carrier_part_5:lag_location_ia_report_mgr_part_5]),
                                          error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                          warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_auditor_part_5) > 0) {
      ia_staff_carrier_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_carrier_part_5:lag_location_ia_report_auditor_part_5]),
                                   error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                   warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_3rd_part_5) > 0) {
      ia_staff_carrier_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_carrier_part_5:lag_location_ia_report_3rd_part_5]),
                                   error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                   warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_staff_carrier_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_carrier_part_5:lag_location_ia_violation_part_5]),
                                   error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 다섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                   warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 다섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_staff_carrier_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_staff_carrier_part_5:length(tables_part_5)]),
                                        error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 여섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                        warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 여섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_staff_carrier_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_staff_carrier_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_staff_carrier_part_5)
  
  ##### ia_report_mgr #####
  tryCatch({    
  if (length(location_ia_report_mgr_part_5) > 0) { 
    if (length(location_ia_report_auditor_part_5) > 0){
      if (location_ia_report_auditor_part_5 - location_ia_report_mgr_part_5 == 1) {
        ia_report_mgr_part_5 <- tryCatch(tables_part_5[[location_ia_report_mgr_part_5]],
                                  error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                  warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_report_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_mgr_part_5:lag_location_ia_report_auditor_part_5]),
                                       error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                       warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_report_3rd_part_5) > 0) {
      ia_report_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_mgr_part_5:lag_location_ia_report_3rd_part_5]),
                                error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_report_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_mgr_part_5:lag_location_ia_violation_part_5]),
                                error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_report_mgr_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_mgr_part_5:length(tables_part_5)]),
                                     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 다섯 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 다섯 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_report_mgr_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_mgr_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_report_mgr_part_5)
  
  ##### ia_rerport_auditor #####
  tryCatch({    
  if (length(location_ia_report_auditor_part_5) > 0) { 
    if (length(location_ia_report_3rd_part_5) > 0){
      if (location_ia_report_3rd_part_5 - location_ia_report_auditor_part_5 == 1) {
        ia_report_auditor_part_5 <- tryCatch(tables_part_5[[location_ia_report_auditor_part_5]],
                                      error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                      warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_report_auditor_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_auditor_part_5:lag_location_ia_report_3rd_part_5]),
                                           error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                           warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else if (length(location_ia_violation_part_5) > 0) {
      ia_report_auditor_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_auditor_part_5:lag_location_ia_violation_part_5]),
                                    error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                    warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_report_auditor_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_auditor_part_5:length(tables_part_5)]),
                                         error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 네 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                         warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 네 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_report_auditor_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_auditor_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_report_auditor_part_5)
  
  ##### ia_rerport_3rd #####
  tryCatch({    
  if (length(location_ia_report_3rd_part_5) > 0) { 
    if (length(location_ia_violation_part_5) > 0){
      if (location_ia_violation_part_5 - location_ia_report_3rd_part_5 == 1) {
        ia_report_3rd_part_5 <- tryCatch(tables_part_5[[location_ia_report_3rd_part_5]],
                                  error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                  warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
      } else ia_report_3rd_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_3rd_part_5:lag_location_ia_violation_part_5]),
                                       error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                       warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_report_3rd_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_report_3rd_part_5:length(tables_part_5)]),
                                     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 세 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 세 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_report_3rd_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_report_3rd_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_report_3rd_part_5)
  
  ##### ia_violation #####
  tryCatch({    
  if (length(location_ia_violation_part_5) > 0) { 
    if (length(tables_part_5) - length(location_ia_violation_part_5) == 0) {
      ia_violation_part_5 <- tryCatch(tables_part_5[[location_ia_violation_part_5]],
                               error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation_part_5 테이블 중 첫 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                               warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation_part_5 테이블 중 첫 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
    } else ia_violation_part_5 <- tryCatch(do.call(rbind.fill.matrix, tables_part_5[location_ia_violation_part_5:length(tables_part_5)]), 
                                    error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation 테이블 중 두 번째 조건 에러:", as.character(e_part_5)), sep = "\n"),
                                    warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation 테이블 중 두 번째 조건 경고:", as.character(w_part_5)), sep = "\n"))
  } else ia_violation_part_5 <- NA}, 
     error = function(e_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation_part_5 테이블 중 기타 에러:", as.character(e_part_5))),
     warning = function(w_part_5) cat(paste0(ia_ops_reports_by_code_part_5[report_part_5, "path_part_5"], "의 ia_violation_part_5 테이블 중 기타 경고:", as.character(w_part_5)))
  )
  
  SOAR::Store(ia_violation_part_5)
  SOAR::Store(page_part_5)
  SOAR::Store(report_part_5)
  SOAR::Store(tables_part_5)
  
  ##### indv ia ops report #####
  
  indv_ia_ops_report_by_code_part_5 <- list("고유번호" = corp_code_part_5, 
                                     "주요 개선내용" = ia_ipv_part_5,
                                     "책임자 현황" = ia_mgr_part_5,
                                     "인력 보유현황" = ia_staff_part_5,
                                     "경력 및 교육 실적" = ia_staff_carrier_part_5,
                                     "대표자가 보고한 운영실태보고서" = ia_report_mgr_part_5,
                                     "감사가 보고한 운영실태보고서" = ia_report_auditor_part_5,
                                     "감사인의 검토의견" = ia_report_3rd_part_5,
                                     "내부회계관리규정 위반 징계 내용" = ia_violation_part_5
                                     )
  
  SOAR::Store(indv_ia_ops_report_by_code_part_5)
  
  indv_ia_location_part_5 <- list("고유번호" = corp_code_part_5, 
                                  "주요 개선내용" = location_ia_ipv_part_5,
                                  "책임자 현황" = location_ia_mgr_part_5,
                                  "인력 보유현황" = location_ia_staff_part_5,
                                  "경력 및 교육 실적" = location_ia_staff_carrier_part_5,
                                  "대표자가 보고한 운영실태보고서" = location_ia_report_mgr_part_5,
                                  "감사가 보고한 운영실태보고서" = location_ia_report_auditor_part_5,
                                  "감사인의 검토의견" = location_ia_report_3rd_part_5,
                                  "내부회계관리규정 위반 징계 내용" = location_ia_violation_part_5
                                  )
  
  SOAR::Store(indv_ia_location_part_5)
  
  indv_ia_ops_report_part_5[[report_part_5]] <- indv_ia_ops_report_by_code_part_5
  names(indv_ia_ops_report_part_5)[[report_part_5]] <- fiscal_year_part_5
  
  SOAR::Store(indv_ia_ops_report_part_5)
  
  indv_ia_locations_part_5[[report_part_5]] <- indv_ia_location_part_5
  names(indv_ia_locations_part_5)[[report_part_5]] <- fiscal_year_part_5
  
  SOAR::Store(indv_ia_locations_part_5)
  
  }
  gross_ia_ops_report_part_5[[code_part_5]] <- indv_ia_ops_report_part_5
  names(gross_ia_ops_report_part_5)[[code_part_5]] <- corp_code_part_5
  # indv_ia_ops_report_part_5 <- list()
  
  SOAR::Store(gross_ia_ops_report_part_5)
  
  gross_ia_locations_part_5[[code_part_5]] <- indv_ia_locations_part_5
  names(gross_ia_locations_part_5)[[code_part_5]] <- corp_code_part_5
  
  SOAR::Store(gross_ia_locations_part_5)
  
  cat(paste(code_part_5, "번째 기업 시행: 기업코드 = ", unq_corp_corps_part_5[code_part_5], "종료 시각:", Sys.time()), sep = "\n")
  
}
sink()