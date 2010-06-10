//-----------------------------------------------------------------------------
// File          : test.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 07/06/2009
//-----------------------------------------------------------------------------
// Description :
// Source code for test.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/06/2009: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include "lib/SidLink.h"
#include "lib/AdcFpga.h"
using namespace std;

// Main Function
int main ( int argc, char **argv ) {

   try {

      SidLink *sidLink;
      AdcFpga *adcFpga;

      // Open link
      sidLink = new SidLink();
      sidLink->linkOpen ( "/dev/com4" );

      // Create FPGA object
      adcFpga = new AdcFpga(sidLink);

      // Read Version
      cout << "Version=0x" << hex << setw(8) << setfill('0') << adcFpga->getVersion() << endl;

      while (1) {

         // Get ADC Data
         cout << "ADC Value=0x" << hex << setw(3) << setfill('0') << adcFpga->getAdcValue() << endl;

         sleep (1);
      }

   } catch ( string error ) {
      cout << "Error: " << error << endl;
   }
}

