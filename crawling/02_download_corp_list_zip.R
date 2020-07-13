source("00_environment.R", encoding = "UTF-8")

file_name = "codebook.zip"

url_code = paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=",
                  Sys.getenv("key")) 

download.file(url = url_code, 
              destfile = file_name,
              mode = "wb", 
              quiet = TRUE)
