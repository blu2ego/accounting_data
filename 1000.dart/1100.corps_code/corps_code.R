############################################################
## download and unzip the corporate unique code 
############################################################

## set working directory
setwd(file.path(data_dir, corps_code_zip_dir))

## download unique corporate code
corps_code_zip <- paste0("corps_code_", date, ".zip")
request_url_corps_code <- paste0("https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=", key_dart)
download.file(url = request_url_corps_code, 
              destfile = corps_code_zip,
              # mode = "wb", 
              quiet = TRUE)

## unzip
unzip(zipfile = paste0("corps_code_", date, ".zip"), exdir = file.path(data_dir, corps_code_unzip_dir))

## set working directory
setwd(file.path(data_dir, corps_code_unzip_dir))

## rename file
new_name <- paste0("corps_code_", date, ".xml")
file.rename("CORPCODE.xml", to = new_name)

## parsing xml to csv
read_xml(new_name) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

## write to csv
write.csv(x = corps_code, 
          file = paste0(data_dir, corps_code_parsed_csv_dir, "corps_code_", date, ".csv"), 
          row.names = FALSE)
