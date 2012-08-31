//-----------------------------------------------------------------------------
// File          : readExample.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : Kpix DAQ
//-----------------------------------------------------------------------------
// Description :
// Read data example
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//----------------------------------------------------------------------------
#include <KpixEvent.h>
#include <KpixSample.h>
#include <KpixCalibRead.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <Data.h>
#include <DataRead.h>
using namespace std;

int main (int argc, char **argv) {
   DataRead      dataRead;
   KpixEvent     event;
   KpixSample    *sample;
   uint          x;
   uint          count;
   stringstream  tmp;
   uint          hits[1024];

   // Check args
   if ( argc < 2 ) {
      cout << "Usage: hitMap datafile.bin" << endl;
      return(1);
   }

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening file " << argv[1] << endl;
      return(2);
   }

   for (x=0; x < 1024; x++) hits[x] = 0;

   // Process each event
   count = 0;
   while ( dataRead.next(&event) ) {

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         // Do something if this is a data sample
         if ( sample->getSampleType() == KpixSample::Data ) {

            if ( sample->getKpixBucket() ) hits[sample->getKpixChannel()]++;
         }
      }
   }

   for (x=0; x < 1024; x++) 
      cout << "Channel " << setw(4) << setfill(' ') << x << " = " << hits[x] << endl;

   return(0);
}

