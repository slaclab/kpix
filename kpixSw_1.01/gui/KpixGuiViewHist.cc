//-----------------------------------------------------------------------------
// File          : KpixGuiViewHist.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing histograms.
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
#include <TF1.h>
#include <qlineedit.h>
#include <qtabwidget.h>
#include <TQtWidget.h>
#include "KpixGuiViewHist.h"
#include "KpixGuiCalFit.h"
using namespace std;


// Constructor
KpixGuiViewHist::KpixGuiViewHist ( unsigned int dirCount, string *dirNames, KpixGuiCalFit *parent ) : KpixGuiViewHistForm() {

   unsigned int x;

   // Set Parent
   this->parent = parent;

   // Init histograms
   hist[0] = NULL;
   hist[1] = NULL;

   // Update directory selection
   selDir->clear();
   for (x=0; x<dirCount; x++) selDir->insertItem(dirNames[x],x);

   // Directory is blank
   kpixCalibData = NULL;
}


// Delete CLass
KpixGuiViewHist::~KpixGuiViewHist () {
   if ( hist[0] != NULL ) delete hist[0];
   if ( hist[1] != NULL ) delete hist[1];
}


// Update Kpix selection
void KpixGuiViewHist::setCalibData(KpixCalibRead *kpixCalibData) {
   unsigned int x;
   stringstream temp;

   this->kpixCalibData = kpixCalibData;
   selSerial->clear();
   if ( kpixCalibData != NULL ) {
      for (x=0; x < (unsigned int)(kpixCalibData->kpixRunRead->getAsicCount()-1); x++) {
         temp.str("");
         temp << kpixCalibData->kpixRunRead->getAsic(x)->getSerial();
         selSerial->insertItem(temp.str(),x);
      }

      // Select channel range
      if ( kpixCalibData->kpixRunRead->getAsicCount() > 0 ) 
         selChannel->setMaxValue ( kpixCalibData->kpixRunRead->getAsic(x)->getChCount()-1 );
   }
}


// Show
void KpixGuiViewHist::show() {
   if ( kpixCalibData != NULL ) {
      KpixGuiViewHistForm::show();
      updateDisplay();
   }
}


// Force current directory selection
void KpixGuiViewHist::selectDir(unsigned int selDir) {
   this->selDir->setCurrentItem(selDir);
   this->reFitEn->setChecked(true);
   updateDisplay();
}


void KpixGuiViewHist::updateDisplay() {
   int          bucket, channel, gain, serial, dirIndex;
   string       dirName;
   string       dirString;
   stringstream temp;

   // Calib Data or directory not valid
   if ( kpixCalibData == NULL ) 
      throw(string("KpixGuiViewHist::updateDisplay -> Input File Not Open"));

   // Delete old plots
   if ( hist[0] != NULL ) delete hist[0];
   if ( hist[1] != NULL ) delete hist[1];

   // Get Current Values
   dirIndex = selDir->currentItem();
   dirName  = selDir->currentText().ascii();
   serial   = selSerial ->currentItem();
   gain     = selGain->currentItem();
   channel  = selChannel->value();
   bucket   = selBucket->value();

   // Get plots
   hist[0] = kpixCalibData->getHistValue(dirName,gain,
                                         kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                         channel,bucket);
   hist[1] = kpixCalibData->getHistTime(dirName,gain,
                                        kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                        channel,bucket);
   // Set fit options
   gStyle->SetOptFit(1111);

   // Clear results
   meanValue->setText("");
   sigmaValue->setText("");

   // Update write buttons
   if ( parent->isHistWritable(dirIndex,gain,serial,channel,bucket) ) {
      writePlot->setEnabled(true);   
      writeAll->setEnabled(true);   
   } else {
      writePlot->setEnabled(false);   
      writeAll->setEnabled(false);   
   }

   // Re-Fit Enabled
   if ( reFitEn->isChecked() && hist[0] != NULL ) hist[0]->Fit("gaus","q");

   // Extract fit results
   if ( hist[0] != NULL && hist[0]->GetFunction("gaus") != NULL ) {
      temp.str(""); temp << hist[0]->GetFunction("gaus")->GetParameter(1);
      meanValue->setText(temp.str());
      temp.str(""); temp << hist[0]->GetFunction("gaus")->GetParameter(2);
      sigmaValue->setText(temp.str());
   }

   // Draw Plots
   plotDisplay->GetCanvas()->Clear();
   plotDisplay->GetCanvas()->Divide(1,2,.01,.01);
   plotDisplay->GetCanvas()->cd(1);
   if ( hist[0] != NULL ) hist[0]->Draw();
   plotDisplay->GetCanvas()->cd(2);
   if ( hist[1] != NULL ) hist[1]->Draw();
   plotDisplay->GetCanvas()->Update();

   // Update main window
   update();
}


void KpixGuiViewHist::prevPlot_pressed() {
   int bucket, channel, gain, serial, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   gain    = selGain->currentItem();
   channel = selChannel->value();
   bucket  = selBucket->value();
   chCount = kpixCalibData->kpixRunRead->getAsic(0)->getChCount();

   bucket--;
   if ( bucket == -1 ) {
      bucket = 3;
      channel--;
   }
   if ( channel == -1 ) {
      channel = chCount-1;
      gain--;
   }
   if ( gain == -1 ) {
      gain = 2;
      serial--;
   }
   if ( serial == -1 ) serial = kpixCalibData->kpixRunRead->getAsicCount()-2;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selGain->setCurrentItem(gain);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   update();
}


void KpixGuiViewHist::nextPlot_pressed() {
   int bucket, channel, gain, serial, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   gain    = selGain->currentItem();
   channel = selChannel->value();
   bucket  = selBucket->value();
   chCount = kpixCalibData->kpixRunRead->getAsic(0)->getChCount();

   bucket++;
   if ( bucket == 4 ) {
      bucket = 0;
      channel++;
   }
   if ( channel == chCount ) {
      channel = 0;
      gain++;
   }
   if ( gain == 3 ) {
      gain = 0;
      serial++;
   }
   if ( serial == (int)(kpixCalibData->kpixRunRead->getAsicCount()-1) ) serial = 0;

   // Find out last
   if ( bucket == 3 && channel == (chCount-1) && gain == 2 && 
        serial == (int)(kpixCalibData->kpixRunRead->getAsicCount()-2) ) atLast = true;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selGain->setCurrentItem(gain);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   update();
}


void KpixGuiViewHist::writePlot_pressed() {
   int    dirIndex = selDir->currentItem();
   int    serial   = selSerial->currentItem();
   int    gain     = selGain->currentItem();
   int    channel  = selChannel->value();
   int    bucket   = selBucket->value();
   parent->writeHist(dirIndex,gain,serial,channel,bucket,hist);
   nextPlot_pressed();
}


void KpixGuiViewHist::writeAll_pressed() {

   // Set Low End Values
   selSerial->setCurrentItem(0);
   selGain->setCurrentItem(0);
   selChannel->setValue(0);
   selBucket->setValue(0);

   atLast = false;
   while ( !atLast ) writePlot_pressed();
   writePlot_pressed();
}


void KpixGuiViewHist::writePdf_pressed() {

   stringstream tempName;
   stringstream cmd;

   int dirIndex = selDir->currentItem();
   int serial   = selSerial->currentItem();
   int gain     = selGain->currentItem();
   int channel  = selChannel->value();
   int bucket   = selBucket->value();

   // Generate file name based upon current settings
   tempName.str("");
   tempName << "hist_";
   if ( dirIndex == 0 ) tempName << "force_";
   if ( dirIndex == 1 ) tempName << "self_";
   if ( gain == 0 )     tempName << "norm_s";
   if ( gain == 1 )     tempName << "double_s";
   if ( gain == 2 )     tempName << "low_s";
   tempName << dec << setw(4) << setfill('0') << kpixCalibData->kpixRunRead->getAsic(serial)->getSerial();
   tempName << dec << setw(4) << setfill('0') << "_c" << channel << "_b";
   tempName << dec << setw(1) << bucket << ".ps";

   // Write Plot
   cout << "KpixGuiViewHist::writePdf_pressed -> Wrote canvas to file " << tempName.str() << endl;
   plotDisplay->GetCanvas()->Print(tempName.str().c_str());
   cmd.str(""); cmd << "ps2pdf " << tempName.str();
   system(cmd.str().c_str());
}
