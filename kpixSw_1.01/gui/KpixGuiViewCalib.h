//-----------------------------------------------------------------------------
// File          : KpixGuiViewCalib.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing calibrations.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_VIEW_CALIB_H__
#define __KPIX_GUI_VIEW_CALIB_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiViewCalibForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixCalibRead.h>
#include <SidLink.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qerrormessage.h>
#include <qtable.h>
#include <qspinbox.h>
#include <TMultiGraph.h>
#include "KpixGuiInject.h"
#include "KpixGuiConfig.h"
#include "KpixGuiError.h"
#include "KpixGuiList.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"

class KpixGuiCalFit;

class KpixGuiViewCalib : public KpixGuiViewCalibForm {

      // Parent
      KpixGuiCalFit *parent;

      // Input File
      KpixCalibRead *kpixCalibData;

      // Graphs
      TGraph      *graph[8];
      TMultiGraph *mGraph[3];

      // Time buckets for 4 calibration pulses
      unsigned int calCount;
      unsigned int calTime[4];

      // At last status
      bool atLast;

   public:

      // Creation Class
      KpixGuiViewCalib (unsigned int dirCount, string *dirNames, KpixGuiCalFit *parent );

      // Delete class
      ~KpixGuiViewCalib();

      // Set Calib Data
      void setCalibData ( KpixCalibRead *kpixCalibData );

      // Set Data Directory
      void setDir(int dirIndex);

      // Show
      void show();

      // Force current directory selection
      void selectDir(unsigned int selDir);

   private slots:

      void updateDisplay();
      void prevPlot_pressed();
      void nextPlot_pressed();
      void writePlot_pressed();
      void writePdf_pressed();

   public slots:
      void writeAll_pressed();
};

#endif
