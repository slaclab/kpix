//-----------------------------------------------------------------------------
// File          : hits_per_channel.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 01/20/2009
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Plot the number of hits in a run.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 01/20/2009: created
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
   KpixRunRead       *runRead;
   unsigned int      x,y;
   TH1F              *hist;
   double            hits[64], chan[64];
   unsigned int      bins;
   stringstream      temp;
   unsigned int      lastTrain, firstTrain, iterCount;
   TGraph            *graph;

   // Check Input
   if ( argc < 3 ) {
      cout << "Usage: hits_per_channel imput_root_file desc\n";
      return(0);
   }

   // Open root file
   try {
      runRead  = new KpixRunRead(argv[1],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(1);
   }

   // Start X11 view
   TApplication theApp("App",&argc,argv);

   // Figure out the number of iterations
   firstTrain = runRead->getSample(0)->getTrainNum();
   lastTrain = runRead->getSample(runRead->getSampleCount()-1)->getTrainNum();
   iterCount = (lastTrain - firstTrain)+1;
   cout << "Iteration Count = " << iterCount << endl;

   // Get each channel
   for (x=0; x < 64; x++) {

      // Generate Name
      temp.str("");
      temp << "/RunPlots/hist_raw_s" << dec << setw(4) << setfill('0') << runRead->getAsic(0)->getSerial();
      temp << "_c" << dec << setw(4) << setfill('0') << x;
      temp << "_r0";

      // Get histogram
      runRead->treeFile->GetObject(temp.str().c_str(),hist);
      hits[x] = 0;

      // Valid histogram
      if ( hist != NULL ) {

         // Get trigger counts
         bins = hist->GetNbinsX();

         // Get contents of each bin
         for (y=1; y <= bins; y++) hits[x] += hist->GetBinContent(y);
      }

      // Normalize hit count
      chan[x] = x;
      hits[x] /= (double)(iterCount);

      // Local channel Count
      cout << "Channel = " << setw(2) << setfill(' ') << x;
      cout << ", Count = " << setw(6) << setfill(' ') << hits[x] << endl;
   }

   // Set Name
   temp.str("");
   temp << "Iterations=" << iterCount << ", Desc=" << argv[2];

   // Draw Graph
   graph = new TGraph(64,chan,hits);
   graph->SetTitle(temp.str().c_str());
   graph->Draw("A*");

   // Start X-Windows
   theApp.Run();
}

