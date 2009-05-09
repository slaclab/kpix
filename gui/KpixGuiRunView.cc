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
#include <TQtWidget.h>
#include <TError.h>
#include "KpixGuiRunView.h"
using namespace std;


// Constructor
KpixGuiRunView::KpixGuiRunView ( string baseDir, bool open ) : KpixGuiRunViewForm() {

   stringstream temp;

   this->inFileRoot = NULL;
   inFileIsOpen     = false;
   this->baseDir    = baseDir;

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
   if ( hist[0] != NULL ) delete hist[0];
   if ( hist[1] != NULL ) delete hist[1];
   if ( hist[2] != NULL ) delete hist[2];
   if ( hist[3] != NULL ) delete hist[3];
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
   int          x;
   stringstream temp;

   if ( ! inFileIsOpen ) {
      try {
         inFileRoot = new KpixRunRead(inFile->text().ascii(),false);
         inFileIsOpen = true;
         gErrorIgnoreLevel = 5000; 

         // Update Kpix selection
         selSerial->clear();
         for (x=0; x < (inFileRoot->getAsicCount()-1); x++) {
            temp.str("");
            temp << inFileRoot->getAsic(x)->getSerial();
            selSerial->insertItem(temp.str(),x);
         }
         update();

         // Update range on channel spin box
         if ( inFileRoot->getAsicCount() > 0 ) 
            selChannel->setMaxValue ( inFileRoot->getAsic(0)->getChCount()-1 );

         // Update windows
         kpixGuiViewConfig->setRunData(inFileRoot);
         kpixGuiSampleView->setRunData(inFileRoot);
      } catch (string error) {
         errorMsg->showMessage(error);
      }
   }
   setEnabled(true);
   updateDisplay();
}


// Close the input file
void KpixGuiRunView::inFileClose_pressed() {

   if ( inFileIsOpen ) {

      // Close sub-windows
      kpixGuiViewConfig->close();
      kpixGuiSampleView->close();
      
      // No FPGA/ASIC Entries
      kpixGuiViewConfig->setRunData(NULL);
      kpixGuiSampleView->setRunData(NULL);

      // Close file
      delete inFileRoot;
   }

   // Set flags, update buttons and update display
   inFileIsOpen = false;
   setEnabled(true);
   updateDisplay();
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
   inFileOpen->setEnabled(inFileIsOpen?false:enable);
   inFileClose->setEnabled(inFileIsOpen?enable:false);
   inFileBrowse->setEnabled(inFileIsOpen?false:enable);
   inFile->setEnabled(inFileIsOpen?false:enable);
   viewConfig->setEnabled(inFileIsOpen?enable:false);
   viewSamples->setEnabled(inFileIsOpen?enable:false);
   selSerial->setEnabled(inFileIsOpen?enable:false);
   selChannel->setEnabled(inFileIsOpen?enable:false);
   selBucket->setEnabled(inFileIsOpen?enable:false);
   writePdf->setEnabled(inFileIsOpen?enable:false);
}


void KpixGuiRunView::updateDisplay() {
   unsigned int serial,chan, bucket;
   stringstream temp;

   // Delete old histogram
   if ( hist[0] != NULL ) { delete hist[0]; hist[0] = NULL; }
   if ( hist[1] != NULL ) { delete hist[1]; hist[1] = NULL; }
   if ( hist[2] != NULL ) { delete hist[2]; hist[2] = NULL; }
   if ( hist[3] != NULL ) { delete hist[3]; hist[3] = NULL; }

   // Only update if input file exists
   if ( inFileIsOpen ) {

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
      inFileRoot->treeFile->GetObject(temp.str().c_str(),hist[0]);
      if ( hist[0] != NULL ) hist[0]->SetDirectory(0);

      // Figure out raw name, range = 1
      temp.str("");
      temp << "/RunPlots/hist_raw_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
      temp << "_c" << dec << setw(4) << setfill('0') << chan;
      temp << "_b" << dec << setw(1) << setfill('0') << bucket;
      temp << "_r1";

      // attempt to get object
      inFileRoot->treeFile->GetObject(temp.str().c_str(),hist[1]);
      if ( hist[1] != NULL ) hist[1]->SetDirectory(0);

      // Figure out charge name, range = 0
      temp.str("");
      temp << "/RunPlots/hist_charge_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
      temp << "_c" << dec << setw(4) << setfill('0') << chan;
      temp << "_b" << dec << setw(1) << setfill('0') << bucket;
      temp << "_r0";

      // attempt to get object
      inFileRoot->treeFile->GetObject(temp.str().c_str(),hist[2]);
      if ( hist[2] != NULL ) hist[2]->SetDirectory(0);

      // Figure out charge name
      temp.str("");
      temp << "/RunPlots/hist_charge_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
      temp << "_c" << dec << setw(4) << setfill('0') << chan;
      temp << "_b" << dec << setw(1) << setfill('0') << bucket;
      temp << "_r1";

      // attempt to get object, range = 1
      inFileRoot->treeFile->GetObject(temp.str().c_str(),hist[3]);
      if ( hist[3] != NULL ) hist[3]->SetDirectory(0);
   }

   // Draw Dist Histograms
   plotData->GetCanvas()->Clear();
   plotData->GetCanvas()->Divide(1,2,.01,.01);

   // Upper plots
   plotData->GetCanvas()->cd(1);
   if ( hist[0] != NULL ) {
      hist[0]->Draw();
      if ( hist[1] != NULL ) hist[1]->Draw("same");
   }
   else if ( hist[1] != NULL ) hist[1]->Draw();

   // Lower Plot
   plotData->GetCanvas()->cd(2);
   if ( hist[2] != NULL ) {
      hist[2]->Draw();
      if ( hist[3] != NULL ) hist[3]->Draw("same");
   }
   else if ( hist[3] != NULL ) hist[3]->Draw();

   // Update
   plotData->GetCanvas()->Update();
   update();
}


void KpixGuiRunView::writePdf_pressed() {
   unsigned int serial,chan;
   stringstream temp, cmd;

   // Get current selection
   serial = selSerial->currentItem();
   chan   = selChannel->value();

   // Generate Plot Name
   temp.str("");
   temp << "hist_raw_s" << dec << setw(4) << setfill('0') << inFileRoot->getAsic(serial)->getSerial();
   temp << "_c" << dec << setw(4) << setfill('0') << chan;
   temp << ".ps";

   // Write Plot
   cout << "KpixGuiRunView::writePdf_pressed -> Wrote canvas to file " << temp.str() << endl;
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
   chCount = inFileRoot->getAsic(0)->getChCount();

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
   updateDisplay();
}


void KpixGuiRunView::nextChan_pressed() {
   int channel, serial, bucket, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   channel = selChannel->value();
   bucket  = selBucket->value();
   chCount = inFileRoot->getAsic(0)->getChCount();

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
   updateDisplay();
}


