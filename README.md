# WARD(Wrangling Accounting Related Raw Data)

Crawling and Processing of Accounting Related Raw Data

# To Do Lists

1. crawl XMLs from Open DART
2. crawl PDFs from DART - Download but not process <- 
3. crawl Google Play Info

# Directory Structure
```bash
├── 1000.dart
│   ├── 1100.corps_code
│   │   ├── 1. cdr01_environments.R
│   │   ├── 2. cdr02_downloader_corps_code_zip.R
│   │   ├── 3. pdr01_environments.R
│   │   ├── 4. pdr02_corps_code_unzip.R
│   │   ├── 5. pdr03_corps_code_xml_parser.R
│   │   └── corps_code.R
│   ├── 1200.filings
│   │   ├── 1210.A001
│   │   │   ├── 1. cdr03_downloader_a001_list_xml.R
│   │   │   └── 2. pdr04_downloaded_a001_list_xml_parser.R
│   │   ├── 1220.F001
│   │   │   ├── 1. cdr04_downloader_f001_list_xml.R
│   │   │   └── 2. pdr05_downloaded_f001_list_xml_parser.R
│   │   └── 1230.I001
│   │       └── crawling_I001.R
│   ├── 1300.reports
│   │   ├── 1310.biz_reports
│   │   │   ├── 1311.A001
│   │   │   │   ├── 1. cdr05_downloader_a001_zip.R
│   │   │   │   └── 2. pdr06_downloaded_a001_unzip.R
│   │   │   └── 1312.F001(for others companies, pending)
│   │   │       ├── cdr07_downloader_f001_zip.R
│   │   │       └── pdr07_downloaded_f001_unzip.R
│   │   └── 1320.to_be_added
│   ├── 1400.data
│   │   ├── 1410.from_biz_report
│   │   │   ├── pdr08_xml_handler_external_audit_from_biz.R
│   │   │   ├── pdr09_xml_handler_external_audit_from_aud.R
│   │   │   ├── pdr10_xml_handler_internal_audit_from_biz.R
│   │   │   └── pdr11_xml_handler_internal_audit_from_aud.R
│   │   ├── 1420.from_aud_report
│   │   └── 1430.to be added
│   └── Setting_Global_Environments.R
├── 2000.ksi
│   ├── crawling_sustainability_reports.Rmd
│   ├── crawl_sr.R
│   └── images
│       └── ksi_db.png
├── 3000.google_play
│   └── google_paly.R
├── README.md
├── sample
│   └── test_code.R
```

# File Structure for Wrangling DART <- to be added
