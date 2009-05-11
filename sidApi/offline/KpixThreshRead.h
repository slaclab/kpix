//-----------------------------------------------------------------------------
// File          : KpixThreshRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/27/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// This class is used to read threshold scan plots.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/27/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_THREAH_READ_H__
#define __KPIX_THREAH_READ_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <Rtypes.h>
#include <TObject.h>
#include <TFile.h>
#include <TText.h>
#include <TGraph.h>
#include <TH2F.h>
#include <TH1D.h>
#include <TGraphAsymmErrors.h>
#include <TError.h>
#include <TStyle.h>
#include "KpixRunRead.h"
using namespace std;

// Calibration Data Class
class KpixThreshRead {

      // Flag to delete runRead
      bool delRunRead;

   public:

      // Run Read Class
      KpixRunRead *kpixRunRead;

      // Calib Data Class Constructor
      // Pass path to calibration data or
      KpixThreshRead ( string threshFile, bool debug = false );

      // Calib Data Class Constructor
      // Pass already open run read class
      KpixThreshRead ( KpixRunRead *kpixRunRead );

      // Calib Data Class DeConstructor
      ~KpixThreshRead ( );

      // Function to create plot name
      static string genPlotName ( string prefix, int gain, int kpix, int channel, int cal=-1 );

      // Function to create plot title
      static string genPlotTitle ( string prefix, int gain, int kpix, int channel, int cal=-1 );

      // Get Threshold Scan Histogram
      TH2F *getThreshScan ( string dir, int gain, int kpix, int channel, int cal );

      // Get Threshold Curve
      TGraphAsymmErrors *getThreshCurve ( string dir, int gain, int kpix, int channel);

      // Get Threshold Cal
      TGraphAsymmErrors *getThreshCal ( string dir, int gain, int kpix, int channel, int cal);

      // Get Threshold Gain
      TGraph *getThreshGain ( string dir, int gain, int kpix, int channel);

      // Get Threshold Data
      bool getThreshData (double *meanVal, double *sigmaVal, double *gainVal, string dir,int gain,int serNum,int channel);

      // Get Calibration Sigma Value
      bool getCalSigma (double *sigmaVal,string dir,int gain,int serNum,int channel, int cal);

};

#endif
