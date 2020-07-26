# 수정 예정입니다.

library(stringi)
library(tabulizer)

listt = list.files(path = "pdfs/",
                   full.names = TRUE)
head(listt)

n = 2
# tbl <- extract_tables(file = listt[2], encoding = "UTF-8", method = "stream")
tbl <- extract_tables(file = "doc_list_A001_pdf_download/corp_no_00101220/doc_A001_00101220_2019.pdf", encoding = "UTF-8", method = "stream")
tbl_cnt <- length(tbl)
tbl[[tbl_cnt]]

#### 1. 테이블 정의 ####
#### ___ ● 감사대상업무 ####
tbl_check_word <- "감사대상"

for(n_tbl in 5:2){
  tbl_sub <- tbl[[tbl_cnt - n_tbl]]
  tbl_check <- sum(grepl(pattern = tbl_check_word, tbl_sub[, 1]))
  if(tbl_check > 0){
    tbl_01_audit <- tbl_sub
  }
}

#### ___ ● 감사 시간 ####
tbl_check_word <- "투입 인원수"

for(n_tbl in 5:2){
  tbl_sub <- tbl[[tbl_cnt - n_tbl]]
  tbl_check <- sum(grepl(pattern = tbl_check_word, tbl_sub[, 1]))
  if(tbl_check > 0){
    tbl_02_hour_no <- n_tbl
    tbl_02_hour <- tbl_sub
  }
}


#### ___ ● 주요 감사실시내용 ####
# 테이블이 2개로 쪼개져있을 수 있다.
tbl_check_word <- c("전반감사계획", "외부전문가 활용")

tbl_flag <- 0
for(n_tbl in 3:0){
  tbl_sub <- tbl[[tbl_cnt - n_tbl]]
  tbl_check <- sum(grepl(pattern = paste(tbl_check_word, collapse = "|"), tbl_sub[, 1]))
  
  if(tbl_check == 2){ # 한 테이블에 두 단어가 모두 들어있는 경우. (한 페이지에 모든 테이블의 모든 정보가 들어가 있는 경우)
    tbl_03_detail <- tbl_sub
  }
  
  if((tbl_check == 1) & (tbl_flag == 0)){ # 테이블이 나누어져 있는 경우
    tbl_03_detail <- tbl_sub
    tbl_03_detail_2nd <- tbl[[tbl_cnt - n_tbl + 1]]
    if(ncol(tbl_03_detail) > ncol(tbl_03_detail_2nd)){
      tbl_03_detail_2nd <- cbind(tbl_03_detail_2nd, "")
    } 
    if(ncol(tbl_03_detail) < ncol(tbl_03_detail_2nd)){
      tbl_03_detail <- cbind(tbl_03_detail, "")
    } 
    tbl_03_detail <- rbind(tbl_03_detail, tbl_03_detail_2nd)
    tbl_flag <- 1
  }
}


#### ___ ● 커뮤니케이션 ####
tbl_check_word <- c("구분", "1")
tbl_sub <- tbl[[tbl_cnt]]
tbl_check <- sum(grepl(pattern = paste(tbl_check_word, collapse = "|"), tbl_sub[, 1]))
if(tbl_check == 2){
  tbl_04_com <- tbl_sub
} else {
  tbl_04_com <- NA
}

#### 2. 값 파싱 ####
#### ___ ● 감사대상업무 ####
tbl_01_audit_value <- grep(pattern = "[0-9]{4}.{1,4}[0-9]", x = tbl_01_audit, value = TRUE) # 감사일
tbl_01_audit_value <- stri_extract(str = tbl_01_audit_value, regex = "[0-9]{4}.*?$")
tbl_01_audit_value

#### ___ ● 감사 시간 ####
tbl_sub = tbl_02_hour
tbl_sub_values <- tbl_sub[(grep(pattern = "투입 인원수", tbl_sub[, 1]):nrow(tbl_sub)), 2:ncol(tbl_sub)]
tbl_sub_values <- tbl_sub_values[c(-3, -5), ]
tbl_sub_values <- apply(X = tbl_sub_values, MARGIN = 1, FUN = paste, collapse = " ")
tbl_sub_values <- strsplit(tbl_sub_values, split = " ")
tbl_sub_values <- matrix(unlist(tbl_sub_values), nrow = 4, byrow = TRUE)
tbl_sub_values <- tbl_sub_values[, -which(apply(tbl_sub_values, MARGIN = 2, FUN = function(x){sum(x == "")}) == 4)]
tbl_sub_values[tbl_sub_values %in% c("", "-")] = NA 

tbl_02_hour <- tbl_sub_values

#### ___ ● 주요 감사실시내용 ####
# tbl_03_detail

#### ______ 1) 전반 감시계획 ####
# 3col 에서 날짜가 처음 등장하는 위치.
tbl_03_pos_01 <- min(grep(pattern = "^[0-9]{4}", tbl_03_detail[, 2])[1],
                     grep(pattern = "^[0-9]{4}", tbl_03_detail[, 3])[1])
tbl_03_pos_01[2] <- grep(pattern = "^일$", tbl_03_detail[tbl_03_pos_01, ])


df_tbl_03_detail_01 <- data.frame(time   = tbl_03_detail[tbl_03_pos_01[1], tbl_03_pos_01[2] - 2], # 수행시기
                                  when   = tbl_03_detail[tbl_03_pos_01[1], tbl_03_pos_01[2] - 1], # 일자
                                  detail = tbl_03_detail[tbl_03_pos_01[1] + 1, tbl_03_pos_01[2] - 2]) # 주요 내용
df_tbl_03_detail_01

#### ______ 2) 현장감사 주요내용 ####
# 2col 에서 날짜가 처음 등장하는 위치.
tbl_03_pos_02 <- c(grep(pattern = "^[0-9]{4}", tbl_03_detail[, 2])[1], 
                   min(grep(pattern = "^실사", tbl_03_detail[, 1])[1],
                       grep(pattern = "^실사", tbl_03_detail[, 2])[1]) - 1)

tbl_03_detail_02 <- tbl_03_detail[tbl_03_pos_02[1]:tbl_03_pos_02[2], ]

if(sum(grep(pattern <- "^[0-9]", tbl_03_detail_02[, 1])) > 0){
  tbl_03_detail_02 <- tbl_03_detail_02[(grep(pattern = "상주", tbl_03_detail_02[, 2]) + 1):nrow(tbl_03_detail_02), ]
} else {
  tbl_03_detail_02 <- tbl_03_detail_02[, -1]
}

if(length(which(apply(tbl_03_detail_02, MARGIN = 1, FUN = function(x){sum(x == "")}) == ncol(tbl_03_detail_02))) > 0){
  tbl_03_detail_02 <- tbl_03_detail_02[-which(apply(tbl_03_detail_02, MARGIN = 1, FUN = function(x){sum(x == "")}) == ncol(tbl_03_detail_02)), ]
}

tbl_03_pos_03 <- grep(pattern = "~", x = tbl_03_detail_02[, 1])
# tbl_03_pos_03 <- matrix(c(tbl_03_pos_03, tbl_03_pos_03 + 2), nrow = 2, byrow = TRUE)
tbl_03_pos_03 <- matrix(c(tbl_03_pos_03, tbl_03_pos_03 + 2), nrow = 2)

tbl_03_detail_02_date <- paste0(tbl_03_detail_02[tbl_03_pos_03[, 1], 1], " ", tbl_03_detail_02[tbl_03_pos_03[, 2], 1])

tbl_03_detail_02_date_hour <- tbl_03_detail_02[grep(pattern = "^[0-9].*?명", tbl_03_detail_02[, 2]), 2:3]
tbl_03_detail_02_date_hour <- unlist(apply(tbl_03_detail_02_date_hour, MARGIN = 1, FUN = strsplit, split = " "))
tbl_03_detail_02_date_hour <- matrix(tbl_03_detail_02_date_hour, ncol = 2, byrow = TRUE)
tbl_03_detail_02_date_hour <- apply(tbl_03_detail_02_date_hour, MARGIN = 1, FUN = paste0, collapse = "")
tbl_03_detail_02_date_hour <- matrix(tbl_03_detail_02_date_hour, nrow = 2, byrow = TRUE)
tbl_03_detail_02_date_hour <- cbind(tbl_03_detail_02_date, tbl_03_detail_02_date_hour)

tbl_03_detail_02_comment_01 <- paste0(tbl_03_detail_02[1:tbl_03_pos_03[1, 2], 4], collapse = " ")
if(nrow(tbl_03_detail_02) > tbl_03_pos_03[2, 1]){
  tbl_03_detail_02_comment <- c(tbl_03_detail_02_comment_01)
  for(n_row in 2:nrow(tbl_03_pos_03)){
    # n_row = 2
    pos_sub = diff(tbl_03_pos_03[(n_row - 1):n_row, 1]) - 3
    tbl_03_detail_02_comment_sub <- paste0(tbl_03_detail_02[(tbl_03_pos_03[n_row, 1] - pos_sub):(tbl_03_pos_03[n_row, 2] + pos_sub), 4], collapse = " ")
    tbl_03_detail_02_comment[n_row] <- tbl_03_detail_02_comment_sub
  }
} else {
  tbl_03_detail_02_comment <- tbl_03_detail_02_comment_01
}
tbl_03_detail_02_comment <- gsub(pattern = " {2, }", replacement = " ", tbl_03_detail_02_comment)
tbl_03_detail_02_comment

df_tbl_03_detail_02 <- as.data.frame(cbind(tbl_03_detail_02_date_hour, tbl_03_detail_02_comment))
colnames(df_tbl_03_detail_02) = c("a", "b", "c", "d")
df_tbl_03_detail_02

#### ______ 3) 재고자산실사 ####
tbl_03_pos_04 <- grep(pattern = "^실사", tbl_03_detail[, 2])

tbl_03_detail_03_ins_stock <- tbl_03_detail[tbl_03_pos_04[1:3], 3:5]
df_tbl_03_detail_03 <- data.frame(time = tbl_03_detail_03_ins_stock[1, 1],
                                  duration = paste0(tbl_03_detail_03_ins_stock[1, 2:3], collapse = ""),
                                  place = tbl_03_detail_03_ins_stock[2, 1],
                                  object = tbl_03_detail_03_ins_stock[3, 1])
df_tbl_03_detail_03

#### ______ 4) 금융자산실사 ####
tbl_03_pos_04 <- grep(pattern = "^실사", tbl_03_detail[, 2])

tbl_03_detail_04_ins_fin = tbl_03_detail[tbl_03_pos_04[4:6], 3:5]
df_tbl_03_detail_04 <- data.frame(time     = tbl_03_detail_04_ins_fin[1, 1],
                                  duration = paste0(tbl_03_detail_04_ins_fin[1, 2:3], collapse = ""),
                                  place    = tbl_03_detail_04_ins_fin[2, 1],
                                  object   = tbl_03_detail_04_ins_fin[3, 1])
df_tbl_03_detail_04

#### ______ 5) 외부조회 ####
tbl_03_detail_05_ext <- tbl_03_detail[grep(pattern = "조회$", tbl_03_detail[, 2]), 2:ncol(tbl_03_detail)]
tbl_03_detail_05_ext <- tbl_03_detail_05_ext[, -which(apply(tbl_03_detail_05_ext, MARGIN = 2, FUN = function(x){sum(x == "")}) == 2)]
tbl_03_detail_05_ext <- as.character(cbind(tbl_03_detail_05_ext[1, ], tbl_03_detail_05_ext[2, ]))
tbl_03_detail_05_ext <- gsub(pattern = "O ", replacement = "O@", tbl_03_detail_05_ext)
tbl_03_detail_05_ext <- unlist(strsplit(tbl_03_detail_05_ext, split = "@"))
tbl_03_detail_05_ext <- ifelse(test = tbl_03_detail_05_ext == "-", yes = NA, no = tbl_03_detail_05_ext)

df_tbl_03_detail_05 <- as.data.frame(matrix(tbl_03_detail_05_ext[(1:4) * 2], nrow = 1))
colnames(df_tbl_03_detail_05) <- tbl_03_detail_05_ext[(1:4) * 2 - 1]
df_tbl_03_detail_05

#### ______ 6) 커뮤니케이션 ####
tbl_03_pos_05 <- grep(pattern = "^지배기구", tbl_03_detail[, 1])
tbl_03_detail_06_com <- tbl_03_detail[tbl_03_pos_05:(tbl_03_pos_05 + 1), 3:4]

df_tbl_03_detail_06 <- data.frame(time = paste0(tbl_03_detail_06_com[1, ], collapse = ""),
                                 when = paste0(tbl_03_detail_06_com[2, ], collapse = ""))
colnames(df_tbl_03_detail_06) <- tbl_03_detail[tbl_03_pos_05:(tbl_03_pos_05 + 1), 2]
df_tbl_03_detail_06

#### ______ 7) 외부전문가활용 ####
tbl_03_pos_06 <- c(grep(pattern = "^외부전문가", tbl_03_detail[, 1]),
                   grep(pattern = "^감사", tbl_03_detail[, 2]))

if(tbl_03_pos_06[1] > tbl_03_pos_06[2]){
  tbl_03_detail_07_ext <- tbl_03_detail[c(tbl_03_pos_06[2], tbl_03_pos_06[2] + 2), 2:ncol(tbl_03_detail)]
} else {
  tbl_03_detail_07_ext <- tbl_03_detail[tbl_03_pos_06[1]:(tbl_03_pos_06[1] + 1), 2:ncol(tbl_03_detail)]
}

tbl_03_pos_07 <- grep(pattern = "^일$", tbl_03_detail_07_ext[2, ])

df_tbl_03_detail_07 <- data.frame(detail   = ifelse(test = tbl_03_detail_07_ext[1, 2] == "-", 
                                                    yes = NA,
                                                    no = paste0(tbl_03_detail_07_ext[1, 2:ncol(tbl_03_detail_07_ext)], collapse = "")),
                                  when     = ifelse(test = tbl_03_detail_07_ext[2, tbl_03_pos_07 - 2] == "-", 
                                                    yes = NA,
                                                    no = paste0(tbl_03_detail_07_ext[2, 1:(tbl_03_pos_07 - 2)], collapse = "")),
                                  duration = ifelse(test = tbl_03_detail_07_ext[2, tbl_03_pos_07 - 1] == "-", 
                                                    yes = NA, 
                                                    no = paste0(tbl_03_detail_07_ext[2, (tbl_03_pos_07 - 1):tbl_03_pos_07], collapse = "")))
df_tbl_03_detail_07

#### ___ ● 커뮤니케이션 ####
tbl_04_com

tbl_04_colname <- as.character(tbl_04_com[1, ])
tbl_04_obs    <- as.numeric(tbl_04_com[grep(pattern = "[0-9]", tbl_04_com[, 1]), 1])
tbl_04_date   <- tbl_04_com[grep(pattern = "^[0-9]{4}", tbl_04_com[, 2]), 2]
tbl_04_people <- tbl_04_com[tbl_04_com[, 3] != "", 3][-1]
tbl_04_type   <- tbl_04_com[tbl_04_com[, 4] != "", 4][-1]
tbl_04_agenda <- tbl_04_com[, 5] # 일부러 제목 빼지 않음.

if(tbl_04_obs == 1){
  tbl_04_type <- paste(tbl_04_type, collapse = " ")
}

tbl_04_pos_01 <- grep(pattern = "^회사", tbl_04_people) # 보통 회사 또는 회사측 으로 시작함
tbl_04_pos_02 <- c((tbl_04_pos_01 - 1)[-1], length(tbl_04_people))

tbl_04_people_pasted <- c()
if(tbl_04_pos_01 > 0){
  for(pos in 1:length(tbl_04_pos_01)){
    tbl_04_people_pasted[pos] <- paste(tbl_04_people[tbl_04_pos_01[pos]:tbl_04_pos_02[pos]], collapse = "/")
  }
} else {
  # 그냥 이름만 있는 경우도 있음
  # matrix로 처리
  tbl_04_people_pasted <- matrix(tbl_04_people, nrow = length(tbl_04_obs), byrow = TRUE)  
  tbl_04_people_pasted <- apply(tbl_04_people_pasted, MARGIN = 1, FUN = "paste", collapse = "/")
}

tbl_04_agenda_pasted <- c()
if(tbl_04_pos_01 > 0){
  for(pos in 1:length(tbl_04_pos_01)){
    tbl_04_agenda_pasted[pos] <- paste(tbl_04_agenda[tbl_04_pos_01[pos]:tbl_04_pos_02[pos]], collapse = "/")
  }
} else {
  # 그냥 이름만 있는 경우도 있음
  # matrix로 처리
  tbl_04_people_pasted <- matrix(tbl_04_people, nrow = length(tbl_04_obs), byrow = TRUE)  
  tbl_04_people_pasted <- apply(tbl_04_people_pasted, MARGIN = 1, FUN = "paste", collapse = "/")
}

tbl_04_gap <- c()
tbl_04_gap[1] <- which(tbl_04_com[, 1] == 1) - 2 # 첫 번째.
if(length(tbl_04_obs) >= 2){
  for(n_gap in 2:length(tbl_04_obs)){
    tbl_04_gap[n_gap] <- diff(which(tbl_04_com[, 1] %in% c(n_gap - 1, n_gap))) - tbl_04_gap[n_gap - 1] - 1  
  }
}
tbl_04_gap <- tbl_04_gap * 2 + 1
tbl_04_pos_03 <- c(2, cumsum(tbl_04_gap) + 1)

tbl_04_agenda_pasted <- c()
for(n_pos in 1:length(tbl_04_obs)){
  tbl_04_agenda_pasted[n_pos] <- paste(tbl_04_agenda[tbl_04_pos_03[n_pos]:tbl_04_pos_03[n_pos + 1]], collapse = "/")
}
tbl_04_agenda_pasted <- gsub(pattern = "\\/{2,}", replacement = "/", tbl_04_agenda_pasted)
tbl_04_agenda_pasted <- gsub(pattern = "^\\/|\\/$", replacement = "", tbl_04_agenda_pasted)

df_tbl_04_com <- data.frame(obs  = tbl_04_obs,
                            date = tbl_04_date,
                            ppl  = tbl_04_people_pasted,
                            type = tbl_04_type,
                            agenda = tbl_04_agenda_pasted)
colnames(df_tbl_04_com) <- tbl_04_colname
df_tbl_04_com

#### 3. json 변환 ####
pdf_list <- list(tbl_01 = tbl_01_audit_value,
                tbl_02 = tbl_02_hour,
                tbl_03 = list(df_tbl_03_detail_01,
                              df_tbl_03_detail_02,
                              df_tbl_03_detail_03,
                              df_tbl_03_detail_04,
                              df_tbl_03_detail_05,
                              df_tbl_03_detail_06,
                              df_tbl_03_detail_07),
                tbl_04 = df_tbl_04_com)
pdf_list



# json 변환까지 마친 이후에는 table 객체를 초기화 해야 한다. 그래야 에러가 났는지 안났는지 알지.