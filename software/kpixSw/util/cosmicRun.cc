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
#include <KpixSample.h>
#include <SidLink.h>
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

class HistData {
   public:
      uint last;
      uint count;
      uint channel;

      HistData (uint chan) {
         last    = 0;
         count   = 0;
         channel = chan;
      }

      bool add (uint value) {
         bool ret = false;
         if ( value == last ) count++;
         else {
            if ( count > 10 ) ret = true;
            last  = value;
            count = 0;
         }
         return(ret);
      }
};

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
   stringstream   outDir;
   stringstream   outFile;
   stringstream   cfgStart;
   stringstream   cfgStop;
   unsigned int   triggers;
   unsigned int   cycles;
   char *         calFile;
   unsigned int   serial;
   unsigned int   address;
   unsigned int   clkPeriod;
   char *         baseDir;
   unsigned int   kpixVersion;
   unsigned int   channel;
   unsigned int   value;
   KpixSample     *sample;
   string         defaultFile;
   HistData       *histData[1023];
   stringstream   error;

   // Get settings
   if ( argc != 4 ) {
      cout << "Usage: cosmicRun address serial cal_file" << endl;
      return(1);
   }
   address     = atoi(argv[1]);
   serial      = atoi(argv[2]);
   calFile     = argv[3];
   kpixVersion = atoi(getenv("KPIX_VERSION"));
   baseDir     = getenv("KPIX_BASE_DIR");
   clkPeriod   = atoi(getenv("KPIX_CLK_PER"));
   defaultFile = "cosmicRun.xml";

   // Create records
   for (channel=0; channel < 1024; channel++) histData[channel] = new HistData(channel);
 
   // Dump settings
   cout << "Using the following settings:" << endl;
   cout << "   address: " << dec << address << endl;
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
      try {
         sidLink      = NULL;
         kpixFpga     = NULL;
         kpixAsic[0]  = NULL;
         kpixAsic[1]  = NULL;
         kpixRunWrite = NULL;
         trainData    = NULL;
         outDir.str("");
         outFile.str("");
         cfgStart.str("");
         cfgStop.str("");

         // Create simulation link
         sidLink = new SidLink();
         sidLink->linkOpen ( 0 );

         // Create FPGA object, set defaults
         kpixFpga = new KpixFpga(sidLink);
         kpixFpga->setDefaults(clkPeriod,(kpixVersion<10));

         // Create the KPIX Devices
         kpixAsic[0] = new KpixAsic(sidLink,kpixVersion,address,serial,false);
         kpixAsic[0]->setDefaults(50);
         kpixAsic[1] = new KpixAsic(sidLink,kpixVersion,3,0,true);
         kpixAsic[1]->setDefaults(50);

         // Make sure we can talk to the devices
         kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);
         kpixAsic[1]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);

         // Configure devices with xml defaults
         xmlConfig.readConfig ((char *)defaultFile.c_str(),kpixFpga,kpixAsic,2,true);

         // Generate file name
         outDir << baseDir << "/" << KpixRunWrite::genTimestamp() << "_run";
         mkdir(outDir.str().c_str(),0755);
         outFile << outDir.str() << "/run.root";
         cfgStart << outDir.str() << "/run_start.xml";
         cfgStop << outDir.str() << "/run_stop.xml";

         // Create Run Write Class To Store Data & Settings
         kpixRunWrite = new KpixRunWrite (outFile.str(),"run","Cosmic Run",calString);
         kpixRunWrite->addFpga  ( kpixFpga );
         for (x=0; x<2; x++) kpixRunWrite->addAsic (kpixAsic[x]);

         // Copy calibration data
         calData->copyCalibData ( kpixRunWrite );

         // Dump config
         xmlConfig.writeConfig ((char *)cfgStart.str().c_str(), kpixFpga, kpixAsic, 2, true);

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

            // Check first 8 channels for duplicating data
            for (x=0; x < trainData->getSampleCount(); x++) {
               sample = trainData->getSampleList()[x];
               channel = sample->getKpixChannel();
               value   = sample->getSampleValue();
               if ( histData[channel]->add(value) ) {
                  error.str("");
                  error << "Detected fixed value in channel " << dec << channel;
                  throw(error.str());
               }
            }

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
            errCnt = 0;
         }
      } catch(string error) { 
         time(&tm);
         cout << endl << "Got Error at " << ctime(&tm);
         cout << error << endl;
         errCnt++;
         sleep(2);
      }
      cout << endl << "Run stopped at " << ctime(&tm);

      // Dump settings
      try {
         if ( kpixFpga != NULL && kpixAsic[0] != NULL && kpixAsic[1] != NULL && cfgStop.str() != "" ) 
            xmlConfig.writeConfig ((char *)cfgStop.str().c_str(), kpixFpga, kpixAsic, 2,true);
      } catch(string error) { 
         cout << "Error reading back settings" << endl;
         sleep(2);
      }

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

      // Stop if things are unrecoverable
      if ( errCnt > 10 ) {
         time(&tm);
         cout << "Could not recover error state. Giving up at " << ctime(&tm);
         gotCntrlC = true;
      }
      else sleep(5);
   }
}

