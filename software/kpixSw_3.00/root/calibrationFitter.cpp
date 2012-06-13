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
   uint                   minChan;
   uint                   maxChan;
   uint                   x;
   uint                   y;
   uint                   range;
   uint                   value;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   uint                   time;
   string                 serial;
   KpixSample::SampleType type;
   TH1F                   *hist;
   stringstream           tmp;
   ofstream               xml;
   bool                   xmlStart;
   double                 grX[256];
   double                 grY[256];
   double                 grYErr[256];
   double                 grXErr[256];
   uint                   grCount;
   TGraphErrors           *grCalib;
   bool                   positive;
   bool                   b0CalibHigh;
   uint                   injectTime[5];
   uint                   eventCount;
   string                 outRoot;
   string                 outXml;
   TFile                  *rFile;
   uint                   tarRange;
   TCanvas                *c1;

   // Init
   for (x=0; x < 32; x++) {
      for (y=0; y < 1024; y++) {
         chanData[x][y] = NULL;
      }
   }

   // Data file is the first and only arg
   if ( argc != 3 ) {
      cout << "Usage: calibrationFitter range data_file\n";
      cout << "       Range = 0 for normal gain\n";
      cout << "       Range = 1 for low    gain\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[2]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }
   tarRange = atoi(argv[1]);

   // Create output names
   tmp.str("");
   tmp << argv[2] << ".r" << tarRange << ".root";
   outRoot = tmp.str();
   tmp.str("");
   tmp << argv[2] << ".r" << tarRange << ".xml";
   outXml = tmp.str();

   //////////////////////////////////////////
   // Read Data
   //////////////////////////////////////////

   cout << "Opened data file: " << argv[2] << endl;
   fileSize = dataRead.size();
   filePos  = dataRead.pos();

   // Init
   currPct    = 0;
   lastPct    = 100;
   eventCount = 0;
   minChan    = 0;
   maxChan    = 0;

   cout << "\rReading File: 0 %" << flush;

   // Process each event
   while ( dataRead.next(&event) ) {

      // Get calibration state
      calState   = dataRead.getStatus("CalState");
      calChannel = dataRead.getStatusInt("CalChannel");
      calDac     = dataRead.getStatusInt("CalDac");

      // Get injection times
      if ( eventCount == 0 ) {
         minChan       = dataRead.getConfigInt("CalChanMin");
         maxChan       = dataRead.getConfigInt("CalChanMax");
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
         kpix    = sample->getKpixAddress();
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();
         time    = sample->getSampleTime();
         range   = sample->getSampleRange();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data && range == tarRange ) {

            // Create entry if it does not exist
            if ( chanData[kpix][channel] == NULL ) chanData[kpix][channel] = new ChannelData;

            // Filter for time
            if ( time > injectTime[bucket] && time < injectTime[bucket+1] ) {

               // Baseline
               if ( calState == "Baseline" ) chanData[kpix][channel]->addBasePoint(bucket,value);

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
         cout << "\rReading File: " << currPct << " %      " << flush;
         lastPct = currPct;
      }
      eventCount++;
   }
   cout << "\rReading File: Done.               " << endl;

   //////////////////////////////////////////
   // Process Data
   //////////////////////////////////////////

   // Default canvas
   c1 = new TCanvas("c1","c1");

   // Open root file
   rFile = new TFile(outRoot.c_str(),"recreate");

   // Open xml file
   xml.open(outXml.c_str(),ios::out | ios::trunc);
   xml << "<calibrationData>" << endl;

   // get calibration mode variables for charge computation
   positive    = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlPolarity") == "Positive");
   b0CalibHigh = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlCalibHigh") == "True");

   // Process each kpix device
   for (kpix=0; kpix<32; kpix++) {
      xmlStart = false;

      // Process each channel
      for (channel=minChan; channel <= maxChan; channel++) {

         // Show progress
         cout << "\rProcessing kpix " << dec << kpix << " / 31, Channel " << channel << " / " << dec << maxChan << "                 " << flush;

         // Channel is valid
         if ( chanData[kpix][channel] != NULL ) {

            // Asic marker
            if ( !xmlStart ) {
               tmp.str("");
               tmp << "cntrlFpga(0):kpixAsic(" << dec << kpix << "):SerialNumber";
               serial = dataRead.getConfig(tmp.str());

               xml << "   <kpixAsic index=\"" << serial << "\">" << endl;
               xmlStart = true;
            }

            // Start channel marker
            xml << "      <Channel index=\"" << channel << "\">" << endl;
            chanData[kpix][channel]->compute();

            // Each bucket
            for (bucket = 0; bucket < 4; bucket++) {
               xml << "         <Bucket index=\"" << bucket << "\">" << endl;

               // Create histogram
               tmp.str("");
               tmp << "hist_" << serial << "_" << dec << setw(4) << setfill('0') << channel;
               tmp << "_" << dec << bucket;
               hist = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8192);

               // Fill histogram
               for (x=0; x < 8192; x++) hist->SetBinContent(x+1,chanData[kpix][channel]->baseData[bucket][x]);
               hist->GetXaxis()->SetRangeUser(chanData[kpix][channel]->baseMin[bucket],
                                              chanData[kpix][channel]->baseMax[bucket]);
               hist->Fit("gaus","q");
               hist->Write();

               // Add to xml
               xml << "            <BaseMean>" << chanData[kpix][channel]->baseMean[bucket] << "</BaseMean>" << endl;
               xml << "            <BaseRms>" << chanData[kpix][channel]->baseRms[bucket] << "</BaseRms>" << endl;
               xml << "            <BaseFitMean>" << hist->GetFunction("gaus")->GetParameter(1) << "</BaseFitMean>" << endl;
               xml << "            <BaseFitSigma>" << hist->GetFunction("gaus")->GetParameter(2) << "</BaseFitSigma>" << endl;
               xml << "            <BaseFitMeanErr>" << hist->GetFunction("gaus")->GetParError(1) << "</BaseFitMeanErr>" << endl;
               xml << "            <BaseFitSigmaErr>" << hist->GetFunction("gaus")->GetParError(2) << "</BaseFitSigmaErr>" << endl;

               // Create calibration graph
               grCount = 0;
               for (x=0; x < 256; x++) {
               
                  // Calibration point is valid
                  if ( chanData[kpix][channel]->calibCount[bucket][x] > 0 ) {
                     grX[x]     = calibCharge ( x, positive, ((bucket==0)?b0CalibHigh:false));
                     grY[x]     = chanData[kpix][channel]->calibMean[bucket][x];
                     grYErr[x]  = chanData[kpix][channel]->calibRms[bucket][x];
                     grXErr[x]  = 0;
                     grCount++;
                  }
               }

               // Create graph
               if ( grCount > 0 ) {
                  grCalib = new TGraphErrors(grCount,grX,grY,grXErr,grYErr);
                  grCalib->Draw("a+");
                  grCalib->Fit("pol1","q");

                  // Create name and write
                  tmp.str("");
                  tmp << "calib_" << serial << "_" << dec << setw(4) << setfill('0') << channel;
                  tmp << "_" << dec << bucket;
                  grCalib->Write(tmp.str().c_str());

                  // Add to xml
                  xml << "            <CalibGain>" << grCalib->GetFunction("pol1")->GetParameter(1) << "</CalibGain>" << endl;
                  xml << "            <CalibIntercept>" << grCalib->GetFunction("pol1")->GetParameter(2) << "</CalibIntercept>" << endl;
                  xml << "            <CalibGainErr>" << grCalib->GetFunction("pol1")->GetParError(1) << "</CalibGainErr>" << endl;
                  xml << "            <CalibInterceptErr>" << grCalib->GetFunction("pol1")->GetParError(2) << "</CalibInterceptErr>" << endl;
               }
               xml << "         <Bucket>" << endl;
            }

            // End channel
            xml << "      </Channel>" << endl;
         }
      }

      // End Asic marker
      if ( xmlStart ) xml << "   </kpixAsic>" << endl;
   }
   cout << endl;
   cout << "Wrote root plots to " << outRoot << endl;
   cout << "Wrote xml data to " << outXml << endl;

   xml << "</calibrationData>" << endl;
   xml.close();
   delete rFile;

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

