//-----------------------------------------------------------------------------
// File          : cosmicRun.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/14/2011
// Project       : KPIX
//-----------------------------------------------------------------------------
// Description :
// Control the KPIX cosmic run
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/14/2011: created
//-----------------------------------------------------------------------------
#include <sys/stat.h>
#include <sys/types.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include <KpixBunchTrain.h>
#include <KpixRunWrite.h>
#include <KpixRunRead.h>
#include <KpixConfigXml.h>
#include <KpixCalibRead.h>
#include <SidLink.h>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <signal.h>
#include <stdio.h>
using namespace std;

#define CAL_FILE "/u1/w_si/samples/2011_03_18_17_35_29_calib_dist/calib_dist_fit.root"
#define VERSION  10
#define SERIAL   1001
#define BASE_DIR "/u1/w_si/samples"
#define DEFAULTS "cosmic_run.xml"

// Global variable to catch cntrl-c
bool gotCntrlC;

// Function to catch cntrl-c
void sigTerm (int) {
   gotCntrlC = true;
   cout << endl << "Caught Cntrl-C" << endl;
}


// Main Function
int main ( int argc, char **argv ) {
   SidLink        *sidLink;
   KpixFpga       *kpixFpga;
   KpixAsic       *kpixAsic[2];
   KpixBunchTrain *trainData;
   KpixRunWrite   *kpixRunWrite;
   KpixConfigXml  xmlConfig;
   KpixCalibRead  *calData;
   string         calString;
   bool           cmdPerr, dataPerr, tempEn;
   unsigned char  tempValue;
   unsigned int   x;
   unsigned int   errCnt;
   time_t         tm, lastTm;
   stringstream   outFile;
   unsigned int   triggers;
   unsigned int   cycles;
   char *         calFile;
   unsigned int   serial;
   unsigned int   clkPeriod;
   char *         baseDir;
   unsigned int   kpixVersion;
   string         defaultFile;

   // Get settings
   if ( argc != 3 ) {
      cout << "Usage: cosmicRun serial cal_file" << endl;
      return(1);
   }
   serial      = atoi(argv[1]);
   calFile     = argv[2];
   kpixVersion = atoi(getenv("KPIX_VERSION"));
   baseDir     = getenv("KPIX_BASE_DIR");
   clkPeriod   = atoi(getenv("KPIX_CLK_PER"));
   defaultFile = "cosmicRun.xml";

   // Dump settings
   cout << "Using the following settings:" << endl;
   cout << "    serial: " << dec << serial << endl;
   cout << "   calFile: " << calFile << endl;
   cout << "   version: " << dec << kpixVersion << endl;
   cout << "   dataDir: " << baseDir << endl;
   cout << "  defaults: " << defaultFile << endl;

   // Catch signals
   signal (SIGINT,&sigTerm);

   try {
      // Open calibration constants
      calData = new KpixCalibRead(calFile);
      calString = calData->kpixRunRead->getRunTime();
   } catch ( string error ) {
      cout << "Error opening calibration constants from " << CAL_FILE << endl;
      return(1);
   }

   // Cycle through runs
   errCnt    = 0;
   gotCntrlC = false;
   while ( ! gotCntrlC ) {

      // Stop if things are unrecoverable
      if ( errCnt > 10 ) {
         time(&tm);
         cout << "Could not recover error state. Giving up at " << ctime(&tm);
         break;
      }

      try {
         sidLink      = NULL;
         kpixFpga     = NULL;
         kpixAsic[0]  = NULL;
         kpixAsic[1]  = NULL;
         kpixRunWrite = NULL;
         trainData    = NULL;

         // Create simulation link
         sidLink = new SidLink();
         sidLink->linkOpen ( 0 );

         // Create FPGA object, set defaults
         kpixFpga = new KpixFpga(sidLink);
         kpixFpga->setDefaults(clkPeriod,(kpixVersion<10));

         // Create the KPIX Devices
         kpixAsic[0] = new KpixAsic(sidLink,kpixVersion,2,serial,false);
         kpixAsic[0]->setDefaults(50);
         kpixAsic[1] = new KpixAsic(sidLink,kpixVersion,3,0,true);
         kpixAsic[1]->setDefaults(50);

         // Make sure we can talk to the devices
         kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);
         kpixAsic[1]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);

         // Configure devices with xml defaults
         kpixAsic[0]->kpixDebug(true);
         xmlConfig.readConfig ((char *)defaultFile.c_str(),kpixFpga,kpixAsic,2,true);
         kpixAsic[0]->kpixDebug(false);

         // Generate file name
         outFile.str("");
         outFile << baseDir << "/" << KpixRunWrite::genTimestamp() << "_run";
         mkdir(outFile.str().c_str(),0755);
         outFile << "/run.root";

         // Create Run Write Class To Store Data & Settings
         kpixRunWrite = new KpixRunWrite (outFile.str(),"run","Cosmic Run",calString);
         kpixRunWrite->addFpga  ( kpixFpga );
         for (x=0; x<2; x++) kpixRunWrite->addAsic (kpixAsic[x]);

         // Copy calibration data
         calData->copyCalibData ( kpixRunWrite );

         time(&tm);
         cout << "Starting Run at " << ctime(&tm);
         cout << "Storing data at " << outFile.str() << endl;
         cout << "Hit cntrl-c to stop run and save data" << endl;

         // Keep running until cntrl-c
         time(&lastTm);
         cycles   = 0;
         triggers = 0;
         while ( !gotCntrlC ) {

            // Send start command
            kpixAsic[0]->cmdAcquire(true);

            // Get bunch train data
            trainData = new KpixBunchTrain ( sidLink, false);
            kpixRunWrite->addBunchTrain(trainData);

            if ( trainData->getSampleCount() > 0 ) triggers++;
            cycles++;

            delete trainData;
            trainData = NULL;

            time(&tm);
            if ( tm != lastTm ) {
               cout << "\r";
               cout << "Iterations=" << dec << setw(4) << setfill('0') << cycles;
               cout << ", Triggers="  << triggers; 
               cout << flush;
               lastTm = tm;
            }
         }

      } catch(string error) { 
         time(&tm);
         cout << endl << "Got Error at " << ctime(&tm);
         cout << error << endl;
         errCnt++;

         // Clean up
         if ( trainData != NULL ) delete trainData;
         if ( kpixRunWrite != NULL ) delete kpixRunWrite;
         if ( kpixAsic[0] != NULL ) delete kpixAsic[0];
         if ( kpixAsic[1] != NULL ) delete kpixAsic[1];
         if ( kpixFpga    != NULL ) delete kpixFpga;
         if ( sidLink     != NULL ) delete sidLink;
         sidLink      = NULL;
         kpixFpga     = NULL;
         kpixAsic[0]  = NULL;
         kpixAsic[1]  = NULL;
         kpixRunWrite = NULL;
         trainData    = NULL;
      }
   }

   cout << endl << "Run stopped at " << ctime(&tm);

   // Clean up
   if ( trainData    != NULL ) delete trainData;
   if ( kpixRunWrite != NULL ) delete kpixRunWrite;
   if ( kpixAsic[0]  != NULL ) delete kpixAsic[0];
   if ( kpixAsic[1]  != NULL ) delete kpixAsic[1];
   if ( kpixFpga     != NULL ) delete kpixFpga;
   if ( sidLink      != NULL ) delete sidLink;
}

