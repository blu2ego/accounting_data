source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(mainDir, biz_report_list_xml_Dir)

biz_reports <- list.files()

for(n in 1:length(biz_reports)){
  biz_report <- read_html(biz_reports[n], encoding = "UTF-8")
  biz_report %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> biz_report_parsed
  
  if(!is.null(biz_report_parsed[1, "rcept_no"])){
    biz_report_parsed <- biz_report_parsed[grep(pattern = "사업보고서", biz_report_parsed$report_nm), ]
    
    if(nrow(biz_report_parsed) >= 1){
      print(n)
      write.csv(biz_report_parsed, 
                paste0(mainDir, biz_report_list_csv_Dir, "a001_parsed_", biz_report_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
