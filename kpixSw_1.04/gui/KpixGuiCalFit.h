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
// 04/30/2009: Remove seperate hist and cal view classes. All functions now
//             handled by this class. Added thread for read/fit operations.
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
#include "KpixGuiSampleView.h"
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
#include <qthread.h>
#include <qapplication.h>
#include <TMultiGraph.h>

// Number Of Directories
#define DIR_COUNT 2


// Class to hold calibration results
// One value for each:
//   directory
//   gain
//   channel
//   bucket
class KpixGuiCalFitData {
   public:
      double calGain[DIR_COUNT][3][1024][4][2];
      double calIntercept[DIR_COUNT][3][1024][4][2];
      double calRms[DIR_COUNT][3][1024][4][2];
      double distMean[DIR_COUNT][3][1024][4];
      double distSigma[DIR_COUNT][3][1024][4];
      double distRms[DIR_COUNT][3][1024][4];
};


class KpixGuiCalFit : public KpixGuiCalFitForm , public QThread {

      // Error Message
      KpixGuiError  *errorMsg;

      // Input/Output Files
      KpixCalibRead *inFileRoot;
      KpixRunWrite  *outFileRoot;

      // Asics
      unsigned int  asicCnt;
      KpixAsic      **asic;

      // Calibration/histogram data
      TGraph      *graph[8];
      TMultiGraph *mGraph[3];
      TH1F        *hist[2];
      TH1F        *sumHist[9];

      // Thread is running
      bool isRunning;

      // Time buckets for 4 calibration pulses
      unsigned int calCount;
      unsigned int calTime[4];

      // Command type
      unsigned int cmdType;

      // Command constants
      static const unsigned int CmdReadOne   = 1;
      static const unsigned int CmdFileOpen  = 2;
      static const unsigned int CmdFileWrite = 3;

      // Data Constants
      static const unsigned int DataPlots   = 1;
      static const unsigned int DataSummary = 2;

      // Display Windows
      KpixGuiViewConfig *kpixGuiViewConfig;
      KpixGuiSampleView *kpixGuiSampleView;

      // Calibration Data
      KpixGuiCalFitData **calibData;

      // List of directories
      string dirNames[DIR_COUNT];

      // Default base directory
      string baseDir;

      // Read data from file and fit if enabled, write if enabled
      void readFitData(unsigned int dirIndex, unsigned int gain, unsigned int serial, 
                       unsigned int channel, unsigned int bucket, bool fitEn, bool writeEn, bool dispEn );

      // Update summary plots
      void updateSummary();

   protected:

      void run();

   public:

      // Creation Class
      KpixGuiCalFit ( string baseDir, bool open=false);

      // Delete
      ~KpixGuiCalFit ( );

      // Set Button Enables
      void setEnabled(bool enable);

      // Window was closed
      void closeEvent(QCloseEvent *e);

   public slots:

      void customEvent ( QCustomEvent *event );
      void viewConfig_pressed();
      void viewSamples_pressed();
      void selChanged();
      void prevPlot_pressed();
      void nextPlot_pressed();
      void inFileBrowse_pressed();
      void inFileOpen_pressed();
      void inFileClose_pressed();
      void outFileBrowse_pressed();
      void writePdf_pressed();
      void autoWriteAll_pressed();
};

#endif
