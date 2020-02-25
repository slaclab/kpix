#!/usr/bin/env python

import sys
import os
import logging
import argparse
import datetime
import time
import click

import pyrogue
import rogue

if '--local' in sys.argv:
    pyrogue.addLibraryPath('../../firmware/common/python')
    pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

parser = argparse.ArgumentParser()


parser.add_argument(
    "--host", 
    type     = str,
    required = False,
    default = 'localhost',
    help     = "ZMQ Server Host",
)

parser.add_argument(
    "--port",
    type=int,
    required=False,
    default=9099,
    help='ZMQ Server port')


parser.add_argument(
    '--config', '-c',
    type = str,
    required = True,
    help = 'Configuration yaml file')

parser.add_argument(
    '--outfile', '-o',
    type = str,
    required = False,
    default = os.path.abspath(datetime.datetime.now().strftime("data/Run_%Y%m%d_%H%M%S.dat")),
    help = 'Output file name')


parser.add_argument(
    '--runcount', '-r',
    type = int,
    required = False,
    default = 2**31-1)


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
    client = pyrogue.VirtualClient(addr=args.host, port=args.port)

    root = client.root
    
    print('Reading all')
    # Read everything
    root.ReadAll()

    # Print the version info
    print('GitHash', root.DesyTracker.AxiVersion.GitHashShort.get())

    if os.path.isdir(args.outfile):
        args.outfile = os.path.abspath(datetime.datetime.now().strftime(f"{args.outfile}/Run_%Y%m%d_%H%M%S.dat"))

    input(f'Data file will be {args.outfile}. \n Hit any key to start run.')

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

    root.DesyTrackerRunControl.MaxRunCount.set(args.runcount)

    try:
        root.DesyTrackerRunControl.runState.setDisp('Running')
        last = 0
        with click.progressbar(
                iterable=range(root.DesyTrackerRunControl.MaxRunCount.get()),
                show_pos=True,
                label=click.style('Running', fg='green')) as bar:

            while root.DesyTrackerRunControl.runState.getDisp() != 'Stopped':
                rc = root.DesyTrackerRunControl.runCount.get()
                bar.update(rc-last)
                last = rc

        
                #root.DesyTrackerRunControl.waitStopped()
    except (KeyboardInterrupt):
        root.DesyTrackerRunControl.runState.setDisp('Stopped')
        
    root.DataWriter.Close()            
        
