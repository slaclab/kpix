//-----------------------------------------------------------------------------
// File          : KpixHistogram.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/15/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Class to track histograms generated in KPIX runs.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/15/2008: created
// 03/03/2009: changed container values to unsigned int
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#include <string>
#include <stdlib.h>
#include "KpixHistogram.h"
using namespace std;


// Constructor
KpixHistogram::KpixHistogram () {
   data       = NULL;
   entries    = 0;
   min        = 0;
   max        = 0;
}


// DeConstructor
KpixHistogram::~KpixHistogram ( ) { 
   if ( data != NULL ) free(data);
}


// Add an entry
void KpixHistogram::fill(unsigned int value) {
   unsigned int *newData;
   unsigned int newEntries;
   unsigned int x,diff;

   // First entry is added
   if ( data == NULL ) {
      data = (unsigned int *) malloc(sizeof(unsigned int));
      if ( data == NULL ) throw(string("KpixHistogram::fill -> Malloc Error"));
      data[0] = 1;
      entries = 1;
      min     = value;
      max     = value;
   } else {

      // Entry is lower than the min value
      if ( value < min ) {
         diff = min-value;
         newEntries = entries + diff;
         newData = (unsigned int *) malloc(newEntries * sizeof(unsigned int));
         if ( newData == NULL ) throw(string("KpixHistogram::fill -> Malloc Error"));
         for (x=0; x < diff; x++) newData[x] = 0;
         for (x=0; x < entries; x++) newData[x+diff] = data[x];
         free(data);
         data    = newData;
         entries = newEntries;
         min     = value;
      }

      // Entry is larger than the max value
      else if ( value > max ) {
         diff = value-max;
         newEntries = entries + diff;
         newData = (unsigned int *) malloc(newEntries * sizeof(unsigned int));
         if ( newData == NULL ) throw(string("KpixHistogram::fill -> Malloc Error"));
         for (x=0; x < entries; x++) newData[x] = data[x];
         for (x=0; x < diff; x++) newData[x+entries] = 0;
         free(data);
         data    = newData;
         entries = newEntries;
         max     = value;
      }

      // Add new entry
      data[value-min]++;
   }
}


// Get Number Of Entries
unsigned int KpixHistogram::binCount() { return(entries); }


// Get Min Value
unsigned int KpixHistogram::minValue() { return(min); }


// Get Max Value
unsigned int KpixHistogram::maxValue() { return(max); }


// Get Bin Value
unsigned int KpixHistogram::value(unsigned int bin) { 
   if ( bin < entries ) return(min+bin);
   else return(0);
}


// Get Bin Count
unsigned int KpixHistogram::count(unsigned int bin) { 
   if ( bin < entries ) return(data[bin]);
   else return(0);
}
