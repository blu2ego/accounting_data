###########################################################
## /ward/processing/dart/r/pdr07_downloaded_f001_unzip.R ##
###########################################################

# set working directory
setwd(file.path(main_dir, audit_report_zip))

list_f001s_zip <- list.files(recursive = TRUE, full.names = TRUE)

list_f001s <- data.frame(path = list_f001s_zip,
                         corp_code = stri_extract(str = list_f001s_zip, regex = "(?<=corp_code_)[0-9]{6,9}"))

list_f001 <- unique(list_f001s$corp_code)

start_f001 <- 1
end_f001 <- length(list_f001)

for(n_corp in start_f001:end_f001){
  corp_code <- list_f001[n_corp]
  path_dir <- paste0(main_dir, audit_report_xml_from_aud, "corp_code_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  list_f001s_sub <- list_f001s[list_f001s$corp_code == corp_code, ]  
  for(n_zip in 1:nrow(list_f001s_sub)){
    if(file.info(list_f001s_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = list_f001s_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
}
