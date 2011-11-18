//-----------------------------------------------------------------------------
// File          : KpixAsic.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/17/2011
// Project       : Kpix ASIC
//-----------------------------------------------------------------------------
// Description :
// Kpix ASIC container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/17/2011: created
//-----------------------------------------------------------------------------
#include <KpixAsic.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixAsic::KpixAsic ( uint destination, uint baseAddress, uint index, uint version, bool dummy ) : 
                     Device(destination,baseAddress,"kpixAsic",index) {

   // Description
   desc_    = "Kpix ASIC Object.";
   dummy_   = dummy;
   version_ = version;

   // Setup registers & variables

   // Serial number & variable
   addVariable(new Variable("SerialNumber", Variable::Configuration));
   variables_["SerialNumber"]->setDescription("ASIC serial number");

   // Status register & variables
   addRegister(new Register("Status", baseAddress_ + 0x00000000));

   addVariable(new Variable("StatCmdPerr", Variable::Status));
   variables_["StatCmdPerr"]->setDescription("Command header parity error");

   addVariable(new Variable("StatDataPerr", Variable::Status));
   variables_["StatDataPerr"]->setDescription("Command data parity error");

   addVariable(new Variable("StatTempEn", Variable::Status));
   variables_["StatTempEn"]->setDescription("Temperature read enable");

   addVariable(new Variable("StatTempIdValue", Variable::Status));
   variables_["StatTempIdValue"]->setDescription("Temperature or ID value");

   // Config register & variables
   addRegister(new Register("Config", baseAddress_ + 0x00000001));

   addVariable(new Variable("CfgTestDataEn",Variable::Configuration));
   variables_["CfgTestDataEn"]->setDescription("Enable test data");
   variables_["CfgTestDataEn"]->setTrueFalse();

   addVariable(new Variable("CfgAutoReadDisable",Variable::Configuration));
   variables_["CfgAutoReadDisable"]->setDescription("Disable auto data readout");
   variables_["CfgAutoReadDisable"]->setTrueFalse();

   addVariable(new Variable("CfgForceTemp",Variable::Configuration));
   variables_["CfgForceTemp"]->setDescription("Force temperature power on");
   variables_["CfgForceTemp"]->setTrueFalse();

   addVariable(new Variable("CfgDisableTemp",Variable::Configuration));
   variables_["CfgDisableTemp"]->setDescription("Disable temperature power on");
   variables_["CfgDisableTemp"]->setTrueFalse();

   addVariable(new Variable("CfgAutoStatusRdEn",Variable::Configuration));
   variables_["CfgAutoStatusReadEn"]->setDescription("Enable auto status register read with data");
   variables_["CfgAutoStatusReadEn"]->setTrueFalse();

   // Timing registers & variables
   addRegister(new Register("TimerA", baseAddress_ + 0x00000008));
   addRegister(new Register("TimerB", baseAddress_ + 0x00000009));
   addRegister(new Register("TimerC", baseAddress_ + 0x0000000a));
   addRegister(new Register("TimerD", baseAddress_ + 0x0000000b));
   addRegister(new Register("TimerE", baseAddress_ + 0x0000000c));
   addRegister(new Register("TimerF", baseAddress_ + 0x0000000d));
   addRegister(new Register("TimerG", baseAddress_ + 0x0000000e));
   addRegister(new Register("TimerH", baseAddress_ + 0x0000000f));

   addVariable(new Variable("TimeResetOn",Variable::Configuration));
   variables_["TimeResetOn"]->setDescription("Reset assertion delay from run start");
   variables_["TimeResetOn"]->setComp(1,50,0,"nS");

   addVariable(new Variable("TimeResetOff",Variable::Configuration));
   variables_["TimeResetOff"]->setDescription("Reset de-assertion delay from run start");
   variables_["TimeResetOff"]->setComp(1,50,0,"nS");

   addVariable(new Variable("TimeLeakageNullOff",Variable::Configuration));
   variables_["TimeLeakageNullOff"]->setDescription("LeakageNull signal turn off delay from run start");
   variables_["TimeLeakageNullOff"]->setComp(1,50,0,"nS");

   addVariable(new Variable("TimeOffsetNullOff",Variable::Configuration));
   variables_["TimeOffsetNullOff"]->setDescription("OffsetNull signal turn off delay from run start");
   variables_["TimeOffsetNullOff"]->setComp(1,50,0,"nS");

   addVariable(new Variable("TimeThreshOff",Variable::Configuration));
   variables_["TimeThreshOff"]->setDescription("Threshold signal turn off delay from run start");
   variables_["TimeThreshOff"]->setComp(1,50,0,"nS");

   addVariable(new Variable("TrigInhibitOff",Variable::Configuration));
   variables_["TrigInhibitOff"]->setDescription("Trigger inhibit turn off bunch crossing");
   variables_["TrigInhibitOff"]->setComp(0,1,0,"");

   addVariable(new Variable("TimePowerUpOn",Variable::Configuration));
   variables_["TimePowerUpOn"]->setDescription("Power up delay from run start");
   variables_["TimePowerUpOn"]->setComp(0,50,0,"nS");

   addVariable(new Variable("TimeDeselDelay",Variable::Configuration));
   variables_["TimeDeselDelay"]->setDescription("Deselect sequence delay from run start");
   variables_["TimeDeselDelay"]->setComp(0,50,0,"nS");

   addVariable(new Variable("TimeBunchClkDelay",Variable::Configuration));
   variables_["TimeBunchClkDelay"]->setDescription("Bunch clock start delay from from run start");
   variables_["TimeBunchClkDelay"]->setComp(0,50,0,"nS");

   addVariable(new Variable("TimeDigitizeDelay",Variable::Configuration));
   variables_["TimeDigitizeDelay"]->setDescription("Digitization delay after power down");
   variables_["TimeDigitizeDelay"]->setComp(0,50,0,"nS");

   addVariable(new Variable("BunchClockCount",Variable::Configuration));
   variables_["BunchCLockCount"]->setDescription("Bunch cock count");
   variables_["BunchClockCount"]->setComp(0,1,0,"");

   // Calibration control registers & variables
   addRegister(new Register("CalDelay0", baseAddress_ + 0x00000010));
   addRegister(new Register("CalDelay1", baseAddress_ + 0x00000011));

   addVariable(new Variable("CalCount",Variable::Configuration));
   variables_["CalCount"]->setDescription("Calibration injection count");
   vector<string> calCounts;
   calCounts.resize(5);
   calCounts[0] = "0";
   calCounts[1] = "1";
   calCounts[2] = "2";
   calCounts[3] = "3";
   calCounts[4] = "4";
   variables_["CalCount"]->setEnums(calCounts);

   addVariable(new Variable("Cal0Delay",Variable::Configuration));
   variables_["Cal0Delay"]->setDescription("Calibration injection 0 delay in bunch crossings");
   variables_["Cal0Delay"]->setComp(1,400,0,"nS");

   addVariable(new Variable("Cal1Delay",Variable::Configuration));
   variables_["Cal1Delay"]->setDescription("Calibration injection 1 delay in bunch crossings");
   variables_["Cal1Delay"]->setComp(1,400,0,"nS");

   addVariable(new Variable("Cal2Delay",Variable::Configuration));
   variables_["Cal2Delay"]->setDescription("Calibration injection 2 delay in bunch crossings");
   variables_["Cal2Delay"]->setComp(1,400,0,"nS");

   addVariable(new Variable("Cal3Delay",Variable::Configuration));
   variables_["Cal3Delay"]->setDescription("Calibration injection 3 delay in bunch crossings");
   variables_["Cal3Delay"]->setComp(0,400,0,"nS");

   // DAC registers and variables
   addRegister(new Register("Dac0", baseAddress_ + 0x00000020));
   addRegister(new Register("Dac1", baseAddress_ + 0x00000021));
   addRegister(new Register("Dac2", baseAddress_ + 0x00000022));
   addRegister(new Register("Dac3", baseAddress_ + 0x00000023));
   addRegister(new Register("Dac4", baseAddress_ + 0x00000024));
   addRegister(new Register("Dac5", baseAddress_ + 0x00000025));
   addRegister(new Register("Dac6", baseAddress_ + 0x00000026));
   addRegister(new Register("Dac7", baseAddress_ + 0x00000027));
   addRegister(new Register("Dac8", baseAddress_ + 0x00000028));
   addRegister(new Register("Dac9", baseAddress_ + 0x00000029));

   addVariable(new Variable("DacThresholdA",Variable::Configuration));
   variables_["DacThresholdA"]->setDescription("Trigger Threshold A dac\nDAC 0/8");

   addVariable(new Variable("DacThresholdAVolt",Variable::Feedback));
   variables_["DacThresholdAVolt"]->setDescription("Trigger Threshold A dac voltage feedback\nDAC 0/8");

   addVariable(new Variable("DacThresholdB",Variable::Configuration));
   variables_["DacThresholdB"]->setDescription("Trigger Threshold B dac\nDAC 1/9");

   addVariable(new Variable("DacThresholdBVolt",Variable::Feedback));
   variables_["DacThresholdBVolt"]->setDescription("Trigger Threshold B dac voltage feedback\nDAC 1/9");

   addVariable(new Variable("DacRampThresh",Variable::Configuration));
   variables_["DacRampThresh"]->setDescription("Ramp threshold dac\nDAC 2");

   addVariable(new Variable("DacRampThreshVolt",Variable::Feedback));
   variables_["DacRampThreshVolt"]->setDescription("Ramp threshold dac voltage feedback\nDAC 2");

   addVariable(new Variable("DacRangeThreshold",Variable::Configuration));
   variables_["DacRangeThreshold"]->setDescription("Range threshold dac\nDAC 3");

   addVariable(new Variable("DacRangeThresholdVolt",Variable::Feedback));
   variables_["DacRangeThresholdVolt"]->setDescription("Range threshold dac voltage feedback\nDAC 3");

   addVariable(new Variable("DacCalibration",Variable::Configuration));
   variables_["DacCalibration"]->setDescription("Calibration dac\nDAC 4");

   addVariable(new Variable("DacCalibrationVolt",Variable::Feedback));
   variables_["DacCalibrationVolt"]->setDescription("Calibration dac voltage feedback\nDAC 4");

   addVariable(new Variable("DacCalibrationCharge",Variable::Feedback));
   variables_["DacCalibrationCharge"]->setDescription("Calibration dac charge");

   addVariable(new Variable("DacEventThreshold",Variable::Configuration));
   variables_["DacEventThreshold"]->setDescription("Event threshold dac\nDAC 5");

   addVariable(new Variable("DacEventThresholdVoltage",Variable::Feedback));
   variables_["DacEventThresholdVoltage"]->setDescription("Event threshold dac voltage feedback\nDAC 5");

   addVariable(new Variable("DacShaperBias",Variable::Configuration));
   variables_["DacShaperBias"]->setDescription("Shaper bias dac\nDAC 6");

   addVariable(new Variable("DacShaperBiasVolt",Variable::Configuration));
   variables_["DacShaperBiasVolt"]->setDescription("Shaper bias dac voltage feedback\nDAC 6");

   addVariable(new Variable("DacDefaultAnalog",Variable::Configuration));
   variables_["DacDefaultAnalog"]->setDescription("Default analog bus dac\nDAC 7");

   addVariable(new Variable("DacDefaultAnalogVolt",Variable::Configuration));
   variables_["DacDefaultAnalogVolt"]->setDescription("Default analog bus dac voltage feedback\nDAC 7");

   // Control register and variables
   addRegister(new Register("Control", baseAddress_ + 0x00000030));

   addVariable(new Variable("CntrlCalibHigh",Variable::Configuration));
   variables_["CntrlCalibHigh"]->setDescription("Force bucket 0 high range calibration");
   variables_["CntrlCalibHigh"]->setTrueFalse();

   addVariable(new Variable("CntrlCalibHigh",Variable::Configuration));
   variables_["CntrlCalibHigh"]->setDescription("Force bucket 0 high range calibration");
   variables_["CntrlCalibHigh"]->setTrueFalse();

   addVariable(new Variable("CntrlForceLowGain",Variable::Configuration));
   variables_["CntrlForceLowGain"]->setDescription("Force low gain");
   variables_["CntrlForceLowGain"]->setTrueFalse();

   addVariable(new Variable("CntrlLeakNullDisable",Variable::Configuration));
   variables_["CntrlLeakNullDisable"]->setDescription("Disable leakage null compensation");
   variables_["CntrlLeakNullDisable"]->setTrueFalse();

   addVariable(new Variable("CntrlHighGain",Variable::Configuration));
   variables_["CntrlHighGain"]->setDescription("Enable high gain");
   variables_["CntrlHighGain"]->setTrueFalse();

   addVariable(new Variable("CntrlNearNeighbor",Variable::Configuration));
   variables_["CntrlNearNeighbor"]->setDescription("Enable neareast neighbor trigger logic");
   variables_["CntrlNearNeighbor"]->setTrueFalse();

   addVariable(new Variable("CntrlPolarity",Variable::Configuration));
   variables_["CntrlPolarity"]->setDescription("Set input polarity");
   vector<string> pol;
   pol.resize(5);
   pol[0] = "Negative";
   pol[1] = "Positive";
   variables_["CntrlPolarity"]->setEnums(pol);

   addVariable(new Variable("CntrlDisPerReset",Variable::Configuration));
   variables_["CntrlDisPerReset"]->setDescription("Disable periodic reset circuitry");
   variables_["CntrlDisPerReset"]->setTrueFalse();

   addVariable(new Variable("CntrlEnDcReset",Variable::Configuration));
   variables_["CntrlEnDcReset"]->setDescription("Enable DC reset circuitry");
   variables_["CntrlEnDcReset"]->setTrueFalse();

   addVariable(new Variable("CntrlCalSource",Variable::Configuration));
   variables_["CntrlCalSource"]->setDescription("Set calibration pulse source");
   src.resize(3);
   src[0] = "Disable";
   src[1] = "Internal";
   src[2] = "External";
   variables_["CntrlCalSource"]->setEnums(src);

   addVariable(new Variable("CntrlForceTrigSource",Variable::Configuration));
   variables_["CntrlForceTrigSource"]->setDescription("Set force trigger source");
   src.resize(3);
   src[0] = "Disable";
   src[1] = "Internal";
   src[2] = "External";
   variables_["CntrlForceTrigSource"]->setEnums(src);

   addVariable(new Variable("CntrlShortIntEn",Variable::Configuration));
   variables_["CntrlShortIntEn"]->setDescription("Short integration enable");
   variables_["CntrlShortIntEn"]->setTrueFalse();

   addVariable(new Variable("CntrlDisPwrCycle",Variable::Configuration));
   variables_["CntrlDisPwrCycle"]->setDescription("Disable power cycle");
   variables_["CntrlDisPwrCycle"]->setTrueFalse();

   addVariable(new Variable("CntrlFeCurr",Variable::Configuration));
   variables_["CntrlFeCurr"]->setDescription("Set front end current");
   curr.resize(8);
   curr[0] = "1uA";
   curr[1] = "31uA";
   curr[2] = "61uA";
   curr[3] = "91uA";
   curr[4] = "121uA";
   curr[5] = "151uA";
   curr[6] = "181uA";
   curr[7] = "211uA";
   variables_["CntrlFeCurr"]->setEnums(curr);

   addVariable(new Variable("CntrlHoldTime",Variable::Configuration));
   variables_["CntrlHoldTime"]->setDescription("Set shaper hold time");
   holdTime.resize(8);
   holdTime[0] = "8x";
   holdTime[1] = "16x";
   holdTime[2] = "24x";
   holdTime[3] = "32x";
   holdTime[4] = "40x";
   holdTime[5] = "48x";
   holdTime[6] = "56x";
   holdTime[7] = "64x";
   variables_["CntrlHoldTime"]->setEnums(holdTime);

   addVariable(new Variable("CntrlDiffTime",Variable::Configuration));
   variables_["CntrlDiffTime"]->setDescription("Set shaper differentiation time");
   diffTime.resize(4);
   diffTime[0] = "Normal";
   diffTime[1] = "Half";
   diffTime[2] = "Third";
   diffTime[3] = "Quarter";
   variables_["CntrlDiffTime"]->setEnums(diffTime);

   addVariable(new Variable("CntrlMonSource", Variable::Configuration));
   variables_["CntrlMonSource"]->setDescription("Set monitor port source");
   monSource.resize(3);
   monSource[0] = "None";
   monSource[1] = "Amp";
   monSource[2] = "Shaper
   variables_["CntrlMonSource"]->setEnums(monSource);

   addVariable(new Variable("CntrlTrigDisable", Variable::Configuration));
   variables_["CntrlTrigDisable"]->setDescription("Disable self trigger");

   // Add channels
   for (int i=0; i < 1024; i++) addDevice(new KpixChannel(i));
}

// Deconstructor
KpixAsic::~KpixAsic ( ) { }

// Method to process a command
string KpixAsic::command ( string name, string arg) {
   stringstream tmp;
   tmp.str("");
   tmp << "<" << name << ">Success</" << name << ">" << endl;
/*
   // Command is local
   if ( name == "MasterReset" ) {
      registers_["MasterReset"]->set(0x1);
      writeRegister(registers_["MasterReset"],true,false);
      return(tmp.str());
   }
   else if ( name == "Apv25Reset" ) {
      registers_["Apv25Reset"]->set(0x1);
      writeRegister(registers_["Apv25Reset"],true);
      return(tmp.str());
   }
   else if ( name == "Apv25HardReset" ) {
      registers_["ApvHardReset"]->set(0x1);
      writeRegister(registers_["ApvHardReset"],true);
      return(tmp.str());
   }
   else return(Device::command(name, arg));
   */
   return(Device::command(name, arg));
}

// Method to read status registers and update variables
void KpixAsic::readStatus ( bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;


   // Sub devices
   //Device::readStatus(subEnable);
}

// Method to read configuration registers and update variables
void KpixAsic::readConfig ( bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;


   // Sub devices
   //Device::readConfig(subEnable);
}

// Method to write configuration registers
void KpixAsic::writeConfig ( bool force, bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;


   // Sub devices
   //Device::writeConfig(force,subEnable);
}

// Verify hardware state of configuration
string KpixAsic::verifyConfig ( bool subEnable, string input ) {
   stringstream ret;
   ret.str("");

   if ( getInt("enabled") == 0 ) return("");

   //ret << verifyRegister(registers_["ScratchPad"]);
   //ret << verifyRegister(registers_["AdcChanEn"]);
   //ret << verifyRegister(registers_["ApvMux"]);
   //ret << verifyRegister(registers_["ApvMux"]);
   //ret << verifyRegister(registers_["ApvTrigSrcType"]);
   //ret << verifyRegister(registers_["ApvTrigGenCnt"]);
   //ret << verifyRegister(registers_["ApvTrigGenPause"]);
   //ret << verifyRegister(registers_["ApvSampleThresh"]);
   //ret << verifyRegister(registers_["CalDelay"]);

   //ret << input;
   //return(Device::verifyConfig(subEnable,ret.str()));
}

