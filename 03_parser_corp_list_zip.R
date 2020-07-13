source("00_environment.R", encoding = "UTF-8")

file_name = "codebook.zip"
file_name_parsed = "codelist_parsed.csv"

unzip(zipfile = file_name)
xml_codes = read_xml("CORPCODE.xml")

xml_codes %>%
  html_nodes(css = "list") %>%
  lapply("udf1") %>%
  do.call(what = "rbind") -> df_codelist
head(df_codelist)

write.csv(df_codelist, file_name_parsed, row.names = FALSE)
