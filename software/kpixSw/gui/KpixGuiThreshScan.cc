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
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
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
#include <qpushbutton.h>
#include <qspinbox.h>
#include <TQtWidget.h>
#include <qcheckbox.h>
#include <TH2F.h>
#include <KpixAsic.h>
#include <SidLink.h>
#include <KpixFpga.h>
#include <KpixRunVar.h>
#include <KpixRunWrite.h>
#include <KpixThreshScan.h>
#include "KpixGuiThreshScan.h"
#include "KpixGuiThreshView.h"
#include "KpixGuiTop.h"
#include "KpixGuiError.h"
#include "KpixGuiEventData.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventStatus.h"
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
   tarBucket->setEnabled(enable);
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
      chanMin->setMaxValue ( asic[0]->getChCount()-1 );
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
   parent->setEnabled(false);
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
   unsigned int       x;
   KpixThreshScan     *kpixThreshScan;
   KpixRunWrite       *kpixRunWrite;
   stringstream       temp;
   KpixGuiEventStatus *event;
   KpixGuiEventError  *error;
   string             delError;
   unsigned int       mainProgress;
   unsigned int       mainTotal;

   // Progress
   mainProgress = 0;
   mainTotal   = (chanMax->value()-chanMin->value()) + 1;

   // Update status display
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusStart,"Starting");
   QApplication::postEvent(this,event);

   kpixThreshScan = NULL;
   try {

      fpga->setRunEnable(false);

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite (outDataFile,"thresh_scan",desc);
      for (x=0; x<asicCnt; x++) kpixRunWrite->addAsic ( asic[x] );
      kpixRunWrite->addFpga ( fpga );
      delError = "";

      try {

         // Add run variables, skip names that will be generated by threshold scanning class
         for (x=0; x< runVarCount; x++) {
            if ( runVars[x]->name() != "threshCount" && runVars[x]->name() != "calenable" && 
                 runVars[x]->name() != "calStart" && runVars[x]->name() != "calEnd" && 
                 runVars[x]->name() != "calStep" && runVars[x]->name() != "threshOffset" ) {
               kpixRunWrite->addRunVar ( runVars[x]->name(),
                                         runVars[x]->description(),
                                         runVars[x]->value());
             }
         }

         // Create & Setup Threshold Scan
         kpixThreshScan = new KpixThreshScan(asic,asicCnt,kpixRunWrite);
         kpixThreshScan->setCalibEn     ( calibEn->isChecked() );
         kpixThreshScan->setCalibRange  ( calMax->value(), calMin->value(), calStep->value());
         kpixThreshScan->setThreshRange ( threshMax->value(), threshMin->value(), threshStep->value());
         kpixThreshScan->setThreshCount ( threshCount->value() );
         kpixThreshScan->setPreTrigger  ( preTrigger->value() );
         kpixThreshScan->setBucket      ( tarBucket->value() );
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
               event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,temp.str(),mainProgress,mainTotal);
               QApplication::postEvent(this,event);

               // Run Threshold Scan
               kpixThreshScan->runThreshold ( x );
               mainProgress++;
            }
         }
      } catch ( string errorMsg ) { delError = errorMsg; }

      // Cleanup
      delete kpixThreshScan;
      delete kpixRunWrite;

      // Log
      cout << "Wrote Data To: " << outDataDir << "\n";

   } catch ( string errorMsg ) { delError = errorMsg; }

   if ( delError != "" ) {
      error = new KpixGuiEventError(delError);
      QApplication::postEvent(this,error);
   }

   // Update status display
   try { fpga->setRunEnable(false); } catch (string error) {}
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusDone,"Done");
   QApplication::postEvent(this,event);
}


// Update progress callback
void KpixGuiThreshScan::updateProgress(unsigned int count, unsigned int total) {
   KpixGuiEventStatus *event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgSub,count,total);
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiThreshScan::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError  *eventError;
   KpixGuiEventStatus *eventStatus;
   KpixGuiEventData   *eventData;
   unsigned int       x;

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

            // Clear progress bars
            runProgress->setProgress(-1,0);
            totProgress->setProgress(-1,0);

            // Read back settings
            parent->readConfig_pressed();
            break;

         // Main progress update
         case KpixGuiEventStatus::StatusPrgMain:
            runProgress->setProgress(-1,0);
            totProgress->setProgress(eventStatus->prgValue,eventStatus->prgTotal);
            status->setText(eventStatus->statusMsg);
            break;

         // Sub progress update
         case KpixGuiEventStatus::StatusPrgSub:
            runProgress->setProgress(eventStatus->prgValue,eventStatus->prgTotal);
            break;
      }
   }

   // Error Event
   if ( event->type() == KPIX_GUI_EVENT_ERROR ) {
      asic[0]->getSidLink()->linkFlush();
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
      if ( eventData->count > 0 && eventData->id == KpixDataTH2F ) 
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
   sleep(1);
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
