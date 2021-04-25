###########################################################
## /ward/processing/dart/r/pdr06_downloaded_a001_unzip.R ##
###########################################################

# set working directory
setwd(file.path(main_dir, biz_report_zip))

list_a001s_zip <- list.files(recursive = TRUE, full.names = TRUE)

list_a001s <- data.frame(path = list_a001s_zip, 
                         corp_code = stri_extract(str = list_a001s_zip, regex = "(?<=corp_code_)[0-9]{6,9}")) # str = list_a001s$corp_code 원래 코드는 str = list_a001

list_a001 <- unique(list_a001s$corp_code)

start_a001 <- 1
end_a001 <- length(list_a001)

for(n_corp in start_a001:end_a001){
  corp_code <- list_a001[n_corp]
  path_dir <- paste0(main_dir, audit_report_xml_from_biz, "corp_code_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  list_a001s_sub <- list_a001s[list_a001s$corp_code == corp_code, ]  
  for(n_zip in 1:nrow(list_a001s_sub)){
    if(file.info(list_a001s_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = list_a001s_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
  list_a001s_del <- list.files(path = path_dir)
  list_a001s_del <- list_a001s_del[!grepl(pattern = "00760.xml$", x = list_a001s_del)] # 감사보고서의 고유 접미사가 00760임
  
  for(n_xml in 1:length(list_a001s_del)){
    file.remove(list_a001s_del[n_xml])
  }
}
