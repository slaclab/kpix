import sys
import os.path
import time
import pyrogue
import rogue.utilities
import rogue.utilities.fileio

pyrogue.addLibraryPath('../python/')
pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

rogue.Logging.setFilter('LegacyStreamReader', rogue.Logging.Debug)

reader = rogue.utilities.fileio.LegacyStreamReader()
parser = KpixDaq.KpixStreamInfo() #KpixCalibration()

pyrogue.streamConnect(reader, parser)

def main(args):
    reader.open(args[1])
    print('opened', args[1])
    reader.closeWait()
    print('closed', args[1])
    #parser.process()
    #parser.noise()

if __name__ == "__main__":
    main(sys.argv)
