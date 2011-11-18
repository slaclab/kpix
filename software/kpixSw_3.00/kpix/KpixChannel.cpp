//-----------------------------------------------------------------------------
// File          : KpixChannel.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/17/2011
// Project       : Kpix ASIC
//-----------------------------------------------------------------------------
// Description :
// Kpix channel container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/17/2011: created
//-----------------------------------------------------------------------------
#include <KpixChannel.h>
#include <Variable.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixChannel::KpixChannel ( uint index ) : 
                     Device(0,0,"kpixChannel",index) {

   // Description
   desc_ = "Kpix Channel";

   // Setup variables
   addVariable(new Variable("Mode", Variable::Configuration));
   variables_["Mode"]->setDescription("Channel threshold & calibration mode");
   vector<string> modes;
   modes.resize(2);
   modes[0] = "ThreshB";
   modes[1] = "Disable";
   modes[2] = "CalibThreshA";
   modes[3] = "ThreshA";
   variables_["Mode"]->setEnums(modes);

   addVariable(new Variable("NormalGain", Variable::Configuration));
   variables_["NormalGain"]->setDescription("Normal range gain value");

   addVariable(new Variable("NormalMean", Variable::Configuration));
   variables_["NormalMean"]->setDescription("Normal range mean value");

   addVariable(new Variable("LowGain", Variable::Configuration));
   variables_["LowGain"]->setDescription("Low range gain value");

   addVariable(new Variable("LowMean", Variable::Configuration));
   variables_["LowMean"]->setDescription("Low range mean value");

   addVariable(new Variable("HighGain", Variable::Configuration));
   variables_["HighGain"]->setDescription("High range gain value");

   addVariable(new Variable("HighMean", Variable::Configuration));
   variables_["HighMean"]->setDescription("High range mean value");
}

// Deconstructor
KpixChannel::~KpixChannel ( ) { }

