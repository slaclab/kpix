//-----------------------------------------------------------------------------
// File          : KpixGuiThreshView.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for threshold scan view GUI
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
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <qlineedit.h>
#include <qfiledialog.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qpushbutton.h>
#include <qcombobox.h>
#include <qcheckbox.h>
#include <qtable.h>
#include <qspinbox.h>
#include <qtabwidget.h>
#include <TQtWidget.h>
#include <TError.h>
#include <TH1D.h>
#include <TH2F.h>
#include <TF1.h>
#include <TStyle.h>
#include <TGraphAsymmErrors.h>
#include <math.h>
#include <KpixAsic.h>
#include <KpixThreshRead.h>
#include <KpixRunRead.h>
#include <KpixRunWrite.h>
#include <KpixRunVar.h>
#include "KpixGuiThreshView.h"
#include "KpixGuiEventStatus.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventData.h"
#include "KpixGuiError.h"
#include "KpixGuiSampleView.h"
#include "KpixGuiViewConfig.h"
using namespace std;

// Convert histogram to error plot
// Pass original histogram containing a bin for each threshold value.
// Pass total number of iterations for bayes divide.
// Returned plot will have millivolts on the x-axis
TGraphAsymmErrors *KpixGuiThreshView::convertHist (TH1D *passHist, unsigned int total, double *hint, 
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

   // Empty
   if ( newCount == 0 ) return(NULL);

   // Create new plot
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


// Constructor
KpixGuiThreshView::KpixGuiThreshView ( string baseDir, bool open ) : KpixGuiThreshViewForm() {

   stringstream temp;
   unsigned int x;

   this->inFileRoot        = NULL;
   this->outFileRoot       = NULL;
   this->baseDir           = baseDir;
   this->cmdType           = 0;
   this->isRunning         = false;
   this->calMin            = 0;
   this->calMax            = 0;
   this->calStep           = 1;
   this->minCalTime        = 0;
   this->maxCalTime        = 0;
   this->trigInh           = 0;
   this->threshCount       = 0;

   // Create error window
   errorMsg = new KpixGuiError(this);
   setEnabled(true);

   // Output Calibration Data
   threshData  = NULL;

   // Init asics
   this->asicCnt = 0;
   this->asic    = NULL;
   selSerial->clear();

   // Hidden windows at startup
   this->kpixGuiViewConfig = new KpixGuiViewConfig();
   this->kpixGuiSampleView = new KpixGuiSampleView();

   // Set default base dirs
   inFile->setText(this->baseDir);
   if ( open ) outFile->setText(inFile->text().section(".",0,-2)+"_fit.root");
   else outFile->setText(this->baseDir);

   // Clear histograms & graphs
   for (x=0; x<6;   x++) sumHist[x]  = NULL;
   for (x=0; x<256; x++) calGraph[x] = NULL;
   for (x=0; x<256; x++) origHist[x] = NULL;
   calPlot     = NULL;
   threshGraph = NULL;
   progressBar->setProgress(-1,100);

   // Setup Summary Table Columns
   summaryTable->setNumCols(5);
   summaryTable->horizontalHeader()->setLabel(0,"Ch");
   summaryTable->horizontalHeader()->setLabel(1,"Gain");
   summaryTable->horizontalHeader()->setLabel(2,"Mean");
   summaryTable->horizontalHeader()->setLabel(3,"Sigma");
   summaryTable->horizontalHeader()->setLabel(4,"Sigma(el)");

   // Adjust width
   for (x=0; x< 5; x++) summaryTable->setColumnWidth(x,80);

   // Update summary table
   summaryTable->setNumRows(1024);
   for(x=0; x<1024; x++) {
      temp.str("");
      temp << setw(4) << setfill('0') << dec << x;
      summaryTable->setText(x,0,temp.str());
   }

   // Auto open file
   if ( open ) inFileOpen_pressed();
}


// Delete
KpixGuiThreshView::~KpixGuiThreshView ( ) {
   inFileClose_pressed();
   delete kpixGuiViewConfig;
   delete kpixGuiSampleView;
}


// Select an input file for opening
void KpixGuiThreshView::inFileBrowse_pressed() {

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

      // Default Output File
      outFile->setText(temp.section(".",0,-2)+"_fit.root");
   }
   delete(fd);
   inFileBrowse->setDown(false);
}


// Open the input file
void KpixGuiThreshView::inFileOpen_pressed() {
   if ( ! isRunning ) {
      reFitEn->setChecked(false);
      setEnabled(false);
      cmdType = CmdFileOpen;
      isRunning = true;
      QThread::start();
   }
}


// Close the input file
void KpixGuiThreshView::inFileClose_pressed() {
   unsigned int x;
   setEnabled(false);

   // Close sub-windows
   kpixGuiViewConfig->close();
   kpixGuiSampleView->close();
      
   // No FPGA/ASIC Entries
   kpixGuiViewConfig->setRunData(NULL);
   kpixGuiSampleView->setRunData(NULL);

   // Free asic list and calibration data
   for (x=0; x< asicCnt; x++) delete threshData[x];
   if ( asic != NULL ) free(asic);
   if ( threshData != NULL ) free(threshData);
   asic=NULL;
   threshData=NULL;
   asicCnt = 0;

   // Close file
   if (inFileRoot != NULL) delete inFileRoot;
   inFileRoot = NULL;

   // Delete old plots
   sourceCanvas->GetCanvas()->Clear();
   calCanvas->GetCanvas()->Clear();
   fitCanvas->GetCanvas()->Clear();
   summaryCanvas->GetCanvas()->Clear();
   for (x=0; x<256; x++) {
      if ( origHist[x] != NULL ) { delete origHist[x]; origHist[x] = NULL; }
      if ( calGraph[x] != NULL ) { delete calGraph[x]; calGraph[x] = NULL; }
   }
   if ( calPlot     != NULL ) { delete calPlot; calPlot = NULL; }
   if ( threshGraph != NULL ) { delete threshGraph; threshGraph = NULL; }
   for (x=0; x<6; x++) if ( sumHist[x] != NULL ) { delete sumHist[x]; sumHist[x] = NULL; }
   sourceCanvas->GetCanvas()->Update();
   calCanvas->GetCanvas()->Update();
   fitCanvas->GetCanvas()->Update();
   summaryCanvas->GetCanvas()->Update();

   // Set flags, update buttons and update display
   setEnabled(true);
}


// Select output file
void KpixGuiThreshView::outFileBrowse_pressed() {
   QString temp;

   // Select output file
   QFileDialog *fd = new QFileDialog(this,"Output Root File",TRUE);
   fd->setFilter("Root Files (*.root)");
   fd->setViewMode(QFileDialog::Detail);
   fd->setMode(QFileDialog::AnyFile);

   // Set Default
   if ( outFile->text() != "" ) fd->setSelection(outFile->text());

   // File was selected
   if ( fd->exec() == QDialog::Accepted ) {
      temp      = fd->selectedFile();

      // Set output File
      outFile->setText(temp);
   }
   delete(fd);
   outFileBrowse->setDown(false);
}


void KpixGuiThreshView::viewConfig_pressed() {
   kpixGuiViewConfig->show();
}


void KpixGuiThreshView::viewSamples_pressed() {
   kpixGuiSampleView->show();
}


void KpixGuiThreshView::autoWriteAll_pressed() {
   if ( ! isRunning ) {
      kpixGuiViewConfig->close();
      kpixGuiSampleView->close();
      setEnabled(false);
      cmdType = CmdFileWrite;
      isRunning = true;
      QThread::start();
   }
}


void KpixGuiThreshView::writePdf_pressed() {
   stringstream       temp, cmd;
   unsigned int       gain;
   unsigned int       serial;
   unsigned int       channel;

   // Get current entries
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();

   // Determine which tab is open
   switch ( calTab->currentPageIndex() ) {

      // Summary Plot
      case 1: 
         temp.str("");
         temp << "summary_";
         if ( gain == 0 )     temp << "norm";
         if ( gain == 1 )     temp << "double";
         if ( gain == 2 )     temp << "low";
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         summaryCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;

      // Source Histograms
      case 2: 
         temp.str("");
         temp << "orig_";
         if ( gain == 0 )     temp << "norm_s";
         if ( gain == 1 )     temp << "double_s";
         if ( gain == 2 )     temp << "low_s";
         temp << dec << setw(4) << setfill('0') << asic[serial]->getSerial() << "_c";
         temp << dec << setw(4) << setfill('0') << channel;
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         sourceCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;

      // Calibration Curves
      case 3: 
         temp.str("");
         temp << "cal_";
         if ( gain == 0 )     temp << "norm_s";
         if ( gain == 1 )     temp << "double_s";
         if ( gain == 2 )     temp << "low_s";
         temp << dec << setw(4) << setfill('0') << asic[serial]->getSerial() << "_c";
         temp << dec << setw(4) << setfill('0') << channel;
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         calCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;

      // Fit Results
      case 4: 
         temp.str("");
         temp << "fit_";
         if ( gain == 0 )     temp << "norm_s";
         if ( gain == 1 )     temp << "double_s";
         if ( gain == 2 )     temp << "low_s";
         temp << dec << setw(4) << setfill('0') << asic[serial]->getSerial() << "_c";
         temp << dec << setw(4) << setfill('0') << channel;
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         fitCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;
   }
}


// Set Button Enables
void KpixGuiThreshView::setEnabled(bool enable) {

   // These buttons depend on file open state
   viewConfig->setEnabled((inFileRoot!=NULL)?enable:false);
   viewSamples->setEnabled((inFileRoot!=NULL)?enable:false);
   reFitEn->setEnabled((inFileRoot!=NULL)?enable:false);
   selSerial->setEnabled((inFileRoot!=NULL)?enable:false);
   selGain->setEnabled((inFileRoot!=NULL)?enable:false);
   selChannel->setEnabled((inFileRoot!=NULL)?enable:false);
   prevPlot->setEnabled((inFileRoot!=NULL)?enable:false);
   nextPlot->setEnabled((inFileRoot!=NULL)?enable:false);
   calFitMin->setEnabled((inFileRoot!=NULL)?enable:false);
   calFitMax->setEnabled((inFileRoot!=NULL)?enable:false);
   calTimeMin->setEnabled((inFileRoot!=NULL)?enable:false);
   calTimeMax->setEnabled((inFileRoot!=NULL)?enable:false);
   calHint->setEnabled((inFileRoot!=NULL)?enable:false);
   threshTimeMin->setEnabled((inFileRoot!=NULL)?enable:false);
   threshTimeMax->setEnabled((inFileRoot!=NULL)?enable:false);
   threshHint->setEnabled((inFileRoot!=NULL)?enable:false);
   fitDebug->setEnabled((inFileRoot!=NULL)?enable:false);
   voltConvert->setEnabled((inFileRoot!=NULL)?enable:false);
   inFileOpen->setEnabled((inFileRoot!=NULL)?false:enable);
   inFileClose->setEnabled((inFileRoot!=NULL)?enable:false);
   inFileBrowse->setEnabled((inFileRoot!=NULL)?false:enable);
   inFile->setEnabled((inFileRoot!=NULL)?false:enable);
   outFileBrowse->setEnabled(enable);
   outFile->setEnabled(enable);
   fitSaveAll->setEnabled((inFileRoot!=NULL)?enable:false);
   writePdf->setEnabled((inFileRoot!=NULL)?enable:false);
   sourceEn->setEnabled((inFileRoot!=NULL)?enable:false);
}


// Read and Fit plot data
void KpixGuiThreshView::readFitData(unsigned int gain, unsigned int serial, unsigned int channel, 
                                    bool fitEn, bool writeEn, bool dispEn ) {
   unsigned int      x;
   KpixGuiEventData  *data;
   TF1               *fitFunc;
   unsigned int      cal;
   TH2F              *torigHist[256];
   TGraphAsymmErrors *tcalGraph[256];
   TGraphAsymmErrors *tthreshGraph;
   TGraph            *tcalPlot;
   double            hint;
   double            min,max,lmin,lmax;
   TH1D              *tempHist;
   TH1D              *addHist;
   unsigned int      histCount, calCnt;
   double            calX[256], calY[256];
   unsigned int      serNum;
   void              *plots[2];

   // Init plots
   tthreshGraph = NULL;
   tcalPlot     = NULL;
   addHist      = NULL;
   for (x=0; x<256; x++) {
      torigHist[x] = NULL;
      tcalGraph[x] = NULL;
   }

   // Create fitting function
   if ( asic[serial]->getSerial() >= 7 ) 
      fitFunc = new TF1("fit","(0.5)*TMath::Erfc(([0]-x)/(sqrt(2.0)*[1]))");
   else
      fitFunc = new TF1("fit","(0.5)*TMath::Erfc((x-[0])/(sqrt(2.0)*[1]))");
   fitFunc->SetParNames("Mean", "Sigma");

   // Get original combined plots
   for (cal=calMin; cal <= calMax; cal += calStep) 
      torigHist[cal] = inFileRoot->getThreshScan("ThreshScan",gain,asic[serial]->getSerial(),channel,cal);

   // Use plots unmodified
   if ( ! fitEn ) {
      tcalPlot = inFileRoot->getThreshGain("ThreshScan",gain,asic[serial]->getSerial(),channel);
      tthreshGraph = inFileRoot->getThreshCurve("ThreshScan",gain,asic[serial]->getSerial(),channel);
      for (cal=calMin; cal <= calMax; cal += calStep) 
         tcalGraph[cal] = inFileRoot->getThreshCal("ThreshScan",gain,asic[serial]->getSerial(),channel,cal);
   }

   // Re-Fit Plots
   else {
      histCount = 0;
      calCnt    = 0;
      min       = -1;
      max       = -1;
      addHist   = NULL;

      // For each calibration value
      for (cal=calMin; cal <= calMax; cal += calStep) {

         // Original hist is not valid
         if ( torigHist[cal] == NULL ) continue;

         // Create Asym Calibration Graph
         tcalGraph[cal] = convertHist(torigHist[cal]->ProjectionX("temp",calTimeMin->value(),calTimeMax->value()),
                                      threshCount,&hint,&lmin,&lmax,fitDebug->isChecked(),voltConvert->isChecked());

         // Valid Graph
         if ( tcalGraph[cal] != NULL ) {

            // Set title
            tcalGraph[cal]->SetTitle(KpixThreshRead::genPlotTitle("Thresh Graph Cal",gain,
                                     asic[serial]->getSerial(),channel,cal).c_str());

            // Determine min/max for all channels
            if ( min == -1 || lmin < min ) min = lmin;
            if ( max == -1 || lmax > max ) max = lmax;

            // Set Fit Hint
            fitFunc->SetParameter(0,hint);
            fitFunc->SetParLimits(0,lmin,lmax);
            fitFunc->SetParameter(1,calHint->text().toDouble());

            // Attempt to fit
            if ( tcalGraph[cal]->Fit(fitFunc,(fitDebug->isChecked()?"":"q")," ",lmin,lmax) != 0 ||
                 (tcalGraph[cal]->GetFunction("fit")->GetParameter(0) < 0 && !fitDebug->isChecked()) ||
                 (tcalGraph[cal]->GetFunction("fit")->GetParameter(1) < 0 && !fitDebug->isChecked())) {
               delete tcalGraph[cal]->GetFunction("fit");
               if ( fitDebug->isChecked() ) cout << "Fit Function Deleted" << endl;

            }
            else {
               calX[calCnt] = KpixAsic::computeCalibCharge(0,cal,asic[serial]->getCntrlPosPixel(false),asic[serial]->getCntrlCalibHigh(false));
               calY[calCnt] = tcalGraph[cal]->GetFunction("fit")->GetParameter(0);
               calCnt++;
            }
         }

         // Create Treshold Plot Using Cal Value
         tempHist = torigHist[cal]->ProjectionX("proj",threshTimeMin->value(),threshTimeMax->value());

         // Valid plot
         if ( tempHist != NULL ) {
            histCount += threshCount;

            // Keep first plot, add others
            if ( addHist == NULL ) {
               addHist = tempHist;
               addHist->SetName("sum");
            } else {
               addHist->Add(tempHist);
               delete tempHist;
            }
         }
      }

      // Adjust min&max range of calibration plots
      min -= 20; max += 20;
      for (cal=calMin; cal <= calMax; cal += calStep)
         if ( tcalGraph[cal] != NULL ) tcalGraph[cal]->GetXaxis()->SetRangeUser(min,max);

      // Create thresh hist graph
      if ( addHist != NULL ) {
         tthreshGraph = convertHist(addHist,histCount,&hint,&min,&max,fitDebug->isChecked(),voltConvert->isChecked());
         tthreshGraph->SetTitle(KpixThreshRead::genPlotTitle("Thresh Graph",gain,asic[serial]->getSerial(),channel).c_str());

         // Set Fit Hint
         fitFunc->SetParameter(0,hint);
         fitFunc->SetParLimits(0,min,max);
         fitFunc->SetParameter(1,threshHint->text().toDouble());

         // Attempt to fit
         if ( tthreshGraph->Fit(fitFunc,fitDebug->isChecked()?"":"q","",min,max) != 0 ||
              tthreshGraph->GetFunction("fit")->GetParameter(0) < 0 ||
              tthreshGraph->GetFunction("fit")->GetParameter(1) < 0 ) {
            delete tthreshGraph->GetFunction("fit");
         }
         tthreshGraph->GetXaxis()->SetRangeUser(min-20,max+20);
      }

      // Create and fit calibration plot
      if ( calCnt > 0 ) {
         tcalPlot = new TGraph(calCnt,calX,calY);
         tcalPlot->SetTitle(KpixThreshRead::genPlotTitle("Thresh Cal",gain,asic[serial]->getSerial(),channel).c_str());
         if ( tcalPlot->Fit("pol1","q","",calFitMin->text().toDouble()*1e-15,calFitMax->text().toDouble()*1e-15) != 0 
            || tcalPlot->GetFunction("pol1")->GetParameter(1) > 0)
            delete tcalPlot->GetFunction("pol1");
      }
   }

   // Init channel data
   threshData[serial]->mean[gain][channel]  = 0;
   threshData[serial]->sigma[gain][channel] = 0;
   threshData[serial]->gain[gain][channel]  = 0;
   for (x=0; x<256; x++) {
      threshData[serial]->calMean[gain][channel][x]  = 0;
      threshData[serial]->calSigma[gain][channel][x]  = 0;
   }

   // Extract fit results from calibration plots
   for (cal=calMin; cal <= calMax; cal += calStep) {

      // Fit exists, extract parameters
      if ( tcalGraph[cal] != NULL && tcalGraph[cal]->GetFunction("fit") != NULL ) {
         threshData[serial]->calMean[gain][channel][cal]  = tcalGraph[cal]->GetFunction("fit")->GetParameter(0);
         threshData[serial]->calSigma[gain][channel][cal] = tcalGraph[cal]->GetFunction("fit")->GetParameter(1);
      }
   }

   // Extract fit result from calibration plot
   if ( tcalPlot != NULL && tcalPlot->GetFunction("pol1") != NULL ) 
      threshData[serial]->gain[gain][channel] = -1 * tcalPlot->GetFunction("pol1")->GetParameter(1);

   // Extract fit result from threshold plot
   if ( tthreshGraph != NULL && tthreshGraph->GetFunction("fit") != NULL ) {
      threshData[serial]->mean[gain][channel]  = tthreshGraph->GetFunction("fit")->GetParameter(0);
      threshData[serial]->sigma[gain][channel] = tthreshGraph->GetFunction("fit")->GetParameter(1);
   }

   // Write if enabled
   if ( writeEn ) {

      // Get serial number
      serNum = asic[serial]->getSerial();

      // Write graphs to file
      outFileRoot->setDir("ThreshScan");
      if ( tthreshGraph != NULL ) 
         tthreshGraph->Write(KpixThreshRead::genPlotName("thresh_curve",gain,serNum,channel).c_str());
      if ( tcalPlot != NULL ) 
         tcalPlot->Write(KpixThreshRead::genPlotName("thresh_gain",gain,serNum,channel).c_str());
      for (x=calMin; x <= calMax; x+=calStep) {
         if ( tcalGraph[x] != NULL ) 
            tcalGraph[x]->Write(KpixThreshRead::genPlotName("thresh_cal",gain,serNum,channel,x).c_str());
         if ( torigHist[x] != NULL ) 
            torigHist[x]->Write();
      }
      outFileRoot->setDir("/");
   }

   if ( fitFunc != NULL ) delete fitFunc;

   // Send plot data to main thread
   if ( dispEn ) {

      // Don't update source histograms if flag is not selected
      if ( ! sourceEn->isChecked() ) {
         for (x=0; x<256; x++) {
            if ( torigHist[x] != NULL ) delete torigHist[x];
            torigHist[x] = NULL;
         }
      }

      // Original Histogram
      data = new KpixGuiEventData(DataOrigHist,256,(void**)torigHist);
      QApplication::postEvent(this,data);

      // Calibration Graphs
      data = new KpixGuiEventData(DataCalGraph,256,(void**)tcalGraph);
      QApplication::postEvent(this,data);

      // Threshold Plots
      plots[0] = (void *)tcalPlot;
      plots[1] = (void *)tthreshGraph;
      data = new KpixGuiEventData(DataThreshGraph,2,plots);
      QApplication::postEvent(this,data);
   }
   else {
      if ( tthreshGraph != NULL ) delete tthreshGraph;
      if ( tcalPlot     != NULL ) delete tcalPlot;
      for (x=0; x<256; x++) {
         if ( torigHist[x] != NULL ) delete torigHist[x];
         if ( tcalGraph[x] != NULL ) delete tcalGraph[x];
      }
   }
}


// Update summary plots
void KpixGuiThreshView::updateSummary () {
   unsigned int     x, chCount, locChannel;
   stringstream     temp;
   string           temp2;
   KpixGuiEventData *data;
   TH1F             *newHist[6];
   double           histMin[6];
   double           histMax[6];
   unsigned int     serial;
   unsigned int     gain;
   double           value;

   // Get Channel Count
   chCount = asic[0]->getChCount();

   // Get directory, serial number and gain settings
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();

   // Determine Title Append
   temp.str("");
   if ( gain == 0 ) temp << "Norm, ";
   if ( gain == 1 ) temp << "Double, ";
   if ( gain == 2 ) temp << "Low, ";
   temp << "KPIX=" << setfill('0') << dec << setw(4) << asic[serial]->getSerial();

   // Recreate newHistograms
   temp2 = "Gain, " + temp.str();
   newHist[0]  = new TH1F("gain",temp2.c_str(),100000,0,100e15);
   newHist[0]->SetDirectory(0);
   histMin[0] = 100e15;
   histMax[0] = 0;

   temp2 = "Mean, " + temp.str();
   newHist[1]  = new TH1F("mean",temp2.c_str(),2550,0,2550);
   newHist[1]->SetDirectory(0);
   histMin[1] = 2550;
   histMax[1] = 0;

   temp2 = "Sigma, " + temp.str();
   newHist[2]  = new TH1F("sigma",temp2.c_str(),50,0,50);
   newHist[2]->SetDirectory(0);
   histMin[2] = 50;
   histMax[2] = 0;

   temp2 = "Sigma (el), " + temp.str();
   newHist[3]  = new TH1F("sigma_el",temp2.c_str(),200,0,100000);
   newHist[3]->SetDirectory(0);
   histMin[3] = 100000;
   histMax[3] = 0;

   temp2 = "Cal Sigma, " + temp.str();
   newHist[4]  = new TH1F("csigma",temp2.c_str(),500,0,50);
   newHist[4]->SetDirectory(0);
   histMin[4] = 50;
   histMax[4] = 0;

   temp2 = "Cal Sigma (el), " + temp.str();
   newHist[5]  = new TH1F("csigma_el",temp2.c_str(),2000,0,100000);
   newHist[5]->SetDirectory(0);
   histMin[5] = 100000;
   histMax[5] = 0;

   // Get data
   for (locChannel=0; locChannel < chCount; locChannel++) {

      if ( threshData[serial]->gain[gain][locChannel] != 0 ) {
         value = threshData[serial]->gain[gain][locChannel];
         if ( value > histMax[0] ) histMax[0] = value;
         if ( value < histMin[0] ) histMin[0] = value;
         newHist[0]->Fill(value);
      }

      if ( threshData[serial]->mean[gain][locChannel] != 0 ) {
         value = threshData[serial]->mean[gain][locChannel];
         if ( value > histMax[1] ) histMax[1] = value;
         if ( value < histMin[1] ) histMin[1] = value;
         newHist[1]->Fill(value);
      }
      if ( threshData[serial]->sigma[gain][locChannel] != 0 ) {
         value = threshData[serial]->sigma[gain][locChannel];
         if ( value > histMax[2] ) histMax[2] = value;
         if ( value < histMin[2] ) histMin[2] = value;
         newHist[2]->Fill(value);
      }
      for (x=0; x<256; x++) {
         if ( threshData[serial]->calSigma[gain][locChannel][x] != 0 ) {
            value = threshData[serial]->calSigma[gain][locChannel][x];
            if ( value > histMax[4] ) histMax[4] = value;
            if ( value < histMin[4] ) histMin[4] = value;
            newHist[4]->Fill(value);
         }
      }

      // Electrons
      if ( threshData[serial]->gain[gain][locChannel] != 0 ) {
         if ( threshData[serial]->sigma[gain][locChannel] != 0 ) {
            value = ((threshData[serial]->sigma[gain][locChannel] / threshData[serial]->gain[gain][locChannel]) * 1e15*6240);
            if ( value > histMax[3] ) histMax[3] = value;
            if ( value < histMin[3] ) histMin[3] = value;
            newHist[3]->Fill(value);
         }
         for (x=0; x<256; x++) {
            if ( threshData[serial]->calSigma[gain][locChannel][x] != 0 ) {
               value = ((threshData[serial]->calSigma[gain][locChannel][x] / threshData[serial]->gain[gain][locChannel]) * 1e15*6240);
               if ( value > histMax[5] ) histMax[5] = value;
               if ( value < histMin[5] ) histMin[5] = value;
               newHist[5]->Fill(value);
            }
         }
      }
   }

   // Update Range
   for (x=0; x<6; x++) if ( newHist[x] != NULL ) newHist[x]->GetXaxis()->SetRangeUser(histMin[x],histMax[x]);

   // Pass plots to main thread
   data = new KpixGuiEventData(DataSummary,6,(void **)newHist);
   QApplication::postEvent(this,data);
}


void KpixGuiThreshView::closeEvent(QCloseEvent *e) {
   inFileClose_pressed();
   if ( kpixGuiViewConfig->close() &&
        kpixGuiSampleView->close() ) {
      inFileClose_pressed();
      e->accept();
   }
   else e->ignore();
}


void KpixGuiThreshView::selChanged() {
   if ( ! isRunning ) {
      setEnabled(false);
      cmdType = CmdReadOne;
      isRunning = true;
      QThread::start();
   }
}


void KpixGuiThreshView::prevPlot_pressed() {
   int channel, serial, chCount, gain;

   // Get Current Values
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();
   chCount  = asic[0]->getChCount();

   channel--;
   if ( channel == -1 ) {
      channel = chCount-1;
      gain--;
   }
   if ( gain == -1 ) {
      gain = 2;
      serial--;
   }
   if ( serial == -1 ) serial = asicCnt-2;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selGain->setCurrentItem(gain);
   selChanged();
}


void KpixGuiThreshView::nextPlot_pressed() {
   int channel, serial, chCount, gain;

   // Get Current Values
   gain     = selGain->currentItem();
   serial  = selSerial ->currentItem();
   channel = selChannel->value();
   chCount = asic[0]->getChCount();

   channel++;
   if ( channel == chCount ) {
      channel = 0;
      gain++;
   }
   if ( gain == 3 ) {
      gain = 0;
      serial++;
   }
   if ( serial == ((int)asicCnt-1) ) serial = 0;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selGain->setCurrentItem(gain);
   selChanged();
}


// Thread for command run
void KpixGuiThreshView::run() {
   KpixGuiEventStatus *event;
   KpixGuiEventError  *error;
   unsigned int       x;
   stringstream       temp, cmd;
   string             calTime;
   KpixRunVar         *runVar;
   unsigned int       curr, total;
   QString            qtemp;
   unsigned int       gain;
   unsigned int       serial;
   unsigned int       channel;
   unsigned int       bucket;
   unsigned int       calA, calB, calC, calD, calCnt;

   // Get current entries
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();

   // Which command
   try {
      switch ( cmdType ) {

         case CmdReadOne: 
            readFitData(gain,serial,channel,reFitEn->isChecked(),false,true);
            updateSummary();
            break;

         case CmdFileOpen:

            // Open File
            inFileRoot = new KpixThreshRead(inFile->text().ascii());
            gErrorIgnoreLevel = 5000; 

            // Create asics and calib data structures
            asicCnt   = inFileRoot->kpixRunRead->getAsicCount()-1;
            asic      = (KpixAsic **) malloc(sizeof(KpixAsic *)*asicCnt);
            threshData = (KpixGuiThreshViewData **) malloc(sizeof(KpixGuiThreshViewData *)*asicCnt);
            for (x=0; x<asicCnt; x++) {
               asic[x] = inFileRoot->kpixRunRead->getAsic(x);
               threshData[x] = new KpixGuiThreshViewData();
            }

            // Extract number of iterations
            runVar = inFileRoot->kpixRunRead->getRunVar("threshCount");
            if ( runVar != NULL ) threshCount = (unsigned int)runVar->value();

            // Extract Calibration Range
            runVar = inFileRoot->kpixRunRead->getRunVar("calEnd");
            if ( runVar != NULL ) calMin = (unsigned int)runVar->value();
            runVar = inFileRoot->kpixRunRead->getRunVar("calStart");
            if ( runVar != NULL ) calMax = (unsigned int)runVar->value();
            runVar = inFileRoot->kpixRunRead->getRunVar("calStep");
            if ( runVar != NULL ) calStep = (unsigned int)runVar->value();

            // Extract target bucket
            runVar = inFileRoot->kpixRunRead->getRunVar("targetBucket");
            if ( runVar != NULL ) bucket = (unsigned int)runVar->value();

            // Update calibration times
            inFileRoot->kpixRunRead->getAsic(0)->getCalibTime(&calCnt,&calA,&calB,&calC,&calD,false);

            // Compute time points
            switch (bucket) {
               case 0:
                  minCalTime = calA;
                  maxCalTime = calA + calB + 3;
                  break;
               case 1:
                  minCalTime = calB;
                  maxCalTime = calB + calC + 3;
                  break;
               case 2:
                  minCalTime = calC;
                  maxCalTime = calC + calD + 3;
                  break;
               case 3:
                  minCalTime = calD;
                  maxCalTime = 8192;
                  break;
               default: break;
            }

            // Get Trig Inhibit Time
            trigInh = inFileRoot->kpixRunRead->getAsic(0)->getTrigInh(false);

            // Loop through types
            total = 3*asicCnt*asic[0]->getChCount();
            for (gain=0; gain < 3; gain++) {
               for (serial=0; serial < asicCnt; serial++) {
                  for (channel=0; channel < asic[0]->getChCount(); channel++) {
                     readFitData(gain,serial,channel,false,false,false);
                     curr = (gain*asicCnt*asic[0]->getChCount()) + (serial*asic[0]->getChCount()) + channel;
                     event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,curr,total);
                     QApplication::postEvent(this,event);
                  }
               } 
            }

            gain     = 0;
            serial   = 0;
            channel  = 0;
            break;

         case CmdFileWrite:

            // Try to create directories leading up to this point
            x = 1;
            qtemp = outFile->text().section("/",0,x);
            while ( qtemp != outFile->text()) {
               mkdir (qtemp.ascii(),0755);
               x++;
               qtemp = outFile->text().section("/",0,x);
            }

            // Determine cal time
            calTime = inFileRoot->kpixRunRead->getRunCalib();
            if ( calTime == "" ) calTime = inFileRoot->kpixRunRead->getRunTime();

            // attempt to open output file
            outFileRoot = new KpixRunWrite(outFile->text().ascii(),
                                           inFileRoot->kpixRunRead->getRunName(),
                                           inFileRoot->kpixRunRead->getRunDescription(), calTime,
                                           inFileRoot->kpixRunRead->getRunTime(),
                                           inFileRoot->kpixRunRead->getEndTime());
            gErrorIgnoreLevel = 5000; 

            // Set Run Variables
            for (x=0; x < (unsigned int)inFileRoot->kpixRunRead->getRunVarCount(); x++) {
               runVar = inFileRoot->kpixRunRead->getRunVar(x);
               outFileRoot->addRunVar(runVar->name(),runVar->description(),runVar->value());
            }

            // Set FPGA
            outFileRoot->addFpga(inFileRoot->kpixRunRead->getFpga());

            // Set ASICs
            for (x=0; x < (unsigned int)inFileRoot->kpixRunRead->getAsicCount(); x++) 
               outFileRoot->addAsic(inFileRoot->kpixRunRead->getAsic(x));

            // Loop through types
            total = 3*asicCnt*asic[0]->getChCount();
            for (gain=0; gain < 3; gain++) {
               for (serial=0; serial < asicCnt; serial++) {
                  for (channel=0; channel < asic[0]->getChCount(); channel++) {
                     readFitData(gain,serial,channel,true,true, false);
                     curr = (gain*asicCnt*asic[0]->getChCount()) + (serial*asic[0]->getChCount()) + channel;
                     event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,curr,total);
                     QApplication::postEvent(this,event);
                  }
               }
            }
            gain     = 0;
            serial   = 0;
            channel  = 0;
            delete outFileRoot;
            updateSummary();
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
void KpixGuiThreshView::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError  *eventError;
   KpixGuiEventStatus *eventStatus;
   KpixGuiEventData   *eventData;
   stringstream       temp;
   unsigned int       x, y, chCount;
   unsigned int       gain;
   unsigned int       serial;
   unsigned int       channel;
   unsigned int       plotCnt, divX, divY;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_STATUS ) {
      eventStatus = (KpixGuiEventStatus *)event;

      // Event Type
      switch ( eventStatus->statusType ) {

         // Run is stopping
         case KpixGuiEventStatus::StatusDone:

            // File open
            if ( cmdType == CmdFileOpen && inFileRoot != NULL ) {

               // Update sub windows
               kpixGuiViewConfig->setRunData(inFileRoot->kpixRunRead);
               kpixGuiSampleView->setRunData(inFileRoot->kpixRunRead);

               // Update Kpix selection
               selSerial->clear();
               for (x=0; x < asicCnt; x++) {
                  temp.str("");
                  temp << asic[x]->getSerial();
                  selSerial->insertItem(temp.str(),x);
               }

               // Update range on channel spin box
               if ( asicCnt > 0 ) {
                  chCount = asic[0]->getChCount();
                  selChannel->setMaxValue( chCount-1 );
               }

               // Set to first values
               selSerial ->setCurrentItem(0);
               selChannel->setValue(0);
               selGain->setCurrentItem(0);

               // Set Threshold Fit Time
               threshTimeMin->setMinValue(trigInh);
               threshTimeMin->setMaxValue(minCalTime-1);
               threshTimeMin->setValue(trigInh+3);
               threshTimeMax->setMinValue(trigInh);
               threshTimeMax->setMaxValue(8192);
               threshTimeMax->setValue(trigInh+3);

               // Set Calibration Fit Max Time
               calTimeMin->setMinValue(trigInh);
               calTimeMin->setMaxValue(maxCalTime-1);
               calTimeMin->setValue(trigInh);
               calTimeMax->setMinValue(minCalTime);
               calTimeMax->setMaxValue(maxCalTime-1);
               calTimeMax->setValue(minCalTime+4);
               
               // Fit Range
               calFitMin->setText("0");
               calFitMax->setText("10");

               // Re-Start thread with read plot command
               cmdType = CmdReadOne;
               QThread::start();
            }
            else {
               setEnabled(true);
               isRunning = false;
            }
            progressBar->setProgress(-1,0);
            break;

         // Progress Update
         case KpixGuiEventStatus::StatusPrgMain:
            progressBar->setProgress(eventStatus->prgValue,eventStatus->prgTotal);
            break;
      }
      update();
   }


   // Data Event
   if ( event->type() == KPIX_GUI_EVENT_DATA ) {
      eventData = (KpixGuiEventData *)event;

      // Which data
      switch (eventData->id) {

         // Original Histograms
         case ( DataOrigHist ):

            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear canvas
            sourceCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            plotCnt = 0;
            for (x=0; x<256; x++) {
               if ( origHist[x] != NULL ) delete origHist[x];
               origHist[x] = (TH2F *)eventData->data[x];
               if ( origHist[x] != NULL ) plotCnt++;
            }

            // Determine plot arrangement
            divX = (int)sqrt(plotCnt);
            divY = divX;
            if (( divX * divY ) < plotCnt ) divY++;
            if (( divX * divY ) < plotCnt ) divX++;

            // Draw Plots
            sourceCanvas->GetCanvas()->Divide(divX,divY,.01,.01);
            y=0;
            for (x=0; x<256; x++) {
               sourceCanvas->GetCanvas()->cd(y+1);
               if ( origHist[x] != NULL ) {
                  origHist[x]->SetStats(false);
                  origHist[x]->Draw("lego");
                  y++;
               }
            }
            sourceCanvas->GetCanvas()->Update();
            break;

         // Cal Graph Histograms
         case ( DataCalGraph ):

            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear canvas
            calCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            plotCnt = 0;
            for (x=0; x<256; x++) {
               if ( calGraph[x] != NULL ) delete calGraph[x];
               calGraph[x] = (TGraphAsymmErrors *)eventData->data[x];
               if ( calGraph[x] != NULL ) plotCnt++;
            }

            // Determine plot arrangement
            divX = (int)sqrt(plotCnt);
            divY = divX;
            if (( divX * divY ) < plotCnt ) divY++;
            if (( divX * divY ) < plotCnt ) divX++;

            // Draw Plots
            calCanvas->GetCanvas()->Divide(divX,divY,.01,.01);
            y=0;
            for (x=0; x<256; x++) {
               calCanvas->GetCanvas()->cd(y+1);
               if ( calGraph[x] != NULL ) {
                  calGraph[x]->Draw("AP*");
                  y++;
               }
            }
            calCanvas->GetCanvas()->Update();
            break;

         // Threshold Plots
         case ( DataThreshGraph ):

            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear canvas
            fitCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            if ( calPlot     != NULL ) delete calPlot;
            calPlot = (TGraph *)eventData->data[0];
            if ( threshGraph != NULL ) delete threshGraph;
            threshGraph = (TGraphAsymmErrors *)eventData->data[1];

            // Draw Plots
            fitCanvas->GetCanvas()->Divide(1,2,.01,.01);
            fitCanvas->GetCanvas()->cd(1);
            if ( calPlot != NULL ) calPlot->Draw("A*");
            fitCanvas->GetCanvas()->cd(2);
            if ( threshGraph != NULL ) threshGraph->Draw("AP*");
            fitCanvas->GetCanvas()->Update();

            // Get current selection
            gain     = selGain->currentItem();
            serial   = selSerial->currentItem();
            channel  = selChannel->value();

            // Update fit values in main window
            temp.str("");
            temp << threshData[serial]->gain[gain][channel];
            threshGainVal->setText(temp.str());
            temp.str("");
            temp << threshData[serial]->mean[gain][channel];
            threshMeanVal->setText(temp.str());
            temp.str("");
            temp << threshData[serial]->sigma[gain][channel];
            threshSigmaVal->setText(temp.str());

            // Calibration Table
            calTable->setNumRows((((calMax-calMin)+1)/calStep)+1);
            y = 0;
            for (x=calMin; x <= calMax; x += calStep) {
               temp.str(""); temp << x;
               calTable->setText(y,0,temp.str());
               temp.str(""); temp << KpixAsic::computeCalibCharge(0,x,
                                                                  asic[serial]->getCntrlPosPixel(false),
                                                                  asic[serial]->getCntrlCalibHigh(false));
               calTable->setText(y,1,temp.str());
               temp.str(""); temp << threshData[serial]->calMean[gain][channel][x];
               calTable->setText(y,2,temp.str());
               temp.str(""); temp << threshData[serial]->calSigma[gain][channel][x];
               calTable->setText(y,3,temp.str());
               y++;
            }
            calTable->adjustColumn(0);
            calTable->adjustColumn(1);
            calTable->adjustColumn(2);
            calTable->adjustColumn(3);
            break;

         // Summary Plots
         case ( DataSummary ):
            
            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear Canvas
            summaryCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            for (x=0; x<6; x++) {
               if ( sumHist[x] != NULL ) delete sumHist[x];
               sumHist[x] = (TH1F *) eventData->data[x];
            }

            // Summary canvas
            summaryCanvas->GetCanvas()->Divide(2,3,.01,.01);
            for (x=0; x < 6; x++) {
               summaryCanvas->GetCanvas()->cd(x+1);
               if ( sumHist[x] != NULL ) sumHist[x]->Draw();
            }
            summaryCanvas->GetCanvas()->Update();

            // Get current selection
            gain     = selGain->currentItem();
            serial   = selSerial->currentItem();
            chCount  = asic[0]->getChCount();

            // Update table values
            for (channel=0; channel < chCount; channel++) {

               // Update Table
               temp.str(""); temp << threshData[serial]->gain[gain][channel];
               summaryTable->setText(channel,1,temp.str());
               temp.str(""); temp << threshData[serial]->mean[gain][channel];
               summaryTable->setText(channel,2,temp.str());
               temp.str(""); temp << threshData[serial]->sigma[gain][channel];
               summaryTable->setText(channel,3,temp.str());

               // Electron Values
               if ( threshData[serial]->gain[gain][channel] != 0 ) {
                  temp.str(""); temp << ((threshData[serial]->sigma[gain][channel] / 
                                          threshData[serial]->gain[gain][channel]) * 1e15*6240);
                  summaryTable->setText(channel,4,temp.str());
               }
               else summaryTable->setText(channel,4,"0");
            }
            break;
      }
      update();
   }

   // Error Event
   if ( event->type() == KPIX_GUI_EVENT_ERROR ) {
      eventError = (KpixGuiEventError *)event;
      errorMsg->showMessage(eventError->errorMsg);
      update();
   }
}


