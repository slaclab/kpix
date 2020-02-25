import rogue
import pyrogue.gui
import sys
import argparse

if '--local' in sys.argv:
    pyrogue.addLibraryPath('../../firmware/common/python/')
    pyrogue.addLibraryPath('../../firmware/submodules/surf/python')

import KpixDaq

#rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)
# Set the argument parser
parser = KpixDaq.DesyTrackerRootArgparser()

args = parser.parse_known_args()
print(args)

with KpixDaq.DesyTrackerRoot(**vars(args[0])) as root:

    # Create GUI
    appTop = pyrogue.gui.application(sys.argv)
    guiTop = pyrogue.gui.GuiTop()
    guiTop.addTree(root)
    guiTop.resize(1000,1000)

    # Run gui
    appTop.exec_()
