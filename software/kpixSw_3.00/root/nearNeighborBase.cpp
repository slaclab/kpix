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
#include <KpixCalibRead.h>
#include <Data.h>
#include <DataRead.h>
#include <math.h>
#include <fstream>
#include <XmlVariables.h>
using namespace std;
// Channel data
class ChannelData {
   public:

      // Baseline Data
      uint         baseData[8192];
      uint         baseMin;
      uint         baseMax;
      double       baseCount;
      double       baseMean;
      double       baseSum;
      double       baseRms;

      // Baseline fit data
      double       baseFitMean;
      double       baseFitSigma;
      double       baseFitMeanErr;
      double       baseFitSigmaErr;
      double       baseFitChisquare;

      ChannelData() {
         uint x;

         for (x=0; x < 8192; x++) baseData[x] = 0;
         baseMin          = 8192;
         baseMax          = 0;
         baseCount        = 0;
         baseMean         = 0;
         baseSum          = 0;
         baseRms          = 0;
         baseFitMean      = 0;
         baseFitSigma     = 0;
         baseFitMeanErr   = 0;
         baseFitSigmaErr  = 0;
         baseFitChisquare = 0;
      }

      void addBasePoint(uint data) {
         baseData[data]++;
         if ( data < baseMin ) baseMin = data;
         if ( data > baseMax ) baseMax = data;
         baseCount++;

         double tmpM = baseMean;
         double value = data;

         baseMean += (value - tmpM) / baseCount;
         baseSum  += (value - tmpM) * (value - baseMean);
      }

      void computeBase () {
         if ( baseCount > 0 ) baseRms = sqrt(baseSum / baseCount);
      }
};

const bool goodChannel ( uint kpix, uint channel ) {

   bool good = true;

   // Global bad channels
   if ( channel == 13  || channel == 14  || channel == 15   || channel == 41   || channel == 54  || channel == 55  ||
        channel == 256 || channel == 257 || channel == 258  || channel == 259  || channel == 265 || channel == 266 ||
        channel == 267 || channel == 268 || channel == 284  || channel == 285  || channel == 286 || channel == 287 ||
        channel == 736 || channel == 737 || channel == 738  || channel == 739  || channel == 745 || channel == 746 ||
        channel == 747 || channel == 748 || channel == 764  || channel == 765  || channel == 766 || channel == 767 ||
        channel == 983 || channel == 984 || channel == 1005 || channel == 1006 || channel == 1007 ) good = false;

   // Kpix 0 bad channels
   if ( kpix == 0 && ( channel == 3  || channel == 4  || channel == 8  || channel == 13 || channel == 14 || channel == 15 || channel == 21 ||
                       channel == 24 || channel == 26 || channel == 32 || channel == 38 || channel == 41 || channel == 45 || channel == 47 ||
                       channel == 49 || channel == 54 || channel == 55 || channel == 57 || channel == 58 || channel == 60 || channel == 61 ||
                       channel == 62 || channel == 63 ) ) good = false;

   // Kpix 2 bad channels
   if ( kpix == 2 && ( channel == 1005 || channel == 1006 || channel == 1007 || channel == 1009 )) good = false;

   // Kpix 7 bad channels
   if ( kpix == 7 && ( channel == 13 || channel == 14 || channel == 15 || channel == 19 || channel == 27 ||
                       channel == 41 || channel == 42 || channel == 49 || channel == 52 || channel == 54 || 
                       channel == 55 || channel == 57 )) good = false;

   return(good);
}

//From http://www.richelbilderbeek.nl/CppRemovePath.htm
//Returns the filename without path
const std::string RemovePath(const std::string& filename) {
  const int sz = static_cast<int>(filename.size());
  const int path_sz = filename.rfind("/",filename.size());
  if (path_sz == sz) return filename;
  return filename.substr(path_sz + 1,sz - 1 - path_sz);
}

// Process the data
int main ( int argc, char **argv ) {
   DataRead               dataRead;
   KpixCalibRead          calibRead;
   KpixEvent              event;
   KpixSample             *sample;
   uint                   calChannel;
   uint                   currPct;
   uint                   lastPct;
   uint                   eventCount;
   uint                   x;
   uint                   y;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   uint                   value;
   uint                   type;
   uint                   tstamp;
   uint                   range;
   size_t                 filePos;
   size_t                 fileSize;
   TH1F                 * hist;
   TH1F                 * histA[9];
   TH1F                 * histB[9];
   TH1F                 * histC[9];
   TCanvas              * c1;
   TCanvas              * c2;
   TCanvas              * c3;
   double                 minValA[9];
   double                 maxValA[9];
   double                 minValB[9];
   double                 maxValB[9];
   double                 minValC[9];
   double                 maxValC[9];
   stringstream           tmp;
   string                 serialList[9];
   char                   temp[200];
   uint                   ttype;
   ChannelData            *chanData[9][1024];
   double                 diff;
   double                 diffCharge;
   double                 gain;
   double                 gainTar;
   int                    bad;
   int                    badTar;
   double                 base;
   string                 outXml;
   ofstream               xml;
   char                   tstr[200];
   struct tm              *timeinfo;
   time_t                 tme;

   // Init structure
   for (kpix=0; kpix < 9; kpix++) {
      for (channel=0; channel < 1024; channel++) {
         chanData[kpix][channel] = new ChannelData;
      }
   }

   TApplication theApp("App",NULL,NULL);
   gStyle->SetOptFit(1111);
   gStyle->SetOptStat(111111111);

   if ( argc != 3 ) {
      cout << "Usage: nearNeighborBase data_file calib_file\n";
      return(1);
   }

   // Attempt to open  calibration file
   if ( calibRead.parse(argv[2]) ) 
      cout << "Read calibration data from " << argv[2] << endl << endl;

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
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
   eventCount = 0;
   while ( dataRead.next(&event) ) {

      // Get serial numbers after first record
      if ( eventCount == 0 ) {
         for (x=0; x < 9; x++) {
            tmp.str("");
            tmp << "cntrlFpga(0):kpixAsic(" << dec << x << "):SerialNumber";
            serialList[x] = dataRead.getConfig(tmp.str());
         }
      }

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
         ttype   = sample->getTrigType();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data ) {
            if ( channel != calChannel && bucket == 0 ) {
               if ( ttype == 0 && range == 0 ) {

                  // Get gain and mean for target channel
                  gainTar = calibRead.calibGain(serialList[kpix],calChannel,0,0);
                  badTar  = calibRead.badChannel(serialList[kpix],calChannel);

                  // Get gain and mean for channel/bucket
                  gain = calibRead.calibGain(serialList[kpix],channel,bucket,range);
                  bad  = calibRead.badChannel(serialList[kpix],channel);

                  if ( (gainTar > 3e15) && (gain > 3e15) && !badTar && !bad && goodChannel(kpix,calChannel) && goodChannel(kpix,channel) ) {
                     chanData[kpix][channel]->addBasePoint(value);
                  }
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

   // Close file
   dataRead.close();

   tmp.str("");
   tmp << argv[1] << ".xml";
   outXml = tmp.str();

   // Open xml file
   xml.open(outXml.c_str(),ios::out | ios::trunc);
   xml << "<calibrationData>" << endl;

   // Add notes
   xml << "   <sourceFile>" << argv[2] << "</sourceFile>" << endl;
   xml << "   <user>" <<  getlogin() << "</user>" << endl;

   time(&tme);
   timeinfo = localtime(&tme);
   strftime(tstr,200,"%Y_%m_%d_%H_%M_%S",timeinfo);
   xml << "   <timestamp>" << tstr << "</timestamp>" << endl;

   // Process channels
   for ( kpix=0; kpix < 9; kpix++ ) {
      xml << "   <kpixAsic id=\"" << serialList[kpix] << "\">" << endl;

      tmp.str("");
      tmp << "base diff adc " << dec << kpix << " " << RemovePath(argv[1]);
      histA[kpix] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),16384,-8191,8191);
      minValA[kpix] = 8192;
      maxValA[kpix] = -8192;

      tmp.str("");
      tmp << "base diff charge " << dec << kpix << " " << RemovePath(argv[1]);
      histB[kpix] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),1000,-500e-15,500e-15);
      minValB[kpix] = 500e-15;
      maxValB[kpix] = -500e-15;

      tmp.str("");
      tmp << "base adc " << dec << kpix << " " << RemovePath(argv[1]);
      histC[kpix] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),16384,-8191,8191);
      minValC[kpix] = 8192;
      maxValC[kpix] = -8192;

      for (x=0; x < 1024; x++ ) {
         gain = calibRead.calibGain(serialList[kpix],x,0,0);
         bad  = calibRead.badChannel(serialList[kpix],x);

         if ( gain > 3e15 && !bad && chanData[kpix][x]->baseCount > 0 ) {
            chanData[kpix][x]->computeBase();

            tmp.str("");
            tmp << "hist_" << serialList[kpix] << "_c" << dec << setw(4) << setfill('0') << x;
            hist = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8192);

            for (y=0; y < 8192; y++) hist->SetBinContent(y+1,chanData[kpix][x]->baseData[y]);
            hist->GetXaxis()->SetRangeUser(chanData[kpix][x]->baseMin,
                                           chanData[kpix][x]->baseMax);
            hist->Fit("gaus","q");

            base = 0;
            base = hist->GetFunction("gaus")->GetParameter(1);

            diff = base - calibRead.baseFitMean(serialList[kpix],x,0,0);
            gain = calibRead.calibGain(serialList[kpix],x,0,0);

            diffCharge = diff / gain;
         
            histA[kpix]->Fill(diff);
            if ( diff > maxValA[kpix] ) maxValA[kpix] = diff;
            if ( diff < minValA[kpix] ) minValA[kpix] = diff;

            histB[kpix]->Fill(diffCharge);
            if ( diffCharge > maxValB[kpix] ) maxValB[kpix] = diffCharge;
            if ( diffCharge < minValB[kpix] ) minValB[kpix] = diffCharge;

            histC[kpix]->Fill(base);
            if ( base > maxValC[kpix] ) maxValC[kpix] = base;
            if ( base < minValC[kpix] ) minValC[kpix] = base;

            if ( base > 50 && base < 300 ) {
               xml << "      <Channel id=\"" << x << "\">" << endl;
               xml << "         <Bucket id=\"0\">" << endl;
               xml << "            <Range id=\"0\">" << endl;
               xml << "               <BaseFitMean>" << base << "</BaseFitMean>" << endl;
               xml << "            </Range>" << endl;
               xml << "         </Bucket>" << endl;
               xml << "      </Channel>" << endl;
            }
         }
      }
      xml << "   </kpixAsic>" << endl;
   }
   xml << "</calibrationData>" << endl;
   xml.close();
   cout << "Wrote xml data to " << outXml << endl;

   c1 = new TCanvas("c1","c1");
   c2 = new TCanvas("c2","c2");
   c3 = new TCanvas("c3","c3");
   c1->Divide(3,3,0.01,0.01);
   c2->Divide(3,3,0.01,0.01);
   c3->Divide(3,3,0.01,0.01);

   // Process channels
   for ( kpix=0; kpix < 9; kpix++ ) {

      //c1->cd(kpix+1)->SetLogy();
      c1->cd(kpix+1);
      histA[kpix]->GetXaxis()->SetRangeUser(minValA[kpix],maxValA[kpix]);
      histA[kpix]->Draw();

      //c2->cd(kpix+1)->SetLogy();
      c2->cd(kpix+1);
      histB[kpix]->GetXaxis()->SetRangeUser(minValB[kpix],maxValB[kpix]);
      histB[kpix]->Fit("gaus","q");
      histB[kpix]->Draw();

      //c3->cd(kpix+1)->SetLogy();
      c3->cd(kpix+1);
      histC[kpix]->GetXaxis()->SetRangeUser(minValC[kpix],maxValC[kpix]);
      histC[kpix]->Draw();
   }

   //sprintf(temp,"%s_adc.ps",RemovePath(argv[1]).c_str());
   //c1->Print(temp);
   //sprintf(temp,"ps2pdf %s_adc.ps",RemovePath(argv[1]).c_str());
   //system(temp);

   sprintf(temp,"%s_charge.ps",RemovePath(argv[1]).c_str());
   c2->Print(temp);
   sprintf(temp,"ps2pdf %s_charge.ps",RemovePath(argv[1]).c_str());
   system(temp);

   //sprintf(temp,"%s_base.ps",RemovePath(argv[1]).c_str());
   //c3->Print(temp);
   //sprintf(temp,"ps2pdf %s_base.ps",RemovePath(argv[1]).c_str());
   //system(temp);

   theApp.Run();

   return(0);
}

