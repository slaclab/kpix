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
using namespace std;

// Channel data
class ChannelData {
   public:

      // Calib Data
      double calibCount[256];
      double calibMean[256];
      double calibSum[256];
      double calibRms[256];

      ChannelData() {
         for (uint x=0; x < 256; x++) {
            calibCount[x]  = 0;
            calibMean[x]   = 0;
            calibSum[x]    = 0;
            calibRms[x]    = 0;
         }
      }

      void addCalibPoint(uint x, uint y) {
         calibCount[x]++;

         double tmpM = calibMean[x];
         double value = y;

         calibMean[x] += (value - tmpM) / calibCount[x];
         calibSum[x]  += (value - tmpM) * (value - calibMean[x]);
      }

      void compute() {
         for (uint x=0; x < 256; x++) {
            if ( calibCount[x] > 0 ) calibRms[x] = sqrt(calibSum[x] / calibCount[x]);
         }
      }
};

// Function to compute calibration charge
double calibCharge ( uint dac, bool positive, bool highCalib ) {
   double volt;
   double charge;

   if ( dac >= 0xf6 ) volt = 2.5 - ((double)(0xff-dac))*50.0*0.0001;
   else volt =(double)dac * 100.0 * 0.0001;

   if ( positive ) charge = (2.5 - volt) * 200e-15;
   else charge = volt * 200e-15;

   if ( highCalib ) charge *= 22.0;

   return(charge);
}


// Process the data
int main ( int argc, char **argv ) {
   DataRead               dataRead;
   off_t                  fileSize;
   off_t                  filePos;
   KpixEvent              event;
   KpixSample             *sample;
   string                 calState;
   uint                   calChannel;
   uint                   calDac;
   uint                   lastPct;
   uint                   currPct;
   ChannelData            *chanData[9];
   int                    chanNum[9];
   uint                   x;
   uint                   y;
   uint                   tar;
   uint                   tarRow;
   uint                   tarCol;
   uint                   value;
   uint                   channel;
   uint                   bucket;
   uint                   tstamp;
   string                 serial;
   KpixSample::SampleType type;
   stringstream           tmp;
   ofstream               xml;
   double                 grX[256];
   double                 grY[256];
   double                 grYErr[256];
   double                 grXErr[256];
   uint                   grCount;
   TGraphErrors           *grCalib[9];
   bool                   positive;
   bool                   b0CalibHigh;
   uint                   injectTime[5];
   uint                   eventCount;
   string                 outRoot;
   string                 outXml;
   TCanvas                *c1;
   stringstream           name;
   int                    row;
   int                    col;

   TApplication theApp("App",NULL,NULL);

   // Data file is the first and only arg
   if ( argc != 3 ) {
      cout << "Usage: crossCalib data_file target\n";
      return(1);
   }

   // Figure out channel, row & col
   tar = atoi(argv[2]);
   tarCol = tar / 32;
   tarRow = tar % 32;

   // Init structure
   // 0 1 2
   // 3 4 5
   // 6 7 8
   for (x=0; x < 9; x++) {
      chanData[x] = new ChannelData;
      if (x==0) { col = tarCol - 1; row = tarRow+1; }
      if (x==1) { col = tarCol;     row = tarRow+1; }
      if (x==2) { col = tarCol + 1; row = tarRow+1; }
      if (x==3) { col = tarCol - 1; row = tarRow;   }
      if (x==4) { col = tarCol;     row = tarRow;   }
      if (x==5) { col = tarCol + 1; row = tarRow;   }
      if (x==6) { col = tarCol - 1; row = tarRow-1; }
      if (x==7) { col = tarCol;     row = tarRow-1; }
      if (x==8) { col = tarCol + 1; row = tarRow-1; }

      // Determine grid number 
      if ( col < 0 || col > 31 || row < 0 || row > 31 ) chanNum[x] = -1;
      else chanNum[x] = col*32 + row;
   }      

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }

   // Print channel information
   cout << "Target=" << dec << tar << ", Row=" << dec << tarCol << ", Col=" << dec << tarRow << endl;
   cout << "Grid: ";
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[0];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[1];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[2];
   cout << endl;
   cout << "      ";
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[3];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[4];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[5];
   cout << endl;
   cout << "      ";
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[6];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[7];
   cout << " " << dec << setfill(' ') << setw(4) << chanNum[8];
   cout << endl;

   //////////////////////////////////////////
   // Read Data
   //////////////////////////////////////////
   cout << "Opened data file: " << argv[1] << endl;
   fileSize = dataRead.size();
   filePos  = dataRead.pos();

   // Init
   currPct    = 0;
   lastPct    = 100;
   eventCount = 0;

   cout << "\rReading File: 0 %" << flush;

   // Process each event
   while ( dataRead.next(&event) ) {

      // Get calibration state
      calState   = dataRead.getStatus("CalState");
      calChannel = dataRead.getStatusInt("CalChannel");
      calDac     = dataRead.getStatusInt("CalDac");

      // Get injection times
      if ( eventCount == 0 ) {
         injectTime[0] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal0Delay");
         injectTime[1] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal1Delay") + injectTime[0] + 4;
         injectTime[2] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal2Delay") + injectTime[1] + 4;
         injectTime[3] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal3Delay") + injectTime[2] + 4;
         injectTime[4] = 8192;
      }

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();
         tstamp  = sample->getSampleTime();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data ) {

            // Filter for time
            if ( tstamp > injectTime[bucket] && tstamp < injectTime[bucket+1] ) {

               // Injection
               if ( calState == "Inject" && chanNum[4] == (int)calChannel ) {
                  for (y=0; y < 9; y++ ) if ( chanNum[y] == (int)channel ) chanData[y]->addCalibPoint(calDac, value);
               }
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

   //////////////////////////////////////////
   // Process Data
   //////////////////////////////////////////
   gStyle->SetOptFit(1111);

   // Default canvas
   c1 = new TCanvas("c1","c1");
   c1->Divide(3,3,0.02,0.02);

   // get calibration mode variables for charge computation
   positive    = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlPolarity") == "Positive");
   b0CalibHigh = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlCalibHigh") == "True");

   // Each channel plot
   for (y=0; y < 9; y++ ) {

 
      // Create calibration graph
      grCount = 0;
      for (x=0; x < 256; x++) {
                           
         // Calibration point is valid
         if ( chanData[y]->calibCount[x] > 0 ) {
            grX[grCount]    = calibCharge ( x, positive, ((bucket==0)?b0CalibHigh:false));
            grY[grCount]    = chanData[y]->calibMean[x];
            grYErr[grCount] = chanData[y]->calibRms[x];
            grXErr[grCount] = 0;
            grCount++;
         }
      }

      // Create graph
      if ( grCount > 0 ) {
         c1->cd(y+1);
         grCalib[y] = new TGraphErrors(grCount,grX,grY,grXErr,grYErr);
         grCalib[y]->Draw("A*");
      }
   }

   // Write file
   name.str("");
   name << "chan_" << dec << setfill('0') << setw(4) << tar << ".ps";
   c1->Print(name.str().c_str());

   theApp.Run();
}

