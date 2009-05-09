//-----------------------------------------------------------------------------
// File          : KpixGuiRunView.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for viewing run data.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_RUN_VIEW_H__
#define __KPIX_GUI_RUN_VIEW_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiRunViewForm.h"
#include "KpixGuiError.h"
#include "KpixGuiSampleView.h"
#include "KpixGuiViewConfig.h"
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
#include <qthread.h>
#include <TFile.h>


class KpixGuiRunView : public KpixGuiRunViewForm, public QThread {

      // Error Message
      KpixGuiError  *errorMsg;

      // Input/Output Files
      KpixRunRead *inFileRoot;

      // Display Windows
      KpixGuiViewConfig *kpixGuiViewConfig;
      KpixGuiSampleView *kpixGuiSampleView;

      // Default base directory
      string baseDir;

      // Histogram plots
      TH1F *hist[4];

      // Thread is running
      bool isRunning;

      // List of KPIX serial numbers
      unsigned int  asicCnt;
      KpixAsic      **asic;

      // Command type
      unsigned int cmdType;

      // Commands
      static const unsigned int CmdReadFile  = 1;
      static const unsigned int CmdReadPlot  = 2;

   public:

      // Creation Class
      KpixGuiRunView ( string baseDir, bool open=false);

      // Delete
      ~KpixGuiRunView ( );

      // Set Button Enables
      void setEnabled(bool enable);

      // Window was closed
      void closeEvent(QCloseEvent *e);

   protected:

      void run();

   public slots:

      void customEvent ( QCustomEvent *event );
      void readPlot();
      void inFileBrowse_pressed();
      void inFileOpen_pressed();
      void inFileClose_pressed();
      void nextChan_pressed();
      void prevChan_pressed();
      void viewConfig_pressed();
      void viewSamples_pressed();
      void writePdf_pressed();
};

#endif
