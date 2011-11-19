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
KpixChannel::KpixChannel ( uint index, Device *parent ) : 
                     Device(0,0,"kpixChannel",index,parent) {

   // Description
   desc_ = "Kpix Channel";

   // Setup variables
   addVariable(new Variable("TrigMode", Variable::Configuration));
   variables_["TrigMode"]->setDescription("Channel threshold & calibration mode");
   vector<string> modes;
   modes.resize(2);
   modes[0] = "ThreshB";
   modes[1] = "Disable";
   modes[2] = "CalibThreshA";
   modes[3] = "ThreshA";
   variables_["TrigMode"]->setEnums(modes);
   variables_["TrigMode"]->setPerInstance(true);

   addVariable(new Variable("NormalGain", Variable::Configuration));
   variables_["NormalGain"]->setDescription("Normal range gain value");
   variables_["NormalGain"]->setPerInstance(true);

   addVariable(new Variable("NormalMean", Variable::Configuration));
   variables_["NormalMean"]->setDescription("Normal range mean value");
   variables_["NormalMean"]->setPerInstance(true);

   addVariable(new Variable("LowGain", Variable::Configuration));
   variables_["LowGain"]->setDescription("Low range gain value");
   variables_["LowGain"]->setPerInstance(true);

   addVariable(new Variable("LowMean", Variable::Configuration));
   variables_["LowMean"]->setDescription("Low range mean value");
   variables_["LowMean"]->setPerInstance(true);

   addVariable(new Variable("HighGain", Variable::Configuration));
   variables_["HighGain"]->setDescription("High range gain value");
   variables_["HighGain"]->setPerInstance(true);

   addVariable(new Variable("HighMean", Variable::Configuration));
   variables_["HighMean"]->setDescription("High range mean value");
   variables_["HighMean"]->setPerInstance(true);
}

// Deconstructor
KpixChannel::~KpixChannel ( ) { }

