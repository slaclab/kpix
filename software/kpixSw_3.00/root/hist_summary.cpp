//-----------------------------------------------------------------------------
// File          : cal_summary.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/03/2011
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// File to generate calibration summary plots.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/03/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <TFile.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TMultiGraph.h>
#include <TApplication.h>
#include <TGraph.h>
#include <TStyle.h>
#include <stdarg.h>
#include <KpixEvent.h>
#include <KpixSample.h>
#include <Data.h>
#include <DataRead.h>
using namespace std;


// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {
   TCanvas         *c1;
   TH1F            *histSng;
   double          histMin;
   double          histMax;
   DataRead        dataRead;
   KpixEvent       event;
   KpixSample      *sample;
   uint            grCnt; 
   uint            x;
   uint            y;
   uint            value;
   uint            channel;
   uint            bucket;
   uint            tar;
   uint            eventCount;
   double          avg;
   char            name[100];
   uint            vlow;
   uint            vhigh;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 3 ) {
      cout << "Usage: hist_summary channel data_file\n";
      return(1);
   }
   tar = atoi(argv[1]);

   // 2d histogram
   histSng = new TH1F("Value_Hist_All","Value_Hist_All",8192,0,8192);
   histMin = 8192;
   histMax = 0;

   // Attempt to open data file
   if ( ! dataRead.open(argv[2]) ) return(2);

   // Process each event
   eventCount = 0;
   grCnt = 0;

   while ( dataRead.next(&event) ) {

      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();

         if ( channel == tar && bucket == 0 ) {
               
            histSng->Fill(value);

            if ( value < histMin ) histMin = value;
            if ( value > histMax ) histMax = value;
         }
      }
      eventCount++;
   }

   c1 = new TCanvas("c1","c1");
   c1->cd();
   histSng->GetXaxis()->SetRangeUser(histMin,histMax);
   histSng->Draw();

   // Start X-Windows
   theApp.Run();

   // Close file
   dataRead.close();
   return(0);
}

