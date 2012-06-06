//-----------------------------------------------------------------------------
// File          : dumpSettingsXml.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : Kpix DAQ
//-----------------------------------------------------------------------------
// Description :
// Dump xml settings
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//----------------------------------------------------------------------------
#include <KpixEvent.h>
#include <KpixSample.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <Data.h>
#include <DataRead.h>
using namespace std;

int main (int argc, char **argv) {
   DataRead   dataRead;
   KpixEvent  event;

   // Check args
   if ( argc != 2 ) {
      cout << "Usage: dumpSettings filename" << endl;
      return(1);
   }

   // Attempt to open data file
   if ( ! dataRead.open(argv[1]) ) return(2);

   // Process each event
   while ( dataRead.next(&event) );

   // Dump config
   cout << dataRead.getConfigXml();

   return(0);
}

