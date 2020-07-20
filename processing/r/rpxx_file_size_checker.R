# checking pdf file size.
# when file size is 0kb, value of is_zero(column) is 1

listt_full <- list.files(path = "doc_list_A001_pdf_download/",
                        full.names = TRUE,
                        recursive = TRUE)

df_listt <- data.frame(path = listt_full,
                      year = as.numeric(substr(x = listt_full, start = 64, stop = 67)))

for(n in 1:length(listt_full)){
  df_listt[n, "size"] <- file.info(listt_full[n])$size
}

df_listt[, "is_zero"] <- ifelse(df_listt$size == 0, yes = 1, no = 0)
table(df_listt[, c("year", "is_zero")])
