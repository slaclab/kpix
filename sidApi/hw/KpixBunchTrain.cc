//-----------------------------------------------------------------------------
// File          : KpixBunchTrain.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to handle a Kpix bunch train contining samples.
// An array of sample objects is stored in this class. These samples
// can be retrieved either by direct channel/bucket addressing or by
// getting an list of samples sorted by time. 
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 12/01/2006: Added 32-bit sample ID, serial number as class variable
//             Add methods to store sample and sample data in file as well as
//             constructor meathod to build sample from data file.
// 03/07/2007: Added support for 4 KPIX devices. Added root support.
// 03/19/2007: Changed class name.
// 03/28/2007: Fixed event sorting function.
// 04/27/2007: Convert to new communication protocol
// 04/30/2007: Modified to throw strings instead of const char *
// 04/30/2007: Added local store of train number, ability to read.
// 08/08/2007: Added check for sample overrun.
// 08/13/2007: Added external accept flag.
// 09/19/2007: Modified width of drop count field in received from, Throw
//             exceptions on parity error detection.
// 02/27/2008: Added badCount and empty flags to received header. Now these
//             values are stored in the created sample.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include "../nohw/KpixSample.h"
#include "KpixBunchTrain.h"
#include "SidLink.h"
using namespace std;


// Function to compare entries in the sample list for sorting
int compareSamples ( const void *a, const void *b ) {
   KpixSample *ta  = *((KpixSample **)a);
   KpixSample *tb  = *((KpixSample **)b);

   // Return primarily based upon time
   if ( ta->getSampleTime() != tb->getSampleTime() ) 
      return( (ta->getSampleTime() - tb->getSampleTime()) );

   // Next sort by kpix
   if ( ta->getKpixAddress() != tb->getKpixAddress() ) 
      return( (ta->getKpixAddress() - tb->getKpixAddress()) );

   // Next sort by channel
   if ( ta->getKpixChannel() != tb->getKpixChannel() ) 
      return( (ta->getKpixChannel() - tb->getKpixChannel()) );

   // Last sort by bucket
   return( (ta->getKpixBucket() - tb->getKpixBucket()) );
}


// BunchTrain class constructor, received frame
// Pass the following values for construction
// link      = SID Link to receive data
// debug     = Debug flag
KpixBunchTrain::KpixBunchTrain ( SidLink *link, bool debug ) {

   // Local variables
   unsigned short data[3];
   unsigned short checkSum;
   unsigned int   x;
   unsigned int   address;
   unsigned int   channel;
   unsigned int   bucket;
   unsigned int   time;
   unsigned int   adc;
   unsigned int   range;
   unsigned int   badCount;
   unsigned int   empty;

   // Init sample count & pointers
   for (x=0; x < (4*64*4); x++) samplesByTime[x] = NULL;
   totalCount = 0;
   deadCount  = 0;

   // Debug
   if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> creating new bunchTrain.\n";

   // Get header first
   link->linkDataRead(data,2,true);

   // Store train sequence number
   trainNumber  = data[0];
   trainNumber |= (data[1] << 16) & 0xFFFF0000;

   // Init
   checkSum   = data[0] + data[1];
   totalCount = 0;

   // Keep going until we got all of the samples
   while ( 1 ) {

      // Read three words
      link->linkDataRead(data,3,false);

      // Is this the end?
      if ((data[0] & 0x8000) != 0 ) break;

      // Add to checksum
      checkSum += data[0];
      checkSum += data[1];
      checkSum += data[2];

      // Double check marker
      if ( (data[0] & 0xC000) != 0x4000 ) continue;
      if ( (data[1] & 0xC000) != 0x0000 ) continue;
      if ( (data[2] & 0xC000) != 0x0000 ) continue;

      // Extract sample data
      address  = (data[0] >> 10) & 0x0003;
      channel  = data[0] & 0x03FF;
      bucket   = (data[0] >> 12) & 0x0003;
      range    = (data[1] >> 13) & 0x0001;
      empty    = (data[1] >> 12) & 0x1;
      time     = data[1] & 0x0FFF;
      adc      = data[2] & 0x1FFF;
      badCount = (data[2] >> 14) & 0x1;

      // Detect overrun of frame data
      if ( totalCount == 64*4*4 ) {
         for ( x=0; x < totalCount; x++) delete samplesByTime[x];
         totalCount = 0;
         throw(string("KpixBunchTrain::KpixBunchTrain -> Sample Overrun"));
      }

      // Create a new Kpix Event
      samplesByTime[totalCount] = 
         new KpixSample(address,channel,bucket,range,time,adc,trainNumber,empty,badCount,debug);
      totalCount++;
   }

   // Add last two values to checksum
   checkSum += data[0];
   checkSum += data[1];

   // Check checksum
   if ( checkSum != data[2] ) {
      for ( x=0; x < totalCount; x++) delete samplesByTime[x];
      totalCount = 0;
      throw(string("KpixBunchTrain::KpixBunchTrain -> Checksum Error"));
   }

   // Check count
   if ( totalCount != (unsigned int)(data[0] & 0x7FFF) ) {
      for ( x=0; x < totalCount; x++) delete samplesByTime[x];
      totalCount = 0;
      throw(string("KpixBunchTrain::KpixBunchTrain -> Sample Count Mismatch"));
   }

   // Dead time counter
   deadCount = data[1] & 0x1FFF;

   // Parity error count
   parErrors = (data[1] >> 13) & 0x1;

   // Throw exception on parity errors
   if ( parErrors > 0 ) 
      throw(string("KpixBunchTrain::KpixBunchTrain -> Parity Errors Detected"));

   // last train flag
   lastTrain = (data[1] & 0x8000) == 0;

   // External Accept Flag
   extAccept = (data[1] & 0x4000) != 0;

   // Sort sample list by time
   if ( totalCount > 0 ) 
      qsort(samplesByTime,totalCount,sizeof(KpixSample *),&(compareSamples));

   // Debug
   if ( debug ) 
      cout << "KpixBunchTrain::KpixBunchTrain -> stored " << dec << totalCount << " samples.\n";
}


// Method to return an sample by KPIX/channel/bucket
// Pass KPIX serial, channel number & bucket number
KpixSample * KpixBunchTrain::getSample ( unsigned short kpix, unsigned short channel, 
                                         unsigned char bucket ) {

   unsigned int x;

   // Find the sample
   for ( x=0; x < totalCount; x++) {
      if ( samplesByTime[x]->getKpixAddress() == kpix    &&
           samplesByTime[x]->getKpixChannel() == channel &&
           samplesByTime[x]->getKpixBucket()  == bucket  ) return(samplesByTime[x]);
   }
   return(NULL);
}


// Method to return an sample list sorted by time
// Return pointer to array of 4*64*4 possible samples, unused locations point to NULL
KpixSample ** KpixBunchTrain::getSampleList ( ) { return(&samplesByTime[0]); }


// Method to return total sample count
unsigned int KpixBunchTrain::getSampleCount ( ) { return(totalCount); }


// Method to return sample count for a kpix/channel
unsigned int KpixBunchTrain::getSampleCount ( unsigned short kpix, unsigned short channel ) { 

   unsigned int count;
   unsigned int x;

   count = 0;

   // Look for matching records
   for ( x=0; x < totalCount; x++) {
      if ( samplesByTime[x]->getKpixAddress() == kpix    &&
           samplesByTime[x]->getKpixChannel() == channel ) count++;
   }
   return(count);
}


// Get dead count
unsigned int KpixBunchTrain::getDeadCount () { return(deadCount); }


// Get parity errors
unsigned int KpixBunchTrain::getParErrors () { return(parErrors); }


// Get External Accept Flag
bool KpixBunchTrain::getAcceptFlag () { return(extAccept); }


// Get last train flag
bool KpixBunchTrain::getLastTrain () { return(lastTrain); }


// Get sequence number
unsigned int KpixBunchTrain::getTrainNumber() { return(trainNumber); }


// Deconstructor
KpixBunchTrain::~KpixBunchTrain ( ) {

   unsigned int x;

   // Free all created sample objects
   for ( x=0; x < totalCount; x++) delete samplesByTime[x];
}


