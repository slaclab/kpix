//-----------------------------------------------------------------------------
// File          : cspadGui.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : CSPAD
//-----------------------------------------------------------------------------
// Description :
// Server application for GUI
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//----------------------------------------------------------------------------
#include <OptoFpgaLink.h>
#include <KpixControl.h>
#include <ControlServer.h>
#include <Device.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <signal.h>
using namespace std;

int main (int argc, char **argv) {
   OptoFpgaLink  optoLink; 
   KpixControl   kpix(KpixControl::Opto,&optoLink);

   try {

      // Create and setup PGP link
      optoLink.setMaxRxTx(500000);
      optoLink.setDebug(true);
      optoLink.open("/dev/ttyUSB0");
      usleep(100);

      // Test
      cout << "Fgga Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("kpixFpga",0)->readSingle("VersionMastReset") << endl;
      cout << "Kpix Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("kpixFpga",0)->device("kpixAsic",3)->readSingle("Status") << endl;
      cout << "Kpix Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("kpixFpga",0)->device("kpixAsic",0)->readSingle("Status") << endl;

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
   }
}

