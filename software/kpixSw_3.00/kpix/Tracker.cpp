//-----------------------------------------------------------------------------
// File          : Tracker.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Heavy Photon Tracker
//-----------------------------------------------------------------------------
// Description :
// Control FPGA container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#include <Tracker.h>
#include <CntrlFpga.h>
#include <TisFpga.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
Tracker::Tracker ( ) : System("Tracker") {

   // Description
   desc_ = "Tracker Control";
   
   // Data mask, lane 0, vc 0
   dataMask_ = 0x11;

   // Add sub-devices
   addDevice(new CntrlFpga(0, 0));

   // Commands
   addCommand(new Command("ApvSWTrig"));
   commands_["ApvSWTrig"]->setDescription("Generate APV software trigger + calibration.");
   variables_["RunCommand"]->set("ApvSWTrig");

   addCommand(new Command("ApvINTrig"));
   commands_["ApvINTrig"]->setDescription("Start internal trigger + calibration sequence.");
}

// Deconstructor
Tracker::~Tracker ( ) { }

// Method to process a command
string Tracker::command ( string name, string arg ) {

   if ( name == "ApvSWTrig" ) {
      device("cntrlFpga",0)->command("ApvSWTrig","");
      return(string("<ApvSWTrig>Success</ApvSWTrig>"));
   }

   else if ( name == "ApvINTrig" ) {
      device("cntrlFpga",0)->command("ApvINTrig","");
      return(string("<ApvINTrig>Success</ApvINTrig>"));
   }

   else return(System::command(name,arg));
}


//! Method to return state string
string Tracker::getState ( string topState ) {
   string ret = topState;
   string loc = "";
   uint apv;
   uint hyb;

   for ( hyb = 0; hyb < 1; hyb++ ) { 
      if ( device("cntrlFpga",0)->device("hybrid",hyb)->get("enabled") == "True" ) {
         for ( apv = 0; apv < 5; apv++ ) {

            if ( device("cntrlFpga",0)->device("hybrid",hyb)->device("apv25",apv)->get("enabled") == "True" ) {

               if ( device("cntrlFpga",0)->device("hybrid",hyb)->device("apv25",apv)->getInt("FifoError") != 0 ) {
                  loc = "APV FIFO Error.\nSoft Reset Required!\n";
                  break;
               }

               if ( device("cntrlFpga",0)->device("hybrid",hyb)->device("apv25",apv)->getInt("LatencyError") != 0 ) {
                  loc = "APV Latency Error.\nSoft Reset Required!\n";
                  break;
               }
            }
         }
      }
   }

   if ( device("cntrlFpga",0)->getInt("ApvSyncError") != 0 ) 
      loc = "APV Sync Error.\nSoft Reset Required!\n";

   else if ( device("cntrlFpga",0)->getInt("ApvSyncDetect") == 0 ) 
      loc = "APV Device Not Synced.\nSoft Reset Required!\n";

   if ( loc == "" ) loc = "System Ready To Take Data.\n";      

   ret = topState;
   ret.append(loc);
   return(ret);
}

//! Method to perform soft reset
void Tracker::softReset ( ) {
   device("cntrlFpga",0)->command("Apv25Reset","");
   sleep(5);
   readStatus(true);
}

//! Method to perform hard reset
void Tracker::hardReset ( ) {
   bool gotVer = false;
   uint count = 0;

   device("cntrlFpga",0)->command("MasterReset","");

   do {
      sleep(1);
      try { 
         gotVer = true;
         device("cntrlFpga",0)->readSingle("Version");
      } catch ( string err ) { 
         if ( count > 5 ) {
            gotVer = true;
            throw(string("Tracker::hardReset -> Error contacting concentrator"));
         }
         else {
            count++;
            gotVer = false;
         }
      }
   } while ( !gotVer );
   device("cntrlFpga",0)->command("Apv25HardReset","");
}

