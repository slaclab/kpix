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
#include <KpixRunRead.h>
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

// Generate name
char * genName (uint c, ...) {
   static char buffer[1000];
   va_list ap;
   uint    x;
   
   va_start(ap, c);
   strcpy(buffer,"");

   for ( x=0; x < c; x++ ) strcat(buffer,va_arg(ap,char *));
   va_end(ap);
   return(buffer);
}

// Plot and convert
void genPlot (TCanvas *c, char *name) {
   char buffer[200];
   c->Print(name);
   strcpy(buffer,"ps2pdf ");
   strcat(buffer,name);
   system(buffer);
   remove(name);
}

// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {

   KpixCalibRead   *calibRead;
   TH1F            *histValue[1024];
   TH1F            *histTime[1024];
   uint            channel, gain;
   TCanvas         *c1, *c2, *c3, *c4;
   TH2F            *histAllTime;
   TH2F            *histAllCen;
   TH2F            *histAll;
   uint            nBins;
   uint            x;
   double          minXTime = 8192;
   double          maxXTime = 0;
   double          minXCen  = 8192;
   double          maxXCen  = -8192;
   double          minX     = 8192;
   double          maxX     = -8192;
   double          bin;
   double          binCen;
   double          value;
   double          mean;
   double          histMean;
   double          histRms;
   double          histSigma;
   TH1F            *grHistMean;
   TH1F            *grHistRms;
   TH1F            *grHistSigma;
   const char      *desc;
   char            *bucket;
   char            *serial;
   const char      *runTime;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 4 ) {
      cout << "Usage: hist_summary serial bucket file.root\n";
      return(1);
   }
   serial = argv[1];
   bucket = argv[2];

   // Open calibration file
   try {
      calibRead  = new KpixCalibRead(argv[3],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }
   runTime = (const char *)calibRead->kpixRunRead->getRunTime();
   desc    = (const char *)calibRead->kpixRunRead->getRunDescription();

   // 2d histogram
   histAllTime = new TH2F("Time_Hist",
      genName(8,"Time Hist - ",serial," - ",desc," - ",bucket," - ",runTime),8192,0,8191,1024,0,1023);
   histAllCen  = new TH2F("Value_Hist_Cen",
      genName(8,"Value Hist - ",serial," - ",desc," - ",bucket," - ",runTime),16384,-8191,8191,1024,0,1023);
   histAll     = new TH2F("Value_Hist",
      genName(8,"Value Hist - ",serial," - ",desc," - ",bucket," - ",runTime),8192,0,8191,1024,0,1023);

   // Summary histograms
   grHistMean  = new TH1F("Hist_Mean",
      genName(8,"Hist Mean - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);
   grHistRms   = new TH1F("Hist_Rms",
      genName(8,"Hist RMS - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);
   grHistSigma = new TH1F("Hist_Sigma",
      genName(8,"Hist Sigma - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);

   // Parameters
   gain   = 0; // 0=Normal Gain, 1=Double Gain, 2=Low Gain

   // Cycle through each channel
   for ( channel = 0; channel < 1024; channel++ ) {

      histValue[channel] = calibRead->getHistValue("Force_Trig",gain,atoi(serial),channel,atoi(bucket));
      histTime[channel]  = calibRead->getHistTime("Force_Trig",gain,atoi(serial),channel,atoi(bucket));

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
         binCen = ((int)histValue[channel]->GetBinCenter(x)) - mean;
         bin = ((int)histValue[channel]->GetBinCenter(x));
         value = histValue[channel]->GetBinContent(x);

         if ( value > 0 ) {
            if ( binCen > maxXCen ) maxXCen = binCen;
            if ( binCen < minXCen ) minXCen = binCen;
            if ( bin    > maxX    ) maxX    = bin;
            if ( bin    < minX    ) minX    = bin;
         }
         histAllCen->SetBinContent((int)binCen+8193,channel,value);
         histAll->SetBinContent((int)bin,channel,value);
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
   genPlot(c1,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_value.ps"));

   // Time histogram
   c2 = new TCanvas("c2","c2");
   c2->cd();
   histAllTime->GetXaxis()->SetRangeUser(minXTime-1,maxXTime+1);
   histAllTime->Draw("colz");
   genPlot(c2,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_time.ps"));

   // Summary
   c3 = new TCanvas("c3","c3");
   //c3->Divide(1,3,0.01,0.01);
   c3->Divide(1,2,0.01,0.01);

   c3->cd(1);
   grHistMean->Draw();

   c3->cd(2);
   //grHistSigma->GetYaxis()->SetRangeUser(0,5);
   grHistSigma->Draw();

   //c3->cd(3);
   //grHistRms->GetYaxis()->SetRangeUser(0,5);
   //grHistRms->Draw();
   genPlot(c3,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_sum.ps"));

   // Value histogram
   c4 = new TCanvas("c4","c4");
   c4->cd();
   histAll->GetXaxis()->SetRangeUser(minX-1,maxX+1);
   histAll->Draw("colz");
   genPlot(c4,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_raw.ps"));

   // Start X-Windows
   theApp.Run();

   // Delete the created classes when done
   delete(calibRead);
}
