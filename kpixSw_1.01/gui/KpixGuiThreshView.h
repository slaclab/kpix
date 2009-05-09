//-----------------------------------------------------------------------------
// File          : KpixGuiThreshView.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for thresh scan viewing
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_THRESH_VIEW_H__
#define __KPIX_GUI_THRESH_VIEW_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiThreshViewForm.h"
#include "KpixGuiError.h"
#include "KpixGuiViewConfig.h"
#include "KpixGuiThreshChan.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixThreshRead.h>
#include <KpixRunRead.h>
#include <KpixRunWrite.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <TFile.h>
#include <TGraphAsymmErrors.h>


// Class to hold threshold results
class KpixGuiThreshFitData {
   public:
      double mean[3][1024];
      double sigma[3][1024];
      double gain[3][1024];
      double calSigma[3][1024][256];
      bool   writeDone[3][1024];
};


class KpixGuiThreshView : public KpixGuiThreshViewForm {

      // Error Message
      KpixGuiError  *errorMsg;

      // Input/Output Files
      KpixThreshRead *inFileRoot;
      bool           inFileIsOpen;
      KpixRunWrite   *outFileRoot;
      bool           outFileIsOpen;

      // Display Windows
      KpixGuiViewConfig *kpixGuiViewConfig;
      KpixGuiThreshChan *kpixGuiThreshChan;

      // Threshold Data
      KpixGuiThreshFitData *inThreshData;
      KpixGuiThreshFitData *outThreshData;

      // Histogram plot
      TH1F *hist;

      // Base Directory
      string baseDir;

      // In Auto Update
      bool inAutoUpdate;
      bool isNonZero;

      // Calibration Range
      unsigned int calMin;
      unsigned int calMax;
      unsigned int calStep;

   public:

      // Creation Class
      KpixGuiThreshView ( string baseDir, bool open=false);

      // Delete
      ~KpixGuiThreshView ( );

      // Set Button Enables
      void setEnabled(bool enable);

      // Window was closed
      void closeEvent(QCloseEvent *e);

      // Write Thresh Data
      bool isThreshWritable(int gain,int serial,int channel);
      void writeThresh(int gain,int serial,int channel,TGraphAsymmErrors **calGraph,
                       TGraphAsymmErrors *threshGraph,TGraph *calPlot);

   public slots:

      void updateDisplay();
      void inFileBrowse_pressed();
      void inFileOpen_pressed();
      void inFileClose_pressed();
      void outFileBrowse_pressed();
      void outFileOpen_pressed();
      void outFileClose_pressed();
      void viewConfig_pressed();
      void viewChan_pressed();
      void writePdf_pressed();
      void autoWriteAll_pressed();
};

#endif
