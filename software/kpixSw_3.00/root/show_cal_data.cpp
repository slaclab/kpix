#include <iostream>
#include <iomanip>
#include <sstream>
#include <KpixCalibRead.h>
#include <TApplication.h>
#include <TFile.h>
#include <TH1F.h>
#include <TCanvas.h>
#include <TGraphErrors.h>
#include <TGraph.h>
#include <TStyle.h>
using namespace std;

// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {
   KpixCalibRead   calibRead;
   uint            channel;
   TCanvas         *c1;
   TH1F            *hist[4];
   int             bucket;
   int             range;
   char            *serial;
   char            *tag;
   char            *file;
   double          min[4];
   double          max[4];
   double          value[4];
   stringstream    name;

   gStyle->SetOptStat(kFALSE);

   // Start X11 view
   TApplication theApp("App",NULL,NULL);

   if ( argc != 5 ) {
      cout << "Usage: show_cal_data serial range value file.xml\n";
      return(1);
   }
   serial = argv[1];
   range  = atoi(argv[2]);
   tag    = argv[3];
   file   = argv[4];

   // Open calibration file
   if ( ! calibRead.parse(file) ) {
      cout << "Error opening file" << file << endl;
      return(2);
   }

   for ( bucket = 0; bucket < 4; bucket++ ) {
      max[bucket] = -1e99;
      min[bucket] = 1e99;
   }

   // Scan data to determine range
   for ( channel = 0; channel < 1024; channel++ ) {
      for ( bucket = 0; bucket < 4; bucket++ ) {
         value[bucket] = calibRead.calibByName(serial,channel,bucket,range,tag);

         if ( value[bucket] > max[bucket] ) max[bucket] = value[bucket];
         if ( value[bucket] < min[bucket] ) min[bucket] = value[bucket];
      }
   }

   // Create histograms
   for ( bucket = 0; bucket < 4; bucket++ ) {
      name.str("");
      name << tag << "_" << bucket;

      hist[bucket] = new TH1F(name.str().c_str(),name.str().c_str(),1000,min[bucket],max[bucket]);
   }

   // Fill histograms
   for ( channel = 0; channel < 1024; channel++ ) {
      for ( bucket = 0; bucket < 4; bucket++ ) {
         value[bucket] = calibRead.calibByName(serial,channel,bucket,range,tag);
         hist[bucket]->Fill(value[bucket]);
      }
   }

   // Summary
   c1 = new TCanvas("c1","c1");
   c1->Divide(2,2,0.01,0.01);

   for ( bucket = 0; bucket < 4; bucket++ ) {
      c1->cd(bucket+1);
      hist[bucket]->Draw();
   }

   // Start X-Windows
   theApp.Run();

}
