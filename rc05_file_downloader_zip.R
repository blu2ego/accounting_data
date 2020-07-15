source("~/projects/wrangling_accounting_related_data/crawling/R/rc01_environment.R", encoding = "UTF-8")

listt <-  list.files(path = "html",
                   full.names = TRUE)

dir.create(path = "doc_list",
           showWarnings = FALSE)
for(n in 1:length(listt)){
  print(n)
  doc <- read_html(listt[n], encoding = "UTF-8")
  doc %>%
    html_nodes(css = "list") %>%
    lapply("xml_child2df") %>% 
    do.call(what = "rbind") -> df_codelist
  recept_no <- df_codelist[1, "rcept_no"]
  
  if(!is.null(recept_no)){
    url_doc = paste0("https://opendart.fss.or.kr/api/document.xml?",
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
