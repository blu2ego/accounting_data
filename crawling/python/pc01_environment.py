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

# setting base path
mainDir = ""

# setting additional paths and making directories
corps_code_zip_Dir = "results/corps_code/zip/"
corps_code_unzip_Dir = "results/corps_code/xml/"
corps_code_parsed_csv_Dir = "results/corps_code/csv/"

dir_maker(mainDir + corps_code_zip_Dir)
dir_maker(mainDir + corps_code_unzip_Dir)
dir_maker(mainDir + corps_code_parsed_csv_Dir)

# setting additional paths and making directories related to A001
biz_report_list_xml_Dir = "results/biz_report/xml/" + base_date + "/"
biz_report_list_csv_Dir = "results/biz_report/csv/" + base_date + "/"
biz_report_zip = "results/biz_report/zip/" + base_date + "/"
biz_report_pdf = "results/biz_report/pdf/" + base_date + "/"
biz_report_doc = "results/biz_report/doc/" + base_date + "/"


dir_maker(mainDir + biz_report_list_xml_Dir)
dir_maker(mainDir + biz_report_list_csv_Dir)
dir_maker(mainDir + biz_report_zip)
dir_maker(mainDir + biz_report_pdf)
dir_maker(mainDir + biz_report_doc)

# setting additional paths and making directories related to F001
audit_report_list_xml_Dir = "results/audit_report/xml/" + base_date + "/"
audit_report_list_csv_Dir = "results/audit_report/csv/" + base_date + "/"
audit_report_zip = "results/audit_report/zip/" + base_date + "/"
audit_report_pdf = "results/audit_report/pdf/" + base_date + "/"
audit_report_doc = "results/audit_report/doc/" + base_date + "/"

dir_maker(mainDir + audit_report_list_xml_Dir)
dir_maker(mainDir + audit_report_list_csv_Dir)
dir_maker(mainDir + audit_report_zip)
dir_maker(mainDir + audit_report_pdf)
dir_maker(mainDir + audit_report_doc)
