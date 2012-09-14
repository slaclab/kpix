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
#include <SimLink.h>
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
   uint          shmId;

   if ( argc == 1 ) {
      cout << "Usage: simLink smem_id [default.xml]" << endl;
      return(1);
   }
   shmId = atoi(argv[1]);

   if ( argc > 2 ) defFile = argv[2];
   else defFile = "";

   // Catch signals
   signal (SIGINT,&sigTerm);

   try {
      SimLink       simLink; 
      KpixControl   kpix(&simLink,defFile);
      int           pid;

      // Setup top level device
      kpix.setDebug(true);

      // Create and setup PGP link
      simLink.setMaxRxTx(500000);
      simLink.setDebug(true);
      simLink.open(shmId);
      usleep(100);

      // Setup control server
      cntrlServer.setDebug(true);
      cntrlServer.startListen(8092);
      cntrlServer.setSystem(&kpix);

      // Fork and start gui
      stop = false;
      switch (pid = fork()) {

         // Error
         case -1:
            cout << "Error occured in fork!" << endl;
            return(1);
            break;

         // Child
         case 0:
            usleep(100);
            cout << "Starting GUI" << endl;
            system("cntrlGui");
            cout << "GUI stopped" << endl;
            kill(getppid(),SIGINT);
            break;

         // Server
         default:
            cout << "Starting server" << endl;
            while ( ! stop ) cntrlServer.receive(100);
            cout << "Stopping GUI" << endl;
            system("killall cntrlGui");
            sleep(1);
            cntrlServer.stopListen();
            cout << "Stopped server" << endl;
            break;
      }

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
      cntrlServer.stopListen();
   }
}

