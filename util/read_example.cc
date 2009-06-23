//-----------------------------------------------------------------------------
// File          : read_example.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/31/2008
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// Example file to demonstrate reading from a KPIX root file.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/31/2008: created
// 06/22/2009: Added namespace.
//-----------------------------------------------------------------------------
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
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {

   KpixRunRead     *runRead;
   KpixAsic        *asic;
   KpixFpga        *fpga;
   KpixEventVar    *eventVar;
   KpixRunVar      *runVar;
   KpixSample      *sample;
   KpixCalibRead   *calibRead;
   double          gain,icept;
   bool            status;
   int             x, y, count;
   int             timeCount, trainCount;
   int             lastTime, lastTrain;

   // Root file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: read_example file.root\n";
      return(1);
   }

   // Attempt to open root file using KpixRunRead class
   // The second arg to the run read file controls debugging.
   try {
      runRead  = new KpixRunRead(argv[1],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }

   // Once the run read file is open you have access to all the
   // data stored in the run. This includes the strings which
   // describe the run as well as the KpixAsic and KpixFpga
   // classes which contain the hardware configurion for the
   // run. In the example below a few run attributes are
   // displayed as an example.
   cout << "   Run Name: " << runRead->getRunName() << endl;
   cout << "   Run Time: " << runRead->getRunTime() << endl;
   cout << "   End Time: " << runRead->getEndTime() << endl;
   cout << "   Cal Time: " << runRead->getRunCalib() << endl;
   cout << "   Duration: " << runRead->getRunDuration() << endl;
   cout << "Description: " << runRead->getRunDescription() << endl;

   // In addition to using the KpixRunRead class to access the root file
   // you can also access the root file class directly. Here we do an
   // ls of the root file base directory.
   cout << endl << "Listing Root File Directory Contents" << endl;
   runRead->treeFile->ls();
   cout << endl;

   // Below is an example of reading data from the support FPGA.
   // The false flag in the read statement indicates that we don't
   // want to really read from hardware. Data from the class is read
   // instead. If false is not provided an exception will be thrown
   // since no hardware link is open.
   fpga = runRead->getFpga();
   cout << "Fpga Clock Period=" << fpga->getClockPeriod(false) << endl;
   cout << endl;

   // We can also read information about the Asics as well. Here we read
   // the serial number, version number and polarity setting for each ASIC.
   // Again the false flag is passed when reading the polarity to indicate 
   // that we don't want to really read from hardware. 
   // Remember that the KpixAsic object with the highest index is not a true
   // KPIX ASIC but a dummy version of the digital core contained in the 
   // FPGA. It has a version number of zero and only supports certain registers.
   cout << "Number of Asics In Configuration: " << runRead->getAsicCount() << endl;
   for ( x=0; x < runRead->getAsicCount(); x++ ) {
      asic = runRead->getAsic(x);
      cout << "Reading Asic " << x << endl;
      cout << "    Serial: " << asic->getSerial() << endl;
      cout << "   Version: " << asic->getVersion() << endl;
      cout << "  Polarity: " << asic->getCntrlPosPixel(false) << endl;
   }

   // Next we will read out the run variables for this file. A run variable is
   // a mechanism to store an unlimited number of double variables in the
   // root file. These variables descrive the conditions under which the run
   // occured. These variables are set once at the start of the run and
   // remain constant during the run.
   cout << endl << "Number of Run Variables: " << runRead->getRunVarCount() << endl;
   for ( x=0; x < runRead->getRunVarCount(); x++ ) {
      runVar = runRead->getRunVar(x);
      cout << "Reading Run Varable " << x << endl;
      cout << "   Name: " << runVar->name() << endl;
      cout << "   Desc: " << runVar->description() << endl;
      cout << "  Value: " << runVar->value() << endl;
   }

   // Next we will read out the event variable key for this file. An event
   // variable is a value which can change from event to event. The 
   // KpixEventVar class contains information about the run variables 
   // related to this root file. The class contains no value field 
   // it simply describes the data stored in each sample. Each KpixSample
   // record (read later in this example) contains an array of doubles
   // to store the event variables. The number field in the KpixEventVar
   // class can be used as an index into the array.
   cout << endl << "Number of event Variables: " << runRead->getEventVarCount() << endl;
   for ( x=0; x < runRead->getEventVarCount(); x++ ) {
      eventVar = runRead->getEventVar(x);
      cout << "Reading Event Variable " << x << endl;
      cout << "   Name: " << eventVar->name() << endl;
      cout << "   Desc: " << eventVar->description() << endl;
      cout << " Number: " << eventVar->number() << endl;
   }

   // Before processing samples we may want to read the calibration constants
   // for each channel. This will allow us to convert the ADC value contained
   // in each sample to a charge value. It is common practice in the new
   // version of the API to store calibration data along with the run data in
   // the same file.
   calibRead = new KpixCalibRead(runRead);

   // Here we will read the calibration data for channel 0, bucket 0 of
   // the first KPIX. The return value will be true on success, false on fail. 
   // "ForceTrig" is the common directory for stored calibration plots.
   // We will read the values for each gain mode.
   cout << endl << "Reading Calibration Data" << endl;
   for (x=0; x<3; x++) { // 0=Low Gain, 1=Double Gain, 2=Low Gain
      status = calibRead->getCalibData(&gain,&icept,"Force_Trig",x,
                                       runRead->getAsic(0)->getSerial(),
                                       0,0); // Channel=0, bucket=0
      cout << "Mode=" << x;
      cout << ", Gain=" << gain;
      cout << ", Intercept=" << icept;
      cout << ", Status=" << status << endl;
   }
   // For normal data processing it is best to read all of the needed 
   // calibration constants at the start of processing. This way the
   // values are available as you read through the events. You don't want
   // to have to read from the root file after each event.

   // Next we will process each event in the file. The root file contains a 
   // series of events sorted by their timestamp. Each sample contains about
   // a single event bucket within a single channel. Each sample record
   // contains information about the address of the Kpix it was read from,
   // the train number in which it was read, the timestamp of the sample
   // as well as the sample's value. If one wishes to group a number of
   // samples into an event, all samples with a matching timestemp for
   // example, they would be grouped as they are read from the file.
   try {

      // Here we read the number of samples contained in the root file
      count = runRead->getSampleCount();
      cout << endl << "Found " << count << " Samples In the File" << endl;

      // Init a couple of variables we will use
      lastTime = 0; 
      lastTrain = 0;
      timeCount = 0;
      trainCount = 0;

      // Iterate through each sample serially
      for ( x=0; x < count; x++ ) {

         // Get the sample.
         sample = runRead->getSample(x);

         // Before processing the sample you may want to check to see if you
         // now in a new train or time bucket. This way you can process
         // samples in groups.

         // If we wanted to process samples by time group
         if ( x!=0 && lastTime != sample->getSampleTime() ) {

            // Here we will process samples that were read between calls to
            // this block of code. Here we simply return the number of 
            // samples in the time group.
            cout << "We found " << timeCount;
            cout << " Samples For Time " << lastTime;
            cout << " In Train " << lastTrain << endl;
            timeCount = 0;
         }

         // If we wanted to process samples by train
         if ( x!=0 && lastTrain != sample->getTrainNum() ) {

            // Here we will process samples that were read between calls to
            // this block of code. Here we simply return the number of 
            // samples in the train group.
            cout << "We found " << trainCount;
            cout << " Samples In Train " << lastTrain << endl;
            trainCount = 0;
         }

         // Once we have read the sample we can extract the information contained
         // inside it. Here we will print each variable contained in the sample.
         cout << endl << "Reading Sample " << x << endl;
         cout << "   Train Number: " << sample->getTrainNum() << endl;
         cout << "   Kpix Address: " << sample->getKpixAddress() << endl;
         cout << "   Kpix Channel: " << sample->getKpixChannel() << endl;
         cout << "    Kpix Bucket: " << sample->getKpixBucket() << endl;
         cout << "   Sample Range: " << sample->getSampleRange() << endl;
         cout << "    Sample Time: " << sample->getSampleTime() << endl;
         cout << "   Sample Value: " << sample->getSampleValue() << endl;

         // Next read the event variable values. These are just a sequence
         // of doubles contained in the sample. The name and description
         // of each sample can be determined by retrieving the associated
         // event variable from the rootRead object.
         for (y=0; y < sample->getVarCount(); y++) {
            cout << "   Sample Value: " << sample->getSampleValue() << endl;
            cout << "   Var " << dec << setw(2) << y;
            cout << " Value: " << sample->getVarValue(y) << endl;
         }

         // Increment train and time counters
         trainCount++;
         timeCount++;

         // Set last train and last time value to detect new state on next iteration
         lastTime = sample->getSampleTime();
         lastTrain = sample->getTrainNum();
      }
   } catch ( string error ) {
      cout << "Error extracting Events:\n";
      cout << error << "\n";
      return(1);
   }

   // Delete the created classes when done
   delete(calibRead);
   delete(runRead);
}
