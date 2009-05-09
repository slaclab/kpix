//-----------------------------------------------------------------------------
// File          : KpixGuiCalFit.h
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
#ifndef __KPIX_GUI_CAL_FIT_H__
#define __KPIX_GUI_CAL_FIT_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiCalFitForm.h"
#include "KpixGuiError.h"
#include "KpixGuiViewConfig.h"
#include "KpixGuiViewHist.h"
#include "KpixGuiViewCalib.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixCalibRead.h>
#include <KpixRunRead.h>
#include <KpixRunWrite.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <TFile.h>

// Number Of Directories
#define DIR_COUNT 2


// Class to hold calibration results
class KpixGuiCalFitData {
   public:
      double calGain[DIR_COUNT][3][1024][4];
      double calIntercept[DIR_COUNT][3][1024][4];
      double calRms[DIR_COUNT][3][1024][4];
      double distMean[DIR_COUNT][3][1024][4];
      double distSigma[DIR_COUNT][3][1024][4];
      double distRms[DIR_COUNT][3][1024][4];
      bool   calWriteDone[DIR_COUNT][3][1024][4];
      bool   distWriteDone[DIR_COUNT][3][1024][4];
};


class KpixGuiCalFit : public KpixGuiCalFitForm {

      // Error Message
      KpixGuiError  *errorMsg;

      // Input/Output Files
      KpixCalibRead *inFileRoot;
      bool          inFileIsOpen;
      KpixRunWrite  *outFileRoot;
      bool          outFileIsOpen;

      // Display Windows
      KpixGuiViewConfig *kpixGuiViewConfig;
      KpixGuiViewHist   *kpixGuiViewHist;
      KpixGuiViewCalib  *kpixGuiViewCalib;

      // Output Calibration Data
      KpixGuiCalFitData *outCalibData;
      KpixGuiCalFitData *inCalibData;

      // List of directories
      string dirNames[DIR_COUNT];

      // Default base directory
      string baseDir;

      // Histogram plot
      TH1F *hist;
      bool isNonZero;

      // Auto update flag
      bool inAutoUpdate;

   public:

      // Creation Class
      KpixGuiCalFit ( string baseDir, bool open=false);

      // Delete
      ~KpixGuiCalFit ( );

      // Set Button Enables
      void setEnabled(bool enable);

      // Is Hist or Calib Writable
      bool isHistWritable(int dirIndex,int gain,int serial,int channel,int bucket);
      bool isCalibWritable(int dirIndex,int gain,int serial,int channel,int bucket);

      // Write Hist or Calib Data
      void writeHist(int dirIndex,int gain,int serial,int channel,int bucket,TH1F **hist);
      void writeCalib(int dirIndex,int gain,int serial,int channel,int bucket,TGraph **graph);

      // Window was closed
      void closeEvent(QCloseEvent *e);

   public slots:

      void updateDisplay();
      void inFileBrowse_pressed();
      void inFileOpen_pressed();
      void inFileClose_pressed();
      void outFileBrowse_pressed();
      void outFileOpen_pressed();
      void outFileClose_pressed();
      void viewConfig_pressed();
      void viewInCalib_pressed();
      void viewInHist_pressed();
      void autoWriteAll_pressed();
      void writePdf_pressed();
};

#endif
