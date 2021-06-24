# Java 사용을 위한 환경변수 설정
Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre1.8.0_281')


# 필요한 패키지 로딩
library(RSelenium)
library(rvest)
library(httr)
library(stringr)


# 브라우저(chrome) 시동
remDr <- remoteDriver(
  remoteServerAddr="localhost",
  port=4445L,
  browserName="chrome")

remDr$open()

# 기본 주소 설정
base_url <- "https://www.ksa.or.kr"


# 대상 페이지로 이동
remDr$navigate(paste0(base_url, "/ksi/4982/subview.do"))


# 국문보고서 선택
remDr$findElement(using = "xpath",
                  value ="/html/body/div/div[3]/div/div[3]/div[2]/article/div/div[2]/form/div/ul/li[1]/a")$clickElement()


next_flag <- TRUE
cnt <- 0

whitle(next_flag) { 
  
  page_parse <- remDr$getPageSource()[[1]]
  
  page_html <- page_parse %>% 
    read_html()
  
  sub_pages <- html_nodes(page_html, "._inner") %>% 
    html_elements("li") %>%
    length()
  
  sub_page_xpath <- paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", sub_pages, "]/a")
  
  remDr$findElement(using = "xpath",
                    value = sub_page_xpath)$clickElement()
  
  for (j in sub_pages:1){
   
    page_parse <- remDr$getPageSource()[[1]]  
    
    page_html <- page_parse %>% 
      read_html()
    
    links <- html_nodes(page_html, "a") %>%
      html_attr("href")
    
    download_links <- links[grep("download", links)]
    
    Sys.setlocale('LC_ALL', 'English')
    table <- page_html %>% 
      html_table() %>%
      data.frame()
    Sys.setlocale('LC_ALL', 'Korean')
  
    pbls_year <- str_sub(table[, 3], 1, 4)
  
    for(i in 1:length(download_links)){
      
      cnt <- cnt + 1
      
      download_url <- paste0(base_url, download_links[i])
      
      dest_file_name <- paste0(table[i, 1], "_", pbls_year[i], ".pdf")
      
      download.file(download_url, destfile = 
                      paste0("C:/Users/nabataea/Google 드라이브(muoe78@kNou.ac.kr)/문서/projects/sustainability/ksr_kor/", 
                             dest_file_name))
      
    }
    sub_page_xpath <- paste0("/html/body/div/div[3]/div/div[3]/div[2]/article/div/form/div/div/ul/li[", sub_pages, "]/a")
  }
  
  flag_next <- html_nodes(page_html, "._inner") %>% 
    html_elements("._next") %>% 
    length()
  
  if (next_flag == 1) {
    remDr$findElement(using = "css selector", value = "._next")$clickElement()
  } # else next_flag <- FALSE
}
