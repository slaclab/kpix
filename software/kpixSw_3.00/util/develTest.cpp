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
#include <UdpLink.h>
#include <KpixControl.h>
#include <ControlServer.h>
#include <Device.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <signal.h>
using namespace std;

int main (int argc, char **argv) {
   UdpLink     udpLink; 
   KpixControl kpix(&udpLink);

   try {

      // Create and setup PGP link
      udpLink.setMaxRxTx(500000);
      udpLink.setDebug(true);
      udpLink.open(8192,1,"192.168.1.16");
      usleep(100);

      // Test
      cout << "Fgga Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("cntrlFpga",0)->readSingle("Version") << endl;
      cout << "Kpix Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("cntrlFpga",0)->device("kpixAsic",3)->readSingle("Status") << endl;
      cout << "Kpix Version: 0x" << hex << setw(8) << setfill('0') << kpix.device("cntrlFpga",0)->device("kpixAsic",0)->readSingle("Status") << endl;

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
   }
}

