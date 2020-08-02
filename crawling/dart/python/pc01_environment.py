# Setting Global Environments

# importing dart's key
key_dart_file = open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/sources/key_dart.txt", 'r')
key_dart = key_dart_file.readline()
key_dart_file.close()

# loading required libraries
import os
import time

# UDF - dir_maker
def dir_maker(path):
    if not os.path.exists(path):
        os.makedirs(path)
        print("True")
    else:
        print("False")

# setting base date
base_date = time.strftime('%Y-%m-%d', time.localtime(time.time()))

# set main path
mainDir = ""

# set addtional path and create directories related to corp_code
corps_code_zip_Dir        = "results/dart/corps_code/zip/"
corps_code_unzip_Dir      = "results/dart/corps_code/zip/"
corps_code_parsed_csv_Dir = "results/dart/corps_code/zip/"

dir_maker(mainDir + corps_code_zip_Dir)
dir_maker(mainDir + corps_code_unzip_Dir)
dir_maker(mainDir + corps_code_parsed_csv_Dir)

# set addtional path and create directories related to a001
biz_report_list_xml_dir = "results/dart/biz_report_list/xml/" + base_date + "/"
biz_report_list_csv_dir = "results/dart/biz_report_list/csv/" + base_date + "/"
biz_report_zip          = "results/dart/biz_report/zip/" +      base_date + "/"

dir_maker(mainDir + biz_report_list_xml_dir)
dir_maker(mainDir + biz_report_list_csv_dir)
dir_maker(mainDir + biz_report_zip)

# set addtional path and create directories related to f001
audit_report_list_xml_dir = "results/dart/audit_report_list/xml/" + base_date + "/"
audit_report_list_csv_dir = "results/dart/audit_report_list/csv/" + base_date + "/"
audit_report_zip          = "results/dart/audit_report/zip/" + base_date + "/"
audit_report_xml_from_biz = "results/dart/audit_report/xml/from_biz/" + base_date + "/"
audit_report_xml_from_aud = "results/dart/audit_report/xml/from_aud/" + base_date + "/"
audit_report_pdf_from_biz = "results/dart/audit_report/pdf/from_biz/" + base_date + "/"
audit_report_pdf_from_aud = "results/dart/audit_report/pdf/from_aud/" + base_date + "/" 

dir_maker(mainDir + audit_report_list_xml_dir)
dir_maker(mainDir + audit_report_list_csv_dir)
dir_maker(mainDir + audit_report_zip)
dir_maker(mainDir + audit_report_xml_from_biz)
dir_maker(mainDir + audit_report_xml_from_aud)
dir_maker(mainDir + audit_report_pdf_from_biz)
dir_maker(mainDir + audit_report_pdf_from_aud)
