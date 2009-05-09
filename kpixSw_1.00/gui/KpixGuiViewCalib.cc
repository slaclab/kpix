//-----------------------------------------------------------------------------
// File          : KpixGuiViewCalib.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing calibrations.
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
#include "KpixGuiViewCalib.h"
#include "KpixGuiCalFit.h"
using namespace std;


// Constructor
KpixGuiViewCalib::KpixGuiViewCalib (unsigned int dirCount, string *dirNames, KpixGuiCalFit *parent) : KpixGuiViewCalibForm() {

   unsigned int x;

   // Set Parent
   this->parent = parent;

   // Init graphs
   for (x=0; x<8; x++) graph[x] = NULL;
   mGraph[0] = NULL;
   mGraph[1] = NULL;
   mGraph[2] = NULL;

   // Update directory selection
   selDir->clear();
   for (x=0; x<dirCount; x++) selDir->insertItem(dirNames[x],x);

   // Directory is blank
   kpixCalibData = NULL;

   // Bucket times
   calCount      = 0;
   calTime[0]    = 0;
   calTime[1]    = 0;
   calTime[2]    = 0;
   calTime[3]    = 0;
}


// Delete CLass
KpixGuiViewCalib::~KpixGuiViewCalib () {
   if ( mGraph[0] != NULL ) delete mGraph[0];
   if ( mGraph[1] != NULL ) delete mGraph[1];
   if ( mGraph[2] != NULL ) delete mGraph[2];
}


// Update Kpix selection
void KpixGuiViewCalib::setCalibData(KpixCalibRead *kpixCalibData) {
   unsigned int x, calA, calB, calC, calD;
   stringstream temp;

   this->kpixCalibData = kpixCalibData;
   selSerial->clear();

   if ( kpixCalibData != NULL ) {

      // Update KPIX Box
      for (x=0; x < (unsigned int)(kpixCalibData->kpixRunRead->getAsicCount()-1); x++) {
         temp.str("");
         temp << kpixCalibData->kpixRunRead->getAsic(x)->getSerial();
         selSerial->insertItem(temp.str(),x);
      }

      // Update calibration times
      kpixCalibData->kpixRunRead->getAsic(0)->getCalibTime(&calCount,&calA,&calB,&calC,&calD,false);

      // Compute time points
      calTime[0] = calA;
      calTime[1] = calA + calB + 4;
      calTime[2] = calA + calB + calC + 8;
      calTime[3] = calA + calB + calC + calD + 12;

      // Select channel range
      if ( kpixCalibData->kpixRunRead->getAsicCount() > 0 ) 
         selChannel->setMaxValue ( kpixCalibData->kpixRunRead->getAsic(0)->getChCount()-1 );
   }
}


// Show
void KpixGuiViewCalib::show() {
   if ( kpixCalibData != NULL ) {
      KpixGuiViewCalibForm::show();
      updateDisplay();
   }
}


// Force current directory selection
void KpixGuiViewCalib::selectDir(unsigned int selDir) {
   this->selDir->setCurrentItem(selDir);
   this->reFitEn->setChecked(true);
   this->timeFiltEn->setChecked(true);
   updateDisplay();
}


void KpixGuiViewCalib::updateDisplay() {
   int          x,bucket, channel, gain, serial, dirIndex;
   string       dirName;
   stringstream temp;
   int          newCount, oldCount;
   double       newX[256], newY[256];
   double       minFit, maxFit;
   double       oldX, oldY, oldTX, oldTY;
   unsigned int timeMin, timeMax;
   bool         valid;

   // Calib Data or directory not valid
   if ( kpixCalibData == NULL ) 
      throw(string("KpixGuiViewCalib::updateDisplay -> Input File Not Open"));

   // Delete old plots
   if ( mGraph[0] != NULL ) delete mGraph[0]; mGraph[0] = NULL;
   if ( mGraph[1] != NULL ) delete mGraph[1]; mGraph[1] = NULL;
   if ( mGraph[2] != NULL ) delete mGraph[2]; mGraph[2] = NULL;
   for (x=0; x<8; x++) graph[x] = NULL;

   // Get Current Values
   dirIndex = selDir->currentItem();
   dirName  = selDir->currentText().ascii();
   serial   = selSerial ->currentItem();
   gain     = selGain->currentItem();
   channel  = selChannel->value();
   bucket   = selBucket->value();

   // Get plots
   graph[0] = kpixCalibData->getGraphValue(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                           channel,bucket,0);
   graph[1] = kpixCalibData->getGraphValue(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                           channel,bucket,1);
   graph[2] = kpixCalibData->getGraphTime(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                          channel,bucket,0);
   graph[3] = kpixCalibData->getGraphTime(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                          channel,bucket,1);
   graph[4] = kpixCalibData->getGraphResid(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                           channel,bucket,0);
   graph[5] = kpixCalibData->getGraphResid(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                           channel,bucket,1);
   graph[6] = kpixCalibData->getGraphFilt(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                          channel,bucket,0);
   graph[7] = kpixCalibData->getGraphFilt(dirName,gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(),
                                          channel,bucket,1);

   // Set fit options
   gStyle->SetOptFit(1111);

   // Clear results
   lowGainValue->setText("");
   lowInterceptValue->setText("");
   lowRmsValue->setText("");
   highGainValue->setText("");
   highInterceptValue->setText("");
   highRmsValue->setText("");

   // Update write buttons
   if ( parent->isCalibWritable(dirIndex,gain,serial,channel,bucket) ) {
      writePlot->setEnabled(true);   
      writeAll->setEnabled(true);   
   } else {
      writePlot->setEnabled(false);   
      writeAll->setEnabled(false);   
   }

   // Determine time Range
   timeMin = calTime[bucket];
   if (bucket != 3) timeMax = calTime[bucket+1];
   else timeMax = 2880;

   // Show min/max time
   temp.str(""); temp << timeMin; minTimeVal->setText(temp.str());
   temp.str(""); temp << timeMax; maxTimeVal->setText(temp.str());

   // Re-Fit Enabled
   if ( reFitEn->isChecked() ) {

      // Choose Fit Range
      switch (gain) {
         case 0:
            minFit = normMinFit->text().toDouble() * 1e-15;
            maxFit = normMaxFit->text().toDouble() * 1e-15;
            break;
         case 1:
            minFit = doubleMinFit->text().toDouble() * 1e-15;
            maxFit = doubleMaxFit->text().toDouble() * 1e-15;
            break;
         case 2:
            minFit = lowMinFit->text().toDouble() * 1e-15;
            maxFit = lowMaxFit->text().toDouble() * 1e-15;
            break;
         default:
            minFit = 0;
            maxFit = 0;
            break;
      }

      // Time Filter
      if ( timeFiltEn->isChecked() ) {

         // Delete old filter graphs if they exist
         if ( graph[6] != NULL ) delete graph[6]; graph[6] = NULL;
         if ( graph[7] != NULL ) delete graph[7]; graph[7] = NULL;

         // Generate new range 0 value/time points
         if ( graph[0] != NULL ) {
            oldCount = graph[0]->GetN();
            newCount = 0;
            for (x=0; x< oldCount; x++) {
               graph[0]->GetPoint(x,oldX,oldY);
               graph[2]->GetPoint(x,oldTX,oldTY);
               if ( oldX != oldTX ) cout << "KpixGuiViewCalib::updateDisplay -> Error: X Value Mismatch" << endl;
               if ( oldTY >= timeMin && oldTY < timeMax ) {
                  newX[newCount] = oldX;
                  newY[newCount] = oldY;
                  newCount++;
               }
            }

            // Create new plots
            if ( newCount > 0 ) {
               graph[6] = new TGraph(newCount,newX,newY);
               graph[6]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                            channel, bucket,"Calib Filt",0).c_str());
            }

            // Delete Fitted Function 
            delete (graph[0]->GetFunction("pol1"));
         }

         // Generate new range 1 value/time points
         if ( graph[1] != NULL ) {
            oldCount = graph[1]->GetN();
            newCount = 0;
            for (x=0; x< oldCount; x++) {
               graph[1]->GetPoint(x,oldX,oldY);
               graph[3]->GetPoint(x,oldTX,oldTY);
               if ( oldX != oldTX ) cout << "KpixGuiViewCalib::updateDisplay -> Error: X Value Mismatch" << endl;
               if ( oldTY >= timeMin && oldTY < timeMax ) {
                  newX[newCount] = oldX;
                  newY[newCount] = oldY;
                  newCount++;
               }
            }

            // Create new plots
            if ( newCount > 0 ) {
               graph[7] = new TGraph(newCount,newX,newY);
               graph[7]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                            channel, bucket,"Calib Filt",1).c_str());
            } 

            // Delete Fitted Function 
            delete (graph[1]->GetFunction("pol1"));
         }
      }

      // Fit Range 0, Value Plot, Non-Filtered
      if ( graph[0] != NULL && graph[6] == NULL ) {
         graph[0]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( graph[4] != NULL ) delete graph[4];

         // Generate New RMS Plot
         oldCount = graph[0]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            graph[0]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - graph[0]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         graph[4] = new TGraph(newCount,newX,newY);
         graph[4]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }

      // Fit Range 0, Value Plot, Filtered
      if ( graph[6] != NULL ) {
         graph[6]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( graph[4] != NULL ) delete graph[4];

         // Generate New RMS Plot
         oldCount = graph[6]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            graph[6]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - graph[6]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         graph[4] = new TGraph(newCount,newX,newY);
         graph[4]->SetTitle(KpixCalibRead::genPlotTitle(gain,kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }

      // Fit Range 1, Value Plot, Non-Filtered
      if ( graph[1] != NULL && graph[7] == NULL ) {
         graph[1]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( graph[5] != NULL ) delete graph[4];

         // Generate New RMS Plot
         oldCount = graph[1]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            graph[1]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - graph[1]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         graph[5] = new TGraph(newCount,newX,newY);
         graph[5]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",1).c_str());
      }

      // Fit Range 0, Value Plot, Filtered
      if ( graph[7] != NULL ) {
         graph[7]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( graph[5] != NULL ) delete graph[5];

         // Generate New RMS Plot
         oldCount = graph[7]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            graph[7]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - graph[7]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         graph[5] = new TGraph(newCount,newX,newY);
         graph[5]->SetTitle(KpixCalibRead::genPlotTitle(gain, kpixCalibData->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }
   } // FIT

   // Extract Range 0 Value Fit Results
   if ( graph[6] != NULL && graph[6]->GetFunction("pol1") != NULL ) {
      temp.str(""); temp << graph[6]->GetFunction("pol1")->GetParameter(1);
      highGainValue->setText(temp.str());
      temp.str(""); temp << graph[6]->GetFunction("pol1")->GetParameter(0);
      highInterceptValue->setText(temp.str());
   }
   else if ( graph[0] != NULL && graph[0]->GetFunction("pol1") != NULL ) {
      temp.str(""); temp << graph[0]->GetFunction("pol1")->GetParameter(1);
      highGainValue->setText(temp.str());
      temp.str(""); temp << graph[0]->GetFunction("pol1")->GetParameter(0);
      highInterceptValue->setText(temp.str());
   }
   if ( graph[4] != NULL ) {
      temp.str(""); temp << graph[4]->GetRMS(2);
      highRmsValue->setText(temp.str());
   }

   // Extract Range 1 Value Fit Results
   if ( graph[7] != NULL && graph[7]->GetFunction("pol1") != NULL ) {
      temp.str(""); temp << graph[7]->GetFunction("pol1")->GetParameter(1);
      lowGainValue->setText(temp.str());
      temp.str(""); temp << graph[7]->GetFunction("pol1")->GetParameter(0);
      lowInterceptValue->setText(temp.str());
   }
   else if ( graph[1] != NULL && graph[1]->GetFunction("pol1") != NULL ) {
      temp.str(""); temp << graph[1]->GetFunction("pol1")->GetParameter(1);
      lowGainValue->setText(temp.str());
      temp.str(""); temp << graph[1]->GetFunction("pol1")->GetParameter(0);
      lowInterceptValue->setText(temp.str());
   }
   if ( graph[5] != NULL ) {
      temp.str(""); temp << graph[5]->GetRMS(2);
      lowRmsValue->setText(temp.str());
   }

   // Draw Plots
   plotDisplay->GetCanvas()->Clear();
   plotDisplay->GetCanvas()->Divide(1,3,.01,.01);
   plotDisplay->GetCanvas()->cd(1);

   // Draw calibration
   mGraph[0] = new TMultiGraph(); valid = false;
   if ( graph[0] != NULL ) {
      graph[0]->SetMarkerColor(4);
      mGraph[0]->Add(graph[0]);
      mGraph[0]->SetTitle(graph[0]->GetTitle());
      valid = true;
   }
   if ( graph[1] != NULL ) {
      graph[1]->SetMarkerColor(3);
      mGraph[0]->Add(graph[1]);
      mGraph[0]->SetTitle(graph[1]->GetTitle());
      valid = true;
   }
   if ( graph[6] != NULL ) {
      graph[6]->SetMarkerColor(4);
      mGraph[0]->Add(graph[6]);
      mGraph[0]->SetTitle(graph[6]->GetTitle());
      valid = true;
   }
   if ( graph[7] != NULL ) {
      graph[7]->SetMarkerColor(3);
      mGraph[0]->Add(graph[7]);
      mGraph[0]->SetTitle(graph[7]->GetTitle());
      valid = true;
   }
   if ( valid ) mGraph[0]->Draw("A*");

   // Draw Time
   plotDisplay->GetCanvas()->cd(2);
   mGraph[1] = new TMultiGraph(); valid = false;
   if ( graph[2] != NULL ) {
      graph[2]->SetMarkerColor(4);
      mGraph[1]->Add(graph[2]);
      mGraph[1]->SetTitle(graph[2]->GetTitle());
      valid = true;
   }
   if ( graph[3] != NULL ) {
      graph[3]->SetMarkerColor(3);
      mGraph[1]->Add(graph[3]);
      mGraph[1]->SetTitle(graph[3]->GetTitle());
      valid = true;
   }
   if ( valid ) mGraph[1]->Draw("A*");

   // Draw residuals
   plotDisplay->GetCanvas()->cd(3);
   mGraph[2] = new TMultiGraph(); valid = false;
   if ( graph[4] != NULL ) {
      graph[4]->SetMarkerColor(4);
      mGraph[2]->Add(graph[4]);
      mGraph[2]->SetTitle(graph[4]->GetTitle());
      valid = true;
   }
   if ( graph[5] != NULL ) {
      graph[5]->SetMarkerColor(3);
      mGraph[2]->Add(graph[5]);
      mGraph[2]->SetTitle(graph[5]->GetTitle());
      valid = true;
   }
   if ( valid ) mGraph[2]->Draw("A*");
   plotDisplay->GetCanvas()->Update();

   // Update Main Windows
   update();
}


void KpixGuiViewCalib::prevPlot_pressed() {
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


void KpixGuiViewCalib::nextPlot_pressed() {
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
   if ( serial == (kpixCalibData->kpixRunRead->getAsicCount()-1) ) serial = 0;

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


void KpixGuiViewCalib::writePlot_pressed() {
   int dirIndex = selDir->currentItem();
   int serial   = selSerial->currentItem();
   int gain     = selGain->currentItem();
   int channel  = selChannel->value();
   int bucket   = selBucket->value();
   parent->writeCalib(dirIndex,gain,serial,channel,bucket,graph);
   nextPlot_pressed();
}


void KpixGuiViewCalib::writeAll_pressed() {

   // Set Low End Values
   selSerial ->setCurrentItem(0);
   selGain->setCurrentItem(0);
   selChannel->setValue(0);
   selBucket->setValue(0);

   atLast = false;
   while ( !atLast ) writePlot_pressed();
   writePlot_pressed();
}


void KpixGuiViewCalib::writePdf_pressed() {

   stringstream tempName;
   stringstream cmd;

   int dirIndex = selDir->currentItem();
   int serial   = selSerial->currentItem();
   int gain     = selGain->currentItem();
   int channel  = selChannel->value();
   int bucket   = selBucket->value();

   // Generate file name based upon current settings
   tempName.str("");
   tempName << "calib_";
   if ( dirIndex == 0 ) tempName << "force_";
   if ( dirIndex == 1 ) tempName << "self_";
   if ( gain == 0 )     tempName << "norm_s";
   if ( gain == 1 )     tempName << "double_s";
   if ( gain == 2 )     tempName << "low_s";
   tempName << dec << setw(4) << setfill('0') << kpixCalibData->kpixRunRead->getAsic(serial)->getSerial() << "_c";
   tempName << dec << setw(4) << setfill('0') << channel << "_b";
   tempName << dec << setw(1) << bucket << ".ps";

   // Write Plot
   cout << "KpixGuiViewCalib::writePdf_pressed -> Wrote canvas to file " << tempName.str() << endl;
   plotDisplay->GetCanvas()->Print(tempName.str().c_str());
   cmd.str(""); cmd << "ps2pdf " << tempName.str();
   system(cmd.str().c_str());
}

