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
   double        minVal[9];
   double        maxVal[9];

   TApplication theApp("App",NULL,NULL);
   gStyle->SetOptFit(1111);
   gStyle->SetOptStat(111111111);

   // Check args
   if ( argc != 2 ) {
      cout << "Usage: readExample datafile.bin" << endl;
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
      hist[x] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8191);
      tmp.str("");
      minVal[x] = 8191;
      maxVal[x] = 0;
   }

   // Process each event
   count = 0;
   while ( dataRead.next(&event) ) {

      // Get serial numbers after first record
      if ( count == 0 ) {
         for (x=0; x < 32; x++) {
            tmp.str("");
            tmp << "cntrlFpga(0):kpixAsic(" << dec << x << "):SerialNumber";
            serialList[x] = dataRead.getConfig(tmp.str());
         }
      }

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         // Get serial number
         if ( sample->getKpixAddress() < 32 ) serial = serialList[sample->getKpixAddress()];
         else serial = "";

         // Get sample data
         addr   = sample->getKpixAddress();
         bucket = sample->getKpixBucket();
         time   = sample->getSampleTime();
         range  = sample->getSampleRange();

         // Do something if this is a data sample
         if ( sample->getSampleType() == KpixSample::Data ) {

            charge = sample->getSampleValue();

            // Time cut
            if ( bucket == 0 && time == 752 ) {
               hist[addr]->Fill(charge);
               if ( minVal[addr] > charge ) minVal[addr] = charge;
               if ( maxVal[addr] < charge ) maxVal[addr] = charge;
            }
         }
      }
   }

   c1 = new TCanvas("c1","c1");
   c1->Divide(3,3,0.01,0.01);

   for( x=0; x < 9; x++ ) {
      c1->cd(x+1);
      hist[x]->GetXaxis()->SetRangeUser(minVal[x],maxVal[x]);
      hist[x]->Draw();
   }

   c1->Print("beam_plots_raw.ps");

   theApp.Run();

   return(0);
}

