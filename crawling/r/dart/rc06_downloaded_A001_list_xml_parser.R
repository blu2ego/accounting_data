source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

listt <- list.files(path = biz_report_list_xml_Dir,
                    pattern = "a001",
                    full.names = TRUE)

for(n in 1:length(listt)){
  doc <- read_html(listt[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_codelist
  if(!is.null(df_codelist[1, "rcept_no"])){
    df_codelist <- df_codelist[grep(pattern = "사업보고서", df_codelist$report_nm), ]
    
    if(nrow(df_codelist) >= 1){
      print(n)
      write.csv(df_codelist, 
                paste0(corps_code_parsed_csv_Dir, "/doc_a001_list_parsed_", df_codelist[1, "corp_code"], ".csv"),
                row.names = FALSE) 
    }
  }
}