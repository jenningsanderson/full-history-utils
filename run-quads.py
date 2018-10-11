#!/usr/bin/python3

import os

for file in os.listdir('QUAD_EXTRACTS'):
    print(file)
    
    command = "./run.sh QUAD_EXTRACTS/{0} QUADS/{1}".format(file, file[:-8])
    print(command)