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
#include <KpixCalibRead.h>
#include <TApplication.h>
#include <TFile.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TMultiGraph.h>
#include <TGraph.h>
#include <TStyle.h>
using namespace std;

// Generate name
char * genName (char *first, char *second, char *third, char *fourth) {
   static char buffer[300];
   strcpy(buffer,first);
   strcat(buffer,second);
   strcat(buffer,third);
   strcat(buffer,fourth);
   return(buffer);
}


// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {

   KpixCalibRead   *calibRead;
   TH1F            *histValue[1024];
   TH1F            *histTime[1024];
   uint            channel, bucket, gain;
   TCanvas         *c1, *c2, *c3;
   TH2F            *histAllTime;
   TH2F            *histAllCen;
   uint            nBins;
   uint            x;
   double          minXTime = 8192;
   double          maxXTime = 0;
   double          minXCen  = 8192;
   double          maxXCen  = -8192;
   double          bin;
   double          value;
   double          mean;
   double          histMean;
   double          histRms;
   double          histSigma;
   TH1F            *grHistMean;
   TH1F            *grHistRms;
   TH1F            *grHistSigma;
   char            *desc;
   char            *serial;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 4 ) {
      cout << "Usage: hist_summary serial desc file.root\n";
      return(1);
   }
   serial = argv[1];
   desc   = argv[2];

   // Open calibration file
   try {
      calibRead  = new KpixCalibRead(argv[3],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }

   // 2d histogram
   histAllTime = new TH2F("Time_Hist",genName("Time Hist - ",serial," - ",desc),8192,0,8191,1024,0,1023);
   histAllCen  = new TH2F("Value_Hist_Cen",genName("Value Hist - ",serial," - ",desc),16384,-8191,8191,1024,0,1023);

   // Summary histograms
   grHistMean  = new TH1F("Hist_Mean",genName("Hist Mean - ",serial," - ",desc),1024,0,1024);
   grHistRms   = new TH1F("Hist_Rms",genName("Hist RMS - ",serial," - ",desc),1024,0,1024);
   grHistSigma = new TH1F("Hist_Sigma",genName("Hist Sigma - ",serial," - ",desc),1024,0,1024);

   // Parameters
   bucket = 0;
   gain   = 0; // 0=Normal Gain, 1=Double Gain, 2=Low Gain

   // Cycle through each channel
   for ( channel = 0; channel < 1024; channel++ ) {

      histValue[channel] = calibRead->getHistValue("Force_Trig",gain,atoi(serial),channel,bucket);
      histTime[channel]  = calibRead->getHistTime("Force_Trig",gain,atoi(serial),channel,bucket);

      if ( histValue[channel] == NULL || histTime[channel] == NULL ) {
         cout << "Channel " << dec << channel << " is missing!" << endl;
         continue;
      }

      // Fit histogram
      histValue[channel]->Fit("gaus","q");
      histMean  = histValue[channel]->GetFunction("gaus")->GetParameter(1);
      histSigma = histValue[channel]->GetFunction("gaus")->GetParameter(2);
      histRms   = histValue[channel]->GetRMS();
      mean      = histValue[channel]->GetMean();

      // Summary plot
      grHistMean->SetBinContent(channel+1,histMean);
      grHistRms->SetBinContent(channel+1,histRms);
      grHistSigma->SetBinContent(channel+1,histSigma);

      // Copy value histogram
      nBins = histValue[channel]->GetNbinsX();
      for ( x = 1; x <= nBins; x++ ) {
         bin = ((int)histValue[channel]->GetBinCenter(x)) - mean;
         value = histValue[channel]->GetBinContent(x);

         if ( value > 0 ) {
            if ( bin > maxXCen ) maxXCen = bin;
            if ( bin < minXCen ) minXCen = bin;
         }
         histAllCen->SetBinContent((int)bin+8193,channel,value);
      }

      // Copy time histogram
      nBins = histTime[channel]->GetNbinsX();
      for ( x = 1; x <= nBins; x++ ) {
         bin = (int)histTime[channel]->GetBinCenter(x);
         value = histTime[channel]->GetBinContent(x);

         if ( value > 0 ) {
            if ( bin > maxXTime ) maxXTime = bin;
            if ( bin < minXTime ) minXTime = bin;
         }
         histAllTime->SetBinContent((int)bin+1,channel,value);
      }
   }

   // Value histogram
   c1 = new TCanvas("c1","c1");
   c1->cd();
   histAllCen->GetXaxis()->SetRangeUser(minXCen-1,maxXCen+1);
   histAllCen->Draw("colz");
   c1->Print(genName(serial,"_",desc,"_value.ps"));

   // Time histogram
   c2 = new TCanvas("c2","c2");
   c2->cd();
   histAllTime->GetXaxis()->SetRangeUser(minXTime-1,maxXTime+1);
   histAllTime->Draw("colz");
   c2->Print(genName(serial,"_",desc,"_time.ps"));

   // Summary
   c3 = new TCanvas("c3","c3");
   c3->Divide(1,3,0.01,0.01);

   c3->cd(1);
   grHistMean->Draw();

   c3->cd(2);
   grHistSigma->GetYaxis()->SetRangeUser(0,5);
   grHistSigma->Draw();

   c3->cd(3);
   grHistRms->GetYaxis()->SetRangeUser(0,5);
   grHistRms->Draw();
   c3->Print(genName(serial,"_",desc,"_sum.ps"));

   // Start X-Windows
   theApp.Run();

   // Delete the created classes when done
   delete(calibRead);
}
