from datetime import datetime
from genericpath import isfile
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

def ZipDir(path, ziph):
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))


def MakeZip(name, source, destination):
    
    now = datetime.now()
    curDate = now.strftime("%d%m%Y_%H%M")    
    zipf = ZipFile(f"{destination}\{name}_{curDate}.zip", 'w', zipfile.ZIP_DEFLATED)

    scriptDir = os.path.dirname(os.path.realpath(__file__))
    os.chdir(scriptDir)
    
    if(os.path.isdir(source)):      #archive dir
        ZipDir(source, zipf)    
        print(f"Made backup for directory {name}")
        zipf.close()
    elif(os.path.isfile(source)):   #archive file
        os.chdir(os.path.dirname(source))
        zipf.write(os.path.basename(source))
        print(f"Made backup for file {name}")    
        zipf.close()
    else:                           #if nothing was found
        os.remove(f"{destination}\{name}_{curDate}.zip")    


if __name__ == '__main__':
    f = open(INPUT_FILE, 'r')

    for line in f.readlines():
        if("#" not in line):
            line = re.sub(r"\n$", r"", line)

            name = line.split(";")[0]
            source = line.split(";")[1]
            destination = line.split(";")[2].replace(r"\n","")

            MakeZip(name, source, destination)
    
    input("\nPlease press Enter for continue...")