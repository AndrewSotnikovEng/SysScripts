from datetime import datetime
from json.tool import main
import os
import re
from zipfile import ZipFile, ZIP_DEFLATED
import zipfile

'''
    Script makes bakup based on input file.
    Please specify INPUT_FILE if needed.
    
    Lines which begin from "#" will be ignore. The template of input file is:
    
        name;source;destination           
        
'''

INPUT_FILE = "input.txt"

def zipdir(path, ziph):
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))


if __name__ == '__main__':
    f = open(INPUT_FILE, 'r')
    now = datetime.now()
    print(chr(27) + "[2J")

    curDate = now.strftime("%d%m%Y_%H%M")

    for line in f.readlines():
        if("#" not in line):
            line = re.sub(r"\n$", r"", line)

            name = line.split(";")[0]
            source = line.split(";")[1]
            destination = line.split(";")[2].replace(r"\n","")

            zipf = ZipFile(f"{destination}\{name}_{curDate}.zip", 'w', zipfile.ZIP_DEFLATED)
            zipdir(source, zipf)
            zipf.close()
            print(f"Made backup for {name}")