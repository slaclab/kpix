#!/usr/bin/env python

import sys
import os
import logging
import argparse
import datetime
import time

import pyrogue
import rogue

pyrogue.addLibraryPath('../python')
pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)
rogue.Logging.setFilter('pyrogue.ZmqServer', rogue.Logging.Debug)

parser = argparse.ArgumentParser()


parser.add_argument(
    "--ip", 
    type     = str,
    required = False,
    default = '192.168.2.10',
    help     = "IP address",
)

parser.add_argument(
    "--port",
    type=int,
    required=False,
    default=9099,
    help='Port to use for ZMQ Server')
    

parser.add_argument(
    '--debug', '-d',
    action = 'store_true',
    required = False,
    default = False)

parser.add_argument(
    '--pollEn',
    action = 'store_true',
    required = False,
    default = False)


if __name__ == "__main__":
    args = parser.parse_args()
    

    with KpixDaq.DesyTrackerRoot(pollEn=args.pollEn, ip=args.ip, debug=args.debug, zmqPort=args.port) as root:
        try:
            while True:
                time.sleep(1)
        except (KeyboardInterrupt):
            print('Exiting')
            
        
