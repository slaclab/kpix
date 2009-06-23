//-----------------------------------------------------------------------------
// File          : KpixThreshRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/27/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// This class is used to read threshold scan plots.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/27/2008: created
// 06/18/2009: Added namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_THREAH_READ_H__
#define __KPIX_THREAH_READ_H__

#include <string>

// Forward declarations
namespace sidApi {
   namespace offline {
      class KpixRunRead;
   }
}
class TH2F;
class TGraph;
class TGraphAsymmErrors;


namespace sidApi {
   namespace offline {
      class KpixThreshRead {

            // Flag to delete runRead
            bool delRunRead;

         public:

            // Run Read Class
            KpixRunRead *kpixRunRead;

            // Calib Data Class Constructor
            // Pass path to calibration data or
            KpixThreshRead ( std::string threshFile, bool debug = false );

            // Calib Data Class Constructor
            // Pass already open run read class
            KpixThreshRead ( KpixRunRead *kpixRunRead );

            // Calib Data Class DeConstructor
            ~KpixThreshRead ( );

            // Function to create plot name
            static std::string genPlotName ( std::string prefix, int gain, int kpix, int channel, int cal=-1 );

            // Function to create plot title
            static std::string genPlotTitle ( std::string prefix, int gain, int kpix, int channel, int cal=-1 );

            // Get Threshold Scan Histogram
            TH2F *getThreshScan ( std::string dir, int gain, int kpix, int channel, int cal );

            // Get Threshold Curve
            TGraphAsymmErrors *getThreshCurve ( std::string dir, int gain, int kpix, int channel);

            // Get Threshold Cal
            TGraphAsymmErrors *getThreshCal ( std::string dir, int gain, int kpix, int channel, int cal);

            // Get Threshold Gain
            TGraph *getThreshGain ( std::string dir, int gain, int kpix, int channel);

            // Get Threshold Data
            bool getThreshData (double *meanVal, double *sigmaVal, double *gainVal, std::string dir,int gain,int serNum,int channel);

            // Get Calibration Sigma Value
            bool getCalSigma (double *sigmaVal,std::string dir,int gain,int serNum,int channel, int cal);

      };
   }
}

#endif
