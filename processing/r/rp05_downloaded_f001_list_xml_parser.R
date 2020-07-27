source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", 
       encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, audit_report_list_xml_Dir))

# get document list from specific directory that contains xml files.
audit_reports_xml_list <- list.files()

for(n in 1:length(audit_reports_xml_list)){
  audit_report <- read_html(audit_reports[n], encoding = "UTF-8")
  
  audit_report %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> corp_audit_report
  
  if(!is.null(corp_audit_report[1, "rcept_no"])){
    if(nrow(corp_audit_report) >= 1){
      print(n)
      print(corp_audit_report[1, ])
      write.csv(corp_audit_report, 
                paste0(mainDir, audit_report_list_csv_Dir, 
                       "f001_parsed_", corp_audit_report[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}