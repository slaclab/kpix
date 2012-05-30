//-----------------------------------------------------------------------------
// File          : OptoFpga.cpp
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
#include <OptoFpga.h>
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
OptoFpga::OptoFpga ( uint destination, uint index, Device *parent ) : 
                     Device(destination,0,"cntrlFpga",index,parent) {

   // Description
   desc_ = "KPIX FPGA Object.";

   // Setup registers & variables
   addRegister(new Register("VersionMastReset", 0x02000000));
   addVariable(new Variable("Version", Variable::Status));
   getVariable("Version")->setDescription("FPGA version field");

   addRegister(new Register("JumperKpixReset", 0x02000001));
   addVariable(new Variable("Jumpers", Variable::Status));
   getVariable("Jumpers")->setDescription("FPGA jumpers field");

   addRegister(new Register("ScratchPad", 0x02000002));
   addVariable(new Variable("ScratchPad", Variable::Configuration));
   getVariable("ScratchPad")->setDescription("FPGA scratchpad register");
   getVariable("ScratchPad")->setComp(0,1,0,"");

   // Clock select register
   addRegister(new Register("ClockSelect", 0x02000003));
   vector<string> clkPeriod;
   clkPeriod.resize(32);
   clkPeriod[0]   = "10nS";
   clkPeriod[1]   = "20nS";
   clkPeriod[2]   = "30nS";
   clkPeriod[3]   = "40nS";
   clkPeriod[4]   = "50nS";
   clkPeriod[5]   = "60nS";
   clkPeriod[6]   = "70nS";
   clkPeriod[7]   = "80nS";
   clkPeriod[8]   = "90nS";
   clkPeriod[9]   = "100nS";
   clkPeriod[10]  = "110nS";
   clkPeriod[11]  = "120nS";
   clkPeriod[12]  = "130nS";
   clkPeriod[13]  = "140nS";
   clkPeriod[14]  = "150nS";
   clkPeriod[15]  = "160nS";
   clkPeriod[16]  = "170nS";
   clkPeriod[17]  = "180nS";
   clkPeriod[18]  = "190nS";
   clkPeriod[19]  = "200nS";
   clkPeriod[20]  = "210nS";
   clkPeriod[21]  = "220nS";
   clkPeriod[22]  = "230nS";
   clkPeriod[23]  = "240nS";
   clkPeriod[24]  = "250nS";
   clkPeriod[25]  = "260nS";
   clkPeriod[26]  = "270nS";
   clkPeriod[27]  = "280nS";
   clkPeriod[28]  = "290nS";
   clkPeriod[29]  = "300nS";
   clkPeriod[30]  = "310nS";
   clkPeriod[31]  = "320nS";

   addVariable(new Variable("ClkPeriodAcq", Variable::Configuration));
   getVariable("ClkPeriodAcq")->setDescription("Acquisition clock period");
   getVariable("ClkPeriodAcq")->setEnums(clkPeriod);

   addVariable(new Variable("ClkPeriodIdle", Variable::Configuration));
   getVariable("ClkPeriodIdle")->setDescription("Idle clock period");
   getVariable("ClkPeriodIdle")->setEnums(clkPeriod);

   addVariable(new Variable("ClkPeriodDig", Variable::Configuration));
   getVariable("ClkPeriodDig")->setDescription("Digitization clock period");
   getVariable("ClkPeriodDig")->setEnums(clkPeriod);

   addVariable(new Variable("ClkPeriodRead", Variable::Configuration));
   getVariable("ClkPeriodRead")->setDescription("Readout clock period");
   getVariable("ClkPeriodRead")->setEnums(clkPeriod);

   // Checksum error register
   addRegister(new Register("ChecksumError", 0x02000004));

   addVariable(new Variable("ChecksumError", Variable::Status));
   getVariable("ChecksumError")->setDescription("Checksum error count");
   getVariable("ChecksumError")->setComp(0,1,0,"");

   // Readback control
   addRegister(new Register("ReadControl", 0x02000005));
   addVariable(new Variable("KpixReadDelay", Variable::Configuration));
   getVariable("KpixReadDelay")->setDescription("Kpix return data sample delay");
   getVariable("KpixReadDelay")->setRange(0,8);

   addVariable(new Variable("KpixReadEdge", Variable::Configuration));
   getVariable("KpixReadEdge")->setDescription("Kpix return data sample edge");
   vector<string> readEdge;
   readEdge.resize(2);
   readEdge[0]  = "Neg";
   readEdge[1]  = "Pos";
   getVariable("KpixReadEdge")->setEnums(readEdge);

   // KPIX control register
   addRegister(new Register("KPIXControl", 0x02000008));

   addVariable(new Variable("BncSourceA", Variable::Configuration));
   getVariable("BncSourceA")->setDescription("BNC output A source select");
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
   getVariable("BncSourceA")->setEnums(bncSource);

   addVariable(new Variable("BncSourceB", Variable::Configuration));
   getVariable("BncSourceB")->setDescription("BNC output B source select");
   getVariable("BncSourceB")->setEnums(bncSource);

   addVariable(new Variable("DropData", Variable::Configuration));
   getVariable("DropData")->setDescription("Drop all KPIX data");
   getVariable("DropData")->setTrueFalse();

   addVariable(new Variable("RawData", Variable::Configuration));
   getVariable("RawData")->setDescription("Send raw KPIX data");
   getVariable("RawData")->setTrueFalse();

   // Parity error register
   addRegister(new Register("ParityError", 0x02000009));

   addVariable(new Variable("ParityError", Variable::Status));
   getVariable("ParityError")->setDescription("Parity error");
   getVariable("ParityError")->setComp(0,1,0,"");

   // Trigger control register
   addRegister(new Register("TriggerControl", 0x0200000B));

   addVariable(new Variable("TrigEnable", Variable::Configuration));
   getVariable("TrigEnable")->setDescription("External trigger enable, mask. One bit per clock period.");

   addVariable(new Variable("TrigExpand", Variable::Configuration));
   getVariable("TrigExpand")->setDescription("Expand external trigger");
   getVariable("TrigExpand")->setRange(0,255);

   addVariable(new Variable("CalDelay", Variable::Configuration));
   getVariable("CalDelay")->setDescription("Calibration delay for trigger source");
   getVariable("CalDelay")->setRange(0,255);

   addVariable(new Variable("TrigSource", Variable::Configuration));
   getVariable("TrigSource")->setDescription("External trigger source");
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
   getVariable("TrigSource")->setEnums(trgSource);

   // Train number register
   addRegister(new Register("TrainNumber", 0x0200000C));

   addVariable(new Variable("TrainNumber", Variable::Status));
   getVariable("TrainNumber")->setDescription("Train number register");
   getVariable("TrainNumber")->setComp(0,1,0,"");

   // Dead count register
   addRegister(new Register("DeadCounter", 0x0200000D));

   addVariable(new Variable("DeadCounter", Variable::Status));
   getVariable("DeadCounter")->setDescription("Dead coutner register");
   getVariable("DeadCounter")->setComp(0,1,0,"");

   // External run register
   addRegister(new Register("ExternalRun", 0x0200000E));

   addVariable(new Variable("ExtRunSource", Variable::Configuration));
   getVariable("ExtRunSource")->setDescription("External run source");
   vector<string> extRun;
   extRun.resize(5);
   extRun[0]  = "Disable";
   extRun[1]  = "NimA";
   extRun[2]  = "NimB";
   extRun[3]  = "BncA";
   extRun[4]  = "BncB";
   getVariable("ExtRunSource")->setEnums(extRun);

   addVariable(new Variable("ExtRunDelay", Variable::Configuration));
   getVariable("ExtRunDelay")->setDescription("External run delay");
   getVariable("ExtRunDelay")->setRange(0,65535);

   addVariable(new Variable("ExtRunType", Variable::Configuration));
   getVariable("ExtRunType")->setDescription("External run type");
   vector<string> extType;
   extType.resize(2);
   extType[0]  = "Acquire";
   extType[1]  = "Calibrate";
   getVariable("ExtRunType")->setEnums(extType);

   addVariable(new Variable("ExtRecord", Variable::Configuration));
   getVariable("ExtRecord")->setDescription("External record");
   vector<string> extRec;
   extRec.resize(6);
   extRec[0]  = "Disable";
   extRec[1]  = "NimA";
   extRec[2]  = "NimB";
   extRec[3]  = "BncA";
   extRec[4]  = "BncB";
   extRec[5]  = "CalStrobe";
   getVariable("ExtRecord")->setEnums(extRec);

   // Create Registers: name, address
   addRegister(new Register("RunEnable", 0x0200000F));

   addVariable(new Variable("RunEnable", Variable::Configuration));
   getVariable("RunEnable")->setDescription("RunEnable");
   getVariable("RunEnable")->setTrueFalse();

   // Commands
   addCommand(new Command("RunAcquire",0x2));
   getCommand("RunAcquire")->setDescription("Run acquire command");

   addCommand(new Command("RunCalibrate",0x3));
   getCommand("RunCalibrate")->setDescription("Run calibrate command");

   addCommand(new Command("KpixCmdReset",0x1));
   getCommand("KpixCmdReset")->setDescription("Soft KPIX reset command");

   addCommand(new Command("MasterReset"));
   getCommand("MasterReset")->setDescription("Master FPGA reset");

   addCommand(new Command("KpixHardReset"));
   getCommand("KpixHardReset")->setDescription("Hard KPIX reset command");

   addCommand(new Command("CountReset"));
   getCommand("CountReset")->setDescription("Reset counters");

   // Add sub-devices
   for (uint i=0; i < 4; i++) addDevice(new KpixAsic(destination,((i << 8)& 0xFF00),i,(i==3),this));

   getVariable("enabled")->setHidden(true);
}

// Deconstructor
OptoFpga::~OptoFpga ( ) { }

// Method to process a command
void OptoFpga::command ( string name, string arg) {

   // Command is local
   if ( name == "MasterReset" ) {
      REGISTER_LOCK
      getRegister("VersionMastReset")->set(0x1);
      writeRegister(getRegister("VersionMastReset"),true,false);
      REGISTER_UNLOCK
   }
   else if ( name == "KpixHardReset" ) {
      REGISTER_LOCK
      getRegister("JumperKpixReset")->set(0x1);
      writeRegister(getRegister("JumperKpixReset"),true,true);
      REGISTER_UNLOCK
   }
   else if ( name == "CountReset" ) {
      REGISTER_LOCK
      writeRegister(getRegister("ChecksumError"),true,true);
      writeRegister(getRegister("ParityError"),true,true);
      writeRegister(getRegister("TrainNumber"),true,true);
      writeRegister(getRegister("DeadCounter"),true,true);
      REGISTER_UNLOCK
   }
   else Device::command(name, arg);
}

// Method to read status registers and update variables
void OptoFpga::readStatus ( ) {
   REGISTER_LOCK

   readRegister(getRegister("VersionMastReset"));
   getVariable("Version")->setInt(getRegister("VersionMastReset")->get());

   readRegister(getRegister("JumperKpixReset"));
   getVariable("Jumpers")->setInt(getRegister("JumperKpixReset")->get());

   readRegister(getRegister("TrainNumber"));
   getVariable("TrainNumber")->setInt(getRegister("TrainNumber")->get());

   readRegister(getRegister("DeadCounter"));
   getVariable("DeadCounter")->setInt(getRegister("DeadCounter")->get());

   readRegister(getRegister("ChecksumError"));
   getVariable("ChecksumError")->setInt(getRegister("ChecksumError")->get());

   readRegister(getRegister("ParityError"));
   getVariable("ParityError")->setInt(getRegister("ParityError")->get());

   // Sub devices
   Device::readStatus();
   REGISTER_UNLOCK
}

// Method to read configuration registers and update variables
void OptoFpga::readConfig ( ) {
   REGISTER_LOCK

   // Scratchpad
   readRegister(getRegister("ScratchPad"));
   getVariable("ScratchPad")->setInt(getRegister("ScratchPad")->get());

   // Clock set register
   readRegister(getRegister("ClockSelect"));
   getVariable("ClkPeriodAcq")->setInt(getRegister("ClockSelect")->get(0,0x1F));
   getVariable("ClkPeriodIdle")->setInt(getRegister("ClockSelect")->get(24,0x1F));
   getVariable("ClkPeriodDig")->setInt(getRegister("ClockSelect")->get(8,0x1F));
   getVariable("ClkPeriodRead")->setInt(getRegister("ClockSelect")->get(16,0x1F));

   // Readback control
   readRegister(getRegister("ReadControl"));
   getVariable("KpixReadDelay")->setInt(getRegister("ReadControl")->get(0,0xFF));
   getVariable("KpixReadEdge")->setInt(getRegister("ReadControl")->get(8,0xFF));

   // KPIX control register
   readRegister(getRegister("KPIXControl"));
   getVariable("BncSourceA")->setInt(getRegister("KPIXControl")->get(16,0x1F));
   getVariable("BncSourceB")->setInt(getRegister("KPIXControl")->get(21,0x1F));
   getVariable("DropData")->setInt(getRegister("KPIXControl")->get(4,0x1));
   getVariable("RawData")->setInt(getRegister("KPIXControl")->get(5,0x1));

   // Parity error register
   readRegister(getRegister("ParityError"));
   getVariable("ParityError")->setInt(getRegister("ParityError")->get());

   // Trigger control register
   readRegister(getRegister("TriggerControl"));
   getVariable("TrigEnable")->setInt(getRegister("TriggerControl")->get(0,0xFF));
   getVariable("TrigExpand")->setInt(getRegister("TriggerControl")->get(8,0xFF));
   getVariable("CalDelay")->setInt(getRegister("TriggerControl")->get(16,0xFF));
   getVariable("TrigSource")->setInt(getRegister("TriggerControl")->get(24,0x1));

   // Train number register
   readRegister(getRegister("TrainNumber"));
   getVariable("TrainNumber")->setInt(getRegister("TrainNumber")->get());

   // Dead count register
   readRegister(getRegister("DeadCounter"));
   getVariable("DeadCounter")->setInt(getRegister("DeadCounter")->get());

   // External run register
   readRegister(getRegister("ExternalRun"));
   getVariable("ExtRunSource")->setInt(getRegister("ExternalRun")->get(16,0x7));
   getVariable("ExtRunDelay")->setInt(getRegister("ExternalRun")->get(0,0xFFFF));
   getVariable("ExtRunType")->setInt(getRegister("ExternalRun")->get(19,0x1));
   getVariable("ExtRecord")->setInt(getRegister("ExternalRun")->get(20,0x1));

   // Create Registers: name, address
   readRegister(getRegister("RunEnable"));
   getVariable("RunEnable")->setInt(getRegister("RunEnable")->get());

   // Sub devices
   Device::readConfig();
   REGISTER_UNLOCK
}

// Method to write configuration registers
void OptoFpga::writeConfig ( bool force ) {
   REGISTER_LOCK

   // Scratchpad
   getRegister("ScratchPad")->set(getVariable("ScratchPad")->getInt());
   writeRegister(getRegister("ScratchPad"),force);

   // Clock set register
   getRegister("ClockSelect")->set(getVariable("ClkPeriodAcq")->getInt(),0,0x1F);
   getRegister("ClockSelect")->set(getVariable("ClkPeriodIdle")->getInt(),24,0x1F);
   getRegister("ClockSelect")->set(getVariable("ClkPeriodDig")->getInt(),8,0x1F);
   getRegister("ClockSelect")->set(getVariable("ClkPeriodRead")->getInt(),16,0x1F);
   writeRegister(getRegister("ClockSelect"),force);

   // Readback control
   getRegister("ReadControl")->set(getVariable("KpixReadDelay")->getInt(),0,0xFF);
   getRegister("ReadControl")->set(getVariable("KpixReadEdge")->getInt(),8,0xFF);
   writeRegister(getRegister("ReadControl"),force);

   // KPIX control register
   getRegister("KPIXControl")->set(getVariable("BncSourceA")->getInt(),16,0x1F);
   getRegister("KPIXControl")->set(getVariable("BncSourceB")->getInt(),21,0x1F);
   getRegister("KPIXControl")->set(getVariable("DropData")->getInt(),4,0x1);
   getRegister("KPIXControl")->set(getVariable("RawData")->getInt(),5,0x1);
   getRegister("KPIXControl")->set(device("kpixAsic",0)->getInt("RawData"),28,0x1);
   writeRegister(getRegister("KPIXControl"),force);

   // Parity error register
   getRegister("ParityError")->set(getVariable("ParityError")->getInt());
   writeRegister(getRegister("ParityError"),force);

   // Trigger control register
   getRegister("TriggerControl")->set(getVariable("TrigEnable")->getInt(),0,0xFF);
   getRegister("TriggerControl")->set(getVariable("TrigExpand")->getInt(),8,0xFF);
   getRegister("TriggerControl")->set(getVariable("CalDelay")->getInt(),16,0xFF);
   getRegister("TriggerControl")->set(getVariable("TrigSource")->getInt(),24,0x1);
   writeRegister(getRegister("TriggerControl"),force);

   // Train number register
   getRegister("TrainNumber")->set(getVariable("TrainNumber")->getInt());
   writeRegister(getRegister("TrainNumber"),force);

   // Dead count register
   getRegister("DeadCounter")->set(getVariable("DeadCounter")->getInt());
   writeRegister(getRegister("DeadCounter"),force);

   // External run register
   getRegister("ExternalRun")->set(getVariable("ExtRunSource")->getInt(),16,0x7);
   getRegister("ExternalRun")->set(getVariable("ExtRunDelay")->getInt(),0,0xFFFF);
   getRegister("ExternalRun")->set(getVariable("ExtRunType")->getInt(),19,0x1);
   getRegister("ExternalRun")->set(getVariable("ExtRecord")->getInt(),20,0x1);
   writeRegister(getRegister("ExternalRun"),force);

   // Create Registers: name, address
   getRegister("RunEnable")->set(getVariable("RunEnable")->getInt());
   writeRegister(getRegister("RunEnable"),force);

   // Sub devices
   Device::writeConfig(force);
   REGISTER_UNLOCK
}

// Verify hardware state of configuration
void OptoFpga::verifyConfig ( ) {
   REGISTER_LOCK

   verifyRegister(getRegister("ScratchPad"));
   verifyRegister(getRegister("ClockSelect"));
   verifyRegister(getRegister("ReadControl"));
   verifyRegister(getRegister("KPIXControl"));
   verifyRegister(getRegister("TriggerControl"));
   verifyRegister(getRegister("ExternalRun"));
   verifyRegister(getRegister("RunEnable"));

   Device::verifyConfig();
   REGISTER_UNLOCK
}

