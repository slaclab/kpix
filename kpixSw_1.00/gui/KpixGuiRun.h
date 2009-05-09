//-----------------------------------------------------------------------------
// File          : KpixGuiRun.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC data runs.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_RUN_H__
#define __KPIX_GUI_RUN_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiRunForm.h"
#include "KpixGuiError.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixProgress.h>
#include <KpixCalDist.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <TMultiGraph.h>
#include <qtable.h>
#include <qthread.h>
#include <qspinbox.h>
#include <TQtWidget.h>
#include <TCanvas.h>
#include "KpixGuiEventRun.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventData.h"
#include "KpixGuiRunView.h"

class KpixGuiTop;

class KpixGuiRun : public KpixGuiRunForm, public QThread {

      // ASIC & FPGA Containers
      unsigned int asicCnt;
      KpixAsic     **asic;
      KpixFpga     *fpga;
      KpixGuiTop   *parent;
      KpixGuiError *errorMsg;
      bool         enRun;
      bool         pRun;
      bool         isRunning;
      string       baseDir, desc, outDataDir, outDataFile, calFile;
      TH1F         *plots[32];
      unsigned int prgCurrent;
      unsigned int prgTotal;
      KpixRunVar   **runVars;
      unsigned int runVarCount;
      int          dispKpix[16];
      int          dispChan[16];

   public:

      // Creation Class
      KpixGuiRun ( KpixGuiTop *parent );

      // Delete
      ~KpixGuiRun ( );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Set Configurations
      void setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga, KpixRunRead *runRead=NULL );

      // Window was closed
      void closeEvent(QCloseEvent *e);

      // Run Data Viewer
      KpixGuiRunView *runView;

      // Close is called
      bool close();

      // Show is called
      void show();

   protected:

      void run();

   private slots:

      void startRun_pressed();
      void stopRun_pressed();
      void pauseRun_stateChanged(int state);
      void viewData_pressed();
      void customEvent ( QCustomEvent *event );
      void addEvent_pressed();
      void delEvent_pressed();

   public slots:

};

#endif
