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
#include <OptoFpga.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixControl::KpixControl ( uint type ) : System("KpixControl") {

   // Description
   desc_ = "Kpix Control";
   
   // Data mask, lane 0, vc/type 1
   dataMask_ = 0x12;

   // Add sub-devices
   switch(type) {
      case Opto: 
         cout << "KpixControl::KpixControl -> Using Opto FPGA" << endl;
         addDevice(new OptoFpga(0, 0, this));
         fpga_ = "optoFpga";
         break;
      case Con: 
         cout << "KpixControl::KpixControl -> Using Con FPGA" << endl;
         //addDevice(new FpgaCon(0, 0, this));
         fpga_ = "conFpga";
         break;
      default: cout << "KpixControl::KpixControl -> Invalid FPGA Type" << endl; break;
   }
}

// Deconstructor
KpixControl::~KpixControl ( ) { }

// Method to process a command
void KpixControl::command ( string name, string arg ) {
   System::command(name,arg);
}


//! Method to return state string
string KpixControl::getState ( ) {
   string loc = "";

   loc = "System Ready To Take Data.\n";

   return(loc);
}

//! Method to perform soft reset
void KpixControl::softReset ( ) {
   System::softReset();

   device(fpga_,0)->command("CountReset","");
}

//! Method to perform hard reset
void KpixControl::hardReset ( ) {
   bool gotVer = false;
   uint count = 0;

   System::hardReset();

   device(fpga_,0)->command("MasterReset","");
   do {
      sleep(1);
      try { 
         gotVer = true;
         device(fpga_,0)->readSingle("Version");
      } catch ( string err ) { 
         if ( count > 5 ) {
            gotVer = true;
            throw(string("KpixControl::hardReset -> Error contacting fpga"));
         }
         else {
            count++;
            gotVer = false;
         }
      }
   } while ( !gotVer );
   device(fpga_,0)->command("KpixCmdReset","");
}

