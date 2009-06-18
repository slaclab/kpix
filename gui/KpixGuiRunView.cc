//-----------------------------------------------------------------------------
// File          : KpixGuiRunView.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for calibration/dist fit GUI
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
#include <qfiledialog.h>
#include <qapplication.h>
#include <TQtWidget.h>
#include <TError.h>
#include "KpixGuiRunView.h"
#include "KpixGuiEventStatus.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventData.h"
using namespace std;


// Constructor
KpixGuiRunView::KpixGuiRunView ( string baseDir, bool open ) : KpixGuiRunViewForm() {

   stringstream temp;

   this->inFileRoot = NULL;
   this->baseDir    = baseDir;
   this->asicCnt    = 0;
   this->asic       = NULL;
   this->isRunning  = false;

   // Create error window
   errorMsg = new KpixGuiError(this);
   setEnabled(true);

   // Hidden windows at startup
   this->kpixGuiViewConfig = new KpixGuiViewConfig();
   this->kpixGuiSampleView = new KpixGuiSampleView();

   // Set default base dirs
   inFile->setText(this->baseDir);

   // Clear histogram
   hist[0] = NULL;
   hist[1] = NULL;
   hist[2] = NULL;
   hist[3] = NULL;

   // Auto open file
   if ( open ) inFileOpen_pressed();
}


// Delete
KpixGuiRunView::~KpixGuiRunView ( ) {
   inFileClose_pressed();
   delete kpixGuiViewConfig;
   delete kpixGuiSampleView;
}


// Select an input file for opening
void KpixGuiRunView::inFileBrowse_pressed() {

   QString      temp;

   // Select Input File
   QFileDialog *fd = new QFileDialog(this,"Input Root File",TRUE);
   fd->setFilter("Root Files (*.root)");
   fd->setViewMode(QFileDialog::Detail);

   // Set Default
   if ( inFile->text() != "" ) fd->setSelection(inFile->text());

   // File Was selected
   if ( fd->exec() == QDialog::Accepted ) {
      temp      = fd->selectedFile();

      // Set Input File
      inFile->setText(temp);
   }
   delete(fd);
   inFileBrowse->setDown(false);
}


// Open the input file
void KpixGuiRunView::inFileOpen_pressed() {
   plotData->GetCanvas()->Clear();
   setEnabled(false);
   cmdType = CmdReadFile;
   isRunning = true;
   QThread::start();
}


// Close the input file
void KpixGuiRunView::inFileClose_pressed() {

   // Close sub-windows
   kpixGuiViewConfig->close();
   kpixGuiSampleView->close();
   
   // No FPGA/ASIC Entries
   kpixGuiViewConfig->setRunData(NULL);
   kpixGuiSampleView->setRunData(NULL);

   // Clear plots
   plotData->GetCanvas()->Clear();
   if ( hist[0] != NULL ) { delete hist[0]; hist[0] = NULL; }
   if ( hist[1] != NULL ) { delete hist[1]; hist[1] = NULL; }
   if ( hist[2] != NULL ) { delete hist[2]; hist[2] = NULL; }
   if ( hist[3] != NULL ) { delete hist[3]; hist[3] = NULL; }
   plotData->GetCanvas()->Update();

   // Clear asics
   if ( asic != NULL ) free(asic);
   asicCnt = 0;

   // Close file
   if ( inFileRoot != NULL ) delete inFileRoot;
   inFileRoot = NULL;

   // Set flags, update buttons and update display
   setEnabled(true);
}


void KpixGuiRunView::readPlot() {
   if ( !isRunning ) {
      setEnabled(false);
      cmdType = CmdReadPlot;
      isRunning = true;
      QThread::start();
   }
}


void KpixGuiRunView::viewConfig_pressed() {
   kpixGuiViewConfig->show();
}


void KpixGuiRunView::viewSamples_pressed() {
   kpixGuiSampleView->show();
}


// Set Button Enables
void KpixGuiRunView::setEnabled(bool enable) {

   // These buttons depend on file open state
   inFileOpen->setEnabled(inFileRoot!=NULL?false:enable);
   inFileClose->setEnabled(inFileRoot!=NULL?enable:false);
   inFileBrowse->setEnabled(inFileRoot!=NULL?false:enable);
   inFile->setEnabled(inFileRoot!=NULL?false:enable);
   viewConfig->setEnabled(inFileRoot!=NULL?enable:false);
   viewSamples->setEnabled(inFileRoot!=NULL?enable:false);
   selSerial->setEnabled(inFileRoot!=NULL?enable:false);
   selChannel->setEnabled(inFileRoot!=NULL?enable:false);
   selBucket->setEnabled(inFileRoot!=NULL?enable:false);
   writePdf->setEnabled(inFileRoot!=NULL?enable:false);
   fitHistogram->setEnabled(inFileRoot!=NULL?enable:false);
   prevChan->setEnabled(inFileRoot!=NULL?enable:false);
   nextChan->setEnabled(inFileRoot!=NULL?enable:false);
   logScale->setEnabled(inFileRoot!=NULL?enable:false);
}


void KpixGuiRunView::writePdf_pressed() {
   unsigned int       serial,chan, bucket;
   stringstream       temp, cmd;

   // Get current selection
   serial = selSerial->currentItem();
   chan   = selChannel->value();
   bucket = selBucket->value();

   // Generate Plot Name
   temp.str("");
   temp << "run_view_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
   temp << "_c" << dec << setw(4) << setfill('0') << chan;
   temp << "_b" << dec << setw(1) << setfill('0') << bucket;
   temp << ".ps";

   // Write Plot
   cout << "Wrote canvas to file " << temp.str() << endl;
   plotData->GetCanvas()->Print(temp.str().c_str());
   cmd.str(""); cmd << "ps2pdf " << temp.str();
   system(cmd.str().c_str());
}


void KpixGuiRunView::closeEvent(QCloseEvent *e) {
   if ( kpixGuiViewConfig->close() && kpixGuiSampleView->close() ) {
      inFileClose_pressed();
      e->accept();
   }
   else e->ignore();
}


void KpixGuiRunView::prevChan_pressed() {
   int channel, serial, bucket, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   channel = selChannel->value();
   bucket  = selBucket->value();
   chCount = asic[0]->getChCount();

   bucket--;
   if ( bucket == -1 ) {
      bucket = 3;
      channel--;
   }
   if ( channel == -1 ) {
      channel = chCount-1;
      serial--;
   }
   if ( serial == -1 ) serial = inFileRoot->getAsicCount()-2;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   readPlot();
}


void KpixGuiRunView::nextChan_pressed() {
   int channel, serial, bucket, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   channel = selChannel->value();
   bucket  = selBucket->value();
   chCount = asic[0]->getChCount();

   bucket++;
   if ( bucket == 4 ) {
      bucket = 0;
      channel++;
   }
   if ( channel == chCount ) {
      channel = 0;
      serial++;
   }
   if ( serial == (inFileRoot->getAsicCount()-1) ) serial = 0;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   readPlot();
}


// Thread for command run
void KpixGuiRunView::run() {
   KpixGuiEventStatus *event;
   KpixGuiEventError  *error;
   KpixGuiEventData   *data;
   unsigned int       x;
   unsigned int       serial,chan, bucket;
   stringstream       temp, cmd;
   TH1F               *tempHist[4];

   // Which command
   try {
      switch ( cmdType ) {

         case CmdReadFile:
            inFileRoot = new KpixRunRead(inFile->text().ascii(),false);
            gErrorIgnoreLevel = 5000;

            // Update Kpix info
            asicCnt = inFileRoot->getAsicCount();
            asic = (KpixAsic **) malloc(sizeof(KpixAsic*)*asicCnt);
            for (x=0; x < asicCnt-1; x++) asic[x] = inFileRoot->getAsic(x);
            break;

         case CmdReadPlot:

            // Init histograms
            tempHist[0] = NULL;
            tempHist[1] = NULL;
            tempHist[2] = NULL;
            tempHist[3] = NULL;

            // Get current selection
            serial = selSerial->currentItem();
            chan   = selChannel->value();
            bucket = selBucket->value();

            // Figure out raw name, range = 0
            temp.str("");
            temp << "/RunPlots/hist_raw_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
            temp << "_c" << dec << setw(4) << setfill('0') << chan;
            temp << "_b" << dec << setw(1) << setfill('0') << bucket;
            temp << "_r0";

            // attempt to get object
            inFileRoot->treeFile->GetObject(temp.str().c_str(),tempHist[0]);
            if ( tempHist[0] != NULL ) {
               tempHist[0]->SetDirectory(0);
               if ( fitHistogram->isChecked() ) {
                  tempHist[0]->Fit("gaus","q");
                  tempHist[0]->SetStats(true);
               }
            }

            // Figure out raw name, range = 1
            temp.str("");
            temp << "/RunPlots/hist_raw_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
            temp << "_c" << dec << setw(4) << setfill('0') << chan;
            temp << "_b" << dec << setw(1) << setfill('0') << bucket;
            temp << "_r1";

            // attempt to get object
            inFileRoot->treeFile->GetObject(temp.str().c_str(),tempHist[1]);
            if ( tempHist[1] != NULL ) {
               tempHist[1]->SetDirectory(0);
               if ( fitHistogram->isChecked() ) {
                  tempHist[1]->Fit("gaus","q");
                  tempHist[1]->SetStats(true);
               }
            }

            // Figure out charge name, range = 0
            temp.str("");
            temp << "/RunPlots/hist_charge_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
            temp << "_c" << dec << setw(4) << setfill('0') << chan;
            temp << "_b" << dec << setw(1) << setfill('0') << bucket;
            temp << "_r0";

            // attempt to get object
            inFileRoot->treeFile->GetObject(temp.str().c_str(),tempHist[2]);
            if ( tempHist[2] != NULL ) {
               tempHist[2]->SetDirectory(0);
               if ( fitHistogram->isChecked() ) {
                  tempHist[2]->Fit("gaus","q");
                  tempHist[2]->SetStats(true);
               }
            }

            // Figure out charge name
            temp.str("");
            temp << "/RunPlots/hist_charge_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
            temp << "_c" << dec << setw(4) << setfill('0') << chan;
            temp << "_b" << dec << setw(1) << setfill('0') << bucket;
            temp << "_r1";

            // attempt to get object, range = 1
            inFileRoot->treeFile->GetObject(temp.str().c_str(),tempHist[3]);
            if ( tempHist[3] != NULL ) {
               tempHist[3]->SetDirectory(0);
               if ( fitHistogram->isChecked() ) {
                  tempHist[3]->Fit("gaus","q");
                  tempHist[3]->SetStats(true);
               }
            }

            // Generate data event
            data = new KpixGuiEventData(0,4,(void **)tempHist);
            QApplication::postEvent(this,data);
            break;
      }
   }
   catch ( string errorMsg ) {
      error = new KpixGuiEventError(errorMsg);
      QApplication::postEvent(this,error);
   }

   // Update status display
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusDone);
   QApplication::postEvent(this,event);
}

   
// Receive Custom Events
void KpixGuiRunView::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError *eventError;
   KpixGuiEventData  *eventData;
   stringstream      temp;
   unsigned int      x;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_STATUS ) {

      // Read file command
      if ( cmdType == CmdReadFile && inFileRoot != NULL ) {

         // Update Kpix selection pulldown 
         for (x=0; x < asicCnt-1; x++) {
            temp.str("");
            temp << asic[x]->getSerial();
            selSerial->insertItem(temp.str(),x);
         }

         // Update range on channel spin box
         if ( asicCnt > 0 ) selChannel->setMaxValue ( asic[0]->getChCount()-1 );

         // Update windows
         kpixGuiViewConfig->setRunData(inFileRoot);
         kpixGuiSampleView->setRunData(inFileRoot);

         // Set default values
         selSerial ->setCurrentItem(0);
         selChannel->setValue(0);
         selBucket->setValue(0);

         // Re-Start thread with read plot command
         cmdType = CmdReadPlot;
         QThread::start();
      }
      else {
         setEnabled(true);
         isRunning = false;
      }
      update();
   }

   // Data Event
   if ( event->type() == KPIX_GUI_EVENT_DATA ) {
      eventData = (KpixGuiEventData *)event;

      // Set fit options
      gStyle->SetOptFit(1111);

      // Clear display
      plotData->GetCanvas()->Clear();
      plotData->GetCanvas()->Divide(1,2,.01,.01);

      // Delete old histograms
      if ( hist[0] != NULL ) { delete hist[0]; hist[0] = NULL; }
      if ( hist[1] != NULL ) { delete hist[1]; hist[1] = NULL; }
      if ( hist[2] != NULL ) { delete hist[2]; hist[2] = NULL; }
      if ( hist[3] != NULL ) { delete hist[3]; hist[3] = NULL; }

      // Copy new histograms
      if ( eventData->count > 0 ) hist[0] = (TH1F *)eventData->data[0];
      if ( eventData->count > 1 ) hist[1] = (TH1F *)eventData->data[1];
      if ( eventData->count > 2 ) hist[2] = (TH1F *)eventData->data[2];
      if ( eventData->count > 3 ) hist[3] = (TH1F *)eventData->data[3];

      // Upper plots
      plotData->GetCanvas()->cd(1);
      if ( logScale->isChecked() ) plotData->GetCanvas()->cd(1)->SetLogy();
      if ( hist[0] != NULL ) {
         hist[0]->Draw();
         if ( hist[1] != NULL ) hist[1]->Draw("same");
      }
      else if ( hist[1] != NULL ) hist[1]->Draw();

      // Lower Plot
      plotData->GetCanvas()->cd(2);
      if ( logScale->isChecked() ) plotData->GetCanvas()->cd(2)->SetLogy();
      if ( hist[2] != NULL ) {
         hist[2]->Draw();
         if ( hist[3] != NULL ) hist[3]->Draw("same");
      }
      else if ( hist[3] != NULL ) hist[3]->Draw();

      // Update
      plotData->GetCanvas()->Update();
      update();
   }

   // Error Event
   if ( event->type() == KPIX_GUI_EVENT_ERROR ) {
      cout << "InFile ==NULL = " << (inFileRoot == NULL) << endl;
      eventError = (KpixGuiEventError *)event;
      errorMsg->showMessage(eventError->errorMsg);
      update();
   }
}


