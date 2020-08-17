#####################################################################
## /ward/processing/dart/r/pdr04_downloaded_a001_list_xml_parser.R ##
#####################################################################

# set working directory
setwd(file.path(main_dir, biz_report_list_xml_dir, "init_date"))

list_a001s_xml <- list.files()

for(n_a001s in 1:length(list_a001s_xml)){
  list_a001 <- read_html(list_a001s_xml[n_a001s], encoding = "UTF-8")
  list_a001 %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> list_a001_parsed
  
  if(!is.null(list_a001_parsed[1, "rcept_no"])){
    list_a001_parsed <- list_a001_parsed[grep(pattern = "사업보고서", list_a001_parsed$report_nm), ]
    
    if(nrow(list_a001_parsed) >= 1){
      print(n_a001s)
      write.csv(list_a001_parsed, 
                paste0(main_dir, biz_report_list_csv_dir, "init_date/a001_parsed_", list_a001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}