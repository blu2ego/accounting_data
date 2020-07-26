#!/usr/bin/env python
# coding: utf-8

# In[ ]:


key_dart_file = open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/sources/key_dart.txt", 'r')
key_dart = key_dart_file.readline()
key_dart_file.close()


# In[10]:


import os
import time


# In[27]:


# mainDir = "~/projects/wrangling_accounting_related_data/"
mainDir = "C:/Users/Encaion/Documents/41_outsource/crawling_DART_package"
os.chdir(mainDir)

base_date = time.strftime('%Y%m%d', time.localtime(time.time()))

corps_code_zip_Dir = "results/corps_code/zip/"
corps_code_unzip_Dir = "results/corps_code/xml/"
corps_code_parsed_csv_Dir = "results/corps_code/csv/"


# In[26]:


if not os.path.exists(mainDir + corps_code_zip_Dir):
    os.makedirs(mainDir + corps_code_zip_Dir)
if not os.path.exists(mainDir + corps_code_unzip_Dir):
    os.makedirs(mainDir +corps_code_unzip_Dir)    
if not os.path.exists(mainDir + corps_code_parsed_csv_Dir):
    os.makedirs(mainDir + corps_code_parsed_csv_Dir)


# In[29]:


audit_report_list_xml_Dir = "results/audit_report/audit_report_list/" + base_date + "/"
audit_report_zip = "results/audit_report/zip/" + base_date + "/"


# In[ ]:


if not os.path.exists(mainDir + audit_report_list_xml_Dir):
    os.makedirs(mainDir + audit_report_list_xml_Dir)
if not os.path.exists(mainDir + audit_report_zip):
    os.makedirs(mainDir + audit_report_zip)


# In[ ]:


biz_report_list_xml_Dir = "results/biz_report/biz_report_list/" + base_date + "/"
biz_report_zip = "results/biz_report/zip/" + base_date + "/")


# In[ ]:


if not os.path.exists(mainDir + biz_report_list_xml_Dir):
    os.makedirs(mainDir + biz_report_list_xml_Dir)
if not os.path.exists(mainDir + biz_report_zip):
    os.makedirs(mainDir + biz_report_zip)

