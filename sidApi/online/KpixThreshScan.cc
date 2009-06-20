//-----------------------------------------------------------------------------
// File          : KpixThreshScan.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/07/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for class to perform a threshold scan
// A scan is performed on a target channel or on all channels.
// Threshold range A is scanned while a pulse is injected into the selected
// channel. 
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/07/2007: created
// 03/20/2007: Modified for new root tree structures
// 04/05/2007: Added ability to set how pre-trigger threshold setting tacks
//             trigger threshold setting.
// 04/05/2007: Added ability to choose the threshold (A or B) to use for test.
// 05/01/2007: Added support for multiple KPIX devices
// 08/03/2007: Added local catching of timeout errors and retry
// 08/10/2007: Fixed broadcast of calibration command for multiple Kpixs.
// 10/06/2007: Added display of timestamps in debug mode.
// 11/12/2007: runThresholdmethods modified for new channel modes.
//             removed threshold select method
// 10/10/2008: Added support for progress updates to calling class. Added
//             iteration count variable.
// 10/26/2008: Added support for plot generation.
//-----------------------------------------------------------------------------
#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <TH2F.h>
#include <TError.h>
#include "KpixThreshScan.h"
#include "KpixBunchTrain.h"
#include "../offline/KpixSample.h"
#include "../offline/KpixAsic.h"
#include "../offline/KpixThreshRead.h"
#include "KpixRunWrite.h"
using namespace std;


// Constructor for single KPIX. 
// Pass a pointer to the Kpix Asic and the Run object
KpixThreshScan::KpixThreshScan ( KpixAsic *asic, KpixRunWrite *run ) {
   KpixThreshScan(&asic,1,run);
}


// Constructor for multiple KPIX devices. 
// Pass a pointer to the Kpix Asic and the Run object
KpixThreshScan::KpixThreshScan ( KpixAsic **asic, unsigned int count, KpixRunWrite *run ) {

   // Store Kpix
   kpixAsic  = asic;
   kpixCount = count;

   // Store values
   kpixRunWrite = run;
   enDebug      = false;
   enNormal     = false;
   enDouble     = false;
   enLow        = false;
   calEnable    = true;
   calStart     = 0xFF;
   calEnd       = 0x00;
   calStep      = 0x01;
   threshStart  = 0xb0;
   threshEnd    = 0x50;
   threshStep   = 0x01;
   threshCount  = 10;
   threshOffset = 0;
   rawEn        = false;
   plotEn       = false;
   plotDir      = "";
   kpixProgress = NULL;

   // Create Variables used by threshold scan
   kpixRunWrite->addEventVar("threshChan",
      "Target Channel For Thresh Scan, -1 for all",-2.0);
   kpixRunWrite->addEventVar("threshGain",
      "Gain For Thresh Scan, 0=Normal,1=Double,2=Low Gain",0.0);
   kpixRunWrite->addEventVar("threshDac","Threshold DAC Value",0.0);
   kpixRunWrite->addEventVar("calibDac","Calibration DAC Value",0.0);
   kpixRunWrite->addEventVar("b0Charge","Bucket 0 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b1Charge","Bucket 1 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b2Charge","Bucket 2 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b3Charge","Bucket 3 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("preTrigDac","Pre-Trigger Dac Value",0.0);
   kpixRunWrite->addEventVar("calEnable","Calibration Enable, 1=True",0.0);
}



// Enable disable charge injection
void KpixThreshScan::setCalibEn ( bool enable ) { calEnable = enable; }


// Set calibration DAC steps for threshold scan
void KpixThreshScan::setCalibRange ( unsigned char start, unsigned char end, unsigned char step ) {
   this->calStart = start;
   this->calEnd   = end;
   this->calStep  = step;
}


// Set threshold steps for threshold scan
void KpixThreshScan::setThreshRange (unsigned char start, unsigned char end, unsigned char step) {
   this->threshStart = start;
   this->threshEnd   = end;
   this->threshStep  = step;
}


// Set pre-trigger threshold offset
// Set a negative value to track the pre-trigger threshold below
// the trigger threshold. Set to zero to keep the same as
// the trigger threshold. Set to a positive value to set 
// pre-trigger to always be 0xB0.
void KpixThreshScan::setPreTrigger ( char diff ) { this->threshOffset = diff; }


// Set number of iterations to run at each step
void KpixThreshScan::setThreshCount ( int count ) { this->threshCount = count; }


// Enable/Disable normal gain iteration
void KpixThreshScan::enNormalGain ( bool enable ) { this->enNormal = enable; }


// Enable/Disable double gain iteration
void KpixThreshScan::enDoubleGain ( bool enable ) { this->enDouble = enable; }


// Enable/Disable low gain iteration
void KpixThreshScan::enLowGain ( bool enable ) { this->enLow = enable; }


// Turn on or off debugging for the class
void KpixThreshScan::threshDebug ( bool debug ) { this->enDebug = debug; }


// Enable raw data
void KpixThreshScan::enableRawData( bool enable ) {this->rawEn = enable; }


// Enable plot generation
void KpixThreshScan::enablePlots( bool enable ) { this->plotEn = enable; }


// Pass name of the TFile directory in which to store the plots
void KpixThreshScan::setPlotDir( string plotDir ) { this->plotDir = plotDir; }


// Execute threshold scan, pass target channel
// Or pass -1 to enable all channels
void KpixThreshScan::runThreshold ( short channel ) {

   int            x,y,gain,thresh;
   KpixBunchTrain *train;
   unsigned int   modes[1024];
   unsigned int   mode;
   int            count;
   double         charges[4];
   unsigned char  preTrig;
   int            errCnt;
   int            t0, t1, t2, t3;
   unsigned int   prgCount, prgTotal;
   TH2F           *hist[kpixCount];
   unsigned int   minX[kpixCount], minY[kpixCount], maxX[kpixCount], maxY[kpixCount];
   unsigned int   time,idx;

   // Set Plot Directory
   if ( plotEn ) {
      gErrorIgnoreLevel = 5000; 
      kpixRunWrite->setDir(plotDir);
   }

   // Add variable with iteration count
   kpixRunWrite->addRunVar ( "threshCount", "Total number of iterations", threshCount);

   // Run Variable For Calibration Range
   kpixRunWrite->addRunVar ( "calenable", "Calibration Enabled", calEnable);
   kpixRunWrite->addRunVar ( "calStart", "Calibration Start Value", calStart);
   kpixRunWrite->addRunVar ( "calEnd", "Calibration End Value", calEnd);
   kpixRunWrite->addRunVar ( "calStep", "Calibration Step Value", calStep);

   // Threshold Offset
   kpixRunWrite->addRunVar("threshOffset","Threshold Offset",threshOffset);

   // Init modes
   for (x=0; x < 1024; x++) modes[x] = DISABLE;

   // Determine if calibration is enabled
   if (calEnable) {
      kpixRunWrite->setEventVar("calEnable",1.0);
      mode = CAL_A;
   }
   else {
      kpixRunWrite->setEventVar("calEnable",0.0);
      mode = TH_A;
   }

   // All Channels Calibration Enabled
   if ( channel == -1 ) {
      for (x=0; x < 1024; x++) modes[x] = mode;
      kpixRunWrite->setEventVar("threshChan",-1.0);
      plotEn = false;
   }

   // One Channel Enabled
   else {
      modes[channel] = mode;
      kpixRunWrite->setEventVar("threshChan",(double)channel);
   }

   // Update channel modes
   for (x=0;x<kpixCount;x++) kpixAsic[x]->setChannelModeArray(modes);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixThreshScan::runThreshold -> ";
      cout << "Threshold Scan Started For Channel ";
      if ( channel == -1 ) cout << "All\n";
      else if ( channel == -2 ) cout << "None\n";
      else cout << "0x" << hex << setw(3) << setfill('0') << channel << "\n";
   }

   // Init progress
   prgCount = 0;
   prgTotal = 0;

   // Compute total
   if ( enNormal ) prgTotal++;
   if ( enDouble ) prgTotal++;
   if ( enLow    ) prgTotal++;
   prgTotal *= threshCount;
   prgTotal *= (((threshStart-threshEnd)/threshStep)+1);
   if ( calEnable ) prgTotal *= (((calStart-calEnd)/calStep)+1);

   // Once for each gain mode
   for ( gain=0; gain < 3; gain++ ) {

      // Normal gain
      if ( gain==0 ) {
         if ( ! enNormal ) continue;
         for (x=0; x<kpixCount; x++) {
            kpixAsic[x]->setCntrlForceLowGain ( false );
            kpixAsic[x]->setCntrlDoubleGain   ( false );
         }
      }

      // Double gain
      else if ( gain==1 ) {
         if ( ! enDouble ) continue;
         for (x=0; x<kpixCount; x++) {
            kpixAsic[x]->setCntrlForceLowGain ( false );
            kpixAsic[x]->setCntrlDoubleGain   ( true  );
         }
      }

      // Low gain
      else if ( gain==2 ) {
         if ( ! enLow ) continue;
         for (x=0; x<kpixCount; x++) {
            kpixAsic[x]->setCntrlForceLowGain ( true  );
            kpixAsic[x]->setCntrlDoubleGain   ( false );
         }
      }

      // Store gain variable
      kpixRunWrite->setEventVar("threshGain",(double)gain);

      // Loop through each calibration value
      for ( x=calStart; x >= calEnd; x-=calStep ) {

         // Set calibration DAC
         for (y=0; y<kpixCount; y++) kpixAsic[y]->setDacCalib((unsigned char)x);
         kpixRunWrite->setEventVar("calibDac",(double)x);

         // Get and store charges
         kpixAsic[0]->getCalibCharges(charges);
         kpixRunWrite->setEventVar("b0Charge",charges[0]);
         kpixRunWrite->setEventVar("b1Charge",charges[1]);
         kpixRunWrite->setEventVar("b2Charge",charges[2]);
         kpixRunWrite->setEventVar("b3Charge",charges[3]);

         // Create 2d histogram to store count for each threshold/time
         if ( plotEn ) {
            for ( y=0; y < kpixCount-1; y++ ) {
               hist[y] = new TH2F(KpixThreshRead::genPlotName("thresh_scan",gain,kpixAsic[y]->getSerial(),channel,x).c_str(),
                                  KpixThreshRead::genPlotTitle("Thresh Scan",gain,kpixAsic[y]->getSerial(),channel,x).c_str(),
                                  (threshStart-threshEnd)+1,threshEnd,threshStart+1,2880,0,2880);
               hist[y]->SetDirectory(0);
               minX[y] = 256;
               maxX[y] = 0;
               minY[y] = 2880;
               maxY[y] = 0;
            }
         }

         // Loop through each threshold
         for ( thresh=threshStart; thresh >= threshEnd; thresh-=threshStep ) {

            // Choose pretrigger value
            if ( threshOffset > 0 ) preTrig = 0xB0;
            else preTrig = thresh + threshOffset;

            // Set threshold DAC
            for (y=0; y<kpixCount; y++) 
               kpixAsic[y]->setDacThreshRangeA( (unsigned char) preTrig, 
                                                (unsigned char) thresh);

            // Set run variables
            kpixRunWrite->setEventVar("threshDac",(double)thresh);
            kpixRunWrite->setEventVar("preTrigDac",(double)preTrig);

            count=0;
            for ( y=0; y < threshCount; y++ ) {

               // Start Calibration
               errCnt = 0;
               while (1) {
                  try {
                     kpixAsic[0]->cmdCalibrate(kpixCount>1); // Broadcast if count != 1
                     train = new KpixBunchTrain ( kpixAsic[0]->getSidLink(), kpixAsic[0]->kpixDebug() );
                     break;
                  } catch (string error) {
                     if ( enDebug ) {

                        // Display error
                        cout << "KpixThreshScan::runThreshold -> ";
                        cout << "Caught Error: " << error << "\n";

                        // Count errors
                        errCnt++;
                        if ( errCnt == 5 )
                           throw(string("KpixThreshScan::runThreshold -> Too many errors. Giving Up"));
                     }
                  }
               }

               // Extract count
               t0 = -1; t1 = -1; t2 = -1; t3 = -1;
               if (train->getSample(kpixAsic[0]->getAddress(),channel,0) != NULL ) { 
                  count++; 
                  t0= train->getSample(kpixAsic[0]->getAddress(),channel,0)->getSampleTime();
               }
               if (train->getSample(kpixAsic[0]->getAddress(),channel,1) != NULL )
                  t1= train->getSample(kpixAsic[0]->getAddress(),channel,1)->getSampleTime();
               if (train->getSample(kpixAsic[0]->getAddress(),channel,2) != NULL )
                  t2= train->getSample(kpixAsic[0]->getAddress(),channel,2)->getSampleTime();
               if (train->getSample(kpixAsic[0]->getAddress(),channel,3) != NULL )
                  t3= train->getSample(kpixAsic[0]->getAddress(),channel,3)->getSampleTime();

               // Add To Plot
               if ( plotEn ) {
                  for (idx=0; idx < (unsigned int)(kpixCount-1); idx++) {
                     if ( train->getSample(kpixAsic[idx]->getAddress(),channel,0) != NULL ) {
                        time = train->getSample(kpixAsic[idx]->getAddress(),channel,0)->getSampleTime();
                        hist[idx]->Fill(thresh,time);
                        if ( (unsigned int)thresh < minX[idx] ) minX[idx] = thresh;
                        if ( (unsigned int)thresh > maxX[idx] ) maxX[idx] = thresh;
                        if ( time   < minY[idx] ) minY[idx] = time;
                        if ( time   > maxY[idx] ) maxY[idx] = time;
                     }
                  }
               }

               // Store data
               if ( rawEn ) kpixRunWrite->addBunchTrain(train);
               prgCount++;
               delete train;
            }

            if ( t0 > 4095 ) t0 = -1 * (t0 & 0xFFF);
            if ( t1 > 4095 ) t1 = -1 * (t1 & 0xFFF);
            if ( t2 > 4095 ) t2 = -1 * (t2 & 0xFFF);
            if ( t3 > 4095 ) t3 = -1 * (t3 & 0xFFF);

            // Log event count
            if ( enDebug ) {
               cout << "KpixThreshScan::runThreshold -> ";
               cout << "Channel=";
               if ( channel == -1 ) cout << "All, ";
               else if ( channel == -2 ) cout << "None, ";
               else cout << "0x" << hex << setw(3) << setfill('0') << channel << ", ";
               cout << "Mode=" << gain << ", " ;
               cout << "DAC4=0x" << hex << setw(2) << setfill('0') << x << ", ";
               cout << "Thresh=0x" << hex << setw(2) << setfill('0') << thresh << ", ";
               cout << "Count=" << dec << setw(2) << setfill('0') << count << ", ";
               cout << "T0=" << dec << setfill('0') << t0 << ", ";
               cout << "T1=" << dec << setfill('0') << t1 << ", ";
               cout << "T2=" << dec << setfill('0') << t2 << ", ";
               cout << "T3=" << dec << setfill('0') << t3 << "\n";
            }

            // Update Progress
            if ( kpixProgress != NULL ) kpixProgress->updateProgress(prgCount,prgTotal);
         }

         // Pass Plot
         if ( plotEn ) {
            for (idx=0; idx < (unsigned int)(kpixCount-1); idx++) {
               hist[idx]->GetXaxis()->SetRangeUser(minX[idx],maxX[idx]);
               hist[idx]->GetYaxis()->SetRangeUser(minY[idx],maxY[idx]);
               hist[idx]->Write();
               if ( kpixProgress != NULL ) kpixProgress->updateData(KPRG_TH2F,1,(void**)(&(hist[idx])));
               else delete hist[idx];
            }
            sleep(2);
         }
         if ( calEnable == false ) break;
      }
   }
   if ( plotEn ) kpixRunWrite->setDir("/");

   // Debug if enabled
   if ( enDebug )
      cout << "KpixThreshScan::runThreshold -> Threshold Scan Done\n";
}


// Set progress Callback
void KpixThreshScan::setKpixProgress(KpixProgress *progress) {
   this->kpixProgress = progress;
}


// Deconstructor
KpixThreshScan::~KpixThreshScan () { }


