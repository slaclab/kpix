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
   TH2F            *histAll;
   double          histMin;
   double          histMax;
   DataRead        dataRead;
   KpixEvent       event;
   KpixSample      *sample;
   uint            x;
   uint            channel;
   uint            bucket;
   uint            value;
   uint            type;
   TCanvas         *c1;

   gStyle->SetOptStat(kFALSE);
   TApplication theApp("App",NULL,NULL);

   // Data file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: showHits data_file\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }

   // Histogram
   histAll = new TH2F("Value_Hist","Value_Hist",8192,0,8191,1024,0,1023);
   histMin  = 8192;
   histMax  = 0;

   // Process each event
   while ( dataRead.next(&event) ) {

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data ) {
            histAll->Fill(value,channel);
            if ( value > histMax ) histMax = value;
            if ( value < histMin ) histMin = value;
         }
      }
   }

   // Default canvas
   c1 = new TCanvas("c1","c1");
   histAll->GetXaxis()->SetRangeUser(histMin-1,histMax+1);
   histAll->Draw("colz");

   theApp.Run();
   return(0);
}

