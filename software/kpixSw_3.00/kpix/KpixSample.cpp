//-----------------------------------------------------------------------------
// File          : KpixSample.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : Kpix DAQ
//-----------------------------------------------------------------------------
// Description :
// Sample Container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 08/26/2011: created
//-----------------------------------------------------------------------------
#include <string.h>
#include <iostream>
#include "KpixSample.h"
using namespace std;

// Constructor for static pointer
KpixSample::KpixSample () {
   data_        = ldata_;
   trainNumber_ = 0;
}

// Constructor with copy
KpixSample::KpixSample ( ushort *data, uint trainNumber ) {
   data_        = ldata_;
   trainNumber_ = trainNumber;
   memcpy(ldata_,data,16);
}

//! DeConstructor
KpixSample::~KpixSample ( ) { }

// Set data pointer.
void KpixSample::setData ( ushort *data, uint trainNumber ) {
   data_        = data;
   trainNumber_ = trainNumber;
}

// Get sample train number.
uint KpixSample::getTrainNum() {
   return(trainNumber_);
}

// Get KPIX address from sample.
uint KpixSample::getKpixAddress() {
   uint ret;
   ret = (data_[0] >> 10) & 0x3;
   return(ret);
}

// Get KPIX channel.
uint KpixSample::getKpixChannel() {
   uint ret;
   ret = data_[0] & 0x3FF;
   return(ret);
}

// Get KPIX bucket.
uint KpixSample::getKpixBucket() {
   uint ret;
   ret = (data_[0] >> 12) & 0x3;
   return(ret);
}

// Get sample range.
uint KpixSample::getSampleRange() {
   uint ret;
   ret = (data_[1] >> 13) & 0x1;
   return(ret);
}

// Get sample time
uint KpixSample::getSampleTime() {
   uint ret;
   ret = data_[1] & 0xFFF;
   ret |= (data_[1] >> 2) & 0x1000;
   return(ret);
}

// Get sample value.
uint KpixSample::getSampleValue() {
   uint ret;
   ret = data_[2] & 0x1FFF;
   return(ret);
}

// Get empty flag.
uint KpixSample::getEmpty() {
   uint ret;
   ret = (data_[1] >> 12) & 0x1;
   return(ret);
}

// Get badCount flag.
uint KpixSample::getBadCount() {
   uint ret;
   ret = (data_[2] >> 13) & 0x1;
   return(ret);
}

// Get trigger type flag.
uint KpixSample::getTrigType() {
   uint ret;
   ret = (data_[2] >> 14) & 0x1;
   return(ret);
}

// Get special flag.
uint KpixSample::getSpecial() {
   uint ret;
   ret = (data_[1] >> 15) & 0x1;
   return(ret);
}

