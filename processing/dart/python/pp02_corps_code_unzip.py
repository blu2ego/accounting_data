# set working directory
os.chdir(main_dir + corps_code_zip_dir)

file_name       = "corps_code_" + base_date + ".zip"
file_name_unzip = "corps_code_" + base_date + ".xml"
file_unzip_path = "../xml/"

file_zip = zipfile.ZipFile(file_name)
file_zip.extractall(file_unzip_path)
file_zip.close()

os.rename(file_unzip_path + "CORPCODE.xml", file_unzip_path + file_name_unzip)
