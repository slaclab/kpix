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
   TGraph          *calValue[1024];
   uint            channel, gain;
   TCanvas         *c1, *c2;
   double          calGain;
   double          calIcept;
   double          calErr;
   TH1F            *grCalGain;
   TH1F            *grCalIcept;
   TH1F            *grCalErr;
   const char      *desc;
   char            *bucket;
   char            *serial;
   const char      *runTime;
   TMultiGraph     *mg;
   int             color;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 4 ) {
      cout << "Usage: cal_summary serial bucket file.root\n";
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

   // Summary histograms
   grCalGain  = new TH1F("Cal_Gain",genName(8,"Cal Gain - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);
   grCalIcept = new TH1F("Cal_Icept",genName(8,"Cal Icept - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);
   grCalErr   = new TH1F("Cal_Err",genName(8,"Cal Err - ",serial," - ",desc," - ",bucket," - ",runTime),1024,0,1024);

   // Parameters
   gain   = 0; // 0=Normal Gain, 1=Double Gain, 2=Low Gain

   mg = new TMultiGraph();
   color = 4;

   // Cycle through each channel
   for ( channel = 0; channel < 1024; channel++ ) {

      calValue[channel] = calibRead->getGraphValue("Force_Trig",gain,atoi(serial),channel,atoi(bucket),0);

      if ( calValue[channel] == NULL ) {
         cout << "Channel " << dec << channel << " is missing!" << endl;
         continue;
      }

      // Fit calibration
      calValue[channel]->Fit("pol1","q","",5e-15,150e-15);
      calValue[channel]->SetMarkerStyle(7);
      calValue[channel]->GetFunction("pol1")->SetLineWidth(1);

      // Get values
      calGain  = calValue[channel]->GetFunction("pol1")->GetParameter(1);
      calIcept = calValue[channel]->GetFunction("pol1")->GetParameter(0);
      calErr   = calValue[channel]->GetFunction("pol1")->GetParError(1);

      if ( calErr > 80e12 ) {
         calValue[channel]->SetMarkerColor(color);
         color++;
         mg->Add(calValue[channel]);
      }

      // Summary plot
      grCalGain->SetBinContent(channel+1,calGain);
      grCalIcept->SetBinContent(channel+1,calIcept);
      grCalErr->SetBinContent(channel+1,calErr);
   }

   // Summary
   c1 = new TCanvas("c1","c1");
   //c1->Divide(1,3,0.01,0.01);
   c1->Divide(1,2,0.01,0.01);

   c1->cd(1);
   grCalGain->Draw();

   c1->cd(2);
   grCalIcept->Draw();

   //c1->cd(3);
   //grCalErr->Draw();
   genPlot(c1,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_cal.ps"));

   // Multigraph
   c2 = new TCanvas("c2","c2");
   c2->cd();
   mg->SetTitle(genName(8,serial," ",desc," b",bucket," ",runTime," Err > 80e12"));
   mg->Draw("A*");
   genPlot(c2,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_high_err.ps"));

   // Start X-Windows
   theApp.Run();

   // Delete the created classes when done
   delete(calibRead);
}
