//-----------------------------------------------------------------------------
// File          : KpixGuiThreshChan.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing Thresh Scan Plots
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
#include <TMinuit.h>
#include <TMath.h>
#include <qlineedit.h>
#include <qtabwidget.h>
#include <TQtWidget.h>
#include "KpixGuiThreshChan.h"
#include "KpixGuiThreshView.h"
#include "KpixGuiCalFit.h"
using namespace std;


// Constructor
KpixGuiThreshChan::KpixGuiThreshChan (KpixGuiThreshView *parent) : KpixGuiThreshChanForm() {
   unsigned int x;

   // Set Parent
   this->parent = parent;

   // Directory is blank
   threshRead = NULL;

   // Init graphs
   calPlot     = NULL;
   origHist    = NULL;
   threshGraph = NULL;
   for(x=0; x<256; x++) calGraph[x] = NULL;

   // Cal Range
   calMin  = 0;
   calMax  = 0;
   calStep = 1;

   // Cal Time Range
   minCalTime  = 0;
   maxCalTime  = 0;
   trigInh     = 0;
   threshCount = 0;

   // At last plot
   atLast = false;
}


// Delete CLass
KpixGuiThreshChan::~KpixGuiThreshChan () {
   unsigned int x;
   if ( calPlot     != NULL ) delete calPlot;
   if ( origHist    != NULL ) delete origHist;
   if ( threshGraph != NULL ) delete threshGraph;
   for(x=0; x<256; x++) if ( calGraph[x] != NULL ) delete calGraph[x];
}


// Update Kpix selection
void KpixGuiThreshChan::setThreshData(KpixThreshRead *kpixThreshData) {
   unsigned int x, calA, calB, calC, calD, calCnt;
   stringstream temp;
   KpixRunVar   *runVar;

   this->threshRead = kpixThreshData;
   selSerial->clear();

   if ( threshRead != NULL ) {

      // Update KPIX Box
      for (x=0; x < (unsigned int)(threshRead->kpixRunRead->getAsicCount()-1); x++) {
         temp.str("");
         temp << threshRead->kpixRunRead->getAsic(x)->getSerial();
         selSerial->insertItem(temp.str(),x);
      }

      // Select channel range
      if ( threshRead->kpixRunRead->getAsicCount() > 0 ) 
         selChannel->setMaxValue ( threshRead->kpixRunRead->getAsic(0)->getChCount()-1 );

      // Extract number of iterations
      runVar = threshRead->kpixRunRead->getRunVar("threshCount");
      if ( runVar != NULL ) threshCount = (unsigned int)runVar->value();

      // Extract Calibration Range
      runVar = threshRead->kpixRunRead->getRunVar("calEnd");
      if ( runVar != NULL ) calMin = (unsigned int)runVar->value();
      runVar = threshRead->kpixRunRead->getRunVar("calStart");
      if ( runVar != NULL ) calMax = (unsigned int)runVar->value();
      runVar = threshRead->kpixRunRead->getRunVar("calStep");
      if ( runVar != NULL ) calStep = (unsigned int)runVar->value();

      // Update calibration times
      threshRead->kpixRunRead->getAsic(0)->getCalibTime(&calCnt,&calA,&calB,&calC,&calD,false);

      // Compute time points
      minCalTime = calA;
      maxCalTime = calA + calB + 3;

      // Calibration Dac Value Range
      calDac->setMinValue(calMin);
      calDac->setValue(calMax);
      calDac->setMaxValue(calMax);
      calDac->setLineStep(calStep);

      // Get Trig Inhibit Time
      trigInh = threshRead->kpixRunRead->getAsic(0)->getTrigInh(false);

      // Set Threshold Fit Time
      threshTime->setMinValue(trigInh);
      threshTime->setMaxValue(minCalTime-1);
      threshTime->setValue(trigInh+3);

      // Set Calibration Fit Max Time
      calTime->setMinValue(minCalTime);
      calTime->setMaxValue(maxCalTime-1);
      calTime->setValue(minCalTime+4);
   }
}


// Show
void KpixGuiThreshChan::show() {
   if ( threshRead != NULL ) {
      KpixGuiThreshChanForm::show();
      updateDisplay();
   }
}


// Convert histogram to error plot
// Pass original histogram containing a bin for each threshold value.
// Pass total number of iterations for bayes divide.
// Returned plot will have millivolts on the x-axis
TGraphAsymmErrors *KpixGuiThreshChan::convertHist (TH1D *passHist, unsigned int total, double *hint, 
                                                   double *min, double *max, bool debug, bool convert ) {
   TGraphAsymmErrors *temp;
   TH1D              *tot;
   unsigned int      newCount;
   unsigned int      x;
   double            newX[256];
   double            newXlow[256];
   double            newXhigh[256];
   double            newY[256];
   double            newYlow[256];
   double            newYhigh[256];
   double            hintMin, hintMax;

   // Clone histogram to total hist
   tot = new TH1D(*passHist);

   // Fill each bin with the total count
   for (x=1; x<= (unsigned int)tot->GetNbinsX(); x++) tot->SetBinContent(x,total);

   // Create AsymErrors Plot
   temp = new TGraphAsymmErrors(passHist,tot,"w");
   delete passHist;
   delete tot;

   // Init min & max values
   *min    = -1; 
   *max    = -1;
   hintMin = -1;
   hintMax = -1;

   // Go through each point
   newCount = temp->GetN();
   for (x=0; x< newCount; x++) {

      // Set x errors to zero
      temp->SetPointEXhigh(x, 0.0);
      temp->SetPointEXlow(x, 0.0);

      // Get points for voltage conversion
      temp->GetPoint(x,newX[x],newY[x]);
      if ( convert ) newX[x] = KpixAsic::dacToVolt((unsigned char)newX[x])*1000.0;
      else newX[x] = newX[x] - 0.5;
      newXlow[x]  = 0;
      newXhigh[x] = 0;
      newYlow[x]  = temp->GetErrorYlow(x);
      newYhigh[x] = temp->GetErrorYhigh(x);

      // Debug output
      if ( debug ) {
         cout << setw(10) << setfill(' ') << x;
         cout << setprecision(4) << setw(10) << setfill(' ') << newX[x];
         cout << setprecision(4) << setw(10) << setfill(' ') << newY[x];
         cout << setprecision(4) << setw(10) << setfill(' ') << newYlow[x];
         cout << setprecision(4) << setw(10) << setfill(' ') << newYhigh[x];
         cout << endl;
      }

      // Find min value as last zero value moving from left to right
      if ( *min == -1 && newY[x] != 0 ) {
         if ( x > 0 ) *min = newX[x-1];
         else *min = newX[0];
      }

      // Find max value as the last 1 value moving from right to left
      if ( *max == -1 ) {
         if ( newY[x] == 1 ) *max = newX[x];
      }
      else if ( newY[x] < 1 ) *max = -1; // Reset if non 1 value found after max set

      // Find range for possible mean
      if ( newY[x] <= 0.15 ) hintMin = newX[x];
      if ( newY[x] >= 0.85 && hintMax == -1 ) hintMax = newX[x];
   }

   // Create converted graph
   delete temp;
   temp = new TGraphAsymmErrors(newCount,newX,newY,newXlow,newXhigh,newYlow,newYhigh);

   // make sure we always get a min and a max
   if ( *min == -1 ) *min = newX[0];
   if ( *max == -1 ) *max = newX[newCount-1];

   // Determine hint, Use max value if plot never reaches 100%
   if ( hintMax == -1 ) *hint = newX[newCount-1];
   else *hint = hintMin + (hintMax-hintMin)/2.0;

   // Debug
   if ( debug ) {
      cout << "Min =" << *min << endl;
      cout << "Max =" << *max << endl;
      cout << "Hint=" << *hint << endl;
   }

   // Return new plot
   return(temp);
}


void KpixGuiThreshChan::updateDisplay() {
   unsigned int channel, gain, serial, cal, x;
   unsigned int histCount;
   bool         first;
   TF1          *fitFunc;
   TH1D         *tempHist;
   TH1D         *sumHist;
   stringstream temp;
   unsigned int calCnt;
   double       calX[256], calY[256];
   double       gainVal, sigmaVal;
   double       hint;
   double       min,max,lmin,lmax;
   bool         debug;

   // Calib Data or directory not valid
   if ( threshRead == NULL ) 
      throw(string("KpixGuiThreshChan::updateDisplay -> Input File Not Open"));

   // Delete old plots
   if ( calPlot    != NULL ) delete calPlot; calPlot = NULL;
   if ( origHist   != NULL ) delete origHist; origHist = NULL;
   if ( threshGraph != NULL ) delete threshGraph; threshGraph = NULL;
   for(x=0; x<256; x++) {
      if ( calGraph[x] != NULL ) delete calGraph[x];
      calGraph[x] = NULL;
   }

   // Get Current Values
   serial  = selSerial ->currentItem();
   gain    = selGain->currentItem();
   channel = selChannel->value();

   // Update write buttons
   if ( parent->isThreshWritable(gain,serial,channel) ) {
      saveCurr->setEnabled(true);   
      saveAll->setEnabled(true);   
   } else {
      saveCurr->setEnabled(false);   
      saveAll->setEnabled(false);   
   }

   // Control enable of fit / cal Dac widgets
   if ( selMode->currentItem() == 0 ) {
      calDac->setEnabled(true);
      reFitEn->setEnabled(false);
      calTime->setEnabled(false);
      calHint->setEnabled(false);
      threshHint->setEnabled(false);
      threshTime->setEnabled(false);
   } else {
      calDac->setEnabled(!calSame->isChecked());
      reFitEn->setEnabled(true);
      calTime->setEnabled(reFitEn->isChecked());
      threshTime->setEnabled(reFitEn->isChecked());
      calHint->setEnabled(reFitEn->isChecked());
      threshHint->setEnabled(reFitEn->isChecked());
   }

   // Set fit options
   gStyle->SetOptFit(1111);

   // Create fitting function
   if ( threshRead->kpixRunRead->getAsic(serial)->getSerial() >= 7 ) 
      fitFunc = new TF1("fit","(0.5)*TMath::Erfc(([0]-x)/(sqrt(2.0)*[1]))");
   else
      fitFunc = new TF1("fit","(0.5)*TMath::Erfc((x-[0])/(sqrt(2.0)*[1]))");
   fitFunc->SetParNames("Mean", "Sigma");

   // Fit Plot View Mode
   if ( selMode->currentItem() == 1 ) {

      // Use plots unmodified
      if ( ! reFitEn->isChecked() ) {
      
         calPlot = threshRead->getThreshGain("ThreshScan",gain,       
                                             threshRead->kpixRunRead->getAsic(serial)->getSerial(),channel);
         threshGraph = threshRead->getThreshCurve("ThreshScan",gain,       
                                                 threshRead->kpixRunRead->getAsic(serial)->getSerial(),channel);
         for (cal=calMin; cal <= calMax; cal += calStep) {
            calGraph[cal] = threshRead->getThreshCal("ThreshScan",gain,
                                                     threshRead->kpixRunRead->getAsic(serial)->getSerial(), channel,cal);
         }
      }

      // Regenerate and fit plots
      else {

         // Process each calibration value
         histCount=0;
         calCnt=0;
         min = -1;
         max = -1;
         sumHist=NULL;
         for (cal=calMin; cal <= calMax; cal += calStep) {

            // Delete original histogram
            if ( origHist != NULL ) delete origHist;

            // Get original combined plot
            origHist = threshRead->getThreshScan("ThreshScan",gain,
                       threshRead->kpixRunRead->getAsic(serial)->getSerial(),
                       channel,cal);

            // Skip if histogram is not found
            if ( origHist == NULL ) continue;

            // Determine debug
            debug = (!calSame->isChecked()) && 
                    (cal == (unsigned int)calDac->value()) && 
                    fitDebug->isChecked();

            // Create Asym Calibration Graph
            calGraph[cal] = convertHist(origHist->ProjectionX("temp",0,calTime->value()),
                                        threshCount,&hint,&lmin,&lmax,debug,voltConvert->isChecked());

            // Set title
            calGraph[cal]->SetTitle(KpixThreshRead::genPlotTitle("Thresh Graph Cal",gain,
                                   threshRead->kpixRunRead->getAsic(serial)->getSerial(),
                                   channel,cal).c_str());

            // Determine min/max for all channels
            if ( min == -1 || lmin < min ) min = lmin;
            if ( max == -1 || lmax > max ) max = lmax;

            // Set Fit Hint
            fitFunc->SetParameter(0,hint);
            fitFunc->SetParLimits(0,lmin,lmax);
            fitFunc->SetParameter(1,calHint->text().toDouble());

            // Attempt to fit
            if ( calGraph[cal]->Fit(fitFunc,(debug?"":"q")," ",lmin,lmax) != 0 ||
                 (calGraph[cal]->GetFunction("fit")->GetParameter(0) < 0 && !debug) ||
                 (calGraph[cal]->GetFunction("fit")->GetParameter(1) < 0 && !debug)) {
               delete calGraph[cal]->GetFunction("fit");
               if ( debug ) cout << "Fit Function Deleted" << endl;
            }
            else {
               calX[calCnt] = KpixAsic::computeCalibCharge(0,cal,
                  threshRead->kpixRunRead->getAsic(serial)->getCntrlPosPixel(false),
                  threshRead->kpixRunRead->getAsic(serial)->getCntrlCalibHigh(false));
               calY[calCnt] = calGraph[cal]->GetFunction("fit")->GetParameter(0);
               calCnt++;
            }

            // Create Treshold Plot Using Cal Value
            tempHist = origHist->ProjectionX("proj",threshTime->value(),threshTime->value());
            histCount += threshCount;

            // Keep first plot, add others
            if ( sumHist == NULL ) {
               sumHist = tempHist;
               sumHist->SetName("sum");
            } else {
               sumHist->Add(tempHist);
               delete tempHist;
            }
         }

         // Adjust min&max range of calibration plots
         min -= 20; max += 20;
         for (cal=calMin; cal <= calMax; cal += calStep)
            if ( calGraph[cal] != NULL ) calGraph[cal]->GetXaxis()->SetRangeUser(min,max);

         // Create thresh hist graph
         if ( sumHist != NULL ) {
            threshGraph = convertHist(sumHist,histCount,&hint,&min,&max,fitDebug->isChecked(),voltConvert->isChecked());
            threshGraph->SetTitle(KpixThreshRead::genPlotTitle("Thresh Graph",gain,
                                  threshRead->kpixRunRead->getAsic(serial)->getSerial(),
                                  channel).c_str());

            // Set Fit Hint
            fitFunc->SetParameter(0,hint);
            fitFunc->SetParLimits(0,min,max);
            fitFunc->SetParameter(1,threshHint->text().toDouble());

            // Attempt to fit
            if ( threshGraph->Fit(fitFunc,fitDebug->isChecked()?"":"q","",min,max) != 0 ||
                 threshGraph->GetFunction("fit")->GetParameter(0) < 0 ||
                 threshGraph->GetFunction("fit")->GetParameter(1) < 0 ) {
               delete threshGraph->GetFunction("fit");
            }
            threshGraph->GetXaxis()->SetRangeUser(min-20,max+20);
         }

         // Create and fit calibration plot
         if ( calCnt > 0 ) {
            calPlot = new TGraph(calCnt,calX,calY);
            calPlot->SetTitle(KpixThreshRead::genPlotTitle("Thresh Cal",gain,
                              threshRead->kpixRunRead->getAsic(serial)->getSerial(),
                              channel).c_str());
            if ( calPlot->Fit("pol1","q") != 0 || calPlot->GetFunction("pol1")->GetParameter(1) > 0)
               delete calPlot->GetFunction("pol1");
         }
      }

      // Extract fit results from calibration plots
      calTable->setNumRows((((calMax-calMin)+1)/calStep)+1);
      x = 0;
      for (cal=calMin; cal <= calMax; cal += calStep) {

         // First two columns of table always valid
         temp.str(""); temp << cal;
         calTable->setText(x,0,temp.str());
         temp.str(""); temp << KpixAsic::computeCalibCharge(0,cal,
               threshRead->kpixRunRead->getAsic(serial)->getCntrlPosPixel(false),
               threshRead->kpixRunRead->getAsic(serial)->getCntrlCalibHigh(false));
         calTable->setText(x,1,temp.str());

         // Fit exists, extract parameters
         if ( calGraph[cal] != NULL && calGraph[cal]->GetFunction("fit") != NULL ) {
            temp.str(""); temp << calGraph[cal]->GetFunction("fit")->GetParameter(0);
            calTable->setText(x,2,temp.str());
            temp.str(""); temp << calGraph[cal]->GetFunction("fit")->GetParameter(1);
            calTable->setText(x,3,temp.str());
         } else {
            calTable->setText(x,2,"Fail");
            calTable->setText(x,3,"Fail");
         }
         x++;
      }
      calTable->adjustColumn(0);
      calTable->adjustColumn(1);
      calTable->adjustColumn(2);
      calTable->adjustColumn(3);

      // Extract fit result from calibration plot
      if ( calPlot != NULL && calPlot->GetFunction("pol1") != NULL ) {
         temp.str("");
         gainVal = calPlot->GetFunction("pol1")->GetParameter(1);
         temp << gainVal;
         threshGainVal->setText(temp.str());
      }
      else gainVal = 0;

      // Extract fit result from threshold plot
      if ( threshGraph != NULL && threshGraph->GetFunction("fit") != NULL ) {
         temp.str("");
         temp << threshGraph->GetFunction("fit")->GetParameter(0);
         threshMeanVal->setText(temp.str());
         sigmaVal = threshGraph->GetFunction("fit")->GetParameter(1);
         temp.str("");
         temp << sigmaVal;
         if ( gainVal != 0 ) temp << " (" << (sigmaVal/gainVal)*1e15*-6240 << ")";
         threshSigmaVal->setText(temp.str());
      } else {
         threshMeanVal->setText("Fail");
         threshSigmaVal->setText("Fail");
      }

      // Plot is divided into two main canvases
      plotDisplay->GetCanvas()->Clear();
      plotDisplay->GetCanvas()->Divide(1,2,.01,.01);
      plotDisplay->GetCanvas()->cd(1);

      // Plot calibration histograms, multiple histograms overlayed on the same canvas
      first = true;
      for (x=calMin; x <= calMax; x += calStep) 
         if ( calGraph[x] != NULL && (calSame->isChecked() || x == (unsigned int)calDac->value())) {
            if ( first ) calGraph[x]->Draw("AP*");
            else calGraph[x]->Draw("P*");
            first = false;
         }

      // Divide lower canvas into two
      plotDisplay->GetCanvas()->cd(2)->Divide(2,1,.01,.01);

      // Left Window Has Threshold Fit
      plotDisplay->GetCanvas()->cd(2)->cd(1);
      if ( threshGraph != NULL ) threshGraph->Draw("AP*");

      // Right Window Has Calibration Fit
      plotDisplay->GetCanvas()->cd(2)->cd(2);
      if ( calPlot != NULL ) calPlot->Draw("A*");
   }

   // View original hist mode
   else {
      origHist = threshRead->getThreshScan("ThreshScan",gain,
                                       threshRead->kpixRunRead->getAsic(serial)->getSerial(),
                                       channel,calDac->value());
      plotDisplay->GetCanvas()->Clear();
      plotDisplay->GetCanvas()->cd();
      if ( origHist != NULL ) {
         origHist->SetStats(false);
         origHist->Draw("lego");
      }
   }

   // Update Windows
   delete fitFunc;
   plotDisplay->GetCanvas()->Update();
   update();
}


void KpixGuiThreshChan::prevPlot_pressed() {
   int channel, gain, serial, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   gain    = selGain->currentItem();
   channel = selChannel->value();
   chCount = threshRead->kpixRunRead->getAsic(0)->getChCount();

   channel--;
   if ( channel == -1 ) {
      channel = chCount-1;
      gain--;
   }
   if ( gain == -1 ) {
      gain = 2;
      serial--;
   }
   if ( serial == -1 ) serial = threshRead->kpixRunRead->getAsicCount()-2;

   // Set Current Values
   selSerial->setCurrentItem(serial);
   selGain->setCurrentItem(gain);
   selChannel->setValue(channel);
   update();
}


void KpixGuiThreshChan::nextPlot_pressed() {
   int channel, gain, serial, chCount;

   // Get Current Values
   serial  = selSerial ->currentItem();
   gain    = selGain->currentItem();
   channel = selChannel->value();
   chCount = threshRead->kpixRunRead->getAsic(0)->getChCount();

   channel++;
   if ( channel == chCount ) {
      channel = 0;
      gain++;
   }
   if ( gain == 3 ) {
      gain = 0;
      serial++;
   }
   if ( serial == (threshRead->kpixRunRead->getAsicCount()-1) ) serial = 0;

   // Find out last
   if ( channel == (chCount-1) && gain == 2 && 
        serial == (int)(threshRead->kpixRunRead->getAsicCount()-2) ) atLast = true;

   // Set Current Values
   selSerial->setCurrentItem(serial);
   selGain->setCurrentItem(gain);
   selChannel->setValue(channel);
   update();
}


void KpixGuiThreshChan::writePdf_pressed() {

   stringstream tempName;
   stringstream cmd;
   
   int serial  = selSerial ->currentItem();
   int gain    = selGain->currentItem();
   int channel = selChannel->value();
   int cal     = calDac->value();

   // Generate file name based upon current settings
   tempName.str("");
   tempName << "thresh_";
   if ( gain == 0 )     tempName << "norm_s";
   if ( gain == 1 )     tempName << "double_s";
   if ( gain == 2 )     tempName << "low_s";
   tempName << dec << setw(4) << setfill('0') << threshRead->kpixRunRead->getAsic(serial)->getSerial() << "_c";
   tempName << dec << setw(4) << setfill('0') << channel;
   if ( ! calSame->isChecked() )  tempName << "_d" << setw(3) << setfill('0') << cal;
   tempName << ".ps";

   // Write Plot
   cout << "KpixGuiThreshChan::writePdf_pressed -> Wrote canvas to file " << tempName.str() << endl;
   plotDisplay->GetCanvas()->Print(tempName.str().c_str());
   cmd.str(""); cmd << "ps2pdf " << tempName.str();
   system(cmd.str().c_str());
}


void KpixGuiThreshChan::saveCurr_pressed() {
   int serial   = selSerial->currentItem();
   int gain     = selGain->currentItem();
   int channel  = selChannel->value();
   parent->writeThresh(gain,serial,channel,calGraph,threshGraph,calPlot);
   nextPlot_pressed();
}


void KpixGuiThreshChan::saveAll_pressed() {

   // Set re-git check box and select fit hist mode 
   selMode->setCurrentItem(1);
   reFitEn->setChecked(true);

   // Set Low End Values
   selSerial ->setCurrentItem(0);
   selGain->setCurrentItem(0);
   selChannel->setValue(0);

   atLast = false;
   while (!atLast) saveCurr_pressed();
   saveCurr_pressed();
}

