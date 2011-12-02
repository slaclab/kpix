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
#include <PgpLink.h>
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
   stop = true;
   cout << "Stopping gui server" << endl;
}

int main (int argc, char **argv) {
   PgpLink       pgpLink; 
   CommLink      commLink; 
   KpixControl   kpix(KpixControl::Opto);
   ControlServer cntrlServer;
   string        xmlTest;
   int           pid;

   // Catch signals
   signal (SIGINT,&sigTerm);
   cout << "Starting gui server" << endl;

   try {

      // Setup top level device
      //cspad.setDebug(true,true);

      if ( argc > 1 ) {

         // Create and setup PGP link
         //commLink.setDebug(true);
         commLink.setMaxRxTx(500000);
         commLink.open();
         kpix.setCommLink(&commLink);
         cout << "Using debug interface" << endl;

      } else {

         // Create and setup PGP link
         pgpLink.setMaxRxTx(500000);
         pgpLink.setDebug(true);
         pgpLink.open("/dev/pgpcard0");
         usleep(100);
         kpix.setCommLink(&pgpLink);
         cout << "Using PGP interface" << endl;
      }

      // Setup control server
      //cntrlServer.setDebug(true);
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
            cout << "Starting GUI" << endl;
            system("cntrlGui");
            cout << "Gui stopped" << endl;
            kill(getppid(),SIGINT);
            break;

         // Server
         default:
            while ( ! stop ) cntrlServer.receive(100);
            kill(pid,SIGINT);
            sleep(1);
            cntrlServer.stopListen();
            cout << "Stopped gui server" << endl;
            break;
      }

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error;
      cntrlServer.stopListen();
   }
}

