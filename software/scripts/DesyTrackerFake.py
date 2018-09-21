import rogue
import pyrogue
import pyrogue.gui
import KpixDaq
import logging
import sys


rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

    
# Create Coulter Root
with KpixDaq.DesyTrackerRoot(mode="MEM_EMU") as root:
    # Create GUI
    appTop = pyrogue.gui.application(sys.argv)
    guiTop = pyrogue.gui.GuiTop(group='DesyTrackerGui')
    guiTop.addTree(root)
    guiTop.resize(1000,1000)

    # Run gui
    appTop.exec_()
