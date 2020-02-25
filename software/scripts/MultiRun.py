#!/usr/bin/env python

import sys
import os
import logging
import argparse
import datetime
import time

import pyrogue
import rogue

if '--local' in sys.argv:
    pyrogue.addLibraryPath('../../firmware/common/python')
    pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

rootParser = KpixDaq.DesyTrackerRootArgparser()
runParser = argparse.ArgumentParser()

runParser.add_argument(
    '--config', '-c',
    type = str,
    required = True,
    help = 'Configuration yaml file')

runParser.add_argument(
    '--outfile', '-o',
    type = str,
    required = False,
    default = os.path.abspath(datetime.datetime.now().strftime("data/")),
    help = 'Output file name')

runParser.add_argument(
    '--runcount', '-r',
    type = int,
    required = False,
    default = 2**31-1)

runParser.add_argument(
    '--time', '-t',
    type = int,
    required = False,
    default = 10)


if __name__ == "__main__":
    rootArgs, runArgs = rootParser.parse_known_args()
    runArgs = runParser.parse_known_args(runArgs)

    
    # with KpixDaq.DesyTrackerRoot(pollEn=False, ip=args.ip, debug=args.debug) as root:
    #     # Just reload the FPGA since its the most consistent way to get to a known start state
    #     print('Reloading FPGA')
    #     root.DesyTracker.AxiVersion.FpgaReload()
    #     #root.waitOnUpdate()
        
    # # Sleep for 5 seconds to allow FPGA to load
    # print('Sleeping')
    # time.sleep(2)
    # print('Done sleeping')

    with KpixDaq.DesyTrackerRoot(**vars(rootArgs)) as root:

        while True:
            print('Reading all')
            # Read everything
            root.ReadAll()
            root.waitOnUpdate()

            # Print the version info
            root.DesyTracker.AxiVersion.printStatus()

            outfile = os.path.abspath(datetime.datetime.now().strftime(f"{runArgs.outfile}/Run_%Y%m%d_%H%M%S.dat"))

            print(f'Opening data file: {outfile}')
            root.DataWriter.DataFile.setDisp(outfile)
            root.DataWriter.Open()

            print(f"Hard Reset")
            root.HardReset()

            print(f"Count Reset")        
            root.CountReset()

            print('Writing initial configuration')
            root.LoadConfig(runArgs.config)
            root.ReadAll()
            root.waitOnUpdate()

            root.DesyTrackerRunControl.MaxRunCount.set(runArgs.runcount)
            try:
                root.DesyTrackerRunControl.runState.setDisp('Running')

                pyrogue.VariableWait([root.DesyTrackerRunControl.runState],
                                     lambda val: val[0].valueDisp == 'Stopped',
                                     timeout=runArgs.time)

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
        
