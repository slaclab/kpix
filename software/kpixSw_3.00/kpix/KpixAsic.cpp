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

// Function to convert dac value into a voltage
double KpixAsic::dacToVolt(uint dac) {
   double       volt;

   // Change to voltage
   if ( dac >= 0xf6 ) volt = 2.5 - ((double)(0xff-dac))*50.0*0.0001;
   else volt =(double)dac * 100.0 * 0.0001;

   return(volt);
}

// Function to convert dac value into a voltage
string KpixAsic::dacToVoltString(uint dac) {
   stringstream tmp;
   tmp.str("");
   tmp << dacToVolt(dac) << " V";
   return(tmp.str());
}

// Channel count
uint KpixAsic::channels() {
   if ( dummy_ ) return(0);
   switch(variables_["Version"]->getInt()) {
      case  9: return(512);  break;
      case 10: return(1024); break;
      default: return(0);    break;
   }
}

// Constructor
KpixAsic::KpixAsic ( uint destination, uint baseAddress, uint index, bool dummy, Device *parent ) : 
                     Device(destination,baseAddress,"kpixAsic",index,parent) {
   stringstream tmp;
   uint         x;

   // Description
   desc_    = "Kpix ASIC Object.";
   dummy_   = dummy;

   // Version value
   addVariable(new Variable("Version", Variable::Configuration));
   variables_["Version"]->setDescription("KPIX Version");
   variables_["Version"]->setComp(0,1,0,"");

   // Serial number & variable
   addVariable(new Variable("SerialNumber", Variable::Configuration));
   variables_["SerialNumber"]->setDescription("ASIC serial number");
   variables_["SerialNumber"]->setPerInstance(true);
   variables_["SerialNumber"]->setComp(0,1,0,"");

   // Status register & variables
   addRegister(new Register("Status", baseAddress_ + 0x00000000));

   addVariable(new Variable("StatCmdPerr", Variable::Status));
   variables_["StatCmdPerr"]->setDescription("Command header parity error");
   variables_["StatCmdPerr"]->setComp(0,1,0,"");

   addVariable(new Variable("StatDataPerr", Variable::Status));
   variables_["StatDataPerr"]->setDescription("Command data parity error");
   variables_["StatDataPerr"]->setComp(0,1,0,"");

   addVariable(new Variable("StatTempEn", Variable::Status));
   variables_["StatTempEn"]->setDescription("Temperature read enable");

   addVariable(new Variable("StatTempIdValue", Variable::Status));
   variables_["StatTempIdValue"]->setDescription("Temperature or ID value");

// HERE

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

   addVariable(new Variable("CfgAutoStatusReadEn",Variable::Configuration));
   variables_["CfgAutoStatusReadEn"]->setDescription("Enable auto status register read with data");
   variables_["CfgAutoStatusReadEn"]->setTrueFalse();

   // Timing registers & variables
   addRegister(new Register("TimerA", baseAddress_ + 0x00000008));
   addRegister(new Register("TimerB", baseAddress_ + 0x00000009));
   addRegister(new Register("TimerC", baseAddress_ + 0x0000000a));
   addRegister(new Register("TimerD", baseAddress_ + 0x0000000b));
   addRegister(new Register("TimerE", baseAddress_ + 0x0000000c));
   addRegister(new Register("TimerF", baseAddress_ + 0x0000000d));
   //addRegister(new Register("TimerG", baseAddress_ + 0x0000000e));
   //addRegister(new Register("TimerH", baseAddress_ + 0x0000000f));

   addVariable(new Variable("TimeResetOn",Variable::Configuration));
   variables_["TimeResetOn"]->setDescription("Reset assertion delay from run start");
   variables_["TimeResetOn"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeResetOn"]->setRange(0,65535);

   addVariable(new Variable("TimeResetOff",Variable::Configuration));
   variables_["TimeResetOff"]->setDescription("Reset de-assertion delay from run start");
   variables_["TimeResetOff"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeResetOff"]->setRange(0,65535);

   addVariable(new Variable("TimeLeakageNullOff",Variable::Configuration));
   variables_["TimeLeakageNullOff"]->setDescription("LeakageNull signal turn off delay from run start");
   variables_["TimeLeakageNullOff"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeLeakageNullOff"]->setRange(0,65535);

   addVariable(new Variable("TimeOffsetNullOff",Variable::Configuration));
   variables_["TimeOffsetNullOff"]->setDescription("OffsetNull signal turn off delay from run start");
   variables_["TimeOffsetNullOff"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeOffsetNullOff"]->setRange(0,65535);

   addVariable(new Variable("TimeThreshOff",Variable::Configuration));
   variables_["TimeThreshOff"]->setDescription("Threshold signal turn off delay from run start");
   variables_["TimeThreshOff"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeThreshOff"]->setRange(0,65535);

   addVariable(new Variable("TrigInhibitOff",Variable::Configuration));
   variables_["TrigInhibitOff"]->setDescription("Trigger inhibit turn off bunch crossing");
   variables_["TrigInhibitOff"]->setComp(0,1,0,"");
   variables_["TrigInhibitOff"]->setRange(0,8191);

   addVariable(new Variable("TimePowerUpOn",Variable::Configuration));
   variables_["TimePowerUpOn"]->setDescription("Power up delay from run start");
   variables_["TimePowerUpOn"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimePowerUpOn"]->setRange(0,65535);

   addVariable(new Variable("TimeDeselDelay",Variable::Configuration));
   variables_["TimeDeselDelay"]->setDescription("Deselect sequence delay from run start");
   variables_["TimeDeselDelay"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeDeselDelay"]->setRange(0,255);

   addVariable(new Variable("TimeBunchClkDelay",Variable::Configuration));
   variables_["TimeBunchClkDelay"]->setDescription("Bunch clock start delay from from run start");
   variables_["TimeBunchClkDelay"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeBunchClkDelay"]->setRange(0,65535);

   addVariable(new Variable("TimeDigitizeDelay",Variable::Configuration));
   variables_["TimeDigitizeDelay"]->setDescription("Digitization delay after power down");
   variables_["TimeDigitizeDelay"]->setComp(1,KpixAcqPeriod,0,"nS (@50nS)");
   variables_["TimeDigitizeDelay"]->setRange(0,255);

   addVariable(new Variable("BunchClockCount",Variable::Configuration));
   variables_["BunchClockCount"]->setDescription("Bunch cock count");
   variables_["BunchClockCount"]->setComp(0,1,1,"");
   variables_["BunchClockCount"]->setRange(0,8191);

   // Calibration control registers & variables
   addRegister(new Register("CalDelay0", baseAddress_ + 0x00000010));
   addRegister(new Register("CalDelay1", baseAddress_ + 0x00000011));

   addVariable(new Variable("CalCount",Variable::Configuration));
   variables_["CalCount"]->setDescription("Calibration injection count");
   variables_["CalCount"]->setRange(0,4);

   addVariable(new Variable("Cal0Delay",Variable::Configuration));
   variables_["Cal0Delay"]->setDescription("Calibration injection 0 delay in bunch crossings");
   variables_["Cal0Delay"]->setComp(1,400,0,"nS");
   variables_["Cal0Delay"]->setRange(0,4095);

   addVariable(new Variable("Cal1Delay",Variable::Configuration));
   variables_["Cal1Delay"]->setDescription("Calibration injection 1 delay in bunch crossings");
   variables_["Cal1Delay"]->setComp(1,400,0,"nS");
   variables_["Cal1Delay"]->setRange(0,4095);

   addVariable(new Variable("Cal2Delay",Variable::Configuration));
   variables_["Cal2Delay"]->setDescription("Calibration injection 2 delay in bunch crossings");
   variables_["Cal2Delay"]->setComp(1,400,0,"nS");
   variables_["Cal2Delay"]->setRange(0,4095);

   addVariable(new Variable("Cal3Delay",Variable::Configuration));
   variables_["Cal3Delay"]->setDescription("Calibration injection 3 delay in bunch crossings");
   variables_["Cal3Delay"]->setComp(0,400,0,"nS");
   variables_["Cal3Delay"]->setRange(0,4095);

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
   variables_["DacThresholdA"]->setPerInstance(true);
   variables_["DacThresholdA"]->setRange(0,255);

   addVariable(new Variable("DacThresholdAVolt",Variable::Feedback));
   variables_["DacThresholdAVolt"]->setDescription("Trigger Threshold A dac voltage feedback\nDAC 0/8");
   variables_["DacThresholdAVolt"]->setPerInstance(true);

   addVariable(new Variable("DacThresholdB",Variable::Configuration));
   variables_["DacThresholdB"]->setDescription("Trigger Threshold B dac\nDAC 1/9");
   variables_["DacThresholdB"]->setPerInstance(true);
   variables_["DacThresholdB"]->setRange(0,255);

   addVariable(new Variable("DacThresholdBVolt",Variable::Feedback));
   variables_["DacThresholdBVolt"]->setDescription("Trigger Threshold B dac voltage feedback\nDAC 1/9");
   variables_["DacThresholdBVolt"]->setPerInstance(true);

   addVariable(new Variable("DacRampThresh",Variable::Configuration));
   variables_["DacRampThresh"]->setDescription("Ramp threshold dac\nDAC 2");
   variables_["DacRampThresh"]->setRange(0,255);

   addVariable(new Variable("DacRampThreshVolt",Variable::Feedback));
   variables_["DacRampThreshVolt"]->setDescription("Ramp threshold dac voltage feedback\nDAC 2");

   addVariable(new Variable("DacRangeThreshold",Variable::Configuration));
   variables_["DacRangeThreshold"]->setDescription("Range threshold dac\nDAC 3");
   variables_["DacRangeThreshold"]->setRange(0,255);

   addVariable(new Variable("DacRangeThresholdVolt",Variable::Feedback));
   variables_["DacRangeThresholdVolt"]->setDescription("Range threshold dac voltage feedback\nDAC 3");

   addVariable(new Variable("DacCalibration",Variable::Configuration));
   variables_["DacCalibration"]->setDescription("Calibration dac\nDAC 4");
   variables_["DacCalibration"]->setRange(0,255);

   addVariable(new Variable("DacCalibrationVolt",Variable::Feedback));
   variables_["DacCalibrationVolt"]->setDescription("Calibration dac voltage feedback\nDAC 4");

   addVariable(new Variable("DacCalibrationCharge",Variable::Feedback));
   variables_["DacCalibrationCharge"]->setDescription("Calibration dac charge");

   addVariable(new Variable("DacEventThreshold",Variable::Configuration));
   variables_["DacEventThreshold"]->setDescription("Event threshold dac\nDAC 5");
   variables_["DacEventThreshold"]->setRange(0,255);

   addVariable(new Variable("DacEventThresholdVoltage",Variable::Feedback));
   variables_["DacEventThresholdVoltage"]->setDescription("Event threshold dac voltage feedback\nDAC 5");

   addVariable(new Variable("DacShaperBias",Variable::Configuration));
   variables_["DacShaperBias"]->setDescription("Shaper bias dac\nDAC 6");
   variables_["DacShaperBias"]->setRange(0,255);

   addVariable(new Variable("DacShaperBiasVolt",Variable::Feedback));
   variables_["DacShaperBiasVolt"]->setDescription("Shaper bias dac voltage feedback\nDAC 6");

   addVariable(new Variable("DacDefaultAnalog",Variable::Configuration));
   variables_["DacDefaultAnalog"]->setDescription("Default analog bus dac\nDAC 7");
   variables_["DacDefaultAnalog"]->setRange(0,255);

   addVariable(new Variable("DacDefaultAnalogVolt",Variable::Feedback));
   variables_["DacDefaultAnalogVolt"]->setDescription("Default analog bus dac voltage feedback\nDAC 7");

   // Control register and variables
   addRegister(new Register("Control", baseAddress_ + 0x00000030));

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
   pol.resize(2);
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
   vector<string> src;
   src.resize(3);
   src[0] = "Disable";
   src[1] = "Internal";
   src[2] = "External";
   variables_["CntrlCalSource"]->setEnums(src);

   addVariable(new Variable("CntrlForceTrigSource",Variable::Configuration));
   variables_["CntrlForceTrigSource"]->setDescription("Set force trigger source");
   variables_["CntrlForceTrigSource"]->setEnums(src);

   addVariable(new Variable("CntrlShortIntEn",Variable::Configuration));
   variables_["CntrlShortIntEn"]->setDescription("Short integration enable");
   variables_["CntrlShortIntEn"]->setTrueFalse();

   addVariable(new Variable("CntrlDisPwrCycle",Variable::Configuration));
   variables_["CntrlDisPwrCycle"]->setDescription("Disable power cycle");
   variables_["CntrlDisPwrCycle"]->setTrueFalse();

   addVariable(new Variable("CntrlFeCurr",Variable::Configuration));
   variables_["CntrlFeCurr"]->setDescription("Set front end current");
   vector<string> curr;
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
   vector<string> holdTime;
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
   vector<string> diffTime;
   diffTime.resize(4);
   diffTime[0] = "Normal";
   diffTime[1] = "Half";
   diffTime[2] = "Third";
   diffTime[3] = "Quarter";
   variables_["CntrlDiffTime"]->setEnums(diffTime);

   addVariable(new Variable("CntrlMonSource", Variable::Configuration));
   variables_["CntrlMonSource"]->setDescription("Set monitor port source");
   vector<string> monSource;
   monSource.resize(3);
   monSource[0] = "None";
   monSource[1] = "Amp";
   monSource[2] = "Shaper";
   variables_["CntrlMonSource"]->setEnums(monSource);

   addVariable(new Variable("CntrlTrigDisable", Variable::Configuration));
   variables_["CntrlTrigDisable"]->setDescription("Disable self trigger");
   variables_["CntrlTrigDisable"]->setTrueFalse();

   // Mode registers
   for (x=0; x < 32; x++) {
      tmp.str("");
      tmp << "ColMode_" << setw(2) << setfill('0') << dec << x;
      addVariable(new Variable(tmp.str(),Variable::Configuration));
      variables_[tmp.str()]->setDescription("Channel configuration for column.\n"
                                            "Each charactor represents a row in the column with row 0 being the leftmost value\n"
                                            "The following charactors are allowed:\n"
                                            "D = Channel trigger disabled\n"
                                            "A = Channel trigger threshold A\n"
                                            "B = Channel trigger threshold B\n"
                                            "C = Channel trigger threshold A, with calibration enabled");
      variables_[tmp.str()]->set("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
      variables_[tmp.str()]->setPerInstance(true);

      tmp.str("");
      tmp << "ChanModeA_0x" << setw(2) << setfill('0') << hex << x;
      addRegister(new Register(tmp.str(), baseAddress_ + 0x00000040 + x));
      tmp.str("");
      tmp << "ChanModeB_0x" << setw(2) << setfill('0') << hex << x;
      addRegister(new Register(tmp.str(), baseAddress_ + 0x00000060 + x));
   }

   variables_["enabled"]->set("False");
}

// Deconstructor
KpixAsic::~KpixAsic ( ) { }

// Method to read status registers and update variables
void KpixAsic::readStatus ( ) {
   REGISTER_LOCK

   // Read status register
   readRegister(registers_["Status"]);

   variables_["StatCmdPerr"]->setInt(registers_["Status"]->get(0,0x1));
   variables_["StatDataPerr"]->setInt(registers_["Status"]->get(1,0x1));
   variables_["StatTempEn"]->setInt(registers_["Status"]->get(2,0x1));
   variables_["StatTempIdValue"]->setInt(registers_["Status"]->get(24,0xFF));
   REGISTER_UNLOCK
}

// Method to read configuration registers and update variables
void KpixAsic::readConfig ( ) {
   stringstream tmp;
   stringstream regA;
   stringstream regB;
   stringstream varName;
   string       varTemp;
   uint val;
   uint col;
   uint row;
   uint calCount;

   REGISTER_LOCK

   // Config register & variables
   readRegister(registers_["Config"]);

   variables_["CfgTestDataEn"]->setInt(registers_["Config"]->get(0,0x1));
   variables_["CfgAutoReadDisable"]->setInt(registers_["Config"]->get(2,0x1));
   variables_["CfgForceTemp"]->setInt(registers_["Config"]->get(3,0x1));
   variables_["CfgDisableTemp"]->setInt(registers_["Config"]->get(4,0x1));
   variables_["CfgAutoStatusReadEn"]->setInt(registers_["Config"]->get(5,0x1));

   // Timing registers
   readRegister(registers_["TimerA"]);
   variables_["TimeResetOn"]->setInt(registers_["TimerA"]->get(0,0xFFFF));
   variables_["TimeResetOff"]->setInt(registers_["TimerA"]->get(16,0xFFFF));

   readRegister(registers_["TimerB"]);
   variables_["TimeOffsetNullOff"]->setInt(registers_["TimerB"]->get(0,0xFFFF));
   variables_["TimeLeakageNullOff"]->setInt(registers_["TimerB"]->get(16,0xFFFF));

   readRegister(registers_["TimerC"]);
   variables_["TimePowerUpOn"]->setInt(registers_["TimerC"]->get(0,0xFFFF));
   variables_["TimeThreshOff"]->setInt(registers_["TimerC"]->get(16,0xFFFF));

   readRegister(registers_["TimerE"]);
   variables_["BunchClockCount"]->setInt(registers_["TimerE"]->get(0,0xFFFF));

   readRegister(registers_["TimerF"]);
   variables_["TimeDeselDelay"]->setInt(registers_["TimerF"]->get(0,0xFF));
   variables_["TimeBunchClkDelay"]->setInt(registers_["TimerF"]->get(8,0xFFFF));
   variables_["TimeDigitizeDelay"]->setInt(registers_["TimerF"]->get(24,0xFF));

   readRegister(registers_["TimerD"]);
   val = registers_["TimerD"]->get();
   val = val - variables_["TimeBunchClkDelay"]->getInt();
   val = val - 1;
   val = val / 8;
   variables_["TrigInhibitOff"]->setInt(val);

   // Calibration control registers & variables
   readRegister(registers_["CalDelay0"]);
   readRegister(registers_["CalDelay1"]);

   variables_["Cal0Delay"]->setInt(registers_["CalDelay0"]->get(0,0x1FFF));
   variables_["Cal1Delay"]->setInt(registers_["CalDelay0"]->get(16,0x1FFF));
   variables_["Cal2Delay"]->setInt(registers_["CalDelay1"]->get(0,0x1FFF));
   variables_["Cal3Delay"]->setInt(registers_["CalDelay1"]->get(16,0x1FFF));

   calCount = 0;
   calCount += registers_["CalDelay0"]->get(15,0x1);
   calCount += registers_["CalDelay0"]->get(31,0x1);
   calCount += registers_["CalDelay1"]->get(15,0x1);
   calCount += registers_["CalDelay1"]->get(31,0x1);
   variables_["CalCount"]->setInt(calCount);

   // Some registers don't exist in dummy
   if ( !dummy_ ) {

      // DAC registers and variables
      readRegister(registers_["Dac0"]);
      val = registers_["Dac0"]->get(0,0xFF);
      variables_["DacThresholdA"]->setInt(val);
      variables_["DacThresholdAVolt"]->set(dacToVoltString(val));

      readRegister(registers_["Dac1"]);
      val = registers_["Dac1"]->get(0,0xFF);
      variables_["DacThresholdB"]->setInt(val);
      variables_["DacThresholdBVolt"]->set(dacToVoltString(val));

      readRegister(registers_["Dac2"]);
      val = registers_["Dac2"]->get(0,0xFF);
      variables_["DacRampThresh"]->setInt(val);
      variables_["DacRampThreshVolt"]->set(dacToVoltString(val));

      readRegister(registers_["Dac3"]);
      val = registers_["Dac3"]->get(0,0xFF);
      variables_["DacRangeThreshold"]->setInt(val);
      variables_["DacRangeThresholdVolt"]->set(dacToVoltString(val));

      readRegister(registers_["Dac4"]);
      val = registers_["Dac4"]->get(0,0xFF);
      variables_["DacCalibration"]->setInt(val);
      variables_["DacCalibrationVolt"]->set(dacToVoltString(val));

      tmp.str("");
      if ( variables_["CntrlPolarity"]->get() == "Positive" ) {
         tmp << ((2.5 - dacToVolt(val)) * 200e-15);
         tmp << " / ";
         tmp << (((2.5 - dacToVolt(val)) * 200e-15) * 22.0);
      }
      else {
         tmp << (dacToVolt(val) * 200e-15);
         tmp << " / ";
         tmp << ((dacToVolt(val) * 200e-15) * 22.0);
      }
      variables_["DacCalibrationCharge"]->set(tmp.str());
      
      readRegister(registers_["Dac5"]);
      val = registers_["Dac5"]->get(0,0xFF);
      variables_["DacEventThreshold"]->setInt(val);
      variables_["DacEventThresholdVoltage"]->set(dacToVoltString(val));

      readRegister(registers_["Dac6"]);
      val = registers_["Dac6"]->get(0,0xFF);
      variables_["DacShaperBias"]->setInt(val);
      variables_["DacShaperBiasVolt"]->set(dacToVoltString(val));

      readRegister(registers_["Dac7"]);
      val = registers_["Dac7"]->get(0,0xFF);
      variables_["DacDefaultAnalog"]->setInt(val);
      variables_["DacDefaultAnalogVolt"]->set(dacToVoltString(val));

      // Control register and variables
      readRegister(registers_["Control"]);

      variables_["CntrlDisPerReset"]->setInt(registers_["Control"]->get(0,0x1));
      variables_["CntrlEnDcReset"]->setInt(registers_["Control"]->get(1,0x1));
      variables_["CntrlHighGain"]->setInt(registers_["Control"]->get(2,0x1));
      variables_["CntrlNearNeighbor"]->setInt(registers_["Control"]->get(3,0x1));

      val = 0;
      if ( registers_["Control"]->get(6,0x1) == 1 ) val = 1;
      if ( registers_["Control"]->get(4,0x1) == 1 ) val = 2;
      variables_["CntrlCalSource"]->setInt(val);

      val = 0;
      if ( registers_["Control"]->get(7,0x1) == 1 ) val = 1;
      if ( registers_["Control"]->get(5,0x1) == 1 ) val = 2;
      variables_["CntrlForceTrigSource"]->setInt(val);

      variables_["CntrlHoldTime"]->setInt(registers_["Control"]->get(8,0x7));
      variables_["CntrlCalibHigh"]->setInt(registers_["Control"]->get(11,0x1));
      variables_["CntrlShortIntEn"]->setInt(registers_["Control"]->get(12,0x1));
      variables_["CntrlForceLowGain"]->setInt(registers_["Control"]->get(13,0x1));
      variables_["CntrlLeakNullDisable"]->setInt(registers_["Control"]->get(14,0x1));
      variables_["CntrlPolarity"]->setInt(registers_["Control"]->get(15,0x1));
      variables_["CntrlTrigDisable"]->setInt(registers_["Control"]->get(16,0x1));
      variables_["CntrlDisPwrCycle"]->setInt(registers_["Control"]->get(24,0x1));

      // bit order of FeCurr is reversed
      val  = (registers_["Control"]->get(25,0x1) << 2) & 0x4;
      val |= (registers_["Control"]->get(26,0x1) << 1) & 0x2;
      val |= (registers_["Control"]->get(27,0x1)     ) & 0x1;
      variables_["CntrlFeCurr"]->setInt(val);

      variables_["CntrlDiffTime"]->setInt(registers_["Control"]->get(28,0x3));

      val = 0;
      if ( registers_["Control"]->get(30,0x1) == 1 ) val = 2;
      if ( registers_["Control"]->get(31,0x1) == 1 ) val = 1;
      variables_["CntrlMonSource"]->setInt(val);

      // Calibration Mask Registers
      for (col=0; col < (channels()/32); col++) {
         regA.str("");
         regA << "ChanModeA_0x" << setw(2) << setfill('0') << hex << col;
         regB.str("");
         regB << "ChanModeB_0x" << setw(2) << setfill('0') << hex << col;

         varName.str("");
         varName << "ColMode_" << setw(2) << setfill('0') << dec << col;
         varTemp = "";

         readRegister(registers_[regB.str()]);
         readRegister(registers_[regA.str()]);

         for (row=0; row < 32; row++) {
            switch(registers_[regB.str()]->get(row,0x1),registers_[regA.str()]->get(row,0x1)) {
               case  0: varTemp.append("B"); break;
               case  1: varTemp.append("D"); break;
               case  2: varTemp.append("A"); break;
               case  3: varTemp.append("C"); break;
               default: varTemp.append("D"); break;
            }
         }
         variables_[varName.str()]->set(varTemp);
      }
   }

   REGISTER_UNLOCK
}

// Method to write configuration registers
void KpixAsic::writeConfig ( bool force ) {
   stringstream tmp;
   stringstream regA;
   stringstream regB;
   stringstream varName;
   string       varOld;
   string       varNew;
   uint val;
   uint col;
   uint row;
   uint calCount;

   REGISTER_LOCK

   // Config register & variables
   registers_["Config"]->set(variables_["CfgTestDataEn"]->getInt(),0,0x1);
   registers_["Config"]->set(variables_["CfgAutoReadDisable"]->getInt(),2,0x1);
   registers_["Config"]->set(variables_["CfgForceTemp"]->getInt(),3,0x1);
   registers_["Config"]->set(variables_["CfgDisableTemp"]->getInt(),4,0x1);
   registers_["Config"]->set(variables_["CfgAutoStatusReadEn"]->getInt(),5,0x1);
   writeRegister(registers_["Config"],force);

   // Timing registers
   registers_["TimerA"]->set(variables_["TimeResetOn"]->getInt(),0,0xFFFF);
   registers_["TimerA"]->set(variables_["TimeResetOff"]->getInt(),16,0xFFFF);
   writeRegister(registers_["TimerA"],force);

   registers_["TimerB"]->set(variables_["TimeOffsetNullOff"]->getInt(),0,0xFFFF);
   registers_["TimerB"]->set(variables_["TimeLeakageNullOff"]->getInt(),16,0xFFFF);
   writeRegister(registers_["TimerB"],force);

   registers_["TimerC"]->set(variables_["TimePowerUpOn"]->getInt(),0,0xFFFF);
   registers_["TimerC"]->set(variables_["TimeThreshOff"]->getInt(),16,0xFFFF);
   writeRegister(registers_["TimerC"],force);

   val = (variables_["TrigInhibitOff"]->getInt() * 8) + variables_["TimeBunchClkDelay"]->getInt() + 1;
   registers_["TimerD"]->set(val);
   writeRegister(registers_["TimerD"],force);

   registers_["TimerE"]->set(variables_["BunchClockCount"]->getInt(),0,0xFFFF);
   registers_["TimerE"]->set(variables_["TimePowerUpOn"]->getInt(),16,0xFFFF);
   writeRegister(registers_["TimerE"],force);

   registers_["TimerF"]->set(variables_["TimeDeselDelay"]->getInt(),0,0xFF);
   registers_["TimerF"]->set(variables_["TimeBunchClkDelay"]->getInt(),8,0xFFFF);
   registers_["TimerF"]->set(variables_["TimeDigitizeDelay"]->getInt(),24,0xFF);
   writeRegister(registers_["TimerF"],force);

   // Calibration control registers & variables
   registers_["CalDelay0"]->set(variables_["Cal0Delay"]->getInt(),0,0x1FFF);
   registers_["CalDelay0"]->set(variables_["Cal1Delay"]->getInt(),16,0x1FFF);
   registers_["CalDelay1"]->set(variables_["Cal2Delay"]->getInt(),0,0x1FFF);
   registers_["CalDelay1"]->set(variables_["Cal3Delay"]->getInt(),16,0x1FFF);

   calCount = variables_["CalCount"]->getInt();
   registers_["CalDelay0"]->set((calCount>0)?1:0,15,0x1);
   registers_["CalDelay0"]->set((calCount>1)?1:0,31,0x1);
   registers_["CalDelay1"]->set((calCount>2)?1:0,15,0x1);
   registers_["CalDelay1"]->set((calCount>3)?1:0,31,0x1);
   writeRegister(registers_["CalDelay0"],force);
   writeRegister(registers_["CalDelay1"],force);

   // Some registers don't exist in dummy
   if ( !dummy_ ) {

      // DAC registers and variables
      val = variables_["DacThresholdA"]->getInt();
      variables_["DacThresholdAVolt"]->set(dacToVoltString(val));
      registers_["Dac0"]->set(val,0,0xFF);
      registers_["Dac0"]->set(val,8,0xFF);
      registers_["Dac0"]->set(val,16,0xFF);
      registers_["Dac0"]->set(val,24,0xFF);
      writeRegister(registers_["Dac0"],force);
      registers_["Dac8"]->set(val,0,0xFF);
      registers_["Dac8"]->set(val,8,0xFF);
      registers_["Dac8"]->set(val,16,0xFF);
      registers_["Dac8"]->set(val,24,0xFF);
      writeRegister(registers_["Dac8"],force);

      val = variables_["DacThresholdB"]->getInt();
      variables_["DacThresholdBVolt"]->set(dacToVoltString(val));
      registers_["Dac1"]->set(val,0,0xFF);
      registers_["Dac1"]->set(val,8,0xFF);
      registers_["Dac1"]->set(val,16,0xFF);
      registers_["Dac1"]->set(val,24,0xFF);
      writeRegister(registers_["Dac1"],force);
      registers_["Dac9"]->set(val,0,0xFF);
      registers_["Dac9"]->set(val,8,0xFF);
      registers_["Dac9"]->set(val,16,0xFF);
      registers_["Dac9"]->set(val,24,0xFF);
      writeRegister(registers_["Dac9"],force);

      val = variables_["DacRampThresh"]->getInt();
      variables_["DacRampThreshVolt"]->set(dacToVoltString(val));
      registers_["Dac2"]->set(val,0,0xFF);
      registers_["Dac2"]->set(val,8,0xFF);
      registers_["Dac2"]->set(val,16,0xFF);
      registers_["Dac2"]->set(val,24,0xFF);
      writeRegister(registers_["Dac2"],force);

      val = variables_["DacRangeThreshold"]->getInt();
      variables_["DacRangeThresholdVolt"]->set(dacToVoltString(val));
      registers_["Dac3"]->set(val,0,0xFF);
      registers_["Dac3"]->set(val,8,0xFF);
      registers_["Dac3"]->set(val,16,0xFF);
      registers_["Dac3"]->set(val,24,0xFF);
      writeRegister(registers_["Dac3"],force);

      val = variables_["DacCalibration"]->getInt();
      variables_["DacCalibrationVolt"]->set(dacToVoltString(val));
      registers_["Dac4"]->set(val,0,0xFF);
      registers_["Dac4"]->set(val,8,0xFF);
      registers_["Dac4"]->set(val,16,0xFF);
      registers_["Dac4"]->set(val,24,0xFF);
      writeRegister(registers_["Dac4"],force);

      tmp.str("");
      if ( variables_["CntrlPolarity"]->get() == "Positive" ) {
         tmp << ((2.5 - dacToVolt(val)) * 200e-15);
         tmp << " / ";
         tmp << (((2.5 - dacToVolt(val)) * 200e-15) * 22.0);
      }
      else {
         tmp << (dacToVolt(val) * 200e-15);
         tmp << " / ";
         tmp << ((dacToVolt(val) * 200e-15) * 22.0);
      }
      variables_["DacCalibrationCharge"]->set(tmp.str());
      
      val = variables_["DacEventThreshold"]->getInt();
      variables_["DacEventThresholdVoltage"]->set(dacToVoltString(val));
      registers_["Dac5"]->set(val,0,0xFF);
      registers_["Dac5"]->set(val,8,0xFF);
      registers_["Dac5"]->set(val,16,0xFF);
      registers_["Dac5"]->set(val,24,0xFF);
      writeRegister(registers_["Dac5"],force);

      val = variables_["DacShaperBias"]->getInt();
      variables_["DacShaperBiasVolt"]->set(dacToVoltString(val));
      registers_["Dac6"]->set(val,0,0xFF);
      registers_["Dac6"]->set(val,8,0xFF);
      registers_["Dac6"]->set(val,16,0xFF);
      registers_["Dac6"]->set(val,24,0xFF);
      writeRegister(registers_["Dac6"],force);

      val = variables_["DacDefaultAnalog"]->getInt();
      variables_["DacDefaultAnalogVolt"]->set(dacToVoltString(val));
      registers_["Dac7"]->set(val,0,0xFF);
      registers_["Dac7"]->set(val,8,0xFF);
      registers_["Dac7"]->set(val,16,0xFF);
      registers_["Dac7"]->set(val,24,0xFF);
      writeRegister(registers_["Dac7"],force);

      // Control register and variables
      registers_["Control"]->set(variables_["CntrlDisPerReset"]->getInt(),0,0x1);
      registers_["Control"]->set(variables_["CntrlEnDcReset"]->getInt(),1,0x1);
      registers_["Control"]->set(variables_["CntrlHighGain"]->getInt(),2,0x1);
      registers_["Control"]->set(variables_["CntrlNearNeighbor"]->getInt(),3,0x1);

      val = variables_["CntrlCalSource"]->getInt();
      registers_["Control"]->set((val==1)?1:0,6,0x1);
      registers_["Control"]->set((val==2)?1:0,4,0x1);

      val = variables_["CntrlForceTrigSource"]->getInt();
      registers_["Control"]->set((val==1)?1:0,7,0x1);
      registers_["Control"]->set((val==2)?1:0,5,0x1);

      registers_["Control"]->set(variables_["CntrlHoldTime"]->getInt(),8,0x7);
      registers_["Control"]->set(variables_["CntrlCalibHigh"]->getInt(),11,0x1);
      registers_["Control"]->set(variables_["CntrlShortIntEn"]->getInt(),12,0x1);
      registers_["Control"]->set(variables_["CntrlForceLowGain"]->getInt(),13,0x1);
      registers_["Control"]->set(variables_["CntrlLeakNullDisable"]->getInt(),14,0x1);
      registers_["Control"]->set(variables_["CntrlPolarity"]->getInt(),15,0x1);
      registers_["Control"]->set(variables_["CntrlTrigDisable"]->getInt(),16,0x1);
      registers_["Control"]->set(variables_["CntrlDisPwrCycle"]->getInt(),24,0x1);

      // bit order of FeCurr is reversed
      val = variables_["CntrlFeCurr"]->getInt();
      registers_["Control"]->set(((val   )&0x1),27,0x1);
      registers_["Control"]->set(((val>>1)&0x1),26,0x1);
      registers_["Control"]->set(((val>>2)&0x1),25,0x1);

      registers_["Control"]->set(variables_["CntrlDiffTime"]->getInt(),28,0x3);

      val = variables_["CntrlMonSource"]->getInt();
      registers_["Control"]->set((val==2)?1:0,30,0x1);
      registers_["Control"]->set((val==1)?1:0,31,0x1);

      writeRegister(registers_["Control"],force);

      // Calibration Mask Registers
      for (col=0; col < (channels()/32); col++) {
         regA.str("");
         regA << "ChanModeA_0x" << setw(2) << setfill('0') << hex << col;
         regB.str("");
         regB << "ChanModeB_0x" << setw(2) << setfill('0') << hex << col;

         varName.str("");
         varName << "ColMode_" << setw(2) << setfill('0') << dec << col;
         varOld = variables_[varName.str()]->get();
         varNew = "";

         for (row=0; row < 32; row++) {
            if ( varOld.length() < (row+1) ) varOld.append("D");
            switch(varOld[row]) {
               case 'B':
                  registers_[regB.str()]->set(0,row,0x1);
                  registers_[regA.str()]->set(0,row,0x1);
                  varNew.append("B");
                  break;
               case 'D':
                  registers_[regB.str()]->set(0,row,0x1);
                  registers_[regA.str()]->set(1,row,0x1);
                  varNew.append("D");
                  break;
               case 'C':
                  registers_[regB.str()]->set(1,row,0x1);
                  registers_[regA.str()]->set(1,row,0x1);
                  varNew.append("C");
                  break;
               case 'A':
                  registers_[regB.str()]->set(1,row,0x1);
                  registers_[regA.str()]->set(0,row,0x1);
                  varNew.append("A");
                  break;
               default : 
                  registers_[regB.str()]->set(0,row,0x1);
                  registers_[regA.str()]->set(1,row,0x1);
                  varNew.append("D");
                  break;
            }
         }
         writeRegister(registers_[regB.str()],force);
         writeRegister(registers_[regA.str()],force);
         variables_[varName.str()]->set(varNew);
      }
   }

   REGISTER_UNLOCK
}

// Verify hardware state of configuration
void KpixAsic::verifyConfig ( ) {
   stringstream tmp;
   uint         x;

   REGISTER_LOCK

   verifyRegister(registers_["Config"]);
   verifyRegister(registers_["TimerA"]);
   verifyRegister(registers_["TimerB"]);
   verifyRegister(registers_["TimerC"]);
   verifyRegister(registers_["TimerD"]);
   verifyRegister(registers_["TimerE"]);
   verifyRegister(registers_["TimerF"]);
   //verifyRegister(registers_["TimerG"]);
   //verifyRegister(registers_["TimerH"]);
   verifyRegister(registers_["CalDelay0"]);
   verifyRegister(registers_["CalDelay1"]);

   if ( !dummy_ ) {
      verifyRegister(registers_["Dac0"]);
      verifyRegister(registers_["Dac1"]);
      verifyRegister(registers_["Dac2"]);
      verifyRegister(registers_["Dac3"]);
      verifyRegister(registers_["Dac4"]);
      verifyRegister(registers_["Dac5"]);
      verifyRegister(registers_["Dac6"]);
      verifyRegister(registers_["Dac7"]);
      verifyRegister(registers_["Dac8"]);
      verifyRegister(registers_["Dac9"]);
      verifyRegister(registers_["Control"]);

      for (x=0; x < (channels()/32); x++) {
         tmp.str("");
         tmp << "ChanModeA_0x" << setw(2) << setfill('0') << hex << x;
         verifyRegister(registers_[tmp.str()]);
         tmp.str("");
         tmp << "ChanModeB_0x" << setw(2) << setfill('0') << hex << x;
         verifyRegister(registers_[tmp.str()]);
      }
   }
   REGISTER_UNLOCK
}

