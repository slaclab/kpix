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

//! Class used to parse and read calibration run data.
class KpixCalibRead {

      // Class for channel data
      class KpixCalibData {
         public:

            // values
            double baseMean;
            double baseRms;
            double baseFitMean;
            double baseFitSigma;
            double baseFitMeanErr;
            double baseFitSigmaErr;
            double calibGain;
            double calibIntercept;
            double calibGainErr;
            double calibInterceptErr;

            // Init
            KpixCalibData () {
               baseMean          = 0;
               baseRms           = 0;
               baseFitMean       = 0;
               baseFitSigma      = 0;
               baseFitMeanErr    = 0;
               baseFitSigmaErr   = 0;
               calibGain         = 0;
               calibIntercept    = 0;
               calibGainErr      = 0;
               calibInterceptErr = 0;
            }
      };

      // Structure for ASIC
      class KpixCalibAsic {
         public:

            KpixCalibData *data[1024][4];

            KpixCalibAsic () {
               for (uint x=0; x < 1024; x++) 
                  for (uint y=0; y < 4; y++) 
                     data[x][y] = new KpixCalibData;
            }
      
            ~KpixCalibAsic () {
               for (uint x=0; x < 1024; x++) 
                  for (uint y=0; y < 4; y++) 
                     delete data[x][y];
            }
      };

      // Vector of KPIXs
      map<string,KpixCalibAsic *> asicList_;

      // Parse XML level
      void parseXmlLevel ( xmlNode *node, string kpix, uint channel, uint bucket );

      // Return pointer to ASIC, optional creation
      KpixCalibData *findKpix ( string kpix, uint channel, uint bucket, bool create );
      
   public:

      //! Calib Data Class Constructor
      KpixCalibRead ( );

      //! Parse XML file
      bool parse ( string calibFile );

      //! Get baseline mean value
      double baseMean ( string kpix, uint channel, uint bucket );

      //! Get baseline rms value
      double baseRms ( string kpix, uint channel, uint bucket );

      //! Get baseline guassian fit mean
      double baseFitMean ( string kpix, uint channel, uint bucket );

      //! Get baseline guassian fit sigma
      double baseFitSigma ( string kpix, uint channel, uint bucket );

      //! Get baseline guassian fit mean error
      double baseFitMeanErr ( string kpix, uint channel, uint bucket );

      //! Get baseline guassian fit sigma error
      double baseFitSigmaErr ( string kpix, uint channel, uint bucket );

      //! Get calibration gain
      double calibGain ( string kpix, uint channel, uint bucket );

      //! Get calibration intercept
      double calibIntercept ( string kpix, uint channel, uint bucket );

      //! Get calibration gain error
      double calibGainErr ( string kpix, uint channel, uint bucket );

      //! Get calibration intercept error
      double calibInterceptErr ( string kpix, uint channel, uint bucket );
};

#endif
