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
#include <KpixPwrBk.h>
#include <SidLink.h>
#include <SidLink.h>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <stdlib.h>
#include <signal.h>
#include <stdio.h>
using namespace std;

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

      void init () {
         last    = 0;
         count   = 0;
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
   unsigned int   minCnt;
   time_t         tm, lastTm;
   stringstream   outDir;
   stringstream   outFile;
   stringstream   cfgStart;
   stringstream   cfgStop;
   unsigned int   triggers;
   unsigned int   cycles;
   char *         calFile;
   char *         psFile;
   unsigned int   serial;
   unsigned int   address;
   unsigned int   clkPeriod;
   char *         baseDir;
   char *         deviceStr;
   unsigned int   port;
   int            deviceInt;
   unsigned int   kpixVersion;
   unsigned int   channel;
   unsigned int   attempt;
   unsigned int   value;
   KpixSample     *sample;
   string         defaultFile;
   HistData       *histData[1023];
   stringstream   error;
   KpixPwrBk      kpixPwr;
   unsigned int   maxAddr;

   // Get settings
   if ( argc < 3 ) {
      cout << "Usage: cosmicRun address serial [cal_file]" << endl;
      return(1);
   }
   address     = atoi(argv[1]);
   serial      = atoi(argv[2]);
   if ( argc == 4 ) calFile = argv[3];
   else calFile = NULL;
   kpixVersion = atoi(getenv("KPIX_VERSION"));
   baseDir     = getenv("KPIX_BASE_DIR");
   deviceStr   = getenv("KPIX_DEVICE");
   clkPeriod   = atoi(getenv("KPIX_CLK_PER"));
   maxAddr     = atoi(getenv("KPIX_MAX_ADDR"));
   defaultFile = "cosmicRun.xml";
   psFile      = getenv("KPIX_POWER");
   if ( getenv("KPIX_PORT") != NULL ) port = atoi(getenv("KPIX_PORT"));
   else port = 0;

   // Create records
   for (channel=0; channel < 1024; channel++) histData[channel] = new HistData(channel);
 
   // Dump settings
   cout << "Using the following settings:" << endl;
   cout << "    device: " << deviceStr << endl;
   cout << "      port: " << port << endl;
   cout << "   address: " << dec << address << endl;
   cout << "    serial: " << dec << serial << endl;
   cout << "   calFile: " << ((calFile==NULL)?"None":calFile) << endl;
   cout << "   version: " << dec << kpixVersion << endl;
   cout << "   dataDir: " << baseDir << endl;
   cout << "  defaults: " << defaultFile << endl;
   cout << "     Power: " << psFile << endl;

   outDir.str("");
   outFile.str("");
   cfgStart.str("");
   cfgStop.str("");

   // Determine Device
   if ( strstr(deviceStr,"/dev") != NULL ) deviceInt = -1;
   else deviceInt = atoi(deviceStr);

   // Catch signals
   signal (SIGINT,&sigTerm);

   if ( calFile != NULL ) {
      try {
         // Open calibration constants
         calData = new KpixCalibRead(calFile);
         calString = calData->kpixRunRead->getRunTime();
      } catch ( string error ) {
         cout << "Error opening calibration constants from " << calFile << endl;
         return(1);
      }
   }
   else {
      calString = "";
      calData   = NULL;
   }

   attempt   = 0;
   try {

      // Open power supply
      kpixPwr.open(psFile);
      kpixPwr.init();

      // Create link
      cout << "Setup Start" << endl;
      sidLink = new SidLink();
      //sidLink->linkDebug(true);

      // Create FPGA object
      kpixFpga = new KpixFpga(sidLink);

      // Create the KPIX Devices
      kpixAsic[0] = new KpixAsic(sidLink,kpixVersion,address,serial,false);
      kpixAsic[1] = new KpixAsic(sidLink,kpixVersion,maxAddr,0,true);

      // Set Defaults
      kpixAsic[0]->setDefaults(50,false);
      kpixAsic[1]->setDefaults(50,false);

      // Configure devices with xml defaults
      xmlConfig.readConfig ((char *)defaultFile.c_str(),kpixFpga,kpixAsic,2,false);

      // Generate file name
      outDir << baseDir << "/" << KpixRunWrite::genTimestamp() << "_run";
      mkdir(outDir.str().c_str(),0755);
      outFile << outDir.str() << "/run.root";

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite (outFile.str(),"run","Cosmic Run",calString);
      kpixRunWrite->addFpga  ( kpixFpga );
      for (x=0; x<2; x++) kpixRunWrite->addAsic (kpixAsic[x]);

      // Copy calibration data
      if ( calData != NULL ) calData->copyCalibData ( kpixRunWrite );
      cout << "Setup Done" << endl;

      time(&tm);
      cout << "Starting Run at " << ctime(&tm);
      cout << "Storing data at " << outFile.str() << endl;

   } catch ( string error ) {
      cout << "Error configuring kpix devices: " << error << endl;
      return(1);
   }

   // Cycle through runs
   cycles    = 0;
   errCnt    = 0;
   gotCntrlC = false;
   while ( ! gotCntrlC ) {
      try {
         trainData    = NULL;

         cfgStart.str("");
         cfgStop.str("");
         cfgStart << outDir.str() << "/run_start_" << dec << setw(3) << setfill('0') << attempt << ".xml";
         cfgStop << outDir.str() << "/run_stop_" << dec << setw(3) << setfill('0') << attempt << ".xml";

         cout << "Close Port" << endl;
         sidLink->linkClose();
         sleep(1);

         cout << "Power off" << endl;
         kpixPwr.setOutput(false);
         sleep(3);

         cout << "Power on" << endl;
         kpixPwr.setOutput(true);
         sleep(5);

         cout << "Open Port" << endl;
         if ( port != 0 ) sidLink->linkOpen(deviceStr,port);
         else if ( deviceInt == -1 ) sidLink->linkOpen(deviceStr);
         else sidLink->linkOpen(deviceInt);
         sleep(1);

         // Make sure we can talk to the devices
         minCnt = 0;
         while(1) {
            try {

               cout << "Setup FPGA" << endl;
               kpixFpga->setDefaults(clkPeriod,(kpixVersion<10));
               cout << "Done" << endl;
               sleep(1);
               cout << "FPGA Version=0x" << hex << kpixFpga->getVersion() << endl;

               cout << "Reading Kpix 0 Status" << endl;
               kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);
               cout << "Reading Kpix 1 Status" << endl;
               kpixAsic[1]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);
               cout << "Done" << endl;
               break;
            } catch (string error) {
               minCnt++;
               if ( minCnt > 4 ) throw(error);
               sleep(1);
            }
         }

         // Set Defaults
         cout << "Set defaults" << endl;
         kpixAsic[0]->setDefaults(50);
         kpixAsic[1]->setDefaults(50);
         cout << "Done" << endl;

         // Configure devices with xml defaults
         cout << "Set xml" << endl;
         xmlConfig.readConfig ((char *)defaultFile.c_str(),kpixFpga,kpixAsic,2,true);
         cout << "Done" << endl;

         // Dump config
         xmlConfig.writeConfig ((char *)cfgStart.str().c_str(), kpixFpga, kpixAsic, 2, true);

         // Init records
         for (channel=0; channel < 1024; channel++) histData[channel]->init();

         time(&tm);
         kpixFpga->setRunEnable(true);
         cout << "Starting Run at " << ctime(&tm);
         cout << "Hit cntrl-c to stop run and save data" << endl;

         // Keep running until cntrl-c
         time(&lastTm);
         cycles   = 0;
         triggers = 0;
         while ( !gotCntrlC ) {

            minCnt = 0;
            do {
               try {

                  // Send start command
                  //sidLink->linkDebug(true);
                  kpixAsic[0]->cmdAcquire(true);

                  // Get bunch train data
                  trainData = new KpixBunchTrain ( sidLink, false, 2, kpixAsic);
                  //trainData = new KpixBunchTrain ( sidLink, true, 2, kpixAsic);
                  kpixRunWrite->addBunchTrain(trainData);
                  minCnt = 0;
               } catch (string error) {
                  minCnt++;
                  //if ( minCnt > 4 ) throw(error);
                  throw(error);
                  cout << endl << "------------------------" << endl;
                  cout << "Got Minor Error: " << error << " -- retrying minCnt = " << dec << minCnt << " iteration = " << cycles << endl;
                  sleep(1);
                  sidLink->linkFlush();
                  sleep(1);
               }
            } while ( minCnt != 0 );

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
         cout << endl << "------------------------" << endl;
         cout << "Got Major Error. iteration="  << cycles << " at " << ctime(&tm);
         cout << error << endl;
         errCnt++;
         sleep(1);
         cout << "Flushing USB Device" << endl;
         sidLink->linkFlush();
         cout << "Done." << endl;
      }
      cout << endl << "Run stopped at " << ctime(&tm);
      kpixFpga->setRunEnable(false);

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

      // Stop if things are unrecoverable
      if ( errCnt > 4 ) {
         time(&tm);
         cout << "Could not recover error state. Giving up at " << ctime(&tm);
         gotCntrlC = true;
      }
      else sleep(5);
   }
   delete kpixRunWrite;
   delete sidLink;

   cout << "Power on" << endl;
   kpixPwr.setOutput(true);
}

