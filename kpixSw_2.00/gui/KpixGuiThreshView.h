//-----------------------------------------------------------------------------
// File          : KpixGuiThreshView.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Top Level GUI for threshold scan view GUI
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_THRESH_VIEW_H__
#define __KPIX_GUI_THRESH_VIEW_H__

#include "KpixGuiThreshViewForm.h"
#include <string>
#include <qthread.h>

// Forward Declarations
namespace sidApi {
   namespace offline {
      class KpixThreshRead;
      class KpixAsic;
   }
   namespace online {
      class KpixRunWrite;
   }
}
class KpixGuiError;
class KpixGuiViewConfig;
class KpixGuiSampleView;
class TGraphAsymmErrors;
class TGraph;
class TH1F;
class TH1D;
class TH2F;


// Class to hold threshold results
class KpixGuiThreshViewData {
   public:
      double mean[3][1024];
      double sigma[3][1024];
      double gain[3][1024];
      double calMean[3][1024][256];
      double calSigma[3][1024][256];
};


class KpixGuiThreshView : public KpixGuiThreshViewForm , public QThread {

      // Error Message
      KpixGuiError  *errorMsg;

      // Input/Output Files
      sidApi::offline::KpixThreshRead *inFileRoot;
      sidApi::online::KpixRunWrite    *outFileRoot;

      // Asics
      unsigned int              asicCnt;
      sidApi::offline::KpixAsic **asic;

      // Calibration/histogram data
      TH2F              *origHist[256];
      TGraphAsymmErrors *calGraph[256];
      TGraphAsymmErrors *threshGraph;
      TGraph            *calPlot;
      TH1F              *sumHist[6];

      // Thread is running
      bool isRunning;

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

      // Command type
      unsigned int cmdType;

      // Command constants
      static const unsigned int CmdReadOne   = 1;
      static const unsigned int CmdFileOpen  = 2;
      static const unsigned int CmdFileWrite = 3;

      // Data Constants
      static const unsigned int DataOrigHist    = 1;
      static const unsigned int DataCalGraph    = 2;
      static const unsigned int DataThreshGraph = 3;
      static const unsigned int DataSummary     = 4;

      // Display Windows
      KpixGuiViewConfig *kpixGuiViewConfig;
      KpixGuiSampleView *kpixGuiSampleView;

      // Calibration Data
      KpixGuiThreshViewData **threshData;

      // Default base directory
      std::string baseDir;

      // Read data from file and fit if enabled, write if enabled
      void readFitData(unsigned int gain, unsigned int serial, unsigned int channel,  
                       bool fitEn, bool writeEn, bool dispEn );

      // Update summary plots
      void updateSummary();

      // Convert histogram to error plot
      // Pass original histogram containing a bin for each threshold value.
      // Pass total number of iterations for bayes divide.
      // Returned plot will have millivolts on the x-axis
      TGraphAsymmErrors *convertHist (TH1D *passHist, unsigned int total, double *hint, 
                                      double *min, double *max, bool debug, bool convert );


   protected:

      void run();

   public:

      // Creation Class
      KpixGuiThreshView ( std::string baseDir, bool open=false);

      // Delete
      ~KpixGuiThreshView ( );

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
