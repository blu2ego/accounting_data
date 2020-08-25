file_path_a001_doc = "doc_list_A001_codes"
list_doc = glob.glob(file_path_a001_doc + "/*.csv", recursive = True)

file_path_a001_xml = "doc_list_A001_xml_download"
list_xml = glob.glob(file_path_a001_xml + "/**/*.xml", recursive = True)

list_xml = pd.Series(list_xml)

df_list_xml = pd.DataFrame({"path": list_xml,
                            "corp_code": list_xml.str.extract(pat = "corp_no_([0-9]{6,8})")[0],
                            "doc_no": list_xml.str.extract(pat = "([0-9]{12,16})_007")[0]})
df_list_xml["year"] = df_list_xml["doc_no"].str.slice(start = 0, stop = 4)

def recent_doc(x):
    df_return = ""
    return df_return
    
# df_list_xml_sub.groupby("corp_code").agg(recent_doc)
