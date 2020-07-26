source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, corps_code_Dir))

file_name <- paste0("corps_code_", base_date, ".zip")
file_name_unzip <- paste0("corps_code_", base_date, ".xml")
file_name_parsed <- paste0("corps_code_parsed_", base_date, ".csv")

unzip(zipfile = paste0("zip/", file_name), 
      exdir   = "xml")

file.rename(from = "xml/CORPCODE.xml",
            to = paste0("xml/", file_name_unzip))

read_xml(paste0("xml/", file_name_unzip)) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> df_codelist

write.csv(x = df_codelist, 
          file = paste0("csv/", file_name_parsed), 
          row.names = FALSE)
