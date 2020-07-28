source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

list_a001 <- list.files(path = biz_report_zip,
                        recursive = TRUE,
                        full.names = TRUE)

df_list_a001 = data.frame(path = list_a001,
                          corp_no = stri_extract(str = list_a001, regex = "(?<=corp_no_)[0-9]{6,9}"))

list_a001_corp = unique(df_list_a001$corp_no)

start_a001 <- 1
end_a001 <- length(list_a001_corp)

for(n_corp in start_a001:end_a001){
  # n_corp = 1
  corp_code <- list_a001_corp[n_corp]
  path_dir <- paste0(biz_report_doc, "corp_no_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)    
  
  df_list_a001_sub <- df_list_a001[df_list_a001$corp_no == corp_code, ]  
  for(n_zip in 1:nrow(df_list_a001_sub)){
    if(file.info(df_list_a001_sub[n_zip, "path"])$size > 0){
      unzip(zipfile = df_list_a001_sub[n_zip, "path"],
            exdir = path_dir) 
    }
  }
  df_list_a001_del <- list.files(path = path_dir,
                                 full.names = TRUE)
  df_list_a001_del <- df_list_a001_del[!grepl(pattern = "00760.xml$", x = df_list_a001_del)]
  
  for(n_xml in 1:length(df_list_a001_del)){
    file.remove(df_list_a001_del[n_xml])
  }
}
