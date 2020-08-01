source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, corps_code_unzip_Dir))

read_xml(file_name_unzip) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

file_name_parsed <- paste0("corps_code_parsed_", base_date, ".csv")

write.csv(x = corps_code, 
          file = file.path(mainDir, corps_code_parsed_csv_Dir, file_name_parsed), 
          row.names = FALSE)
