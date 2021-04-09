# crawl sustainability report (SR) from KSA.OR.KR (not coding done)
Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre1.8.0_281')

library(RSelenium)
library(rvest)
library(httr)
library(stringr)

remDr <- remoteDriver(remoteServerAddr="localhost", port=4445L, browserName="chrome")
remDr$open()

base_url <- "https://www.ksa.or.kr"
remDr$navigate("https://www.ksa.or.kr/ksi/4982/subview.do")
remDr$findElement(using = "xpath", value ="/html/body/div/div[3]/div/div[3]/div[2]/article/div/div[2]/form/div/ul/li[1]/a")$clickElement()

flag_next <- TRUE
cnt <- 0

while(flag_next){
  page_parse <- remDr$getPageSource()[[1]]
  page_html <- page_parse %>% read_html()
  flag_next <- html_nodes(page_html, "._inner") %>% html_elements("._next")
  
  if(length(flag_next) == 1) { # there exist next burton
    
    page_parse <- remDr$getPageSource()[[1]]
    page_html <- page_parse %>% read_html()
    
    # parsing table
    Sys.setlocale('LC_ALL', 'English')
    table <- page_html %>% html_table() %>% data.frame()
    Sys.setlocale('LC_ALL', 'Korean')
    
    # parsing "href" attribute
    links <- html_nodes(page_html, "a") %>% html_attr("href")    
    
    # compose download links
    download_links <- links[grep("download", links)]
    
    # compose year variable
    pbls_year <- str_sub(table[, 3], 1, 4)
    
    # download pdf files from one table
    for(i in 1:length(download_links)){
      cnt <- cnt + 1
      Sys.sleep(5)
      download_url <- paste0(base_url, download_links[i])
      dest_file_name <- paste0(table[i, 1], "_", pbls_year[i], ".pdf")
      download.file(download_url, destfile = paste0("C://ksi/", dest_file_name))
    }
    
    li <- html_nodes(page_html, "._inner") %>% html_elements("li")
    
    for(j in 2:length(li)) {
      # compose sub page 
      sub_page_xpath <- tryCatch(paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", j, "]/a")) 
      
      # select sub page
      remDr$findElement(using = "xpath", value = sub_page_xpath)$clickElement()
      
      page_parse <- remDr$getPageSource()[[1]]
      page_html <- page_parse %>% read_html()
      
      # parsing table
      Sys.setlocale('LC_ALL', 'English')
      table <- page_html %>% html_table() %>% data.frame()
      Sys.setlocale('LC_ALL', 'Korean')
      
      # parsing "href" attribute
      links <- html_nodes(page_html, "a") %>% html_attr("href")    
      
      # compose download links
      download_links <- links[grep("download", links)]
      
      # compose year variable
      pbls_year <- str_sub(table[, 3], 1, 4)
      
      # download pdf files from one table
      for(k in 1:length(download_links)){
        cnt <- cnt + 1
        Sys.sleep(5)
        download_url <- paste0(base_url, download_links[k])
        dest_file_name <- paste0(table[k, 1], "_", pbls_year[k], ".pdf")
        download.file(download_url, destfile = paste0("C://ksi/", dest_file_name))
      }
    } 
    
    remDr$findElement(using = "css selector", value = "._next")$clickElement()
    
    flag_next <- TRUE
    
  } else {
    page_parse <- remDr$getPageSource()[[1]]
    page_html <- page_parse %>% read_html()
    
    # parsing table
    Sys.setlocale('LC_ALL', 'English')
    table <- page_html %>% html_table() %>% data.frame()
    Sys.setlocale('LC_ALL', 'Korean')
    
    # parsing "href" attribute
    links <- html_nodes(page_html, "a") %>% html_attr("href")    
    
    # compose download links
    download_links <- links[grep("download", links)]
    
    # compose year variable
    pbls_year <- str_sub(table[, 3], 1, 4)
    
    # download pdf files from one table
    for(i in 1:length(download_links)){
      cnt <- cnt + 1
      Sys.sleep(5)
      download_url <- paste0(base_url, download_links[i])
      dest_file_name <- paste0(table[i, 1], "_", pbls_year[i], ".pdf")
      download.file(download_url, destfile = paste0("C://ksi/", dest_file_name))
    }
    
    li <- html_nodes(page_html, "._inner") %>% html_elements("li")
    
    for(j in 2:length(li)) {
      # compose sub page 
      sub_page_xpath <- tryCatch(paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", j, "]/a")) 
      
      # select sub page
      remDr$findElement(using = "xpath", value = sub_page_xpath)$clickElement()
      
      page_parse <- remDr$getPageSource()[[1]]
      page_html <- page_parse %>% read_html()
      
      # parsing table
      Sys.setlocale('LC_ALL', 'English')
      table <- page_html %>% html_table() %>% data.frame()
      Sys.setlocale('LC_ALL', 'Korean')
      
      # parsing "href" attribute
      links <- html_nodes(page_html, "a") %>% html_attr("href")    
      
      # compose download links
      download_links <- links[grep("download", links)]
      
      # compose year variable
      pbls_year <- str_sub(table[, 3], 1, 4)
      
      # download pdf files from one table
      for(k in 1:length(download_links)){
        cnt <- cnt + 1
        Sys.sleep(5)
        download_url <- paste0(base_url, download_links[k])
        dest_file_name <- paste0(table[k, 1], "_", pbls_year[k], ".pdf")
        download.file(download_url, destfile = paste0("C://ksi/", dest_file_name))
      }
    }
    flag_next <- FALSE
  }
}
