#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : 
#-----------------------------------------------------------------------------
# Description:
# Script to quickly test rogue devices
#-----------------------------------------------------------------------------
# This file is part of the HPS project. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the HPS project, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import time
import argparse
import glob
import os
import sys
import pyrogue
import rogue

# Search paths
pyrogue.addLibraryPath('../python')
pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)
#rogue.Logging.setFilter('pyrogue._Device', rogue.Logging.Info)

# Set the argument parser
parser = argparse.ArgumentParser()

# Add arguments
parser.add_argument(
    "--path", '-p', 
    type     = str,
    required = True,
    help     = "path to image",
)

parser.add_argument(
    "--ip", 
    type     = str,
    required = False,
    default = '192.168.2.10',
    help     = "IP address",
)  

# Get the arguments
args = parser.parse_args()
print(args)

# Get a list of images
images = glob.glob('{}/*.mcs*'.format(args.path))
images = list(reversed(sorted(images)))

for i, l in enumerate(images):
    print('{} : {}'.format(i, l))

idx = int(input('Enter image: '))
image = images[idx]

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

with KpixDaq.DesyTrackerRoot(pollEn=False, ip=args.ip) as root:

    root.DesyTracker.AxiVersion.readBlocks()
    root.DesyTracker.AxiVersion.checkBlocks()
    root.DesyTracker.AxiVersion.printStatus()

    x = input('Are you sure you wish to procede [y]/n: ')
    if x == 'n':
        exit()
    
    prom = root.DesyTracker.AxiMicronN25Q
    prom.enable.set(True)

    print(f'Load MCS file: {image}')
    prom.LoadMcsFile(image)
        
    root.DesyTracker.AxiVersion.FpgaReload()
        

exit()


