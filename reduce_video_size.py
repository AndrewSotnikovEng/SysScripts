# python -m pip install pywin32

from ast import main
import os
import shutil
import subprocess
from time import sleep
import psutil
import threading
import win32con
import win32api
import win32process
import argparse
import textwrap
from send2trash import send2trash


PROCESS_NAME = "ffmpeg"
AFFINITY_MASK = 0xFF       # 0x3 just 2 cores , 0xF - 4, 0x3F - 8, 0xFF - 8
FIND_PROCESS_TIMEOUT = 30
OLD_FILES_DIR = 'tmp'

def getProcessId():
    pid = ""
    for proc in psutil.process_iter():
        if PROCESS_NAME in proc.name():
            pid = proc.pid
    
    return pid

def setProcessAffinity(pid, mask):
    """Set the affinity for process to mask."""
    flags = win32con.PROCESS_QUERY_INFORMATION | win32con.PROCESS_SET_INFORMATION
    handle = win32api.OpenProcess(flags, 0, pid)
    win32process.SetProcessAffinityMask(handle, mask) 

def reduceAffinity(): 
    pid = None
    message = "Couldn't reduce ffmpeg affinity"
    for i in range(FIND_PROCESS_TIMEOUT):
        sleep(1)
        pid = getProcessId()
        if pid != None:            
            try:
                setProcessAffinity(pid, AFFINITY_MASK)
            except TypeError:
                pass            
            # message = f"Reduced affinity for the PID={pid}"    
    print(message)
    
def getFilesToProcess(verbose=False):
    files = os.listdir()
    filesToProcess = []
    for file in files:
        if "mp4" in file:
            if not "_compressed_py" in file:
                filesToProcess.append(file)
    if(verbose):
        for file in filesToProcess:
            print(f"{file}")
        print(f"------------------------------ \
            \nSummary amount of processed files is:\n{ len(filesToProcess)} ")

    return filesToProcess

def doRegularAction():
    files = os.listdir()   
    files_int_total = 0
    processed = 0
    curPosition = 0
    
    filesToProcess = getFilesToProcess()
    print(filesToProcess)
    for file in filesToProcess:                   
        oldName = file
        newName = file.replace(".mp4", "") + "_compressed_py" + ".mp4"
        if newName not in files:
            # start new thread with setting ffmpeg affinity
            t = threading.Thread(target=reduceAffinity, name="Reduce affinity")
            t.daemon = True
            t.start()            
            # run ffmpeg
            command = f"ffmpeg -i \"{oldName}\" -vcodec libx265 -n -crf 28 \"{newName}\""
            returnCode =  subprocess.call(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
            curPosition += 1
            if (returnCode == 0):
                if not os.path.exists(OLD_FILES_DIR):
                    os.makedirs(OLD_FILES_DIR)
                shutil.move(oldName, os.path.join(OLD_FILES_DIR,oldName))
                processed += 1
                print(f"Successfully processed {oldName}. Current position {curPosition}/{len(filesToProcess)}")
            else:
                print(f"Something went wrong with file {oldName}")                

    input("Press any key for close this window")


'''
Args:
verbose - print output

Returns:
filesToProcess - duplicates file list, first elem of list is old name, second is new name

'''
def getDupicates(verbose = False):
    files = os.listdir()
    filesToProcess = []
    for file in files:
        if "mp4" in file:
            # import pdb; pdb.set_trace()
            compressedName = file.replace(".mp4", "") + "_compressed_py" + ".mp4"
            if compressedName in files:
                filesToProcess.append({"origin": file, "processed": compressedName})
    
    if verbose:
        for file in filesToProcess:
            print(f'{file["origin"]} <--------> {file["processed"]}')
            
        if len(filesToProcess) > 0:
            print(f"------------------------------ \
              \nSummary amount of duplicates is:\n{ len(filesToProcess)} ")
        else:
            print(f"All files are process, there is no duplicates")
            
    
        
    return filesToProcess

def removeDuplicates():
    removedFilesCounter = 0
    for file in getDupicates(False):
        # os.remove(file["processed"])
        send2trash(file["processed"])
        print(f"Removed file {file['processed']}")
        removedFilesCounter += 1
    print(f"Removed files in total: {removedFilesCounter}")

if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent('''\
            Few examples:
            --------------------------------
            reduce_video_size.py --remove-duplicates
            reduce_video_size.py --start
            '''
        )
    )
    # Add an argument
    parser.add_argument('--show-duplicates', help="Show unprocessed and processed files", dest= "show_duplicates", action='store_true')
    parser.add_argument('--show-files-to-process', help="Show files to process", dest="show_tobe_processed", action="store_true")
    parser.add_argument('--remove-duplicates', help="Removed files which was partly processed", dest= "remove_duplicates", action='store_true')
    parser.add_argument('--start', help="Start the task", dest= "start", action='store_true')
    args = parser.parse_args()
    
    if(args.show_duplicates):
        getDupicates(True)   
    if(args.show_tobe_processed):
        getFilesToProcess(True)         
    if(args.remove_duplicates):
        removeDuplicates()    
    if(args.start):
        doRegularAction()
    
    
