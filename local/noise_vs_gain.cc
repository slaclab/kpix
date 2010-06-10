//-----------------------------------------------------------------------------
// File          : noise_vs_noise.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/15/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Plot gain vs noise.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/15/2008: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <KpixRunRead.h>
#include <KpixCalibRead.h>
#include <TFile.h>
#include <TTree.h>
#include <TApplication.h>
using namespace std;

// Main Function
int main ( int argc, char **argv ) {
   KpixCalibRead     *calibRead;
   int               x;
   double            gains[64], noise[64];
   double            icept, mean, sigma, rms;
   TGraph            *graph;


   // Check Input
   if ( argc < 2 ) {
      cout << "Usage: noise_vs_gain imput_root_file\n";
      return(0);
   }

   // Open root file
   try {
      calibRead  = new KpixCalibRead(argv[1]);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(1);
   }

   // Start X11 view
   TApplication theApp("App",&argc,argv);

   // Get each gain 
   for (x=0; x < 64; x++) {

      calibRead->getCalibData ( &(gains[x]), &icept,"Force_Trig",0,
                                calibRead->kpixRunRead->getAsic(0)->getSerial(),x,0);

      calibRead->getHistData ( &mean, &sigma, &rms, "Force_Trig", 0, 
                               calibRead->kpixRunRead->getAsic(0)->getSerial(),x,0);

      gains[x] = gains[x] / 1e15;
      if ( gains[x] > 0 ) noise[x] = (sigma / gains[x]) * 6240;
      else noise[x] = 0;
   }

   graph = new TGraph(64,noise,gains);
   graph->Draw("A*");

   theApp.Run();
}

