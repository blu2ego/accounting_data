# set working directory
# os.chdir(main_dir + audit_report_list_xml_dir)

# loading required libraries
from bs4 import BeautifulSoup

file_path_a001_doc = "doc_list_A001_codes"
list_doc = glob.glob(file_path_a001_doc + "/*.csv", recursive = True)

file_path_a001_xml = "doc_list_A001_xml_download"
list_xml = glob.glob(file_path_a001_xml + "/**/*.xml", recursive = True)

list_xml = pd.Series(list_xml)

df_list_xml = pd.DataFrame({"path": list_xml,
                            "corp_code": list_xml.str.extract(pat = "corp_code_([0-9]{6,8})")[0],
                            "doc_no": list_xml.str.extract(pat = "([0-9]{12,16})_007")[0]})
df_list_xml["year"] = df_list_xml["doc_no"].str.slice(start = 0, stop = 4)

df_list_xml["corp_code"] = df_list_xml["corp_code"].astype("int")
df_list_xml["year"     ] = df_list_xml["year"     ].astype("int")

value_filter_year_min_xml = 2015
value_filter_year_max_xml = 2020

df_list_xml = df_list_xml.loc[(df_list_xml["year"] <= value_filter_year_max_xml) & ((df_list_xml["year"] >= value_filter_year_min_xml))]

# def recent_doc(x):
#     df_return = ""
#     return df_return
#     
# df_list_xml_sub.groupby("corp_code").agg(recent_doc)

corp_list = df_list_xml["corp_code"].unique()

# for n_corp in range(len(corp_list)):
n_corp = 0
df_list_xml_sub = df_list_xml.loc[df_list_xml["corp_code"] == corp_list[n_corp]].reset_index(drop = True)

# for n_file in range(len(df_list_xml_sub)):
n_file = 0
# xml_doc = open(file = df_list_xml_sub.loc[n_file, "path"], mode = "r", encoding = "UTF-8")
xml_doc = open(file = df_list_xml_sub.loc[n_file, "path"], mode = "r", encoding = "CP949")
xml_doc = BeautifulSoup(xml_doc)

crop_name = xml_doc.find("company-name").text
doc_code = xml_doc.find("document-name")["acode"]
doc_title = xml_doc.find("document-name").text

tables = xml_doc.find_all("title", {"aassocnote": True})
table_list = [tab["aassocnote"] for tab in tables]

# # audit hour table
# xml_doc %>%
#   html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//title') %>%
#   html_text() -> table_name
# 
# xml_doc %>%
#   html_nodes(xpath = '//*/title[@aassocnote="D-0-2-2-0"]/..//tbody') -> table_sub
# 
# table_sub[1] %>%
#   html_text() %>% 
#   gsub(pattern = "\n", replacement = "") -> table_sub_comment
