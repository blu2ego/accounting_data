source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corp_code_parsed <- paste0("corp_code_parsed_", base_date, ".csv")
corp_code_parsed

unzip(zipfile = corp_code_raw)
xml_codes = read_xml("CORPCODE.xml")

xml_codes %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corp_code

write.csv(corp_code, file = paste0("~/projects/wrangling_accounting_related_data/results/corp_code/corp_code_parsed_", base_date, ".csv"), row.names = FALSE)
