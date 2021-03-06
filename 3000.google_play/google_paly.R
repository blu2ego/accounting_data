#Loading the rvest package
library(rvest)
library(magrittr) # for the '%>%' pipe symbols
library(RSelenium) # to get the loaded html of 

#Specifying the url for desired website to be scrapped
url <- 'https://play.google.com/store/apps/details?id=com.phonegap.rxpal&hl=en_IN'

# starting local RSelenium (this is the only way to start RSelenium that is working for me atm)
selCommand <- wdman::selenium(jvmargs = c("-Dwebdriver.chrome.verboseLogging=true"), retcommand = TRUE)
shell(selCommand, wait = FALSE, minimized = TRUE)
remDr <- remoteDriver(port = 4567L, browserName = "chrome")
remDr$open()

# go to website
remDr$navigate(url)

# get page source and save it as an html object with rvest
html_obj <- remDr$getPageSource(header = TRUE)[[1]] %>% read_html()

# 1) name field (assuming that with 'name' you refer to the name of the reviewer)
names <- html_obj %>% html_nodes(".kx8XBd .X43Kjb") %>% html_text()

# 2) How much star they got 
stars <- html_obj %>% html_nodes(".kx8XBd .nt2C1d [role='img']") %>% html_attr("aria-label")

# 3) review they wrote
reviews <- html_obj %>% html_nodes(".UD7Dzf") %>% html_text()

# create the df with all the info
review_data <- data.frame(names = names, stars = stars, reviews = reviews, stringsAsFactors = F)


# adding or alternative

#Loading the rvest package
library('rvest')
#Specifying the url for desired website to be scrapped
url <- 'https://play.google.com/store/apps/details?id=com.phonegap.rxpal&hl=en_IN'
#Reading the HTML code from the website
webpage <- read_html(url)
# Using Xpath
Name_data_html <- webpage %>% 
  html_nodes(xpath='/html/body/div[1]/div[4]/c-wiz/div/div[2]/div/div[1]/div/c-wiz[1]/c-wiz[1]/div/div[2]/div/div[1]/c-wiz[1]/h1/span')
#Converting the Name data to text
Name_data <- html_text(Name_data_html)
#Look at the Name
head(Name_data)
Name_data_html
