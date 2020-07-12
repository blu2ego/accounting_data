library("rvest")

Sys.setenv(key = "1fde365f255f62f4b7699e1a0c01eb09386426e0")


xml_child2df = function(x){
  x_child = html_children(x)
  
  x_df = as.data.frame(matrix(html_text(x_child), 
                              byrow = TRUE, 
                              nrow = 1))
  colnames(x_df) = html_name(x_child)
  return(x_df)
}

