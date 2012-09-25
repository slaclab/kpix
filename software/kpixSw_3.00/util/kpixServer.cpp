//-----------------------------------------------------------------------------
// File          : kpixServer.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Kpix
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

// Run flag for sig catch
bool stop;

// Function to catch cntrl-c
void sigTerm (int) { 
   cout << "Got Signal!" << endl;
   stop = true; 
}

int main (int argc, char **argv) {
   ControlServer cntrlServer;
   string        defFile;
   int           port;

   if ( argc > 1 ) defFile = argv[1];
   else defFile = "";

   // Catch signals
   signal (SIGINT,&sigTerm);

   try {
      UdpLink       udpLink; 
      KpixControl   kpix(&udpLink,defFile);

      // Setup top level device
      kpix.setDebug(true);

      // Create and setup PGP link
      udpLink.setMaxRxTx(500000);
      udpLink.setDebug(true);
      udpLink.open(8192,1,"192.168.1.16");
      udpLink.openDataNet("127.0.0.1",8099);
      usleep(100);

      // Setup control server
      //cntrlServer.setDebug(true);
      cntrlServer.enableShared(1);
      port = cntrlServer.startListen(0);
      cntrlServer.setSystem(&kpix);
      cout << "Control id = 1" << endl;

      cout << "Starting server at port " << dec << port << endl;
      while ( ! stop ) cntrlServer.receive(100);
      cntrlServer.stopListen();
      cout << "Stopped server" << endl;

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
      cntrlServer.stopListen();
   }
}

