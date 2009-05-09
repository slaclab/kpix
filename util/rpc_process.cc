//-----------------------------------------------------------------------------
// File          : rpc_process.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 06/09/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Combine multiple run files into a single root file.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 06/09/2007: created
// 03/03/2009: Added timestamps to stored data.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <KpixRunRead.h>
#include <KpixCalibRead.h>
#include <TFile.h>
#include <TTree.h>
using namespace std;

// Main Function
int main ( int argc, char **argv ) {
   TFile             *outRoot;
   KpixRunRead       *runRead;
   KpixCalibRead     *calibRead;
   KpixSample        *sample;
   TTree             *sampleTree;
   int               x,y,total, channel, lastEvent;
   int               oldPct, curPct;
   double            icept[64],gain[64];
   Double_t          charge[64];
   Int_t             run,event, time[64];

   // Check Input
   if ( argc < 3 ) {
      cout << "Usage: rpc_process out_file imput_root_files\n";
      return(0);
   }

   // Create Root File To Store Data
   if ( (outRoot = new TFile(argv[1],"recreate")) == NULL ) {
      cout << "Could not open root file" << endl;
      return(1);
   }
   cout << "Storing Data to " << argv[1] << endl;

   // Create tree for samples
   sampleTree = new TTree("SampleTree","Tree Containing KpixSample Objects");
   sampleTree->Branch("run",&run,"run/I");
   sampleTree->Branch("event",&event,"event/I");
   sampleTree->Branch("charge",charge,"charge[64]/D");
   sampleTree->Branch("time",time,"time[64]/I");

   // Process each passed file
   for ( x=2; x < argc; x++ ) {

      // Open root file
      try {
         runRead  = new KpixRunRead(argv[x],false);
      } catch ( string error ) {
         cout << "Error opening run file:\n";
         cout << error << "\n";
         return(2);
      }

      // Extract calibration constants from the first file
      if ( x == 2 ) {
         cout << "Reading Calibration Data" << endl;
         calibRead = new KpixCalibRead(runRead);
         for (y=0; y<64; y++) {
            if ( ! calibRead->getCalibData ( &(gain[y]), &(icept[y]),"Force_Trig",2,
                                             runRead->getAsic(0)->getSerial(),y,0) ) {
               gain[y]  = 0;
               icept[y] = 0;
               cout << "Channel " << y << " Disable" << endl;
            }
         }
         delete calibRead;
         cout << "Done" << endl;
      }

      // Set run number
      run = x-0;

      // Debug
      cout << "Processing File " << dec << setw(3) << x-1;
      cout << " out of " << dec << setw(3) << argc-2;
      cout << ": " << argv[x] << endl;

      // Init variables
      oldPct    = -1;
      lastEvent = -1;
      total     = runRead->getSampleCount();

      // Get each sample
      for (y=0; y < total; y++) {

         // Compute percent done
         curPct = (int)(100.0 * ((double)(y+1) / (double)(total)));
         if ( curPct != oldPct ) {
            cout << "\rProcessing Sample " << dec << setw(6) << y+1;
            cout << " out of " << dec << setw(6) << total;
            cout << " " << dec << setw(3) << curPct << " %" << flush;
            oldPct = curPct;
         }

         // Get sample & Train Number
         sample  = runRead->getSample(y);
         event   = sample->getTrainNum();
         channel = sample->getKpixChannel();

         // Detect a new train. If detected fill sample tree with stored values
         if ( event != lastEvent && lastEvent != -1 ) sampleTree->Fill();
         lastEvent = event;

         // Only store bucket 0
         if ( sample->getKpixBucket() == 0 ) {
            if ( gain[channel] != 0 ) {
               charge[channel] = (sample->getSampleValue() - icept[channel]) / gain[channel];
               time[channel]   = sample->getSampleTime();
            }
            else {
               charge[channel] = 0;
               time[channel]   = 0;
            }
         }
      }

      // Fill One last Time
      sampleTree->Fill();

      // Close file
      delete runRead;
      cout << endl;
   }

   // Close File
   outRoot->cd("/");
   sampleTree->Write();
   outRoot->Close();
   delete outRoot;

   // Log
   cout << "Done\n";
   cout << "Wrote Data To: " << argv[1] << "\n";
}

