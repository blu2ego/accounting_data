# WARD(Wrangling Accounting Related Raw Data)

Crawling and Processing of Accounting Related Raw Data

# To Do Lists

1. crawl XMLs from Open DART
2. crawl PDFs from DART - Download but not process <- 
3. crawl Google Play Info

# Directory Structure
```bash
├── crawling
│   ├── dart
│   │   ├── python
│   │   │   ├── pc01_environment.py
│   │   │   ├── pc02_downloader_corps_code_zip.py
│   │   │   ├── pc03_downloader_a001_list_xml.py
│   │   │   ├── pc04_downloader_f001_list_xml.py
│   │   │   ├── pc05_downloader_a001_zip.py
│   │   │   ├── pc06_downloader_a-f001_pdf.py
│   │   │   ├── pc07_downloader_f001_zip.py
│   │   │   ├── pc08_downloader_f-f001_pdf.py
│   │   │   └── pc99_temp.py
│   │   └── r
│   │       ├── cdr01_environments.R
│   │       ├── cdr02_downloader_corps_code_zip.R
│   │       ├── cdr03_downloader_a001_list_xml.R
│   │       ├── cdr04_downloader_f001_list_xml.R
│   │       ├── cdr05_downloader_a001_zip.R
│   │       ├── cdr06_downloader_a-f001_pdf.R
│   │       ├── cdr06_downloader_a-O001_pdf.R
│   │       ├── cdr07_downloader_f001_zip.R
│   │       ├── cdr08_downloader_f-f001_pdf.R
│   │       └── full_crawling.R
│   ├── google_play
│   │   └── r
│   │       └── google_paly.R
│   └── ksa
│       └── crawl_sr.R
├── dart
│   └── corps_code
├── google_play
├── images
│   └── file_structure.png
├── ksi
├── processing
│   └── dart
│       ├── python
│       │   ├── pp01_environment.py
│       │   ├── pp02_corps_code_unzip.py
│       │   ├── pp03_corps_code_xml_parser.py
│       │   ├── pp04_downloaded_a001_list_xml_parser.py
│       │   ├── pp05_downloaded_f001_list_xml_parser.py
│       │   ├── pp06_downloaded_a001_unzip.py
│       │   ├── pp07_downloaded_f001_unzip.py
│       │   ├── pp08_xml_handler.py
│       │   └── pp09_pdf_handler.py
│       └── r
│           ├── dstrb_ia_ops_report
│           │   ├── ia_ops_logs_part_10.txt
│           │   ├── ia_ops_logs_part_1.txt
│           │   ├── ia_ops_logs_part_2.txt
│           │   ├── ia_ops_logs_part_3.txt
│           │   ├── ia_ops_logs_part_4.txt
│           │   ├── ia_ops_logs_part_5.txt
│           │   ├── ia_ops_logs_part_6.txt
│           │   ├── ia_ops_logs_part_7.txt
│           │   ├── ia_ops_logs_part_8.txt
│           │   ├── ia_ops_logs_part_9.txt
│           │   ├── pdr21_pdf_handler_ia_ops_part_10.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_1.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_2.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_3.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_4.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_5.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_6.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_7.R
│           │   ├── pdr21_pdf_handler_ia_ops_part_8.R
│           │   └── pdr21_pdf_handler_ia_ops_part_9.R
│           ├── pdr01_environments.R
│           ├── pdr02_corps_code_unzip.R
│           ├── pdr03_corps_code_xml_parser.R
│           ├── pdr04_downloaded_a001_list_xml_parser.R
│           ├── pdr05_downloaded_f001_list_xml_parser.R
│           ├── pdr06_downloaded_a001_unzip.R
│           ├── pdr07_downloaded_f001_unzip.R
│           ├── pdr08_xml_handler_external_audit_from_biz.R
│           ├── pdr09_xml_handler_external_audit_from_aud.R
│           ├── pdr10_xml_handler_internal_audit_from_biz.R
│           ├── pdr11_xml_handler_internal_audit_from_aud.R
│           ├── pdr20_pdf_handler.R
│           ├── pdr21_pdf_handler_ia_ops.R
│           └── samples
│               ├── refer_xml_handler_blu2ego.R
│               ├── refer_xml_handler_encaion.R
│               ├── rps01_external_audit.R
│               ├── rps02_internal_accounting.R
│               └── rps99_table_handling_sample.R
├── README.md


# File Structure for Wrangling DART <- to be fixed
![File Structure for Wrangling DART](https://github.com/blu2ego/ward/blob/master/images/file_structure.png "File Structure for Wrangling DART")
