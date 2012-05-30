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
#include <TGraph.h>
#include <TStyle.h>
#include <stdarg.h>
#include <KpixEvent.h>
#include <KpixSample.h>
#include <Data.h>
#include <DataRead.h>
using namespace std;

// Channel data
class ChannelData {
   public:

      // Baseline Data
      uint         baseData[4][8192];
      uint         baseMin[4];
      uint         baseMax[4];
      double       baseCount[4];
      double       baseMean[4];
      double       baseSum[4];
      double       baseStdDev[4];

      // Calib Data
      double       calibCount[4][256];
      double       calibMean[4][256];
      double       calibSum[4][256];
      double       calibStdDev[4][256];
   
      ChannelData() {
         uint x;
         uint y;

         for (x=0; x < 4; x++) {
            for (y=0; y < 8192; y++) baseData[x][y] = 0;
            baseMin[x]    = 8192;
            baseMax[x]    = 0;
            baseCount[x]  = 0;
            baseMean[x]   = 0;
            baseSum[x]    = 0;
            baseStdDev[x] = 0;

            for (y=0; y < 256; y++) {
               calibCount[x][y]  = 0;
               calibMean[x][y]   = 0;
               calibSum[x][y]    = 0;
               calibStdDev[x][y] = 0;
            }
         }
      }

      void addBasePoint(uint b, uint data) {
         baseData[b][data]++;
         if ( data < baseMin[b] ) baseMin[b] = data;
         if ( data > baseMax[b] ) baseMax[b] = data;
         baseCount[b]++;

         double tmpM = baseMean[b];
         double value = data;

         baseMean[b] += (value - tmpM) / baseCount[b];
         baseSum[b]  += (value - tmpM) * (value - baseMean[b]);
      }

      void addCalibPoint(uint b, uint x, uint y) {
         calibCount[b][x]++;

         double tmpM = calibMean[b][x];
         double value = y;

         calibMean[b][x] += (value - tmpM) / calibCount[b][x];
         calibSum[b][x]  += (value - tmpM) * (value - calibMean[b][x]);
      }

      void compute() {
         uint x;
         uint y;

         for (x=0; x < 4; x++) {
            if ( baseCount[x] > 0 ) baseStdDev[x] = sqrt(baseStdSum[x] / baseCount[x]);
            for (y=0; y < 256; y++) {
               if ( calibCount[x][y] > 0 ) 
                  calibStdDev[x][y] = sqrt(calibStdSum[x][y] / calibCount[x][y]);
            }
         }
      }
};

// Process the data
int main ( int argc, char **argv ) {
   //TCanvas         *c1;
   //TH1F            *histSng;
   //double          histMin;
   //double          histMax;
   DataRead               dataRead;
   double                 fileSize;
   double                 filePos;
   KpixEvent              event;
   KpixSample             *sample;
   string                 calState;
   uint                   calChannel;
   uint                   calDac;
   uint                   lastPct;
   uint                   currPct;
   ChannelData            *chanData[32][1024];
   //uint            grCnt; 
   uint                   x;
   uint                   y;
   uint                   value;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   KpixSample::SampleType type;
   //uint            tar;
   //uint            eventCount;
   //double          avg;
   //char            name[100];
   //uint            vlow;
   //uint            vhigh;

   for (x=0; x < 32; x++) {
      for (y=0; y < 1024; y++) {
         chanData[x][y] = NULL;
      }
   }

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Data file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: calibrationFitter data_file\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }

   // Determine file size
   fileSize = dataRead.size();
   filePos  = dataRead.pos();
   currPct  = 0;
   lastPct  = 100;

   // Process each event
   while ( dataRead.next(&event) ) {

      // Get calibration state
      calState   = dataRead.getStatus("calState");
      calChannel = dataRead.getStatusInt("calChannel");
      calDac     = dataRead.getStatusInt("calDac");

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         kpix    = sample->getKpixAddress();
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();

         // Only process real samples
         if ( type == KpixSample::Data ) {

            // Create entry if it does not exist
            if ( chanData[kpix][channel] == NULL ) chanData[kpix][channel] = new ChannelData;

            // Baseline
            if ( calState == "Baseline" ) chanData[kpix][channel]->addBasePoint(bucket,value);

            // Injection
            else if ( calState == "Inject" && channel == calChannel ) 
               chanData[kpix][channel]->addCalibPoint(bucket, calDac, value);
         }
      }

      // Show progress
      filePos  = dataRead.pos();
      currPct = (uint)((filePos / fileSize) * 100.0);
      if ( currPct != lastPct ) {
         cout << "\rReading File: " << currPct << " %";
         lastPct = currPct;
      }
   }
   cout << "  Done!" << endl;


/*











   c1 = new TCanvas("c1","c1");
   c1->cd();
   histSng->GetXaxis()->SetRangeUser(histMin,histMax);
   histSng->Draw();

*/

   // Start X-Windows
   theApp.Run();

   // Cleanup
   for (x=0; x < 32; x++) {
      for (y=0; y < 1024; y++) {
         if ( chanData[x][y] != NULL ) delete chanData[x][y];
      }
   }

   // Close file
   dataRead.close();
   return(0);
}

