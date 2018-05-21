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
   KpixCalibRead calibRead;
   uint          x;
   double        mean;
   double        gain;
   double        charge;
   uint          count;
   uint          channel;
   stringstream  tmp;
   string        serialList[32];
   string        serial;
   TH1F        * hist[4];
   uint          addr;
   uint          bucket;
   uint          time;
   uint          range;
   TCanvas     * c1;

   TApplication theApp("App",NULL,NULL);
   gStyle->SetOptFit(1111);
   gStyle->SetOptStat(111111111);

   // Check args
   if ( argc < 3 ) {
      cout << "Usage: beamChannels datafile.bin calibFile.xml" << endl;
      return(1);
   }

   // Attempt to open  calibration file
   calibRead.parse(argv[2]);
   cout << "Read calibration data from " << argv[2] << endl;

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening file " << argv[1] << endl;
      return(2);
   }

   // Init plot
   for( x=0; x < 9; x++ ) {
      tmp.str("");
      tmp << "layer " << dec << x;
      hist[x] = new TH1F(tmp.str().c_str(),tmp.str().c_str(),1000,-500e-15,500e-15);
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
         addr    = sample->getKpixAddress();
         bucket  = sample->getKpixBucket();
         time    = sample->getSampleTime();
         range   = sample->getSampleRange();
         channel = sample->getKpixChannel();

         // Do something if this is a data sample
         if ( sample->getSampleType() == KpixSample::Data ) {

            mean = calibRead.baseFitMean(serial,channel,bucket,range);

            gain = calibRead.calibGain(serial,channel,bucket,range);

            charge = (sample->getSampleValue() - mean ) / gain;

            if ( addr == 7 && range == 0 && bucket == 0 && time == 752 ) {
               if ( channel == 332 ) hist[0]->Fill(charge);
               if ( channel == 334 ) hist[1]->Fill(charge);
            }
         }
      }
   }

   c1 = new TCanvas("c1","c1");
   c1->Divide(1,2,0.01,0.01);

   for( x=0; x < 2; x++ ) {
      c1->cd(x+1);
      hist[x]->GetXaxis()->SetRangeUser(-25e-15,25e-15);
      hist[x]->Draw();
   }

   c1->Print("beam_chan.ps");
   system("ps2pdf beam_chan.ps");

   theApp.Run();

   return(0);
}

