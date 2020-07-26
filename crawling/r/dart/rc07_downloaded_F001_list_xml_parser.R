source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

listt <- list.files(path = audit_report_list_xml_Dir,
                    pattern = "f001",
                    full.names = TRUE)

for(n in 1:length(listt)){
  doc <- read_html(listt[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_codelist
  if(!is.null(df_codelist[1, "rcept_no"])){
    if(nrow(df_codelist) >= 1){
      print(n)
      write.csv(df_codelist, 
                paste0(audit_report_list_csv_Dir, "/doc_f001_list_parsed_", df_codelist[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}
