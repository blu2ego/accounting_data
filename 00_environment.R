library("rvest")

source("01_keys.R")

xml_child2df = function(x){
  x_child = html_children(x)
  
  x_df = as.data.frame(matrix(html_text(x_child), 
                              byrow = TRUE, 
                              nrow = 1))
  colnames(x_df) = html_name(x_child)
  return(x_df)
}

