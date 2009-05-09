//-----------------------------------------------------------------------------
// File          : KpixGuiViewHist.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for viewing histograms.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_VIEW_HIST_H__
#define __KPIX_GUI_VIEW_HIST_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiViewHistForm.h"
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
#include "KpixGuiInject.h"
#include "KpixGuiConfig.h"
#include "KpixGuiError.h"
#include "KpixGuiList.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"

class KpixGuiCalFit;

class KpixGuiViewHist : public KpixGuiViewHistForm {

      // Input File
      KpixCalibRead *kpixCalibData;

      // Parent
      KpixGuiCalFit *parent;

      // Graphs
      TH1F *hist[2];

      // At last status
      bool atLast;

   public:

      // Creation Class
      KpixGuiViewHist ( unsigned int dirCount, string *dirNames, KpixGuiCalFit *parent );

      // Delete class
      ~KpixGuiViewHist();

      // Set Calib Data
      void setCalibData ( KpixCalibRead *kpixCalibData );

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
