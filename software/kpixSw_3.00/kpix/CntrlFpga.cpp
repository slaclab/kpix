//-----------------------------------------------------------------------------
// File          : CntrlFpga.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Heavy Photon Tracker
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
#include <CntrlFpga.h>
#include <Hybrid.h>
#include <Ad9252.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
CntrlFpga::CntrlFpga ( uint destination, uint index ) : 
                     Device(destination,0,"cntrlFpga",index) {

   // Description
   desc_ = "Control FPGA Object.";

   // Create Registers: name, address
   addRegister(new Register("Version",         0x01000000));
   addRegister(new Register("MasterReset",     0x01000001));
   addRegister(new Register("ScratchPad",      0x01000002));
   addRegister(new Register("AdcChanEn",       0x01000003));
   addRegister(new Register("Apv25Reset",      0x01000004));
   addRegister(new Register("ApvSyncReset",    0x01000007));
   addRegister(new Register("ApvSyncStatus",   0x01000008));
   addRegister(new Register("ApvHardReset",    0x01000009));
   addRegister(new Register("ApvTrigGenCnt",   0x0100000A));
   addRegister(new Register("ApvTrigGenPause", 0x0100000B));
   addRegister(new Register("ApvTrigSrcType",  0x0100000C));
   addRegister(new Register("ApvSampleThresh", 0x0100000D));
   addRegister(new Register("ClockSelect",     0x0100000E));
   addRegister(new Register("ApvMux",          0x0100000F));
   addRegister(new Register("GetTemp",         0x01000016));
   addRegister(new Register("CalDelay",        0x01000017));

   // Setup variables
   addVariable(new Variable("FpgaVersion", Variable::Status));
   variables_["FpgaVersion"]->setDescription("FPGA version field");

   addVariable(new Variable("ScratchPad", Variable::Configuration));
   variables_["ScratchPad"]->setDescription("Scratchpad for testing");

   addVariable(new Variable("Adc0Enable", Variable::Configuration));
   variables_["Adc0Enable"]->setDescription("Enable ADC channel 0");
   variables_["Adc0Enable"]->setTrueFalse();

   addVariable(new Variable("Adc1Enable", Variable::Configuration));
   variables_["Adc1Enable"]->setDescription("Enable ADC channel 1");
   variables_["Adc1Enable"]->setTrueFalse();

   addVariable(new Variable("Adc2Enable", Variable::Configuration));
   variables_["Adc2Enable"]->setDescription("Enable ADC channel 2");
   variables_["Adc2Enable"]->setTrueFalse();

   addVariable(new Variable("Adc3Enable", Variable::Configuration));
   variables_["Adc3Enable"]->setDescription("Enable ADC channel 3");
   variables_["Adc3Enable"]->setTrueFalse();

   addVariable(new Variable("Adc4Enable", Variable::Configuration));
   variables_["Adc4Enable"]->setDescription("Enable ADC channel 4");
   variables_["Adc4Enable"]->setTrueFalse();

   addVariable(new Variable("Adc5Enable", Variable::Configuration));
   variables_["Adc5Enable"]->setDescription("Enable ADC channel 5");
   variables_["Adc5Enable"]->setTrueFalse();

   addVariable(new Variable("Adc6Enable", Variable::Configuration));
   variables_["Adc6Enable"]->setDescription("Enable ADC channel 6");
   variables_["Adc6Enable"]->setTrueFalse();

   addVariable(new Variable("Adc7Enable", Variable::Configuration));
   variables_["Adc7Enable"]->setDescription("Enable ADC channel 7");
   variables_["Adc7Enable"]->setTrueFalse();

   addVariable(new Variable("ApvSyncError", Variable::Status));
   variables_["ApvSyncError"]->setDescription("APV sync error status. 8-bit mask.\n"
                                              "One bit per channe. 0=APV0, 1=APV1...");

   addVariable(new Variable("ApvSyncDetect", Variable::Status));
   variables_["ApvSyncDetect"]->setDescription("APV sync detect status. 8-bit mask.\n"
                                               "One bit per channe. 0=APV0, 1=APV1...");

   addVariable(new Variable("ApvTrigType", Variable::Configuration));
   variables_["ApvTrigType"]->setDescription("Set APV trigger type. Double or single.");
   vector<string> trigTypes;
   trigTypes.resize(5);
   trigTypes[0] = "Test";
   trigTypes[1] = "SingleTrig";
   trigTypes[2] = "DoubleTrig";
   trigTypes[3] = "SingleCalib";
   trigTypes[4] = "DoubleCalib";
   variables_["ApvTrigType"]->setEnums(trigTypes);

   addVariable(new Variable("ApvTrigSource", Variable::Configuration));
   variables_["ApvTrigSource"]->setDescription("Set trigger source.");
   vector<string> trigSources;
   trigSources.resize(4);
   trigSources[0] = "None";
   trigSources[1] = "Internal";
   trigSources[2] = "Software";
   trigSources[3] = "External";
   variables_["ApvTrigSource"]->setEnums(trigSources);

   addVariable(new Variable("ApvTrigGenCnt", Variable::Configuration));
   variables_["ApvTrigGenCnt"]->setDescription("Set internal trigger generation count.");

   addVariable(new Variable("ApvTrigGenPause", Variable::Configuration));
   variables_["ApvTrigGenPause"]->setDescription("Set internal trigger generation period.");
   variables_["ApvTrigGenPause"]->setComp(0,0.025,0,"uS");

   addVariable(new Variable("ApvThreshold", Variable::Configuration));
   variables_["ApvThreshold"]->setDescription("Set APV threshold in ADUs for event detection.");

   addVariable(new Variable("ApvSampleSize", Variable::Configuration));
   variables_["ApvSampleSize"]->setDescription("Set sample size for APV25");
   vector<string> sampSize;
   sampSize.resize(4);
   sampSize[0] = "Samp1";
   sampSize[1] = "Samp2";
   sampSize[2] = "Samp3";
   sampSize[3] = "Samp6";
   variables_["ApvSampleSize"]->setEnums(sampSize);

   addVariable(new Variable("ClockSelect", Variable::Configuration));
   variables_["ClockSelect"]->setDescription("Selects between internally and externally generated APV and ADC Clk.");
   vector<string> clkSel;
   clkSel.resize(2);
   clkSel[0] = "Internal";
   clkSel[1] = "External";
   variables_["ClockSelect"]->setEnums(clkSel);

   addVariable(new Variable("ApvMux", Variable::Configuration));
   variables_["ApvMux"]->setDescription("Enables Apv data demuxing.");
   variables_["ApvMux"]->setTrueFalse();

   addVariable(new Variable("GetTemp", Variable::Configuration));
   variables_["GetTemp"]->setDescription("Enables getting temperature.");
   variables_["GetTemp"]->setTrueFalse();

   addVariable(new Variable("CalDelay", Variable::Configuration));
   variables_["CalDelay"]->setDescription("Cal to trig delay.");
   variables_["CalDelay"]->setComp(0,25,0,"nS");

   // Commands
   addCommand(new Command("ApvSWTrig",0x1));
   commands_["ApvSWTrig"]->setDescription("Generate APV software trigger + calibration.");

   addCommand(new Command("ApvINTrig",0x2));
   commands_["ApvINTrig"]->setDescription("Start internal trigger + calibration sequence.");

   addCommand(new Command("MasterReset"));
   commands_["MasterReset"]->setDescription("Send master FPGA reset.\n"
                                            "Wait a few moments following reset generation before\n"
                                            "issuing addition commands or configuration read/writes");

   addCommand(new Command("Apv25Reset"));
   commands_["Apv25Reset"]->setDescription("Send APV25 RESET101.");

   addCommand(new Command("Apv25HardReset"));
   commands_["Apv25HardReset"]->setDescription("Assert reset line to APV25s.");

   // Add sub-devices
   addDevice(new Hybrid(destination,0x01100000, 0));
   //addDevice(new Hybrid(destination,0x01101000, 1));
   //addDevice(new Hybrid(destination,0x01102000, 2));
   addDevice(new Ad9252(destination,0x01104000, 0));
   //addDevice(new Ad9252(destination,0x01105000, 1));
}

// Deconstructor
CntrlFpga::~CntrlFpga ( ) { }

// Method to process a command
string CntrlFpga::command ( string name, string arg) {
   stringstream tmp;
   tmp.str("");
   tmp << "<" << name << ">Success</" << name << ">" << endl;

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
}

// Method to read status registers and update variables
void CntrlFpga::readStatus ( bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   // Read status
   readRegister(registers_["Version"]);
   variables_["FpgaVersion"]->setInt(registers_["Version"]->get());

   readRegister(registers_["ApvSyncStatus"]);
   variables_["ApvSyncError"]->setInt(registers_["ApvSyncStatus"]->get(8,0xFF));
   variables_["ApvSyncDetect"]->setInt(registers_["ApvSyncStatus"]->get(0,0xFF));

   // Sub devices
   Device::readStatus(subEnable);
}

// Method to read configuration registers and update variables
void CntrlFpga::readConfig ( bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   // Read config
   readRegister(registers_["ScratchPad"]);
   variables_["ScratchPad"]->setInt(registers_["ScratchPad"]->get());

   readRegister(registers_["AdcChanEn"]);
   variables_["Adc0Enable"]->setInt(registers_["AdcChanEn"]->get(0,0x1));
   variables_["Adc1Enable"]->setInt(registers_["AdcChanEn"]->get(1,0x1));
   variables_["Adc2Enable"]->setInt(registers_["AdcChanEn"]->get(2,0x1));
   variables_["Adc3Enable"]->setInt(registers_["AdcChanEn"]->get(3,0x1));
   variables_["Adc4Enable"]->setInt(registers_["AdcChanEn"]->get(4,0x1));
   variables_["Adc5Enable"]->setInt(registers_["AdcChanEn"]->get(5,0x1));
   variables_["Adc6Enable"]->setInt(registers_["AdcChanEn"]->get(6,0x1));
   variables_["Adc7Enable"]->setInt(registers_["AdcChanEn"]->get(7,0x1));

   readRegister(registers_["ApvTrigSrcType"]);
   variables_["ApvTrigType"]->setInt(registers_["ApvTrigSrcType"]->get(8,0xFF));
   variables_["ApvTrigSource"]->setInt(registers_["ApvTrigSrcType"]->get(0,0xFF));

   readRegister(registers_["ApvTrigGenCnt"]);
   variables_["ApvTrigGenCnt"]->setInt(registers_["ApvTrigGenCnt"]->get(0,0xFFFFFFFF));

   readRegister(registers_["ApvTrigGenPause"]);
   variables_["ApvTrigGenPause"]->setInt(registers_["ApvTrigGenPause"]->get(0,0xFFFFFFFF));

   readRegister(registers_["ApvSampleThresh"]);
   variables_["ApvThreshold"]->setInt(registers_["ApvSampleThresh"]->get(0,0xFFFF));

   switch(registers_["ApvSampleThresh"]->get(16,0xFF)) {
      case 1: variables_["ApvSampleSize"]->setInt(0); break;
      case 2: variables_["ApvSampleSize"]->setInt(1); break;
      case 3: variables_["ApvSampleSize"]->setInt(2); break;
      case 6: variables_["ApvSampleSize"]->setInt(3); break;
      default: variables_["ApvSampleSize"]->setInt(0); break;
   }

   readRegister(registers_["ClockSelect"]);
   variables_["ClockSelect"]->setInt(registers_["ClockSelect"]->get(0,0x1));

   readRegister(registers_["ApvMux"]);
   variables_["ApvMux"]->setInt(registers_["ApvMux"]->get(0,0x1));

   readRegister(registers_["CalDelay"]);
   variables_["CalDelay"]->setInt(registers_["CalDelay"]->get(0,0xFFFF));

   // Sub devices
   Device::readConfig(subEnable);
}

// Method to write configuration registers
void CntrlFpga::writeConfig ( bool force, bool subEnable ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   // Write config
   registers_["ScratchPad"]->set(variables_["ScratchPad"]->getInt());
   writeRegister(registers_["ScratchPad"],force);

   registers_["ClockSelect"]->set(variables_["ClockSelect"]->getInt(),0,0x1);
   writeRegister(registers_["ClockSelect"],force);

   registers_["ApvMux"]->set(variables_["ApvMux"]->getInt(),0,0x1);
   writeRegister(registers_["ApvMux"],force);

   registers_["AdcChanEn"]->set(variables_["Adc0Enable"]->getInt(),0,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc1Enable"]->getInt(),1,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc2Enable"]->getInt(),2,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc3Enable"]->getInt(),3,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc4Enable"]->getInt(),4,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc5Enable"]->getInt(),5,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc6Enable"]->getInt(),6,0x1);
   registers_["AdcChanEn"]->set(variables_["Adc7Enable"]->getInt(),7,0x1);
   writeRegister(registers_["AdcChanEn"],force);

   registers_["ApvTrigGenCnt"]->set(variables_["ApvTrigGenCnt"]->getInt(),0,0xFFFFFFFF);
   writeRegister(registers_["ApvTrigGenCnt"],force);

   registers_["ApvTrigGenPause"]->set(variables_["ApvTrigGenPause"]->getInt(),0,0xFFFFFFFF);
   writeRegister(registers_["ApvTrigGenPause"],force);

   registers_["ApvTrigSrcType"]->set(variables_["ApvTrigType"]->getInt(),8,0xFF);
   registers_["ApvTrigSrcType"]->set(variables_["ApvTrigSource"]->getInt(),0,0xFF);
   writeRegister(registers_["ApvTrigSrcType"],force);

   switch (variables_["ApvSampleSize"]->getInt() ) {
      case 0: registers_["ApvSampleThresh"]->set(1,16,0xFF); break;
      case 1: registers_["ApvSampleThresh"]->set(2,16,0xFF); break;
      case 2: registers_["ApvSampleThresh"]->set(3,16,0xFF); break;
      case 3: registers_["ApvSampleThresh"]->set(6,16,0xFF); break;
      default: registers_["ApvSampleThresh"]->set(1,16,0xFF); break;
   }
   registers_["ApvSampleThresh"]->set(variables_["ApvThreshold"]->getInt(),0,0xFFFF);
   writeRegister(registers_["ApvSampleThresh"],force);

   registers_["GetTemp"]->set(variables_["GetTemp"]->getInt(),0,0x1);
   writeRegister(registers_["GetTemp"],force);

   registers_["CalDelay"]->set(variables_["CalDelay"]->getInt(),0,0xFFFF);
   writeRegister(registers_["CalDelay"],force);

   // Sub devices
   Device::writeConfig(force,subEnable);
}

// Verify hardware state of configuration
string CntrlFpga::verifyConfig ( bool subEnable, string input ) {

   stringstream ret;
   ret.str("");

   if ( getInt("enabled") == 0 ) return("");

   ret << verifyRegister(registers_["ScratchPad"]);
   ret << verifyRegister(registers_["AdcChanEn"]);
   ret << verifyRegister(registers_["ApvMux"]);
   ret << verifyRegister(registers_["ApvMux"]);
   ret << verifyRegister(registers_["ApvTrigSrcType"]);
   ret << verifyRegister(registers_["ApvTrigGenCnt"]);
   ret << verifyRegister(registers_["ApvTrigGenPause"]);
   ret << verifyRegister(registers_["ApvSampleThresh"]);
   ret << verifyRegister(registers_["CalDelay"]);

   ret << input;
   return(Device::verifyConfig(subEnable,ret.str()));
}

