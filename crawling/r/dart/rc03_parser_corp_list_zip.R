source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

corps_code_parsed <- paste0("corps_code_parsed_", base_date, ".csv")
corps_code_parsed

unzip(zipfile = corps_code_raw)
xml_codes <- read_xml("CORPCODE.xml")

xml_codes %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

write.csv(corps_code, file = paste0("~/projects/wrangling_accounting_related_data/results/corp_code/corps_code_parsed_", base_date, ".csv"), row.names = FALSE)
