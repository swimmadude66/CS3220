__author__ = 'Adam'

import sys
import re

file1 = open(sys.argv[1], 'r')
file2 = open(sys.argv[2], 'r')
linenum = 0

for line1 in file1:
    line2 = file2.readline()
    linenum+=1
    line1 = line1.capitalize()
    line2 = line2.capitalize()
    line1 = re.sub(r'\s+', ' ', line1)
    line2 = re.sub(r'\s+', ' ', line2)
    if line2 != line1:
        print(linenum)
        print("\t"+line1)
        print("\t"+line2)
