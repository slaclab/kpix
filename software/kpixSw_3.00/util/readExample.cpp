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
   KpixCalibRead calibRead;
   uint          x;
   double        mean;
   double        gain;
   double        charge;
   uint          count;
   stringstream  tmp;
   string        serialList[32];
   string        serial;

   // Check args
   if ( argc < 2 || argc > 3 ) {
      cout << "Usage: readExample datafile.bin [calibFile.xml]" << endl;
      return(1);
   }

   // Attempt to open calibration file
   if ( argc == 3 && calibRead.parse(argv[2]) ) 
      cout << "Read calibration data from " << argv[2] << endl << endl;

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening file " << argv[1] << endl;
      return(2);
   }

   // Process each event
   count = 0;
   while ( dataRead.next(&event) ) {

      // Extract kpix serial numbers after reading first event
      if ( count == 0 ) {
         for (x=0; x < 32; x++) {
            tmp.str("");
            tmp << "cntrlFpga(0):kpixAsic(" << dec << x << "):SerialNumber";
            serialList[x] = dataRead.getConfig(tmp.str());
         }
      }

      if ( dataRead.sawRunStop()  ) dataRead.dumpRunStop();
      if ( dataRead.sawRunStart() ) dataRead.dumpRunStart();

      // Dump header values
      cout << "Header:eventNumber = " << dec << event.eventNumber() << endl;
      cout << "Header:timeStamp   = " << dec << event.timestamp() << endl;
      cout << endl;

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         // Get serial number
         if ( sample->getKpixAddress() < 32 ) serial = serialList[sample->getKpixAddress()];
         else serial = "";

         // Show sample data
         cout << "Sample:index       = " << dec << x << endl;
         cout << "Sample:eventNumber = " << dec << sample->getEventNum()    << endl;
         cout << "Sample:address     = " << dec << sample->getKpixAddress() << endl;
         cout << "Sample:serial      = " << dec << serial                   << endl;
         cout << "Sample:channel     = " << dec << sample->getKpixChannel() << endl;
         cout << "Sample:bucket      = " << dec << sample->getKpixBucket()  << endl;
         cout << "Sample:time        = " << dec << sample->getSampleTime()  << endl;
         cout << "Sample:value       = " << dec << sample->getSampleValue() << endl;
         cout << "Sample:range       = " << dec << sample->getSampleRange() << endl;
         cout << "Sample:trigType    = " << dec << sample->getTrigType()    << endl;
         cout << "Sample:empty       = " << dec << sample->getEmpty()       << endl;
         cout << "Sample:badCount    = " << dec << sample->getBadCount()    << endl;
         cout << "Sample:sampleType  = " << dec << sample->getSampleType()  << endl;

         // Do something if this is a data sample
         if ( sample->getSampleType() == KpixSample::Data ) {

            // Get gain and mean for channel/bucket
            mean = calibRead.baseMean(serial,sample->getKpixChannel(),
                                             sample->getKpixBucket(),
                                             sample->getSampleRange());
            gain = calibRead.calibGain(serial,sample->getKpixChannel(),
                                              sample->getKpixBucket(),
                                              sample->getSampleRange());

            // compute charge value from calibration
            if ( gain != 0 ) {
               charge = ((double)sample->getSampleValue() - mean) / gain;
               cout << "Sample:mean        = " << mean   << endl;
               cout << "Sample:gain        = " << gain   << endl;
               cout << "Sample:charge      = " << charge << endl;
            }

            // Get a config variable associated with event
            cout << "Sample:CalDac      = " << dataRead.getConfigInt("conFpga:kpixAsic:DacCalibration") << endl;
         }
         cout << endl;
      }
   }

   // Dump config
   dataRead.dumpConfig();
   dataRead.dumpStatus();

   return(0);
}

