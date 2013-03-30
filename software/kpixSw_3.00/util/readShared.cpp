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
   double        mean;
   double        gain;
   double        charge;
   uint          count;
   stringstream  tmp;
   string        serialList[32];
   string        serial;
   time_t        curr, last;

   // Check args
   if ( argc != 1 ) {
      cout << "Usage: readShared" << endl;
      return(1);
   }

   dataRead.openShared("kpix",1);

   // Process each event
   time(&curr);
   last = curr;
   count = 0;
   while (1) {

      time(&curr);
      if ( last != curr ) {
         cout << "Got " << dec << count << " events" << endl;
         last = curr;
      }

      if ( dataRead.next(&event) ) {

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
         if ( dataRead.sawRunTime()  ) dataRead.dumpRunTime();

#if 0

         // Dump header values
         cout << "Header:eventNumber = " << dec << event.eventNumber() << endl;
         cout << "Header:timeStamp   = " << dec << event.timestamp() << endl;
         cout << "Header:count       = " << dec << event.count() << endl;
         cout << endl;

#endif
#if 0

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

               // Get a config variable associated with event
               cout << "Sample:CalDac      = " << dataRead.getConfigInt("conFpga:kpixAsic:DacCalibration") << endl;
               cout << "Sample:CalState    = " << dataRead.getStatus("CalState") << endl;
            }
            cout << endl;
         }

#endif

         count++;
      }
      else usleep(100);
   }

   return(0);
}

