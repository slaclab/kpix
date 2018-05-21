//-----------------------------------------------------------------------------
// File          : KpixSample.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 11/13/2006: Added debug for sample creation
// 12/01/2006: Added 32-bit sample ID for linking
// 12/19/2006: Added support for run variables, added root support
// 03/19/2007: Changed variable types to root specific values. 
//             Changed name to KpixSample.
// 04/29/2007: Train number now passed during creation
// 04/30/2007: Modified to throw strings instead of const char *
// 02/27/2008: Added ability to store/read empty & bad count flags.
// 04/27/2009: Added trigger type flag.
// 05/13/2009: Added special flag.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include "KpixSample.h"
using namespace std;

ClassImp(KpixSample)


// Event class constructor
KpixSample::KpixSample ( ) {

   // Set values
   trainNum    = 0;
   kpixAddress = 0;
   kpixChannel = 0;
   kpixBucket  = 0;
   sampleRange = 0;
   sampleTime  = 0;
   sampleValue = 0;
   varCount    = 0;
   varValue    = NULL;
}


// Event class constructor
// Pass the following values for construction
// address      = KPIX Address
// channel      = KPIX Channel
// bucket       = KPIX Bucket
// range        = Range Flag
// time         = Timestamp
// value        = Value
// train        = Train Number
// empty        = Sample is empty
// badCount     = Channel counter was bad
// trigType     = 0=Local, 1=Neighbor
// special      = 0=Normal Data, 1=Special Data Type
KpixSample::KpixSample ( Int_t address, Int_t channel, Int_t bucket, Int_t range, 
                         Int_t time, Int_t value, Int_t train, Int_t empty, 
                         Int_t badCount, Int_t trigType, Int_t special, bool debug ) {

   // Set values
   trainNum     = train;
   kpixAddress  = address;
   kpixChannel  = channel;
   kpixBucket   = bucket;
   sampleRange  = (range & 0x1) | 
                  ((empty << 1) & 0x2) | 
                  ((badCount << 2) & 0x4) | 
                  ((trigType << 3) & 0x8) |
                  ((special  << 4) & 0x10);
   sampleTime   = time;
   sampleValue  = value;
   varCount     = 0;
   varValue     = NULL;

   if ( debug ) {
      cout << "KpixSample::KpixSample -> Created new sample: ";
      cout << "Address=0x" << setw(4) << setfill('0') << hex << address;
      cout << ", Channel=0x" << setw(3) << setfill('0') << hex << channel;
      cout << ", Bucket=" << bucket;
      cout << ", Range=" << range;
      cout << ", Time=0x" << setw(4) << setfill('0') << hex << time;
      cout << ", Value=0x" << setw(4) << setfill('0') << hex << value;
      cout << ", Train=0x" << setw(8) << setfill('0') << hex << train;
      cout << ", Empty=" << empty;
      cout << ", BadCount=" << badCount;
      cout << ", TrigType=" << trigType;
      cout << ", Special=" << special;
      cout << "\n";
   }
}


// Pass number of values to store and an array containing
// a list of those variables. The passed array pointer value
// should be persistant for the live of this sample object.
void KpixSample::setVariables ( Int_t count, Double_t *values ) {

   // Store variables count and values
   varCount = count;
   varValue = values;
}

// Get train number
Int_t KpixSample::getTrainNum() { return(trainNum); }

// Get KPIX address
Int_t KpixSample::getKpixAddress() { return(kpixAddress); }

// Get KPIX channel
Int_t KpixSample::getKpixChannel() { return(kpixChannel & 0x3FF); }

// Get KPIX bucket
Int_t KpixSample::getKpixBucket() { return(kpixBucket & 0x3); }

// Get sample range
Int_t KpixSample::getSampleRange() { return(sampleRange & 0x1); }

// Get sample time
Int_t KpixSample::getSampleTime() { return(sampleTime & 0x1FFF); }

// Get sample value
Int_t KpixSample::getSampleValue() { return(sampleValue & 0x1FFF); }

// Get variable count
Int_t KpixSample::getVarCount() { return(varCount); }

// Get variable value
Double_t KpixSample::getVarValue(Int_t var) {

   if ( var > varCount ) throw(string("KpixSample::getVarValue -> Var index out of range."));
   return(varValue[var]);
}

// Get empty flag
Int_t KpixSample::getEmpty() { return(((sampleRange >> 1) & 0x1)); }

// Get badCount flag
Int_t KpixSample::getBadCount() { return(((sampleRange >> 2) & 0x1)); }

// Get trigger type flag
Int_t KpixSample::getTrigType() { return(((sampleRange >> 3) & 0x1)); }

// Get special flag
Int_t KpixSample::getSpecial() { return(((sampleRange >> 4) & 0x1)); }

// Deconstructor
KpixSample::~KpixSample () {}

