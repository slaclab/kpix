//-----------------------------------------------------------------------------
// File          : KpixEvent.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : KPIX Data acquisition
//-----------------------------------------------------------------------------
// Description :
// Event Container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <string>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "KpixEvent.h"
using namespace std;

// Constructor
KpixEvent::KpixEvent () : Data() {
   word_        = NULL;
   trainNumber_ = 0;
   count_       = 0;
   deadCount_   = 0;
}

// Deconstructor
KpixEvent::~KpixEvent () { }

// Update pointers
void KpixEvent::update() {
   uint         x;
   ushort       csum;
   stringstream error;
   error.str("");

   // Set pointer
   word_ = (ushort *)data_;

   // Get train number
   trainNumber_  = word_[0];
   trainNumber_ |= (word_[0] << 16) & 0xFFFF0000;

   // Init markers
   x      = 2;
   count_ = 0;
   csum   = word_[0] + word_[1];

   // process each sample looking for tail
   while ( (word_[x] & 0x8000) == 0 ) {

      // Check for overrun
      if ( (x+3) > (size_*2) ) {
         error << "KpixEvent::update -> Bad data alignment";
         cout << error.str() << endl;
         throw(error.str());
      }

      // Update checksum and count
      csum += word_[x] + word_[x+1] + word_[x+2];
      count_++;
      x += 3;
   }

   // last two values added to checksum
   csum += word_[x] + word_[x+1];

   // Check checksum
   if ( csum != word_[x+2] ) {
      error << "KpixEvent::update -> Checksum Error.";
      cout << error.str() << endl;
      throw(error.str());
   }

   // Check count = 3x events (new fpga)
   if ( (count_*3) != (word_[x] & 0x7FFF) ) {
      error << "KpixEvent::update -> Sample Count Mismatch. ";
      error << "Got=" << dec << (word_[x] & 0x7FFF);
      error << ", Exp=" << dec << (count_*3);
      cout << error.str() << endl;
      throw(error.str());
   }

   // Check for parity error
   if ( (word_[x+1] & 0x2000) != 0 ) {
      error << "KpixEvent::update -> Parity error detected";
      cout << error.str() << endl;
      throw(error.str());
   }
    
   // Update tail values
   deadCount_ = word_[x+1] & 0x1FFF;
}

// Get train number
uint KpixEvent::trainNumber ( ) {
   return(trainNumber_);
}

// Get sample count
uint KpixEvent::count ( ) {
   return(count_);
}

// Get dead count
uint KpixEvent::deadCount ( ) {
   return(deadCount_);
}

// Get sample at index
KpixSample *KpixEvent::sample (uint index) {
   if ( index >= count_ ) return(NULL);
   else {
      sample_.setData(&(word_[headSize_+(index*sampleSize_)]),trainNumber_);
      return(&sample_);
   }
}

// Get sample at index
KpixSample *KpixEvent::sampleCopy (uint index) {
   KpixSample *tmp;

   if ( index >= count_ ) return(NULL);
   else {
      tmp = new KpixSample (&(word_[headSize_+(index*sampleSize_)]),trainNumber_);
      return(tmp);
   }
}

