
# daqHardReset          
# daqSoftReset          
# daqRefreshState       
# daqSetDefaults        
# daqLoadSettings       file
# daqSaveSettings       file
# daqOpenData           file
# daqCloseData          
# daqSetRunParameters   rate count
# daqSetRunState        state
# daqGetRunState        
# daqResetCounters      
# daqSendCommand        command
# daqReadStatus         
# daqGetStatus          variable
# daqReadConfig         
# daqVerifyConfig       
# daqSetConfig          variable arg
# daqGetConfig          variable
# daqGetSystemStatus    
# daqGetUserStatus      
# daqGetError           
# daqSendXml            xml_string
# daqDisableTimeout

import pythonDaq
import time

pythonDaq.daqOpen("kpix",1);

oldCalLength = 9
oldCalString = [""] * oldCalLength;
oldCalIndex  = [""] * oldCalLength;

# Function to set a channel for calibrate, remebering old settings for restore purposes
def setChannel ( index, mode ) :

   base = (index / 32) * 32;
   top  = base + 31;

   conf = "Chan_%04d" % base + "_%04d" % top

   for i in range(0,oldCalLength):
      oldCalIndex[i] = "cntrlFpga(0):kpixAsic(%d):" % i + conf;
      oldCalString[i] = pythonDaq.daqGetConfig(oldCalIndex[i])

      group    = (index % 32) / 8
      offset   = (index % 32) % 8 
      position = (group * 8) + group + offset

      newCalString = oldCalString[i][:position] + mode + oldCalString[i][position+1:]
      print "Updating calibration: Idx=" + oldCalIndex[i] + " Old=" + oldCalString[i] + " New=" + newCalString
      pythonDaq.daqSetConfig(oldCalIndex[i],newCalString)

   pythonDaq.daqSetConfig("UserDataA",str(index))

# Restore configuration
def restoreConfig ( ) :
   for i in range(0,oldCalLength):
      pythonDaq.daqSetConfig(oldCalIndex[i],oldCalString[i]);

pythonDaq.daqSetDefaults();
pythonDaq.daqResetCounters();
pythonDaq.daqOpenData("");
#pythonDaq.daqSetRunParameters("5Hz",100);
pythonDaq.daqSetRunParameters("No Limit",100);

print "Writing to data file " +  pythonDaq.daqGetConfig("DataFile")

for i in range(0,1024):
   setChannel ( i, 'C' )

   print "Injecting on channel " + str(i) 

   pythonDaq.daqSetRunState("Running");

   while pythonDaq.daqGetRunState() == "Running":
      time.sleep(1);

   restoreConfig ()

pythonDaq.daqCloseData("");

