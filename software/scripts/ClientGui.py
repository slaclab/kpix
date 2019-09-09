import rogue
import pyrogue
import pyrogue.gui
import sys
import argparse

pyrogue.addLibraryPath('../python/')
pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)
# Set the argument parser
parser = argparse.ArgumentParser()

parser.add_argument(
    "--host", 
    type     = str,
    required = False,
    default = 'localhost',
    help     = "ZMQ Server host (or ip address)",
)  

parser.add_argument(
    "--port", 
    type     = int,
    required = False,
    default = 9099,
    help     = "ZMQ Server port",
)  


args = parser.parse_args()
print(args)

client = pyrogue.VirtualClient(addr=args.host, port=args.port)
root = client.root


# Create GUI
appTop = pyrogue.gui.application(sys.argv)
guiTop = pyrogue.gui.GuiTop()
guiTop.addTree(root)
guiTop.resize(1000,1000)

# Run gui
appTop.exec_()

