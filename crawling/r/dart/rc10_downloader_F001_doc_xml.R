source("~/projects/wrangling_accounting_related_data/crawling/r/dart/rc01_environment.R", encoding = "UTF-8")

list_f001 <- list.files(path = audit_report_list_csv_Dir,
                        full.names = TRUE)

start_f001 <- 1
end_f001 <- length(listt)
time_delay_f001 <- 1

for(n_file in start_f001:end_f001){
  df_code <- read.csv(list_f001[n_file])
  df_code[, "year"] <- as.numeric(stri_extract(str = df_code$report_nm, regex = "[0-9]{4}"))
  
  corp_code <- sprintf(fmt = "%08d", df_code[1, "corp_code"])
  
  path_dir <- paste0(audit_report_zip, "corp_no_", corp_code)
  dir.create(path = path_dir, showWarnings = FALSE)
  
  for(n_row in 1:nrow(df_code)){
    recept_no <- as.character(df_code[n_row, "rcept_no"])
    
    url_doc <- paste0("https://opendart.fss.or.kr/api/document.xml?",
                      "&crtfc_key=", key_dart,
                      "&rcept_no=", recept_no)
    
    path_zip <- paste(path_dir, "/", df_code[n_row, "year"], "_", recept_no, ".zip", sep = "")
    
    download.file(url = url_doc, destfile = path_zip,
                  mode = "wb", quiet = TRUE)
    
    Sys.sleep(time_delay_f001 + runif(1) * 2)
  }
}
