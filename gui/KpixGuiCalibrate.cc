//-----------------------------------------------------------------------------
// File          : KpixGuiCalibrate.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC calibrations.
// This is a class which builds off of the class created in
// KpixGuiCalibrateForm.ui
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
#include <TGraph2D.h>
#include <TMultiGraph.h>
#include <KpixCalDist.h>
#include "KpixGuiCalibrate.h"
#include "KpixGuiTop.h"
using namespace std;


// Constructor
KpixGuiCalibrate::KpixGuiCalibrate ( KpixGuiTop *parent ) : KpixGuiCalibrateForm() {

   unsigned int x;

   this->asicCnt = 0;
   this->fpga    = NULL;
   this->asic    = NULL;
   this->parent  = parent;

   // calibration viewer
   calFit = NULL;

   // Create error window
   errorMsg = new KpixGuiError(this);

   // Run Flags
   enRun = false;
   isRunning = false;

   // Default status
   status->setText("Idle");

   // Update Plots
   for (x=0; x < 16; x++) plots[x]= NULL;
   pType = 0;

   // Init multigraph pointers
   mGraph[0] = NULL;
   mGraph[1] = NULL;

   // Update DAC Values
   dacCalib_valueChanged();
}


// Delete
KpixGuiCalibrate::~KpixGuiCalibrate ( ) {
   unsigned int x;

   if ( mGraph[0] != NULL ) {
      delete mGraph[0]; 
      mGraph[0] = NULL;
      plots[0]  = NULL;
      plots[1]  = NULL;
   }
   if ( mGraph[0] != NULL ) {
      delete mGraph[1]; 
      mGraph[1] = NULL;
      plots[2]  = NULL;
      plots[3]  = NULL;
   }
   for (x=0; x < 16; x++) {
      if ( plots[x] != NULL ) {
         switch (pType) {
            case KPRG_TH1F:   delete ((TH1F *)plots[x]); break;
            case KPRG_TGRAPH: delete ((TGraph *)plots[x]); break;
            default: break;
         }
      }
   }
   for (x=0; x< runVarCount; x++) delete runVars[x];
   if ( calFit != NULL ) delete calFit;
}


// Control Enable Of Buttons/Edits
void KpixGuiCalibrate::setEnabled ( bool enable ) {
   enNormalGain->setEnabled(enable);
   enDoubleGain->setEnabled(enable);
   enLowGain->setEnabled(enable);
   iterations->setEnabled(enable);
   dacCalib->setEnabled(enable);
   distForceTrig->setEnabled(enable);
   distSelfTrig->setEnabled(enable);
   calMin->setEnabled(enable);
   calMax->setEnabled(enable);
   calStep->setEnabled(enable);
   chanMin->setEnabled(enable);
   chanMax->setEnabled(enable);
   calForceTrig->setEnabled(enable);
   calSelfTrig->setEnabled(enable);
   enableRawData->setEnabled(enable);
   enablePlots->setEnabled(enable);
   distCalEn->setEnabled(enable);
   calibAllChannels->setEnabled(enable);
   verbose->setEnabled(enable);
   runTest->setEnabled(enable);
   stopTest->setEnabled(!enable);
   closeWindow->setEnabled(enable);
   if ( outDataFile == "" ) viewCalib->setEnabled(false);
   else viewCalib->setEnabled(enable);
}


// Set Asics
void KpixGuiCalibrate::setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga ) {
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
void KpixGuiCalibrate::runTest_pressed ( ) {

   stringstream temp;
   unsigned int x,fd;

   // Get Config Data
   baseDir = parent->getBaseDir();
   desc    = parent->getRunDescription();
   runVars = parent->getRunVarList(&runVarCount);

   // Generate directory name based on time
   temp.str("");
   temp << baseDir << "/" << KpixRunWrite::genTimestamp() << "_" << "calib_dist";
   outDataDir = temp.str();
   mkdir (outDataDir.c_str(),0755);
   dataDir->setText(outDataDir);

   // Generate File Name
   temp.str("");
   temp << outDataDir << "/" << "calib_dist.root";
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
void KpixGuiCalibrate::stopTest_pressed ( ) {
   stopTest->setEnabled(false);
   enRun = false;
   status->setText("Stopping At Next Break Point");
   update();
}


// Thread for register test
void KpixGuiCalibrate::run() {
   unsigned int      x,y;
   KpixCalDist       *kpixCalDist;
   KpixRunWrite      *kpixRunWrite;
   stringstream      temp;
   KpixGuiEventRun   *event;
   KpixGuiEventError *error;
   unsigned int      calSteps;

   // Update status display
   event = new KpixGuiEventRun(true,false,"Starting",0,100,0,100);
   QApplication::postEvent(this,event);

   // Total progress 
   prgCurrent = 0;
   prgTotal   = 0;
   calSteps   = (chanMax->value()-chanMin->value()) + 1;
   if ( distForceTrig->isChecked() ) prgTotal++;
   if ( distSelfTrig->isChecked() ) prgTotal++;
   if ( calibAllChannels->isChecked() ) {
      if ( calForceTrig->isChecked() ) prgTotal++;
      if ( calSelfTrig->isChecked() ) prgTotal++;
   } else {
      if ( calForceTrig->isChecked() ) prgTotal+= calSteps;
      if ( calSelfTrig->isChecked() ) prgTotal+= calSteps;
   }

   try {

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite (outDataFile,"calib_dist",desc);
      for (x=0; x<asicCnt; x++) kpixRunWrite->addAsic ( asic[x] );
      kpixRunWrite->addFpga ( fpga );

      // Add run variables
      for (x=0; x< runVarCount; x++)
         kpixRunWrite->addRunVar ( runVars[x]->name(),
                                   runVars[x]->description(),
                                   runVars[x]->value());

      // Event variable for forced trigger mode, initially on (set above)
      kpixRunWrite->addEventVar ( "ForceTrig","Force Trigger Status, 0=Dis, 1=En",1.0 );

      // Create Calibration/Dist object
      kpixCalDist = new KpixCalDist(asic,asicCnt,kpixRunWrite);

      // Display calibration status during run
      kpixCalDist->calDistDebug (verbose->isChecked());
      kpixCalDist->setKpixProgress(this);

      // Setup gains to support, Set Fit Range
      kpixCalDist->enNormalGain (enNormalGain->isChecked());
      kpixCalDist->enDoubleGain (enDoubleGain->isChecked());
      kpixCalDist->enLowGain    (enLowGain->isChecked());

      // Setup disribution, Set charge if used
      kpixCalDist->setDistCount  (iterations->value());
      kpixCalDist->setDistCalDac (dacCalib->value());

      // Set calibration range
      kpixCalDist->setCalibRange (calMax->value(),calMin->value(),calStep->value());

      // Plots & Raw Data
      kpixCalDist->enablePlots(enablePlots->isChecked());
      kpixCalDist->enableRawData(enableRawData->isChecked());

      // Forced Trigger Distribution
      if ( enRun && distForceTrig->isChecked() ) {

         // Debug Output
         if ( verbose->isChecked() ) cout << "Forced Trigger Distribution" << endl;

         // Update status display
         event = new KpixGuiEventRun(false,false,"Running Forced Trigger Distribution",
                                     0,100,prgCurrent,prgTotal);
         QApplication::postEvent(this,event);

         // Start Run
         kpixCalDist->setPlotDir("Force_Trig");
         kpixRunWrite->setEventVar ( "ForceTrig",1.0 );
         for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( true );
         kpixCalDist->runDistribution (distCalEn->isChecked()?-1:-2);
         prgCurrent++;
         sleep(1); // Delay for plot update
      }

      // Self Trigger Distribution
      if ( enRun && distSelfTrig->isChecked() ) {

         // Debug Output
         if ( verbose->isChecked() ) cout << "Self Trigger Distribution" << endl;

         // Update status display
         event = new KpixGuiEventRun(false,false,"Running Self Trigger Distribution",
                                     0,100,prgCurrent,prgTotal);
         QApplication::postEvent(this,event);

         // Start Run
         kpixCalDist->setPlotDir("Self_Trig");
         kpixRunWrite->setEventVar ( "ForceTrig",0.0 );
         for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( false );
         kpixCalDist->runDistribution (distCalEn->isChecked()?-1:-2);
         prgCurrent++;
         sleep(1); // Delay for plot update
      }

      // Calibrate All Channels At Once
      if ( calibAllChannels->isChecked() ) {

         // Force Trigger
         if ( enRun && calForceTrig->isChecked() ) {

            // Update status display
            event = new KpixGuiEventRun(false,false,
                                        "Running Calibration, Force Trigger, All Channels",
                                        0,100,prgCurrent,prgTotal);
            QApplication::postEvent(this,event);

            // First calibrate with forced trigger
            if ( verbose->isChecked() ) cout << "Forced Trigger Calibration" << endl;
            kpixCalDist->setPlotDir("Force_Trig");
            kpixRunWrite->setEventVar ( "ForceTrig",1.0 );
            for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( true );
            kpixCalDist->runCalibration ( -1 );
            prgCurrent++;
            sleep(1); // Delay for plot update
         }

         // Self Trigger
         if ( enRun && calSelfTrig->isChecked() ) {

            // Update status display
            event = new KpixGuiEventRun(false,false,
                                        "Running Calibration, Self Trigger, All Channels",
                                        0,100,prgCurrent,prgTotal);
            QApplication::postEvent(this,event);

            // Next calibrate with self trigger
            if ( verbose->isChecked() ) cout << "Self Trigger Calibration" << endl;
            kpixCalDist->setPlotDir("Self_Trig");
            kpixRunWrite->setEventVar ( "ForceTrig",0.0 );
            for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( false );
            kpixCalDist->runCalibration ( -1 );
            prgCurrent++;
            sleep(1); // Delay for plot update
         }
      }
      else {

         // Run calibration once for each channel
         for (x=chanMin->value(); x <= (unsigned int)chanMax->value(); x++) { 

            // Force Trigger
            if ( enRun && calForceTrig->isChecked() ) {

               // Generate new status
               temp.str("");
               temp << "Running Calibration, Force Trigger, ";
               temp << "Channel " << dec << setw(2) << setfill(' ') << x;
               temp << " Of " << dec << setw(2) << setfill(' ') << chanMax->value();

               // Update status display
               event = new KpixGuiEventRun(false,false,temp.str(),0,100,prgCurrent,prgTotal);
               QApplication::postEvent(this,event);

               // First calibrate with forced trigger
               if ( verbose->isChecked() ) cout << "Forced Trigger Calibration" << endl;
               kpixCalDist->setPlotDir("Force_Trig");
               kpixRunWrite->setEventVar ( "ForceTrig",1.0 );
               for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( true );
               kpixCalDist->runCalibration ( x );
               prgCurrent++;
            }

            // Self Trigger
            if ( enRun && calSelfTrig->isChecked() ) {

               // Generate new status
               temp.str("");
               temp << "Running Calibration, Self Trigger, ";
               temp << "Channel " << dec << setw(2) << setfill(' ') << x;
               temp << " Of " << dec << setw(2) << setfill(' ') << chanMax->value();

               // Update status display
               event = new KpixGuiEventRun(false,false,temp.str(),0,100,prgCurrent,prgTotal);
               QApplication::postEvent(this,event);

               // Next calibrate with self trigger
               if ( verbose->isChecked() ) cout << "Self Trigger Calibration" << endl;
               kpixCalDist->setPlotDir("Self_Trig");
               kpixRunWrite->setEventVar ( "ForceTrig",0.0 );
               for(y=0; y<asicCnt; y++) asic[y]->setCntrlTrigSrcCore ( false );
               kpixCalDist->runCalibration ( x );
               prgCurrent++;
            }
         }
      }

      // Cleanup
      delete kpixCalDist;
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
void KpixGuiCalibrate::updateProgress(unsigned int count, unsigned int total) {
   KpixGuiEventRun *event = new KpixGuiEventRun(false,false,"",count,total,prgCurrent,prgTotal);
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiCalibrate::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError *eventError;
   KpixGuiEventRun   *eventRun;
   KpixGuiEventData  *eventData;
   unsigned int      x;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_RUN ) {
      eventRun = (KpixGuiEventRun *)event;

      // Run is starting
      if ( eventRun->runStart ) {
         isRunning = true;
         parent->setEnabled(false);
         liveDisplay->GetCanvas()->Clear();
         liveDisplay->GetCanvas()->Update();
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
         if ( runVarCount != 0 ) free(runVars);

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
      liveDisplay->GetCanvas()->Divide(1,2,.01,.01);

      // Delete multigraphs
      if ( mGraph[0] != NULL ) {
         delete mGraph[0]; 
         mGraph[0] = NULL;
         plots[0]  = NULL;
         plots[1]  = NULL;
      }
      if ( mGraph[0] != NULL ) {
         delete mGraph[1]; 
         mGraph[1] = NULL;
         plots[2]  = NULL;
         plots[3]  = NULL;
      }

      // Delete old plots, copy new plots
      for (x=0; x < 16; x++) {

         // Delete old
         if ( plots[x] != NULL ) {
            switch (pType) {
               case KPRG_TH1F:   delete ((TH1F *)plots[x]); break;
               case KPRG_TGRAPH: delete ((TGraph *)plots[x]); break;
               default: 
                  throw(string("KpixGuiCalibrate::customEvent -> Invalid Plot Type"));
                  break;
            }
         }

         // Copy new plots
         pType = eventData->id;
         if ( x < eventData->count ) plots[x] = eventData->data[x];
         else plots[x] = NULL;
      }

      // Plot Type
      switch (pType) {

         // Histograms
         case KPRG_TH1F:
            liveDisplay->GetCanvas()->cd(1);
            if ( plots[0] != NULL ) ((TH1F*)plots[0])->Draw();
            liveDisplay->GetCanvas()->cd(2);
            if ( plots[1] != NULL ) ((TH1F*)plots[1])->Draw();
            break;

         // Graphs
         case KPRG_TGRAPH:

            // Value
            liveDisplay->GetCanvas()->cd(1);
            mGraph[0] = new TMultiGraph();
            if ( plots[0] != NULL ) {
               mGraph[0]->Add((TGraph *)plots[0]);
               mGraph[0]->SetTitle(((TGraph *)plots[0])->GetTitle());
            }
            if ( plots[1] != NULL ) {
               mGraph[0]->Add((TGraph *)plots[1]);
               mGraph[0]->SetTitle(((TGraph *)plots[1])->GetTitle());
            }
            mGraph[0]->Draw("A*");

            // Time
            liveDisplay->GetCanvas()->cd(2);
            mGraph[1] = new TMultiGraph();
            if ( plots[2] != NULL ) {
               mGraph[1]->Add((TGraph *)plots[2]);
               mGraph[1]->SetTitle(((TGraph *)plots[2])->GetTitle());
            }
            if ( plots[3] != NULL ) {
               mGraph[1]->Add((TGraph *)plots[3]);
               mGraph[1]->SetTitle(((TGraph *)plots[3])->GetTitle());
            }
            mGraph[1]->Draw("A*");
            break;

         // Invalid
         default: 
            throw(string("KpixGuiCalibrate::customEvent -> Invalid Plot Type"));
            break;
      }
      liveDisplay->GetCanvas()->Update();
   }
}


// Update Plots
void KpixGuiCalibrate::updateData(unsigned int id, unsigned int count, void **data) {
   KpixGuiEventData *event = new KpixGuiEventData(id,count,data);
   QApplication::postEvent(this,event);
}


void KpixGuiCalibrate::closeEvent(QCloseEvent *e) {
   if ( isRunning ) e->ignore();
   else {
      if ( calFit != NULL ) delete calFit;
      calFit = NULL;
      e->accept();
   }
}


bool KpixGuiCalibrate::close() { return(KpixGuiCalibrateForm::close()); }


void KpixGuiCalibrate::viewCalib_pressed() {
   if ( calFit != NULL ) delete calFit;
   calFit = new KpixGuiCalFit(outDataFile,true);
   calFit->show();
}

