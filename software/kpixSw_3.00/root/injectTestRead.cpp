//-----------------------------------------------------------------------------
// File          : calibrationFitter.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 05/30/2012
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// Application to process and fit kpix calibration data
//-----------------------------------------------------------------------------
// Copyright (c) 2012 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 05/30/2012: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <TFile.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TMultiGraph.h>
#include <TApplication.h>
#include <TGraphErrors.h>
#include <TGraph.h>
#include <TStyle.h>
#include <stdarg.h>
#include <KpixEvent.h>
#include <KpixSample.h>
#include <Data.h>
#include <DataRead.h>
#include <math.h>
#include <fstream>
#include <XmlVariables.h>
using namespace std;

// Process the data
int main ( int argc, char **argv ) {
   DataRead               dataRead;
   KpixEvent              event;
   KpixSample             *sample;
   uint                   calChannel;
   uint                   currPct;
   uint                   lastPct;
   uint                   eventCount;
   uint                   x;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   uint                   value;
   uint                   type;
   uint                   tstamp;
   uint                   range;
   size_t                 filePos;
   size_t                 fileSize;
   TH1F                 * histA[9];
   TH1F                 * histB[9];
   TCanvas              * c1;
   TCanvas              * c2;
   uint                   minVal[9];
   uint                   maxVal[9];
   stringstream           tmp;

   TApplication theApp("App",NULL,NULL);
   gStyle->SetOptFit(1111);
   gStyle->SetOptStat(111111111);

   // Data file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: injectTestRead data_file\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[2] << endl;
      return(1);
   }

   // Init plot
   for( x=0; x < 9; x++ ) {
      tmp.str("");
      tmp << "all layer " << dec << x;
      histA[x] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8191);
      tmp.str("");
      tmp << "zoom layer " << dec << x;
      histB[x] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8191);
      minVal[x] = 8192;
      maxVal[x] = 0;
   }

   //////////////////////////////////////////
   // Read Data
   //////////////////////////////////////////
   cout << "Opened data file: " << argv[1] << endl;
   fileSize = dataRead.size();
   filePos  = dataRead.pos();

   // Init
   currPct          = 0;
   lastPct          = 100;
   eventCount       = 0;

   cout << "\rReading File: 0 %" << flush;

   // Process each event
   while ( dataRead.next(&event) ) {

      // Get calibration state
      calChannel = dataRead.getConfigInt("UserDataA");

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         kpix    = sample->getKpixAddress();
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();
         tstamp  = sample->getSampleTime();
         range   = sample->getSampleRange();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data ) {

            // Report crosstalk, expected is 753
            //if ( channel != calChannel && tstamp > 753 && bucket == 0 ) {
            if ( channel != calChannel && bucket == 0 ) {
               histA[kpix]->Fill(tstamp);
               histB[kpix]->Fill(tstamp);
               if ( minVal[kpix] > tstamp ) minVal[kpix] = tstamp;
               if ( maxVal[kpix] < tstamp ) maxVal[kpix] = tstamp;
            }
         }
      }

      // Show progress
      filePos  = dataRead.pos();
      currPct = (uint)(((double)filePos / (double)fileSize) * 100.0);
      if ( currPct != lastPct ) {
         cout << "\rReading File: " << currPct << " %      " << flush;
         lastPct = currPct;
      }
      eventCount++;
   }
   cout << "\rReading File: Done.               " << endl;

   // Close file
   dataRead.close();

   c1 = new TCanvas("c1","c1");
   c2 = new TCanvas("c2","c2");
   c1->Divide(3,3,0.01,0.01);
   c2->Divide(3,3,0.01,0.01);

   for( x=0; x < 9; x++ ) {

      // All Data
      c1->cd(x+1)->SetLogy();
      if ( minVal[x] < 10 ) minVal[x] = 0;
      else minVal[x] += 10;
      if ( maxVal[x] > 8181 ) maxVal[x] = 8191;
      else maxVal[x] += 10;
      histA[x]->GetXaxis()->SetRangeUser(minVal[x],maxVal[x]);
      histA[x]->Draw();

      // Zoomed in
      c2->cd(x+1)->SetLogy();
      histB[x]->GetXaxis()->SetRangeUser(750,850);
      histB[x]->Draw();
   }

   c1->Print("crosstalk_all.ps");
   c2->Print("crosstalk_zoom.ps");

   theApp.Run();

   return(0);
}

