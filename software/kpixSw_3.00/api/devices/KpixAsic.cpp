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
#include "Variable.h"
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

//! Constructor
KpixAsic::KpixAsic ( uint version, uint address, bool dummy ) : Device("asic",address) {
   stringstream   tmp;
   stringstream   var;
   uint           x;
   vector<string> chanModes;
   vector<string> calTrigSource;
   vector<string> feCurr;
   vector<string> holdTime;
   vector<string> diffTime;
   vector<string> monSource;

   // Copy values
   version_ = version;
   dummy_   = dummy;

   // Create Registers: name, address, writeEn, testEn
   registers_.insert(pair<string,Register*>("Status",      new Register(0x00,false,false)));
   registers_.insert(pair<string,Register*>("Config",      new Register(0x01,true,true)));
   registers_.insert(pair<string,Register*>("Timer A",     new Register(0x08,true,true)));
   registers_.insert(pair<string,Register*>("Timer B",     new Register(0x09,true,true)));
   registers_.insert(pair<string,Register*>("Timer C",     new Register(0x0A,true,true)));
   registers_.insert(pair<string,Register*>("Timer D",     new Register(0x0B,true,true)));
   registers_.insert(pair<string,Register*>("Timer E",     new Register(0x0C,true,true)));
   registers_.insert(pair<string,Register*>("Timer F",     new Register(0x0D,true,true)));
   registers_.insert(pair<string,Register*>("Timer G",     new Register(0x0E,true,true)));
   registers_.insert(pair<string,Register*>("Timer H",     new Register(0x0F,true,true)));
   registers_.insert(pair<string,Register*>("Cal Delay 0", new Register(0x10,true,true)));
   registers_.insert(pair<string,Register*>("Cal Delay 1", new Register(0x11,true,true)));

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

   // Setup channel mode enum
   chanModes[0] = "ThreshB";
   chanModes[1] = "Disable";
   chanModes[2] = "Calib";
   chanModes[3] = "ThreshA";

   // Setup channel mode variables
   if ( ! dummy_ ) {
      for ( x=0; x < channels(); x++ ) {
         var.str("");
         var << "KpixChanMode" << setw(4) << setfill('0') << dec << x;
         variables_.insert(pair<string,Variable*>(var.str(), new Variable(chanModes)));
      }
      variables_.insert(pair<string,Variable*>("KpixChanModeDefault",new Variable(chanModes)));
   }

   // Setup Timing Variables
   variables_.insert(pair<string,Variable*>("ClkPeriodAcq",      new Variable()));
   variables_.insert(pair<string,Variable*>("ResetOn",           new Variable()));
   variables_.insert(pair<string,Variable*>("ResetOff",          new Variable()));
   variables_.insert(pair<string,Variable*>("LeakageNullOff",    new Variable()));
   variables_.insert(pair<string,Variable*>("OffsetNullOff",     new Variable()));
   variables_.insert(pair<string,Variable*>("ThreshOff",         new Variable()));
   variables_.insert(pair<string,Variable*>("TrigInhibitOff",    new Variable()));
   variables_.insert(pair<string,Variable*>("PowerUpOn",         new Variable()));
   variables_.insert(pair<string,Variable*>("DeselDelay",        new Variable()));
   variables_.insert(pair<string,Variable*>("BunchClkDelay",     new Variable()));
   variables_.insert(pair<string,Variable*>("DigitizationDelay", new Variable()));
   variables_.insert(pair<string,Variable*>("BunchClockCount",   new Variable()));
      
   // Setup DAC Variables
   variables_.insert(pair<string,Variable*>("DacCalib",          new Variable()));
   variables_.insert(pair<string,Variable*>("DacRampThresh",     new Variable()));
   variables_.insert(pair<string,Variable*>("DacRangeThresh",    new Variable()));
   variables_.insert(pair<string,Variable*>("DacDefaultAnalog",  new Variable()));
   variables_.insert(pair<string,Variable*>("DacEventThreshRef", new Variable()));
   variables_.insert(pair<string,Variable*>("DacShaperBias",     new Variable()));
   variables_.insert(pair<string,Variable*>("DacRstThreshA",     new Variable()));
   variables_.insert(pair<string,Variable*>("DacTrigThreshA",    new Variable()));
   variables_.insert(pair<string,Variable*>("DacRstThreshB",     new Variable()));
   variables_.insert(pair<string,Variable*>("DacTrigThreshB",    new Variable()));

   // Setup calib variables
   variables_.insert(pair<string,Variable*>("CalCount",  new Variable()));
   variables_.insert(pair<string,Variable*>("Cal0Delay", new Variable()));
   variables_.insert(pair<string,Variable*>("Cal1Delay", new Variable()));
   variables_.insert(pair<string,Variable*>("Cal2Delay", new Variable()));
   variables_.insert(pair<string,Variable*>("Cal3Delay", new Variable()));

   // Setup config variables
   variables_.insert(pair<string,Variable*>("CfgTestData",    new Variable()));
   variables_.insert(pair<string,Variable*>("CfgAutoReadDis", new Variable()));
   variables_.insert(pair<string,Variable*>("CfgForceTemp",   new Variable()));
   variables_.insert(pair<string,Variable*>("CfgDisableTemp", new Variable()));
   variables_.insert(pair<string,Variable*>("CfgAutoStatus",  new Variable()));

   // Setup cal/trig source enum
   calTrigSource[0] = "Disable";
   calTrigSource[1] = "Internal";
   calTrigSource[2] = "External";

   // Setup Fe curr enum
   feCurr[0] = "1uA";
   feCurr[1] = "31uA";
   feCurr[2] = "61uA";
   feCurr[3] = "91uA";
   feCurr[4] = "121uA";
   feCurr[5] = "151uA";
   feCurr[6] = "181uA";
   feCurr[7] = "211uA";

   // Setup hold time enum
   holdTime[0] = "8x";
   holdTime[1] = "16x";
   holdTime[2] = "24x";
   holdTime[3] = "32x";
   holdTime[4] = "40x";
   holdTime[5] = "48x";
   holdTime[6] = "56x";
   holdTime[7] = "64x";

   // Setup diff time enum
   diffTime[0] = "Normal";
   diffTime[1] = "Half";
   diffTime[2] = "Third";
   diffTime[3] = "Quarter";

   // Setup mon source enum
   monSource[0] = "None";
   monSource[1] = "Amp";
   monSource[2] = "Shaper";

   // Setup control variables
   variables_.insert(pair<string,Variable*>("CntrlCalibHigh",    new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlForceLowGain", new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlLeakNullDis",  new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlDoubleGain",   new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlNearNeighbor", new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlPosPixel",     new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlDisPerReset",  new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlEnDcReset",    new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlCalSource",    new Variable(calTrigSource)));
   variables_.insert(pair<string,Variable*>("CntrlTrigSource",   new Variable(calTrigSource)));
   variables_.insert(pair<string,Variable*>("CntrlShortIntEn",   new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlDisPwrCycle",  new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlFeCurr",       new Variable(feCurr)));
   variables_.insert(pair<string,Variable*>("CntrlHoldTime",     new Variable(holdTime)));
   variables_.insert(pair<string,Variable*>("CntrlDiffTime",     new Variable(diffTime)));
   variables_.insert(pair<string,Variable*>("CntrlTrigDisable",  new Variable()));
   variables_.insert(pair<string,Variable*>("CntrlMonSource",    new Variable(monSource)));

   // Setup status variables
   variables_.insert(pair<string,Variable*>("StatCmdPerr",     new Variable()));
   variables_.insert(pair<string,Variable*>("StatDataPerr",    new Variable()));
   variables_.insert(pair<string,Variable*>("StatTempEn",      new Variable()));
   variables_.insert(pair<string,Variable*>("StatTempIdValue", new Variable()));

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
   uint         defVal;
   bool         defOk;
   uint         varVal;
   bool         varOk;

   if ( dummy_ ) return("");

   // Clear errors
   err.str("");

   // Get default value
   defVal = variables_["KpixChanModeDefault"]->getReg(&defOk);

   // Each column
   for ( col=0; col < channels()/32; col++ ) {
      regA.str("");
      regA << "Channel Mode A 0x" << setw(2) << setfill('0') << hex << col;
      regB.str("");
      regB << "Channel Mode B 0x" << setw(2) << setfill('0') << hex << col;

      // Each row
      for ( row=0; row < 32; row++ ) {

         // Get mode
         var.str("");
         var << "KpixChanMode" << setw(4) << setfill('0') << dec << col*32 + row;
         varVal = variables_[var.str()]->getReg(&varOk);

         // Use default?
         if ( !varOk ) {
            varVal = defVal;
            varOk  = defOk;
         }

         // Set register values
         registers_[regB.str()]->set((varVal>>1)&0x1,row,1);
         registers_[regA.str()]->set(varVal&0x1,row,1);

         // Show error
         if ( !varOk ) {
            if ( debug_ ) cout << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                               << " Invalid Mode. Channel " << dec << (col*32+row);
            err << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                << " Invalid Mode. Channel " << dec << (col*32+row);
         }
         else {
            if ( debug_ ) cout << "KpixAsic::writeChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                               << " Set " << var.str() << " = " << variables_[var.str()]->get() << endl;
         }
      }
   }
   return(err.str());
}


void KpixAsic::readChanMode() {
   stringstream var;
   stringstream regA;
   stringstream regB;
   uint         col;
   uint         row;

   if ( dummy_ ) return;

   // Each column
   for ( col=0; col < channels()/32; col++ ) {
      regA.str("");
      regA << "Channel Mode A 0x" << setw(2) << setfill('0') << hex << col;
      regB.str("");
      regB << "Channel Mode B 0x" << setw(2) << setfill('0') << hex << col;

      // Each row
      for ( row=0; row < 32; row++ ) {
         var.str("");
         var << "KpixChanMode" << setw(4) << setfill('0') << dec << col*32 + row;

         // Set register value
         variables_[var.str()]->setReg((registers_[regB.str()]->get(row,1), registers_[regB.str()]->get(row,1)));

         // Debug
         if ( debug_ ) cout << "KpixAsic::readChanMode -> Address 0x" << hex << setw(4) << setfill('0') << address_
                            << " Get " << var.str() << " = " << variables_[var.str()]->get() << endl;
      }
   }
}


// Process timing settings
string KpixAsic::writeTiming() {
   uint         clkPeriodAcq;
   uint         resetOn;
   uint         resetOff;
   uint         leakageNullOff;
   uint         offsetNullOff;
   uint         threshOff;
   uint         trigInhibitOff;
   uint         powerUpOn;
   uint         deselDelay;
   uint         bunchClkDelay;
   uint         digitizationDelay;
   uint         bunchClockCount;
   stringstream err;
   bool         ok;
   bool         okAll;
   uint         temp;

   // Get values
   okAll = true;
   clkPeriodAcq      = variables_["ClkPeriodAcq"]->getReg(&ok);      if ( ! ok ) okAll = false;
   resetOn           = variables_["ResetOn"]->getReg(&ok);           if ( ! ok ) okAll = false;
   resetOff          = variables_["ResetOff"]->getReg(&ok);          if ( ! ok ) okAll = false;
   leakageNullOff    = variables_["LeakageNullOff"]->getReg(&ok);    if ( ! ok ) okAll = false;
   offsetNullOff     = variables_["OffsetNullOff"]->getReg(&ok);     if ( ! ok ) okAll = false;
   threshOff         = variables_["ThreshOff"]->getReg(&ok);         if ( ! ok ) okAll = false;
   trigInhibitOff    = variables_["TrigInhibitOff"]->getReg(&ok);    if ( ! ok ) okAll = false;
   powerUpOn         = variables_["PowerUpOn"]->getReg(&ok);         if ( ! ok ) okAll = false;
   deselDelay        = variables_["DeselDelay"]->getReg(&ok);        if ( ! ok ) okAll = false;
   bunchClkDelay     = variables_["BunchClkDelay"]->getReg(&ok);     if ( ! ok ) okAll = false;
   digitizationDelay = variables_["DigitizationDelay"]->getReg(&ok); if ( ! ok ) okAll = false;
   bunchClockCount   = variables_["BunchClockCount"]->getReg(&ok);   if ( ! ok ) okAll = false;

   // Check timing sequence
   err.str("");
   if ( 

      // Leakage null comes first    - Then reset assertion
      (leakageNullOff < resetOn)     && (resetOn < powerUpOn)

      // Then power up               - Then deselect 
      && (powerUpOn < deselDelay)    && (deselDelay < offsetNullOff)
      
      // Then offset null            - Then threshold offset
      && (offsetNullOff < threshOff) && (threshOff < resetOff)

      // Then reset off              - Then bunch clock delay, trigger inhibit
      && (resetOff < bunchClkDelay)  && (bunchClkDelay < trigInhibitOff) ) {

      // Declare error
      err << "KpixAsic::writeTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Timing sequence error detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Timing sequence error detected" << endl;
   }

   // Check clock period divide
   if ( ((resetOn           % clkPeriodAcq) != 0 ) || ((resetOn           / clkPeriodAcq) > 0xFFFF ) ||
        ((resetOff          % clkPeriodAcq) != 0 ) || ((resetOff          / clkPeriodAcq) > 0xFFFF ) ||
        ((leakageNullOff    % clkPeriodAcq) != 0 ) || ((leakageNullOff    / clkPeriodAcq) > 0xFFFF ) ||
        ((offsetNullOff     % clkPeriodAcq) != 0 ) || ((offsetNullOff     / clkPeriodAcq) > 0xFFFF ) ||
        ((threshOff         % clkPeriodAcq) != 0 ) || ((threshOff         / clkPeriodAcq) > 0xFFFF ) ||
        ((trigInhibitOff    % clkPeriodAcq) != 0 ) || 
        ((powerUpOn         % clkPeriodAcq) != 0 ) || ((powerUpOn         / clkPeriodAcq) > 0xFFFF ) ||
        ((deselDelay        % clkPeriodAcq) != 0 ) || ((deselDelay        / clkPeriodAcq) > 0xFF   ) ||
        ((bunchClkDelay     % clkPeriodAcq) != 0 ) || ((bunchClkDelay     / clkPeriodAcq) > 0xFFFF ) ||
        ((digitizationDelay % clkPeriodAcq) != 0 ) || ((digitizationDelay / clkPeriodAcq) > 0xFF   ) ||
        (bunchClockCount > 8191) || !okAll ) {
      err << "KpixAsic::writeTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Bad timing value detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Bad timing value detected" << endl;
   }

   // Set registers
   temp  = (resetOn            / clkPeriodAcq)        & 0x0000FFFF; 
   temp |= ((resetOff          / clkPeriodAcq) << 16) & 0xFFFF0000;
   registers_["Timer A"]->set(temp);

   temp  = (offsetNullOff      / clkPeriodAcq)        & 0x0000FFFF; 
   temp |= ((leakageNullOff    / clkPeriodAcq) << 16) & 0xFFFF0000;
   registers_["Timer B"]->set(temp);

   temp  = (powerUpOn          / clkPeriodAcq)        & 0x0000FFFF; 
   temp |= ((threshOff         / clkPeriodAcq) << 16) & 0xFFFF0000;
   registers_["Timer C"]->set(temp);

   temp  = (trigInhibitOff     / clkPeriodAcq);
   registers_["Timer D"]->set(temp);

   temp  = bunchClockCount                            & 0x0000FFFF;
   temp |= ((powerUpOn         / clkPeriodAcq) << 16) & 0xFFFF0000;
   registers_["Timer E"]->set(temp);

   temp  = (deselDelay         / clkPeriodAcq)        & 0x000000FF;
   temp |= ((bunchClkDelay     / clkPeriodAcq) <<  8) & 0x00FFFF00;
   temp |= ((digitizationDelay / clkPeriodAcq) << 24) & 0xFF000000;
   registers_["Timer F"]->set(temp);

   // Debug if enabled
   if ( debug_ ) {
      cout << "KpixAsic::writeTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " writing timing: " << endl;
      cout << "                         clkPeriodAcq      = " << dec << clkPeriodAcq      << endl;
      cout << "                         resetOn           = " << dec << resetOn           << endl;
      cout << "                         resetOff          = " << dec << resetOff          << endl;
      cout << "                         leakageNullOff    = " << dec << leakageNullOff    << endl;
      cout << "                         offsetNullOff     = " << dec << offsetNullOff     << endl;
      cout << "                         threshOff         = " << dec << threshOff         << endl;
      cout << "                         trigInhibitOff    = " << dec << trigInhibitOff    << endl;
      cout << "                         powerUpOn         = " << dec << powerUpOn         << endl;
      cout << "                         deselDelay        = " << dec << deselDelay        << endl;
      cout << "                         bunchClkDelay     = " << dec << bunchClkDelay     << endl;
      cout << "                         digitizationDelay = " << dec << digitizationDelay << endl;
      cout << "                         bunchClockCount   = " << dec << bunchClockCount   << endl;
   }

   return(err.str());
}


void KpixAsic::readTiming() {
   uint clkPeriodAcq;
   uint resetOn;
   uint resetOff;
   uint leakageNullOff;
   uint offsetNullOff;
   uint threshOff;
   uint trigInhibitOff;
   uint powerUpOn;
   uint deselDelay;
   uint bunchClkDelay;
   uint digitizationDelay;
   uint bunchClockCount;
   uint temp;
   bool ok;

   // Store clock period
   clkPeriodAcq = variables_["ClkPeriodAcq"]->getReg(&ok);

   // Get registers
   temp = registers_["Timer A"]->get();
   resetOn           = ((temp      ) & 0xFFFF) * clkPeriodAcq; 
   resetOff          = ((temp >> 16) & 0xFFFF) * clkPeriodAcq;

   temp = registers_["Timer B"]->get();
   offsetNullOff     = ((temp      ) & 0xFFFF) * clkPeriodAcq; 
   leakageNullOff    = ((temp >> 16) & 0xFFFF) * clkPeriodAcq;

   temp = registers_["Timer C"]->get();
   powerUpOn         = ((temp      ) & 0xFFFF) * clkPeriodAcq; 
   threshOff         = ((temp >> 16) & 0xFFFF) * clkPeriodAcq;

   temp = registers_["Timer D"]->get();
   trigInhibitOff    = ( temp                ) * clkPeriodAcq; 

   temp = registers_["Timer E"]->get();
   bunchClockCount   = ( temp        & 0xFFFF);

   temp = registers_["Timer F"]->get();
   deselDelay        = ((temp      ) & 0x00FF) * clkPeriodAcq;
   bunchClkDelay     = ((temp >>  8) & 0xFFFF) * clkPeriodAcq;
   digitizationDelay = ((temp >> 24) & 0x00FF) * clkPeriodAcq;

   // Set variables
   variables_["ResetOn"]->setReg(resetOn);
   variables_["ResetOff"]->setReg(resetOff);
   variables_["LeakageNullOff"]->setReg(leakageNullOff);
   variables_["OffsetNullOff"]->setReg(offsetNullOff);
   variables_["ThreshOff"]->setReg(threshOff);
   variables_["TrigInhibitOff"]->setReg(trigInhibitOff);
   variables_["PowerUpOn"]->setReg(powerUpOn);
   variables_["DeselDelay"]->setReg(deselDelay);
   variables_["BunchClkDelay"]->setReg(bunchClkDelay);
   variables_["DigitizationDelay"]->setReg(digitizationDelay);
   variables_["BunchClockCount"]->setReg(bunchClockCount);

   // Debug if enabled
   if ( debug_ ) {
      cout << "KpixAsic::readTiming -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading timing: " << endl;
      cout << "                        clkPeriodAcq      = " << dec << clkPeriodAcq      << endl;
      cout << "                        resetOn           = " << dec << resetOn           << endl;
      cout << "                        resetOff          = " << dec << resetOff          << endl;
      cout << "                        leakageNullOff    = " << dec << leakageNullOff    << endl;
      cout << "                        offsetNullOff     = " << dec << offsetNullOff     << endl;
      cout << "                        threshOff         = " << dec << threshOff         << endl;
      cout << "                        trigInhibitOff    = " << dec << trigInhibitOff    << endl;
      cout << "                        powerUpOn         = " << dec << powerUpOn         << endl;
      cout << "                        deselDelay        = " << dec << deselDelay        << endl;
      cout << "                        bunchClkDelay     = " << dec << bunchClkDelay     << endl;
      cout << "                        digitizationDelay = " << dec << digitizationDelay << endl;
      cout << "                        bunchClockCount   = " << dec << bunchClockCount   << endl;
   }
}


string KpixAsic::writeDacs() {
   uint         dacCalib;
   uint         dacRampThresh;
   uint         dacRangeThresh;
   uint         dacDefaultAnalog;
   uint         dacEventThreshRef;
   uint         dacShaperBias;
   uint         dacRstThreshA;
   uint         dacTrigThreshA;
   uint         dacRstThreshB;
   uint         dacTrigThreshB;
   bool         ok;
   bool         okAll;
   stringstream err;

   // Get variables
   okAll = true;
   dacCalib          = variables_["DacCalib"]->getReg(&ok);          if ( !ok ) okAll = false;
   dacRampThresh     = variables_["DacRampThresh"]->getReg(&ok);     if ( !ok ) okAll = false;
   dacRangeThresh    = variables_["DacRangeThresh"]->getReg(&ok);    if ( !ok ) okAll = false;
   dacDefaultAnalog  = variables_["DacDefaultAnalog"]->getReg(&ok);  if ( !ok ) okAll = false;
   dacEventThreshRef = variables_["DacEventThreshRef"]->getReg(&ok); if ( !ok ) okAll = false;
   dacShaperBias     = variables_["DacShaperBias"]->getReg(&ok);     if ( !ok ) okAll = false;
   dacRstThreshA     = variables_["DacRstThreshA"]->getReg(&ok);     if ( !ok ) okAll = false;
   dacTrigThreshA    = variables_["DacTrigThreshA"]->getReg(&ok);    if ( !ok ) okAll = false;
   dacRstThreshB     = variables_["DacRstThreshB"]->getReg(&ok);     if ( !ok ) okAll = false;
   dacTrigThreshB    = variables_["DacTrigThreshB"]->getReg(&ok);    if ( !ok ) okAll = false;

   // Set registers, repeat dac value 
   registers_["Event A Reset Dac"]->set(dacRstThreshA,0,0xFF);
   registers_["Event A Reset Dac"]->set(dacRstThreshA,8,0xFF);
   registers_["Event A Reset Dac"]->set(dacRstThreshA,16,0xFF);
   registers_["Event A Reset Dac"]->set(dacRstThreshA,24,0xFF);

   registers_["Event B Reset Dac"]->set(dacRstThreshB,0,0xFF);
   registers_["Event B Reset Dac"]->set(dacRstThreshB,8,0xFF);
   registers_["Event B Reset Dac"]->set(dacRstThreshB,16,0xFF);
   registers_["Event B Reset Dac"]->set(dacRstThreshB,24,0xFF);

   registers_["Ramp Thresh Dac"]->set(dacRampThresh,0,0xFF);
   registers_["Ramp Thresh Dac"]->set(dacRampThresh,8,0xFF);
   registers_["Ramp Thresh Dac"]->set(dacRampThresh,16,0xFF);
   registers_["Ramp Thresh Dac"]->set(dacRampThresh,24,0xFF);

   registers_["Range Threshold Dac"]->set(dacRangeThresh,0,0xFF);
   registers_["Range Threshold Dac"]->set(dacRangeThresh,8,0xFF);
   registers_["Range Threshold Dac"]->set(dacRangeThresh,16,0xFF);
   registers_["Range Threshold Dac"]->set(dacRangeThresh,24,0xFF);

   registers_["Calibration Dac"]->set(dacCalib,0,0xFF);
   registers_["Calibration Dac"]->set(dacCalib,8,0xFF);
   registers_["Calibration Dac"]->set(dacCalib,16,0xFF);
   registers_["Calibration Dac"]->set(dacCalib,24,0xFF);

   registers_["Event Thold Ref Dac"]->set(dacEventThreshRef,0,0xFF);
   registers_["Event Thold Ref Dac"]->set(dacEventThreshRef,8,0xFF);
   registers_["Event Thold Ref Dac"]->set(dacEventThreshRef,16,0xFF);
   registers_["Event Thold Ref Dac"]->set(dacEventThreshRef,24,0xFF);

   registers_["Shaper Bias Dac"]->set(dacShaperBias,0,0xFF);
   registers_["Shaper Bias Dac"]->set(dacShaperBias,8,0xFF);
   registers_["Shaper Bias Dac"]->set(dacShaperBias,16,0xFF);
   registers_["Shaper Bias Dac"]->set(dacShaperBias,24,0xFF);

   registers_["Default Analog Dac"]->set(dacDefaultAnalog,0,0xFF);
   registers_["Default Analog Dac"]->set(dacDefaultAnalog,8,0xFF);
   registers_["Default Analog Dac"]->set(dacDefaultAnalog,16,0xFF);
   registers_["Default Analog Dac"]->set(dacDefaultAnalog,24,0xFF);

   registers_["Event A Trig Dac"]->set(dacTrigThreshA,0,0xFF);
   registers_["Event A Trig Dac"]->set(dacTrigThreshA,8,0xFF);
   registers_["Event A Trig Dac"]->set(dacTrigThreshA,16,0xFF);
   registers_["Event A Trig Dac"]->set(dacTrigThreshA,24,0xFF);

   registers_["Event B Trig Dac"]->set(dacTrigThreshB,0,0xFF);
   registers_["Event B Trig Dac"]->set(dacTrigThreshB,8,0xFF);
   registers_["Event B Trig Dac"]->set(dacTrigThreshB,16,0xFF);
   registers_["Event B Trig Dac"]->set(dacTrigThreshB,24,0xFF);

   // Error
   err.str("");
   if ( ! okAll ) {
      err << "KpixAsic::writeDacs -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Bad dac value detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeDacs -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Bad dac value detected" << endl;
   } else {
      if ( debug_ ) {
         cout << "KpixAsic::writeDacs -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " writing dacs: " << endl;
         cout << "                       dacCalib          = " << dec << dacCalib << endl;
         cout << "                       dacRampThresh     = " << dec << dacRampThresh << endl;
         cout << "                       dacRangeThresh    = " << dec << dacRangeThresh << endl;
         cout << "                       dacDefaultAnalog  = " << dec << dacDefaultAnalog << endl;
         cout << "                       dacEventThreshRef = " << dec << dacEventThreshRef << endl;
         cout << "                       dacShaperBias     = " << dec << dacShaperBias << endl;
         cout << "                       dacRstThreshA     = " << dec << dacRstThreshA << endl;
         cout << "                       dacTrigThreshA    = " << dec << dacTrigThreshA << endl;
         cout << "                       dacRstThreshB     = " << dec << dacRstThreshB << endl;
         cout << "                       dacTrigThreshB    = " << dec << dacTrigThreshB << endl;
      }
   }

   return(err.str());
}


void KpixAsic::readDacs() {
   uint dacCalib;
   uint dacRampThresh;
   uint dacRangeThresh;
   uint dacDefaultAnalog;
   uint dacEventThreshRef;
   uint dacShaperBias;
   uint dacRstThreshA;
   uint dacTrigThreshA;
   uint dacRstThreshB;
   uint dacTrigThreshB;

   // Get registers
   dacRstThreshA     = registers_["Event A Reset Dac"]->get(0,0xFF);
   dacRstThreshB     = registers_["Event B Reset Dac"]->get(0,0xFF);
   dacRampThresh     = registers_["Ramp Thresh Dac"]->get(0,0xFF);
   dacRangeThresh    = registers_["Range Threshold Dac"]->get(0,0xFF);
   dacCalib          = registers_["Calibration Dac"]->get(0,0xFF);
   dacEventThreshRef = registers_["Event Thold Ref Dac"]->get(0,0xFF);
   dacShaperBias     = registers_["Shaper Bias Dac"]->get(0,0xFF);
   dacDefaultAnalog  = registers_["Default Analog Dac"]->get(0,0xFF);
   dacTrigThreshA    = registers_["Event A Trig Dac"]->get(0,0xFF);
   dacTrigThreshB    = registers_["Event B Trig Dac"]->get(0,0xFF);

   // Set variables
   variables_["DacCalib"]->setReg(dacCalib);
   variables_["DacRampThresh"]->setReg(dacRampThresh);
   variables_["DacRangeThresh"]->setReg(dacRangeThresh);
   variables_["DacDefaultAnalog"]->setReg(dacDefaultAnalog);
   variables_["DacEventThreshRef"]->setReg(dacEventThreshRef);
   variables_["DacShaperBias"]->setReg(dacShaperBias);
   variables_["DacRstThreshA"]->setReg(dacRstThreshA);
   variables_["DacTrigThreshA"]->setReg(dacTrigThreshA);
   variables_["DacRstThreshB"]->setReg(dacRstThreshB);
   variables_["DacTrigThreshB"]->setReg(dacTrigThreshB);

   // Debug
   if ( debug_ ) {
      cout << "KpixAsic::readDacs -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading dacs: " << endl;
      cout << "                      dacCalib          = " << dec << dacCalib << endl;
      cout << "                      dacRampThresh     = " << dec << dacRampThresh << endl;
      cout << "                      dacRangeThresh    = " << dec << dacRangeThresh << endl;
      cout << "                      dacDefaultAnalog  = " << dec << dacDefaultAnalog << endl;
      cout << "                      dacEventThreshRef = " << dec << dacEventThreshRef << endl;
      cout << "                      dacShaperBias     = " << dec << dacShaperBias << endl;
      cout << "                      dacRstThreshA     = " << dec << dacRstThreshA << endl;
      cout << "                      dacTrigThreshA    = " << dec << dacTrigThreshA << endl;
      cout << "                      dacRstThreshB     = " << dec << dacRstThreshB << endl;
      cout << "                      dacTrigThreshB    = " << dec << dacTrigThreshB << endl;
   }
}


string KpixAsic::writeCalib() {
   uint         calCount;
   uint         cal0Delay;
   uint         cal1Delay;
   uint         cal2Delay;
   uint         cal3Delay;
   bool         ok;
   bool         okAll;
   stringstream err;

   // Get variables
   okAll = true;
   calCount  = variables_["CalCount"]->getReg(&ok);  if ( !ok ) okAll = false;
   cal0Delay = variables_["Cal0Delay"]->getReg(&ok); if ( !ok ) okAll = false;
   cal1Delay = variables_["Cal1Delay"]->getReg(&ok); if ( !ok ) okAll = false;
   cal2Delay = variables_["Cal2Delay"]->getReg(&ok); if ( !ok ) okAll = false;
   cal3Delay = variables_["Cal3Delay"]->getReg(&ok); if ( !ok ) okAll = false;

   // Set registers
   registers_["Cal Delay 0"]->set(((calCount>=1)?1:0),15,0x1);
   registers_["Cal Delay 0"]->set(((calCount>=2)?1:0),31,0x1);
   registers_["Cal Delay 0"]->set(cal0Delay,0,0x1FFF);
   registers_["Cal Delay 0"]->set(cal1Delay,16,0x1FFF);

   registers_["Cal Delay 1"]->set(((calCount>=3)?1:0),15,0x1);
   registers_["Cal Delay 1"]->set(((calCount==4)?1:0),31,0x1);
   registers_["Cal Delay 1"]->set(cal2Delay,0,0x1FFF);
   registers_["Cal Delay 1"]->set(cal3Delay,16,0x1FFF);

   // Error
   err.str("");
   if ( ! okAll ) {
      err << "KpixAsic::writeCalib -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Bad calib value detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeCalib -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Bad calib value detected" << endl;
   } else {
      if ( debug_ ) {
         cout << "KpixAsic::writeCalib -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " writing calib: " << endl;
         cout << "                        calCount  = " << dec << calCount << endl;
         cout << "                        cal0Delay = " << dec << cal0Delay << endl;
         cout << "                        cal1Delay = " << dec << cal1Delay << endl;
         cout << "                        cal2Delay = " << dec << cal2Delay << endl;
         cout << "                        cal3Delay = " << dec << cal3Delay << endl;
      }
   }

   return(err.str());
}


void KpixAsic::readCalib() {
   uint         calCount;
   uint         cal0Delay;
   uint         cal1Delay;
   uint         cal2Delay;
   uint         cal3Delay;

   // Get registers
   cal0Delay = registers_["Cal Delay 0"]->get(0,0x1FFF);
   cal1Delay = registers_["Cal Delay 0"]->get(16,0x1FFF);
   cal2Delay = registers_["Cal Delay 1"]->get(0,0x1FFF);
   cal3Delay = registers_["Cal Delay 1"]->get(16,0x1FFF);

   calCount = 0;
   if ( registers_["Cal Delay 0"]->get(15,0x1) == 1 ) calCount++;
   if ( registers_["Cal Delay 0"]->get(31,0x1) == 1 ) calCount++;
   if ( registers_["Cal Delay 1"]->get(15,0x1) == 1 ) calCount++;
   if ( registers_["Cal Delay 1"]->get(31,0x1) == 1 ) calCount++;

   // Get variables
   variables_["CalCount"]->setReg(calCount);
   variables_["Cal0Delay"]->setReg(cal0Delay);
   variables_["Cal1Delay"]->setReg(cal1Delay);
   variables_["Cal2Delay"]->setReg(cal2Delay);
   variables_["Cal3Delay"]->setReg(cal3Delay);

   // Debug
   if ( debug_ ) {
      cout << "KpixAsic::readCalib -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading calib: " << endl;
      cout << "                       calCount  = " << dec << calCount << endl;
      cout << "                       cal0Delay = " << dec << cal0Delay << endl;
      cout << "                       cal1Delay = " << dec << cal1Delay << endl;
      cout << "                       cal2Delay = " << dec << cal2Delay << endl;
      cout << "                       cal3Delay = " << dec << cal3Delay << endl;
   }
}


// Process config settings
string KpixAsic::writeConfig() {
   uint         cfgTestData;
   uint         cfgAutoReadDis;
   uint         cfgDisableTemp;
   uint         cfgForceTemp;
   uint         cfgAutoStatus;
   bool         ok;
   bool         okAll;
   stringstream err;

   // Get variables
   okAll = true;
   cfgTestData    = variables_["CfgTestData"]->getReg(&ok);    if ( !ok ) okAll = false;
   cfgAutoReadDis = variables_["CfgAutoReadDis"]->getReg(&ok); if ( !ok ) okAll = false;
   cfgForceTemp   = variables_["CfgForceTemp"]->getReg(&ok);   if ( !ok ) okAll = false;
   cfgDisableTemp = variables_["CfgDisableTemp"]->getReg(&ok); if ( !ok ) okAll = false;
   cfgAutoStatus  = variables_["CfgAutoStatus"]->getReg(&ok);  if ( !ok ) okAll = false;

   // Set registers
   registers_["Config"]->set(cfgTestData,0,0x1);
   registers_["Config"]->set(cfgAutoReadDis,2,0x1);
   registers_["Config"]->set(cfgForceTemp,3,0x1);
   registers_["Config"]->set(cfgDisableTemp,4,0x1);
   registers_["Config"]->set(cfgAutoStatus,5,0x1);

   // Error
   err.str("");
   if ( ! okAll ) {
      err << "KpixAsic::writeConfig -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Bad config value detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeConfig -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Bad config value detected" << endl;
   } else {
      if ( debug_ ) {
         cout << "KpixAsic::writeConfig -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " writing config: " << endl;
         cout << "                         cfgTestData    = " << dec << cfgTestData << endl;
         cout << "                         cfgAutoReadDis = " << dec << cfgAutoReadDis << endl;
         cout << "                         cfgForceTemp   = " << dec << cfgForceTemp << endl;
         cout << "                         cfgDisableTemp = " << dec << cfgDisableTemp << endl;
         cout << "                         cfgAutoStatus  = " << dec << cfgAutoStatus << endl;
      }
   }

   return(err.str());
}


void KpixAsic::readConfig() {
   uint cfgTestData;
   uint cfgAutoReadDis;
   uint cfgDisableTemp;
   uint cfgForceTemp;
   uint cfgAutoStatus;

   // Get registers
   cfgTestData    = registers_["Config"]->get(0,0x1);
   cfgAutoReadDis = registers_["Config"]->get(2,0x1);
   cfgForceTemp   = registers_["Config"]->get(3,0x1);
   cfgDisableTemp = registers_["Config"]->get(4,0x1);
   cfgAutoStatus  = registers_["Config"]->get(5,0x1);

   // Set variables
   variables_["CfgTestData"]->setReg(cfgTestData);
   variables_["CfgAutoReadDis"]->setReg(cfgAutoReadDis);
   variables_["CfgForceTemp"]->setReg(cfgForceTemp);
   variables_["CfgDisableTemp"]->setReg(cfgDisableTemp);
   variables_["CfgAutoStatus"]->setReg(cfgAutoStatus);

   // Debug
   if ( debug_ ) {
      cout << "KpixAsic::readConfig -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading config: " << endl;
      cout << "                        cfgTestData    = " << dec << cfgTestData << endl;
      cout << "                        cfgAutoReadDis = " << dec << cfgAutoReadDis << endl;
      cout << "                        cfgForceTemp   = " << dec << cfgForceTemp << endl;
      cout << "                        cfgDisableTemp = " << dec << cfgDisableTemp << endl;
      cout << "                        cfgAutoStatus  = " << dec << cfgAutoStatus << endl;
   }
}


string KpixAsic::writeControl() {
   uint cntrlCalibHigh;
   uint cntrlForceLowGain;
   uint cntrlLeakNullDis;
   uint cntrlDoubleGain;
   uint cntrlNearNeighbor;
   uint cntrlPosPixel;
   uint cntrlDisPerReset;
   uint cntrlEnDcReset;
   uint cntrlCalSource;
   uint cntrlTrigSource;
   uint cntrlShortIntEn;
   uint cntrlDisPwrCycle;
   uint cntrlFeCurr;
   uint cntrlHoldTime;
   uint cntrlDiffTime;
   uint cntrlTrigDisable;
   uint cntrlMonSource;
   bool         ok;
   bool         okAll;
   stringstream err;

   // Get variables
   okAll = true;
   cntrlCalibHigh    = variables_["CntrlCalibHigh"]->getReg(&ok);    if ( !ok ) okAll = false;
   cntrlForceLowGain = variables_["CntrlForceLowGain"]->getReg(&ok); if ( !ok ) okAll = false;
   cntrlLeakNullDis  = variables_["CntrlLeakNullDis"]->getReg(&ok);  if ( !ok ) okAll = false;
   cntrlDoubleGain   = variables_["CntrlDoubleGain"]->getReg(&ok);   if ( !ok ) okAll = false;
   cntrlNearNeighbor = variables_["CntrlNearNeighbor"]->getReg(&ok); if ( !ok ) okAll = false;
   cntrlPosPixel     = variables_["CntrlPosPixel"]->getReg(&ok);     if ( !ok ) okAll = false;
   cntrlDisPerReset  = variables_["CntrlDisPerReset"]->getReg(&ok);  if ( !ok ) okAll = false;
   cntrlEnDcReset    = variables_["CntrlEnDcReset"]->getReg(&ok);    if ( !ok ) okAll = false;
   cntrlCalSource    = variables_["CntrlCalSource"]->getReg(&ok);    if ( !ok ) okAll = false;
   cntrlTrigSource   = variables_["CntrlTrigSource"]->getReg(&ok);   if ( !ok ) okAll = false;
   cntrlShortIntEn   = variables_["CntrlShortIntEn"]->getReg(&ok);   if ( !ok ) okAll = false;
   cntrlDisPwrCycle  = variables_["CntrlDisPwrCycle"]->getReg(&ok);  if ( !ok ) okAll = false;
   cntrlFeCurr       = variables_["CntrlFeCurr"]->getReg(&ok);       if ( !ok ) okAll = false;
   cntrlHoldTime     = variables_["CntrlHoldTime"]->getReg(&ok);     if ( !ok ) okAll = false;
   cntrlDiffTime     = variables_["CntrlDiffTime"]->getReg(&ok);     if ( !ok ) okAll = false;
   cntrlTrigDisable  = variables_["CntrlTrigDisable"]->getReg(&ok);  if ( !ok ) okAll = false;
   cntrlMonSource    = variables_["CntrlMonSource"]->getReg(&ok);    if ( !ok ) okAll = false;

   // Set registers
   registers_["Control"]->set(cntrlCalibHigh,11,0x1);
   registers_["Control"]->set(cntrlForceLowGain,13,0x1);
   registers_["Control"]->set(cntrlLeakNullDis,14,0x1);
   registers_["Control"]->set(cntrlDoubleGain,2,0x1);
   registers_["Control"]->set(cntrlNearNeighbor,3,0x1);
   registers_["Control"]->set(cntrlPosPixel,15,0x1);
   registers_["Control"]->set(cntrlDisPerReset,0,0x1);
   registers_["Control"]->set(cntrlEnDcReset,1,0x1);
   registers_["Control"]->set(cntrlShortIntEn,12,0x1);
   registers_["Control"]->set(cntrlDisPwrCycle,24,0x1);
   registers_["Control"]->set(cntrlFeCurr,25,0x7);
   registers_["Control"]->set(cntrlHoldTime,8,0x7);
   registers_["Control"]->set(cntrlDiffTime,28,0x1);
   registers_["Control"]->set(cntrlTrigDisable,16,0x1);

   // Cal source
   registers_["Control"]->set((cntrlCalSource&0x1),6,0x1);      // bit 6 = internal
   registers_["Control"]->set(((cntrlCalSource>>1)&0x1),4,0x1); // bit 4 = external
  
   // Trig source
   registers_["Control"]->set((cntrlTrigSource&0x1),7,0x1);      // bit 6 = internal
   registers_["Control"]->set(((cntrlTrigSource>>1)&0x1),5,0x1); // bit 4 = external

   // Mon source
   registers_["Control"]->set(((cntrlMonSource>>1)&0x1),30,0x1); // bit 30 = Shaper
   registers_["Control"]->set((cntrlMonSource&0x1),31,0x1);      // bit 31 = Amp

   // Error
   err.str("");
   if ( ! okAll ) {
      err << "KpixAsic::writeControl -> Address 0x" << hex << setw(4) << setfill('0') << address_
          << " Bad control value detected" << endl;
      if ( debug_ ) cout << "KpixAsic::writeControl -> Address 0x" << hex << setw(4) << setfill('0') << address_
                         << " Bad control value detected" << endl;
   } else {
      if ( debug_ ) {
         cout << "KpixAsic::writeControl -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " writing control: " << endl;
         cout << "                          cntrlCalibHigh    = " << dec << cntrlCalibHigh << endl;
         cout << "                          cntrlForceLowGain = " << dec << cntrlForceLowGain << endl;
         cout << "                          cntrlLeakNullDis  = " << dec << cntrlLeakNullDis << endl;
         cout << "                          cntrlDoubleGain   = " << dec << cntrlDoubleGain << endl;
         cout << "                          cntrlNearNeighbor = " << dec << cntrlNearNeighbor << endl;
         cout << "                          cntrlPosPixel     = " << dec << cntrlPosPixel << endl;
         cout << "                          cntrlDisPerReset  = " << dec << cntrlDisPerReset << endl;
         cout << "                          cntrlEnDcReset    = " << dec << cntrlEnDcReset << endl;
         cout << "                          cntrlCalSource    = " << dec << cntrlCalSource << endl;
         cout << "                          cntrlTrigSource   = " << dec << cntrlTrigSource << endl;
         cout << "                          cntrlShortIntEn   = " << dec << cntrlShortIntEn << endl;
         cout << "                          cntrlDisPwrCycle  = " << dec << cntrlDisPwrCycle << endl;
         cout << "                          cntrlFeCurr       = " << dec << cntrlFeCurr << endl;
         cout << "                          cntrlHoldTime     = " << dec << cntrlHoldTime << endl;
         cout << "                          cntrlDiffTime     = " << dec << cntrlDiffTime << endl;
         cout << "                          cntrlTrigDisable  = " << dec << cntrlTrigDisable << endl;
         cout << "                          cntrlMonSource    = " << dec << cntrlMonSource << endl;
      }
   }

   return(err.str());
}


void KpixAsic::readControl() {
   uint cntrlCalibHigh;
   uint cntrlForceLowGain;
   uint cntrlLeakNullDis;
   uint cntrlDoubleGain;
   uint cntrlNearNeighbor;
   uint cntrlPosPixel;
   uint cntrlDisPerReset;
   uint cntrlEnDcReset;
   uint cntrlCalSource;
   uint cntrlTrigSource;
   uint cntrlShortIntEn;
   uint cntrlDisPwrCycle;
   uint cntrlFeCurr;
   uint cntrlHoldTime;
   uint cntrlDiffTime;
   uint cntrlTrigDisable;
   uint cntrlMonSource;

   // Get registers
   cntrlCalibHigh    = registers_["Control"]->get(11,0x1);
   cntrlForceLowGain = registers_["Control"]->get(13,0x1);
   cntrlLeakNullDis  = registers_["Control"]->get(14,0x1);
   cntrlDoubleGain   = registers_["Control"]->get(2,0x1);
   cntrlNearNeighbor = registers_["Control"]->get(3,0x1);
   cntrlPosPixel     = registers_["Control"]->get(15,0x1);
   cntrlDisPerReset  = registers_["Control"]->get(0,0x1);
   cntrlEnDcReset    = registers_["Control"]->get(1,0x1);
   cntrlShortIntEn   = registers_["Control"]->get(12,0x1);
   cntrlDisPwrCycle  = registers_["Control"]->get(24,0x1);
   cntrlFeCurr       = registers_["Control"]->get(25,0x7);
   cntrlHoldTime     = registers_["Control"]->get(8,0x7);
   cntrlDiffTime     = registers_["Control"]->get(28,0x1);
   cntrlTrigDisable  = registers_["Control"]->get(16,0x1);

   // Cal source
   cntrlCalSource = 0;
   if ( registers_["Control"]->get(6,0x1) == 1 ) cntrlCalSource = 1;
   if ( registers_["Control"]->get(4,0x1) == 1 ) cntrlCalSource = 2;
  
   // Trig source
   cntrlTrigSource = 0;
   if ( registers_["Control"]->get(7,0x1) == 1 ) cntrlTrigSource = 1;
   if ( registers_["Control"]->get(5,0x1) == 1 ) cntrlTrigSource = 2;

   // Mon source
   cntrlMonSource = 0;
   if ( registers_["Control"]->get(30,0x1) == 1 ) cntrlMonSource = 2;
   if ( registers_["Control"]->get(31,0x1) == 1 ) cntrlMonSource = 1;

   // Set variables
   variables_["CntrlCalibHigh"]->setReg(cntrlCalibHigh);
   variables_["CntrlForceLowGain"]->setReg(cntrlForceLowGain);
   variables_["CntrlLeakNullDis"]->setReg(cntrlLeakNullDis);
   variables_["CntrlDoubleGain"]->setReg(cntrlDoubleGain);
   variables_["CntrlNearNeighbor"]->setReg(cntrlNearNeighbor);
   variables_["CntrlPosPixel"]->setReg(cntrlPosPixel);
   variables_["CntrlDisPerReset"]->setReg(cntrlDisPerReset);
   variables_["CntrlEnDcReset"]->setReg(cntrlEnDcReset);
   variables_["CntrlCalSource"]->setReg(cntrlCalSource);
   variables_["CntrlTrigSource"]->setReg(cntrlTrigSource);
   variables_["CntrlShortIntEn"]->setReg(cntrlShortIntEn);
   variables_["CntrlDisPwrCycle"]->setReg(cntrlDisPwrCycle);
   variables_["CntrlFeCurr"]->setReg(cntrlFeCurr);
   variables_["CntrlHoldTime"]->setReg(cntrlHoldTime);
   variables_["CntrlDiffTime"]->setReg(cntrlDiffTime);
   variables_["CntrlTrigDisable"]->setReg(cntrlTrigDisable);
   variables_["CntrlMonSource"]->setReg(cntrlMonSource);

   // Debug
   if ( debug_ ) {
      cout << "KpixAsic::readControl -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading control: " << endl;
      cout << "                         cntrlCalibHigh    = " << dec << cntrlCalibHigh << endl;
      cout << "                         cntrlForceLowGain = " << dec << cntrlForceLowGain << endl;
      cout << "                         cntrlLeakNullDis  = " << dec << cntrlLeakNullDis << endl;
      cout << "                         cntrlDoubleGain   = " << dec << cntrlDoubleGain << endl;
      cout << "                         cntrlNearNeighbor = " << dec << cntrlNearNeighbor << endl;
      cout << "                         cntrlPosPixel     = " << dec << cntrlPosPixel << endl;
      cout << "                         cntrlDisPerReset  = " << dec << cntrlDisPerReset << endl;
      cout << "                         cntrlEnDcReset    = " << dec << cntrlEnDcReset << endl;
      cout << "                         cntrlCalSource    = " << dec << cntrlCalSource << endl;
      cout << "                         cntrlTrigSource   = " << dec << cntrlTrigSource << endl;
      cout << "                         cntrlShortIntEn   = " << dec << cntrlShortIntEn << endl;
      cout << "                         cntrlDisPwrCycle  = " << dec << cntrlDisPwrCycle << endl;
      cout << "                         cntrlFeCurr       = " << dec << cntrlFeCurr << endl;
      cout << "                         cntrlHoldTime     = " << dec << cntrlHoldTime << endl;
      cout << "                         cntrlDiffTime     = " << dec << cntrlDiffTime << endl;
      cout << "                         cntrlTrigDisable  = " << dec << cntrlTrigDisable << endl;
      cout << "                         cntrlMonSource    = " << dec << cntrlMonSource << endl;
   }
}


void KpixAsic::readStatus() {
   uint statCmdPerr;
   uint statDataPerr;
   uint statTempEn;
   uint statTempIdValue;

   // Get registers
   statCmdPerr     = registers_["Status"]->get(0,0x1);
   statDataPerr    = registers_["Status"]->get(1,0x1);
   statTempEn      = registers_["Status"]->get(2,0x1);
   statTempIdValue = registers_["Status"]->get(24,0xFF);

   // Set variables
   variables_["StatCmdPerr"]->setReg(statCmdPerr);
   variables_["StatDataPerr"]->setReg(statDataPerr);
   variables_["StatTempEn"]->setReg(statTempEn);
   variables_["StatTempIdValue"]->setReg(statTempIdValue);

   // Debug
   if ( debug_ ) {
      cout << "KpixAsic::readStatus -> Address 0x" << hex << setw(4) << setfill('0') << address_ << " reading status: " << endl;
      cout << "                        statCmdPerr     = " << dec << statCmdPerr << endl;
      cout << "                        statDataPerr    = " << dec << statDataPerr << endl;
      cout << "                        statTempEn      = " << dec << statTempEn << endl;
      cout << "                        statTempIdValue = " << dec << statTempIdValue << endl;
   }
}


//! Method to read variables from registers
string KpixAsic::read() {

   // Process registers
   readTiming();
   readDacs();
   readCalib();
   readConfig();
   readControl();
   readChanMode();
   readStatus();
   
   // Return XML string
   return(Device::read());
}


//! Method to write variables to registers
string KpixAsic::write( string xml ) {
   stringstream err;

   // Process xml string
   Device::write(xml);

   // Process registers
   err << writeTiming();
   err << writeDacs();
   err << writeCalib();
   err << writeConfig();
   err << writeControl();
   err << writeChanMode();

   // Return errors
   return(err.str());
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

