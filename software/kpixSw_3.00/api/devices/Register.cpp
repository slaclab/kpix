//-----------------------------------------------------------------------------
// File          : Register.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic register container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------

#include "Register.h"
using namespace std;

//! Constructor
Register::Register ( uint address, bool writeEn, bool testEn ) {
   writeEn_ = writeEn;
   address_ = address;
   testEn_  = testEn;
   stale_   = true;
   value_   = 0;
}

//! Method to get register address
uint Register::address () { return(address_); }

//! Method to get register write enable state
bool Register::writeEn() { return(writeEn_); }

//! Method to get register test enable state
bool Register::testEn() { return(testEn_); }

//! Method to get stale flag
bool Register::stale() { return(stale_); }

//! Method to set register value
void Register::set ( uint value, uint bit, uint mask ) {
   uint newVal; 

   newVal &= (0xFFFFFFFF ^ (mask << bit));
   newVal |= ((value & mask) << bit);

   if ( newVal != value_ ) {
      value_ = newVal;
      stale_ = true;
   }
}

//! Method to get register value
uint Register::get ( uint bit, uint mask ) {
   return((value_>>bit) & mask);
}

//! Method called when writing data to device. 
uint Register::write () {
   stale_ = false;
   return(value_);
}

//! Method called when reading data from device
void Register::read (uint value) {
   value_ = value;
   stale_ = false;
}

//! Method called when verifying register
bool Register::verify (uint value) {
   return(value == value_);
}

