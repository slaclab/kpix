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
// 04/30/2009: Remove seperate hist and cal view classes. All functions now
//             handled by this class. Added thread for read/fit operations.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <qfiledialog.h>
#include <qprogressbar.h>
#include <qtabwidget.h>
#include <TQtWidget.h>
#include <TError.h>
#include "KpixGuiCalFit.h"
#include "KpixGuiEventStatus.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventData.h"
using namespace std;


// Constructor
KpixGuiCalFit::KpixGuiCalFit ( string baseDir, bool open ) : KpixGuiCalFitForm() {

   stringstream temp;
   unsigned int x, y;

   this->inFileRoot        = NULL;
   this->outFileRoot       = NULL;
   this->baseDir           = baseDir;
   this->cmdType           = 0;
   this->isRunning         = false;

   // Create error window
   errorMsg = new KpixGuiError(this);
   setEnabled(true);

   // Output Calibration Data
   calibData  = NULL;

   // Directories
   dirNames[0] = "Force_Trig";
   dirNames[1] = "Self_Trig";

   // Init asics
   this->asicCnt = 0;
   this->asic    = NULL;
   selSerial->clear();

   // Hidden windows at startup
   this->kpixGuiViewConfig = new KpixGuiViewConfig();
   this->kpixGuiSampleView = new KpixGuiSampleView();

   // Update directory selection
   selDir->clear();
   for (x=0; x<DIR_COUNT; x++) selDir->insertItem(dirNames[x],x);

   // Set default base dirs
   inFile->setText(this->baseDir);
   if ( open ) outFile->setText(inFile->text().section(".",0,-2)+"_fit.root");
   else outFile->setText(this->baseDir);

   // Clear histograms & graphs
   for (x=0; x<9; x++) sumHist[x] = NULL;
   for (x=0; x<2; x++) hist[x]    = NULL;
   for (x=0; x<3; x++) mGraph[x]  = NULL;
   progressBar->setProgress(-1,100);

   // Setup Summary Table Columns
   summaryTable->setNumCols(10);
   summaryTable->horizontalHeader()->setLabel(0,"Ch/Bk");
   summaryTable->horizontalHeader()->setLabel(1,"Gain");
   summaryTable->horizontalHeader()->setLabel(2,"Icept");
   summaryTable->horizontalHeader()->setLabel(3,"RMS");
   summaryTable->horizontalHeader()->setLabel(4,"RMS(el)");
   summaryTable->horizontalHeader()->setLabel(5,"Mean");
   summaryTable->horizontalHeader()->setLabel(6,"Sigma");
   summaryTable->horizontalHeader()->setLabel(7,"Sigma(el)");
   summaryTable->horizontalHeader()->setLabel(8,"HRMS");
   summaryTable->horizontalHeader()->setLabel(9,"HRMS(el)");

   // Adjust width
   for (x=0; x< 10; x++) summaryTable->setColumnWidth(x,80);

   // Update summary table
   summaryTable->setNumRows(4096);
   for(x=0; x<1024; x++) {
      for(y=0; y<4; y++) {
         temp.str("");
         temp << setw(4) << setfill('0') << dec << x << "-";
         temp << setw(1) << dec << y;
         summaryTable->setText(x*4+y,0,temp.str());
      }
   }

   // Auto open file
   if ( open ) inFileOpen_pressed();
}


// Delete
KpixGuiCalFit::~KpixGuiCalFit ( ) {
   inFileClose_pressed();
   delete kpixGuiViewConfig;
   delete kpixGuiSampleView;
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
   if ( ! isRunning ) {
      reFitEn->setChecked(false);
      setEnabled(false);
      cmdType = CmdFileOpen;
      isRunning = true;
      QThread::start();
   }
}


// Close the input file
void KpixGuiCalFit::inFileClose_pressed() {
   unsigned int x;
   setEnabled(false);

   // Close sub-windows
   kpixGuiViewConfig->close();
   kpixGuiSampleView->close();
      
   // No FPGA/ASIC Entries
   kpixGuiViewConfig->setRunData(NULL);
   kpixGuiSampleView->setRunData(NULL);

   // Free asic list and calibration data
   for (x=0; x< asicCnt; x++) delete calibData[x];
   if ( asic != NULL ) free(asic);
   if ( calibData != NULL ) free(calibData);
   asic=NULL;
   calibData=NULL;
   asicCnt = 0;

   // Close file
   if (inFileRoot != NULL) delete inFileRoot;
   inFileRoot = NULL;

   // Clear Plots
   calibCanvas->GetCanvas()->Clear();
   histCanvas->GetCanvas()->Clear();
   summaryCanvas->GetCanvas()->Clear();
   for (x=0; x<3; x++) if ( mGraph[x]  != NULL ) {delete mGraph[x]; mGraph[x] = NULL; }
   for (x=0; x<9; x++) if ( sumHist[x] != NULL ) {delete sumHist[x]; sumHist[x] = NULL; }
   for (x=0; x<2; x++) if ( hist[x]    != NULL ) {delete hist[x]; hist[x] = NULL; }
   calibCanvas->GetCanvas()->Update();
   histCanvas->GetCanvas()->Update();
   summaryCanvas->GetCanvas()->Update();

   // Set flags, update buttons and update display
   setEnabled(true);
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


void KpixGuiCalFit::viewConfig_pressed() {
   kpixGuiViewConfig->show();
}


void KpixGuiCalFit::viewSamples_pressed() {
   kpixGuiSampleView->show();
}


void KpixGuiCalFit::autoWriteAll_pressed() {
   if ( ! isRunning ) {
      kpixGuiViewConfig->close();
      kpixGuiSampleView->close();
      setEnabled(false);
      cmdType = CmdFileWrite;
      isRunning = true;
      QThread::start();
   }
}


void KpixGuiCalFit::writePdf_pressed() {
   stringstream       temp, cmd;
   unsigned int       dirIndex;
   unsigned int       gain;
   unsigned int       serial;
   unsigned int       channel;
   unsigned int       bucket;

   // Get current entries
   dirIndex = selDir->currentItem();
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();
   bucket   = selBucket->value();

   // Determine which tab is open
   switch ( calTab->currentPageIndex() ) {

      // Summary Plot
      case 1: 
         temp.str("");
         temp << "summary_";
         if ( dirIndex == 0 ) temp << "force_";
         if ( dirIndex == 1 ) temp << "self_";
         if ( gain == 0 )     temp << "norm";
         if ( gain == 1 )     temp << "double";
         if ( gain == 2 )     temp << "low";
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         summaryCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;

      // Calib Plot
      case 2: 
         temp.str("");
         temp << "calib_";
         if ( dirIndex == 0 ) temp << "force_";
         if ( dirIndex == 1 ) temp << "self_";
         if ( gain == 0 )     temp << "norm_s";
         if ( gain == 1 )     temp << "double_s";
         if ( gain == 2 )     temp << "low_s";
         temp << dec << setw(4) << setfill('0') << asic[serial]->getSerial() << "_c";
         temp << dec << setw(4) << setfill('0') << channel << "_b";
         temp << dec << setw(1) << bucket;
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         calibCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;

      // Hist Plot
      case 3: 
         temp.str("");
         temp << "hist_";
         if ( dirIndex == 0 ) temp << "force_";
         if ( dirIndex == 1 ) temp << "self_";
         if ( gain == 0 )     temp << "norm_s";
         if ( gain == 1 )     temp << "double_s";
         if ( gain == 2 )     temp << "low_s";
         temp << dec << setw(4) << setfill('0') << asic[serial]->getSerial() << "_c";
         temp << dec << setw(4) << setfill('0') << channel << "_b";
         temp << dec << setw(1) << bucket;
         cout << "Generating file " << temp.str() << ".pdf" << endl;
         temp << ".ps";
         histCanvas->GetCanvas()->Print(temp.str().c_str());
         cmd.str(""); cmd << "ps2pdf " << temp.str();
         system(cmd.str().c_str());
         break;
   }
}


// Set Button Enables
void KpixGuiCalFit::setEnabled(bool enable) {

   // These buttons depend on file open state
   viewConfig->setEnabled((inFileRoot!=NULL)?enable:false);
   viewSamples->setEnabled((inFileRoot!=NULL)?enable:false);
   selDir->setEnabled((inFileRoot!=NULL)?enable:false);
   reFitEn->setEnabled((inFileRoot!=NULL)?enable:false);
   selSerial->setEnabled((inFileRoot!=NULL)?enable:false);
   selGain->setEnabled((inFileRoot!=NULL)?enable:false);
   selChannel->setEnabled((inFileRoot!=NULL)?enable:false);
   selBucket->setEnabled((inFileRoot!=NULL)?enable:false);
   prevPlot->setEnabled((inFileRoot!=NULL)?enable:false);
   nextPlot->setEnabled((inFileRoot!=NULL)?enable:false);
   normMinFit->setEnabled((inFileRoot!=NULL)?enable:false);
   normMaxFit->setEnabled((inFileRoot!=NULL)?enable:false);
   doubleMinFit->setEnabled((inFileRoot!=NULL)?enable:false);
   doubleMaxFit->setEnabled((inFileRoot!=NULL)?enable:false);
   lowMinFit->setEnabled((inFileRoot!=NULL)?enable:false);
   lowMaxFit->setEnabled((inFileRoot!=NULL)?enable:false);
   timeFiltEn->setEnabled((inFileRoot!=NULL)?enable:false);
   inFileOpen->setEnabled((inFileRoot!=NULL)?false:enable);
   inFileClose->setEnabled((inFileRoot!=NULL)?enable:false);
   inFileBrowse->setEnabled((inFileRoot!=NULL)?false:enable);
   inFile->setEnabled((inFileRoot!=NULL)?false:enable);
   outFileBrowse->setEnabled(enable);
   outFile->setEnabled(enable);
   fitSaveAll->setEnabled((inFileRoot!=NULL)?enable:false);
   writePdf->setEnabled((inFileRoot!=NULL)?enable:false);
}


// Read and Fit plot data
void KpixGuiCalFit::readFitData(unsigned int dirIndex, unsigned int gain, unsigned int serial, 
                                unsigned int channel, unsigned int bucket, bool fitEn, bool writeEn, bool dispEn ) {
   int              x;
   int              newCount, oldCount;
   double           newX[256], newY[256];
   double           minFit, maxFit;
   double           oldX, oldY, oldTX, oldTY;
   unsigned int     timeMin, timeMax;
   bool             valid;
   TGraph           *tGraph[8];
   TMultiGraph      *tmGraph[3];
   TH1F             *tHist[2];
   void             *plots[5];
   KpixGuiEventData *data;

   // Get tHist plots
   tHist[0] = inFileRoot->getHistValue(dirNames[dirIndex],gain,asic[serial]->getSerial(), channel,bucket);
   tHist[1] = inFileRoot->getHistTime(dirNames[dirIndex],gain,asic[serial]->getSerial(), channel,bucket);

   // Get calib plots
   tGraph[0] = inFileRoot->getGraphValue(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,0);
   tGraph[1] = inFileRoot->getGraphValue(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,1);
   tGraph[2] = inFileRoot->getGraphTime(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,0);
   tGraph[3] = inFileRoot->getGraphTime(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,1);
   tGraph[4] = inFileRoot->getGraphResid(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,0);
   tGraph[5] = inFileRoot->getGraphResid(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,1);
   tGraph[6] = inFileRoot->getGraphFilt(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,0);
   tGraph[7] = inFileRoot->getGraphFilt(dirNames[dirIndex],gain, asic[serial]->getSerial(), channel,bucket,1);

   // Determine time Range
   timeMin = calTime[bucket];
   if (bucket != 3) timeMax = calTime[bucket+1];
   else timeMax = 8191;

   // Re-Fit Enabled
   if ( fitEn ) {

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

         // Delete old filter tGraphs if they exist
         if ( tGraph[6] != NULL ) delete tGraph[6]; tGraph[6] = NULL;
         if ( tGraph[7] != NULL ) delete tGraph[7]; tGraph[7] = NULL;

         // Generate new range 0 value/time points
         if ( tGraph[0] != NULL ) {
            oldCount = tGraph[0]->GetN();
            newCount = 0;
            for (x=0; x< oldCount; x++) {
               tGraph[0]->GetPoint(x,oldX,oldY);
               tGraph[2]->GetPoint(x,oldTX,oldTY);
               if ( oldX != oldTX ) cout << "KpixGuiCalFit::readFitData -> Error: X Value Mismatch" << endl;
               if ( oldTY >= timeMin && oldTY < timeMax ) {
                  newX[newCount] = oldX;
                  newY[newCount] = oldY;
                  newCount++;
               }
            }

            // Create new plots
            if ( newCount > 0 ) {
               tGraph[6] = new TGraph(newCount,newX,newY);
               tGraph[6]->SetTitle(KpixCalibRead::genPlotTitle(gain, inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                            channel, bucket,"Calib Filt",0).c_str());
            }

            // Delete Fitted Function 
            delete (tGraph[0]->GetFunction("pol1"));
         }

         // Generate new range 1 value/time points
         if ( tGraph[1] != NULL ) {
            oldCount = tGraph[1]->GetN();
            newCount = 0;
            for (x=0; x< oldCount; x++) {
               tGraph[1]->GetPoint(x,oldX,oldY);
               tGraph[3]->GetPoint(x,oldTX,oldTY);
               if ( oldX != oldTX ) cout << "KpixGuiCalFit::readFitData -> Error: X Value Mismatch" << endl;
               if ( oldTY >= timeMin && oldTY < timeMax ) {
                  newX[newCount] = oldX;
                  newY[newCount] = oldY;
                  newCount++;
               }
            }

            // Create new plots
            if ( newCount > 0 ) {
               tGraph[7] = new TGraph(newCount,newX,newY);
               tGraph[7]->SetTitle(KpixCalibRead::genPlotTitle(gain, inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                            channel, bucket,"Calib Filt",1).c_str());
            } 

            // Delete Fitted Function 
            delete (tGraph[1]->GetFunction("pol1"));
         }
      }

      // Fit Range 0, Value Plot, Non-Filtered
      if ( tGraph[0] != NULL && tGraph[6] == NULL ) {
         tGraph[0]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( tGraph[4] != NULL ) delete tGraph[4];

         // Generate New RMS Plot
         oldCount = tGraph[0]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            tGraph[0]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - tGraph[0]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         tGraph[4] = new TGraph(newCount,newX,newY);
         tGraph[4]->SetTitle(KpixCalibRead::genPlotTitle(gain, inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }

      // Fit Range 0, Value Plot, Filtered
      if ( tGraph[6] != NULL ) {
         tGraph[6]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( tGraph[4] != NULL ) delete tGraph[4];

         // Generate New RMS Plot
         oldCount = tGraph[6]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            tGraph[6]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - tGraph[6]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         tGraph[4] = new TGraph(newCount,newX,newY);
         tGraph[4]->SetTitle(KpixCalibRead::genPlotTitle(gain,inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }

      // Fit Range 1, Value Plot, Non-Filtered
      if ( tGraph[1] != NULL && tGraph[7] == NULL ) {
         tGraph[1]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( tGraph[5] != NULL ) delete tGraph[4];

         // Generate New RMS Plot
         oldCount = tGraph[1]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            tGraph[1]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - tGraph[1]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         tGraph[5] = new TGraph(newCount,newX,newY);
         tGraph[5]->SetTitle(KpixCalibRead::genPlotTitle(gain, inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",1).c_str());
      }

      // Fit Range 0, Value Plot, Filtered
      if ( tGraph[7] != NULL ) {
         tGraph[7]->Fit("pol1","q","",minFit,maxFit);

         // Delete old RMS Plot
         if ( tGraph[5] != NULL ) delete tGraph[5];

         // Generate New RMS Plot
         oldCount = tGraph[7]->GetN();
         newCount = 0;
         for (x=0; x< oldCount; x++) {
            tGraph[7]->GetPoint(x,oldX,oldY);
            if ( oldX >= minFit && oldX <= maxFit ) {
               newX[newCount] = oldX;
               newY[newCount] = oldY - tGraph[7]->GetFunction("pol1")->Eval(oldX);
               newCount++;
            }
         }
         tGraph[5] = new TGraph(newCount,newX,newY);
         tGraph[5]->SetTitle(KpixCalibRead::genPlotTitle(gain, inFileRoot->kpixRunRead->getAsic(serial)->getSerial(), 
                                                      channel, bucket,"Calib Residuals",0).c_str());
      }

      // Histogram
      if ( tHist[0] != NULL ) tHist[0]->Fit("gaus","q");
   } // FIT


   // Extract Range 0 Value Fit Results
   if ( tGraph[6] != NULL && tGraph[6]->GetFunction("pol1") != NULL ) {
      calibData[serial]->calGain[dirIndex][gain][channel][bucket][0] = tGraph[6]->GetFunction("pol1")->GetParameter(1);
      calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][0] = tGraph[6]->GetFunction("pol1")->GetParameter(0);
   }
   else if ( tGraph[0] != NULL && tGraph[0]->GetFunction("pol1") != NULL ) {
      calibData[serial]->calGain[dirIndex][gain][channel][bucket][0] = tGraph[0]->GetFunction("pol1")->GetParameter(1);
      calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][0] = tGraph[0]->GetFunction("pol1")->GetParameter(0);
   }
   else {
      calibData[serial]->calGain[dirIndex][gain][channel][bucket][0] = 0;
      calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][0] = 0;
   }
   if ( tGraph[4] != NULL ) calibData[serial]->calRms[dirIndex][gain][channel][bucket][0] = tGraph[4]->GetRMS(2);
   else calibData[serial]->calRms[dirIndex][gain][channel][bucket][0] = 0;

   // Extract Range 1 Value Fit Results
   if ( tGraph[7] != NULL && tGraph[7]->GetFunction("pol1") != NULL ) {
      calibData[serial]->calGain[dirIndex][gain][channel][bucket][1] = tGraph[7]->GetFunction("pol1")->GetParameter(1);
      calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][1] = tGraph[7]->GetFunction("pol1")->GetParameter(0);
   }
   else if ( tGraph[1] != NULL && tGraph[1]->GetFunction("pol1") != NULL ) {
      calibData[serial]->calGain[dirIndex][gain][channel][bucket][1] = tGraph[1]->GetFunction("pol1")->GetParameter(1);
      calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][1] = tGraph[1]->GetFunction("pol1")->GetParameter(0);
   }
   if ( tGraph[5] != NULL ) calibData[serial]->calRms[dirIndex][gain][channel][bucket][1] = tGraph[5]->GetRMS(2);
   else calibData[serial]->calRms[dirIndex][gain][channel][bucket][1] = 0;

   // Extract fit results
   if ( tHist[0] != NULL && tHist[0]->GetFunction("gaus") != NULL ) {
      calibData[serial]->distMean[dirIndex][gain][channel][bucket]  = tHist[0]->GetFunction("gaus")->GetParameter(1);
      calibData[serial]->distSigma[dirIndex][gain][channel][bucket] = tHist[0]->GetFunction("gaus")->GetParameter(2);
      calibData[serial]->distRms[dirIndex][gain][channel][bucket]   = tHist[0]->GetRMS();
   }
   else {
      calibData[serial]->distMean[dirIndex][gain][channel][bucket]  = 0;
      calibData[serial]->distSigma[dirIndex][gain][channel][bucket] = 0;
      calibData[serial]->distRms[dirIndex][gain][channel][bucket]   = 0;
   }

   // Write if enabled
   if ( writeEn ) {

      // Select directory
      outFileRoot->setDir(dirNames[dirIndex]);

      // Write tHistograms
      if ( tHist[0] != NULL ) tHist[0]->Write();
      if ( tHist[1] != NULL ) tHist[1]->Write();

      // Write calibration
      if ( tGraph[0] != NULL ) 
         tGraph[0]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_value",0).c_str());
      if ( tGraph[1] != NULL ) 
         tGraph[1]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_value",1).c_str());
      if ( tGraph[2] != NULL ) 
         tGraph[2]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_time",0).c_str());
      if ( tGraph[3] != NULL ) 
         tGraph[3]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_time",1).c_str());
      if ( tGraph[4] != NULL ) 
         tGraph[4]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_resid",0).c_str());
      if ( tGraph[5] != NULL ) 
         tGraph[5]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_resid",1).c_str());
      if ( tGraph[6] != NULL ) 
         tGraph[6]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_filt",0).c_str());
      if ( tGraph[7] != NULL ) 
         tGraph[7]->Write(KpixCalibRead::genPlotName(gain, asic[serial]->getSerial(), channel, bucket,"calib_filt",1).c_str());

      // Reset directory
      outFileRoot->setDir("/");
   }

   // Generate multitGraphs
   // Calib
   tmGraph[0] = new TMultiGraph(); valid = false;
   if ( tGraph[0] != NULL ) {
      tGraph[0]->SetMarkerColor(4);
      tmGraph[0]->Add(tGraph[0]);
      tmGraph[0]->SetTitle(tGraph[0]->GetTitle());
      valid = true;
   }
   if ( tGraph[1] != NULL ) {
      tGraph[1]->SetMarkerColor(3);
      tmGraph[0]->Add(tGraph[1]);
      tmGraph[0]->SetTitle(tGraph[1]->GetTitle());
      valid = true;
   }
   if ( tGraph[6] != NULL ) {
      tGraph[6]->SetMarkerColor(4);
      tmGraph[0]->Add(tGraph[6]);
      tmGraph[0]->SetTitle(tGraph[6]->GetTitle());
      valid = true;
   }
   if ( tGraph[7] != NULL ) {
      tGraph[7]->SetMarkerColor(3);
      tmGraph[0]->Add(tGraph[7]);
      tmGraph[0]->SetTitle(tGraph[7]->GetTitle());
      valid = true;
   }
   if ( ! valid ) {
      delete tmGraph[0];
      tmGraph[0] = NULL;
   }

   // Time
   tmGraph[1] = new TMultiGraph(); valid = false;
   if ( tGraph[2] != NULL ) {
      tGraph[2]->SetMarkerColor(4);
      tmGraph[1]->Add(tGraph[2]);
      tmGraph[1]->SetTitle(tGraph[2]->GetTitle());
      valid = true;
   }
   if ( tGraph[3] != NULL ) {
      tGraph[3]->SetMarkerColor(3);
      tmGraph[1]->Add(tGraph[3]);
      tmGraph[1]->SetTitle(tGraph[3]->GetTitle());
      valid = true;
   }
   if ( ! valid ) {
      delete tmGraph[1];
      tmGraph[1] = NULL;
   }

   // Residuals
   tmGraph[2] = new TMultiGraph(); valid = false;
   if ( tGraph[4] != NULL ) {
      tGraph[4]->SetMarkerColor(4);
      tmGraph[2]->Add(tGraph[4]);
      tmGraph[2]->SetTitle(tGraph[4]->GetTitle());
      valid = true;
   }
   if ( tGraph[5] != NULL ) {
      tGraph[5]->SetMarkerColor(3);
      tmGraph[2]->Add(tGraph[5]);
      tmGraph[2]->SetTitle(tGraph[5]->GetTitle());
      valid = true;
   }
   if ( ! valid ) {
      delete tmGraph[2];
      tmGraph[2] = NULL;
   }

   // Update data display
   if ( dispEn ) {

      // Create array to hold plots
      for (x=0; x<3; x++) plots[x]  = (void *)tmGraph[x];
      for (x=0; x<2; x++) plots[3+x] = (void *)tHist[x];

      // Pass plots to main thread
      data = new KpixGuiEventData(DataPlots,5,plots);
      QApplication::postEvent(this,data);
   }
   else {
      for (x=0; x<3; x++) if ( tmGraph[x] != NULL ) delete tmGraph[x]; 
      for (x=0; x<2; x++) if ( tHist[x]   != NULL ) delete tHist[x]; 
   }
}


// Update summary plots
void KpixGuiCalFit::updateSummary () {
   unsigned int     x, chCount, locChannel, locBucket;
   stringstream     temp;
   string           temp2;
   void             *plots[9];
   KpixGuiEventData *data;
   TH1F             *newHist[9];
   double           histMin[9];
   double           histMax[9];
   unsigned int     dirIndex;
   unsigned int     serial;
   unsigned int     gain;
   unsigned int     range;
   double           value;

   // Get Channel Count
   chCount = asic[0]->getChCount();

   // Get directory, serial number and gain settings
   dirIndex = selDir->currentItem();
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();

   // Determine which range to use
   if ( gain == 1 ) range = 1;
   else range = 0;

   // Determine Title Append
   temp.str("");
   if ( dirIndex == 0 ) temp << "Force Trig, ";
   if ( dirIndex == 1 ) temp << "Self Trig, ";
   if ( gain == 0 ) temp << "Norm, ";
   if ( gain == 1 ) temp << "Double, ";
   if ( gain == 2 ) temp << "Low, ";
   temp << "KPIX=" << setfill('0') << dec << setw(4) << asic[serial]->getSerial();

   // Recreate newHistograms
   temp2 = "Gain, " + temp.str();
   newHist[0]  = new TH1F("gain",temp2.c_str(),2000,0,20e15);
   newHist[0]->SetDirectory(0);
   histMin[0] = 20e15;
   histMax[0] = 0;

   temp2 = "Intercept, " + temp.str();
   newHist[1]  = new TH1F("intercept",temp2.c_str(),500,0,500);
   newHist[1]->SetDirectory(0);
   histMin[1] = 500;
   histMax[1] = 0;

   temp2 = "RMS, " + temp.str();
   newHist[2]  = new TH1F("rms",temp2.c_str(),100,0,20);
   newHist[2]->SetDirectory(0);
   histMin[2] = 20;
   histMax[2] = 0;

   temp2 = "Mean, " + temp.str();
   newHist[3]  = new TH1F("mean",temp2.c_str(),500,0,500);
   newHist[3]->SetDirectory(0);
   histMin[3] = 500;
   histMax[3] = 0;

   temp2 = "Sigma, " + temp.str();
   newHist[4]  = new TH1F("sigma",temp2.c_str(),50,0,10);
   newHist[4]->SetDirectory(0);
   histMin[4] = 10;
   histMax[4] = 0;

   temp2 = "Rms (el), " + temp.str();
   newHist[5]  = new TH1F("rms_el",temp2.c_str(),1000,0,100000);
   newHist[5]->SetDirectory(0);
   histMin[5] = 100000;
   histMax[5] = 0;

   temp2 = "Sigma (el), " + temp.str();
   newHist[6]  = new TH1F("sigma_el",temp2.c_str(),1000,0,100000);
   newHist[6]->SetDirectory(0);
   histMin[6] = 100000;
   histMax[6] = 0;

   temp2 = "HRMS, " + temp.str();
   newHist[7]  = new TH1F("hrms",temp2.c_str(),50,0,10);
   newHist[7]->SetDirectory(0);
   histMin[7] = 10;
   histMax[7] = 0;

   temp2 = "HRMS (el), " + temp.str();
   newHist[8]  = new TH1F("hrms_el",temp2.c_str(),1000,0,100000);
   newHist[8]->SetDirectory(0);
   histMin[8] = 100000;
   histMax[8] = 0;

   // Get data
   for (locChannel=0; locChannel < chCount; locChannel++) {
      for (locBucket=0; locBucket < 4; locBucket++) {
         value = calibData[serial]->calGain[dirIndex][gain][locChannel][locBucket][range];
         if ( value > histMax[0] ) histMax[0] = value;
         if ( value < histMin[0] ) histMin[0] = value;
         newHist[0]->Fill(value);
         value = calibData[serial]->calIntercept[dirIndex][gain][locChannel][locBucket][range];
         if ( value > histMax[1] ) histMax[1] = value;
         if ( value < histMin[1] ) histMin[1] = value;
         newHist[1]->Fill(value);
         value = calibData[serial]->calRms[dirIndex][gain][locChannel][locBucket][range];
         if ( value > histMax[2] ) histMax[2] = value;
         if ( value < histMin[2] ) histMin[2] = value;
         newHist[2]->Fill(value);
         value = calibData[serial]->distMean[dirIndex][gain][locChannel][locBucket];
         if ( value > histMax[3] ) histMax[3] = value;
         if ( value < histMin[3] ) histMin[3] = value;
         newHist[3]->Fill(value);
         value = calibData[serial]->distSigma[dirIndex][gain][locChannel][locBucket];
         if ( value > histMax[4] ) histMax[4] = value;
         if ( value < histMin[4] ) histMin[4] = value;
         newHist[4]->Fill(value);
         value = calibData[serial]->distRms[dirIndex][gain][locChannel][locBucket];
         if ( value > histMax[7] ) histMax[7] = value;
         if ( value < histMin[7] ) histMin[7] = value;
         newHist[7]->Fill(value);

         // Electrons
         if ( calibData[serial]->calGain[dirIndex][gain][locChannel][locBucket][range] != 0 ) {
            value = ((calibData[serial]->calRms[dirIndex][gain][locChannel][locBucket][range] / 
                      calibData[serial]->calGain[dirIndex][gain][locChannel][locBucket][range]) * 1e15*6240);
            if ( value > histMax[5] ) histMax[5] = value;
            if ( value < histMin[5] ) histMin[5] = value;
            newHist[5]->Fill(value);
            value = ((calibData[serial]->distSigma[dirIndex][gain][locChannel][locBucket] / 
                      calibData[serial]->calGain[dirIndex][gain][locChannel][locBucket][range]) * 1e15*6240);
            if ( value > histMax[6] ) histMax[6] = value;
            if ( value < histMin[6] ) histMin[6] = value;
            newHist[6]->Fill(value);
            value = ((calibData[serial]->distRms[dirIndex][gain][locChannel][locBucket] / 
                      calibData[serial]->calGain[dirIndex][gain][locChannel][locBucket][range]) * 1e15*6240);
            if ( value > histMax[8] ) histMax[8] = value;
            if ( value < histMin[8] ) histMin[8] = value;
            newHist[8]->Fill(value);
         }
      }
   }

   // Update Range
   for (x=0; x<9; x++) if ( newHist[x] != NULL ) newHist[x]->GetXaxis()->SetRangeUser(histMin[x],histMax[x]);

   // Create array to hold plots
   for (x=0; x<9; x++) plots[x] = (void *)newHist[x];

   // Pass plots to main thread
   data = new KpixGuiEventData(DataSummary,9,plots);
   QApplication::postEvent(this,data);
}


void KpixGuiCalFit::closeEvent(QCloseEvent *e) {
   inFileClose_pressed();
   if ( kpixGuiViewConfig->close() &&
        kpixGuiSampleView->close() ) {
      inFileClose_pressed();
      e->accept();
   }
   else e->ignore();
}


void KpixGuiCalFit::selChanged() {
   if ( ! isRunning ) {
      setEnabled(false);
      cmdType = CmdReadOne;
      isRunning = true;
      QThread::start();
   }
}


void KpixGuiCalFit::prevPlot_pressed() {
   int dirIndex, channel, serial, bucket, chCount, gain;

   // Get Current Values
   dirIndex = selDir->currentItem();
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();
   bucket   = selBucket->value();
   chCount  = asic[0]->getChCount();

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
   if ( serial == -1 ) {
      serial = asicCnt-2;
      dirIndex--;
   }
   if ( dirIndex == -1 ) dirIndex = DIR_COUNT-1;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   selDir->setCurrentItem(dirIndex);
   selGain->setCurrentItem(gain);
   selChanged();
}


void KpixGuiCalFit::nextPlot_pressed() {
   int dirIndex, channel, serial, bucket, chCount, gain;

   // Get Current Values
   dirIndex = selDir->currentItem();
   gain     = selGain->currentItem();
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
      gain++;
   }
   if ( gain == 3 ) {
      gain = 0;
      serial++;
   }
   if ( serial == ((int)asicCnt-1) ) {
      serial = 0;
      dirIndex++;
   }
   if ( dirIndex == DIR_COUNT ) dirIndex = 0;

   // Set Current Values
   selSerial ->setCurrentItem(serial);
   selChannel->setValue(channel);
   selBucket->setValue(bucket);
   selDir->setCurrentItem(dirIndex);
   selGain->setCurrentItem(gain);
   selChanged();
}


// Thread for command run
void KpixGuiCalFit::run() {
   KpixGuiEventStatus *event;
   KpixGuiEventError  *error;
   unsigned int       x;
   stringstream       temp, cmd;
   string             calTime;
   KpixRunVar         *runVar;
   unsigned int       curr, total;
   QString            qtemp;
   unsigned int       dirIndex;
   unsigned int       gain;
   unsigned int       serial;
   unsigned int       channel;
   unsigned int       bucket;

   // Get current entries
   dirIndex = selDir->currentItem();
   gain     = selGain->currentItem();
   serial   = selSerial->currentItem();
   channel  = selChannel->value();
   bucket   = selBucket->value();

   // Which command
   try {
      switch ( cmdType ) {

         case CmdReadOne: 
            readFitData(dirIndex,gain,serial,channel,bucket,reFitEn->isChecked(),false,true);
            updateSummary();
            break;

         case CmdFileOpen:

            // Open File
            inFileRoot = new KpixCalibRead(inFile->text().ascii());
            gErrorIgnoreLevel = 5000; 

            // Create asics and calib data structures
            asicCnt   = inFileRoot->kpixRunRead->getAsicCount()-1;
            asic      = (KpixAsic **) malloc(sizeof(KpixAsic *)*asicCnt);
            calibData = (KpixGuiCalFitData **) malloc(sizeof(KpixGuiCalFitData *)*asicCnt);
            for (x=0; x<asicCnt; x++) {
               asic[x] = inFileRoot->kpixRunRead->getAsic(x);
               calibData[x] = new KpixGuiCalFitData();
            }

            // Loop through types
            total = DIR_COUNT*3*asicCnt*asic[0]->getChCount();
            for (dirIndex=0; dirIndex < DIR_COUNT; dirIndex++) {
               for (gain=0; gain < 3; gain++) {
                  for (serial=0; serial < asicCnt; serial++) {
                     for (channel=0; channel < asic[0]->getChCount(); channel++) {
                        for (bucket=0; bucket < 4; bucket++) 
                           readFitData(dirIndex,gain,serial,channel,bucket,false,false,false);
                        curr = (dirIndex*3*asicCnt*asic[0]->getChCount()) +
                               (gain*asicCnt*asic[0]->getChCount()) +
                               (serial*asic[0]->getChCount()) + channel;
                        event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,curr,total);
                        QApplication::postEvent(this,event);
                     }
                  } 
               }
            }
            dirIndex = 0;
            gain     = 0;
            serial   = 0;
            channel  = 0;
            bucket   = 0;
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
            total = DIR_COUNT*3*asicCnt*asic[0]->getChCount();
            for (dirIndex=0; dirIndex < DIR_COUNT; dirIndex++) {
               for (gain=0; gain < 3; gain++) {
                  for (serial=0; serial < asicCnt; serial++) {
                     for (channel=0; channel < asic[0]->getChCount(); channel++) {
                        for (bucket=0; bucket < 4; bucket++) 
                           readFitData(dirIndex,gain,serial,channel,bucket,true,true, false);
                        curr = (dirIndex*3*asicCnt*asic[0]->getChCount()) +
                               (gain*asicCnt*asic[0]->getChCount()) +
                               (serial*asic[0]->getChCount()) + channel;
                        event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,curr,total);
                        QApplication::postEvent(this,event);
                     }
                  } 
               }
            }
            dirIndex = 0;
            gain     = 0;
            serial   = 0;
            channel  = 0;
            bucket   = 0;
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
void KpixGuiCalFit::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError  *eventError;
   KpixGuiEventStatus *eventStatus;
   KpixGuiEventData   *eventData;
   stringstream       temp;
   unsigned int       x, chCount;
   unsigned int       dirIndex;
   unsigned int       gain;
   unsigned int       range;
   unsigned int       serial;
   unsigned int       channel;
   unsigned int       bucket;

   // Init range
   range = 0;

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
               selBucket->setValue(0);
               selDir->setCurrentItem(0);
               selGain->setCurrentItem(0);

               // Re-Start thread with read plot command
               cmdType = CmdReadOne;
               QThread::start();
            }
            else {
               isRunning = false;
               setEnabled(true);
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

         // Channel plots
         case ( DataPlots ):

            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear canvas
            calibCanvas->GetCanvas()->Clear();
            histCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            for (x=0; x<3; x++) {
               if ( mGraph[x] != NULL ) delete mGraph[x];
               mGraph[x] = (TMultiGraph *)eventData->data[x];
            }
            for (x=0; x<2; x++) {
               if ( hist[x] != NULL ) delete hist[x];
               hist[x] = (TH1F *) eventData->data[3+x];
            }

            // Draw calibration data
            calibCanvas->GetCanvas()->Divide(1,3,.01,.01);
            for (x=0; x < 3; x++) {
               calibCanvas->GetCanvas()->cd(x+1);
               if ( mGraph[x] != NULL ) mGraph[x]->Draw("A*");
            }
            calibCanvas->GetCanvas()->Update();

            // Draw histogram data
            histCanvas->GetCanvas()->Divide(1,2,.01,.01);
            for (x=0; x < 2; x++) {
               histCanvas->GetCanvas()->cd(x+1);
               if ( hist[x] != NULL ) hist[x]->Draw();
            }
            histCanvas->GetCanvas()->Update();

            // Get current selection
            dirIndex = selDir->currentItem();
            gain     = selGain->currentItem();
            serial   = selSerial->currentItem();
            channel  = selChannel->value();
            bucket   = selBucket->value();

            // Update fit values in main window
            temp.str("");
            temp << calibData[serial]->calGain[dirIndex][gain][channel][bucket][0];
            highGain->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->calGain[dirIndex][gain][channel][bucket][1];
            lowGain->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][0];
            highIcept->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][1];
            lowIcept->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->calRms[dirIndex][gain][channel][bucket][0];
            highRms->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->calRms[dirIndex][gain][channel][bucket][1];
            lowRms->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->distMean[dirIndex][gain][channel][bucket];
            histMean->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->distSigma[dirIndex][gain][channel][bucket];
            histSigma->setText(temp.str());
            temp.str("");
            temp << calibData[serial]->distRms[dirIndex][gain][channel][bucket];
            histRms->setText(temp.str());
            break;

         // Summary Plots
         case ( DataSummary ):

            // Set fit options
            gStyle->SetOptFit(1111);

            // Clear Canvas
            summaryCanvas->GetCanvas()->Clear();

            // Delete old plots, get new plots
            for (x=0; x<9; x++) {
               if ( sumHist[x] != NULL ) delete sumHist[x];
               sumHist[x] = (TH1F *) eventData->data[x];
            }

            // Summary canvas
            summaryCanvas->GetCanvas()->Divide(3,3,.01,.01);
            for (x=0; x < 9; x++) {
               summaryCanvas->GetCanvas()->cd(x+1);
               if ( sumHist[x] != NULL ) sumHist[x]->Draw();
            }
            summaryCanvas->GetCanvas()->Update();

            // Get current selection
            dirIndex = selDir->currentItem();
            gain     = selGain->currentItem();
            serial   = selSerial->currentItem();
            chCount  = asic[0]->getChCount();

            // Determine which range to use
            if ( gain == 1 ) range = 1;
            else range = 0;

            // Update table values
            for (channel=0; channel < chCount; channel++) {
               for (bucket=0; bucket < 4; bucket++) {

                  // Update Table
                  temp.str(""); temp << calibData[serial]->calGain[dirIndex][gain][channel][bucket][range];
                  summaryTable->setText(channel*4+bucket,1,temp.str());
                  temp.str(""); temp << calibData[serial]->calIntercept[dirIndex][gain][channel][bucket][range];
                  summaryTable->setText(channel*4+bucket,2,temp.str());
                  temp.str(""); temp << calibData[serial]->calRms[dirIndex][gain][channel][bucket][range];
                  summaryTable->setText(channel*4+bucket,3,temp.str());
                  temp.str(""); temp << calibData[serial]->distMean[dirIndex][gain][channel][bucket];
                  summaryTable->setText(channel*4+bucket,5,temp.str());
                  temp.str(""); temp << calibData[serial]->distSigma[dirIndex][gain][channel][bucket];
                  summaryTable->setText(channel*4+bucket,6,temp.str());
                  temp.str(""); temp << calibData[serial]->distRms[dirIndex][gain][channel][bucket];
                  summaryTable->setText(channel*4+bucket,8,temp.str());

                  // Electron Values
                  if ( calibData[serial]->calGain[dirIndex][gain][channel][bucket][range] != 0 ) {
                     temp.str(""); temp << ((calibData[serial]->calRms[dirIndex][gain][channel][bucket][range] / 
                                             calibData[serial]->calGain[dirIndex][gain][channel][bucket][range]) * 1e15*6240);
                     summaryTable->setText(channel*4+bucket,4,temp.str());
                     temp.str(""); temp << ((calibData[serial]->distSigma[dirIndex][gain][channel][bucket] / 
                                             calibData[serial]->calGain[dirIndex][gain][channel][bucket][range]) * 1e15*6240);
                     summaryTable->setText(channel*4+bucket,7,temp.str());
                     temp.str(""); temp << ((calibData[serial]->distRms[dirIndex][gain][channel][bucket] / 
                                             calibData[serial]->calGain[dirIndex][gain][channel][bucket][range]) * 1e15*6240);
                     summaryTable->setText(channel*4+bucket,9,temp.str());
                  }
                  else {
                     summaryTable->setText(channel*4+bucket,4,"");
                     summaryTable->setText(channel*4+bucket,7,"");
                     summaryTable->setText(channel*4+bucket,9,"");
                  }
               }
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


