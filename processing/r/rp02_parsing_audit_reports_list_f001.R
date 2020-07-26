# set working directory
setwd(file.path(mainDir, biz_report_list_xml_Dir))

# get document list from specific directory that contains xml files.
audit_reports_xml_list <- list.files()

for(n in 1:length(audit_reports_xml_list)){
  doc <- read_html(audit_reports_xml_list[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> corp_audit_report
  
  if(!is.null(corp_audit_report[1, "rcept_no"])){
    if(nrow(corp_audit_report) >= 1){
      print(n)
      print(corp_audit_report[1, ])
      write.csv(corp_audit_report, paste0(mainDir, audit_report_list_csv_Dir, corp_audit_report[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
