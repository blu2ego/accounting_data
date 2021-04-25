###########################################################
## /ward/processing/dart/r/pdr03_corps_code_xml_parser.R ##
###########################################################

# set working directory
setwd(file.path(main_dir, corps_code_unzip_dir))

read_xml(file_name_unzip) %>%
  html_nodes(css = "list") %>%
  lapply("xml_child2df") %>%
  do.call(what = "rbind") -> corps_code

file_name_parsed <- paste0("corps_code_parsed_", base_date, ".csv")

write.csv(x = corps_code, 
          file = file.path(main_dir, corps_code_parsed_csv_dir, file_name_parsed), 
          row.names = FALSE)
