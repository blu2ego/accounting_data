# 감사보고서(audit report) 중 외부감사 실시 내용

# 외부감사 실시 내용 중 투입 인원수 정보 
quality_ctrl <- c("품질관리검토자" = 17)

cpa <- list("감사업무 담당 회계사" = 
               list("담당이사" = 1, 
                 "등록 공인회계사" = 26, 
                 "수습 공인회계사" = 18))

prf <- c("전산감사 등 전문가" = 74, 
         "수주산업 등 전문가" = NA)

auditors <- c(quality_ctrl, cpa, prf)

# 외부감사 실시 내용 중 투입 시간 정보(분/반기)
quality_ctrl_time_periodic <- c("품질관리검토자" = 32)

cpa_time_periodic <- list("감사업무 담당 회계사" = 
                            list("담당이사" = 612, 
                              "등록 공인회계사" = 14976, 
                              "수습 공인회계사" = 4194))

prf_time_periodic <- c("전산감사 등 전문가" = 4287, 
                       "수주산업 등 전문가" = NA)

auditors_time_periodic <- c(quality_ctrl_time_periodic, cpa_time_periodic, prf_time_periodic)

# 외부감사 실시 내용 중 투입 시간 정보(기말)
quality_ctrl_time_yearend <- c("품질관리검토자" = 32)

cpa_time_yearend <- list("감사업무 담당 회계사" = 
                           list("담당이사" = 612, 
                             "등록 공인회계사" = 14976, 
                             "수습 공인회계사" = 4194))

prf_time_yearend <- c("전산감사 등 전문가" = 4287, 
                      "수주산업 등 전문가" = NA)

auditors_time_yearend <- c(quality_ctrl_time_yearend, cpa_time_yearend, prf_time_yearend)

# 외부 감사 실시 내용(집합)
external_audit_contents <- list("삼성전자_00126380" = 
                                  list("fiscal_year" = 
                                         list("year_end" = "1231", 
                                              "corp_cls" = "Y", 
                                              "corp_name" = "삼성전자",
                                              "corp_code" = "00126380", 
                                              "stock_code" = "005930", 
                                              "report_name" = "감사보고서",  
                                              "rcept_no" = "20030807000168", 
                                              "flr_name" = "삼일회계법인", 
                                              "rcept_dt" = "20030807", 
                                              "rm" = "Y",
                                              "감사참여자 구분별 인원수 및 감사시간" = 
                                                list("투입 인원수" = auditors, 
                                                     "분/반기검토(시간)" = auditors_time_periodic, 
                                                     "감사(시간)" = auditors_time_yearend))
                                       )
                                )


# 외부 감사 실시 내용(집합)을 josn으로 변형
external_audit_contents <- jsonlite::toJSON(external_audit_contents, pretty = TRUE, auto_unbox = TRUE)

# json 파일로 writing 하려면,
write(external_audit_contents, "~/projects/ward/results/dart/for_accounting/samples/external_audit_contents.json") 

