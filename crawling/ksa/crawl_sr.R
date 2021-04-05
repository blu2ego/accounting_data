# crawl sustainability report (SR) from KSA.OR.KR (not coding done)

Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre1.8.0_281')

library(RSelenium)
library(rvest)
library(httr)
library(stringr)

remDr <- remoteDriver(
  remoteServerAddr="localhost",
  port=4445L,
  browserName="chrome")

remDr$open()

base_url <- "https://www.ksa.or.kr"

remDr$navigate("https://www.ksa.or.kr/ksi/4982/subview.do")

remDr$findElement(using = "xpath",
                  value ="/html/body/div/div[3]/div/div[3]/div[2]/article/div/div[2]/form/div/ul/li[1]/a")$clickElement()

flag_next <- TRUE
cnt <- 0

while(flag_next){
  
  page_parse <- remDr$getPageSource()[[1]]
  
  page_html <- page_parse %>% 
    read_html()
  
  flag_next <- html_nodes(page_html, "._inner") %>% 
    html_elements("._next")
  
  li <- html_nodes(page_html, "._inner") %>% 
    html_elements("li")
  
  if(length(flag_next) == 1){  # there exist next burton
    
    # parsing "li" tag: number of li is sub pages at one full page
    
    for(j in 1:length(li)) {
      
      last_subpage_xpath <- sub_page_xpath <- paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", length(li), "]/a")
      
      remDr$findElement(using = "xpath",
                        value = last_subpage_xpath)$clickElement()  
      
      # compose sub page 
      sub_page_xpath <- tryCatch(paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", j, "]/a")) 
      
      # select sub page
      tryCatch(
        remDr$findElement(using = "xpath", value = sub_page_xpath)$clickElement(),
        error = print(j, i)
        )
      
      page_parse <- remDr$getPageSource()[[1]]
      
      page_html <- page_parse %>% 
        read_html()
      
      # parsing table
      Sys.setlocale('LC_ALL', 'English')
      table <- page_html %>% 
        html_table() %>%
        data.frame()
      Sys.setlocale('LC_ALL', 'Korean')
      
      # parsing "href" attribute
      links <- html_nodes(page_html, "a") %>%
        html_attr("href")    
      
      # compose download links
      download_links <- links[grep("download", links)]
      
      # compose year variable
      pbls_year <- str_sub(table[, 3], 1, 4)
      
      # download pdf files from one table
      
      for(i in 1:length(download_links)){
        
        cnt <- cnt + 1
        
        download_url <- paste0(base_url, download_links[i])
        
        dest_file_name <- paste0(table[i, 1], "_", pbls_year[i], ".pdf")
        
        download.file(download_url, destfile = 
                        paste0("D://ksi/", dest_file_name))
      }
    } 
    # page_parse <- remDr$getPageSource()[[1]]
    
    # page_html <- page_parse %>% 
    #   read_html()
    
    # flag_next <- html_nodes(page_html, "._inner") %>% 
    #  html_elements("._next")
    
    remDr$findElement(using = "css selector", value = "._next")$clickElement()
  } else {
 
    for(j in 1:length(li)) {
      
      last_subpage_xpath <- sub_page_xpath <- paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", length(li), "]/a")
      
      remDr$findElement(using = "xpath",
                        value = last_subpage_xpath)$clickElement()  
      
      sub_page_xpath <- tryCatch(paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", j, "]/a")) 
      
     tryCatch(remDr$findElement(using = "xpath",
                                 value = sub_page_xpath)$clickElement()) 
      
      page_parse <- remDr$getPageSource()[[1]]
      
      page_html <- page_parse %>% 
        read_html()
      
      Sys.setlocale('LC_ALL', 'English')
      table <- page_html %>% 
        html_table() %>%
        data.frame()
      Sys.setlocale('LC_ALL', 'Korean')
      
      links <- html_nodes(page_html, "a") %>%
        html_attr("href")    
      
      download_links <- links[grep("download", links)]
      
      # compose year variable
      pbls_year <- str_sub(table[, 3], 1, 4)
      
      # download pdf files from one table
      for(i in 1:length(download_links)){
        
        cnt <- cnt + 1
        
        download_url <- paste0(base_url, download_links[i])
        
        dest_file_name <- paste0(table[i, 1], "_", pbls_year[i], ".pdf")
        
        download.file(download_url, destfile = 
                        paste0("D://ksi/", dest_file_name))
      }
    }
    flag_next <- FALSE
  } 
}
