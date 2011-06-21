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
// Copyright (c) 2009 by SLAC. All rights reserved.
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
// 05/13/2009: Added special data flag for Temp value and trigger log.
// 05/13/2009: Removed Accept Flag.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
// 09/11/2009: Added max sample constant.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include "../offline/KpixSample.h"
#include "KpixBunchTrain.h"
#include "SidLink.h"
#include "../offline/KpixAsic.h"
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
KpixBunchTrain::KpixBunchTrain ( SidLink *link, bool debug, unsigned int asicCnt, KpixAsic **asics ) {

   // Local variables
   unsigned short checkSum;
   unsigned int   x;
   unsigned int   address;
   unsigned int   channel;
   unsigned int   bucket;
   unsigned int   time;
   unsigned int   adc;
   unsigned int   range;
   unsigned int   badCount;
   unsigned int   trigType;
   unsigned int   empty;
   unsigned int   special;
   unsigned short data[MaxSamples*3+10];
   bool           frameMask[8];
   unsigned int   idx;
   unsigned int   subCnt;
   int            eof;
   stringstream   error;

   // Determine how many frames we need to retrieve
   for (idx=0; idx < 8; idx++) frameMask[idx] = false;
   if ( asicCnt == 0 ) frameMask[0] = true;
   else {
      for (idx=0; idx < asicCnt; idx++) {
         if (      asics[idx]->getAddress() < 4  ) frameMask[0] = true;
         else if ( asics[idx]->getAddress() < 8  ) frameMask[1] = true;
         else if ( asics[idx]->getAddress() < 12 ) frameMask[2] = true;
         else if ( asics[idx]->getAddress() < 16 ) frameMask[3] = true;
         else if ( asics[idx]->getAddress() < 20 ) frameMask[4] = true;
         else if ( asics[idx]->getAddress() < 24 ) frameMask[5] = true;
         else if ( asics[idx]->getAddress() < 28 ) frameMask[6] = true;
         else if ( asics[idx]->getAddress() < 32 ) frameMask[7] = true;
      }
   }
     
   totalCount = 0;
   deadCount = 0;
   parErrors = 0;
   lastTrain = false;

   for ( idx=0; idx < 8; idx++ ) if ( frameMask[idx] ) {

      // Debug
      if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> Creating new bunchTrain. Idx=" << dec << idx << "\n";

      // Get header first
      link->linkDataRead(data,2,true,&eof);
      if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> Read Header.\n";
      subCnt = 0;

      // Keep going until we got all of the samples
      while ( 1 ) {

         // Read three words
         link->linkDataRead(&(data[subCnt*3+2]),3,false,&eof);
         if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> Read Sample. Count=" << dec << subCnt << "\n";

         // Is this the end?
         if ((data[subCnt*3+2] & 0x8000) != 0 ) break;

         // Detect overrun of frame data
         if ( totalCount == MaxSamples ) {
            for ( x=0; x < totalCount; x++) delete samplesByTime[x];
            totalCount = 0;
            link->linkFlush();
            throw(string("KpixBunchTrain::KpixBunchTrain -> Sample Overrun"));
         }
         subCnt++;
      }

      // Store train sequence number
      trainNumber  = data[0];
      trainNumber |= (data[1] << 16) & 0xFFFF0000;

      // Debug
      if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> Got Header. Train Number=" << dec << trainNumber << endl;

      // Init checksum
      checkSum = data[0] + data[1];

      // Keep going until we got all of the samples
      for (x=0; x<subCnt; x++) {

         // Add to checksum
         checkSum += data[x*3+2+0];
         checkSum += data[x*3+2+1];
         checkSum += data[x*3+2+2];

         // Double check marker
         if ( (data[x*3+2+0] & 0xC000) != 0x4000 ) {
            if ( debug ) cout << "KpixBunchTrain::KpixBunchTrain -> Found Bad Marker.\n";
            continue;
         }

         // Extract sample data

         // Word 0
         bucket   = (data[x*3+2+0] >> 12) & 0x0003;
         address  = (data[x*3+2+0] >> 10) & 0x0003;
         channel  = data[x*3+2+0] & 0x03FF;

         // Word 1
         special  = (data[x*3+2+1] >> 15) & 0x1;
         range    = (data[x*3+2+1] >> 13) & 0x0001;
         empty    = (data[x*3+2+1] >> 12) & 0x1;
         time     = data[x*3+2+1] & 0x0FFF;
         time    += (data[x*3+2+1] >> 2) & 0x1000; // Time Bit Expansion, Bit 14

         // Word 2
         //       = (data[2] >> 15) & 0x1; // Future
         trigType = (data[x*3+2+2] >> 14) & 0x1;
         badCount = (data[x*3+2+2] >> 13) & 0x1;
         adc      = data[x*3+2+2] & 0x1FFF;

         // Create a new Kpix Event
         samplesByTime[totalCount] = 
            new KpixSample(address,channel,bucket,range,time,adc,trainNumber,empty,badCount,trigType,special,debug);
         totalCount++;
      }

      // Add last two values to checksum
      checkSum += data[subCnt*3+2+0];
      checkSum += data[subCnt*3+2+1];

      // Check checksum
      //if ( checkSum != data[subCnt*3+2+2] ) {
         //error.str("");
         //error << "KpixBunchTrain::KpixBunchTrain -> Checksum Error. SubCount=" << dec << subCnt;
         //error << ", Rec=0x" << setw(4) << setfill('0') << data[subCnt*3+2+2];
         //error << ", Comp=0x" << setw(4) << setfill('0') << checkSum;
         //for ( x=0; x < totalCount; x++) delete samplesByTime[x];
         //totalCount = 0;
         //throw(error.str());
      //}

      // Check count either 1x events (old fpag) or 3x events (new fpga)
      if ( (subCnt*3) != (unsigned int)(data[subCnt*3+2+0] & 0x7FFF) ) {
         for ( x=0; x < totalCount; x++) delete samplesByTime[x];
         error.str("");
         error << "KpixBunchTrain::KpixBunchTrain -> Sample Count Mismatch. ";
         error << "Got=" << dec << (unsigned int)(data[subCnt*3+2+0] & 0x7FFF);
         error << ", Exp=" << dec << (subCnt*3);
         totalCount = 0;
         throw(error.str());
      }

      // Dead time counter
      deadCount += data[subCnt*3+2+1] & 0x1FFF;

      // Parity error count
      parErrors += (data[subCnt*3+2+1] >> 13) & 0x1;

      // last train flag
      if ( (data[subCnt*3+2+1] & 0x8000) == 0 ) lastTrain = true;

      // Debug
      if ( debug ) {
         cout << "KpixBunchTrain::KpixBunchTrain -> Got Tail. Idx=" << dec << idx;
         cout << ", Last Train=" << dec << setw(1) << lastTrain;
         cout << ", Dead Count=" << dec << deadCount << ", Errors=" << dec << parErrors;
         cout << ", Sub Count=" << dec << subCnt;
         cout << ", Total Count=" << dec << totalCount << endl;
      }
   }

   // Set last entry to NULL
   samplesByTime[totalCount] = NULL;

   // Sort sample list by time
   if ( totalCount > 0 ) 
      qsort(samplesByTime,totalCount,sizeof(KpixSample *),&(compareSamples));

   // Throw exception on parity errors
   if ( parErrors > 0 ) throw(string("KpixBunchTrain::KpixBunchTrain -> Errors Detected."));

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


