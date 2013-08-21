#include <KpixEvent.h>
#include <KpixSample.h>
#include <KpixCalibRead.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <Data.h>
#include <DataRead.h>
#include <TH1F.h>
#include <TCanvas.h>
#include <TApplication.h>
#include <TStyle.h>
using namespace std;

int main (int argc, char **argv) {
   DataRead      dataRead;
   KpixEvent     event;
   KpixSample  * sample;
   uint          x;
   double        mean;
   double        gain;
   double        charge;
   uint          count;
   stringstream  tmp;
   string        serialList[32];
   string        serial;
   TH1F        * hist[9];
   uint          addr;
   uint          bucket;
   uint          time;
   uint          range;
   TCanvas     * c1;
   double        meanNn;
   uint          channel;

   TApplication theApp("App",NULL,NULL);
   gStyle->SetOptFit(1111);
   gStyle->SetOptStat(111111111);

   // Check args
   if ( argc != 2 ) {
      cout << "Usage: beamHits datafile.bin" << endl;
      return(1);
   }

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening file " << argv[1] << endl;
      return(2);
   }

   // Init plot
   for( x=0; x < 9; x++ ) {
      tmp.str("");
      tmp << "layer " << dec << x;
      hist[x] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),1024,0,1023);
   }

   // Process each event
   count = 0;
   while ( dataRead.next(&event) ) {

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         // Get sample data
         addr    = sample->getKpixAddress();
         bucket  = sample->getKpixBucket();
         time    = sample->getSampleTime();
         range   = sample->getSampleRange();
         channel = sample->getKpixChannel();

         // Do something if this is a data sample
         if ( sample->getSampleType() == KpixSample::Data ) {

            if ( range == 0 && bucket == 0 && time == 752 ) hist[addr]->Fill(channel);
         }
      }
   }

   c1 = new TCanvas("c1","c1");
   c1->Divide(3,3,0.01,0.01);

   for( x=0; x < 9; x++ ) {
      c1->cd(x+1);
      hist[x]->Draw();
   }

   c1->Print("beam_hits.ps");
   system("ps2pdf beam_hits.ps");

   theApp.Run();

   return(0);
}

