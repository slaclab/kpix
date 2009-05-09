//-----------------------------------------------------------------------------
// File          : KpixGuiThreshScan.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC threshold scan.
// This is a class which builds off of the class created in
// KpixGuiThreshScanForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <KpixThreshScan.h>
#include "KpixGuiThreshScan.h"
#include "KpixGuiTop.h"
using namespace std;


// Constructor
KpixGuiThreshScan::KpixGuiThreshScan ( KpixGuiTop *parent ) : KpixGuiThreshScanForm() {

   this->asicCnt = 0;
   this->fpga    = NULL;
   this->asic    = NULL;
   this->parent  = parent;
   isRunning     = false;

   // Create error window
   errorMsg = new KpixGuiError(this);

   // Plot
   plot = NULL;

   // Run Flags
   running = false;
   enRun   = false;

   // Thresh Viewer
   threshView = NULL;

   // Default status
   status->setText("Idle");
}


// Delete
KpixGuiThreshScan::~KpixGuiThreshScan ( ) {
   unsigned int x;
   for (x=0; x< runVarCount; x++) delete runVars[x];
   if ( plot != NULL ) delete plot;
   if ( threshView != NULL ) delete threshView;
}


// Control Enable Of Buttons/Edits
void KpixGuiThreshScan::setEnabled ( bool enable ) {
   enNormalGain->setEnabled(enable);
   enDoubleGain->setEnabled(enable);
   enLowGain->setEnabled(enable);
   threshCount->setEnabled(enable);
   preTrigger->setEnabled(enable);
   calMin->setEnabled(enable);
   calMax->setEnabled(enable);
   calStep->setEnabled(enable);
   calibEn->setEnabled(enable);
   chanMin->setEnabled(enable);
   chanMax->setEnabled(enable);
   threshMin->setEnabled(enable);
   threshMax->setEnabled(enable);
   threshStep->setEnabled(enable);
   verbose->setEnabled(enable);
   runTest->setEnabled(enable);
   stopTest->setEnabled(true);
   closeWindow->setEnabled(enable);
   enableRawData->setEnabled(enable);
   enablePlots->setEnabled(enable);
   if ( outDataFile == "" ) viewPlots->setEnabled(false);
   else viewPlots->setEnabled(enable);
}


// Set Asics
void KpixGuiThreshScan::setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga ) {
   this->asicCnt = asicCnt;
   this->asic    = asic;
   this->fpga    = fpga;

   // Update Spin Box
   if ( asicCnt > 0 ) {
      chanMax->setMaxValue ( asic[0]->getChCount()-1 );
      chanMax->setValue ( asic[0]->getChCount()-1 );
   }
}


// Run 
void KpixGuiThreshScan::runTest_pressed ( ) {

   stringstream temp;
   unsigned int x,fd;

   // Get Config Data
   baseDir = parent->getBaseDir();
   desc    = parent->getRunDescription();
   runVars = parent->getRunVarList(&runVarCount);

   // Generate directory name based on time
   temp.str("");
   temp << baseDir << "/" << KpixRunWrite::genTimestamp() << "_" << "thresh_scan";
   outDataDir = temp.str();
   mkdir (outDataDir.c_str(),0755);
   dataDir->setText(outDataDir);

   // Generate File Name
   temp.str("");
   temp << outDataDir << "/" << "thresh_scan.root";
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
   enRun = true;
   QThread::start();
}


// Stop
void KpixGuiThreshScan::stopTest_pressed ( ) {
   stopTest->setEnabled(false);
   enRun = false;
   status->setText("Stopping At Next Break Point");
   update();
}


// Thread for register test
void KpixGuiThreshScan::run() {
   unsigned int      x;
   KpixThreshScan    *kpixThreshScan;
   KpixRunWrite      *kpixRunWrite;
   stringstream      temp;
   KpixGuiEventRun   *event;
   KpixGuiEventError *error;

   // Progress
   prgCurrent = 0;
   prgTotal   = (chanMax->value()-chanMin->value()) + 1;

   // Update status display
   event = new KpixGuiEventRun(true,false,"Starting",0,100,0,100);
   QApplication::postEvent(this,event);

   try {

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite (outDataFile,"thresh_scan",desc);
      for (x=0; x<asicCnt; x++) kpixRunWrite->addAsic ( asic[x] );
      kpixRunWrite->addFpga ( fpga );

      // Add run variables
      for (x=0; x< runVarCount; x++)
         kpixRunWrite->addRunVar ( runVars[x]->name(),
                                   runVars[x]->description(),
                                   runVars[x]->value());

      // Create & Setup Threshold Scan
      kpixThreshScan = new KpixThreshScan(asic,asicCnt,kpixRunWrite);
      kpixThreshScan->setCalibEn     ( calibEn->isChecked() );
      kpixThreshScan->setCalibRange  ( calMax->value(), calMin->value(), calStep->value());
      kpixThreshScan->setThreshRange ( threshMax->value(), threshMin->value(), threshStep->value());
      kpixThreshScan->setThreshCount ( threshCount->value() );
      kpixThreshScan->setPreTrigger  ( preTrigger->value() );
      kpixThreshScan->enNormalGain   ( enNormalGain->isChecked());
      kpixThreshScan->enDoubleGain   ( enDoubleGain->isChecked());
      kpixThreshScan->enLowGain      ( enLowGain->isChecked());
      kpixThreshScan->threshDebug    ( verbose->isChecked());
      kpixThreshScan->enableRawData  ( enableRawData->isChecked());
      kpixThreshScan->enablePlots    ( enablePlots->isChecked());
      kpixThreshScan->setPlotDir     ("ThreshScan");
      kpixThreshScan->setKpixProgress(this);

      // Run calibration once for each channel
      for (x=chanMin->value(); x <= (unsigned int)chanMax->value(); x++) { 
         if ( enRun ) {

            // Generate New Status
            temp.str("");
            temp << "Running Threshold Scan, ";
            temp << "Channel " << dec << setw(2) << setfill(' ') << x;
            temp << " Of " << dec << setw(2) << setfill(' ') << chanMax->value();

            // Update status display
            event = new KpixGuiEventRun(false,false,temp.str(),0,100,prgCurrent,prgTotal);
            QApplication::postEvent(this,event);

            // Run Threshold Scan
            kpixThreshScan->runThreshold ( x );
            prgCurrent++;
         }
      }

      // Cleanup
      delete kpixThreshScan;
      delete kpixRunWrite;

      // Log
      cout << "Wrote Data To: " << outDataDir << "\n";
   } catch ( string errorMsg ) {
      error = new KpixGuiEventError(errorMsg);
      QApplication::postEvent(this,error);
   }

   // Update status display
   event = new KpixGuiEventRun(false,true,"Done",100,100,100,100);
   QApplication::postEvent(this,event);
}


// Update progress callback
void KpixGuiThreshScan::updateProgress(unsigned int count, unsigned int total) {
   KpixGuiEventRun *event = new KpixGuiEventRun(false,false,"",count,total,prgCurrent,prgTotal);
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiThreshScan::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError *eventError;
   KpixGuiEventRun   *eventRun;
   KpixGuiEventData  *eventData;
   unsigned int      x;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_RUN ) {
      eventRun = (KpixGuiEventRun *)event;

      // Run is starting
      if ( eventRun->runStart ) {
         parent->setEnabled(false);
         isRunning = true;
      }

      // Run is stopping
      if ( eventRun->runStop ) {
         try {
            parent->readConfig(true);
            parent->readFpgaCounters();
         } catch ( string error ) {
            errorMsg->showMessage(error);
         }

         // Delete run variables
         for (x=0; x< runVarCount; x++) delete runVars[x];
         if ( runVars != NULL ) free(runVars);

         // Enable buttons
         parent->setEnabled(true);
         isRunning = false;
      }
            
      // Update status
      if ( eventRun->statusMsg != "" ) status->setText(eventRun->statusMsg);
      runProgress->setProgress(eventRun->prgCurrent,eventRun->prgTotal);
      totProgress->setProgress(eventRun->totCurrent,eventRun->totTotal);
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
      eventData = (KpixGuiEventData *)event;

      // Update Display
      liveDisplay->GetCanvas()->Clear();

      // Delete plot
      if ( plot != NULL ) delete plot;

      // Copy new plot
      if ( eventData->count > 0 && eventData->id == KPRG_TH2F ) 
         plot = (TH2F*)(eventData->data[0]);

      // Draw Plots
      if ( plot != NULL ) {
         plot->SetStats(false);
         plot->Draw("lego");
      }
      liveDisplay->GetCanvas()->Update();
   }
}


// Upldate Plots
void KpixGuiThreshScan::updateData(unsigned int id, unsigned int count, void **data) {
   KpixGuiEventData *event = new KpixGuiEventData(id,count,data);
   QApplication::postEvent(this,event);
}


void KpixGuiThreshScan::closeEvent(QCloseEvent *e) {
   if ( isRunning ) e->ignore();
   else {
      if ( threshView != NULL ) delete threshView;
      threshView = NULL;
      e->accept();
   }
}


bool KpixGuiThreshScan::close() { return(KpixGuiThreshScanForm::close()); }


void KpixGuiThreshScan::viewPlots_pressed() {
   if ( threshView != NULL ) delete threshView;
   threshView = new KpixGuiThreshView(outDataFile,true);
   threshView->show();
}
