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

}

void KpixAsic::readChanMode() {


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

