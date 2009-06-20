//-----------------------------------------------------------------------------
// File          : KpixCalDist.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/07/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to perform calibrations and distributions
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/06/2007: created
// 03/19/2007: Added Sample variables to store calibration charge in Coulombs.
// 05/01/2007: Added support for multiple KPIX devices
// 02/29/2008: Added ability to create histograms and calibration plots on the fly
// 05/19/2008: Created seperate calibration ranges for the three gains. 
//             Full configured range is always fit.
// 09/26/2008: Added support for progress updates to calling class.
// 10/13/2008: Removed fitting functions. Seperate plot & raw data enable from
//             canvas and plot directory setting.
// 03/05/2009: Added ability to rate limit calibration and dist generation
// 05/11/2009: Added range checking on serial number lookup.
// 05/15/2009: Added feature to support random histogram time generation.
//-----------------------------------------------------------------------------
#ifndef __KPIX_CAL_DIST_H__
#define __KPIX_CAL_DIST_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <Rtypes.h>
#include <TGraph.h>
#include <TH2F.h>
#include "KpixProgress.h"
#include "KpixBunchTrain.h"
#include "../offline/KpixSample.h"
#include "../offline/KpixAsic.h"
#include "KpixRunWrite.h"
using namespace std;


// Class to store calibration plots
class KpixCalDistData {
   public:
      unsigned int count;
      double       xData[256];   
      double       vData[256];   
      double       tData[256];   
      KpixCalDistData() { count = 0; }
};


// KPIX Event Data Class
class KpixCalDist {

      // Locations to store asic and run objects to use
      KpixAsic     *tempAsic;
      KpixAsic     **kpixAsic;
      KpixRunWrite *kpixRunWrite;

      // Numer of Kpix devices
      unsigned int kpixCount;

      // Enable debug
      bool enDebug;

      // Enables for each gain range
      bool enNormal;
      bool enDouble;
      bool enLow;

      // Raw data and plot enables
      bool rawDataEn;
      bool plotEn;

      // Range for calibration
      unsigned char calStart;
      unsigned char calEnd;
      unsigned char calStep;

      // Distribution counts and charge
      unsigned int  distCount;
      unsigned char distCalDac;

      // Lookup Table For Kpix Index
      unsigned int *kpixIdxLookup;
      unsigned int maxAddress;

      // Rate Limit In uS
      unsigned int rateLimit;

      // Enable and range for random histogram time generation
      static const unsigned int distTimeMin = 100; // Buckets from 0
      static const unsigned int distTimeMax = 100; // Buckets from max
      bool randDistTimeEn;

      // Plot information
      string plotDir;

      // Progress class for reporting status
      KpixProgress *kpixProgress;

   public:

      // Constructor for single KPIX. 
      // Pass a pointer to the Kpix Asic and the Run object
      KpixCalDist ( KpixAsic *asic, KpixRunWrite *run );

      // Constructor for multiple KPIX devices. 
      // Pass a pointer to the Kpix Asic and the Run object
      KpixCalDist ( KpixAsic **asic, unsigned int count, KpixRunWrite *run );

      // Set calibration DAC value for distribution
      void setDistCalDac ( unsigned char value );

      // Set number of distribution iterations
      void setDistCount ( unsigned int count );

      // Set calibration DAC steps for calibration run
      void setCalibRange ( unsigned char start, unsigned char end, unsigned char step );

      // Enable/Disable normal gain iteration
      void enNormalGain ( bool enable );

      // Enable/Disable double gain iteration
      void enDoubleGain ( bool enable );

      // Enable/Disable low gain iteration
      void enLowGain ( bool enable );

      // Turn on or off debugging for the class
      void calDistDebug ( bool debug );

      // Enable raw data
      void enableRawData( bool enable );

      // Enable plot generation
      void enablePlots( bool enable );

      // Pass name of the TFile directory in which to store the plots
      void setPlotDir( string plotDir );

      // Set Rate Limit
      void setRateLimit( unsigned int rateLimit );

      // Enable random histogram time
      void enableRandDistTime ( bool enable );

      // Execute distribution, pass channel to enable calibration mask for
      // Or pass -1 to set cal mask for all channels or -2 to set mask for no channels
      void runDistribution ( short channel );

      // Execute calibration, pass channel to enable calibration mask for
      // Or pass -1 to set cal mask for all channels or -2 to set mask for no channels
      void runCalibration ( short channel );

      // Deconstructor
      virtual ~KpixCalDist ();

      // Set progress Callback
      void setKpixProgress(KpixProgress *progress);

};

#endif
