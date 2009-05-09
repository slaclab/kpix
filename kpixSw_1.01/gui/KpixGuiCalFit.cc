//-----------------------------------------------------------------------------
// File          : KpixGuiCalFit.cc
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
// 12/12/2008: Added RMS extraction and plots for histogram.
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
#include "KpixGuiCalFit.h"
using namespace std;


// Constructor
KpixGuiCalFit::KpixGuiCalFit ( string baseDir, bool open ) : KpixGuiCalFitForm() {

   stringstream temp;
   unsigned int x;

   this->inFileRoot        = NULL;
   this->outFileRoot       = NULL;
   this->inFileIsOpen      = false;
   this->outFileIsOpen     = false;
   this->baseDir           = baseDir;

   // Create error window
   errorMsg = new KpixGuiError(this);
   setEnabled(true);

   // Output Calibration Data
   outCalibData = NULL;
   inCalibData  = NULL;

   // Directories
   dirNames[0] = "Force_Trig";
   dirNames[1] = "Self_Trig";

   // Hidden windows at startup
   this->kpixGuiViewConfig = new KpixGuiViewConfig();
   this->kpixGuiViewHist   = new KpixGuiViewHist(DIR_COUNT,dirNames,this);
   this->kpixGuiViewCalib  = new KpixGuiViewCalib(DIR_COUNT,dirNames,this);

   // Update directory selection
   selDir->clear();
   for (x=0; x<DIR_COUNT; x++) selDir->insertItem(dirNames[x],x);

   // Set default base dirs
   inFile->setText(this->baseDir);
   if ( open ) outFile->setText(inFile->text().section(".",0,-2)+"_fit.root");
   else outFile->setText(this->baseDir);

   // Auto Update Flag
   inAutoUpdate = false;

   // Clear histogram
   hist = NULL;

   // Auto open file
   if ( open ) inFileOpen_pressed();
}


// Delete
KpixGuiCalFit::~KpixGuiCalFit ( ) {
   inFileClose_pressed();
   if ( hist != NULL ) delete hist;
   delete kpixGuiViewConfig;
   delete kpixGuiViewHist;
   delete kpixGuiViewCalib;
}


// Select an input file for opening
void KpixGuiCalFit::inFileBrowse_pressed() {

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
void KpixGuiCalFit::inFileOpen_pressed() {
   int          x,y,dir,serial,gain,channel,bucket,serNum, chCount;
   double       gainVal, iceptVal, rmsVal, meanVal, sigmaVal, hrmsVal;
   stringstream temp;

   if ( ! inFileIsOpen ) {
      try {
         inFileRoot = new KpixCalibRead(inFile->text().ascii());
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
         resultsTable->setNumRows(chCount*4);
         for(x=0; x<chCount; x++) {
            for(y=0; y<4; y++) {
               temp.str("");
               temp << setw(4) << setfill('0') << dec << x << "-";
               temp << setw(1) << dec << y;
               resultsTable->setText(x*4+y,0,temp.str());
            }
         }

         // Init Calibration Data
         selPlot->setCurrentItem(0);
         inCalibData = 
            (KpixGuiCalFitData *)malloc(sizeof(KpixGuiCalFitData)*((inFileRoot->kpixRunRead->getAsicCount()-1)));
         if ( inCalibData == NULL ) throw(string("KpixGuiCalFit::inFileOpen_pressed -> Malloc Error"));
         chCount     = inFileRoot->kpixRunRead->getAsic(0)->getChCount();
         for (serial=0; serial < (inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
            serNum  = inFileRoot->kpixRunRead->getAsic(serial)->getSerial();
            for (dir=0; dir < DIR_COUNT; dir++) {
               for (gain=0; gain < 3; gain++) {
                  for (channel=0; channel < chCount; channel++) {
                     for (bucket=0; bucket < 4; bucket++) {

                        // Get calibration data
                        inFileRoot->getCalibData (&gainVal,&iceptVal,dirNames[dir],gain,serNum,channel,bucket);
                        inFileRoot->getCalibRms  (&rmsVal,dirNames[dir],gain,serNum,channel,bucket);
                        inFileRoot->getHistData ( &meanVal, &sigmaVal, &hrmsVal, dirNames[dir], gain, serNum, channel, bucket);

                        // Set structure
                        inCalibData[serial].calGain[dir][gain][channel][bucket] = gainVal;
                        inCalibData[serial].calIntercept[dir][gain][channel][bucket] = iceptVal;
                        inCalibData[serial].calRms[dir][gain][channel][bucket] = rmsVal; 
                        inCalibData[serial].distMean[dir][gain][channel][bucket] = meanVal;
                        inCalibData[serial].distSigma[dir][gain][channel][bucket] = sigmaVal;
                        inCalibData[serial].distRms[dir][gain][channel][bucket] = hrmsVal;
                        inCalibData[serial].calWriteDone[dir][gain][channel][bucket] = false;
                        inCalibData[serial].distWriteDone[dir][gain][channel][bucket] = false;
                     }
                     if ( (channel+1)%8 == 0 ) {
                        selDir->setCurrentItem(dir);
                        selSerial->setCurrentItem(serial);
                        selGain->setCurrentItem(gain);
                        updateDisplay();
                     }
                  }
               }
            }
         }

         // Update windows
         kpixGuiViewConfig->setRunData(inFileRoot->kpixRunRead);
         kpixGuiViewHist->setCalibData(inFileRoot);
         kpixGuiViewCalib->setCalibData(inFileRoot);
      } catch (string error) {
         errorMsg->showMessage(error);
      }
   }
   setEnabled(true);
   updateDisplay();
}


// Close the input file
void KpixGuiCalFit::inFileClose_pressed() {

   // Close the output file if open
   outFileClose_pressed();

   if ( inFileIsOpen ) {

      // Close sub-windows
      kpixGuiViewConfig->close();
      kpixGuiViewHist->close();
      kpixGuiViewCalib->close();
      
      // No FPGA/ASIC Entries
      kpixGuiViewConfig->setRunData(NULL);
      kpixGuiViewHist->setCalibData(NULL);
      kpixGuiViewCalib->setCalibData(NULL);

      // Close file
      delete inFileRoot;
      free(inCalibData);
   }

   // Set flags, update buttons and update display
   inFileIsOpen = false;
   setEnabled(true);
   updateDisplay();
}


// Select output file
void KpixGuiCalFit::outFileBrowse_pressed() {
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
void KpixGuiCalFit::outFileOpen_pressed() {
   unsigned int x,dir,serial,gain,channel,bucket, chCount;
   KpixRunVar   *runVar;
   QString      temp;
   string       calTime;

   try {
      if ( inFileIsOpen && ! outFileIsOpen ) {

         // Close usb windows
         kpixGuiViewConfig->close();
         kpixGuiViewHist->close();
         kpixGuiViewCalib->close();

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
         if ( calTime == "" )
            calTime = inFileRoot->kpixRunRead->getRunTime();

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

         // Init Calibration Data
         outCalibData = 
            (KpixGuiCalFitData *)malloc(sizeof(KpixGuiCalFitData)*((inFileRoot->kpixRunRead->getAsicCount()-1)));
         if ( outCalibData == NULL ) throw(string("KpixGuiCalFit::outFileOpen_pressed -> Malloc Error"));
         chCount      = inFileRoot->kpixRunRead->getAsic(0)->getChCount();
         for (serial=0; serial < ((unsigned int)inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
            for (dir=0; dir < DIR_COUNT; dir++) {
               for (gain=0; gain < 3; gain++) {
                  for (channel=0; channel < chCount; channel++) {
                     for (bucket=0; bucket <4; bucket++) {

                        // Init structure
                        outCalibData[serial].calGain[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].calIntercept[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].calRms[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].distMean[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].distSigma[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].distRms[dir][gain][channel][bucket] = 0;
                        outCalibData[serial].calWriteDone[dir][gain][channel][bucket] = false;
                        outCalibData[serial].distWriteDone[dir][gain][channel][bucket] = false;
                     }
                  }
               }
            }
         }
      }
   } catch (string error) {
      errorMsg->showMessage(error);
   }
   setEnabled(true);
   updateDisplay();
}


void KpixGuiCalFit::outFileClose_pressed() {
   if ( outFileIsOpen ) {
      kpixGuiViewConfig->close();
      kpixGuiViewHist->close();
      kpixGuiViewCalib->close();
      delete(outFileRoot);
      free(outCalibData);
   }
   outFileIsOpen = false;
   setEnabled(true);
   updateDisplay();
}


void KpixGuiCalFit::viewInCalib_pressed() {
   kpixGuiViewCalib->show();
}


void KpixGuiCalFit::viewInHist_pressed() {
   kpixGuiViewHist->show();
}


void KpixGuiCalFit::viewConfig_pressed() {
   kpixGuiViewConfig->show();
}


void KpixGuiCalFit::autoWriteAll_pressed() {

   setEnabled(false);
   inAutoUpdate = true;

   // Force Trig
   selPlot->setCurrentItem(0);
   kpixGuiViewCalib->selectDir(0);
   kpixGuiViewCalib->writeAll_pressed();
   updateDisplay();
   selPlot->setCurrentItem(4);
   kpixGuiViewHist->selectDir(0);
   kpixGuiViewHist->writeAll_pressed();
   updateDisplay();

   // Self Trig
   selPlot->setCurrentItem(0);
   kpixGuiViewCalib->selectDir(1);
   kpixGuiViewCalib->writeAll_pressed();
   updateDisplay();

   inAutoUpdate = false;
   setEnabled(true);
}


// Set Button Enables
void KpixGuiCalFit::setEnabled(bool enable) {

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
   viewInHist->setEnabled(inFileIsOpen?enable:false);
   viewInCalib->setEnabled(inFileIsOpen?enable:false);
   autoWriteAll->setEnabled(outFileIsOpen?enable:false);
   selDir->setEnabled(inFileIsOpen?enable:false);
   selSerial->setEnabled(inFileIsOpen?enable:false);
   selGain->setEnabled(inFileIsOpen?enable:false);
   writePdf->setEnabled(inFileIsOpen?enable:false);
}


// Is Hist Writable
bool KpixGuiCalFit::isHistWritable(int dirIndex,int gain,int serial,int channel,int bucket) {
   if ( ! outFileIsOpen ) return(false);
   return(! outCalibData[serial].distWriteDone[dirIndex][gain][channel][bucket]);
}


// Is Calib Writable
bool KpixGuiCalFit::isCalibWritable(int dirIndex,int gain,int serial,int channel,int bucket) {
   if ( ! outFileIsOpen ) return(false);
   return(! outCalibData[serial].calWriteDone[dirIndex][gain][channel][bucket]);
}


// Write Hist Data
void KpixGuiCalFit::writeHist(int dirIndex,int gain,int serial,int channel,int bucket,TH1F **hist) {

   // Make sure we can write
   if ( ! outCalibData[serial].distWriteDone[dirIndex][gain][channel][bucket] ) {

      // Set current data
      selDir->setCurrentItem(dirIndex);
      selSerial->setCurrentItem(serial);
      selGain->setCurrentItem(gain);

      // Set histogram data
      if ( hist[0] != NULL && hist[0]->GetFunction("gaus") != NULL ) {
         outCalibData[serial].distMean[dirIndex][gain][channel][bucket] =
            hist[0]->GetFunction("gaus")->GetParameter(1);
         outCalibData[serial].distSigma[dirIndex][gain][channel][bucket] =
            hist[0]->GetFunction("gaus")->GetParameter(2);
         outCalibData[serial].distRms[dirIndex][gain][channel][bucket] =
            hist[0]->GetRMS();
      }

      // Write Graphs To File
      outFileRoot->setDir(dirNames[dirIndex]);
      if ( hist[0] != NULL ) hist[0]->Write();
      if ( hist[1] != NULL ) hist[1]->Write();
      outFileRoot->setDir("/");

      // No Longer Writable
      outCalibData[serial].distWriteDone[dirIndex][gain][channel][bucket] = true;
   }
   if ( ! inAutoUpdate || (((channel+1) % 16) == 0 && bucket == 3)) updateDisplay();
}


// Write Calib Data
void KpixGuiCalFit::writeCalib(int dirIndex,int gain,int serial,int channel,int bucket,TGraph **graph) {

   TGraph       *cal,*rms;
   unsigned int serNum;

   // Make sure we can write
   if ( ! outCalibData[serial].calWriteDone[dirIndex][gain][channel][bucket] ) {

      // Set current data
      selDir->setCurrentItem(dirIndex);
      selSerial->setCurrentItem(serial);
      selGain->setCurrentItem(gain);

      // Determine which plot to use
      if ( gain == 2 ) {
         if ( graph[7] == NULL ) cal = graph[1]; else cal = graph[7];
         rms = graph[5];
      }
      else {
         if ( graph[6] == NULL ) cal = graph[0]; else cal = graph[6];
         rms = graph[4];
      }

      // Set calibration data
      if ( cal != NULL && cal->GetFunction("pol1") != NULL ) {
         outCalibData[serial].calGain[dirIndex][gain][channel][bucket] =
            cal->GetFunction("pol1")->GetParameter(1);
         outCalibData[serial].calIntercept[dirIndex][gain][channel][bucket] =
            cal->GetFunction("pol1")->GetParameter(0);
      }
      else {
         outCalibData[serial].calGain[dirIndex][gain][channel][bucket] = 0;
         outCalibData[serial].calIntercept[dirIndex][gain][channel][bucket] = 0;
      }

      // Set RMS Data
      if ( rms != NULL ) outCalibData[serial].calRms[dirIndex][gain][channel][bucket] = rms->GetRMS(2);
      else outCalibData[serial].calRms[dirIndex][gain][channel][bucket] = 0;

      // Get serial number
      serNum = inFileRoot->kpixRunRead->getAsic(serial)->getSerial();

      // Write Graphs To File
      outFileRoot->setDir(dirNames[dirIndex]);
      if ( graph[0] != NULL ) 
         graph[0]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_value",0).c_str());
      if ( graph[1] != NULL ) 
         graph[1]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_value",1).c_str());
      if ( graph[2] != NULL ) 
         graph[2]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_time",0).c_str());
      if ( graph[3] != NULL ) 
         graph[3]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_time",1).c_str());
      if ( graph[4] != NULL ) 
         graph[4]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_resid",0).c_str());
      if ( graph[5] != NULL ) 
         graph[5]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_resid",1).c_str());
      if ( graph[6] != NULL ) 
         graph[6]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_filt",0).c_str());
      if ( graph[7] != NULL ) 
         graph[7]->Write(KpixCalibRead::genPlotName(gain, serNum, channel, bucket,"calib_filt",1).c_str());
      outFileRoot->setDir("/");

      // No Longer Writable
      outCalibData[serial].calWriteDone[dirIndex][gain][channel][bucket] = true;
   }
   if ( ! inAutoUpdate || (((channel+1) % 8) == 0 && bucket == 3)) updateDisplay();
}


void KpixGuiCalFit::updateDisplay() {

   unsigned int dir,serial,gain,channel,bucket,chCount;
   double       gainVal, iceptVal, rmsVal, meanVal, sigmaVal, hrmsVal;
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
      dir    = selDir->currentItem();
      gain   = selGain->currentItem();

      // Determine Title Append
      temp.str("");
      if ( dir  == 0 ) temp << "Force Trig, ";
      if ( dir  == 1 ) temp << "Self Trig, ";
      if ( gain == 0 ) temp << "Norm, ";
      if ( gain == 1 ) temp << "Double, ";
      if ( gain == 2 ) temp << "Low, ";
      temp << "KPIX=" << setfill('0') << dec << setw(4);
      temp << inFileRoot->kpixRunRead->getAsic(serial)->getSerial();

      // Recreate histograms
      switch ( selPlot->currentItem() ) {
         case 0:
            temp2 = "Gain, " + temp.str();
            hist  = new TH1F("gain",temp2.c_str(),2000,0,20e15);
            hist->SetDirectory(0);
            break;
         case 1:
            temp2 = "Intercept, " + temp.str();
            hist  = new TH1F("intercept",temp2.c_str(),500,0,500);
            hist->SetDirectory(0);
            break;
         case 2:
            temp2 = "RMS, " + temp.str();
            hist  = new TH1F("rms",temp2.c_str(),100,0,20);
            hist->SetDirectory(0);
            break;
         case 3:
            temp2 = "Mean, " + temp.str();
            hist  = new TH1F("mean",temp2.c_str(),500,0,500);
            hist->SetDirectory(0);
            break;
         case 4:
            temp2 = "Sigma, " + temp.str();
            hist  = new TH1F("sigma",temp2.c_str(),50,0,10);
            hist->SetDirectory(0);
            break;
         case 5:
            temp2 = "Rms (el), " + temp.str();
            hist  = new TH1F("rms_el",temp2.c_str(),1000,0,100000);
            hist->SetDirectory(0);
            break;
         case 6:
            temp2 = "Sigma (el), " + temp.str();
            hist  = new TH1F("sigma_el",temp2.c_str(),1000,0,100000);
            hist->SetDirectory(0);
            break;
         case 7:
            temp2 = "HRMS, " + temp.str();
            hist  = new TH1F("hrms",temp2.c_str(),50,0,10);
            hist->SetDirectory(0);
            break;
         case 8:
            temp2 = "HRMS (el), " + temp.str();
            hist  = new TH1F("hrms_el",temp2.c_str(),1000,0,100000);
            hist->SetDirectory(0);
            break;
         default:
            hist = NULL;
            break;
      }

      // Get data
      for (channel=0; channel < chCount; channel++) {
         for (bucket=0; bucket < 4; bucket++) {

            // Use output data
            if ( outFileIsOpen ) {
               gainVal  = outCalibData[serial].calGain[dir][gain][channel][bucket];
               iceptVal = outCalibData[serial].calIntercept[dir][gain][channel][bucket];
               rmsVal   = outCalibData[serial].calRms[dir][gain][channel][bucket];
               meanVal  = outCalibData[serial].distMean[dir][gain][channel][bucket];
               sigmaVal = outCalibData[serial].distSigma[dir][gain][channel][bucket];
               hrmsVal  = outCalibData[serial].distRms[dir][gain][channel][bucket];
            }

            // Use Input File
            else {
               gainVal  = inCalibData[serial].calGain[dir][gain][channel][bucket];
               iceptVal = inCalibData[serial].calIntercept[dir][gain][channel][bucket];
               rmsVal   = inCalibData[serial].calRms[dir][gain][channel][bucket];
               meanVal  = inCalibData[serial].distMean[dir][gain][channel][bucket];
               sigmaVal = inCalibData[serial].distSigma[dir][gain][channel][bucket];
               hrmsVal  = inCalibData[serial].distRms[dir][gain][channel][bucket];
            }

            // Update Table
            temp.str(""); temp << gainVal;  resultsTable->setText(channel*4+bucket,1,temp.str());
            temp.str(""); temp << iceptVal; resultsTable->setText(channel*4+bucket,2,temp.str());
            temp.str(""); temp << rmsVal;   resultsTable->setText(channel*4+bucket,3,temp.str());
            temp.str(""); temp << meanVal;  resultsTable->setText(channel*4+bucket,4,temp.str());
            temp.str(""); temp << sigmaVal; resultsTable->setText(channel*4+bucket,5,temp.str());
            temp.str(""); if ( gainVal != 0 ) temp << ((rmsVal/gainVal)*1e15*6240);
            resultsTable->setText(channel*4+bucket,6,temp.str());
            temp.str(""); if ( gainVal != 0 ) temp << ((sigmaVal/gainVal)*1e15*6240);
            resultsTable->setText(channel*4+bucket,7,temp.str());
            temp.str(""); temp << hrmsVal; resultsTable->setText(channel*4+bucket,8,temp.str());
            temp.str(""); if ( gainVal != 0 ) temp << ((hrmsVal/gainVal)*1e15*6240);
            resultsTable->setText(channel*4+bucket,9,temp.str());
            
            // Auto Adjust
            resultsTable->adjustColumn(0);
            resultsTable->adjustColumn(1);
            resultsTable->adjustColumn(2);
            resultsTable->adjustColumn(3);
            resultsTable->adjustColumn(4);
            resultsTable->adjustColumn(5);
            resultsTable->adjustColumn(6);
            resultsTable->adjustColumn(7);
            resultsTable->adjustColumn(8);
            resultsTable->adjustColumn(9);

            // Select Fill Value
            switch ( selPlot->currentItem() ) {
               case 0: fillValue = gainVal;  break;
               case 1: fillValue = iceptVal; break;
               case 2: fillValue = rmsVal;   break;
               case 3: fillValue = meanVal;  break;
               case 4: fillValue = sigmaVal; break;
               case 5: 
                  if ( gainVal != 0 ) fillValue = (rmsVal/gainVal)*1e15*6240;
                  else fillValue = 0; 
                  if ( fillValue < 0   ) fillValue = 0;
                  if ( fillValue > 1e5 ) fillValue = 0;
                  break;
               case 6: 
                  if ( gainVal != 0 ) fillValue = (sigmaVal/gainVal)*1e15*6240;
                  else fillValue = 0; 
                  if ( fillValue < 0   ) fillValue = 0;
                  if ( fillValue > 1e5 ) fillValue = 0;
                  break;
               case 7: fillValue = hrmsVal; break;
               case 8: 
                  if ( gainVal != 0 ) fillValue = (hrmsVal/gainVal)*1e15*6240;
                  else fillValue = 0; 
                  if ( fillValue < 0   ) fillValue = 0;
                  if ( fillValue > 1e5 ) fillValue = 0;
                  break;
               default: fillValue = 0; break;
            }

            // Fill Histogram
            if ( fillValue != 0 ) {
               hist->Fill(fillValue);
               if ( fillValue > fillMax || fillMax == 0 ) fillMax = fillValue;
               if ( fillValue < fillMin || fillMin == 0 ) fillMin = fillValue;
               if ( fillValue != 0 ) isNonZero = true;
            }
         }
      }
   }

   // Draw Dist Histograms
   plotData->GetCanvas()->Clear();
   plotData->GetCanvas()->cd();
   if ( hist != NULL ) {
      fillMax += 1;
      fillMin -= 1;
      hist->GetXaxis()->SetRangeUser(fillMin,fillMax);
      hist->Draw();
   }
   plotData->GetCanvas()->Update();
   update();
}


void KpixGuiCalFit::writePdf_pressed() {
   unsigned int dir, serial, gain, plot;
   stringstream cmd;

   if ( inFileIsOpen ) {
      plotData->GetCanvas()->Print("summary.ps[");
      for ( serial=0; serial < (unsigned int)(inFileRoot->kpixRunRead->getAsicCount()-1); serial++) {
         for ( dir=0; dir < DIR_COUNT; dir++) {
            for ( gain=0; gain < 3; gain++ ) {
               for ( plot=0; plot < 9; plot++ ) {

                  // Set current items
                  selSerial->setCurrentItem(serial);
                  selDir->setCurrentItem(dir);
                  selGain->setCurrentItem(gain);
                  selPlot->setCurrentItem(plot);
                  updateDisplay();

                  // Plot is valid
                  if ( isNonZero ) plotData->GetCanvas()->Print("summary.ps");
               }
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


void KpixGuiCalFit::closeEvent(QCloseEvent *e) {
   inFileClose_pressed();
   if ( kpixGuiViewConfig->close() &&
        kpixGuiViewHist->close() &&
        kpixGuiViewCalib->close() ) {
      inFileClose_pressed();
      e->accept();
   }
   else e->ignore();
}


