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
#include <KpixSample.h>
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
   uint            pixel, channel, gain;
   TCanvas         *c1, *c2, *c3, *c4;
   TH2F            *histAllTime;
   TH2F            *histAllCen;
   TH2F            *histAll;
   TH1D            *projCen;
   uint            x;
   double          mean[64];
   double          fgain[64];
   double          icept;
   double          sigma;
   double          rms;
   double          minXTime = 8192;
   double          maxXTime = 0;
   double          minXCen  = 8192;
   double          maxXCen  = -8192;
   double          minX     = 8192;
   double          maxX     = -8192;
   double          bin;
   double          binCen;
   double          time;
   const char      *desc;
   char            *bucket;
   char            *serial;
   const char      *runTime;
   uint            col;
   uint            row;
   uint            count;
   KpixSample      *sample;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   // Root file is the first and only arg
   if ( argc != 4 ) {
      cout << "Usage: gem_summary serial bucket file.root\n";
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
      genName(8,"Time Hist - ",serial," - ",desc," - ",bucket," - ",runTime),8192,0,8191,64,0,63);
   histAllCen  = new TH2F("Value_Hist_Cen",
      genName(8,"Value Hist Cen - ",serial," - ",desc," - ",bucket," - ",runTime),16384,-8191,8191,64,0,63);
   histAll     = new TH2F("Value_Hist",
      genName(8,"Value Hist - ",serial," - ",desc," - ",bucket," - ",runTime),8192,0,8191,64,0,63);

   // Parameters
   gain = 0; // 0=Normal Gain, 1=Double Gain, 2=Low Gain

   // Get mean values
   for ( x=0; x < 64; x++ ) {
      col = x / 4;
      row = (x % 4);
      channel = (col * 32) + ((row < 2)?(row):(28+row));
      calibRead->getHistData(&(mean[x]),&sigma,&rms,"Force_Trig",gain,atoi(serial),channel,atoi(bucket));
      calibRead->getCalibData(&(fgain[x]),&icept,"Force_Trig",gain,atoi(serial),channel,atoi(bucket));
      cout << "Pixel=" << dec << x << " Channel=" << dec << channel << " Gain=" << fgain[x] << " Mean=" << mean[x] << endl;
   }

   // Go through each sample
   count = calibRead->kpixRunRead->getSampleCount();
   for ( x=0; x < count; x++ ) {

      sample  = calibRead->kpixRunRead->getSample(x);
      channel = sample->getKpixChannel();

      // Convert channel
      col = channel / 32;
      row = channel % 32;

      // Skip some pixels
      if ( row < 2 || row > 29 ) {
         pixel = (4 * col) + ((row < 2)?(row):(row-28));

         // Get mean
         bin     = sample->getSampleValue();
         binCen  = bin - mean[pixel];
         time    = sample->getSampleTime();

         // Fill value histogram
         histAll->Fill(bin,pixel);
         if ( bin > maxX ) maxX = bin;
         if ( bin < minX ) minX = bin;

         // Fill time histogram
         histAllTime->Fill(time,pixel);
         if ( time > maxXTime ) maxXTime = time;
         if ( time < minXTime ) minXTime = time;

         // Fill centered histogram
         histAllCen->Fill(binCen,pixel);
         if ( binCen > maxXCen ) maxXCen = binCen;
         if ( binCen < minXCen ) minXCen = binCen;
      }
   }

   // Value histogram
   c1 = new TCanvas("c1","c1");
   c1->cd();
   histAllCen->GetXaxis()->SetRangeUser(minXCen-1,maxXCen+1);
   cout << "MinXCen=" << minXCen << " MaxXCen=" << maxXCen << endl;
   histAllCen->Draw("colz");
   genPlot(c1,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_value.ps"));

   // Time histogram
   c2 = new TCanvas("c2","c2");
   c2->cd();
   histAllTime->GetXaxis()->SetRangeUser(minXTime-1,maxXTime+1);
   histAllTime->Draw("colz");
   genPlot(c2,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_time.ps"));

   // Value histogram
   c3 = new TCanvas("c3","c3");
   c3->cd();
   histAll->GetXaxis()->SetRangeUser(minX-1,maxX+1);
   histAll->Draw("colz");
   genPlot(c3,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_raw.ps"));

   // Projection
   c4 = new TCanvas("c4","c4");
   c4->cd();
   projCen = histAllCen->ProjectionX();
   projCen->GetXaxis()->SetRangeUser(minXCen-1,maxXCen+1);
   projCen->Draw();
   genPlot(c4,genName(8,serial,"_",desc,"_b",bucket,"_",runTime,"_proj.ps"));

   // Start X-Windows
   theApp.Run();

   // Delete the created classes when done
   delete(calibRead);
}
