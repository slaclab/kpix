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
    default = os.path.abspath(datetime.datetime.now().strftime("data/")),
    help = 'Output file name')


parser.add_argument(
    '--debug', '-d',
    action = 'store_true',
    required = False,
    default = False)

parser.add_argument(
    '--runcount', '-r',
    type = int,
    required = False,
    default = 2**31-1)

parser.add_argument(
    '--time', '-t',
    type = int,
    required = False,
    default = 10)



if __name__ == "__main__":
    args = parser.parse_args()
    
    # with KpixDaq.DesyTrackerRoot(pollEn=False, ip=args.ip, debug=args.debug) as root:
    #     # Just reload the FPGA since its the most consistent way to get to a known start state
    #     print('Reloading FPGA')
    #     root.DesyTracker.AxiVersion.FpgaReload()
    #     #root.waitOnUpdate()
        
    # # Sleep for 5 seconds to allow FPGA to load
    # print('Sleeping')
    # time.sleep(2)
    # print('Done sleeping')

    with KpixDaq.DesyTrackerRoot(pollEn=False, ip=args.ip, debug=args.debug) as root:

        while True:
            print('Reading all')
            # Read everything
            root.ReadAll()
            root.waitOnUpdate()

            # Print the version info
            root.DesyTracker.AxiVersion.printStatus()

            outfile = os.path.abspath(datetime.datetime.now().strftime(f"{args.outfile}/Run_%Y%m%d_%H%M%S.dat"))

            print(f'Opening data file: {outfile}')
            root.DataWriter.DataFile.setDisp(outfile)
            root.DataWriter.Open()

            print(f"Hard Reset")
            root.HardReset()

            print(f"Count Reset")        
            root.CountReset()

            print('Writing initial configuration')
            root.LoadConfig(args.config)
            root.ReadAll()
            root.waitOnUpdate()

            root.DesyTrackerRunControl.MaxRunCount.set(args.runcount)
            try:
                root.DesyTrackerRunControl.runState.setDisp('Running')

                pyrogue.VariableWait([root.DesyTrackerRunControl.runState],
                                     lambda val: val[0].valueDisp == 'Stopped',
                                     timeout=args.time)

                root.DesyTrackerRunControl.runState.setDisp('Stopped')
                root.DataWriter.Close()
                print(f'Ending run')                
                #root.DesyTrackerRunControl.waitStopped()
            except (KeyboardInterrupt):
                print('Caught interrupt')
                root.DesyTrackerRunControl.runState.setDisp('Stopped')
                root.DataWriter.Close()
                print(f'Ending run')
                
            print(f'Ended')
        
