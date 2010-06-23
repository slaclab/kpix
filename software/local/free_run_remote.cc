//-----------------------------------------------------------------------------
// File          : free_run.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 05/07/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for example program to perform free running acquisition.
//-----------------------------------------------------------------------------
// Copyrigt ht (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 05/07/2007: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <signal.h>
#include <KpixRunRead.h>
#include <KpixRunWrite.h>
#include <KpixCalibRead.h>
#include <KpixSample.h>
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixCalDist.h>
#include <KpixAsic.h>
#include <SidLink.h>
#include <KpixBunchTrain.h>
#include <TString.h>

using namespace std;

// Serial device to use
//#define DEVICE "/dev/ttyUSB0"
#define DEVICE 0

// Prefix for run name / file name
#define TEST_PREFIX "free_run"

// Base dit rectory to store calibration data
#define SAMPLE_DIR "/home/silicon/samples"

// Version of KPIX under test
#define KPIX_VERSION 9

// Target Device Configuration, set serial to 0 for none
#define KPIXA_SERIAL 0
#define KPIXB_SERIAL 0
#define KPIXC_SERIAL 902

// Define DVDD Voltage
#define DVDD_VOLT 1.8


// Clock period for test in ns
#define CLOCK_PERIOD 50
//#define CLOCK_PERIOD 100

// Function and global variable to handle run interuption
bool stop;
void sigstop (int sig) { 
   stop = true;
   (void) signal(SIGINT, SIG_DFL);
   cout << "got signal " << sig << endl;
   cout <<  "\nRun will stop after next iteration\n";
}


// Main Function
int main ( int argc, char **argv ) {

   int               kpixCount, x,y;
   stringstream      testDir;
   stringstream      testFile;
   stringstream      testSource;
   stringstream      testDirCmd;
   string            testDesc;
   SidLink           *sidLink;
   KpixAsic          *kpixAsic[4];
   KpixFpga          *kpixFpga;
   KpixRunWrite      *kpixRunWrite;
   KpixBunchTrain    *kpixBunchTrain;
   unsigned int      modes[1024];
   long              curTime, prvTime, startTime;
   int               curCount, prvCount;
   int               trainCount=0;
   int               hours, mins, secs;


   // Append test description
   if ( argc != 7 ) {
      cout << "Wrong Number of Parameters\n";
      return(0);
   }
   testDesc = argv[1];

   // Generate directory name based on time
   //testDir    << SAMPLE_DIR << "/" << KpixRunWrite::genTimestamp() << "_" << TEST_PREFIX; //original
   testDir    << argv[2];  //specify directory in call will be created below
   testFile   << testDir.str() << "/" << TEST_PREFIX "_"<< KpixRunWrite::genTimestamp() << ".root";
   try {   		
   	testDirCmd << "mkdir " << testDir.str().c_str();
   	system(testDirCmd.str().c_str());
   }
   catch(string error){};
   
   cout << "Logging Data To: " << testFile.str() << "\n";
   
   // Save the source file to generated directory
   testSource << "cp " << TEST_PREFIX << ".cc " << testDir.str();
   system(testSource.str().c_str());
   cout << "Logging Source Code To:" << testDir.str() << "/" << TEST_PREFIX << ".cc\n";
   
   // Open serial link
   try {
      sidLink = new SidLink();
      sidLink->linkOpen(DEVICE);
      sidLink->linkDebug(false);
   } catch ( string error ) {
      cout << "Error opening serial link:\n";
      cout << error << "\n";
      cout << "Exiting!\n";
      return(1);
   }

   // Create FPGA object, reset system, configure
   try {

      // Create object
      kpixFpga = new KpixFpga(sidLink);
      //kpixFpga = new KpixFpga();
      //kpixFpga->SetSidLink(sidLink);
      
      //important for kpix 8+  false for kpix 7 (default)
      kpixFpga->setDefaults(CLOCK_PERIOD,KPIX_VERSION > 7); 
      //cout<< "DMS  Set Kpix fpga to version: " << KPIX_VERSION <<endl;
     
      kpixFpga->fpgaDebug(false);
      //sidLink->linkDebug(true);

      // Flush the link
      sidLink->linkFlush();

      // Read version as a test
      kpixFpga->getVersion();
      
     // Debug Outputs
      kpixFpga->setBncSourceA(0x07); // threshOff
      kpixFpga->setBncSourceB(0x08); // TrigInh     

   } catch ( string error ) {
      cout << "Error creating/configuring FPGA object:\n";
      cout << error << "\n";
      cout << "Exiting!\n";
      return(2);
   }
 
   // Create the KPIX classes
   try {
      kpixCount = 0;
      if ( KPIXA_SERIAL != 0 ) { 
         kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,0,KPIXA_SERIAL,0);
         kpixCount++;
      }
      if ( KPIXB_SERIAL != 0 ) { 
         kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,1,KPIXB_SERIAL,0);
         kpixCount++;
      }
      if ( KPIXC_SERIAL != 0 ) { 
         kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,2,KPIXC_SERIAL,0);
         kpixCount++;
      }
      
      kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,3,0,true); // Dummy KPIX
      kpixCount++;
    } 
    catch ( string error ) {
      	cout << "Error creating Kpix Objects:\n";
      	cout << error << "\n";
      	cout << "Exiting!\n";
      	return(1);
    }
      
      for (x=0; x < kpixCount; x++) try {

      // Send reset command    
      kpixAsic[x]->cmdReset();

      kpixAsic[x]->setDefaults(CLOCK_PERIOD);


      // Attempt to read configuration register as test
      //

      // Configure KPIX Object
      kpixAsic[x]->setCntrlTrigSrcCore  ( true  );

      // Set Threshold DACs, Unused
      kpixAsic[x]->setDacThreshRangeA ( (unsigned char)0xED, // Range A Reset Inhibit Threshold
                                        (unsigned char)0xED  // Range A Trigger Threshold
                                      );
      kpixAsic[x]->setDacThreshRangeB ( (unsigned char)0xFB, // Range B Reset Inhibit Threshold
                                        (unsigned char)0xFB  // Range B Trigger Threshold
                                      );

      //all other to B
      for (y=0; y<1024; y++) modes[y] = 1;//should be DISABLE Unsure of analog in new sidApi.  Using menu index in ../gui/KpixGuiTrig.cc
      modes[7] = 2;  //should be TH_A unsure of analog in new sidApi.  Using menu index in ../gui/KpixGuiTrig.cc  see below quote for options
      
/*    mode[x*1024+y]->insertItem("Thresh B",0);
      mode[x*1024+y]->insertItem("Disable",1);
      mode[x*1024+y]->insertItem("Thresh A",2);
      mode[x*1024+y]->insertItem("Calib",3);*/

      kpixAsic[x]->setChannelModeArray ( modes );

      //for (y=0; y<1024; y++) ranges[y] = false;
      // set noisy channels to threshold A
      //ranges[21]  = true;
      //ranges[23]  = true;
      //ranges[26]  = true;
      //ranges[51]  = true;
      //ranges[53]  = true;
      //ranges[60]  = true;

      //for (y=0; y<1; y++) ranges[y] = true;

      //kpixAsic[x]->setThreshRangeArray ( ranges );

     }//end try
   catch ( string error ) {
      cout << "Error configuring Kpix " << x << " Object:\n";
      cout << error << "\n";
      cout << "Exiting!\n";
      return(1);
   }

   // Create / Setup run write object
   try {

      // Create Run Object To Store Data
      kpixRunWrite = new KpixRunWrite (testFile.str(),TEST_PREFIX,testDesc);
      for (x=0; x<kpixCount; x++) kpixRunWrite->addAsic ( kpixAsic[x] );
      kpixRunWrite->addFpga ( kpixFpga );

      // Run variables
      kpixRunWrite->addRunVar   ( "Dvdd_Voltage", "Dvdd Voltage Setting", DVDD_VOLT );
      kpixRunWrite->addRunVar   ( "Avdd_Voltage", "Avdd Voltage Setting", 2.5 );
      
      
      float TSBias;
      float LaserPwr;
      float LaserPw;
      sscanf(argv[3],"%e",&TSBias);
      sscanf(argv[4],"%e",&LaserPwr);
      sscanf(argv[5],"%e",&LaserPw);
    

      //Event variables
      kpixRunWrite->addEventVar ( "TSBias", "Top Side Bias Voltage (V)",TSBias );
      kpixRunWrite->addEventVar ( "LaserPwr", "Laser Power (mw)",LaserPwr );
      kpixRunWrite->addEventVar ( "LaserPW", "Laser Pulse Width",LaserPw );

	      

   } catch ( string error ) {
      cout << "Error setting up run:\n";
      cout << error << "\n";
      cout << "Exiting!\n";
      return(1);
   }
   
   // Set control-c handler to stop runs gracefully
   (void) signal(SIGINT, sigstop);

      // Setup variables
   time(&curTime); 
   prvTime = curTime;
   startTime = curTime;
   curCount = 0;
   prvCount = 0;
   int numberOfBunchTrains;
   sscanf(argv[6], "%d",&numberOfBunchTrains);

   // Run until cntrl-c
   for (int i=0; i < numberOfBunchTrains;i++){

      // Try to get data, keep going if there is an error
      try {

         // Run Acquisition
 	cout << "DMS about to cmdAcquire" << endl;
         kpixAsic[0]->cmdAcquire(true);
       cout << "DMS  done with cmdAquire" << endl;

         // Get bunch train data
         kpixBunchTrain = new KpixBunchTrain ( sidLink, false ); //second arg is debug
         cout << "DMS done with bunchTrain data" << endl; 

         // Calculate counts
         trainCount++;
         curCount += kpixBunchTrain->getSampleCount();
         cout << "DMS curCount" << curCount << endl;

         // Store data
         kpixRunWrite->addBunchTrain(kpixBunchTrain);

         // Report progress
         time(&curTime);
         if ( (curTime - prvTime) >= 1 ) {
            hours = (curTime-prvTime)/3600;
            mins  = ((curTime-hours*3600)-startTime)/60;
            secs  = ((curTime-hours*3600-mins*60)-startTime);
            cout << "\r";
            cout << "Sample Count=" << dec << setw(7) << setfill('0') << curCount;
            cout << ", Delta=" << dec << setw(4) << setfill('0') << (curCount-prvCount);
            cout << ", Last=" << dec << setw(4) << setfill('0') << kpixBunchTrain->getSampleCount();
            cout << ", Par=" << dec << setw(4) << setfill('0') << kpixBunchTrain->getParErrors();
            cout << ", Live="  << ((trainCount*0.000655) * 100) << "% (" << trainCount << ")";
            cout << ", Hours=" << hours;
            cout << ", Mins=" << mins;
            cout << ", Secs=" << secs;
            cout << "               " << flush;
            prvTime = curTime;
            prvCount = curCount;
            trainCount = 0;
         }
         delete kpixBunchTrain;
	 } catch ( string error ) {
	    cout << "\nError Occured: " << error << "\n";
	 }
   }
   cout << "\n";

   // Close run
   try { 
//      kpixRunWrite->close(); 
   } catch ( string error ) {
      cout << "Error closing run file:\n";
      cout << error << "\n";
      return(1);
   }

   // Log
   cout << "Wrote Data To: " << testDir.str() << "\n";
}

