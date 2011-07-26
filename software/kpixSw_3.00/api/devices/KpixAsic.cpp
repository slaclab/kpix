//-----------------------------------------------------------------------------
// File          : KpixAsic.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Kpix ASIC container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------

#include "KpixAsic.h"
#include "Register.h"
#include <sstream>
#include <iomanip>
using namespace std;

//! Constructor
KpixAsic::KpixAsic ( uint version, uint address, bool dummy ) : Device("asic",address) {
   stringstream tmp;
   uint         x;

   // Copy values
   version_ = version;
   dummy_   = dummy;

   // Create Registers: name, address, writeEn, testEn
   registers_.insert(pair<string,Register*>("Status",            new Register(0x00,false,false)));
   registers_.insert(pair<string,Register*>("Config",            new Register(0x01,true,true)));
   registers_.insert(pair<string,Register*>("Reset Timer",       new Register(0x08,true,true)));
   registers_.insert(pair<string,Register*>("LeakageNull Timer", new Register(0x09,true,true)));
   registers_.insert(pair<string,Register*>("OffsetNull Timer",  new Register(0x0A,true,true)));
   registers_.insert(pair<string,Register*>("ThreshOff Timer",   new Register(0x0B,true,true)));
   registers_.insert(pair<string,Register*>("TrigInh Timer",     new Register(0x0C,true,true)));
   registers_.insert(pair<string,Register*>("PwrUpAcq Timer",    new Register(0x0D,true,true)));
   registers_.insert(pair<string,Register*>("PwrUpDig Timer",    new Register(0x0E,true,true)));
   registers_.insert(pair<string,Register*>("State Timer",       new Register(0x0F,true,true)));
   registers_.insert(pair<string,Register*>("Cal Delay 0",       new Register(0x10,true,true)));
   registers_.insert(pair<string,Register*>("Cal Delay 1",       new Register(0x11,true,true)));

   // Dig only in dummy kpix
   if ( ! dummy_ ) {
      registers_.insert(pair<string,Register*>("Event A Reset Dac",   new Register(0x20,true,true)));
      registers_.insert(pair<string,Register*>("Event B Reset Dac",   new Register(0x21,true,true)));
      registers_.insert(pair<string,Register*>("Ramp Thresh Dac",     new Register(0x22,true,true)));
      registers_.insert(pair<string,Register*>("Range Threshold Dac", new Register(0x23,true,true)));
      registers_.insert(pair<string,Register*>("Calibration Dac",     new Register(0x24,true,true)));
      registers_.insert(pair<string,Register*>("Event Thold Ref Dac", new Register(0x25,true,true)));
      registers_.insert(pair<string,Register*>("Shaper Bias Dac",     new Register(0x26,true,true)));
      registers_.insert(pair<string,Register*>("Default Analog Dac",  new Register(0x27,true,true)));
      registers_.insert(pair<string,Register*>("Event A Trig Dac",    new Register(0x28,true,true)));
      registers_.insert(pair<string,Register*>("Event B Trig Dac",    new Register(0x29,true,true)));
      registers_.insert(pair<string,Register*>("Control",             new Register(0x30,true,true)));

      // Calibration Mask Registers
      for (x=0; x < (channels()/32); x++) {
         tmp.str("");
         tmp << "Channel Mode A 0x" << setw(2) << setfill('0') << hex << x;
         registers_.insert(pair<string,Register*>(tmp.str(),new Register(0x40+x,true,true)));
         tmp.str("");
         tmp << "Channel Mode B 0x" << setw(2) << setfill('0') << hex << x;
         registers_.insert(pair<string,Register*>(tmp.str(),new Register(0x60+x,true,true)));
      }
   }
}

//! Deconstructor
KpixAsic::~KpixAsic ( ) {
}

// Process channel mode settings
string KpixAsic::writeChanMode() {
   stringstream err;
   stringstream var;
   stringstream regA;
   stringstream regB;
   uint         col;
   uint         row;
   string       varVal;
   string       defVal;

   // Clear errors
   err.str("");

   // Get default value
   defVal = variables_["KpixChanModeDefault"].get();

   // Each column
   for ( col=0; x < channels()/32; col++ ) {
      regA.str("");
      regA << "Channel Mode A 0x" << setw(2) << setfill('0') << hex << col;
      regB.str("");
      regB << "Channel Mode B 0x" << setw(2) << setfill('0') << hex << col;

      // Each row
      for ( row=0; x < 32; row++ ) {

         // Get mode
         var.str("");
         var << "KpixChanMode" << setw(4) << setfill('0') << dec << col*32 + row;
         varVal = variables_[var.str()].get();

         // Use default?
         if ( varVal == "" ) varVal = defVal;

         // Debug
         if ( debug_ ) cout << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                            << " Set Channel " << dec << (col*32+row) << " = " << varVal << endl;

         // Figure out mode
         if ( varVal == "CalibThreshA" ) { // 3
            registers_[regA.str()].set(1,row,1);
            registers_[regB.str()].set(1,row,1);
         }
         else if ( varVal == "ThreshA" ) { // 2
            registers_[regA.str()].set(0,row,1);
            registers_[regB.str()].set(1,row,1);
         }
         else if ( varVal == "Disable" ) { // 1
            registers_[regA.str()].set(1,row,1);
            registers_[regB.str()].set(0,row,1);
         }
         else if ( varVal == "ThreshB" ) { // 0
            registers_[regA.str()].set(0,row,1);
            registers_[regB.str()].set(0,row,1);
         }
         else { 
            registers_[regA.str()].set(1,row,1); // Default to disable
            registers_[regB.str()].set(0,row,1);

            // Show error
            if ( debug_ ) cout << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                               << " Invalid Mode. Channel " << dec << (col*32+row) << " = " << varVal << endl;
            err << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                << " Invalid Mode. Channel " << dec << (col*32+row) << " = " << varVal << endl;
         }
      }
   }
   return(err.str(""));
}

void KpixAsic::readChanMode() {
   stringstream var;
   stringstream regA;
   stringstream regB;
   uint         col;
   uint         row;
   uint         regValA;
   uint         regValB;

   // Set default
   variables_["KpixChanModeDefault"].set("Disable");

   // Each column
   for ( col=0; x < channels()/32; col++ ) {
      regA.str("");
      regA << "Channel Mode A 0x" << setw(2) << setfill('0') << hex << col;
      regB.str("");
      regB << "Channel Mode B 0x" << setw(2) << setfill('0') << hex << col;

      // Each row
      for ( row=0; x < 32; row++ ) {
         var.str("");
         var << "KpixChanMode" << setw(4) << setfill('0') << dec << col*32 + row;

         // Determine register value
         switch ( registers_[regB.str()].get(row,1), registers_[regB.str()].get(row,1) ) {
            case 0:  variables_[var.str()].set("ThreshB");      break;
            case 1:  variables_[var.str()].set("Disable");      break;
            case 2:  variables_[var.str()].set("ThreshA");      break;
            case 3:  variables_[var.str()].set("CalibThreshA"); break;
            default: variables_[var.str()].set("Disable");      break;
         }

         // Debug
         if ( debug_ ) cout << "KpixAsic::readChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                            << " Get Channel " << dec << (col*32+row) << " = " << variables_[var.str()].get() << endl;
      }
   }
}

// Process timing settings
string KpixAsic::writeTiming() {

}

void KpixAsic::readTiming() {



}

//! Method to read variables from registers
string KpixAsic::read() {






   
   return(Device::read());
}

//! Method to write variables to registers
string KpixAsic::write( string xml ) {
   Device::write(xml);





}

//! Return version
uint KpixAsic::version() {
   return(version_);
}

//! Return dummy
bool KpixAsic::dummy() {
   return(dummy_);
}

//! Channel count
uint KpixAsic::channels() {
   switch(version_) {
      case  9: return(512);  break;
      case 10: return(1024); break;
      default: return(0);    break;
   }
}

