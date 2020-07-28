source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, audit_report_list_xml_Dir))

audit_reports <- list.files()

for(n in 1:length(audit_reports)){
  audit_report <- read_html(audit_reports[n], encoding = "UTF-8")
  audit_report %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> audit_report_parsed
  
  if(!is.null(audit_report_parsed[1, "rcept_no"])){
    if(nrow(audit_report_parsed) >= 1){
      print(n)
      write.csv(audit_report_parsed, 
                paste0(mainDir, audit_report_list_csv_Dir, "f001_parsed_", audit_report_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
