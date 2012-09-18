#include <iostream>
#include <iomanip>
#include <KpixRunRead.h>
#include <KpixCalibRead.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include <KpixRunVar.h>
#include <KpixSample.h>
#include <KpixEventVar.h>
#include <TFile.h>
using namespace std;

// Process the data
int main ( int argc, char **argv ) {

   KpixRunRead     *runRead;
   KpixSample      *sample;
   int             x, count;
   double          calCharge[4];

   // Root file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: simRead file.root\n";
      return(1);
   }

   // Attempt to open root file using KpixRunRead class
   try {
      runRead  = new KpixRunRead(argv[1],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }


   // Get simulation charge
   runRead->getAsic(0)->getCalibCharges(calCharge);
   cout << "Calibration Charge = " << calCharge[0] << endl;

   // Get data
   try {

      // Here we read the number of samples contained in the root file
      count = runRead->getSampleCount();
      cout << endl << "Found " << dec << count << " Samples In the File" << endl;

      // Iterate through each sample serially
      for ( x=0; x < count; x++ ) {

         // Get the sample.
         sample = runRead->getSample(x);

         // Temp value
         if ( sample->getSpecial() == 1 ) {
            cout << "Temp Value = " << KpixAsic::convertTemp(sample->getSampleValue());
            cout << " (0x" << hex << sample->getSampleValue() << ")" << endl;
         }

         // Normal record
         else if ( sample->getEmpty() == 0 ) {
            cout << "Channel= " << dec << setw(4) << setfill('0') << sample->getKpixChannel();
            cout << ", Bucket= " << dec << setw(1) << setfill('0') << sample->getKpixBucket();
            cout << ", Time= " << dec << setw(4) << setfill('0') << sample->getSampleTime();
            cout << ", Range= " << dec << setw(1) << setfill('0') << sample->getSampleRange();
            cout << ", Trig= " << dec << setw(1) << setfill('0') << sample->getTrigType();
            cout << ", Value= " << dec << setw(4) << setfill('0') << sample->getSampleValue() << endl;
         }
      }
   } catch ( string error ) {
      cout << "Error extracting Events:\n";
      cout << error << "\n";
      return(1);
   }

   // Delete the created classes when done
   delete(runRead);
}
