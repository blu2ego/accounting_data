source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# working directory를 코드별로 변경하자.

corps_code_parsed <- paste0("corps_code_parsed_", base_date, ".csv")
corps_code_parsed

# unzip이 동작하지 않음. 왜지?
unzip(paste0(mainDir, corps_code_download_Dir_zip, corps_code_raw), exdir = paste0(mainDir, corps_code_unzip_Dir_xml))
file.rename(paste0(mainDir, corps_code_unzip_Dir_xml, "CORPCODE.xml"), paste0(mainDir, corps_code_unzip_Dir_xml, "corpcode_", base_date, ".xml"))

xml_codes <- read_xml(paste0(mainDir, corps_code_unzip_Dir_xml, "corpcode_", base_date, ".xml"))

xml_codes %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

write.csv(corps_code, file = paste0(mainDir, corps_code_parsed_Dir_csv, "corps_code_parsed_", base_date, ".csv"), row.names = FALSE)
