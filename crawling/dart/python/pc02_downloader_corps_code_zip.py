exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(mainDir + corps_code_zip_Dir)

# loading required libraries
import urllib.request

base_date_corps_code_zip = "corps_code_" + base_date + ".zip"
request_url_corps_code = "https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=" + key_dart

urllib.request.urlretrieve(request_url_corps_code, base_date_corps_code_zip)
