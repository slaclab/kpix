
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

pythonDaq.daqHardReset();
pythonDaq.daqSetDefaults();
pythonDaq.daqResetCounters();
pythonDaq.daqSetConfig("cntrlFpga:BncSourceA","SelCell");
pythonDaq.daqSetRunParameters("No Limit",100);
pythonDaq.daqRefreshState();
pythonDaq.daqSetRunState("Running");
while pythonDaq.daqGetRunState() == "Running":
   time.sleep(1);
   print("running");

print("stopped");

