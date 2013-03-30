#include <KpixEvent.h>
#include <KpixSample.h>
#include <KpixCalibRead.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <Data.h>
#include <DataRead.h>
using namespace std;

int main (int argc, char **argv) {
   DataRead      dataRead;
   KpixEvent     event;
   KpixSample    *sample;
   KpixCalibRead calibRead;
   uint          x;
   double        mean;
   double        gain;
   double        charge;
   uint          count;
   stringstream  tmp;
   string        serialList[32];
   string        serial;
   uint          hitCount[32][1024][4];
   uint          kpix, chan, buck;

   // Check args
   if ( argc != 2 ) {
      cout << "Usage: hitMap datafile.bin" << endl;
      return(1);
   }

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening file " << argv[1] << endl;
      return(2);
   }

   for ( kpix = 0; kpix < 32; kpix++ ) {
      for ( chan = 0; chan < 1024; chan++ ) {
         for ( buck = 0; buck < 4; buck++ ) {
            hitCount[kpix][chan][buck] = 0;
         }
      }
   }


   // Process each event
   count = 0;
   while ( dataRead.next(&event) ) {

      // Iterate through samples
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample = event.sample(x);

         hitCount[sample->getKpixAddress()][sample->getKpixChannel()][sample->getKpixBucket()]++;
      }
   }

   for ( kpix = 0; kpix < 32; kpix++ ) {
      for ( chan = 0; chan < 1024; chan++ ) {
         for ( buck = 0; buck < 4; buck++ ) {
            cout << "Kpix=" << dec << kpix << ", Channel=" << dec << chan;
            cout << " b0=" << dec << hitCount[kpix][chan][0];
            cout << " b1=" << dec << hitCount[kpix][chan][1];
            cout << " b2=" << dec << hitCount[kpix][chan][2];
            cout << " b3=" << dec << hitCount[kpix][chan][3];
            cout << endl;
         }
      }
   }

   return(0);
}

