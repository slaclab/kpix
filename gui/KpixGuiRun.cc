//-----------------------------------------------------------------------------
// File          : KpixGuiRun.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC data runs.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
// 04/29/2009: Added support for all 4 buckets.
// 05/11/2009: Added range check on address field.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <TError.h>
#include <TStyle.h>
#include <TH2F.h>
#include <TH1F.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qlistbox.h>
#include <sys/time.h>
#include <KpixCalDist.h>
#include "KpixGuiRun.h"
#include "KpixGuiTop.h"
#include <KpixRunWrite.h>
#include <KpixBunchTrain.h>
#include <KpixHistogram.h>
#include <KpixCalibRead.h>
#include <KpixSample.h>
#include "KpixGuiRunNetwork.h"
using namespace std;


// Constructor
KpixGuiRun::KpixGuiRun ( KpixGuiTop *parent ) : KpixGuiRunForm() {
   unsigned int x;

   this->asicCnt = 0;
   this->fpga    = NULL;
   this->asic    = NULL;
   this->parent  = parent;

   // Create error window
   errorMsg = new KpixGuiError(this);

   // Run Flags
   enRun     = false;
   pRun      = false;
   isRunning = false;

   // Default status
   status->setText("Idle");

   // Init plots
   for (x=0; x<32; x++) plots[x]    = NULL;
   for (x=0; x<16; x++) {
      dispKpix[x] = -1;
      dispChan[x] = -1;
   }

   // Run viewer
   runView = NULL;

   // Default to calibrate
   runCommand->setCurrentItem(1);
}


// Delete
KpixGuiRun::~KpixGuiRun ( ) {
   unsigned int x;
   for (x=0; x<32; x++) if ( plots[x] != NULL ) delete plots[x];
   for (x=0; x< runVarCount; x++) delete runVars[x];
   if ( runView != NULL ) delete runView;
}


// Show is called
void KpixGuiRun::show() {
   KpixGuiRunForm::show();
}


// Control Enable Of Buttons/Edits
void KpixGuiRun::setEnabled ( bool enable ) {
   enableRawData->setEnabled(enable);
   enablePlots->setEnabled(enable);
   runCommand->setEnabled(enable);
   startRun->setEnabled(enable);
   stopRun->setEnabled(!enable);
   pauseRun->setEnabled(!enable);
   closeWindow->setEnabled(enable);
   netEnable->setEnabled(enable);
   netPort->setEnabled(enable);
   addEvent->setEnabled(enable);
   delEvent->setEnabled(enable);
   if ( outDataFile == "" ) viewData->setEnabled(false);
   else viewData->setEnabled(enable);
   eventTable->setColumnReadOnly(0,!enable);
   eventTable->setColumnReadOnly(1,!enable);
   eventTable->setColumnReadOnly(2,!enable);
}


// Set Asics
void KpixGuiRun::setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga, KpixRunRead *runRead ) {
   unsigned int x,y,z,count;
   stringstream temp;
   string       temp2;
   KpixEventVar *eventVar;

   this->asicCnt = asicCnt;
   this->asic    = asic;
   this->fpga    = fpga;

   // Update box
   chanSel->clear();
   count = 0;
   if ( asicCnt > 1 ) for (x=0; x < (asicCnt-1); x++) {
      for (y=0; y < asic[x]->getChCount(); y++) {
         for (z=0; z < 4; z++) {
            temp.str("");
            temp << "Kpix " << dec << x;
            temp << " - Ch " << dec << y;
            temp << " - Bk " << dec << z;
            chanSel->insertItem(temp.str(),count);
            count++;
         }
      }
   }

   // Only copy event variables from other runs
   if ( runRead != NULL && runRead->getRunName() == "run" ) {

      // For Each Event Variable
      eventTable->setNumRows(runRead->getEventVarCount());
      for (x=0; x < (unsigned int)runRead->getEventVarCount(); x++ ) {
         eventVar = runRead->getEventVar(x);
         temp2 = eventVar->name(); eventTable->setText(x,0,temp2);
         temp2 = eventVar->description(); eventTable->setText(x,2,temp2);
         eventTable->setText(x,1,"");
      }
      eventTable->adjustColumn(0);
      eventTable->adjustColumn(1);
      eventTable->adjustColumn(2);
   }
   update();
}


// Run 
void KpixGuiRun::startRun_pressed ( ) {

   stringstream temp;
   unsigned int x,fd;

   // Get Config Data
   baseDir = parent->getBaseDir();
   desc    = parent->getRunDescription();
   runVars = parent->getRunVarList(&runVarCount);
   calFile = parent->getCalFile();

   // Generate directory name based on time
   temp.str("");
   temp << baseDir << "/" << KpixRunWrite::genTimestamp() << "_" << "run";
   outDataDir = temp.str();
   mkdir (outDataDir.c_str(),0755);
   dataDir->setText(outDataDir);

   // Generate File Name
   temp.str("");
   temp << outDataDir << "/" << "run.root";
   outDataFile = temp.str();
   cout << "Logging Data To: " << outDataFile << "\n";

   // Add Text File To Directory With Description
   temp.str("");
   temp << outDataDir;
   temp << "/00_" << desc;
   for ( x=0; x<asicCnt; x++ ) temp << "_" << dec << asic[x]->getSerial();
   fd = open(temp.str().c_str(), O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
   ::close(fd);

   // Start Thread
   enRun     = true;
   pRun      = false;
   isRunning = true;
   parent->setEnabled(false);
   pauseRun->setDown(false);
   QThread::start();
}


// Stop
void KpixGuiRun::stopRun_pressed ( ) {
   stopRun->setEnabled(false);
   enRun = false;
   status->setText("Stopping At Next Break Point");
   pauseRun->setDown(false);
   update();
}


// Pause
void KpixGuiRun::pauseRun_stateChanged ( int state ) { 
   if ( state == 0 ) pRun = false;
   else pRun = true;
   update();
}


// Update list of plots to show
void KpixGuiRun::viewData_pressed() {
   if ( runView != NULL ) delete runView;
   runView = new KpixGuiRunView(outDataFile,true);
   runView->show();
}


// Thread for register test
void KpixGuiRun::run() {
   unsigned int       x,y,z,r,idx;
   KpixRunWrite       *kpixRunWrite;
   KpixBunchTrain     *train;
   KpixSample         *sample;
   KpixGuiEventStatus *event;
   KpixGuiEventError  *error;
   KpixGuiEventData   *data;
   bool               runCmd, enPlot, enRaw;
   double             bMin, bMax;
   unsigned int       iters, rate, triggers;
   stringstream       temp, temp2;
   unsigned int       *kpixIdxLookup;
   unsigned int       maxAddress;
   int                kpixIdx, kpixAddr, chan, bucket, range;
   struct timeval     curTime, prvTime, acqTime;
   KpixHistogram      **histR0;
   KpixHistogram      **histR1;
   TH1F               *plot[32];
   TH1F               *cHist;
   KpixCalibRead      *calData;
   double             tempIcept;
   double             tempSigma;
   double             tempRms;
   double             *chGainR0;
   double             *chMeanR0;
   double             *chGainR1;
   double             *chMeanR1;
   unsigned int       gain;
   unsigned int       netCount;
   string             calString;
   bool               paused;
   KpixGuiRunNetwork  *network;
   double             **eventVars;
   double             *eventCmd;
   unsigned int       eventCnt;
   string             status;
   string             delError;
   unsigned int       rateLimit;
   unsigned long      diff, secUs;

   // Figure out which gain we are running in
   gain = 0;
   if ( asic[0]->getCntrlForceLowGain(false) ) gain = 2;
   if ( asic[0]->getCntrlDoubleGain(false) ) gain = 1;

   // Update Display
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusStart,"Starting");
   QApplication::postEvent(this,event);

   // Store Plots?
   enPlot = enablePlots->isChecked();

   // Store Raw Data
   enRaw = enableRawData->isChecked();

   // Get rate limit
   rateLimit = parent->getRateLimit();

   // Determine run type
   if ( runCommand->currentItem() == 0 ) runCmd = false;
   else runCmd = true;

   // Create network port if enabled
   if ( netEnable->isChecked() ) network = new KpixGuiRunNetwork(netPort->text().toInt());
   else network = NULL;

   // Create index lookup table
   maxAddress = 0; 
   for (x=0; x < asicCnt; x++) if ( asic[x]->getAddress() > maxAddress ) maxAddress = asic[x]->getAddress();
   kpixIdxLookup = (unsigned int *)malloc((maxAddress+1)*sizeof(unsigned int));     
   if ( kpixIdxLookup == NULL ) throw(string("KpixGuiRun::run -> Malloc Error"));
   for (x=0; x < asicCnt; x++) kpixIdxLookup[asic[x]->getAddress()] = x;

   // Total progress 
   gettimeofday(&curTime, NULL); 
   prvTime.tv_sec  = curTime.tv_sec - 100;
   prvTime.tv_usec = 0;
   acqTime.tv_sec  = curTime.tv_sec - 100;
   acqTime.tv_usec = 0;
   iters    = 0;
   rate     = 0;
   triggers = 0;

   // Don't show status box
   gStyle->SetOptStat(kFALSE);

   // Create tracking histograms
   if ( enPlot ) {
      histR0 = (KpixHistogram **) malloc(sizeof(KpixHistogram *) * (asicCnt-1) * 4096);
      histR1 = (KpixHistogram **) malloc(sizeof(KpixHistogram *) * (asicCnt-1) * 4096);
      if ( histR0 == NULL || histR1 == NULL ) throw(string("KpixGuiRun::run -> Malloc Error"));
      for (x=0; x< (asicCnt-1); x++) {
         for (y=0; y< 4096; y++) {
            histR0[x*4096+y] = NULL;
            histR1[x*4096+y] = NULL;
         }
      }
   }
   else {
      histR0 = NULL;
      histR1 = NULL;
   }

   try {

      // Load Calibration Constants
      if ( calFile != "" ) {
         calData = new KpixCalibRead(calFile);
         calString = calData->kpixRunRead->getRunCalib();
         if ( calString == "" ) calString = calData->kpixRunRead->getRunTime();
      }
      else {
         calString = "";
         calData = NULL;
      }
   } catch ( string errorMsg ) {
      cout << "Error opening calibration file: " << calFile << "\n";
      calString = "";
      calData = NULL;
   }


   chGainR0  = NULL;
   chMeanR0  = NULL;
   chGainR1  = NULL;
   chMeanR1  = NULL;
   eventCnt  = 0;
   eventVars = NULL;
   eventCmd  = NULL;
   try {

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite (outDataFile,"run",desc,calString);
      gErrorIgnoreLevel = 5000; 
      for (x=0; x<asicCnt; x++) kpixRunWrite->addAsic ( asic[x] );
      kpixRunWrite->addFpga ( fpga );
      delError = "";

      try {

         // Load Calibration Constants
         if ( calFile != "" ) {

            // Update status display
            event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusMsg,"Copying Calibration Data");
            QApplication::postEvent(this,event);

            // Copy calibrations data to the new file
            calData->copyCalibData ( kpixRunWrite->treeFile, "Force_Trig",asic,asicCnt);

            // Update status display
            event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusMsg,"Loading Calibration Constants");
            QApplication::postEvent(this,event);

            // Only load cal constants if plots are enabled
            if ( enPlot ) {

               // Storage for constants
               chGainR0 = (double *) malloc(sizeof(double) * (asicCnt-1) * 4096);
               chMeanR0 = (double *) malloc(sizeof(double) * (asicCnt-1) * 4096);
               chGainR1 = (double *) malloc(sizeof(double) * (asicCnt-1) * 4096);
               chMeanR1 = (double *) malloc(sizeof(double) * (asicCnt-1) * 4096);
               if ( chGainR0 == NULL || chMeanR0 == NULL || chGainR1 == NULL || chMeanR1 == NULL )
                  throw(string("KpixGuiRun::run -> Malloc Error"));
       
               // Load the constants
               for (x=0; x< (asicCnt-1); x++) {
                  for (y=0; y< 1024; y++) {
                     for (z=0; z< 4; z++) {
       
                        // Load range 0 gain if not in force low gain mode
                        if ( gain != 2 ) {
                           calData->getCalibData ( &(chGainR0[x*4096+y*4+z]), &tempIcept,
                                                   "Force_Trig", gain, asic[x]->getSerial(), y, z);
                           calData->getHistData ( &(chMeanR0[x*4096+y*4+z]), &tempSigma, &tempRms,
                                                   "Force_Trig", gain, asic[x]->getSerial(), y, z);
                        }
                        else {
                           chGainR0[x*4096+y*4+z] = 0;
                           chMeanR0[x*4096+y*4+z] = 0;
                        }

                        // Load range 1 if in normal mode or force low gain mode
                        if ( gain != 1 ) {
                           calData->getCalibData ( &(chGainR1[x*4096+y*4+z]), &tempIcept,
                                                   "Force_Trig", 2, asic[x]->getSerial(), y, z);
                           calData->getHistData ( &(chMeanR1[x*4096+y*4+z]), &tempSigma, &tempRms,
                                                   "Force_Trig", 2, asic[x]->getSerial(), y, z);
                        }
                        else {
                           chGainR1[x*4096+y*4+z] = 0;
                           chMeanR1[x*4096+y*4+z] = 0;
                        }
                     }
                  }
               }
            }
            else {
               chGainR0 = NULL;
               chMeanR0 = NULL;
               chGainR1 = NULL;
               chMeanR1 = NULL;
            }
         }
         else {
            chGainR0 = NULL;
            chMeanR0 = NULL;
            chGainR1 = NULL;
            chMeanR1 = NULL;
         }

         if ( calData != NULL ) delete calData;

         // Add run variables
         for (x=0; x< runVarCount; x++) kpixRunWrite->addRunVar ( runVars[x]->name(), runVars[x]->description(),
                                                                  runVars[x]->value());

         // Create run variable list
         eventCnt = eventTable->numRows();
         eventVars = (double **) malloc(sizeof(double *)*eventCnt);
         eventCmd  = (double *) malloc(sizeof(double)*eventCnt);
         if ( eventVars == NULL ) throw(string("KpixGuiRun::run -> Malloc Error"));

         // Add event variables
         for (x=0; x< eventCnt; x++) {
            if ( eventTable->text(x,0) != "" ) {
               kpixRunWrite->addEventVar (eventTable->text(x,0).ascii(),
                                          eventTable->text(x,2).ascii(),
                                          eventTable->text(x,1).toDouble());

            }
            eventVars[x] = (double *)malloc(sizeof(double));
            eventCmd[x] = eventTable->text(x,1).toDouble();
            if ( eventVars[x] == NULL ) throw(string("KpixGuiRun::run -> Malloc Error"));
         }

         // Update status display
         event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusMsg,"Running");
         QApplication::postEvent(this,event);

         // Do run stuff here
         paused=false;
         netCount = 0;
         status = "";
         while ( enRun ) {

            // Detect new pause
            if ( pRun ) {
               event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPause,"Paused",iters,0,triggers);
               QApplication::postEvent(this,event);
               paused=true;
            }

            // In Pause
            while ( pRun && enRun ) usleep(1);

            // Leaving Pause
            if ( paused ) {
               event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusResume,"Running",iters,0,triggers);
               QApplication::postEvent(this,event);
               paused=false;

               // Update event variables
               for (x=0; x < (unsigned int)eventTable->numRows(); x++ ) {
                  if ( eventTable->text(x,0) != "" )
                     kpixRunWrite->setEventVar(eventTable->text(x,0).ascii(),eventTable->text(x,1).toDouble());
               }
            }

            // Possible network stop point
            if ( network != NULL ) {
               
               // Still Running
               if ( netCount > 0 ) netCount--;

               // Wait for new command
               else {

                  // Ack old command
                  network->ackCommand();

                  // Update Status
                  status = network->getStatus();
                  event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusRun,status,iters,0,triggers);
                  QApplication::postEvent(this,event);

                  // Get command and variables from socket
                  while ( (netCount = network->getCommand(eventCmd,eventCnt)) == 0 && enRun ) {
                     if ( network->getStatus() != status ) {
                        status = network->getStatus();
                        event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusRun,status,iters,0,triggers);
                        QApplication::postEvent(this,event);
                     }
                     usleep(1); 
                  }

                  // Net count was valid
                  if ( netCount > 0 ) {
                     for(x=0; x<eventCnt; x++) {
                        *(eventVars[x]) = eventCmd[x];
                        kpixRunWrite->setEventVar(eventTable->text(x,0).ascii(),eventCmd[x]);
                     }
                     data = new KpixGuiEventData(KPRG_DOUBLE,eventCnt,(void **)eventVars);
                     QApplication::postEvent(this,data);
                  }
                  netCount--;
               }
            }

            // Skip Last Run If Stopped
            if ( enRun ) {

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

               // Send start command
               if ( runCmd ) asic[0]->cmdCalibrate(true);
               else asic[0]->cmdAcquire(true);
               iters++;

               // Get bunch train data
               train = new KpixBunchTrain ( asic[0]->getSidLink(), false );

               // Add sample to run
               if ( enRaw ) kpixRunWrite->addBunchTrain(train);

               // Plots Enabled
               if ( enPlot ) {

                  // Process samples
                  for (x=0; x < train->getSampleCount(); x++) {
                     sample   = train->getSampleList()[x];
                     kpixAddr = sample->getKpixAddress();
                     chan     = sample->getKpixChannel();
                     bucket   = sample->getKpixBucket();
                     range    = sample->getSampleRange();

                     if ( (unsigned int)kpixAddr > maxAddress )
                        throw(string("KpixGuiRun::run -> Data Received From Unkown KPIX Address"));

                     kpixIdx  = kpixIdxLookup[kpixAddr];
                     idx = kpixIdx*4096+chan*4+bucket;

                     // Fill full run histogram
                     if ( range == 0 ) {
                        if ( histR0[idx] == NULL ) histR0[idx] = new KpixHistogram();
                        histR0[idx]->fill(sample->getSampleValue());
                     } else {
                        if ( histR1[idx] == NULL ) histR1[idx] = new KpixHistogram();
                        histR1[idx]->fill(sample->getSampleValue());
                     }
                  }
               }
               if ( train->getSampleCount() > 0 ) triggers++;
               delete train;
            }

            // Report progress every second, force update if we will wait for network on next cycle
            if ( (curTime.tv_sec - prvTime.tv_sec) >= 1 || (network != NULL && netCount == 0) || pRun || !enRun ) {
               cout << "\r";
               cout << "Iterations=" << dec << setw(4) << setfill('0') << iters;
               cout << ", Rate="  << rate << " Hz";
               cout << ", Triggers="  << triggers; 
               cout << flush;
               prvTime.tv_sec = curTime.tv_sec;

               // Generate status
               temp.str("");
               temp << "Running - ";
               if ( gain == 0 ) temp << "Normal Gain";
               else if ( gain == 1 ) temp << "Double Gain";
               else temp << "Low Gain";

               // Status Update
               event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusRun,temp.str(),iters,rate,triggers);
               QApplication::postEvent(this,event);
               rate = 0;

               // Look through plots list
               if ( enPlot ) {
                  for (x=0; x < 16; x++) {

                     // Plot is enabled 
                     if ( dispKpix[x] >= 0 && dispChan[x] >= 0 && dispBucket[x] >= 0 ) {
                        idx = dispKpix[x]*4096+dispChan[x]*4+dispBucket[x];

                        // Range 0 Plot
                        if ( histR0[idx] != NULL ) {
                           temp.str("");
                           temp << "h0" << dec << setw(1) << x;
                           temp2.str("");
                           temp2 << "Charge Histogram, Kpix=" << asic[dispKpix[x]]->getSerial();
                           temp2 << ", Channel=" << dispChan[x];
                           temp2 << ", Bucket=" << dispBucket[x];
                           temp2 << ", Range=0";

                           // Convert end points to charge with calibration constants
                           if ( chGainR0 != NULL && chGainR0[idx] != 0 ) {
                              bMin = (histR0[idx]->minValue()-chMeanR0[idx]) / chGainR0[idx];
                              bMax = ((histR0[idx]->maxValue()+1)-chMeanR0[idx]) / chGainR0[idx];
                           }
                           else {
                              bMin = histR0[idx]->minValue();
                              bMax = histR0[idx]->maxValue()+1;
                           }

                           // Create Plot
                           plot[x*2] = new TH1F(temp.str().c_str(),temp2.str().c_str(),histR0[idx]->binCount(),bMin,bMax);
                           plot[x*2]->SetDirectory(0);
                           plot[x*2]->SetLineColor(4);

                           // Add values
                           for (y=0; y < histR0[idx]->binCount(); y++) {
                              plot[x*2]->SetBinContent(y+1,histR0[idx]->count(y));
                           }
                        }
                        else plot[x*2] = NULL;

                        // Range 1 Plot
                        if ( histR1[idx] != NULL ) {
                           temp.str("");
                           temp << "h1" << dec << setw(1) << x;
                           temp2.str("");
                           temp2 << "Charge Histogram, Kpix=" << asic[dispKpix[x]]->getSerial();
                           temp2 << ", Channel=" << dispChan[x];
                           temp2 << ", Bucket=" << dispBucket[x];
                           temp2 << ", Range=1";

                           // Convert end points to charge with calibration constants
                           if ( chGainR1 != NULL && chGainR1[idx] != 0 ) {
                              bMin = (histR1[idx]->minValue()-chMeanR1[idx]) / chGainR1[idx];
                              bMax = ((histR1[idx]->maxValue()+1)-chMeanR1[idx]) / chGainR1[idx];
                           }
                           else {
                              bMin = histR1[idx]->minValue();
                              bMax = histR1[idx]->maxValue()+1;
                           }

                           // Create Plot
                           plot[x*2+1] = new TH1F(temp.str().c_str(),temp2.str().c_str(),histR1[idx]->binCount(),bMin,bMax);
                           plot[x*2+1]->SetDirectory(0);
                           plot[x*2+1]->SetLineColor(3);

                           // Add values
                           for (y=0; y < histR1[idx]->binCount(); y++) {
                              plot[x*2+1]->SetBinContent(y+1,histR1[idx]->count(y));
                           }
                        }
                        else plot[x*2+1] = NULL;
                     }
                     else {
                        plot[x*2]   = NULL;
                        plot[x*2+1] = NULL;
                     }
                  }

                  // Pass Plots
                  data = new KpixGuiEventData(KPRG_TH1F,32,(void **)plot);
                  QApplication::postEvent(this,data);
               }
            } else rate++;
         } // Run stopped

      } catch ( string errorMsg ) { delError = errorMsg; }

      // Status Update
      event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusRun,"Storing Histograms",iters,0,triggers);

      QApplication::postEvent(this,event);

      // Store histograms
      if ( enPlot ) {

         // Set Directory
         kpixRunWrite->setDir("RunPlots");

         // Create channel histograms
         for (x=0; x< (asicCnt-1); x++) {
            for (y=0; y< 1024; y++) {
               for (r=0; r< 4; r++) {
                  idx = x*4096+y*4+r;

                  // Range 0
                  if ( histR0[idx] != NULL ) {

                     // Create Raw histogram
                     temp.str("");
                     temp << "hist_raw_s" << dec << setw(4) << setfill('0') << asic[x]->getSerial();
                     temp << "_c" << dec << setw(4) << setfill('0') << y;
                     temp << "_b" << dec << setw(1) << setfill('0') << r;
                     temp << "_r0";
                     temp2.str("");
                     temp2 << "Raw Histogram, Kpix=" << asic[x]->getSerial();
                     temp2 << ", Channel=" << y;
                     temp2 << ", Bucket="  << r;
                     temp2 << ", Range=0";
                     cHist = new TH1F(temp.str().c_str(),temp2.str().c_str(),
                                      histR0[idx]->binCount(),
                                      histR0[idx]->minValue(),
                                      histR0[idx]->maxValue()+1);
                     cHist->SetDirectory(0);
                     cHist->SetLineColor(4);
                     for (z=0; z < histR0[idx]->binCount(); z++) 
                        cHist->SetBinContent(z+1,histR0[idx]->count(z));
                     cHist->Write();
                     delete cHist;

                     // Create Charge histogram
                     temp.str("");
                     temp << "hist_charge_s" << dec << setw(4) << setfill('0') << asic[x]->getSerial();
                     temp << "_c" << dec << setw(4) << setfill('0') << y;
                     temp << "_b" << dec << setw(1) << setfill('0') << r;
                     temp << "_r0";
                     temp2.str("");
                     temp2 << "Charge Histogram, Kpix=" << asic[x]->getSerial();
                     temp2 << ", Channel=" << y;
                     temp2 << ", Bucket="  << r;
                     temp2 << ", Range=0";

                     // Convert to charge with calibration constants
                     if ( chGainR0 != NULL && chGainR0[idx] != 0 ) {
                        bMin = (histR0[idx]->minValue() - chMeanR0[idx]) / chGainR0[idx];
                        bMax = ((histR0[idx]->maxValue()+1) - chMeanR0[idx]) / chGainR0[idx];
                     }
                     else {
                        bMin = histR0[idx]->minValue();
                        bMax = histR0[idx]->maxValue()+1;
                     }

                     // Create new plot
                     cHist = new TH1F(temp.str().c_str(),temp2.str().c_str(),histR0[idx]->binCount(),bMin,bMax);
                     cHist->SetDirectory(0);
                     cHist->SetLineColor(4);

                     // Add values
                     for (z=0; z < histR0[idx]->binCount(); z++) {
                        cHist->SetBinContent(z+1,histR0[idx]->count(z));
                     }
                     cHist->Write();
                     delete cHist;
                     delete histR0[idx];
                  }

                  // Range 1
                  if ( histR1[idx] != NULL ) {

                     // Create Raw histogram
                     temp.str("");
                     temp << "hist_raw_s" << dec << setw(4) << setfill('0') << asic[x]->getSerial();
                     temp << "_c" << dec << setw(4) << setfill('0') << y;
                     temp << "_b" << dec << setw(1) << setfill('0') << r;
                     temp << "_r1";
                     temp2.str("");
                     temp2 << "Raw Histogram, Kpix=" << asic[x]->getSerial();
                     temp2 << ", Channel=" << y;
                     temp2 << ", Bucket="  << r;
                     temp2 << ", Range=1";
                     cHist = new TH1F(temp.str().c_str(),temp2.str().c_str(),
                                      histR1[idx]->binCount(),
                                      histR1[idx]->minValue(),
                                      histR1[idx]->maxValue()+1);
                     cHist->SetDirectory(0);
                     cHist->SetLineColor(3);
                     for (z=0; z < histR1[idx]->binCount(); z++) 
                        cHist->SetBinContent(z+1,histR1[idx]->count(z));
                     cHist->Write();
                     delete cHist;

                     // Create Charge histogram
                     temp.str("");
                     temp << "hist_charge_s" << dec << setw(4) << setfill('0') << asic[x]->getSerial();
                     temp << "_c" << dec << setw(4) << setfill('0') << y;
                     temp << "_b" << dec << setw(1) << setfill('0') << r;
                     temp << "_r1";
                     temp2.str("");
                     temp2 << "Charge Histogram, Kpix=" << asic[x]->getSerial();
                     temp2 << ", Channel=" << y;
                     temp2 << ", Bucket="  << r;
                     temp2 << ", Range=1";

                     // Convert to charge with calibration constants
                     if ( chGainR1 != NULL && chGainR1[idx] != 0 ) {
                        bMin = (histR1[idx]->minValue() - chMeanR1[idx]) / chGainR1[idx];
                        bMax = ((histR1[idx]->maxValue()+1) - chMeanR1[idx]) / chGainR1[idx];
                     }
                     else {
                        bMin = histR1[idx]->minValue();
                        bMax = histR1[idx]->maxValue()+1;
                     }

                     // Create new plot
                     cHist = new TH1F(temp.str().c_str(),temp2.str().c_str(),histR1[idx]->binCount(),bMin,bMax);
                     cHist->SetDirectory(0);
                     cHist->SetLineColor(3);

                     // Add values
                     for (z=0; z < histR1[idx]->binCount(); z++) {
                        cHist->SetBinContent(z+1,histR1[idx]->count(z));
                     }
                     cHist->Write();
                     delete cHist;
                     delete histR1[idx];
                  }
               }
            }
         }
         free(histR0);
         free(histR1);

         // Set Directory
         kpixRunWrite->setDir("/");
      }

      // Cleanup
      for (x=0; x< eventCnt; x++) free(eventVars[x]);
      free(eventVars);
      free(eventCmd);
      if ( chGainR0 != NULL ) free(chGainR0);
      if ( chMeanR0 != NULL ) free(chMeanR0);
      if ( chGainR1 != NULL ) free(chGainR1);
      if ( chMeanR1 != NULL ) free(chMeanR1);
      free(kpixIdxLookup);
      delete kpixRunWrite;

      // Log
      cout << endl << "Wrote Data To: " << outDataDir << "\n";

   } catch ( string errorMsg ) { delError = errorMsg; }

   if ( delError != "" ) {
      error = new KpixGuiEventError(delError);
      QApplication::postEvent(this,error);
   }

   // Close network
   if ( network != NULL ) delete network;

   // Update status display
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusDone,"Done");
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiRun::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError  *eventError;
   KpixGuiEventStatus *eventStatus;
   KpixGuiEventData   *eventPlots;
   unsigned int       x,y,z, count, divx, divy, idx;
   stringstream       temp;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_STATUS ) {
      eventStatus = (KpixGuiEventStatus *)event;

      // Status Type
      switch (eventStatus->statusType) {

         // Run is starting
         case KpixGuiEventStatus::StatusStart:
            status->setText(eventStatus->statusMsg);
            liveDisplay->GetCanvas()->Clear();
            liveDisplay->GetCanvas()->Update();
            break;

         // Run is Stopping
         case KpixGuiEventStatus::StatusDone:

            // Delete run variables
            for (x=0; x< runVarCount; x++) delete runVars[x];
            if ( runVarCount != 0 ) free(runVars);

            // Update flags
            isRunning = false;

            // Read back settings
            parent->readConfig_pressed();
            break;

         // Run Pause
         case KpixGuiEventStatus::StatusPause:
            eventTable->setColumnReadOnly(1,false);
            break;
 
         // Run Resume
         case KpixGuiEventStatus::StatusResume:
            eventTable->setColumnReadOnly(1,false);
            break;

         // Run Update
         case KpixGuiEventStatus::StatusRun:
            status->setText(eventStatus->statusMsg);
            temp.str("");
            temp << eventStatus->iterations;
            iterCount->setText(temp.str());
            temp.str("");
            temp << eventStatus->rate;
            rateCount->setText(temp.str());
            temp.str("");
            temp << eventStatus->triggers;
            trigCount->setText(temp.str());
            break;

         // Message Update
         case KpixGuiEventStatus::StatusMsg:
            status->setText(eventStatus->statusMsg);
            break;
      }

      // Clear plot selections
      for (x=0; x< 16; x++) {
         dispKpix[x] = -1;
         dispChan[x] = -1;
      }

      // Update plot selections
      count = 0;
      idx = 0;
      if ( asicCnt > 1 ) for (x=0; x < (asicCnt-1); x++) {
         for (y=0; y < asic[x]->getChCount(); y++) {
            for (z=0; z < 4; z++) {
               if ( chanSel->isSelected(count) && idx < 16) {
                  dispKpix[idx] = x;
                  dispChan[idx] = y;
                  dispBucket[idx] = z;
                  idx++;
               }
               count++;
            }
         }
      }
      update();
   }

   // Error Event
   if ( event->type() == KPIX_GUI_EVENT_ERROR ) {
      eventError = (KpixGuiEventError *)event;
      errorMsg->showMessage(eventError->errorMsg);
      update();
   }

   // Plot Update
   if ( event->type() == KPIX_GUI_EVENT_DATA ) {
      eventPlots = (KpixGuiEventData *)event;

      // Variables
      if ( eventPlots->id == KPRG_DOUBLE ) {
         for (x=0; x<eventPlots->count; x++) {
            temp.str("");
            temp << *((double *)(eventPlots->data[x]));
            eventTable->setText(x,1,temp.str());
            update();
         }
      } 

      // Plot Data
      else {

         // Update Display
         liveDisplay->GetCanvas()->Clear();

         // Delete old plots
         for (x=0; x<32; x++) {
            if ( plots[x] != NULL ) delete plots[x];
            plots[x] = NULL;
         }

         // Copy New Plots
         count = 0;
         if ( eventPlots->id == KPRG_TH1F ) {
            for (x=0; x<16; x++) {
               plots[x*2] = (TH1F *)eventPlots->data[x*2];
               plots[x*2+1] = (TH1F *)eventPlots->data[x*2+1];
               if ( plots[x*2] != NULL || plots[x*2+1] != NULL ) count++;
            }
         }
         else throw(string("KpixGuiRun::customEvent -> Invalid Plot Type"));

         // Determine number of cols/rows
         if ( count >= 12 ) {divx=4; divy=4; }
         else if ( count >= 10 ) {divx=3; divy=4; }
         else if ( count >= 7  ) {divx=3; divy=3; }
         else if ( count >= 5  ) {divx=2; divy=3; }
         else if ( count >= 3  ) {divx=2; divy=2; }
         else if ( count >= 2  ) {divx=1; divy=2; }
         else {divx=1; divy=1; }

         // Divide Canvas
         liveDisplay->GetCanvas()->Divide(divx,divy,.01,.01);

         // Draw Plots
         count = 0;
         for (x=0; x<16; x++) {
            if ( plots[x*2] != NULL || plots[x*2+1] != NULL ) {
               count++;
               liveDisplay->GetCanvas()->cd(count);
               if ( logScale->isChecked() ) liveDisplay->GetCanvas()->cd(count)->SetLogy();
               if ( plots[x*2] != NULL ) {
                  plots[x*2]->Draw();
                  if ( plots[x*2+1] != NULL ) plots[x*2+1]->Draw("same");
               }
               else if ( plots[x*2+1] != NULL ) plots[x*2+1]->Draw();
            }
         }
         liveDisplay->GetCanvas()->Update();
      }
   }
}


void KpixGuiRun::closeEvent(QCloseEvent *e) {
   if ( isRunning ) e->ignore();
   else {
      if ( runView != NULL ) delete runView;
      runView = NULL;
      e->accept();
   }
}


bool KpixGuiRun::close() { return(KpixGuiRunForm::close()); }


void KpixGuiRun::addEvent_pressed() {
   unsigned int count;
   stringstream temp;

   // Get current count
   count = eventTable->numRows();

   // Create default Name
   temp.str("");
   temp << "new_var_" << count;

   // Add new column
   eventTable->insertRows(count);

   // Set defaults
   eventTable->setText(count,0,temp.str());
   eventTable->setText(count,1,"0.0");
   eventTable->setText(count,2,"New Variable");
}


void KpixGuiRun::delEvent_pressed() {
   eventTable->removeRow(eventTable->currentRow());
}

