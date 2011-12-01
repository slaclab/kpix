//-----------------------------------------------------------------------------
// File          : CntrlFpga.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/20/2011
// Project       : Kpix ASIC
//-----------------------------------------------------------------------------
// Description :
// Control FPGA container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/20/2011: created
//-----------------------------------------------------------------------------
#include <CntrlFpga.h>
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
CntrlFpga::CntrlFpga ( uint destination, uint index, uint kpixCnt, Device *parent ) : 
                     Device(destination,0,"cntrlFpga",index,parent) {

   // Description
   desc_ = "Control FPGA Object.";

   // Setup registers & variables
   addRegister(new Register("VersionMastReset", 0x00000000));
   addVariable(new Variable("Version", Variable::Status));
   variables_["Version"]->setDescription("FPGA version field");

   addRegister(new Register("JumperKpixReset", 0x00000001));
   addVariable(new Variable("Jumpers", Variable::Status));
   variables_["Jumpers"]->setDescription("FPGA jumpers field");

   addRegister(new Register("ScratchPad", 0x00000002));
   addVariable(new Variable("ScratchPad", Variable::Configuration));
   variables_["ScratchPad"]->setDescription("FPGA scratchpad register");

   // Clock select register
   addRegister(new Register("ClockSelect", 0x00000003));

   addVariable(new Variable("ClkPeriodAcq", Variable::Configuration));
   variables_["ClkPeriodAcq"]->setDescription("Acquisition clock period");

   addVariable(new Variable("ClkPeriodIdle", Variable::Configuration));
   variables_["ClkPeriodIdle"]->setDescription("Idle clock period");

   addVariable(new Variable("ClkPeriodDig", Variable::Configuration));
   variables_["ClkPeriodDig"]->setDescription("Digitization clock period");

   addVariable(new Variable("ClkPeriodRead", Variable::Configuration));
   variables_["ClkPeriodRead"]->setDescription("Readout clock period");

   // Checksum error register
   addRegister(new Register("ChecksumError", 0x00000004));

   addVariable(new Variable("ChecksumError", Variable::Status));
   variables_["ChecksumError"]->setDescription("Readout clock period");

   // Readback control
   addRegister(new Register("ReadControl", 0x00000005));
   addVariable(new Variable("KpixReadDelay", Variable::Configuration));
   variables_["KpixReadDelay"]->setDescription("Kpix return data sample delay");

   addVariable(new Variable("KpixReadEdge", Variable::Configuration));
   variables_["KpixReadEdge"]->setDescription("Kpix return data sample edge");

   // KPIX control register
   addRegister(new Register("KPIXControl", 0x00000008));

   addVariable(new Variable("BncSourceA", Variable::Configuration));
   variables_["BncSourceA"]->setDescription("BNC output A source select");
   vector<string> bncSource;
   bncSource.resize(28);
   bncSource[0]  = "RegClock";
   bncSource[1]  = "RegSel1";
   bncSource[2]  = "RegSel0";
   bncSource[3]  = "PwrUpAcq";
   bncSource[4]  = "ResetLoad";
   bncSource[5]  = "LeakageNull";
   bncSource[6]  = "OffsetNull";
   bncSource[7]  = "ThreashOff";
   bncSource[8]  = "TrigInh";
   bncSource[9]  = "CalStrobe";
   bncSource[10] = "PwrUpAcqDig";
   bncSource[11] = "SelCell";
   bncSource[12] = "DeselAllCells";
   bncSource[13] = "RampPeriod";
   bncSource[14] = "PrechargeBus";
   bncSource[15] = "RegData";
   bncSource[16] = "RegWrEn";
   bncSource[17] = "KpixClk";
   bncSource[18] = "ForceTrig";
   bncSource[19] = "TrigEnable";
   bncSource[20] = "CalStrobeDelay";
   bncSource[21] = "NimA";
   bncSource[22] = "NimB";
   bncSource[23] = "BncA";
   bncSource[24] = "BncB";
   bncSource[25] = "BcPhase";
   bncSource[26] = "TrainNumRst";
   bncSource[27] = "TrainNumClk";
   variables_["BncSourceA"]->setEnums(bncSource);

   addVariable(new Variable("BncSourceB", Variable::Configuration));
   variables_["BncSourceB"]->setDescription("BNC output B source select");
   variables_["BncSourceB"]->setEnums(bncSource);

   addVariable(new Variable("DropData", Variable::Configuration));
   variables_["DropData"]->setDescription("Drop all KPIX data");

   addVariable(new Variable("RawData", Variable::Configuration));
   variables_["RawData"]->setDescription("Send raw KPIX data");

   // Parity error register
   addRegister(new Register("ParityError", 0x00000009));

   addVariable(new Variable("ParityError", Variable::Configuration));
   variables_["ParityError"]->setDescription("Parity error");

   // Trigger control register
   addRegister(new Register("TriggerControl", 0x0000000B));

   addVariable(new Variable("TrigEnable", Variable::Configuration));
   variables_["TrigEnable"]->setDescription("External trigger enable");

   addVariable(new Variable("TrigExpand", Variable::Configuration));
   variables_["TrigExpand"]->setDescription("Expand external trigger");

   addVariable(new Variable("CalDelay", Variable::Configuration));
   variables_["CalDelay"]->setDescription("Calibration delay for trigger source");

   addVariable(new Variable("TrigSource", Variable::Configuration));
   variables_["TrigSource"]->setDescription("External trigger source");
   vector<string> trgSource;
   trgSource.resize(28);
   trgSource[0]  = "None";
   trgSource[1]  = "CalStrobe";
   trgSource[2]  = "NimA";
   trgSource[3]  = "NimB";
   trgSource[4]  = "BncA";
   trgSource[5]  = "BncB";
   trgSource[6]  = "MaskNimA";
   trgSource[7]  = "MaskNimB";
   trgSource[8]  = "MaskBncA";
   trgSource[9]  = "MaskBncB";
   trgSource[10] = "CalStrobeDelay";
   variables_["TrigSource"]->setEnums(trgSource);

   // Train number register
   addRegister(new Register("TrainNumber", 0x0000000C));

   addVariable(new Variable("TrainNumber", Variable::Status));
   variables_["TrainNumber"]->setDescription("Train number register");

   // Dead count register
   addRegister(new Register("DeadCounter", 0x0000000D));

   addVariable(new Variable("DeadCounter", Variable::Status));
   variables_["DeadCounter"]->setDescription("Dead coutner register");

   // External run register
   addRegister(new Register("ExternalRun", 0x0000000E));

   addVariable(new Variable("ExtRunSource", Variable::Configuration));
   variables_["ExtRunSource"]->setDescription("External run source");

   addVariable(new Variable("ExtRunDelay", Variable::Configuration));
   variables_["ExtRunDelay"]->setDescription("External run delay");

   addVariable(new Variable("ExtRunType", Variable::Configuration));
   variables_["ExtRunType"]->setDescription("External run type");

   addVariable(new Variable("ExtRecord", Variable::Configuration));
   variables_["ExtRecord"]->setDescription("External record");

   // Create Registers: name, address
   addRegister(new Register("RunEnable", 0x0000000F));

   addVariable(new Variable("RunEnable", Variable::Configuration));
   variables_["RunEnable"]->setDescription("RunEnable");

   // Commands
   addCommand(new Command("RunAcquire",0x1));
   commands_["RunAcquire"]->setDescription("Run acquire command");

   addCommand(new Command("RunCalibrate",0x2));
   commands_["RunCalibrate"]->setDescription("Run calibrate command");

   addCommand(new Command("SoftKpixReset",0x3));
   commands_["SoftKpixReset"]->setDescription("Soft KPIX reset command");

   addCommand(new Command("MasterReset"));
   commands_["MasterReset"]->setDescription("Master FPGA reset");

   addCommand(new Command("HardKpixReset"));
   commands_["HardKpixReset"]->setDescription("Hard KPIX reset command");

   // Add sub-devices
   for (uint i=0; i < kpixCnt; i++) {
      cout << "adding index " << dec << i << endl;
      addDevice(new KpixAsic(destination,((i << 8)& 0xFF00),i,(i==(kpixCnt-1)),this));
   }
}

// Deconstructor
CntrlFpga::~CntrlFpga ( ) { }

// Method to process a command
void CntrlFpga::command ( string name, string arg) {

   // Command is local
   if ( name == "MasterReset" ) {
      registers_["VersionMastReset"]->set(0x1);
      writeRegister(registers_["VersionMastReset"],true,false);
   }
   else if ( name == "HardKpixReset" ) {
      registers_["JumperKpixReset"]->set(0x1);
      writeRegister(registers_["JumperKpixReset"],true,true);
   }
   else Device::command(name, arg);
}

// Method to read status registers and update variables
void CntrlFpga::readStatus ( ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   readRegister(registers_["VersionMastReset"]);
   variables_["Version"]->setInt(registers_["VersionMastReset"]->get());

   readRegister(registers_["JumperKpixReset"]);
   variables_["Jumpers"]->setInt(registers_["JumperKpixReset"]->get());

   readRegister(registers_["TrainNumber"]);
   variables_["TrainNumber"]->setInt(registers_["TrainNumber"]->get());

   readRegister(registers_["DeadCounter"]);
   variables_["DeadCounter"]->setInt(registers_["DeadCounter"]->get());

   readRegister(registers_["ChecksumError"]);
   variables_["ChecksumError"]->setInt(registers_["ChecksumError"]->get());

   // Sub devices
   Device::readStatus();
}

// Method to read configuration registers and update variables
void CntrlFpga::readConfig ( ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   // Scratchpad
   readRegister(registers_["ScratchPad"]);
   variables_["ScratchPad"]->setInt(registers_["ScratchPad"]->get());

   // Clock set register
   readRegister(registers_["ClockSelect"]);
   variables_["ClkPeriodAcq"]->setInt(registers_["ClockSelect"]->get(0,0x1F));
   variables_["ClkPeriodIdle"]->setInt(registers_["ClockSelect"]->get(24,0x1F));
   variables_["ClkPeriodDig"]->setInt(registers_["ClockSelect"]->get(8,0x1F));
   variables_["ClkPeriodRead"]->setInt(registers_["ClockSelect"]->get(16,0x1F));

   // Readback control
   readRegister(registers_["ReadControl"]);
   variables_["KpixReadDelay"]->setInt(registers_["ReadControl"]->get(0,0xFF));
   variables_["KpixReadEdge"]->setInt(registers_["ReadControl"]->get(8,0xFF));

   // KPIX control register
   readRegister(registers_["KPIXControl"]);
   variables_["BncSourceA"]->setInt(registers_["KPIXControl"]->get(16,0x1F));
   variables_["BncSourceB"]->setInt(registers_["KPIXControl"]->get(21,0x1F));
   variables_["DropData"]->setInt(registers_["KPIXControl"]->get(4,0x1));
   variables_["RawData"]->setInt(registers_["KPIXControl"]->get(5,0x1));

   // Parity error register
   readRegister(registers_["ParityError"]);
   variables_["ParityError"]->setInt(registers_["ParityError"]->get());

   // Trigger control register
   readRegister(registers_["TriggerControl"]);
   variables_["TrigEnable"]->setInt(registers_["TriggerControl"]->get(0,0xFF));
   variables_["TrigExpand"]->setInt(registers_["TriggerControl"]->get(8,0xFF));
   variables_["CalDelay"]->setInt(registers_["TriggerControl"]->get(16,0xFF));
   variables_["TrigSource"]->setInt(registers_["TriggerControl"]->get(24,0x1));

   // Train number register
   readRegister(registers_["TrainNumber"]);
   variables_["TrainNumber"]->setInt(registers_["TrainNumber"]->get());

   // Dead count register
   readRegister(registers_["DeadCounter"]);
   variables_["DeadCounter"]->setInt(registers_["DeadCounter"]->get());

   // External run register
   readRegister(registers_["ExternalRun"]);
   variables_["ExtRunSource"]->setInt(registers_["ExternalRun"]->get(16,0x7));
   variables_["ExtRunDelay"]->setInt(registers_["ExternalRun"]->get(0,0xFFFF));
   variables_["ExtRunType"]->setInt(registers_["ExternalRun"]->get(19,0x1));
   variables_["ExtRecord"]->setInt(registers_["ExternalRun"]->get(20,0x1));

   // Create Registers: name, address
   readRegister(registers_["RunEnable"]);
   variables_["RunEnable"]->setInt(registers_["RunEnable"]->get());

   // Sub devices
   Device::readConfig();
}

// Method to write configuration registers
void CntrlFpga::writeConfig ( bool force ) {

   // Device is not enabled
   if ( getInt("enabled") == 0 ) return;

   // Scratchpad
   registers_["ScratchPad"]->set(variables_["ScratchPad"]->getInt());
   writeRegister(registers_["ScratchPad"],force);

   // Clock set register
   registers_["ClockSelect"]->set(variables_["ClkPeriodAcq"]->getInt(),0,0x1F);
   registers_["ClockSelect"]->set(variables_["ClkPeriodIdle"]->getInt(),24,0x1F);
   registers_["ClockSelect"]->set(variables_["ClkPeriodDig"]->getInt(),8,0x1F);
   registers_["ClockSelect"]->set(variables_["ClkPeriodRead"]->getInt(),16,0x1F);
   writeRegister(registers_["ClockSelect"],force);

   // Readback control
   registers_["ReadControl"]->set(variables_["KpixReadDelay"]->getInt(),0,0xFF);
   registers_["ReadControl"]->set(variables_["KpixReadEdge"]->getInt(),8,0xFF);
   writeRegister(registers_["ReadControl"],force);

   // KPIX control register
   registers_["KPIXControl"]->set(variables_["BncSourceA"]->getInt(),16,0x1F);
   registers_["KPIXControl"]->set(variables_["BncSourceB"]->getInt(),21,0x1F);
   registers_["KPIXControl"]->set(variables_["DropData"]->getInt(),4,0x1);
   registers_["KPIXControl"]->set(variables_["RawData"]->getInt(),5,0x1);
   writeRegister(registers_["KPIXControl"],force);

   // Parity error register
   registers_["ParityError"]->set(variables_["ParityError"]->getInt());
   writeRegister(registers_["ParityError"],force);

   // Trigger control register
   registers_["TriggerControl"]->set(variables_["TrigEnable"]->getInt(),0,0xFF);
   registers_["TriggerControl"]->set(variables_["TrigExpand"]->getInt(),8,0xFF);
   registers_["TriggerControl"]->set(variables_["CalDelay"]->getInt(),16,0xFF);
   registers_["TriggerControl"]->set(variables_["TrigSource"]->getInt(),24,0x1);
   writeRegister(registers_["TriggerControl"],force);

   // Train number register
   registers_["TrainNumber"]->set(variables_["TrainNumber"]->getInt());
   writeRegister(registers_["TrainNumber"],force);

   // Dead count register
   registers_["DeadCounter"]->set(variables_["DeadCounter"]->getInt());
   writeRegister(registers_["DeadCounter"],force);

   // External run register
   registers_["ExternalRun"]->set(variables_["ExtRunSource"]->getInt(),16,0x7);
   registers_["ExternalRun"]->set(variables_["ExtRunDelay"]->getInt(),0,0xFFFF);
   registers_["ExternalRun"]->set(variables_["ExtRunType"]->getInt(),19,0x1);
   registers_["ExternalRun"]->set(variables_["ExtRecord"]->getInt(),20,0x1);
   writeRegister(registers_["ExternalRun"],force);

   // Create Registers: name, address
   registers_["RunEnable"]->set(variables_["RunEnable"]->getInt());
   writeRegister(registers_["RunEnable"],force);

   // Sub devices
   Device::writeConfig(force);
}

// Verify hardware state of configuration
void CntrlFpga::verifyConfig ( ) {

   if ( getInt("enabled") == 0 ) return;

   verifyRegister(registers_["ScratchPad"]);
   verifyRegister(registers_["ClockSelect"]);
   verifyRegister(registers_["ReadControl"]);
   verifyRegister(registers_["KPIXControl"]);
   verifyRegister(registers_["ParityError"]);
   verifyRegister(registers_["TriggerControl"]);
   verifyRegister(registers_["TrainNumber"]);
   verifyRegister(registers_["DeadCounter"]);
   verifyRegister(registers_["ExternalRun"]);
   verifyRegister(registers_["RunEnable"]);

   Device::verifyConfig();
}

