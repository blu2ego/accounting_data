source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

list_f001 <- list.files(path = audit_report_zip,
                        recursive = TRUE,
                        full.names = TRUE)


df_list_f001 = data.frame(path = list_f001,
                          corp_no = stri_extract(str = list_f001, regex = "(?<=corp_no_)[0-9]{6,9}"))

list_f001_corp = unique(df_list_f001$corp_no)

start_f001 <- 1
end_f001 <- length(list_f001_corp)

for(n_corp in start_f001:end_f001){
  # n_corp = 1
  corp_code <- list_f001_corp[n_corp]
  path_dir <- paste0(audit_report_doc, "corp_no_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  df_list_f001_sub <- df_list_f001[df_list_f001$corp_no == corp_code, ]  
  for(n_zip in 1:nrow(df_list_f001_sub)){
    if(file.info(df_list_f001_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = df_list_f001_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
}
