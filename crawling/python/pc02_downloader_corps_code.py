exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/crawling/python/pc01_environment.py").read())

# set working directory
os.chdir(mainDir + corps_code_zip_Dir)

# loading required libraries
import urllib.request

corps_code_raw = "corps_code_" + base_date + ".zip"
corps_code_request_url = "https://opendart.fss.or.kr/api/corpCode.xml?&crtfc_key=" + key_dart

urllib.request.urlretrieve(corps_code_request_url, corps_code_raw)
