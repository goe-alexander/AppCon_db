from sys import argv
from os.path import exists
import os
import time
import sys
script, rootFld  = argv

#Function that prints the characters with a small delay
def print_delay(str):
    for i in str:
        sys.stdout.write(i)
        sys.stdout.flush()
        time.sleep(0.05)
def delete_content(pfile_path):
	print "trying to delete: "
	pfile_path.seek(0)
	pfile_path.truncate

#We need to find out the number of files in a directory and empty all of them
d = os.path.abspath(rootFld)

if os.path.isdir(d):
	print "File is a directory \n"
	print_delay('We have found the following files \n')
	for flName in os.listdir(d):
		print_delay(' - ' + flName + '\n')
		fOpen = open(d + '/' + flName, 'w')
		fOpen.close
		print "-------Deleted Contents---------"
else:
	print "File is not a directory"
