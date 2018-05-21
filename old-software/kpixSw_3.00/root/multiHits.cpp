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

// Process the data
int main ( int argc, char **argv ) {
   DataRead        dataRead;
   KpixEvent       event;
   KpixSample      *sample;
   uint            x;
   uint            b0Cnt;
   uint            b1Cnt;
   uint            b2Cnt;
   uint            b3Cnt;
   uint            channel;
   uint            bucket;
   uint            value;
   uint            type;
   uint            time;
   uint            ser;

   //gStyle->SetOptStat(kFALSE);
   //TApplication theApp("App",NULL,NULL);

   // Data file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: multiHits data_file\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }

   // Process each event
   ser = 0;
   while ( dataRead.next(&event) ) {
      b0Cnt = 0;
      b1Cnt = 0;
      b2Cnt = 0;
      b3Cnt = 0;
      ser++;

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         time    = sample->getSampleTime();
         type    = sample->getSampleType();

         // Data samples
         if ( type == KpixSample::Data ) {

            // Strange Samples
            if (   sample->getBadCount() ) cout << "Bad count" << endl;
            if (   sample->getEmpty()    ) cout << "Empty    " << endl;
            if ( ! sample->getTrigType() ) cout << "Ext trig " << endl;

            if ( bucket == 0 ) b0Cnt++;
            if ( bucket == 1 ) b1Cnt++;
            if ( bucket == 2 ) b2Cnt++;
            if ( bucket == 3 ) b3Cnt++;
         }
      }

      if ( b0Cnt > 200 ) {
         cout << "Got large event:";
         cout << " ser=" << dec << ser;
         cout << " b0=" << dec << b0Cnt;
         cout << " b1=" << dec << b1Cnt;
         cout << " b2=" << dec << b2Cnt;
         cout << " b3=" << dec << b3Cnt;
         if ( b0Cnt != 911 ) cout << "   *";
         cout << endl;
      }
   }

   //theApp.Run();
   return(0);
}

   //TH2F            *histAll;
   //double          histMin;
   //double          histMax;
   //TCanvas         *c1;

   // Default canvas
   //c1 = new TCanvas("c1","c1");
   //histAll->GetXaxis()->SetRangeUser(histMin-1,histMax+1);
   //histAll->Draw("colz");

