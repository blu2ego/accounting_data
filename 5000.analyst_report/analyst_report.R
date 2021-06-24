library(rvest)
library(stringr)

base_url_page <- "http://consensus.hankyung.com/apps.analysis/analysis.list?&sdate=2002-02-01&edate=2021-06-23&report_type=CO&pagenum=80&order_type=&now_page="
base_url_download <- "http://consensus.hankyung.com/"

end_page_num <- 3539

analyst_consensus <- data.frame()

for (i in 1:3539) {
  
  page_url <- paste0(base_url_page, i)
  
  html <- read_html(page_url, encoding = "CP949")
  
  # parsing table
  # Sys.setlocale('LC_ALL', 'English')
  table <- html %>% html_table() %>% data.frame()
  # Sys.setlocale('LC_ALL', 'Korean')
  
  table <- table[, -(7:9)]
  
  num_reports <- nrow(table)
  
  # parsing download pdf
  hrefs <- html_nodes(html, "a") %>% html_attr("href")    
  download_urls <- hrefs[grep("downpdf", hrefs)]
  
  for(j in 1:num_reports) {
    
    report_title <- table[j, 2]
    report_title <- str_split(report_title, "\r\n")
    report_title <- report_title[[1]][4]
    table[j, 2] <- report_title 
    table[j, 7] <- str_extract(report_title, "[0-9]+")
    
    url <- paste0(base_url_download, download_urls[j])
    new_name <- paste0("/HDD1T/ward_data/analyst_report/", i, "_", j, "_", table[j, 7], "_", table[j, 1], ".pdf")
    
    download.file(url, 
                  destfile = new_name, mode = "wb")
    
    Sys.sleep(3)
  }
  print(i); print(j)
  analyst_consensus <- tryCatch(rbind(analyst_consensus, table))
}