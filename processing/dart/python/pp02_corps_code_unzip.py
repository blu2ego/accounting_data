exec(open("C:/Users/Encaion/Documents/41_outsource/crawling_DART_package/processing/python/pp01_environment.py").read()) 

# set working directory
os.chdir(mainDir + corps_code_zip_Dir)

file_name = "corps_code_" + base_date + ".zip"
file_xml_unzip_path = "../xml/"
file_name_unzip = "corps_code_" + base_date + ".xml"

file_zip = zipfile.ZipFile(file_name)
file_zip.extractall(file_xml_unzip_path)
file_zip.close()

os.rename(file_xml_unzip_path + "CORPCODE.xml", file_xml_unzip_path + file_name_unzip)
