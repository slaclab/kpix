//-----------------------------------------------------------------------------
// File          : KpixGuiThreshChan.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing a threshold scan channel.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_THRESH_CHAN_H__
#define __KPIX_GUI_THRESH_CHAN_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiThreshChanForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixThreshRead.h>
#include <SidLink.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qerrormessage.h>
#include <qtable.h>
#include <qspinbox.h>
#include <TH2F.h>
#include <TMultiGraph.h>
#include <TGraphAsymmErrors.h>
#include <TGraph.h>
#include "KpixGuiInject.h"
#include "KpixGuiConfig.h"
#include "KpixGuiError.h"
#include "KpixGuiList.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"

class KpixGuiThreshView;

class KpixGuiThreshChan : public KpixGuiThreshChanForm {

      // Parent
      KpixGuiThreshView *parent;

      // Input File
      KpixThreshRead *threshRead;

      // Graphs
      TH2F              *origHist;
      TGraphAsymmErrors *calGraph[256];
      TGraphAsymmErrors *threshGraph;
      TGraph            *calPlot;

      // Calibration Range
      unsigned int calMin;
      unsigned int calMax;
      unsigned int calStep;

      // Cal Pulse Time Range
      unsigned int minCalTime;
      unsigned int maxCalTime;

      // Trigger Inhibit Time
      unsigned int trigInh;

      // Number of iterations in run
      unsigned int threshCount;

      // At last plot
      bool atLast;

      // Convert histogram to error plot
      // Pass original histogram containing a bin for each threshold value.
      // Pass total number of iterations for bayes divide.
      // Returned plot will have millivolts on the x-axis
      // hint pointer will be set to estimated mean value
      // min & max pointers will be updated
      static TGraphAsymmErrors *convertHist (TH1D *passHist, unsigned int total, double *hint,
                                             double *min, double *max);

   public:

      // Creation Class
      KpixGuiThreshChan ( KpixGuiThreshView *parent );

      // Delete class
      ~KpixGuiThreshChan();

      // Set Thresh Data
      void setThreshData ( KpixThreshRead *kpixThreshData );

      // Show
      void show();

   private slots:

      void updateDisplay();
      void prevPlot_pressed();
      void nextPlot_pressed();
      void writePdf_pressed();
      void saveCurr_pressed();

   public slots:
      void saveAll_pressed();

   public slots:
};

#endif
