//-----------------------------------------------------------------------------
// File          : KpixFpga.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Kpix FPGA container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------

#include "KpixFpga.h"
#include "Register.h"
#include "Variable.h"
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
#include <math.h>
using namespace std;

//! Constructor
KpixFpga::KpixFpga (uint version) : Device("fpga",0) {
   vector<string> bncSource;
   vector<string> trigSource;
   vector<string> runSource;
   vector<string> recSource;
   vector<string> runType;

   // Set version
   version_ = version;

   // Create Registers: name, address, writeEn, testEn
   registers_.insert(pair<string,Register*>("Version/Mast Reset", new Register(0x00,true,false)));
   registers_.insert(pair<string,Register*>("Jumper/Kpix Reset",  new Register(0x01,true,false)));
   registers_.insert(pair<string,Register*>("Scratchpad",         new Register(0x02,true,true)));
   registers_.insert(pair<string,Register*>("Clock Select",       new Register(0x03,true,true)));
   registers_.insert(pair<string,Register*>("Checksum Error",     new Register(0x04,true,true)));
   registers_.insert(pair<string,Register*>("USB Delay",          new Register(0x05,true,true)));
   registers_.insert(pair<string,Register*>("KPIX Control",       new Register(0x08,true,true)));
   registers_.insert(pair<string,Register*>("Parity Error",       new Register(0x09,true,true)));
   registers_.insert(pair<string,Register*>("Trigger Control",    new Register(0x0B,true,true)));
   registers_.insert(pair<string,Register*>("Train Number",       new Register(0x0C,true,true)));
   registers_.insert(pair<string,Register*>("Dead Counter",       new Register(0x0D,true,true)));
   registers_.insert(pair<string,Register*>("External Run",       new Register(0x0E,true,true)));
   registers_.insert(pair<string,Register*>("Run Enable",         new Register(0x0F,true,true)));

   // Setup BNC Source ENUM
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

   // Setup Run Source ENUM
   runSource[0]  = "Disable";
   runSource[1]  = "NimA";
   runSource[2]  = "NimB";
   runSource[3]  = "BncA";
   runSource[4]  = "BncB";

   // Setup Record Source ENUM
   recSource[0]  = "Disable";
   recSource[1]  = "NimA";
   recSource[2]  = "NimB";
   recSource[3]  = "BncA";
   recSource[4]  = "BncB";
   recSource[4]  = "CalStrobe";

   // Setup Trig Source ENUM
   trigSource[0]  = "None";
   trigSource[1]  = "CalStrobe";
   trigSource[2]  = "NimA";
   trigSource[3]  = "NimB";
   trigSource[4]  = "BncA";
   trigSource[5]  = "BncB";
   trigSource[6]  = "MaskNimA";
   trigSource[7]  = "MaskNimB";
   trigSource[8]  = "MaskBncA";
   trigSource[9]  = "MaskBncB";
   trigSource[10] = "CalStrobeDelay";

   // Setup Run Type ENUM
   runType[0]  = "Acquire";
   runType[1]  = "Calibrate";

   // Setup Variables
   variables_.insert(pair<string,Variable*>("FpgaScratchpad",   new Variable()));
   variables_.insert(pair<string,Variable*>("ClkPeriodAcq",     new Variable()));
   variables_.insert(pair<string,Variable*>("ClkPeriodIdle",    new Variable()));
   variables_.insert(pair<string,Variable*>("ClkPeriodDig",     new Variable()));
   variables_.insert(pair<string,Variable*>("ClkPeriodRead",    new Variable()));
   variables_.insert(pair<string,Variable*>("KpixReadDelay",    new Variable()));
   variables_.insert(pair<string,Variable*>("KpixReadEdge",     new Variable()));
   variables_.insert(pair<string,Variable*>("BncSourceA",       new Variable(bncSource)));
   variables_.insert(pair<string,Variable*>("BncSourceB",       new Variable(bncSource)));
   variables_.insert(pair<string,Variable*>("DropData",         new Variable()));
   variables_.insert(pair<string,Variable*>("RawData",          new Variable()));
   variables_.insert(pair<string,Variable*>("ExtRunSource",     new Variable(runSource)));
   variables_.insert(pair<string,Variable*>("ExtRunDelay",      new Variable()));
   variables_.insert(pair<string,Variable*>("ExtRunType",       new Variable(runType)));
   variables_.insert(pair<string,Variable*>("ExtRecord",        new Variable(recSource)));
   variables_.insert(pair<string,Variable*>("TrigEnable",       new Variable()));
   variables_.insert(pair<string,Variable*>("TrigExpand",       new Variable()));
   variables_.insert(pair<string,Variable*>("CalDelay",         new Variable()));
   variables_.insert(pair<string,Variable*>("TrigSource",       new Variable(trigSource)));
   variables_.insert(pair<string,Variable*>("RunEnable",        new Variable()));

   // Status variables
   variables_.insert(pair<string,Variable*>("FpgaVersion",      new Variable()));
   variables_.insert(pair<string,Variable*>("FpgaJumpers",      new Variable()));
   variables_.insert(pair<string,Variable*>("CheckSumErrors",   new Variable()));
   variables_.insert(pair<string,Variable*>("RespParityErrors", new Variable()));
   variables_.insert(pair<string,Variable*>("DataParityErrors", new Variable()));
   variables_.insert(pair<string,Variable*>("TrainNumber",      new Variable()));
   variables_.insert(pair<string,Variable*>("DeadCount",        new Variable()));

   // Clear Stale Flags
   registers_["Version/Mast Reset"]->clrStale();
   registers_["Jumper/Kpix Reset"]->clrStale();

   // Set KPIX Version Register
   registers_["KPIX Control"]->set(0,28,(version_<10));

}


//! Deconstructor
KpixFpga::~KpixFpga ( ) {
}


//! Method to read variables from registers
string KpixFpga::read() {

   // Read settings
   variables_["FpgaScratchpad"]->setReg(registers_["Scratchpad"]->get());
   variables_["ClkPeriodAcq"]->setReg(registers_["Clock Select"]->get(0,0x1F));
   variables_["ClkPeriodIdle"]->setReg(registers_["Clock Select"]->get(24,0x1F));
   variables_["ClkPeriodDig"]->setReg(registers_["Clock Select"]->get(8,0x1F));
   variables_["ClkPeriodRead"]->setReg(registers_["Clock Select"]->get(16,0x1F));
   variables_["KpixReadDelay"]->setReg(registers_["USB Delay"]->get(0,0xFF));
   variables_["KpixReadEdge"]->setReg(registers_["USB Delay"]->get(8,0xFF));
   variables_["BncSourceA"]->setReg(registers_["KPIX Control"]->get(16,0x1F));
   variables_["BncSourceB"]->setReg(registers_["KPIX Control"]->get(21,0x1F));
   variables_["DropData"]->setReg(registers_["KPIX Control"]->get(4,0x1));
   variables_["RawData"]->setReg(registers_["KPIX Control"]->get(5,0x1));
   variables_["ExtRunSource"]->setReg(registers_["External Run"]->get(16,0x7));
   variables_["ExtRunDelay"]->setReg(registers_["External Run"]->get(0,0xFFFF));
   variables_["ExtRunType"]->setReg(registers_["External Run"]->get(19,0x1));
   variables_["ExtRecord"]->setReg(registers_["External Run"]->get(20,0x1));
   variables_["TrigEnable"]->setReg(registers_["Trigger Control"]->get(0,0xFF));
   variables_["TrigExpand"]->setReg(registers_["Trigger Control"]->get(8,0xFF));
   variables_["CalDelay"]->setReg(registers_["Trigger Control"]->get(16,0xFF));
   variables_["TrigSource"]->setReg(registers_["Trigger Control"]->get(24,0x1));
   variables_["RunEnable"]->setReg(registers_["Run Enable"]->get(0,0x1));

   // Debug
   if ( debug_ ) {
      cout << "KpixFpga::read -> reading config: " << endl;
      cout << "                  FpgaScratchpad = " << variables_["FpgaScratchpad"]->get() << endl;
      cout << "                  ClkPeriodAcq   = " << variables_["ClkPeriodAcq"]->get() << endl;
      cout << "                  ClkPeriodIdle  = " << variables_["ClkPeriodIdle"]->get() << endl;
      cout << "                  ClkPeriodDig   = " << variables_["ClkPeriodDig"]->get() << endl;
      cout << "                  ClkPeriodRead  = " << variables_["ClkPeriodRead"]->get() << endl;
      cout << "                  KpixReadDelay  = " << variables_["KpixReadDelay"]->get() << endl;
      cout << "                  KpixReadEdge   = " << variables_["KpixReadEdge"]->get() << endl;
      cout << "                  BncSourceA     = " << variables_["BncSourceA"]->get() << endl;
      cout << "                  BncSourceB     = " << variables_["BncSourceB"]->get() << endl;
      cout << "                  RawData        = " << variables_["RawData"]->get() << endl;
      cout << "                  ExtRunSource   = " << variables_["ExtRunSource"]->get() << endl;
      cout << "                  ExtRunDelay    = " << variables_["ExtRunDelay"]->get() << endl;
      cout << "                  ExtRunType     = " << variables_["ExtRunType"]->get() << endl;
      cout << "                  ExtRecord      = " << variables_["ExtRecord"]->get() << endl;
      cout << "                  TrigEnable     = " << variables_["TrigEnable"]->get() << endl;
      cout << "                  TrigExpand     = " << variables_["TrigExpand"]->get() << endl;
      cout << "                  CalDelay       = " << variables_["CalDelay"]->get() << endl;
      cout << "                  TrigSource     = " << variables_["TrigSource"]->get() << endl;
   }

   // Read status
   variables_["FpgaVersion"]->setReg(registers_["Version/Mast Reset"]->get());
   variables_["FpgaJumpers"]->setReg(registers_["Jumper/Kpix Reset"]->get(0,0xF));
   variables_["CheckSumErrors"]->setReg(registers_["Checksum Error"]->get(0,0xFF));
   variables_["RespParityErrors"]->setReg(registers_["Parity Error"]->get(8,0xFF));
   variables_["DataParityErrors"]->setReg(registers_["Parity Error"]->get(0,0xFF));
   variables_["TrainNumber"]->setReg(registers_["Train Number"]->get());
   variables_["DeadCount"]->setReg(registers_["Dead Counter"]->get());

   // Debug
   if ( debug_ ) {
      cout << "KpixFpga::read -> reading status: " << endl;
      cout << "                  FpgaVersion      = " << variables_["FpgaVersion"]->get() << endl;
      cout << "                  FpgaJumpers      = " << variables_["FpgaJumpers"]->get() << endl;
      cout << "                  CheckSumErrors   = " << variables_["CheckSumErrors"]->get() << endl;
      cout << "                  RespParityErrors = " << variables_["RespParityErrors"]->get() << endl;
      cout << "                  DataParityErrors = " << variables_["DataParityErrors"]->get() << endl;
      cout << "                  TrainNumber      = " << variables_["TrainNumber"]->get() << endl;
      cout << "                  DeadCount        = " << variables_["DeadCount"]->get() << endl;
   }

   // Return XML string
   return(Device::read());
}


//! Method to write variables to registers
string KpixFpga::write( string xml ) {
   uint         fpgaScratchpad;
   uint         clkPeriodAcq;
   uint         clkPeriodIdle;
   uint         clkPeriodDig;
   uint         clkPeriodRead;
   uint         kpixReadDelay;
   uint         kpixReadEdge;
   uint         bncSourceA;
   uint         bncSourceB;
   uint         dropData;
   uint         rawData;
   uint         extRunSource;
   uint         extRunDelay;
   uint         extRunType;
   uint         extRecord;
   uint         trigEnable;
   uint         trigExpand;
   uint         calDelay;
   uint         trigSource;
   uint         runEnable;
   bool         ok;
   bool         okAll;
   stringstream err;

   // Process xml string
   Device::write(xml);

   // Read settings
   okAll = true;
   fpgaScratchpad = variables_["FpgaScratchpad"]->getReg(&ok); if ( !ok ) okAll = false;
   clkPeriodAcq   = variables_["ClkPeriodAcq"]->getReg(&ok);   if ( !ok ) okAll = false;
   clkPeriodIdle  = variables_["ClkPeriodIdle"]->getReg(&ok);  if ( !ok ) okAll = false;
   clkPeriodDig   = variables_["ClkPeriodDig"]->getReg(&ok);   if ( !ok ) okAll = false;
   clkPeriodRead  = variables_["ClkPeriodRead"]->getReg(&ok);  if ( !ok ) okAll = false;
   kpixReadDelay  = variables_["KpixReadDelay"]->getReg(&ok);  if ( !ok ) okAll = false;
   kpixReadEdge   = variables_["KpixReadEdge"]->getReg(&ok);   if ( !ok ) okAll = false;
   bncSourceA     = variables_["BncSourceA"]->getReg(&ok);     if ( !ok ) okAll = false;
   bncSourceB     = variables_["BncSourceB"]->getReg(&ok);     if ( !ok ) okAll = false;
   dropData       = variables_["DropData"]->getReg(&ok);       if ( !ok ) okAll = false;
   rawData        = variables_["RawData"]->getReg(&ok);        if ( !ok ) okAll = false;
   extRunSource   = variables_["ExtRunSource"]->getReg(&ok);   if ( !ok ) okAll = false;
   extRunDelay    = variables_["ExtRunDelay"]->getReg(&ok);    if ( !ok ) okAll = false;
   extRunType     = variables_["ExtRunType"]->getReg(&ok);     if ( !ok ) okAll = false;
   extRecord      = variables_["ExtRecord"]->getReg(&ok);      if ( !ok ) okAll = false;
   trigEnable     = variables_["TrigEnable"]->getReg(&ok);     if ( !ok ) okAll = false;
   trigExpand     = variables_["TrigExpand"]->getReg(&ok);     if ( !ok ) okAll = false;
   calDelay       = variables_["CalDelay"]->getReg(&ok);       if ( !ok ) okAll = false;
   trigSource     = variables_["TrigSource"]->getReg(&ok);     if ( !ok ) okAll = false;
   runEnable      = variables_["RunEnable"]->getReg(&ok);      if ( !ok ) okAll = false;

   // Error
   err.str("");
   if ( ! okAll ) {
      err << "KpixFpga::write -> Bad config value detected" << endl;
      if ( debug_ ) err << "KpixFpga::write -> Bad config value detected" << endl;
   }

   // Verify clock settings
   if ( clkPeriodAcq  < 10 || clkPeriodAcq  > 320 || (clkPeriodAcq  % 10) != 0 ||
        clkPeriodIdle < 10 || clkPeriodIdle > 320 || (clkPeriodIdle % 10) != 0 ||
        clkPeriodDig  < 10 || clkPeriodDig  > 320 || (clkPeriodDig  % 10) != 0 ||
        clkPeriodRead < 10 || clkPeriodRead > 320 || (clkPeriodRead % 10) != 0 ) {
      err << "KpixFpga::write -> Bad clock period value detected" << endl;
      if ( debug_ ) err << "KpixFpga::write -> Bad clock period value detected" << endl;
   }

   // Verify delay setting
   if ( kpixReadDelay > clkPeriodAcq  || kpixReadDelay > clkPeriodIdle ||
        kpixReadDelay > clkPeriodDig  || kpixReadDelay > clkPeriodRead ) {
      err << "KpixFpga::write -> Bad read delay value detected" << endl;
      if ( debug_ ) err << "KpixFpga::write -> Bad read delay value detected" << endl;
   }

   // Debug
   if ( debug_ ) {
      cout << "KpixFpga::write -> writing config: " << endl;
      cout << "                   FpgaScratchpad = " << variables_["FpgaScratchpad"]->get() << endl;
      cout << "                   ClkPeriodAcq   = " << variables_["ClkPeriodAcq"]->get() << endl;
      cout << "                   ClkPeriodIdle  = " << variables_["ClkPeriodIdle"]->get() << endl;
      cout << "                   ClkPeriodDig   = " << variables_["ClkPeriodDig"]->get() << endl;
      cout << "                   ClkPeriodRead  = " << variables_["ClkPeriodRead"]->get() << endl;
      cout << "                   KpixReadDelay  = " << variables_["KpixReadDelay"]->get() << endl;
      cout << "                   KpixReadEdge   = " << variables_["KpixReadEdge"]->get() << endl;
      cout << "                   BncSourceA     = " << variables_["BncSourceA"]->get() << endl;
      cout << "                   BncSourceB     = " << variables_["BncSourceB"]->get() << endl;
      cout << "                   RawData        = " << variables_["RawData"]->get() << endl;
      cout << "                   ExtRunSource   = " << variables_["ExtRunSource"]->get() << endl;
      cout << "                   ExtRunDelay    = " << variables_["ExtRunDelay"]->get() << endl;
      cout << "                   ExtRunType     = " << variables_["ExtRunType"]->get() << endl;
      cout << "                   ExtRecord      = " << variables_["ExtRecord"]->get() << endl;
      cout << "                   TrigEnable     = " << variables_["TrigEnable"]->get() << endl;
      cout << "                   TrigExpand     = " << variables_["TrigExpand"]->get() << endl;
      cout << "                   CalDelay       = " << variables_["CalDelay"]->get() << endl;
      cout << "                   TrigSource     = " << variables_["TrigSource"]->get() << endl;
   }

   // Set registers
   registers_["Scratchpad"]->set(fpgaScratchpad);
   registers_["Clock Select"]->set(clkPeriodAcq,0,0x1F);
   registers_["Clock Select"]->set(clkPeriodIdle,24,0x1F);
   registers_["Clock Select"]->set(clkPeriodDig,8,0x1F);
   registers_["Clock Select"]->set(clkPeriodRead,16,0x1F);
   registers_["USB Delay"]->set(kpixReadDelay,0,0xFF);
   registers_["USB Delay"]->set(kpixReadEdge,8,0xFF);
   registers_["KPIX Control"]->set(bncSourceA,16,0x1F);
   registers_["KPIX Control"]->set(bncSourceB,21,0x1F);
   registers_["KPIX Control"]->set(dropData,4,0x1);
   registers_["KPIX Control"]->set(rawData,5,0x1);
   registers_["External Run"]->set(extRunSource,16,0x7);
   registers_["External Run"]->set(extRunDelay,0,0xFFFF);
   registers_["External Run"]->set(extRunType,19,0x1);
   registers_["External Run"]->set(extRecord,20,0x1);
   registers_["Trigger Control"]->set(trigEnable,0,0xFF);
   registers_["Trigger Control"]->set(trigExpand,8,0xFF);
   registers_["Trigger Control"]->set(calDelay,16,0xFF);
   registers_["Trigger Control"]->set(trigSource,24,0x1);
   registers_["Run Enable"]->set(runEnable,0,0x1);

   // Return errors
   return(err.str());
}


//! Set Master Reset
void KpixFpga::setMasterReset() {
   registers_["Version/Mast Reset"]->setStale();
}


//! Set KPIX Reset
void KpixFpga::setKpixReset() {
   registers_["Jumper/Kpix Reset"]->setStale();

}


//! Set Counter Reset
void KpixFpga::setCountReset() {
   registers_["Checksum Error"]->setStale();
   registers_["Parity Error"]->setStale();
   registers_["Train Number"]->setStale();
   registers_["Dead Counter"]->setStale();
}


//! Return version
uint KpixFpga::version() {
   return(version_);
}

