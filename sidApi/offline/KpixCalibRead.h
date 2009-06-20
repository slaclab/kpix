//-----------------------------------------------------------------------------
// File          : KpixCalibRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/30/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// This class is used to extract calibration constants from the root
// file generated by the calib_dist_plot.cc software. 
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/30/2006: created
// 10/25/2008: Added method to copy calibration data to a new root file.
// 12/12/2008: Added RMS value extraction from histogram.
// 04/29/2009: Histograms copied along with calibration data.
//             Parameter errors now read as well.
// 06/18/2009: Added namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_CALIB_READ_H__
#define __KPIX_CALIB_READ_H__

#include <string>
using namespace std;


// Forward Declarations
namespace sidApi {
   namespace offline {
      class KpixRunRead;
      class KpixAsic;
   }
}
class TFile;
class TGraph;
class TH1;
class TH1F;


namespace sidApi {
   namespace offline {
      class KpixCalibRead {

            // Flag to delete runRead
            bool delRunRead;

         public:

            // Run Read Class
            KpixRunRead *kpixRunRead;

            // Calib Data Class Constructor
            // Pass path to calibration data or
            KpixCalibRead ( string calibFile, bool debug = false );

            // Calib Data Class Constructor
            // Pass already open run read class
            KpixCalibRead ( KpixRunRead *kpixRunRead );

            // Calib Data Class DeConstructor
            ~KpixCalibRead ( );

            // Function to create plot name
            static string genPlotName ( int gain, int kpix, int channel, int bucket, string prefix, int range=-1 );

            // Function to create plot title
            static string genPlotTitle ( int gain, int kpix, int channel, int bucket, string prefix, int range=-1 );

            // Get and make copy of Value Histogam
            TH1F *getHistValue ( string dir, int gain, int kpix, int channel, int bucket );

            // Get and make copy of Time Histogam
            TH1F *getHistTime ( string dir, int gain, int kpix, int channel, int bucket );

            // Get and make copy of Value Graph
            TGraph *getGraphValue ( string dir, int gain, int kpix, int channel, int bucket, int range=-1 );

            // Get and make copy of Time Graph
            TGraph *getGraphTime ( string dir, int gain, int kpix, int channel, int bucket, int range=-1 );

            // Get and make copy of Time Graph
            TGraph *getGraphResid ( string dir, int gain, int kpix, int channel, int bucket, int range=-1 );

            // Get and make copy of Filtered Graph
            TGraph *getGraphFilt ( string dir, int gain, int kpix, int channel, int bucket, int range=-1 );

            // Get Calibration Graph Fit Results If They Exist
            bool getCalibData ( double *fitGain, double *fitIntercept, 
                                string dir, int gain, int kpix, int channel, int bucket,
                                double *fitGainErr=NULL, double *fitInterceptErr=NULL );

            // Get Calibration Graph Fit RMS Value
            bool getCalibRms  ( double *rms, 
                                string dir, int gain, int kpix, int channel, int bucket);

            // Get Histogram Graph Fit Results If They Exist
            bool getHistData ( double *mean, double *sigma, double *rms,
                               string dir, int gain, int kpix, int channel, int bucket,
                               double *meanErr=NULL, double *sigmaErr=NULL);

            // Copy calibration data to a new root file
            void copyCalibData ( TFile *newFile, string directory, KpixAsic **asic, int asicCnt );
      };
   }
}
#endif
