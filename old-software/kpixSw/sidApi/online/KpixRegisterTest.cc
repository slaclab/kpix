//-----------------------------------------------------------------------------
// File          : KpixRegisterTest.cc
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
// 05/04/2007: Fixed error in debug message.
// 07/31/2007: Fixed error in register test direction.
// 09/26/2008: Added support for progress updates to calling class.
// 02/23/2009: Added changes required for status read.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
// 04/23/2010: Forced dc mode for KPIX 9 register test.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include "KpixRegisterTest.h"
#include "KpixProgress.h"
#include "../offline/KpixAsic.h"
using namespace std;


// Register test class constructor
// Pass the following values for construction
// asic    = KPIX ASIC Object
KpixRegisterTest::KpixRegisterTest ( KpixAsic *asic ) {

   // Kpix Object
   kpixAsic     = asic;
   endOnError   = true;
   showProgress = false;
   direction    = false;
   iterations   = 100;
   readCount    = 2;
   readErrors   = 0;
   statusErrors = 0;
   enDebug      = false;
   kpixProgress = NULL;
}


// Deconstructor.
KpixRegisterTest::~KpixRegisterTest () {}

// Set end on error flag, default = true
void KpixRegisterTest::setEndOnError(bool flag) { endOnError = flag; }

// Set iterations to run, default = 100
void KpixRegisterTest::setIterations (unsigned int iterations) { this->iterations = iterations; }

// Set reads to perform in each iteration, default = 2
void KpixRegisterTest::setReadCount (unsigned int readCount) { this->readCount = readCount; }

// Turn on progress display
void KpixRegisterTest::setShowProgress ( bool flag ) { this->showProgress = flag; }

// Set direction of test
void KpixRegisterTest::setDirection ( bool flag ) { this->direction = flag; }

// Run the register test
// Return true on success, false on fail
bool KpixRegisterTest::runTest () {

   unsigned int  i,x,y,z;
   unsigned int  temp;
   bool          hperr, dperr, tempEn;
   unsigned char tempVal;


   // Init error counters
   readErrors   = 0;
   statusErrors = 0;

   // Log start of test
   if ( showProgress ) cout << "Register Test Starting.\n";

   // Force dc mode for KPIX 9
   if (kpixAsic->getVersion() == 9 ) {
      cout << "KpixRegisterTest::runTest -> Forcing power cycle to be disabled for KPIX 9" << endl;
      kpixAsic->setCntrlDisPwrCycle ( true, true );
   }

   // Loop through iterations
   for (i=0; i < iterations; i++) {

      // Debug
      if ( enDebug ) cout << "KpixRegisterTest::runTest -> Write Iteration " << i << "\n";

      // Write iteration
      for (z=0; z < 0x7F; z++) {

         // Determine direction
         if ( direction ) x = 0x7F - z;
         else x = z;

         // Register exists
         if ( kpixAsic->regGetWriteable(x) ) {

            // Kpix 9, force disable power cycle to be set
            if ( kpixAsic->getVersion() == 9 && x == 0x30 ) kpixAsic->regSetValue(x,rand()|0x01000000,true,false);
            else kpixAsic->regSetValue(x,rand(),true,false);

            if ( enDebug ) cout << "KpixRegisterTest::runTest -> Writing Register 0x" 
               << setw(2) << setfill('0') << hex << x << ". Value 0x"
               << setw(8) << setfill('0') << hex << kpixAsic->regGetValue(x,false)
               << "\n";
         }
      }

      // Read status register
      kpixAsic->getStatus(&hperr,&dperr,&tempEn,&tempVal);

      // Detect error in write
      if ( hperr || dperr ) {
         if ( enDebug ) {
            cout << "KpixRegisterTest::runTest -> Detected parity error. dperr=" << dperr;
            cout << ", hperr=" << hperr << "\n";
         }
         statusErrors++;
         if ( endOnError ) {
            if ( showProgress ) {
               cout << "Register Test Done. readErrors=" << dec << readErrors;
               cout << ". statusErrors=" << dec << statusErrors << ".\n";
            }
            return(false);
         }
      }

      // Read iterations
      for (x=0; x < readCount; x++) {

         // Debug
         if ( enDebug ) 
            cout << "KpixRegisterTest::runTest -> Read Iteration " << i << "-" << x << "\n";

         // Each channel
         for (z=0; z < 0x7F; z++) {

            // Determine direction
            if ( direction ) y = 0x7F - z;
            else y = z;

            // Register exists
            if ( kpixAsic->regGetWriteable(y) ) {

               // Store expected value
               temp = kpixAsic->regGetValue(y,false);

               // Verbose
               if ( enDebug ) cout << "KpixRegisterTest::runTest -> Reading Register 0x" 
                  << setw(2) << setfill('0') << hex << y << ". Value 0x"
                  << setw(8) << setfill('0') << hex << kpixAsic->regGetValue(y,false)
                  << "\n";

               // Detect error
               if ( kpixAsic->regGetValue(y,true) != temp ) {
                  readErrors++;

                  // Display error
                  if ( enDebug ) {
                     cout << "KpixRegisterTest::runTest -> Read Mismatch. Expected Value 0x" ;
                     cout << setw(8) << setfill('0') << hex << temp;
                     cout << " Got Value 0x" << setw(8) << setfill('0') << hex << kpixAsic->regGetValue(y,false);
                     cout << " --------------------------- \n";
                  }

                  // Set expected value back 
                  kpixAsic->regSetValue(y,temp,false,false);

                  // End on error is set
                  if ( endOnError ) {
                     if ( showProgress ) {
                        cout << "Register Test Done. readErrors=" << dec << readErrors;
                        cout << ". statusErrors=" << dec << statusErrors << ".\n";
                     }
                     return(false);
                  }
               }
            }
         }
      }

      // Show progress
      if ( showProgress ) {
         cout << "Register Test Iteration " << dec << i << " Complete. readErrors=";
         cout << dec << readErrors;
         cout << ". statusErrors=" << dec << statusErrors << ".\n";
      }
 
      // Update Progress
      if ( kpixProgress != NULL ) kpixProgress->updateProgress(i+1,iterations);
   }
   if ( showProgress ) {
      cout << "Register Test Done. readErrors=" << dec << readErrors;
      cout << ". statusErrors=" << dec << statusErrors << ".\n";
   }
   if ( readErrors > 0 || statusErrors > 0 ) return(false);
   return(true);
}


// Return the number of read-mismatches found
unsigned int KpixRegisterTest::getReadErrors() { return(readErrors); }

// Return the number of status errors detected
unsigned int KpixRegisterTest::getStatusErrors() { return(statusErrors); }

// Enable/disable debug
void KpixRegisterTest::setDebug ( bool debug ) { this->enDebug = debug; }


// Set progress Callback
void KpixRegisterTest::setKpixProgress(KpixProgress *progress) {
   this->kpixProgress = progress;
}
