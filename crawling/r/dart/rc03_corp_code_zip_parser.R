source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

# set working directory
setwd(file.path(mainDir, corps_code_zip_Dir))

file_name <- "codebook.zip"
file_name_parsed <- "codelist_parsed.csv"

unzip(zipfile = file_name)
xml_codes <- read_xml("CORPCODE.xml")

xml_codes %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> df_codelist

write.csv(df_codelist, file_name_parsed, row.names = FALSE)
