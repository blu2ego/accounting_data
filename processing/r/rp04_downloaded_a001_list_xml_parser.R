source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", 
       encoding = "UTF-8")

# set working directory
setwd(mainDir, biz_report_list_xml_Dir)

# get document list from specific directory that contains xml files.
biz_reports_xml_list <- list.files()


for(l in 1:length(biz_reports_xml_list)){
  biz_report <- read_html(biz_reports_xml_list[l], encoding = "UTF-8")
  
  biz_report %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> corp_biz_report
  
  if(!is.null(corp_biz_report[l, "rcept_no"])){
    corp_biz_report <- corp_biz_report[grep(pattern = "사업보고서", corp_biz_report$report_nm), ]
    
    if(nrow(corp_biz_report) >= 1){
      print(l)
      print(corp_biz_report[1, ])
      write.csv(corp_biz_report, 
                paste0(mainDir, biz_report_list_csv_Dir, 
                       "a001_parsed_", corp_biz_report[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
