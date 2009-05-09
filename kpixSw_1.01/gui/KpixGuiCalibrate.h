//-----------------------------------------------------------------------------
// File          : KpixGuiCalibrate.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC calibration.
// This is a class which builds off of the class created in
// KpixGuiCalibrateForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_CALIBRATE_H__
#define __KPIX_GUI_CALIBRATE_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiCalibrateForm.h"
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
#include "KpixGuiCalFit.h"

class KpixGuiTop;

class KpixGuiCalibrate : public KpixGuiCalibrateForm, public QThread, public KpixProgress {

      // ASIC & FPGA Containers
      unsigned int  asicCnt;
      KpixAsic      **asic;
      KpixFpga      *fpga;
      KpixGuiTop    *parent;
      KpixGuiError  *errorMsg;
      bool          enRun;
      bool          isRunning;
      string        baseDir, desc, outDataDir, outDataFile;
      void          *plots[16];
      unsigned int  pType;
      unsigned int  prgCurrent;
      unsigned int  prgTotal;
      KpixRunVar    **runVars;
      unsigned int  runVarCount;
      TMultiGraph   *mGraph[2];
      KpixGuiCalFit *calFit;

   public:

      // Creation Class
      KpixGuiCalibrate ( KpixGuiTop *parent );

      // Delete
      ~KpixGuiCalibrate ( );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Set Configurations
      void setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga );

      // Update progress
      void updateProgress(unsigned int count, unsigned int total);
      void updateData(unsigned int id, unsigned int count, void **data);

      // Window was closed
      void closeEvent(QCloseEvent *e);

      // Close is called
      bool close();

   protected:

      void run();

   private slots:

      void runTest_pressed();
      void stopTest_pressed();
      void viewCalib_pressed();
      void customEvent ( QCustomEvent *event );

   public slots:

};

#endif
