//NOT WORKING YET, BACKUP ONLY

//-----------------------------------------------------------------------------
// File          : seq_ch_inject.cc
// Author        : Paul Csonka, based off code by Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 06/28/2010
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for example program to perform free running acquisition.
//-----------------------------------------------------------------------------
// Copyrigt ht (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// June 28 2010.  Code for Dieter's sequential calibration channel scans.
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

// Base directory to store calibration data
#define SAMPLE_DIR "/home/silicon/samples"

// Version of KPIX under test
#define KPIX_VERSION 9

// Target Device Configuration, set serial to 0 for none
#define KPIXA_SERIAL 900
#define KPIXB_SERIAL 0
#define KPIXC_SERIAL 0

// Define DVDD Voltage
#define DVDD_VOLT 1.8


//Trigger modes
#define FORCE_TRIGGER 1
#define THRESH_A_ONLY 2
#define THRESH_A_CALIB 3
		
// Clock period for test in ns
#define CLOCK_PERIOD 50
//#define CLOCK_PERIOD 100


// Maximum train length in clock cycles
#define TRAIN_MAX_LENGTH 2880

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
   
   int numIntervals = 4, interval[4];

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
   
   
//==================================  INIT ====================================

	cout << "\nEntering Sequential Channel Run, ASIC Serial Number " << KPIXA_SERIAL << " [ June 24 2010 ]\n";

	// Append test description
	if ( argc != 3 ) {
	cout << "Wrong Number of Parameters\n";
	return(0);
	}
	testDesc = "test";

	// ----> interactive (potentially menu system instead of command line switches
/*	cout << "Enter number of desired Forced Trains" << endl;
	string input = "";
 	getline(cin, input);
	stringstream convertedStream(input);
	cout << "You asked for " <<  convertedStream << " Forced Trains" <<endl;
*/


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
                                       runRead->getAsic(0)->getSerial(), 0,0); 
      	cout << "Mode=" << x;
     	 	cout << ", Gain=" << gain;
      	cout << ", Intercept=" << icept;
      	cout << ", Status=" << status << endl;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

		
   	//~~~~~~~~~~~~~~~~~~~~~~~  LOGGING  ~~~~~~~~~~~~~~~~~~~~~~~~
   	// make a directory name based on time
	testDir    << "/u/re/pjcsonka/kpix/local/custom_" << KpixRunWrite::genTimestamp();  
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



			//!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	/* dieter's email:
	>  I want to test if we can see data in self-triggered mode above noise
	> background. To start with easy parameters, set all thresholds to our
	> best bet of 2 fC in normal gain. Then run a few thousand data cycles
	> (less in the beginning) and throw a calibration pulse of ~4 fC into one
	> of the pixels on every cycle, cycling through all pixels  I want to
	> find out if we see all calibration pulses and how many noise pulses and
	> their amplitudes.*/

	// procedure:
	/*- No force trigger on any channels for any of this test
	- Set all channels to trigger on 2 fC with trigger only (i.e. no calibration data), and Double Gain.
	- 1/4 shaper pulse
	- With no calibration injections, just collect say 1000 samples to get the background.  Thus, each channelwill have an unknown number of buckets triggered per train.
	- Then, loop through all the channels.  On each loop, inject 4 fC into a single channel (maybe more than once per train, and at specific intervals, depending on the charge injection you're looking for as asked above), then change the channel we're injecting into for the next loop.
	- cycle through all the channels several times.	*/
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			//!!!!!!!!!!!!!!!!!!!!!!!!

      

	//~~~~~~~~~~~~~~~  CONFIG ASIC DEFAULTS  ~~~~~~~~~~~~~~~~~~
	for (x=0; x < kpixCount; x++)	try {

		// ----> Send reset command    
		kpixAsic[x]->cmdReset();
		kpixAsic[x]->setDefaults(CLOCK_PERIOD);


		// ----> Configure KPIX Object
		const bool CORE = true, External = false;	


		// ----> disable DC reset:
		const bool DCResetDesired = true;
		const bool noDCReset = false;
/*
		kpixAsic[x]->setCntrlEnDcRst ( noDCReset, true ); 	// ( flag, actual HW write flag )

		// ----> set to double gain
		kpixAsic[ x ]->setCntrlDoubleGain( true, true );
		
		// ----> set calib charge injection
		kpixAsic[ x ]->setDacCalib ( 0xFB, true );		//4 fC = 251 = 0xFB, based on the GUI values

		// ----> set shaper to 1/4
		kpixAsic[ x ]->setCntrlDiffTime( 3, true );		//mode 3 = 1/4 shaper diff time
		
		kpixAsic[ x ]->setDacThreshRangeA ( 0xF6, 0xF6 );	//0xF6 is 2.455V, which is 2.5V - 2x22mV .  It's 22mV / fC, and dieter wants 2 fC.  Write enable ('true') is set by default
		
		// ----> set force trigger source  (not used, though)
		kpixAsic[ x ]->setCntrlTrigSrcCore  ( CORE );	//IF the thresholds are set to disabled, then this selects the source of the force trigger (internal core, or external connections)
*/

		// ----> set charge injection intervals
		numIntervals = 4;
   		interval[0] = 650; interval[1] = 650; interval[2] = 650; interval[3] = 650;

		int totalIntervalTime = 0;
		for( int intervalNum = 0; intervalNum < numIntervals; intervalNum++ ){
			totalIntervalTime += interval[ intervalNum ];}
	
		if ( totalIntervalTime >= TRAIN_MAX_LENGTH ){
			cout << "Error in Free_Run_Remote: total interval times exceed Train length\n";
			return( 1 );}		//return an error

		kpixAsic[x]->setCalibTime ( numIntervals, interval[0], interval[1], interval[2], interval[3], true);



		//~~~~~~~~~~~~~~~~  MODES / THRESHOLDS  ~~~~~~~~~~~~~~~~


		// ----> set all channels to 'threshold A only' mode
		//
		for (y=0; y<1024; y++){
			modes[y] = THRESH_A_ONLY; }   //2 = threshold A only (no calib)

		//modes[0] = DEFAULT_CHANNEL_MODE;  //all kpix devices have threshold A only.

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



		//verify that it was correctly written:
		//NOTE: it seems 'getCntrlEnDcRst' is not functional
		/*if ( kpixAsic[x]->getCntrlEnDcRst ( true ) != true ){
		 cout << "Error in writing DC offset" << "\n";
		 }*/
		cout << "Done configuring an ASIC\n";

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
		kpixRunWrite->addRunVar   ( "numInts", "Number of Injection Intervals", numIntervals );
		kpixRunWrite->addRunVar   ( "int0", "Interval 0(of 4)", interval[0] );
		kpixRunWrite->addRunVar   ( "int1", "Interval 1(of 4)", interval[1] );
		kpixRunWrite->addRunVar   ( "int2", "Interval 2(of 4)", interval[2] );
		kpixRunWrite->addRunVar   ( "int3", "Interval 3(of 4)", interval[3] );
		
		// ----> add event variables
		//sscanf(argv[3],"%e",&TSBias);
		kpixRunWrite->addEventVar ( "Mode for Cal Only", "Trigger Mode for Calib Channel ", THRESH_A_CALIB );
		kpixRunWrite->addEventVar ( "Mode for All Other", "Trigger Mode for All Other Channels", THRESH_A_ONLY );
		cout << "Done configuring write object\n";

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
	int numberOfBunchTrains;		//total trains desired.  numSamples <= 4(buckets)*N(channels)*numTrains
	int backgroundSamples;
	int desiredNumFullScanCycles;
	sscanf( argv[1], "%d", &backgroundSamples);
	sscanf( argv[2], "%d", &desiredNumFullScanCycles);		//the number of times to loop through injecting into all the channels


	//~~~~~~~~~~~~~~~~~~   BACKGROUND RUN  ~~~~~~~~~~~~~~~~~~~~~~~~~
	// Run until cntrl-c
	
	cout << "Beginning Background Run"  << endl;
	backgroundSamples = 5;
	for (int i = 0; i < backgroundSamples;i++){

	// Try to get data, keep going if there is an error
	try {

	// Acquire Data
	//cout << "DMS about to cmdAcquire" << endl;
	kpixAsic[ 0 ]->cmdAcquire(true);
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
   	
	cout << "Reconfiguring Run Parameters for Cycling Through Pixels"  << endl;
		
	for (int x = 0; x < kpixCount; x++){
   		//modes[x*1024] = 3;		//in all the active ASICs, set channel 0 to mode N
      	
	
		/*
		// ----> set charge injection interval times:
		interval[0] = 650; interval[1] = 650; interval[2] = 650; interval[3] = 650;

		int totalIntervalTime = 0;
		for( int intervalNum = 0; intervalNum < numIntervals; intervalNum++ ){
			totalIntervalTime += interval[ intervalNum ];}
	
		if ( totalIntervalTime >= TRAIN_MAX_LENGTH ){
			cout << "Error in Free_Run_Remote: total interval times exceed Train length\n";
			return( 1 );}		//return an error
			
		kpixAsic[ x ]->setCalibTime ( numIntervals, interval[0], interval[1], interval[2], interval[3], true);
		*/
		
		// ----> add event variables
		//kpixRunWrite->addEventVar ( "Mode", "Trigger Mode for Channel 0", 1 );
		
		
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

	
	//~~~~~~~~~~~  Calib through the channels  ~~~~~~~~~~~~~~~~
      // Get data.  Keep going if there is an error

	cout << "Beginning Channel Scans"  << endl;
	
	const int numChannels = 10;		//512
	desiredNumFullScanCycles = 1;
	
	for (int numFullScanCycles = 0; numFullScanCycles < desiredNumFullScanCycles; numFullScanCycles++ ){
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//----> Reset modes for the start of the next full scan cycle
		//at the start of each scan, reset all thresholds to trigger A only.
		for (int x = 0; x < kpixCount; x++){
			for (y=0; y<1024; y++){
				modes[y] = THRESH_A_ONLY; }   //2 = threshold A only (no calib)
			kpixAsic[x]->setChannelModeArray ( modes );
		}
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//		
		
		for (int whichChannel = 0; whichChannel < numChannels; whichChannel++){

			// For each channel, inject a calibration pulse for all four buckets.
			// set the current channel's mode to 3 (thres A and calibration inject)
			modes[ whichChannel ] = THRESH_A_CALIB;
			if (whichChannel > 1 ){
				//if we've passed the first channel, then set the previous channel (that we just were on) back to it's default mode of threhold only.
				modes[ whichChannel - 1 ] = THRESH_A_ONLY;
			}
			//now write those modes to all asics
			for (int x = 0; x < kpixCount; x++){
				kpixAsic[ x ]->setChannelModeArray ( modes );
			}

			try {


				      	// Run Acquisition
			//cout << "DMS about to cmdAcquire" << endl;
			kpixAsic[0]->cmdAcquire(true);
			//cout << "DMS done with cmdAquire" << endl;

			// Get bunch train data
			kpixBunchTrain = new KpixBunchTrain ( sidLink, false ); //second arg is debug
			//cout << "DMS done with bunchTrain data" << endl; 

			// Calculate counts
			trainCount++;
			curCount += kpixBunchTrain->getSampleCount();
			//cout << "DMS curCount" << curCount << endl;

			// Store data
			kpixRunWrite->addBunchTrain(kpixBunchTrain);

			// Report progress
			time(&curTime);
			if ( (curTime - prvTime) >= 1 ) {
				hours = (curTime-prvTime)/3600;
				mins  = ((curTime-hours*3600)-startTime)/60;
				secs  = ((curTime-hours*3600-mins*60)-startTime);
				cout << "\r";
				cout << "CYCLE # " << numFullScanCycles;
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
			
			
		}//end for numChannels
	}//end for numFullScanCycles
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

		
	//~~~~~~~~~~~~~~~~~~~~ CLOSE RUN ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// ----> Close run
	try { 
	      delete kpixRunWrite;
	} catch ( string error ) {
		cout << "Error closing run file:\n";
		cout << error << "\n";
		return(1);
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
	// ----> Output Log
	cout << "Wrote Data To: " << testDir.str() << "\n";
}

