import rogue
import pyrogue
import pyrogue.gui
import KpixDaq
import PyQt4.QtGui
import logging
import sys


rogue.Logging.setFilter('pyrogue.SrpV3', rogue.Logging.Debug)

    
# Create Coulter Root
with KpixDaq.DesyTrackerRoot(mode="SIM") as root:

    root.DesyTracker.KpixDaqCore.SysConfig.KpixReset()
    root.DesyTracker.KpixDaqCore.AcquisitionControl.ExtAcquisitionSrc.setDisp('EthAcquire')
    root.DesyTracker.KpixDaqCore.AcquisitionControl.ExtAcquisitionEn.set(True)
    root.DesyTracker.KpixDaqCore.SysConfig.KpixEnable.set(0xffffffff)
    

    # Create GUI
    appTop = PyQt4.QtGui.QApplication(sys.argv)
    guiTop = pyrogue.gui.GuiTop(group='DesyTrackerGui')
    guiTop.addTree(root)
    guiTop.resize(1000,1000)

    # Run gui
    appTop.exec_()

    
    
