source("~/projects/wrangling_accounting_related_data/crawling/R/01_environment.R", encoding = "UTF-8")

file_name <- "codebook.zip"

url_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart) 

download.file(url = url_code, 
              destfile = file_name,
              mode = "wb", 
              quiet = TRUE)
