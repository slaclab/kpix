//-----------------------------------------------------------------------------
// File          : KpixCalibRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 05/31/2012
// Project       : KPIX Control Software
//-----------------------------------------------------------------------------
// Description :
// This class is used to extract calibration constants from an XML file.
//-----------------------------------------------------------------------------
// Copyright (c) 2012 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 05/31/2012: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_CALIB_READ_H__
#define __KPIX_CALIB_READ_H__

#include <string>
#include <map>
#include <sys/types.h>
#include <libxml/tree.h>
using namespace std;

#ifdef __CINT__
#define uint unsigned int
#endif

class KpixCalibReadStruct;

typedef map<string,KpixCalibReadStruct *> AsicMap;

// Structure for ASICs
class KpixCalibReadStruct {

   public:

      // Baseline values
      double baseMean        [1024][4];
      double baseRms         [1024][4];
      double baseFitMean     [1024][4];
      double baseFitSigma    [1024][4];
      double baseFitMeanErr  [1024][4];
      double baseFitSigmaErr [1024][4];

      // Calibration values
      double calibGain         [1024][4];
      double calibIntercept    [1024][4];
      double calibGainErr      [1024][4];
      double calibInterceptErr [1024][4];

      // Init
      KpixCalibReadStruct () {
         uint x;
         uint y;

         for (x=0; x < 1024; x++) {
            for (y=0; y < 4; y++) {
               baseMean          [x][y] = 0;
               baseRms           [x][y] = 0;
               baseFitMean       [x][y] = 0;
               baseFitSigma      [x][y] = 0;
               baseFitMeanErr    [x][y] = 0;
               baseFitSigmaErr   [x][y] = 0;
               calibGain         [x][y] = 0;
               calibIntercept    [x][y] = 0;
               calibGainErr      [x][y] = 0;
               calibInterceptErr [x][y] = 0;
            }
         }
      }
};

//! Class used to parse and read calibration run data.
class KpixCalibRead {

      // Vector of KPIXs
      AsicMap asicList_;

      // Parse XML level
      void parseXmlLevel ( xmlNode *node, string kpix, uint channel, uint bucket );

      // Return pointer to ASIC, optional creation
      KpixCalibReadStruct *findKpix ( string kpix, bool create );
      
   public:

      //! Calib Data Class Constructor
      /*! Pass path to calibration data
      */
      KpixCalibRead ( std::string calibFile );

      //! Get Calibration Graph Fit Results
      bool getCalibData ( string kpix, uint channel, uint bucket,
                          double *calibGain, double *calibIntercept,
                          double *calibGainErr=NULL, double *calibInterceptErr=NULL );

      //! Get Baseline Fit Results
      bool getHistData ( string kpix, uint channel, uint bucket,
                         double *mean, double *rms, 
                         double *fitMean=NULL, double *fitSigma=NULL,
                         double *fitMeanErr=NULL, double *fitSigmaErr=NULL);

};
#endif
