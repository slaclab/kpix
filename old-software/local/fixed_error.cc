//-----------------------------------------------------------------------------
// File          : fixed_error.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/03/2011
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// File to check for static values.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/03/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <KpixCalibRead.h>
#include <KpixRunRead.h>
#include <KpixSample.h>
#include <TApplication.h>
#include <TFile.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TMultiGraph.h>
#include <TGraph.h>
#include <TStyle.h>
#include <stdarg.h>
using namespace std;


class HistData {
   public:
      uint last;
      uint count;
      uint channel;
      uint train;
      uint lrange;

      HistData (uint chan) {
         last    = 0;
         count   = 0;
         train   = 0;
         lrange  = 0;
         channel = chan;
      }

      void add (uint tr, uint value, uint range) {
         if ( value == last ) {
            count++;
            if ( range == 1 ) lrange++;
         }
         else {
            if ( count > 10 || lrange > 10 ) {
               cout << "Channel " << dec << channel;
               cout << " Low Range " << dec << lrange;
               cout << " Value " << dec << last;
               cout << " First " << dec << train;
               cout << " Last " << dec << tr;
               cout << " Count " << dec << count << endl;
            }
            last   = value;
            count  = 0;
            lrange = 0;
            train  = tr;
         }
      }
};


// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {

   KpixRunRead     *runRead;
   HistData        *histData[1023];
   uint            channel;
   uint            count;
   uint            value;
   uint            train;
   uint            range;
   uint            x;
   KpixSample      *sample;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   //TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: fixed_error file.root\n";
      return(1);
   }

   // Open run file
   try {
      runRead  = new KpixRunRead(argv[1],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }

   // Create records
   for (channel=0; channel < 1024; channel++) histData[channel] = new HistData(channel);

   // Go through each sample
   count = runRead->getSampleCount();
   for ( x=0; x < count; x++ ) {
      sample  = runRead->getSample(x);
      channel = sample->getKpixChannel();
      value   = sample->getSampleValue();
      range   = sample->getSampleRange();
      train   = sample->getTrainNum();
      if ( channel > 1023 ) cout << "Error: channel = " << dec << channel << endl;
      else histData[channel]->add(train,value,range);
      if ( (x % 10000) == 0 ) {
         cerr << "\rRead " << dec << x << " out of " << dec << count;
         cerr << " " << ((x * 100) / count) << "%" << flush;
      }
   }
   cerr << endl;

   // finalize and delete records
   for (channel=0; channel < 1024; channel++) {
      histData[channel]->add(train,0,0);
      delete histData[channel];
   }

   // Start X-Windows
   //theApp.Run();

   // Delete
   delete(runRead);
}
