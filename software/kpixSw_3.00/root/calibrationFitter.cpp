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
      double       baseRms[4];

      // Calib Data
      double       calibCount[4][256];
      double       calibMean[4][256];
      double       calibSum[4][256];
      double       calibRms[4][256];

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
            baseRms[x]    = 0;

            for (y=0; y < 256; y++) {
               calibCount[x][y]  = 0;
               calibMean[x][y]   = 0;
               calibSum[x][y]    = 0;
               calibRms[x][y]    = 0;
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
            if ( baseCount[x] > 0 ) baseRms[x] = sqrt(baseSum[x] / baseCount[x]);
            for (y=0; y < 256; y++) {
               if ( calibCount[x][y] > 0 ) 
                  calibRms[x][y] = sqrt(calibSum[x][y] / calibCount[x][y]);
            }
         }
      }
};

// Process the data
int main ( int argc, char **argv ) {
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
   uint                   x;
   uint                   y;
   uint                   i;
   uint                   value;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   string                 serial;
   KpixSample::SampleType type;
   TCanvas                *c1;
   TH1F                   *hist;
   stringstream           tmp;
   stringstream           xml;
   bool                   xmlStart;
   double                 grX[256];
   double                 grY[256];
   double                 grYErr[256];
   double                 grXErr[256];
   uint                   grCount;
   TGraphErrors           *grCalib;

   // Init
   for (x=0; x < 32; x++) {
      for (y=0; y < 1024; y++) {
         chanData[x][y] = NULL;
      }
   }

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

            // Filter for time
            { 

               // Baseline
               if ( calState == "Baseline" ) 
                  chanData[kpix][channel]->addBasePoint(bucket,value);

               // Injection
               else if ( calState == "Inject" && channel == calChannel ) 
                  chanData[kpix][channel]->addCalibPoint(bucket, calDac, value);
            }
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

   xml.str("");
   xml << "<calibrationData>" << endl;

   // Process each kpix device
   for (kpix=0; kpix<32; kpix++) {
      xmlStart = false;

      // Process each channel
      for (channel=0; channel < 1024; channel++) {

         // Channel is valid
         if ( chanData[kpix][channel] != NULL ) {

            // Asic marker
            if ( !xmlStart ) {
               xml << "   <kpixAsic>" << endl;
               xml << "      <SerialNumber>";
               tmp.str("");
               tmp << "cntrlFpga(0):kpixAsic(" << dec << kpix << "):SerialNumber";
               serial = dataRead.getConfig(tmp.str());
               xml << serial;
               xml << "</SerialNumber>" << endl;
               xmlStart = true;
            }

            // Start channel marker
            xml << "      <Channel index=\"" << channel << "\">" << endl;
            chanData[kpix][channel]->compute();

            // Each bucket
            for (bucket = 0; bucket < 4; bucket++) {

               // Create histogram
               tmp.str("");
               tmp << "hist_" << serial << "_" << dec << setw(4) << setfill('0') << channel;
               tmp << "_" << dec << bucket;
               hist = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8192);

               // Fill histogram
               for (x=0; x < 8192; x++) {
                  hist->SetBinContent(i+1,chanData[kpix][channel]->baseData[bucket][x]);
                  hist->GetXaxis()->SetRangeUser(chanData[kpix][channel]->baseMin[bucket],
                                                 chanData[kpix][channel]->baseMax[bucket]);
                  hist->Fit("gaus");
                  //hist->Write();

                  // Add to xml
                  xml << "         <BaseMean>" << chanData[kpix][channel]->baseMean[bucket] << "</BaseMean>" << endl;
                  xml << "         <BaseRms>" << chanData[kpix][channel]->baseRms[bucket] << "</BaseRms>" << endl;
               }

               // Create calibration graph
               grCount = 0;
               for (x=0; x < 256; x++) {
                  
                  // Calibration point is valid
                  if ( chanData[kpix][channel]->calibCount[bucket][x] > 0 ) {
                     grX[x]     = x;
                     grY[x]     = chanData[kpix][channel]->calibMean[bucket][x];
                     grYErr[x]  = chanData[kpix][channel]->calibRms[bucket][x];
                     grXErr[x]  = 0;
                     grCount++;
                  }

                  // Create graph
                  grCalib = new TGraphErrors(grCount,grX,grY,grXErr,grYErr);
                  grCalib->Fit("pol1");
                  //grCalib->Write();
               }


            }

            // End channel
            xml << "      </Channel>" << endl;
         }

      }

      // End Asic marker
      if ( xmlStart ) xml << "   </kpixAsic>" << endl;
   }

   xml << "</calibrationData>" << endl;

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

