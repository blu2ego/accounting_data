# 정리되면 수정 하겠습니다. 
# 보셔야 될 것 같아서 일단 업로드 부터 해놓습니다.

#### [[ ver 1 ]] ####
listt = list.files(path = "doc_list",
                   pattern = "xml$",
                   recursive = TRUE,
                   full.names = TRUE)
length(listt)
head(listt)

library("rvest")
library("stringi")
library("jsonlite")

# xml_doc_path <- "doc_list/doc_20200327000723/20200327000723_00760.xml"
xml_doc_path <- listt[30120]
xml_doc <- tryCatch(expr = {
  read_html(xml_doc_path, encoding = "CP949", )
}, error = function(x){
  read_html(xml_doc_path, encoding = "UTF-8")  
})
# http://dart.fss.or.kr/pdf/download/pdf.do?rcp_no=20200402002061&dcm_no=7231980

xml_doc %>%
  html_children() %>%
  html_children() %>%
  html_children()

xml_doc %>%
  html_nodes(xpath = "//*/company-name") -> corp_info

corp_info %>% 
  html_attr("aregcik") -> corp_code

corp_info %>% 
  html_text() -> corp_name
corp_name

xml_doc %>%
  html_nodes(xpath = "//*[@acode]") %>%
  html_text() %>% 
  .[1] -> doc_title

xml_doc %>% 
  html_nodes(xpath = "//*/title[@aassocnote]/..") -> tables

tables %>% 
  html_children() %>%
  html_attr(name = "aassocnote") %>% 
  .[!is.na(.)]



#### 2. 감사참여자 구분별 인원수 및 감사시간 ####
xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//title') %>%
  html_text() -> table_name

xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//tbody') -> table_sub

table_sub[1] %>%
  html_text() %>% 
  gsub(pattern = "\n", replacement = "") -> table_sub_comment

table_sub[2] %>%
  html_nodes(css = "te") %>% 
  html_attr(name = "acode") -> table_sub_names

table_sub[2] %>%
  html_nodes(css = "te") %>% 
  html_text() %>% 
  ifelse(test = . == "-", yes = NA, no = .) %>%
  as.numeric() -> table_sub_data


df_table_sub = data.frame(var = table_sub_names,
                          value = table_sub_data)
df_table_sub

#### 3. 주요 감사실시내용 ####
# 외부 조회(금융거래조회) 제대로 되는지 다시 확인해야함.
# 이건 tu태그...

xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//title') %>%
  html_text() -> table_name

xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-3-0"]/..//tbody') -> table_sub

table_sub %>%
  html_nodes(css = "te") %>% 
  html_attr(name = "acode") -> table_sub_names

table_sub %>%
  html_nodes(css = "te") %>% 
  html_text() %>% 
  ifelse(test = . == "-", yes = NA, no = .) %>%
  gsub(pattern = "\\&cr;", replacement = "") -> table_sub_data

df_table_sub = data.frame(var = table_sub_names,
                          value = table_sub_data)
df_table_sub


#### 4. 감사(감사위원회)와의 커뮤니케이션 ####
# 여러개인 경우 대응 필요
# n = 30014가 여러개임
xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//title') %>%
  html_text() -> table_name

xml_doc %>%
  html_nodes(xpath = '//*/title[@aassocnote="D-0-2-4-0"]/..//tbody') -> table_sub

table_sub %>%
  html_nodes(css = "te") %>% 
  html_attr(name = "acode") -> table_sub_names

table_sub %>%
  html_nodes(css = "te") %>% 
  html_text() %>%
  gsub(pattern = "\\&cr;", replacement = ", ") -> table_sub_data

df_table_sub = data.frame(var = table_sub_names,
                          value = table_sub_data)
df_table_sub

#### 내부회계관리제도 감사 또는 검토의견 ####
xml_doc %>% 
  html_nodes(xpath = "//*/section-1") %>% 
  .[[3]] %>%
  html_children() %>%
  html_text() %>%
  gsub(pattern = "\\n|\\&cr;", replacement = " ") %>%
  gsub(pattern = " {2,}", replacement = " ") %>% 
  gsub(pattern = "^ | $", replacement = "") -> doc_sub

doc_sub <-  doc_sub[doc_sub != ""]

doc_sub %>%
  html_nodes(xpath = "title") %>%
  html_text() -> doc_sub_title

doc_sub %>%
  html_children() %>%
  html_text()

doc_sub %>%
  html_children() %>%
  html_name()

xml_doc %>% 
  html_nodes(xpath = "//*/section-1") %>% 
  .[[3]] %>% 
  html_nodes(xpath = "table") %>% 
  html_text()

#### 독립된 감사인의 감사보고서 중 핵심감사사항 ####
xml_doc %>% 
  html_nodes(xpath = "//*/section-1") %>% 
  .[[1]] %>% 
  html_children() %>% 
  html_text() %>% 
  gsub(pattern = "\\n|\\&cr;", replacement = " ") %>%
  gsub(pattern = " {2,}", replacement = " ") %>% 
  gsub(pattern = "^ | $", replacement = "") -> doc_sub

doc_sub = doc_sub[doc_sub != ""]

doc_sub_loc1 = grep(pattern = "^핵심감사", doc_sub)[1]
doc_sub_loc2 = grep(pattern = "^재무제표.*?책임$", doc_sub)[1]
doc_sub[(doc_sub_loc1 + 2):(doc_sub_loc2 - 1)] 


#### [[ ver 2 ]]  ####
listt = list.files(path = "doc_list",
                   pattern = "xml$",
                   recursive = TRUE,
                   full.names = TRUE)
length(listt)
head(listt)

library("rvest")
library("stringi")
library("jsonlite")

# 4, 5
xml_doc_path = listt[993]
xml_doc <- read_html(xml_doc_path,
                     encoding = "CP949")


xml_doc %>%
  html_nodes(xpath = "//*/company-name") -> corp_info

corp_info %>% 
  html_attr("aregcik") -> corp_code

corp_info %>% 
  html_text() -> corp_name
corp_name

xml_doc %>%
  html_nodes(xpath = "//*[@acode]") %>%
  html_text() %>% 
  .[1] -> doc_title

if(doc_title == ""){
  # 없으면 패스해야함...
}

xml_doc %>%
  html_children() %>%
  html_children() %>% 
  html_children() %>%
  html_children() %>%
  html_text()

#### [[ ver 3 ]] ####
listt = list.files(path = "doc_list",
                   pattern = "xml$",
                   recursive = TRUE,
                   full.names = TRUE)
length(listt)
head(listt)

library("rvest")
library("stringi")
library("jsonlite")

df_doc_info = data.frame()
for(n in 14300:14600){
  # n = 14303
  print(n)
  xml_doc_path = listt[n]
  
  xml_doc <- tryCatch(expr = {
    read_html(xml_doc_path, encoding = "CP949", )
  }, error = function(x){
    read_html(xml_doc_path, encoding = "UTF-8")  
  })
  # rm(xml_doc)
  
  xml_doc %>%
    html_nodes(xpath = "//*/company-name") -> corp_info
  
  if(length(corp_info) > 0){
    corp_info %>% 
      html_attr("aregcik") -> corp_code
    
    corp_info %>% 
      html_text() -> corp_name
    
    xml_doc %>%
      html_nodes(xpath = "//*[@acode]") %>%
      html_text() %>% 
      .[1] -> doc_title
    
    xml_doc %>% 
      html_nodes(xpath = "//*/table") %>%
      html_text() %>%
      .[1] %>%
      gsub(pattern = "\\n", replacement = " ")-> doc_date
    
    # print(c(n, corp_name, doc_title, doc_date)) 
    df_doc_info_sub = data.frame(n = n,
                                 corp_name = corp_name,
                                 title = doc_title,
                                 date = doc_date)
    
    df_doc_info = rbind(df_doc_info, df_doc_info_sub)
  }
}
tail(df_doc_info)

# write.csv(df_doc_info, "doc_list_xml_file_info.csv", row.names = FALSE)

table(substr(df_doc_info$date, start = 1, stop = 5))
df_doc_info$corp_name

df_doc_info[!grepl(pattern = "^[0-9]", df_doc_info$date), ]
