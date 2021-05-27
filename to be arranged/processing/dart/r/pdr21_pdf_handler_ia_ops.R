setwd("/home/woojune/projects/ward/results/dart/operation_report/")

library(tabulizer)
library(stringi)
library(plyr)

ia_ops_reports <- list.files(recursive = TRUE)

ia_ops_reports <- ia_ops_reports[file.info(ia_ops_reports)[1]$size > 0]

smry_ia_ops_reports <- data.frame(path = ia_ops_reports,
                                     corp_code = unlist(stri_extract_all(str = ia_ops_reports, regex = "(?<=corp_code_)[0-9]{6,8}")),
                                     doc_no = unlist(stri_extract_all(str = ia_ops_reports, regex = "(?<=[0-9]_)[0-9]{9,14}")))
smry_ia_ops_reports[, "year"] <- substr(x = smry_ia_ops_reports$doc_no, start = 1, stop = 4)

recent_doc <- function(x){
  aggregate(data = x, . ~ year, FUN = "max")   
}

smry_ia_ops_reports_split <- split(x = smry_ia_ops_reports, f = smry_ia_ops_reports$corp_code)
smry_ia_ops_reports <- lapply(smry_ia_ops_reports_split, FUN = "recent_doc")
smry_ia_ops_reports <- do.call(rbind, smry_ia_ops_reports)
rownames(smry_ia_ops_reports) <- NULL

gross_ia_ops_report <- list()
indv_ia_ops_report <- list()

gross_ia_ops_report_text <- list()
indv_report_text <- list()

gross_ia_locations <- list()
indv_ia_locations <- list()

unq_corp_corps <- unique(smry_ia_ops_reports$corp_code)
no_unq_corp_codes <- length(unq_corp_corps)

file_logs <- file("/home/woojune/projects/ward/ia_ops_logs.txt")
sink("../ia_ops_logs.txt")
for(code in 1:no_unq_corp_codes) {
  
  cat(paste(code, "번째 기업 시행: 기업코드 = ", unq_corp_corps[code], "시작 시각:", Sys.time()), sep = "\n")
  
  cat("===================================================================", sep = "\n")
  cat("===================================================================", sep = "\n")
  
  ia_ops_reports_by_code <- smry_ia_ops_reports[smry_ia_ops_reports$corp_code == unq_corp_corps[code], ]
    
  for (report in 1:nrow(ia_ops_reports_by_code)) {
  
    pages <- tryCatch(tabulizer::get_n_pages(ia_ops_reports_by_code[report, "path"]),
                      error = function(e) cat(paste("tabulizer::get_n_page 에러 - 문서 = ", ia_ops_reports_by_code[report, "path"], 
                                                    "/error message:", as.character(e)), sep = "\n"),
                      warning = function(w) cat("warning message:", as.character(w)))
  
  tables <- c()
  for (page in 1:pages) {
    
    # cat(paste(code, "번째 기업 시행 / 기업코드 = ", unq_corp_corps[code], "/ 문서 코드 = ", ia_ops_reports_by_code[report, "path"]), sep = "\n")
    # cat("===================================================================", sep = "\n")
    
    page_tables_stream <- tryCatch(tabulizer::extract_tables(ia_ops_reports_by_code[report, "path"], pages = page, method = "stream"), 
                                   error = function(e) page_tables_stream <- NULL)
    page_tables_decide <- tryCatch(tabulizer::extract_tables(ia_ops_reports_by_code[report, "path"], pages = page, method = "decide"),
                                   error = function(e) page_tables_decide <- NULL)
    if (length(page_tables_stream) != 0 & length(page_tables_decide) != 0) {
      if (length(page_tables_stream) > length(page_tables_decide)) {
        tables <- c(tables, page_tables_stream)
      } else tables <- c(tables, page_tables_decide)
    } 
    cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ", pages, " 페이지 중 ", page, "번째 페이지의 표 추출"), "\n")
  }
  
  ##### meta information #####
  
  corp_code <- ia_ops_reports_by_code[report, ]$corp_code
  
  fiscal_year <- as.character(as.numeric(ia_ops_reports_by_code[report, ]$year) - 1)
  
  ##### extract tables from internal accounting operation report #####
  
  location_ia_ipv <- grep(pattern = "개선일자", tables)
  location_ia_mgr <- grep(pattern = "담당업무", tables)
  location_ia_staff <- grep(pattern = "보유비율", tables)
  location_ia_staff_carrier <- grep(pattern = "등록여부", tables)
  
  tmp_locations_1 <- grep(pattern = "보고대상", tables)
  tmp_locations_2 <- grep(pattern = "보고내용", tables)
  
  if (length(tmp_locations_1) == 0){
    if (length(tmp_locations_2) == 0) {
      location_ia_report_mgr <- location_ia_report_auditor <- NULL
    } else {location_ia_report_auditor <- tmp_locations_2[1]
            location_ia_report_mgr <- NULL}
  } else if (length(tmp_locations_2) == 0) {
    location_ia_report_mgr <- tmp_locations_1
    location_ia_report_auditor <- NULL 
  } else {location_ia_report_mgr <- tmp_locations_1
          location_ia_report_auditor <- tmp_locations_2[2]}
  
  location_ia_report_3rd <- grep(pattern = "의견내용", tables)
  location_ia_violation <- grep(pattern = "위반내용", tables)
    
  lag_location_ia_mgr            <- location_ia_mgr - 1
  lag_location_ia_staff          <- location_ia_staff - 1 
  lag_location_ia_staff_carrier  <- location_ia_staff_carrier - 1
  lag_location_ia_report_mgr     <- location_ia_report_mgr - 1
  lag_location_ia_report_auditor <- location_ia_report_auditor - 1
  lag_location_ia_report_3rd     <- location_ia_report_3rd - 1
  lag_location_ia_violation      <- location_ia_violation - 1
    
  ###### ia_ipv #####
  tryCatch({  
  if (length(location_ia_ipv) > 0) { 
    if (length(location_ia_mgr) > 0){
      if (location_ia_mgr - location_ia_ipv == 1) {
        ia_ipv <- tryCatch(tables[[location_ia_ipv]],
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_mgr]), 
                                error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_staff) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_staff]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_staff_carrier) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_staff_carrier]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_mgr) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_report_mgr]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 다섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 다섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_auditor) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_report_auditor]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 여섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 여섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_3rd) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_report_3rd]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 일곱 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 일곱 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:lag_location_ia_violation]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 여덟 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 여덟 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_ipv <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_ipv:length(tables)]),
                              error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 아홉 번째 조건 에러:", as.character(e)), sep = "\n"),
                              warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 아홉 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_ipv <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_ipv 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_mgr #####
  tryCatch({    
  if (length(location_ia_mgr) > 0) { 
   if (length(location_ia_staff) > 0){
      if (location_ia_staff - location_ia_mgr == 1) {
        ia_mgr <- tryCatch(tables[[location_ia_mgr]],
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_staff]),
                                error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_staff_carrier) > 0) {
      ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_staff_carrier]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_mgr) > 0) {
      ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_report_mgr]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_auditor) > 0) {
      ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_report_auditor]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 다섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 다섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_3rd) > 0) {
      ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_report_3rd]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 여섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 여섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:lag_location_ia_violation]),
                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 일곱 번째 조건 에러:", as.character(e)), sep = "\n"),
                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 일곱 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_mgr:length(tables)]),
                              error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 여덟 번째 조건 에러:", as.character(e)), sep = "\n"),
                              warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 여덟 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_mgr <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_mgr 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_staff #####
  tryCatch({  
  if (length(location_ia_staff) > 0) { 
    if (length(location_ia_staff_carrier) > 0){
      if (location_ia_staff_carrier - location_ia_staff == 1) {
        ia_staff <- tryCatch(tables[[location_ia_staff]], 
                             error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                             warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:lag_location_ia_staff_carrier]),
                                  error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                  warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_mgr) > 0) {
      ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:lag_location_ia_report_mgr]), 
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_auditor) > 0) {
      ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:lag_location_ia_report_auditor]),
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_3rd) > 0) {
      ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:lag_location_ia_report_3rd]),
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 다섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 다섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:lag_location_ia_violation]),
                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 여섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 여섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_staff <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff:length(tables)]),
                                error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 일곱 번째 조건 에러:", as.character(e)), sep = "\n"),
                                warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 일곱 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_staff <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_staff_carrier #####
  tryCatch({    
  if (length(location_ia_staff_carrier) > 0) { 
    if (length(location_ia_report_mgr) > 0){
      if (location_ia_report_mgr - location_ia_staff_carrier == 1) {
        ia_staff_carrier <- tryCatch(tables[[location_ia_staff_carrier]],
                                     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                                     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_staff_carrier <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff_carrier:lag_location_ia_report_mgr]),
                                          error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                          warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_auditor) > 0) {
      ia_staff_carrier <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff_carrier:lag_location_ia_report_auditor]),
                                   error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                                   warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_3rd) > 0) {
      ia_staff_carrier <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff_carrier:lag_location_ia_report_3rd]),
                                   error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                                   warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_staff_carrier <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff_carrier:lag_location_ia_violation]),
                                   error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 다섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                                   warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 다섯 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_staff_carrier <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_staff_carrier:length(tables)]),
                                        error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 여섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                                        warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 여섯 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_staff_carrier <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_staff_carrier 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_rerport_mgr #####
  tryCatch({    
  if (length(location_ia_report_mgr) > 0) { 
    if (length(location_ia_report_auditor) > 0){
      if (location_ia_report_auditor - location_ia_report_mgr == 1) {
        ia_report_mgr <- tryCatch(tables[[location_ia_report_mgr]],
                                  error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                                  warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_report_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_mgr:lag_location_ia_report_auditor]),
                                       error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                       warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_report_3rd) > 0) {
      ia_report_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_mgr:lag_location_ia_report_3rd]),
                                error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                                warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_report_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_mgr:lag_location_ia_violation]),
                                error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                                warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_report_mgr <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_mgr:length(tables)]),
                                     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 다섯 번째 조건 에러:", as.character(e)), sep = "\n"),
                                     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 다섯 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_report_mgr <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_mgr 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_rerport_auditor #####
  tryCatch({    
  if (length(location_ia_report_auditor) > 0) { 
    if (length(location_ia_report_3rd) > 0){
      if (location_ia_report_3rd - location_ia_report_auditor == 1) {
        ia_report_auditor <- tryCatch(tables[[location_ia_report_auditor]],
                                      error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                                      warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_report_auditor <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_auditor:lag_location_ia_report_3rd]),
                                           error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                           warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else if (length(location_ia_violation) > 0) {
      ia_report_auditor <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_auditor:lag_location_ia_violation]),
                                    error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                                    warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_report_auditor <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_auditor:length(tables)]),
                                         error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 네 번째 조건 에러:", as.character(e)), sep = "\n"),
                                         warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 네 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_report_auditor <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_auditor 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_rerport_3rd #####
  tryCatch({    
  if (length(location_ia_report_3rd) > 0) { 
    if (length(location_ia_violation) > 0){
      if (location_ia_violation - location_ia_report_3rd == 1) {
        ia_report_3rd <- tryCatch(tables[[location_ia_report_3rd]],
                                  error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                                  warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
      } else ia_report_3rd <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_3rd:lag_location_ia_violation]),
                                       error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                       warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_report_3rd <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_report_3rd:length(tables)]),
                                     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 세 번째 조건 에러:", as.character(e)), sep = "\n"),
                                     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 세 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_report_3rd <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_report_3rd 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### ia_violation #####
  tryCatch({    
  if (length(location_ia_violation) > 0) { 
    if (length(tables) - length(location_ia_violation) == 0) {
      ia_violation <- tryCatch(tables[[location_ia_violation]],
                               error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 첫 번째 조건 에러:", as.character(e)), sep = "\n"),
                               warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 첫 번째 조건 경고:", as.character(w)), sep = "\n"))
    } else ia_violation <- tryCatch(do.call(rbind.fill.matrix, tables[location_ia_violation:length(tables)]), 
                                    error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 두 번째 조건 에러:", as.character(e)), sep = "\n"),
                                    warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 두 번째 조건 경고:", as.character(w)), sep = "\n"))
  } else ia_violation <- NA}, 
     error = function(e) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 기타 에러:", as.character(e))),
     warning = function(w) cat(paste0(ia_ops_reports_by_code[report, "path"], "의 ia_violation 테이블 중 기타 경고:", as.character(w)))
  )
  
  ##### indv ia ops report #####
  
  indv_ia_ops_report_by_code <- list("고유번호" = corp_code, 
                                     "주요 개선내용" = ia_ipv,
                                     "책임자 현황" = ia_mgr,
                                     "인력 보유현황" = ia_staff,
                                     "경력 및 교육 실적" = ia_staff_carrier,
                                     "대표자가 보고한 운영실태보고서" = ia_report_mgr,
                                     "감사가 보고한 운영실태보고서" = ia_report_auditor,
                                     "감사인의 검토의견" = ia_report_3rd,
                                     "내부회계관리규정 위반 징계 내용" = ia_violation
                                     )
  
  # no_col <- ncol(ia_report_mgr)
  # ia_report_mgr_text_only <- paste(ia_report_mgr[, 3], collapse = " ")
  # ia_report_auditor_text_only <- paste(ia_report_auditor[, 3], collapse = " ")
  # ia_report_3rd_text_only <- paste(ia_report_auditor[, 2], collapse = " ")
  # indv_report_text_only_by_code <- list("고유번호" = corp_code,
  #                                       "대표자가 보고한 운영실태보고서" = ia_report_mgr_text_only,
  #                                       "감사가 보고한 운영실태보고서" = ia_report_auditor_text_only,
  #                                       "감사인의 검토의견" = ia_report_3rd_text_only
  #                                       )
  
  indv_ia_location <- list("고유번호" = corp_code, 
                           "주요 개선내용" = location_ia_ipv,
                           "책임자 현황" = location_ia_mgr,
                           "인력 보유현황" = location_ia_staff,
                           "경력 및 교육 실적" = location_ia_staff_carrier,
                           "대표자가 보고한 운영실태보고서" = location_ia_report_mgr,
                           "감사가 보고한 운영실태보고서" = location_ia_report_auditor,
                           "감사인의 검토의견" = location_ia_report_3rd,
                           "내부회계관리규정 위반 징계 내용" = location_ia_violation
                           )
  
  indv_ia_ops_report[[report]] <- indv_ia_ops_report_by_code
  names(indv_ia_ops_report)[[report]] <- fiscal_year
  # indv_report_text[[report]] <- indv_report_text_only_by_code
  # names(indv_report_text)[[report]] <- fiscal_year
  
  indv_ia_locations[[report]] <- indv_ia_location
  names(indv_ia_locations)[[report]] <- fiscal_year
  
  }
  gross_ia_ops_report[[code]] <- indv_ia_ops_report
  names(gross_ia_ops_report)[[code]] <- corp_code
  indv_ia_ops_report <- list()
  # gross_ia_ops_report_text[[code]] <- indv_report_text
  # names(gross_ia_ops_report_text)[[code]] <- corp_code
  # indv_report_text <- list()
  
  gross_ia_locations[[code]] <- indv_ia_locations
  names(gross_ia_locations)[[code]] <- corp_code
  
  cat(paste(code, "번째 기업 시행: 기업코드 = ", unq_corp_corps[code], "종료 시각:", Sys.time()), sep = "\n")
  
}
sink()