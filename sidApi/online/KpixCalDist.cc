//-----------------------------------------------------------------------------
// File          : KpixCalDist.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/07/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for class to perform calibrations and distributions
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/07/2007: created
// 03/19/2007: Added Sample variables to store calibration charge in Coulombs.
// 03/28/2007: Changed some debugging outputs.
// 05/01/2007: Added support for multiple KPIX devices
// 08/03/2007: Added local catching of timeout errors and retry
// 11/12/2007: runDistribution and runCalibration methods modified for new
//             channel modes.
// 02/29/2008: Added ability to create histograms and calibration plots on the fly
// 05/19/2008: Created seperate calibration ranges for the three gains. 
//             Full configured range is always fit.
// 09/26/2008: Added support for progress updates to calling class.
// 10/09/2008: Fixed bug where tc was not initalized to NULL.
// 10/13/2008: Removed fitting functions. Seperate plot & raw data enable from
//             canvas and plot directory setting.
// 03/05/2009: Added ability to rate limit calibration and dist generation
// 05/11/2009: Added range checking on serial number lookup.
// 05/15/2009: Added feature to support random histogram time generation.
// 06/22/2009: Added namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <sys/time.h>
#include <TStyle.h>
#include <TH1F.h>
#include <TGraph.h>
#include <TGraph2D.h>
#include <TError.h>
#include <TF1.h>
#include <TMinuit.h>
#include <unistd.h>
#include "KpixCalDist.h"
#include "KpixHistogram.h"
#include "KpixRunWrite.h"
#include "KpixBunchTrain.h"
#include "KpixProgress.h"
#include "../offline/KpixCalibRead.h"
#include "../offline/KpixAsic.h"
#include "../offline/KpixSample.h"
using namespace std;
using namespace sidApi::online;
using namespace sidApi::offline;


// Constructor for single KPIX. 
// Pass a pointer to the Kpix Asic and the Run object
KpixCalDist::KpixCalDist ( KpixAsic *asic, KpixRunWrite *run ) {
   KpixCalDist ( &asic, 1, run);
}


// Constructor for multiple KPIX devices. 
// Pass a pointer to the Kpix Asic and the Run object
KpixCalDist::KpixCalDist ( KpixAsic **asic, unsigned int count, KpixRunWrite *run ) {

   unsigned int x;

   // Store Kpix
   kpixAsic  = asic;
   kpixCount = count;

   // Store values
   kpixRunWrite = run;
   enDebug      = false;
   enNormal     = false;
   enDouble     = false;
   enLow        = false;
   rawDataEn    = true;
   plotEn       = true;
   calStart     = 0xFF;
   calEnd       = 0x00;
   calStep      = 0x01;
   distCount    = 4000;
   distCalDac   = 0xFF;
   plotDir      = "Plots";
   kpixProgress = NULL;
   rateLimit    = 0;
   
   // THis should not happen
   if ( count == 0 ) throw(string("KpixCalDist::KpixCalDist -> Error: Asic Count Is Zero"));

   // Create Variables used by cal/dist
   kpixRunWrite->addEventVar("calDistType","Calib/Dist Type. 0=Cal, 1=Dist",0.0);
   kpixRunWrite->addEventVar("calDistMaskChan",
      "Mask Channel For Calib/Dist, -1 for all, -2 for none",-2.0);
   kpixRunWrite->addEventVar("calDistGain",
      "Gain For Calib/Dist, 0=Normal,1=Double,2=Low Gain",0.0);
   kpixRunWrite->addEventVar("calibDac","Calibration DAC Value",0.0);
   kpixRunWrite->addEventVar("b0Charge","Bucket 0 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b1Charge","Bucket 1 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b2Charge","Bucket 2 Calibration Charge",0.0);
   kpixRunWrite->addEventVar("b3Charge","Bucket 3 Calibration Charge",0.0);

   // Generate Kpix Lookup Table
   maxAddress = 0;
   for (x=0; x < count; x++) if ( kpixAsic[x]->getAddress() > maxAddress ) maxAddress = kpixAsic[x]->getAddress();

   // Creat table
   kpixIdxLookup = (unsigned int *)malloc((maxAddress+1)*sizeof(unsigned int));     
   if ( kpixIdxLookup == NULL ) throw(string("KpixCalDist::KpixCalDist -> Malloc Error"));
   for (x=0; x < count; x++) kpixIdxLookup[kpixAsic[x]->getAddress()] = x;
}


// Set calibration DAC value for distribution
void KpixCalDist::setDistCalDac ( unsigned char value ) { this->distCalDac = value; }


// Set number of distribution iterations
void KpixCalDist::setDistCount ( unsigned int count ) { this->distCount = count; }


// Set calibration DAC steps for calibration run
void KpixCalDist::setCalibRange ( unsigned char start, unsigned char end, unsigned char step ) {
   this->calStart = start;
   this->calEnd   = end;
   this->calStep  = step;
}


// Enable/Disable normal gain iteration
void KpixCalDist::enNormalGain ( bool enable ) { this->enNormal = enable; }


// Enable/Disable double gain iteration
void KpixCalDist::enDoubleGain ( bool enable ) { this->enDouble = enable; }


// Enable/Disable low gain iteration
void KpixCalDist::enLowGain ( bool enable ) { this->enLow = enable; }


// Turn on or off debugging for the class
void KpixCalDist::calDistDebug ( bool debug ) { this->enDebug = debug; }


// Enable raw data
void KpixCalDist::enableRawData( bool enable ) { this->rawDataEn = enable; }


// Enable plots
void KpixCalDist::enablePlots( bool enable ) { this->plotEn = enable; }


// TFile directory in which to store the plots
void KpixCalDist::setPlotDir(string plotDir ) { this->plotDir = plotDir; }


// Set Rate Limit
void KpixCalDist::setRateLimit( unsigned int rateLimit ) { this->rateLimit = rateLimit; }


// Enable random histogram time
void KpixCalDist::enableRandDistTime ( bool enable ) { this->randDistTimeEn = enable; }


// Execute distribution, pass channel to enable calibration mask for
// Or pass -1 to set cal mask for all channels or -2 to set mask for no channels
void KpixCalDist::runDistribution ( short channel ) {

   unsigned int   x,y,gain;
   KpixBunchTrain *train;
   KpixSample     *sample;
   double         charges[4];
   int            errCnt;
   unsigned int   modes[1024];
   TH1F           *hist[8];
   int            kpixSer, kpixAddr, chan, bucket, idx, range;
   unsigned int   kpixIdx;
   unsigned int   prgCount, prgTotal;
   KpixHistogram  *value[4096 * kpixCount];
   KpixHistogram  *time[4096 * kpixCount];
   unsigned int   plotCount;
   struct timeval curTime, acqTime;
   unsigned long  diff, secUs;
   unsigned int   distMin;
   unsigned int   distMax;
   unsigned int   calCount;
   unsigned int   orig0Delay;
   unsigned int   cal0Delay;
   unsigned int   cal1Delay;
   unsigned int   cal2Delay;
   unsigned int   cal3Delay;

   // Set Plot Directory
   if ( plotEn ) {
      gErrorIgnoreLevel = 5000; 
      kpixRunWrite->setDir(plotDir);
   }

   // Set distribution mode 
   kpixRunWrite->setEventVar("calDistType",1.0);

   // Init modes
   for (x=0; x < 1024; x++) modes[x] = ChanDisable;

   // No Channels Enabled
   if ( channel == -2 ) kpixRunWrite->setEventVar("calDistMaskChan",-2.0);

   // All Channels Enabled
   else if ( channel == -1 ) {
      for (x=0; x < 1024; x++) modes[x] = ChanThreshACal;
      kpixRunWrite->setEventVar("calDistMaskChan",-1.0);
   }

   // One Channel Enabled
   else {
      modes[channel] = ChanThreshACal;
      kpixRunWrite->setEventVar("calDistMaskChan",(double)channel);
   }

   // Update channel modes
   for (x=0;x<kpixCount;x++) kpixAsic[x]->setChannelModeArray(modes);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixCalDist::runDistribution -> ";
      cout << "Distribution Started For Channel ";
      if ( channel == -1 ) cout << "All.";
      else if ( channel == -2 ) cout << "None.";
      else cout << "0x" << hex << setw(3) << setfill('0') << channel << ".";
      cout << ", RandDist=" << randDistTimeEn << endl;
   }

   // Init progress
   prgCount = 0;
   prgTotal = 0;

   // Init time
   gettimeofday(&curTime, NULL); 
   acqTime.tv_sec  = curTime.tv_sec - 100;
   acqTime.tv_usec = 0;

   // Compute total
   if ( enNormal ) prgTotal++;
   if ( enDouble ) prgTotal++;
   if ( enLow    ) prgTotal++;
   prgTotal *= distCount;

   // Init histogram pointers
   for (x=0; x < 4096*kpixCount; x++) {
      value[x] = NULL;
      time[x]  = NULL;
   }

   // Random histogram times enabled
   if ( randDistTimeEn ) {

      // Get previous settings
      kpixAsic[0]->getCalibTime(&calCount,&orig0Delay,&cal1Delay,&cal2Delay,&cal3Delay,false);

      // Figure out range for first value
      distMin = KpixCalDist::distTimeMin;
      distMax = kpixAsic[0]->getBunchCount(false) - KpixCalDist::distTimeMax - cal1Delay - cal2Delay - cal3Delay;
   }
   else {
      calCount   = 0;
      orig0Delay = 0;
      cal0Delay  = 0;
      cal1Delay  = 0;
      cal2Delay  = 0;
      cal3Delay  = 0;
      distMin    = 0;
      distMax    = 0;
   }

   // Once for each gain mode
   for ( gain=0; gain < 3; gain++ ) {

      // Normal gain
      if ( gain==0 ) {
         if ( ! enNormal ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( false );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( false );
      }

      // Double gain
      else if ( gain==1 ) {
         if ( ! enDouble ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( false );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( true  );
      }

      // Low gain
      else if ( gain==2 ) {
         if ( ! enLow ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( true  );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( false );
      }

      // Store mode variable
      kpixRunWrite->setEventVar("calDistGain",(double)gain);

      // Set calibration charge
      for(x=0;x<kpixCount;x++) kpixAsic[x]->setDacCalib((unsigned char)distCalDac);
      kpixRunWrite->setEventVar("calibDac",(double)distCalDac);

      // Get and store charges
      kpixAsic[0]->getCalibCharges(charges);
      kpixRunWrite->setEventVar("b0Charge",charges[0]);
      kpixRunWrite->setEventVar("b1Charge",charges[1]);
      kpixRunWrite->setEventVar("b2Charge",charges[2]);
      kpixRunWrite->setEventVar("b3Charge",charges[3]);

      // Loop through dist iterations
      for ( x=0; x < distCount; x++ ) {

         // Generate random times if enabled
         if ( randDistTimeEn ) {

            // Get random number
            cal0Delay = distMin + (unsigned int)((double)(distMax-distMin) * ((double)random()/(double)RAND_MAX));

            // Set new values
            for(y=0;y<kpixCount;y++) kpixAsic[y]->setCalibTime(calCount,cal0Delay,cal1Delay,cal2Delay,cal3Delay);
         }

         // Throttle acquistion if enabled
         do {

            // Get Current acquisition time
            gettimeofday(&curTime,NULL); 

            // Difference in uS
            secUs = 1000000 * (curTime.tv_sec - acqTime.tv_sec);
            diff  = (secUs + curTime.tv_usec) - acqTime.tv_usec;

         } while ( rateLimit != 0 && diff < rateLimit );
         acqTime.tv_sec  = curTime.tv_sec; 
         acqTime.tv_usec = curTime.tv_usec; 

         // Start Calibration
         errCnt = 0;
         while (1) {
            try {
               kpixAsic[0]->cmdCalibrate(kpixCount>1); // Broadcast if count != 1
               train = new KpixBunchTrain (kpixAsic[0]->getSidLink(), kpixAsic[0]->kpixDebug());
               break;
            } catch (string error) {
               if ( enDebug ) {

                  // Display error
                  cout << "KpixCalDist::runDistribution -> ";
                  cout << "Caught Error: " << error << "\n";
               }

               // Count errors
               errCnt++;
               if ( errCnt == 5 )
                  throw(string("KpixCalDist::runDistribution -> Too many errors. Giving Up"));
            }
         }

         // Fill histogram for each channel we have received data for
         if ( plotEn ) {
            for (y=0; y < train->getSampleCount(); y++) {
               sample   = train->getSampleList()[y];
               kpixAddr = sample->getKpixAddress();
               chan     = sample->getKpixChannel();
               bucket   = sample->getKpixBucket();
               range    = sample->getSampleRange();

               if ( (unsigned int)kpixAddr > maxAddress )
                  throw(string("KpixCalDist::runDistribution -> Data Received From Unkown KPIX Address"));

               kpixIdx  = kpixIdxLookup[kpixAddr];

               // Channel matches target & targetted range
               if ( (chan == channel || channel < 0) && ( (range==1 && gain==2) || range==0) ) {
                  idx = kpixIdx*4096 + chan*4 + bucket;
                  if ( value[idx] == NULL ) value[idx] = new KpixHistogram();
                  if ( time[idx]  == NULL ) time[idx]  = new KpixHistogram();
                  value[idx]->fill(sample->getSampleValue());
                  time[idx]->fill(sample->getSampleTime());
               }
            }
         }

         // Log event count
         if ( enDebug && x % 100 == 0) {
            cout << "KpixCalDist::runDistribution -> ";
            cout << "Channel=";
            if ( channel == -1 ) cout << "All, ";
            else if ( channel == -2 ) cout << "None, ";
            else cout << "0x" << hex << setw(3) << setfill('0') << channel << ", ";
            cout << "Mode=" << gain << ", ";
            cout << "Iter=" << dec << setw(2) << setfill('0') << x;

            // Display each buckets values, Use Kpix 0
            for (y=0; y < 4; y++) {
               if ( (sample = train->getSample(kpixAsic[0]->getAddress(),channel,y)) != NULL ) 
                  cout << ", " << hex << setw(4) << setfill('0') << sample->getSampleValue();
            }
            cout << "\n";
         }

         // Add sample to run
         if ( rawDataEn ) kpixRunWrite->addBunchTrain(train);
         delete train;

         // Update Progress
         prgCount++;
         if ( kpixProgress != NULL && (x % 50) == 0) kpixProgress->updateProgress(prgCount,prgTotal);
      }
      if ( kpixProgress != NULL ) kpixProgress->updateProgress(prgCount,prgTotal);

      // Restore original delay settings
      if ( randDistTimeEn ) 
         for(x=0;x<kpixCount;x++) kpixAsic[x]->setCalibTime(calCount,orig0Delay,cal1Delay,cal2Delay,cal3Delay);

      // Store histograms
      if ( plotEn ) {

         // Debug if enabled
         if ( enDebug )
            cout << "KpixCalDist::runDistribution -> Storing Distributions\n";

         // Each Kpix
         for ( kpixIdx=0; kpixIdx < kpixCount; kpixIdx++ ) {

            // Get Kpix Serial Number
            kpixSer = kpixAsic[kpixIdx]->getSerial();

            // Each channel
            for ( chan=0; chan < 1024; chan++ ) {

               // Targetted Channel
               if (chan == channel || channel < 0 ) {

                  // Each bucket
                  plotCount = 0;
                  for ( bucket = 0; bucket < 4; bucket++ ) {
                     idx = kpixIdx*4096 + chan*4 + bucket;

                     // Make sure there is data
                     if ( value[idx] != NULL ) {
                        plotCount++;

                        // Create Value histogram
                        hist[bucket*2] = new TH1F(KpixCalibRead::genPlotName(gain,kpixSer,chan,bucket,"dist_value").c_str(),
                                                  KpixCalibRead::genPlotTitle(gain,kpixSer,chan,bucket,"Dist Value").c_str(),
                                                  value[idx]->binCount(),
                                                  value[idx]->minValue(),
                                                  value[idx]->maxValue()+1);
                        
                        // Fill Value histogram
                        for (x=0; x < value[idx]->binCount(); x++) 
                           hist[bucket*2]->SetBinContent(x+1,value[idx]->count(x));
                        hist[bucket*2]->Write();
                        hist[bucket*2]->SetDirectory(0);

                        // Create Time Histogram
                        hist[bucket*2+1] = new TH1F(KpixCalibRead::genPlotName(gain,kpixSer,chan,bucket,"dist_time").c_str(),
                                                    KpixCalibRead::genPlotTitle(gain,kpixSer,chan,bucket,"Dist Time").c_str(),
                                                    time[idx]->binCount(),
                                                    time[idx]->minValue(),
                                                    time[idx]->maxValue()+1);

                        // Fill Time Histogram
                        for (x=0; x < time[idx]->binCount(); x++) hist[bucket*2+1]->SetBinContent(x+1,time[idx]->count(x));
                        hist[bucket*2+1]->Write();
                        hist[bucket*2+1]->SetDirectory(0);

                        // Delete the histogram
                        delete value[idx]; value[idx] = NULL;
                        delete time[idx];  time[idx]  = NULL;
                     }
                     else {
                        hist[bucket*2]   = NULL;
                        hist[bucket*2+1] = NULL;
                     }
                  }

                  // Update Live Plots
                  if (kpixProgress != NULL && plotCount != 0) 
                     kpixProgress->updateData(DataTH1F,8,(void **)hist); 

                  // Otherwise delete plots
                  else for ( bucket = 0; bucket < 8; bucket++ ) if ( hist[bucket] != NULL ) delete hist[bucket]; 
               }
            }
         }
         sleep(2);
      }
   }

   // Delete canvas
   if ( plotEn ) kpixRunWrite->setDir("/");

   // Debug if enabled
   if ( enDebug )
      cout << "KpixCalDist::runDistribution -> Distribution Done\n";
}


// Execute calibration, pass channel to enable calibration mask for
// Or pass -1 to set cal mask for all channels or -2 to set mask for no channels
void KpixCalDist::runCalibration ( short channel ) {

   unsigned int     x,gain;
   int              cal;
   KpixBunchTrain   *train;
   KpixSample       *sample;
   double           charges[4];
   int              errCnt;
   unsigned int     modes[1024];
   int              kpixSer, kpixAddr, chan, bucket, idx;
   unsigned int     kpixIdx;
   TGraph           *tg[16];
   unsigned int     prgCount, prgTotal;
   KpixCalDistData  *dataR0[4096 * kpixCount];
   KpixCalDistData  *dataR1[4096 * kpixCount];
   unsigned int     plotCount;
   struct timeval   curTime, acqTime;
   unsigned long    diff, secUs;

   // Set Plot Directory
   if ( plotEn ) {
      gErrorIgnoreLevel = 5000; 
      kpixRunWrite->setDir(plotDir);
   }

   // Set calibration mode 
   kpixRunWrite->setEventVar("calDistType",0.0);

   // Init modes
   for (x=0; x < 1024; x++) modes[x] = ChanDisable;

   // No Channels Enabled
   if ( channel == -2 ) kpixRunWrite->setEventVar("calDistMaskChan",-2.0);

   // All Channels Enabled
   else if ( channel == -1 ) {
      for (x=0; x < 1024; x++) modes[x] = ChanThreshACal;
      kpixRunWrite->setEventVar("calDistMaskChan",-1.0);
   }

   // One Channel Enabled
   else {
      modes[channel] = ChanThreshACal;
      kpixRunWrite->setEventVar("calDistMaskChan",(double)channel);
   }

   // Update channel modes
   for (x=0;x<kpixCount;x++) kpixAsic[x]->setChannelModeArray(modes);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixCalDist::runCalibration -> ";
      cout << "Calibration Started For Channel ";
      if ( channel == -1 ) cout << "All\n";
      else if ( channel == -2 ) cout << "None\n";
      else cout << "0x" << hex << setw(3) << setfill('0') << channel << "\n";
   }

   // Init time
   gettimeofday(&curTime, NULL); 
   acqTime.tv_sec  = curTime.tv_sec - 100;
   acqTime.tv_usec = 0;

   // Init progress
   prgCount = 0;
   prgTotal = 0;

   // Compute total
   if ( enNormal ) prgTotal++;
   if ( enDouble ) prgTotal++;
   if ( enLow    ) prgTotal++;
   prgTotal *= (((calStart-calEnd)/calStep)+1);

   // Init graph pointers
   for (x=0; x < 4096*kpixCount; x++) {
      dataR0[x] = NULL;
      dataR1[x] = NULL;
   }

   // Once for each gain mode
   for ( gain=0; gain < 3; gain++ ) {

      // Normal gain
      if ( gain==0 ) {
         if ( ! enNormal ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( false );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( false );
      }

      // Double gain
      else if ( gain==1 ) {
         if ( ! enDouble ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( false );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( true  );
      }

      // Low gain
      else if ( gain==2 ) {
         if ( ! enLow ) continue;
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlForceLowGain ( true  );
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setCntrlDoubleGain   ( false );
      }

      // Store gain variable
      kpixRunWrite->setEventVar("calDistGain",(double)gain);

      // Loop through each calibration value
      for ( cal=calStart; cal >= calEnd; cal-=calStep ) {

         // Set calibration DAC
         for (x=0;x<kpixCount;x++) kpixAsic[x]->setDacCalib((unsigned char)cal);
         kpixRunWrite->setEventVar("calibDac",(double)cal);

         // Get and store charges
         kpixAsic[0]->getCalibCharges(charges);
         kpixRunWrite->setEventVar("b0Charge",charges[0]);
         kpixRunWrite->setEventVar("b1Charge",charges[1]);
         kpixRunWrite->setEventVar("b2Charge",charges[2]);
         kpixRunWrite->setEventVar("b3Charge",charges[3]);

         // Throttle acquistion if enabled
         do {

            // Get Current acquisition time
            gettimeofday(&curTime,NULL); 

            // Difference in uS
            secUs = 1000000 * (curTime.tv_sec - acqTime.tv_sec);
            diff  = (secUs + curTime.tv_usec) - acqTime.tv_usec;

         } while ( rateLimit != 0 && diff < rateLimit );
         acqTime.tv_sec  = curTime.tv_sec; 
         acqTime.tv_usec = curTime.tv_usec; 

         // Start Calibration
         errCnt = 0;
         while (1) {
            try {
               kpixAsic[0]->cmdCalibrate(kpixCount > 1); // Broadcast for count > 1
               train = new KpixBunchTrain ( kpixAsic[0]->getSidLink(), kpixAsic[0]->kpixDebug() );
               break;
            } catch (string error) {
               if ( enDebug ) {

                  // Display error
                  cout << "KpixCalDist::runCalibration -> ";
                  cout << "Caught Error: " << error << "\n";
               }

               // Count errors
               errCnt++;
               if ( errCnt == 5 )
                  throw(string("KpixCalDist::runDistribution -> Too many errors. Giving Up"));
            }
         }

         // Fill histogram for each channel we have received data for
         if ( plotEn ) {

            // Get each sample value
            for (x=0; x < train->getSampleCount(); x++) {
               sample   = train->getSampleList()[x];
               kpixAddr = sample->getKpixAddress();
               chan     = sample->getKpixChannel();
               bucket   = sample->getKpixBucket();

               if ( (unsigned int)kpixAddr > maxAddress )
                  throw(string("KpixCalDist::runCalibration -> Data Received From Unkown KPIX Address"));

               kpixIdx  = kpixIdxLookup[kpixAddr];

               // Channel matches target
               if ( chan == channel || channel < 0 ) {

                  // Generate calibration index
                  idx = kpixIdx*4096 + chan*4 + bucket;
                  kpixAsic[kpixIdx]->getCalibCharges(charges);

                  // Choose Range
                  if ( sample->getSampleRange() ) {

                     // Create data if it does not exist
                     if ( dataR1[idx] == NULL ) dataR1[idx] = new KpixCalDistData();

                     // Add point
                     dataR1[idx]->xData[dataR1[idx]->count] = charges[bucket];
                     dataR1[idx]->vData[dataR1[idx]->count] = sample->getSampleValue();
                     dataR1[idx]->tData[dataR1[idx]->count] = sample->getSampleTime();
                     dataR1[idx]->count++;
                  } else {

                     // Create data if it does not exist
                     if ( dataR0[idx] == NULL ) dataR0[idx] = new KpixCalDistData();

                     // Add point
                     dataR0[idx]->xData[dataR0[idx]->count] = charges[bucket];
                     dataR0[idx]->vData[dataR0[idx]->count] = sample->getSampleValue();
                     dataR0[idx]->tData[dataR0[idx]->count] = sample->getSampleTime();
                     dataR0[idx]->count++;
                  }
               }
            }
         }

         // Log event count
         if ( enDebug && prgCount % 0x10 == 0) {
            cout << "KpixCalDist::runCalibration -> ";
            cout << "Channel=";
            if ( channel == -1 ) cout << "All, ";
            else if ( channel == -2 ) cout << "None, ";
            else cout << "0x" << hex << setw(3) << setfill('0') << channel << ", ";
            cout << "Mode=" << gain << ", ";
            cout << "DAC4=0x" << hex << setw(2) << setfill('0') << cal;

            // Display each buckets values
            for (x=0; x < 4; x++) {
               if ( (sample = train->getSample(kpixAsic[0]->getAddress(),channel,x)) != NULL )  {
                  cout << ", 0x" << hex << setw(4) << setfill('0') << sample->getSampleValue();
                  cout << ", 0x" << hex << setw(4) << setfill('0') << sample->getSampleTime();
               }
            }
            cout << "\n";
         }

         // Add sample to run
         if ( rawDataEn ) kpixRunWrite->addBunchTrain(train);
         delete train;

         // Update Progress
         if ( kpixProgress != NULL && prgCount % 10 == 0) kpixProgress->updateProgress(prgCount,prgTotal);
         prgCount++;
      }
      if ( kpixProgress != NULL ) kpixProgress->updateProgress(prgCount,prgTotal);

      // Store calibrations
      if ( plotEn ) {

         // Debug if enabled
         if ( enDebug )
            cout << "KpixCalDist::runCalibration -> Storing Calibrations\n";

         // Each Kpix
         for ( kpixIdx=0; kpixIdx < kpixCount; kpixIdx++ ) {

            // Get Kpix Serial Number
            kpixSer = kpixAsic[kpixIdx]->getSerial();

            // Each channel
            for ( chan=0; chan < 1024; chan++ ) {

               // Channel matches target
               if ( chan == channel || channel < 0 ) {

                  // Each bucket
                  plotCount = 0;
                  for ( bucket = 0; bucket < 4; bucket++ ) {
                      tg[bucket*4]   = NULL; // Value, R=0
                      tg[bucket*4+1] = NULL; // Value, R=1
                      tg[bucket*4+2] = NULL; // Time,  R=0
                      tg[bucket*4+3] = NULL; // Time,  R=1

                     // Generate calibration index
                     idx = kpixIdx*4096 + chan*4 + bucket;

                     // Range 0
                     if ( dataR0[idx] != NULL ) {
                        plotCount++;

                        // Create Range 0, Value graph
                        tg[bucket*4] = new TGraph(dataR0[idx]->count, dataR0[idx]->xData, dataR0[idx]->vData);
                        tg[bucket*4]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixSer, chan, bucket,"Calib Value",0).c_str());
                        tg[bucket*4]->SetMarkerColor(4);
                        tg[bucket*4]->Write(KpixCalibRead::genPlotName(gain, kpixSer, chan, bucket,"calib_value",0).c_str());

                        // Create Range 0, Time graph
                        tg[bucket*4+2] = new TGraph(dataR0[idx]->count, dataR0[idx]->xData, dataR0[idx]->tData);
                        tg[bucket*4+2]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixSer, chan, bucket,"Calib Time",0).c_str());
                        tg[bucket*4+2]->SetMarkerColor(4);
                        tg[bucket*4+2]->Write(KpixCalibRead::genPlotName(gain, kpixSer, chan, bucket,"calib_time",0).c_str());

                        // Delete data
                        delete dataR0[idx]; dataR0[idx] = NULL;
                     } else {
                        tg[bucket*4]   = NULL;
                        tg[bucket*4+2] = NULL;
                     }

                     // Range 1
                     if ( dataR1[idx] != NULL ) {
                        plotCount++;

                        // Create Range 1, Value graph
                        tg[bucket*4+1] = new TGraph(dataR1[idx]->count, dataR1[idx]->xData, dataR1[idx]->vData);
                        tg[bucket*4+1]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixSer, chan, bucket,"Calib Value",1).c_str());
                        tg[bucket*4+1]->Write(KpixCalibRead::genPlotName(gain, kpixSer, chan, bucket,"calib_value",1).c_str());
                        tg[bucket*4+1]->SetMarkerColor(3);

                        // Create Range 1, Time graph
                        tg[bucket*4+3] = new TGraph(dataR1[idx]->count, dataR1[idx]->xData, dataR1[idx]->tData);
                        tg[bucket*4+3]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixSer, chan, bucket,"Calib Time",1).c_str());
                        tg[bucket*4+3]->Write(KpixCalibRead::genPlotName(gain, kpixSer, chan, bucket,"calib_time",1).c_str());
                        tg[bucket*4+3]->SetMarkerColor(3);

                        // Delete data
                        delete dataR1[idx]; dataR1[idx] = NULL;
                     } else {
                        tg[bucket*4+1] = NULL;
                        tg[bucket*4+3] = NULL;
                     }
                  }

                  // Check For Valid, Update Live Plots
                  if ( kpixProgress != NULL && plotCount != 0 )
                     kpixProgress->updateData(DataTGraph,16,(void **)tg);

                  // Otherwise delete plots
                  else for ( bucket = 0; bucket < 16; bucket++ ) if ( tg[bucket] != NULL ) delete tg[bucket];
               }
            }
         }
         sleep(2);
      }
   }

   // Delete canvas
   if ( plotEn ) kpixRunWrite->setDir("/");

   // Debug if enabled
   if ( enDebug )
      cout << "KpixCalDist::runCalibration -> Calibration Done\n";
}


// Deconstructor
KpixCalDist::~KpixCalDist () {
   free(kpixIdxLookup); 
}


// Set progress Callback
void KpixCalDist::setKpixProgress(KpixProgress *progress) {
   this->kpixProgress = progress;
}

