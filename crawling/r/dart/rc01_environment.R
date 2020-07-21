# Setting Global Environments

# importing dart's key
key_dart <- readLines("~/projects/wrangling_accounting_related_data/crawling/sources/key_dart.txt")

# creating xml_child2df function to import and process xml
library(rvest)
xml_child2df <- function(x){
  x_child <- html_children(x)
  
  x_df <- as.data.frame(matrix(html_text(x_child), 
                              byrow = TRUE, 
                              nrow = 1))
  colnames(x_df) <- html_name(x_child)
  return(x_df)
}

base_date <- Sys.Date()

mainDir <- "~/projects/wrangling_accounting_related_data/results/xmls/"
xmls_download_Dir <- paste0("xmls_", base_date)
ifelse(!dir.exists(file.path(mainDir, xmls_download_Dir)), dir.create(file.path(mainDir, xmls_download_Dir)), FALSE)
