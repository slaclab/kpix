//-----------------------------------------------------------------------------
// File          : KpixControl.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Heavy Photon KpixControl
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
#include <KpixControl.h>
#include <CntrlFpga.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixControl::KpixControl ( ) : System("KpixControl") {

   // Description
   desc_ = "Kpix Control";
   
   // Data mask, lane 0, vc 0
   dataMask_ = 0x11;

   // Add sub-devices
   addDevice(new CntrlFpga(0, 0, 4, 0xA, this));

}

// Deconstructor
KpixControl::~KpixControl ( ) { }

// Method to process a command
string KpixControl::command ( string name, string arg ) {
   return(System::command(name,arg));
}


//! Method to return state string
string KpixControl::getState ( string topState ) {
   string ret;
   string loc = "";
   //uint apv;
   //uint hyb;

   loc = "System Ready To Take Data.\n";      

   ret = topState;
   ret.append(loc);
   return(ret);
}

//! Method to perform soft reset
void KpixControl::softReset ( ) {
   //device("cntrlFpga",0)->command("Apv25Reset","");
   //sleep(5);
   readStatus(true);
}

//! Method to perform hard reset
void KpixControl::hardReset ( ) {
   //bool gotVer = false;
   //uint count = 0;

/*
   device("cntrlFpga",0)->command("MasterReset","");

   do {
      sleep(1);
      try { 
         gotVer = true;
         device("cntrlFpga",0)->readSingle("Version");
      } catch ( string err ) { 
         if ( count > 5 ) {
            gotVer = true;
            throw(string("KpixControl::hardReset -> Error contacting concentrator"));
         }
         else {
            count++;
            gotVer = false;
         }
      }
   } while ( !gotVer );
   device("cntrlFpga",0)->command("Apv25HardReset","");
*/

}

