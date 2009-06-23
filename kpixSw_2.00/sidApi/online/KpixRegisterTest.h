//-----------------------------------------------------------------------------
// File          : KpixRegisterTest.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/19/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to perform a basic register test of the KPIX ASIC.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/19/2006: created
// 09/26/2008: Added support for progress updates to calling class.
// 06/22/2009: Added namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_REGISTER_TEST_H__
#define __KPIX_REGISTER_TEST_H__


// Forward declarations
namespace sidApi {
   namespace online {
      class KpixProgress;
   }
   namespace offline {
      class KpixAsic;
   }
}


namespace sidApi {
   namespace online {
      class KpixRegisterTest {

            // Kpix Object
            sidApi::offline::KpixAsic *kpixAsic;

            // Configuration
            bool endOnError;
            bool showProgress;
            bool direction;
            unsigned int iterations;
            unsigned int readCount;

            // Error counters
            unsigned int readErrors;
            unsigned int statusErrors;

            // Progress class for reporting status
            sidApi::online::KpixProgress *kpixProgress;

            // Debug enable
            bool enDebug;

         public:

            // Register test class constructor
            // Pass the following values for construction
            // asic    = KPIX ASIC Object
            KpixRegisterTest ( sidApi::offline::KpixAsic *asic );

            // Deconstructor.
            virtual ~KpixRegisterTest ();

            // Set end on error flag, default = true
            // Controls if the test should end when an error occurs or just
            // count the error and keep on running.
            void setEndOnError(bool flag);

            // Set iterations to run, default = 100
            void setIterations (unsigned int iterations);

            // Set reads to perform in each iteration, default = 2
            void setReadCount (unsigned int readCount);

            // Turn on progress display, default = false
            void setShowProgress ( bool flag );

            // Set direction of test
            // Controls the order of register read and writes
            void setDirection ( bool flag );

            // Run the register test
            // Return true on success, false on fail
            bool runTest ();

            // Return the number of read-mismatches found
            unsigned int getReadErrors();

            // Return the number of status errors detected
            unsigned int getStatusErrors();

            // Enable/disable debug
            void setDebug ( bool debug );

            // Set progress Callback
            void setKpixProgress(sidApi::online::KpixProgress *progress);

      };
   }
}
#endif
