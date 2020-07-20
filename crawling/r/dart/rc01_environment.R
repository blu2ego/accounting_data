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

