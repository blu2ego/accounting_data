source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, audit_report_list_xml_Dir))

# get document list from specific directory that contains xml files.
audit_reports <- list.files(full.names = TRUE)

for(i in 1:length(audit_reports)){
  print(i)
  audit_report <- read_html(audit_reports[i], encoding = "UTF-8")
  audit_report %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_report_list
  
  rcept_no <- df_report_list[i, "rcept_no"]
  
  if(!is.null(recept_no)){
    url_doc <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                     "&crtfc_key=", Sys.getenv("key"),
                     "&rcept_no=", recept_no)
    
    dir_name <- paste0("doc_", recept_no)
    dir_path <- paste("doc_list", dir_name, sep = "/")
    dir.create(path = dir_path,
               showWarnings = FALSE)
    
    zip_path <- paste(dir_path, "doc.zip", sep = "/")
    download.file(url = url_doc, destfile = zip_path,
                  mode = "wb", quiet = TRUE)
    unzip(zipfile = zip_path, exdir = dir_path, overwrite = TRUE)
    file.remove(zip_path)
  }
}

audit_report <- read_html(audit_reports[1], encoding = "UTF-8")
audit_report %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>% 
  do.call(what = "rbind") -> df_codelist
rcept_no <- df_codelist[1, "rcept_no"]

