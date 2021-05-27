library("rvest")
library("stringi")
library("jsonlite")

xml_doc_path <- "20200327000723_00760.xml"
xml_doc <- read_html(xml_doc_path,
                     encoding = "CP949")

xml_doc %>%
  html_nodes(xpath = "//*[@acode]") %>%
  html_text() %>% 
  .[1] -> doc_title

xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote]/..') -> tables

xml_doc %>%
  html_nodes(xpath = '//*[@aassocnote="D-0-2-2-0"]/..') %>% 
  html_nodes(css = "tbody") -> table_time

table_time[1] %>%
  html_text() %>% 
  gsub(pattern = "\n", replacement = "") -> table_time_comment

# version 1
table_time[2] %>%
  html_nodes(css = "te") %>%
  html_text() %>%
  gsub(pattern = "[^0-9]", replacement = "") %>%
  as.numeric() %>%
  matrix(nrow = 4, byrow = TRUE) %>%
  as.data.frame() -> table_data

# version 2
table_time[2] %>%
  html_nodes(css = "te") %>% 
  html_text() %>% 
  ifelse(test = . == "-", yes = NA, no = .) %>%
  as.numeric() -> table_data

table_time[2] %>%
  html_nodes(css = "te") %>% 
  html_attr(name = "acode") -> table_names

data.frame(var = table_names,
           value = table_data)
