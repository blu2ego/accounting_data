#####################################################################
## /ward/processing/dart/r/pdr05_downloaded_f001_list_xml_parser.R ##
#####################################################################

# set working directory
setwd(file.path(main_dir, audit_report_list_xml_dir))

list_f001s_xml <- list.files() 

for(n_f001s in 1:length(list_f001s_xml)){
  list_f001 <- read_html(list_f001s_xml[n_f001s], encoding = "UTF-8")
  list_f001 %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> list_f001_parsed
  
  if(!is.null(list_f001_parsed[1, "rcept_no"])){
    if(nrow(list_f001_parsed) >= 1){
      print(n_f001s)
      write.csv(list_f001_parsed, 
                paste0(main_dir, audit_report_list_csv_dir, "f001_parsed_", list_f001_parsed[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}