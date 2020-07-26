listt = list.files(path = "doc_list_A001_xml_download/",
                   recursive = TRUE,
                   full.names = TRUE)
length(listt)
head(listt)

for(n_file in 1:length(listt)){
  # n_file = 1
  print(n_file)
  if(is.na(file.info(listt[n_file])$size) == FALSE){
    unzip(zipfile = listt[n_file],
          exdir = gsub(pattern = "\\/doc_.*?$", replacement = "", listt[n_file]),
          overwrite = TRUE)  
  }
  file.remove(listt[n_file])
}

listt = list.files(path = "doc_list_A001_xml_download/",
                   pattern = "xml$",
                   recursive = TRUE,
                   full.names = TRUE)
length(listt)
head(listt)

listt = listt[!grepl(pattern = "00760.xml$", listt)]

for(n_file in 1:length(listt)){
  # n_file = 1
  print(n_file)
  file.remove(listt[n_file])
}