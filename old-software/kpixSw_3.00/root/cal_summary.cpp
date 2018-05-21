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
#include <TGraphErrors.h>
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

   KpixCalibRead   calibRead;
   uint            channel;
   TCanvas         *c1, *c2;
   double          calGain[1024];
   double          calGainErr[1024];
   double          calIcept[1024];
   double          calIceptErr[1024];
   double          calX[1024];
   double          calXErr[1024];
   TGraphErrors    *grCalGain;
   TGraphErrors    *grCalIcept;
   TH1F            *histCalGain;
   TH1F            *histCalIcept;
   int             bucket;
   char            *serial;
   char            *bucketStr;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 4 ) {
      cout << "Usage: cal_summary serial bucket file.xml\n";
      return(1);
   }
   serial    = argv[1];
   bucket    = atoi(argv[2]);
   bucketStr = argv[2];

   // Open calibration file
   if ( ! calibRead.parse(argv[3]) ) {
      cout << "Error opening file\n";
      return(2);
   }

   // Summary histograms
   histCalGain  = new TH1F("Cal_Gain",genName(4,"Cal Gain Hist - ",serial," - ",bucketStr),100,1e15,10e15);
   histCalIcept = new TH1F("Cal_Icept",genName(4,"Cal Icept Hist - ",serial," - ",bucketStr),1000,-500,500);

   // Cycle through each channel
   for ( channel = 0; channel < 1024; channel++ ) {

      // Get values
      calGain[channel]     = calibRead.calibGain(serial,channel,bucket,0);
      calGainErr[channel]  = calibRead.calibGainErr(serial,channel,bucket,0);
      calIcept[channel]    = calibRead.calibIntercept(serial,channel,bucket,0);
      calIceptErr[channel] = calibRead.calibInterceptErr(serial,channel,bucket,0);
      calX[channel]        = channel;
      calXErr[channel]     = 0;

      // Histogram
      histCalGain->Fill(calGain[channel]);
      histCalIcept->Fill(calIcept[channel]);
   }

   // Generate graphs
   grCalGain   = new TGraphErrors(1024,calX,calGain,calXErr,calGainErr);
   grCalIcept  = new TGraphErrors(1024,calX,calIcept,calXErr,calIceptErr);

   // Summary
   c1 = new TCanvas("c1","c1");
   c1->Divide(1,2,0.01,0.01);

   c1->cd(1);
   grCalGain->SetTitle(genName(4,"Cal Gain - ",serial," - ",bucketStr));
   grCalGain->Draw("Ap");

   c1->cd(2);
   grCalIcept->SetTitle(genName(4,"Cal Icept - ",serial," - ",bucketStr));
   grCalIcept->Draw("Ap");

   c2 = new TCanvas("c2","c2");
   c2->Divide(1,2,0.01,0.01);

   c2->cd(1);
   histCalGain->Draw();

   c2->cd(2);
   histCalIcept->Draw();

   // Start X-Windows
   theApp.Run();

}
