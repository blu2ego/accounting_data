library(stringi)

url <- "http://dart.fss.or.kr/dsaf001/main.do?rcpNo=20200327000723"
doc <- read_html(url, encoding = "UTF-8")
doc %>% 
  html_nodes(xpath = "//*/li/a[@href='#download']") %>% 
  html_attr("onclick") %>% 
  stri_extract(regex = ", \'[0-9]{6,8}\'") %>% 
  gsub(pattern = "[^0-9]", replacement = "") -> dcm_no

listt = list.files(path = "doc_list",
                   pattern = "xml$",
                   recursive = TRUE,
                   full.names = TRUE)

listt %>% 
  gsub(pattern = "^.{2,}.*?doc_|\\/.*?$", replacement = "") -> listt_doc_no

url_base = "http://dart.fss.or.kr/dsaf001/main.do?rcpNo="

df_dcm_no = data.frame(doc_path = listt,
                       doc_no = listt_doc_no,
                       dcm_no = "")

time_delay <- 1
for(n in 1:length(listt)){
  print(n)
  url = paste0(url_base, listt_doc_no[n])
  
  doc = read_html(url, encoding = "UTF-8")
  doc %>% 
    html_nodes(xpath = "//*/li/a[@href='#download']") %>% 
    html_attr("onclick") %>% 
    stri_extract(regex = ", \'[0-9]{5,9}\'") %>% 
    gsub(pattern = "[^0-9]", replacement = "") -> dcm_no
  
  df_dcm_no[n, "dcm_no"] = dcm_no
  Sys.sleep(time_delay + runif(1) * 2)
}

