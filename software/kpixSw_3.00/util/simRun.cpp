#include <SimLink.h>
#include <KpixControl.h>
#include <ControlServer.h>
#include <Device.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <signal.h>
using namespace std;

int main (int argc, char **argv) {
   string        defFile;
   uint          shmId;
   stringstream  cmd;

   if ( argc == 1 ) {
      cout << "Usage: simRun smem_id [default.xml]" << endl;
      return(1);
   }
   shmId = atoi(argv[1]);

   if ( argc > 2 ) defFile = argv[2];
   else defFile = "";

   try {

      SimLink     simLink; 
      KpixControl kpix(&simLink,defFile);

      simLink.setMaxRxTx(500000);
      simLink.setDebug(true);
      simLink.open(shmId);
      usleep(100);

      // Test FPGA Read
      cout << "Fgga Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("cntrlFpga",0)->readSingle("Version") << endl;

      // Hard Reset
      kpix.command("HardReset","");
      kpix.poll(NULL);

      // Set Defaults
      kpix.command("SetDefaults","");
      kpix.poll(NULL);

      // Open data file
      kpix.set("DataFile","sim_data.bin");
      kpix.command("OpenDataFile","");
      kpix.poll(NULL);

      // Send run command
      kpix.device("cntrlFpga",0)->command("KpixRun","");

      // Wait for data
      while(simLink.dataFileCount() == 0 ) {
         usleep(100);
         kpix.poll(NULL);
      }
        
      // Close data file 
      kpix.command("CloseDataFile","sim_data.bin");
      kpix.poll(NULL);

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
   }
}

