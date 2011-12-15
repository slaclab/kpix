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
#include <iomanip>
#include <fstream>
#include <iostream>
#include <Data.h>
#include <DataRead.h>
using namespace std;

int main (int argc, char **argv) {
   DataRead   dataRead;
   KpixEvent  event;
   KpixSample *sample;
   uint       x;

   // Check args
   if ( argc != 2 ) {
      cout << "Usage: readExample filename" << endl;
      return(1);
   }

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) return(2);

   // Process each event
   while ( dataRead.next(&event) ) {

      // Dump header values
      cout << "Header:trainNumber = " << dec << event.trainNumber() << endl;
      cout << "Header:count       = " << dec << event.count() << endl;

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         // Show sample data
         cout << "Sample:index       = " << dec << x << endl;
         cout << "Sample:address     = " << dec << sample->getKpixAddress() << endl;
         cout << "Sample:channel     = " << dec << sample->getKpixChannel() << endl;
         cout << "Sample:bucket      = " << dec << sample->getKpixBucket()  << endl;
         cout << "Sample:time        = " << dec << sample->getSampleTime()  << endl;
         cout << "Sample:value       = " << dec << sample->getSampleValue() << endl;
         cout << "Sample:range       = " << dec << sample->getSampleRange() << endl;
         cout << "Sample:trigType    = " << dec << sample->getTrigType()    << endl;
      }

   }

   // Dump config
   dataRead.dumpConfig();
   dataRead.dumpStatus();

   return(0);
}

