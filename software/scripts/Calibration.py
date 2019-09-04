#!/usr/bin/env python

import sys
import os
import logging
import argparse
import datetime

import pyrogue
import rogue

pyrogue.addLibraryPath('../python')
pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

parser = argparse.ArgumentParser()


parser.add_argument(
    "--ip", 
    type     = str,
    required = False,
    default = '192.168.2.10',
    help     = "IP address",
)  

parser.add_argument(
    '--config', '-c',
    type = str,
    required = True,
    help = 'Configuration yaml file')

parser.add_argument(
    '--outfile', '-o',
    type = str,
    required = False,
    default = os.path.abspath(datetime.datetime.now().strftime("data/Calibration_%Y%m%d_%H%M%S.dat")),
    help = 'Output file name')


parser.add_argument(
    '--debug', '-d',
    type = bool,
    required = False,
    default = False)


if __name__ == "__main__":
    args = parser.parse_args()
    
    with KpixDaq.DesyTrackerRoot(pollEn=False, ip=args.ip, debug=args.debug) as root:
        # Just reload the FPGA since its the most consistent way to get to a known start state
        # print('Reloading FPGA')
        # root.DesyTracker.AxiVersion.FpgaReload()

        # # Sleep for 5 seconds to allow FPGA to load
        # time.sleep(5)
        # print('Done Reloading FPGA')

        root.ReadAll()
        root.waitOnUpdate()

        root.DesyTracker.AxiVersion.printStatus()

        if os.path.isdir(args.outfile):
            args.outfile = os.path.abspath(datetime.datetime.now().strftime(f"{args.outfile}/Calibration_%Y%m%d_%H%M%S.dat"))
            
        print(f'Opening data file: {args.outfile}')
        root.DataWriter.DataFile.setDisp(args.outfile)
        root.DataWriter.Open()

        print(f"Hard Reset")
        root.HardReset()
        
        print(f"Count Reset")        
        root.CountReset()
            
        print('Writing initial configuration')
        root.LoadConfig(args.config)
        root.ReadAll()
        root.waitOnUpdate()

        try:
            root.DesyTrackerRunControl.runState.setDisp('Calibration')
            root.DesyTrackerRunControl.waitStopped()
            root.DataWriter.Close()
        except (KeyboardInterrupt):
            root.DesyTrackerRunControl.runState.setDisp('Stopped')
            root.DataWriter.Close()            
            
        
