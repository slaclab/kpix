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
#define KPIXA_SERIAL 900
#define KPIXB_SERIAL 0
#define KPIXC_SERIAL 0

// Define DVDD Voltage
#define DVDD_VOLT 1.8


// Clock period for test in ns
#define CLOCK_PERIOD 50
//#define CLOCK_PERIOD 100


// Maximum train length in clock cycles
#define TRAIN_LENGTH 2880

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

   //~~~~~~~~~~~~~~~~~~~  VARIABLES  ~~~~~~~~~~~~~~~~~~~~~~~~~~
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


   double          gain,icept;
   bool            status;
   stringstream      calibDir;
   stringstream      calibFile;
   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
   
   
//==================================  INIT ====================================

	cout << "\nEntering Free Run, ASIC Serial Number " << KPIXA_SERIAL << " [ June 24 2010 ]\n";

	// Append test description
	if ( argc != 3 ) {
	cout << "Wrong Number of Parameters\n";
	return(0);
	}
	testDesc = "test";


//==========================  CONNECT / SET CAPTURE FILES =======================

	//~~~~~~~~~~~~~~~~~~~~~  calibration  ~~~~~~~~~~~~~~~~~~~~
	
	cout << endl << "Reading Calibration Data" << endl;

	//for now just hard code in a known root file that contains a calibration.
	calibDir << "/kpix/local/";
	calibFile << "calib_dist_fit.root";
	//kpix/local/calib_dist_fit.root
	
	//open root file that has the desired calib data
	KpixRunRead     *runRead;
	runRead  = new KpixRunRead("/u/re/pjcsonka/kpix/local/calib_dist_fit.root",false);
	 
	//read calibration file
   	KpixCalibRead   *calibRead;
   	calibRead = new KpixCalibRead(runRead);
	
	
	//check that it was read correctly by checking a channel
	// Asic(0), Channel=0, bucket=0
   	for (x=0; x<3; x++) { // 0=Normal Gain, 1=Double Gain, 2=Low Gain
	      status = calibRead->getCalibData(&gain,&icept,"Force_Trig",x,
                                       runRead->getAsic(0)->getSerial(),
                                       0,0); 
      	cout << "Mode=" << x;
     	 	cout << ", Gain=" << gain;
      	cout << ", Intercept=" << icept;
      	cout << ", Status=" << status << endl;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

		
   	//~~~~~~~~~~~~~~~~~~~~~~~  LOGGING  ~~~~~~~~~~~~~~~~~~~~~~~~
   	// make a directory name based on time
	testDir    << "/u/re/pjcsonka/kpix/local/pulsed_" << KpixRunWrite::genTimestamp();  
	//name of the file
	testFile   << testDir.str() << "/" << TEST_PREFIX "_"<< KpixRunWrite::genTimestamp() << ".root";
	try {   		
		testDirCmd << "mkdir " << testDir.str().c_str();
		system(testDirCmd.str().c_str());
	} catch(string error){};

	cout << "Logging Data To: " << testFile.str() << "\n";



	// Save the source file to generated directory
	/*testSource << "cp " << TEST_PREFIX << ".cc " << testDir.str();
	system(testSource.str().c_str());
	cout << "Logging Source Code To:" << testDir.str() << "/" << TEST_PREFIX << ".cc\n"; 
	*/
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
	
	
	//~~~~~~~~~~~~~~~~~~~  SERIAL CONNECTION  ~~~~~~~~~~~~~~~~~~~
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
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/


//======================  SET UP FPGA, KPIX CLASSES, AND ASIC TREES ===================


   // ~~~~~~~~~~~~~ Create FPGA object, reset/configure ~~~~~~~~~~~~~~~
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
      	cout << "Created FPGA object\n";

   	} catch ( string error ) {
      	cout << "Error creating/configuring FPGA object:\n";
      	cout << error << "\n";
      	cout << "Exiting!\n";
      	return(2);
   	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
 
 
	//~~~~~~~~~~~~~~~~   Create the KPIX classes   ~~~~~~~~~~~~~~~
	try {
      	kpixCount = 0;
      	if ( KPIXA_SERIAL != 0 ) { 
      	   kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,0,KPIXA_SERIAL,0);
      	   kpixCount++;
      	}
      	/*if ( KPIXB_SERIAL != 0 ) { 
      	   kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,1,KPIXB_SERIAL,0);
      	   kpixCount++;
      	}
      	if ( KPIXC_SERIAL != 0 ) { 
      	   kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,2,KPIXC_SERIAL,0);
      	   kpixCount++;
      	}*/

      	kpixAsic[kpixCount] = new KpixAsic(sidLink,KPIX_VERSION,3,0,true); // Dummy KPIX
      	kpixCount++;					
      	cout << "Created " << kpixCount-1 << " real KPIX Class(es)\n";

    } catch ( string error ) {
      	cout << "Error creating Kpix Objects:\n";
      	cout << error << "\n";
      	cout << "Exiting!\n";
      	return(1);
    }
    	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/



	// ----> MERGE CALIB FILE

	//~~~~~~~~~~~~  copy calibation into new root ~~~~~~~~~~~~~~
	
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	//kpixCalibRead->copyCalibData ( TFile *newFile, string directory, KpixAsic **asic, int asicCnt );
	
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/	


      

	//~~~~~~~~~~~~~~~  CONFIG ASIC DEFAULTS  ~~~~~~~~~~~~~~~~~~
	for (x=0; x < kpixCount; x++)	try {

		// ----> Send reset command    
		kpixAsic[x]->cmdReset();
		kpixAsic[x]->setDefaults(CLOCK_PERIOD);


		// ----> Configure KPIX Object
		const bool CORE = true, External = false;	

		// ----> set force trigger source
		kpixAsic[x]->setCntrlTrigSrcCore  ( CORE );	//select force trigger source

		// ----> set charge injection intervals
		int numIntervals = 4, interval[4];
		interval[0] = 650; interval[1] = 650; interval[2] = 650; interval[3] = 650;

		int totalIntervalTime = 0;
		for( int intervalNum = 0; intervalNum < numIntervals; intervalNum++ ){
			totalIntervalTime += interval[ intervalNum ];}
	
		if ( totalIntervalTime >= TRAIN_LENGTH ){
			cout << "Error in Free_Run_Remote: total interval times exceed Train length\n";
			return( 1 );		//return an error
			
		}
			
		kpixAsic[x]->setCalibTime ( numIntervals, interval[0], interval[1], interval[2], interval[3], true);



		//~~~~~~~~~~~~~~~~  MODES / THRESHOLDS  ~~~~~~~~~~~~~~~~

		// ----> Set Threshold DACs, Unused
		kpixAsic[x]->setDacThreshRangeA ( (unsigned char)0xED, // Range A Reset Inhibit Threshold
                              		    (unsigned char)0xED  // Range A Trigger Threshold
                              		  );
		kpixAsic[x]->setDacThreshRangeB ( (unsigned char)0xFB, // Range B Reset Inhibit Threshold
                              		    (unsigned char)0xFB  // Range B Trigger Threshold
                              		  );

		// ----> set all channels to disables threshold mode
		//all other to B
		for (y=0; y<1024; y++){
			modes[y] = 1; 
		}   //should be DISABLE Unsure of analog in new sidApi.  Using menu index in ../gui/KpixGuiTrig.cc

		modes[0] = 1;  //all kpix devices have channel 0 set to 1 (force trigger).

		/*    mode[x*1024+y]->insertItem("Thresh B",0);
		mode[x*1024+y]->insertItem("Disable",1);
		mode[x*1024+y]->insertItem("Thresh A",2);
		mode[x*1024+y]->insertItem("Calib",3);*/

		kpixAsic[x]->setChannelModeArray ( modes );

		//for (y=0; y<1024; y++) ranges[y] = false;
		// set noisy channels to threshold A
		//ranges[21]  = true;

		//for (y=0; y<1; y++) ranges[y] = true;

		//kpixAsic[x]->setThreshRangeArray ( ranges );


		// ----> enable/disable DC reset:
		const bool DCResetDesired = true;
		kpixAsic[x]->setCntrlEnDcRst ( DCResetDesired, true ); 	// ( flag, actual HW write flag )

		//verify that it was correctly written:
		//NOTE: it seems 'getCntrlEnDcRst' is not functional
		/*if ( kpixAsic[x]->getCntrlEnDcRst ( true ) != true ){
		 cout << "Error in writing DC offset" << "\n";
		 }*/


		// ----> Enable interval settings

	}	//end try
		catch ( string error ) {
		cout << "Error configuring Kpix " << x << " Object:\n";
		cout << error << "\n";
		cout << "Exiting!\n";
		return(1);
	}
   	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
   

	//~~~~~~~~~~~~~~~~   SET UP WRITE OBJECT  ~~~~~~~~~~~~~~~~~~
	// Create / Setup run write object
	try {

		// ----> Create Run Object To Store Data
		kpixRunWrite = new KpixRunWrite (testFile.str(), TEST_PREFIX, testDesc);

		// ----> add the asic trees
		for (x = 0; x < kpixCount; x++) { kpixRunWrite->addAsic ( kpixAsic[x] ); }

		// ----> add the fpga tree
		kpixRunWrite->addFpga ( kpixFpga );

		// ----> add run variables
		kpixRunWrite->addRunVar   ( "Dvdd_Voltage", "Dvdd Voltage Setting", DVDD_VOLT );


		// ----> add event variables
		//sscanf(argv[3],"%e",&TSBias);
		kpixRunWrite->addEventVar ( "Mode", "Trigger Mode for Channel 0", 1 );

	} catch ( string error ) {
		cout << "Error setting up run:\n";
		cout << error << "\n";
		cout << "Exiting!\n";
		return(1);
	}

	// Set control-c handler to stop runs gracefully
	(void) signal(SIGINT, sigstop);
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/


//==========================  RUN AND TAKE DATA  =============================
	// ----> Setup variables
	time(&curTime); 
	prvTime = curTime;
	startTime = curTime;
	curCount = 0;
	prvCount = 0;
	int numberOfBunchTrains;
	int forceTriggerSamples;
	int injectTriggerSamples;;
	sscanf( argv[1], "%d", &forceTriggerSamples);
	sscanf( argv[2], "%d", &injectTriggerSamples);


	//~~~~~~~~~~~~~~~~~~   FIRST SET   ~~~~~~~~~~~~~~~~~~~~~~~~~
	// Run until cntrl-c
	for (int i=0; i < forceTriggerSamples;i++){

	// Try to get data, keep going if there is an error
	try {

	// Run Acquisition
	cout << "DMS about to cmdAcquire" << endl;
	kpixAsic[0]->cmdAcquire(true);
	cout << "DMS done with cmdAquire" << endl;

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
	}//end if
	delete kpixBunchTrain;
	}//end try
	catch ( string error ) {
		cout << "\nError Occured: " << error << "\n";
	}
	}//end for
	cout << "\n";
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

   
   	//~~~~~~~~~~~~~~~~  reconfigure channels ~~~~~~~~~~~~~~~~~~~
     	//----> change modes and intervals
	
	for (int x=0; x < kpixCount; x++){
   		modes[x*1024] = 3;		//in all the active ASICs, set channel 0 to mode N
      	
		// ----> set channel modes:
		kpixAsic[x]->setChannelModeArray ( modes );
				//set charge injection intervals
		
		// ----> set interval times:
		int numIntervals = 4, interval[4];
		interval[0] = 650; interval[1] = 650; interval[2] = 650; interval[3] = 650;

		int totalIntervalTime = 0;
		for( int intervalNum = 0; intervalNum < numIntervals; intervalNum++ ){
			totalIntervalTime += interval[ intervalNum ];}
	
		if ( totalIntervalTime >= TRAIN_LENGTH ){
			cout << "Error in Free_Run_Remote: total interval times exceed Train length\n";
			return( 1 );		//return an error
			
		}
		kpixAsic[x]->setCalibTime ( numIntervals, interval[0], interval[1], interval[2], interval[3], true);
		
		
		// ----> add event variables
		kpixRunWrite->addEventVar ( "Mode", "Trigger Mode for Channel 0", 1 );
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

	
	//~~~~~~~~~~~~~~~~~~~   NEXT SET   ~~~~~~~~~~~~~~~~~~~~~~~~~
      // Try to get data, keep going if there is an error
	for (int i=0; i < injectTriggerSamples;i++){
    	// Try to get data, keep going if there is an error
      try {

	// Run Acquisition
	cout << "DMS about to cmdAcquire" << endl;
	kpixAsic[0]->cmdAcquire(true);
	cout << "DMS done with cmdAquire" << endl;

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
	}//end if
      delete kpixBunchTrain;
	}//end try
	catch ( string error ) {
		cout << "\nError Occured: " << error << "\n";
	}
	}//end for
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/


	//~~~~~~~~~~~~~~~~~~~~ CLOSE RUN ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Close run
	try { 
	      kpixRunWrite->close(); 
	} catch ( string error ) {
		cout << "Error closing run file:\n";
		cout << error << "\n";
		return(1);
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
	// Log
	cout << "Wrote Data To: " << testDir.str() << "\n";
}

