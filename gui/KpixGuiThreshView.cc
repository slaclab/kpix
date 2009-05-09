//-----------------------------------------------------------------------------
// File          : KpixGuiThreshView.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for thresh scan viewing
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
#include "KpixGuiThreshView.h"
using namespace std;


// Constructor
KpixGuiThreshView::KpixGuiThreshView ( string baseDir, bool open ) : KpixGuiThreshViewForm() {

   stringstream temp;

   this->inFileRoot        = NULL;
   this->inFileIsOpen      = false;
   this->outFileRoot       = NULL;
   this->outFileIsOpen     = false;
   this->baseDir           = baseDir;

   // Create error window
   errorMsg = new KpixGuiError(this);
   setEnabled(true);

   // Hidden windows at startup
   this->kpixGuiViewConfig = new KpixGuiViewConfig();
   this->kpixGuiThreshChan = new KpixGuiThreshChan(this);

   // Init data
   inThreshData = NULL;
   outThreshData = NULL;

   // Clear hist
   hist = NULL;

   // Set default base dirs
   inFile->setText(this->baseDir);
   if ( open ) outFile->setText(inFile->text().section(".",0,-2)+"_fit.root");
   else outFile->setText(this->baseDir);

   // Auto open file
   if ( open ) inFileOpen_pressed();

   // Auto update flag
   inAutoUpdate = false;
}


// Delete
KpixGuiThreshView::~KpixGuiThreshView ( ) {
   inFileClose_pressed();
   if ( hist != NULL ) delete hist;
   delete kpixGuiViewConfig;
   delete kpixGuiThreshChan;
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
   int          x,chCount,serial,gain,serNum,channel,cal;
   double       meanVal,sigmaVal,gainVal;
   KpixRunVar   *runVar;
   stringstream temp;

   if ( ! inFileIsOpen ) {
      try {
         inFileRoot = new KpixThreshRead(inFile->text().ascii());
         inFileIsOpen = true;
         gErrorIgnoreLevel = 5000; 

         // Update Kpix selection
         selSerial->clear();
         for (x=0; x < (inFileRoot->kpixRunRead->getAsicCount()-1); x++) {
            temp.str("");
            temp << inFileRoot->kpixRunRead->getAsic(x)->getSerial();
            selSerial->insertItem(temp.str(),x);
         }

         // Update Results Table
         chCount = inFileRoot->kpixRunRead->getAsic(0)->getChCount();
         resultsTable->setNumRows(chCount);
         for(x=0; x<chCount; x++) {
            temp.str("");
            temp << setw(4) << setfill('0') << dec << x;
            resultsTable->setText(x,0,temp.str());
         }

         // Extract Calibration Range
         runVar = inFileRoot->kpixRunRead->getRunVar("calEnd");
         if ( runVar != NULL ) calMin = (unsigned int)runVar->value();
         runVar = inFileRoot->kpixRunRead->getRunVar("calStart");
         if ( runVar != NULL ) calMax = (unsigned int)runVar->value();
         runVar = inFileRoot->kpixRunRead->getRunVar("calStep");
         if ( runVar != NULL ) calStep = (unsigned int)runVar->value();

         // Init Threshold Data
         selPlot->setCurrentItem(0);
         inThreshData = 
            (KpixGuiThreshFitData*)malloc(sizeof(KpixGuiThreshFitData)*((inFileRoot->kpixRunRead->getAsicCount()-1)));
         if ( inThreshData == NULL ) throw(string("KpixGuiThreshView::inFileOpen_pressed -> Malloc Error"));
         chCount = inFileRoot->kpixRunRead->getAsic(0)->getChCount();
         for (serial=0; serial < (inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
            serNum  = inFileRoot->kpixRunRead->getAsic(serial)->getSerial();
            for (gain=0; gain < 3; gain++) {
               for (channel=0; channel < chCount; channel++) {

                  // Get calibration data
                  inFileRoot->getThreshData (&meanVal,&sigmaVal,&gainVal,"ThreshScan",gain,serNum,channel);

                  // Set structure
                  inThreshData[serial].mean[gain][channel] = meanVal;
                  inThreshData[serial].sigma[gain][channel] = sigmaVal;
                  inThreshData[serial].gain[gain][channel] = gainVal;
                  inThreshData[serial].writeDone[gain][channel] = false;

                  // Get Calibration Sigmas
                  for (cal=calMin; cal <= (int)calMax; cal+=calStep) {
                     inFileRoot->getCalSigma (&sigmaVal,"ThreshScan",gain,serNum,channel,cal);
                     inThreshData[serial].calSigma[gain][channel][cal] = sigmaVal;
                  }
               }
               if ( (channel+1)%8 == 0 ) {
                  selSerial->setCurrentItem(serial);
                  selGain->setCurrentItem(gain);
                  updateDisplay();
               }
            }
         }

         // Update windows
         kpixGuiViewConfig->setRunData(inFileRoot->kpixRunRead);
         kpixGuiThreshChan->setThreshData(inFileRoot);
      } catch (string error) {
         errorMsg->showMessage(error);
      }
   }
   setEnabled(true);
   updateDisplay();
}


// Close the input file
void KpixGuiThreshView::inFileClose_pressed() {

   // Close the output file if open
   outFileClose_pressed();

   if ( inFileIsOpen ) {

      // Close sub-windows
      kpixGuiViewConfig->close();
      kpixGuiThreshChan->close();
      
      // No FPGA/ASIC Entries
      kpixGuiViewConfig->setRunData(NULL);
      kpixGuiThreshChan->setThreshData(NULL);

      // Close file
      delete inFileRoot;
      free(inThreshData);
   }

   // Set flags, update buttons and update display
   inFileIsOpen = false;
   setEnabled(true);
   updateDisplay();
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


// Open output file
void KpixGuiThreshView::outFileOpen_pressed() {
   unsigned int x,serial,gain,channel,chCount,serNum;
   KpixRunVar   *runVar;
   QString      temp;
   string       calTime;

   try {
      if ( inFileIsOpen && ! outFileIsOpen ) {

         // Close usb windows
         kpixGuiViewConfig->close();
         kpixGuiThreshChan->close();

         // Try to create directories leading up to this point
         x = 1;
         temp = outFile->text().section("/",0,x);
         while ( temp != outFile->text()) {
            mkdir (temp.ascii(),0755);
            x++;
            temp = outFile->text().section("/",0,x);
         }

         // Determine cal time
         calTime = inFileRoot->kpixRunRead->getRunCalib();

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
      
         outFileIsOpen = true;

         // Init threshold data
         outFileRoot->setDir("ThreshScan");
         outThreshData = 
            (KpixGuiThreshFitData*)malloc(sizeof(KpixGuiThreshFitData)*((inFileRoot->kpixRunRead->getAsicCount()-1)));
         if ( outThreshData == NULL ) throw(string("KpixGuiThreshView::outFileOpen_pressed -> Malloc Error"));
         chCount = inFileRoot->kpixRunRead->getAsic(0)->getChCount();
         for (serial=0; serial < (unsigned int)(inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
            serNum  = inFileRoot->kpixRunRead->getAsic(serial)->getSerial();
            for (gain=0; gain < 3; gain++) {
               for (channel=0; channel < chCount; channel++) {
                  outThreshData[serial].mean[gain][channel] = 0;
                  outThreshData[serial].sigma[gain][channel] = 0;
                  outThreshData[serial].gain[gain][channel] = 0;
                  outThreshData[serial].writeDone[gain][channel] = false;
               }
            }
         }
         outFileRoot->setDir("/");
      }
   } catch (string error) {
      errorMsg->showMessage(error);
   }
   setEnabled(true);
   updateDisplay();
}


void KpixGuiThreshView::outFileClose_pressed() {
   if ( outFileIsOpen ) {
      kpixGuiViewConfig->close();
      kpixGuiThreshChan->close();
      delete(outFileRoot);
      free(outThreshData);
   }
   outFileIsOpen = false;
   setEnabled(true);
   updateDisplay();
}


void KpixGuiThreshView::viewChan_pressed() {
   kpixGuiThreshChan->show();
}


void KpixGuiThreshView::viewConfig_pressed() {
   kpixGuiViewConfig->show();
}


// Set Button Enables
void KpixGuiThreshView::setEnabled(bool enable) {

   // These buttons depend on file open state
   inFileOpen->setEnabled(inFileIsOpen?false:enable);
   inFileClose->setEnabled(inFileIsOpen?enable:false);
   inFileBrowse->setEnabled(inFileIsOpen?false:enable);
   inFile->setEnabled(inFileIsOpen?false:enable);
   outFileOpen->setEnabled(inFileIsOpen?(outFileIsOpen?false:enable):false);
   outFileClose->setEnabled(inFileIsOpen?(outFileIsOpen?enable:false):false);
   outFileBrowse->setEnabled(inFileIsOpen?(outFileIsOpen?false:enable):false);
   outFile->setEnabled(inFileIsOpen?(outFileIsOpen?false:enable):false);
   viewConfig->setEnabled(inFileIsOpen?enable:false);
   viewChan->setEnabled(inFileIsOpen?enable:false);
   selSerial->setEnabled(inFileIsOpen?enable:false);
   selGain->setEnabled(inFileIsOpen?enable:false);
   selPlot->setEnabled(inFileIsOpen?enable:false);
   writePdf->setEnabled(inFileIsOpen?enable:false);
   autoWriteAll->setEnabled(outFileIsOpen?enable:false);
}


void KpixGuiThreshView::updateDisplay() {
   unsigned int serial,gain,channel,chCount, cal;
   double       gainVal, meanVal, sigmaVal;
   double       *calVals;
   stringstream temp;
   string       temp2;
   double       fillValue, fillMin, fillMax;

   // Delete old histogram
   if ( hist != NULL ) {
      delete hist;
      hist = NULL;
   }
   isNonZero = false;
   fillValue = 0;
   fillMax   = 0;
   fillMin   = 0;

   // Only update if input file exists
   if ( inFileIsOpen ) {

      // Get Channel Count
      chCount = inFileRoot->kpixRunRead->getAsic(0)->getChCount();

      // Get current selection
      serial = selSerial->currentItem();
      gain   = selGain->currentItem();

      // Determine Title Append
      temp.str("");
      if ( gain == 0 ) temp << "Norm, ";
      if ( gain == 1 ) temp << "Double, ";
      if ( gain == 2 ) temp << "Low, ";
      temp << "KPIX=" << setfill('0') << dec << setw(4);
      temp << inFileRoot->kpixRunRead->getAsic(serial)->getSerial();

      // Recreate histograms
      switch ( selPlot->currentItem() ) {
         case 0:
            temp2 = "Gain, " + temp.str();
            hist  = new TH1F("gain",temp2.c_str(),200,0,100e15);
            hist->SetDirectory(0);
            break;
         case 1:
            temp2 = "Mean, " + temp.str();
            hist  = new TH1F("mean",temp2.c_str(),2550,0,2550);
            hist->SetDirectory(0);
            break;
         case 2:
            temp2 = "Sigma, " + temp.str();
            hist  = new TH1F("sigma",temp2.c_str(),50,0,50);
            hist->SetDirectory(0);
            break;
         case 3:
            temp2 = "Sigma (el), " + temp.str();
            hist  = new TH1F("sigma_el",temp2.c_str(),200,0,100000);
            hist->SetDirectory(0);
            break;
         case 4:
            temp2 = "Cal Sigma, " + temp.str();
            hist  = new TH1F("csigma",temp2.c_str(),500,0,50);
            hist->SetDirectory(0);
            break;
         case 5:
            temp2 = "Cal Sigma (el), " + temp.str();
            hist  = new TH1F("csigma_el",temp2.c_str(),2000,0,100000);
            hist->SetDirectory(0);
            break;
         default:
            hist = NULL;
            break;
      }

      // Get data
      for (channel=0; channel < chCount; channel++) {

         // Use output data
         if ( outFileIsOpen ) {
            meanVal  = outThreshData[serial].mean[gain][channel];
            sigmaVal = outThreshData[serial].sigma[gain][channel];
            gainVal  = outThreshData[serial].gain[gain][channel];
            calVals  = &(outThreshData[serial].calSigma[gain][channel][0]);
         }

         // Use Input File
         else {
            meanVal  = inThreshData[serial].mean[gain][channel];
            sigmaVal = inThreshData[serial].sigma[gain][channel];
            gainVal  = inThreshData[serial].gain[gain][channel];
            calVals  = &(inThreshData[serial].calSigma[gain][channel][0]);
         }

         // Update Table
         temp.str(""); temp << gainVal;  resultsTable->setText(channel,1,temp.str());
         temp.str(""); temp << meanVal;  resultsTable->setText(channel,2,temp.str());
         temp.str(""); temp << sigmaVal; resultsTable->setText(channel,3,temp.str());
         temp.str(""); if ( gainVal != 0 ) temp << ((sigmaVal/gainVal)*1e15*-6240);
         resultsTable->setText(channel,4,temp.str());
            
         // Auto Adjust
         resultsTable->adjustColumn(0);
         resultsTable->adjustColumn(1);
         resultsTable->adjustColumn(2);
         resultsTable->adjustColumn(3);
         resultsTable->adjustColumn(4);

         // Select Fill Value
         if ( selPlot->currentItem() < 4 ) {
            switch ( selPlot->currentItem() ) {
               case 0: fillValue = gainVal*-1;  break;
               case 1: fillValue = meanVal;  break;
               case 2: fillValue = sigmaVal; break;
               case 3: if ( gainVal != 0 ) fillValue = (sigmaVal/gainVal)*1e15*-6240;
                       else fillValue = 0; break;
               default: fillValue = 0; break;
            }

            // Fill Histogram
            if ( fillValue != 0 ) {
               hist->Fill(fillValue);
               if ( fillValue > fillMax || fillMax == 0 ) fillMax = fillValue;
               if ( fillValue < fillMin || fillMin == 0 ) fillMin = fillValue;
               isNonZero = true;
            }
         }

         // Multiple points per channel for last two plots
         else {

            // Fill Calibration Points
            for (cal=calMin; cal <= calMax; cal+=calStep) {

               // Get Fill Value
               if ( outFileIsOpen ) 
                  fillValue = outThreshData[serial].calSigma[gain][channel][cal];
               else
                  fillValue = inThreshData[serial].calSigma[gain][channel][cal];

               // Convert To Electrons
               if ( selPlot->currentItem() == 5 ) fillValue = (fillValue / gainVal)*1e15*-6240;

               // Add Value
               if ( fillValue != 0 ) {
                  hist->Fill(fillValue);
                  if ( fillValue > fillMax || fillMax == 0 ) fillMax = fillValue;
                  if ( fillValue < fillMin || fillMin == 0 ) fillMin = fillValue;
                  isNonZero = true;
               }
            }
         }
      }
   }

   // Draw Dist Histograms
   plotData->GetCanvas()->Clear();
   plotData->GetCanvas()->cd();
   if ( hist != NULL ) {
      hist->GetXaxis()->SetRangeUser(fillMin,fillMax);
      hist->Draw();
   }
   plotData->GetCanvas()->Update();
   update();
}


void KpixGuiThreshView::closeEvent(QCloseEvent *e) {
   inFileClose_pressed();
   if ( kpixGuiViewConfig->close() &&
        kpixGuiThreshChan->close() ) {
      inFileClose_pressed();
      e->accept();
   }
   else e->ignore();
}


// Write Thresh Data
void KpixGuiThreshView::writeThresh(int gain,int serial,int channel,TGraphAsymmErrors **calGraph,
                                    TGraphAsymmErrors *threshGraph,TGraph *calPlot) {

   unsigned int serNum, x;
   TH2F         *tempHist;

   // Make sure we can write
   if ( ! outThreshData[serial].writeDone[gain][channel] ) {

      // Set current data
      selSerial->setCurrentItem(serial);
      selGain->setCurrentItem(gain);

      // Extract Fit Data
      if ( threshGraph != NULL && threshGraph->GetFunction("fit") != NULL ) {
         outThreshData[serial].mean[gain][channel] = threshGraph->GetFunction("fit")->GetParameter(0);
         outThreshData[serial].sigma[gain][channel] = threshGraph->GetFunction("fit")->GetParameter(1);
      } else {
         outThreshData[serial].mean[gain][channel] = 0;
         outThreshData[serial].sigma[gain][channel] = 0;
      }
      if ( calPlot != NULL && calPlot->GetFunction("pol1") != NULL ) {
         outThreshData[serial].gain[gain][channel] = calPlot->GetFunction("pol1")->GetParameter(1);
      } else {
         outThreshData[serial].gain[gain][channel] = 0;
      }

      // Get serial number
      serNum = inFileRoot->kpixRunRead->getAsic(serial)->getSerial();

      // Write graphs to file
      outFileRoot->setDir("ThreshScan");
      if ( threshGraph != NULL ) 
         threshGraph->Write(KpixThreshRead::genPlotName("thresh_curve",gain,serNum,channel).c_str());
      if ( calPlot != NULL ) 
         calPlot->Write(KpixThreshRead::genPlotName("thresh_gain",gain,serNum,channel).c_str());
      for (x=calMin; x <= calMax; x+=calStep) {
         if ( calGraph[x] != NULL ) {
            calGraph[x]->Write(KpixThreshRead::genPlotName("thresh_cal",gain,serNum,channel,x).c_str());
            if ( calGraph[x]->GetFunction("fit") != NULL )
               outThreshData[serial].calSigma[gain][channel][x] = calGraph[x]->GetFunction("fit")->GetParameter(1);
            else
               outThreshData[serial].calSigma[gain][channel][x] = 0;
         }

         // Copy original histogram from source file
         tempHist = inFileRoot->getThreshScan("ThreshScan",gain,serNum,channel,x);
         if ( tempHist != NULL ) {
            tempHist->Write();
            delete tempHist;
         }
      }
      outFileRoot->setDir("/");

      // No Longer Writable
      outThreshData[serial].writeDone[gain][channel] = true;
   }
   if ( ! inAutoUpdate || ((channel+1) % 4) == 0) updateDisplay();
}


bool KpixGuiThreshView::isThreshWritable(int gain,int serial,int channel) {
   if ( ! outFileIsOpen ) return(false);
   return(! outThreshData[serial].writeDone[gain][channel]);
}


void KpixGuiThreshView::writePdf_pressed() {
   unsigned int serial, gain, plot;
   stringstream cmd;

   if ( inFileIsOpen ) {
      plotData->GetCanvas()->Print("summary.ps[");
      for ( serial=0; serial < (unsigned int)(inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
         for ( gain=0; gain < 3; gain++ ) {
            for ( plot=0; plot < 6; plot++ ) {

               // Set current items
               selSerial->setCurrentItem(serial);
               selGain->setCurrentItem(gain);
               selPlot->setCurrentItem(plot);
               updateDisplay();

               // Plot is valid
               if ( isNonZero ) plotData->GetCanvas()->Print("summary.ps");
            }
         }
      }

      // Write Plot
      cout << "KpixGuiCalFit::writePdf_pressed -> Wrote canvas to file summary.ps" << endl;
      plotData->GetCanvas()->Print("summary.ps]");
      cmd.str(""); cmd << "ps2pdf summary.ps";
      system(cmd.str().c_str());
   }
}


void KpixGuiThreshView::autoWriteAll_pressed() {
   setEnabled(false);
   inAutoUpdate = true;
   selPlot->setCurrentItem(0);
   kpixGuiThreshChan->saveAll_pressed();
   updateDisplay();
   inAutoUpdate = false;
   setEnabled(true);
}

