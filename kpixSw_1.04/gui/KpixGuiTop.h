//-----------------------------------------------------------------------------
// File          : KpixGuiTop.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the KPIX ASICs
// This is a class which builds off of the class created in
// KpixGuiTopForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
// 04/29/2009: Added thread to handle IO functions
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_TOP_H__
#define __KPIX_GUI_TOP_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiTopForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <SidLink.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qerrormessage.h>
#include <qtable.h>
#include <qthread.h>
#include <qspinbox.h>
#include "KpixGuiInject.h"
#include "KpixGuiConfig.h"
#include "KpixGuiError.h"
#include "KpixGuiFpga.h"
#include "KpixGuiMain.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"
#include "KpixGuiStatus.h"
#include "KpixGuiRegTest.h"
#include "KpixGuiRun.h"
#include "KpixGuiCalibrate.h"
#include "KpixGuiThreshScan.h"
#include "KpixGuiEventStatus.h"
#include "KpixGuiEventError.h"


// Max support KPIX Address
#define KPIX_MAX_ADDR 3


class KpixGuiTop : public KpixGuiTopForm, public QThread {

      // ASIC & FPGA Containers
      unsigned int  asicCnt;
      unsigned int  asicVersion;
      unsigned int  defClkPeriod;
      unsigned int  cmdType;
      KpixAsic      *asic[KPIX_MAX_ADDR+1];
      KpixFpga      *fpga;
      KpixRunRead   *runRead;
      SidLink       *sidLink;
      KpixGuiError  *errorMsg;

      // Widgets In the Tabs
      KpixGuiMain       *kpixGuiMain;
      KpixGuiFpga       *kpixGuiFpga;
      KpixGuiConfig     *kpixGuiConfig;
      KpixGuiTiming     *kpixGuiTiming;
      KpixGuiStatus     *kpixGuiStatus;
      KpixGuiTrig       *kpixGuiTrig;
      KpixGuiInject     *kpixGuiInject;
      KpixGuiRegTest    *kpixGuiRegTest;
      KpixGuiCalibrate  *kpixGuiCalibrate;
      KpixGuiThreshScan *kpixGuiThreshScan;
      KpixGuiRun        *kpixGuiRun;

      // Constants for command type
      static const unsigned int CmdReadStatus    = 1;
      static const unsigned int CmdClearCounters = 2;
      static const unsigned int CmdReadConfig    = 3;
      static const unsigned int CmdWriteConfig   = 4;
      static const unsigned int CmdSetDefaults   = 5;
      static const unsigned int CmdRescanKpix    = 6;
      static const unsigned int CmdLoadSettings  = 7;

   public:

      // Creation Class
      KpixGuiTop ( SidLink *sidLink, unsigned int clkPeriod, unsigned int version, 
                   string baseDir, string calString, unsigned int rateLimit, 
                   QWidget *parent=0 );

      // Delete
      ~KpixGuiTop ( );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Get Run Description
      string getRunDescription();

      // Get Base Directory
      string getBaseDir();

      // Get Run Variable List
      KpixRunVar **getRunVarList(unsigned int *count);

      // Get rate limit value, zero for none
      unsigned int getRateLimit();

      // Get Calibration/Settings File Name
      string getCalFile ();

      // Window was closed
      void closeEvent(QCloseEvent *e);

   protected:

      void run();

   private slots:

      void customEvent ( QCustomEvent *event );
      void kpixReScan_pressed();
      void calibMenu_pressed();
      void threshScanMenu_pressed();
      void regTest_pressed();
      void runMenu_pressed();
      void readStatus_pressed();
      void clearCounters_pressed();
      void writeConfig_pressed();
      void kpixAsicDebug_toggled( bool );
      void kpixFpgaDebug_toggled( bool );
      void sidLinkDebug_toggled( bool );
      void calEnable_toggled( );
      void dumpSettings_pressed( );
      void setDefaults_pressed( );
      void baseDirBrowse_pressed();
      void calSetBrowse_pressed();
      void clearFile_pressed();
      void loadSettings_pressed();

   public slots:

      // update display
      void readConfig_pressed();
      void updateDisplay();
};

#endif
