//-----------------------------------------------------------------------------
// File          : KpixFpga.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/30/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for class for managing the KPIX FPGA. This class is used for
// register access & command control. This class contains individual functions
// which hide the details of the individual registers and differences
// between FPGA versions. Direct register access is still possible using the
// pubilic fpgaRegister array.
// This class can be serialized into a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/30/2007: created
// 04/30/2007: Modified to throw strings instead of const char *
// 07/24/2007: Added support for USB delay.
// 08/07/2007: Added auto run type flag, added support for external run start
//             signal.
// 08/12/2007: Added temperature readback
// 09/19/2007: Added raw data control flag
// 10/11/2007: Added select polarity flag
// 12/17/2007: Added reset pulse extension
// 09/26/2008: Added method to set FPGA defaults.
// 10/23/2008: Added method to set sidLink object.
// 02/06/2009: Added methods to set digization and readout clocks & kpix Version
// 04/29/2009: Added readEn flag to some read calls.
// 05/13/2009: Changed name of accept source to extRecord 
// 05/13/2009: Removed auto train generation logic.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <unistd.h>
#include <stdlib.h>
#include "KpixFpga.h"
using namespace std;
using namespace sidApi::offline;

#ifdef ONLINE_EN
#include "../online/SidLink.h"
using namespace sidApi::online;
#endif


ClassImp(KpixFpga)


// Private method to write register value to Kpix Fpga
void KpixFpga::regWrite ( unsigned char address ) {

#ifdef ONLINE_EN
   unsigned short frameData[4];

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regWrite -> Address out of range");

   // Link has not been set
   if ( sidLink == NULL ) throw string("KpixFpga::regWrite -> FPGA Link Not Open");

   // Debug write
   if ( enDebug ) cout << "KpixFpga::regWrite -> Write '"
      << regGetName(address) << "' (0x"
      << hex << setw(2) << setfill('0') << (int)address << ") Data=0x" 
      << setw(8) << setfill('0') << hex << (int)regData[address] << "\n";

   // Format command, word 0
   frameData[0]  = (address & 0x00FF);
   frameData[0] |= 0x0100; // Write

   // Set data to zero for reset on write registers
   if ( regReset[address] ) {
      frameData[1] = 0;
      frameData[2] = 0;
   }

   // Write data word 1 & 2
   else {
      frameData[1] = (regData[address] & 0xFFFF);
      frameData[2] = ((regData[address] >> 16) & 0xFFFF);
   }

   // Checksum 
   frameData[3] = ((frameData[0] + frameData[1] + frameData[2]) & 0xFFFF);

   // Write data
   sidLink->linkFpgaWrite(frameData,4);
#endif
}


// Private method to read register value from Kpix
void KpixFpga::regRead ( unsigned char address ) {

#ifdef ONLINE_EN
   unsigned short frameWrData[4];
   unsigned short frameRdData[4];

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regRead -> Address out of range");

   // Link has not been set
   if ( sidLink == NULL ) throw string("KpixFpga::regRead -> FPGA Link Not Open");

   // Debug read start
   if ( enDebug ) cout << "KpixFpga::regRead -> Reading '" 
      << regGetName(address) << "' (0x"
      << hex << setw(2) << setfill('0') << (int)address << ")\n";

   // Format command, word 0
   frameWrData[0]  = (address & 0x00FF);

   // word 1 & 2 are 0
   frameWrData[1] = 0;
   frameWrData[2] = 0;

   // Checksum 
   frameWrData[3] = frameWrData[0];

   // Write data
   sidLink->linkFpgaWrite(frameWrData,4);

   // Read response data
   sidLink->linkFpgaRead(frameRdData,4);

   // Check for checksum error
   if ( frameRdData[3] != ((frameRdData[2] + frameRdData[1] + frameRdData[0]) & 0xFFFF) ) 
      throw string("KpixFpga::regRead -> Checksum Error");

   // Mark sure first word matches
   if ( frameRdData[0] != frameWrData[0] )
      throw string("KpixFpga::regRead -> Command Data Mismatch");

   // Update read data
   regData[address]  = (frameRdData[1] & 0x0000FFFF);
   regData[address] |= ((frameRdData[2] << 16) & 0xFFFF0000);

   // Debug read
   if ( enDebug ) cout << "KpixFpga::regRead -> Read '" << regGetName(address)
      << "' (0x" << hex << setw(2) << setfill('0') << (int)address << ") Data=0x" 
      << setw(8) << setfill('0') << hex << (int)regData[address] << "\n";
#endif
}


// Kpix FPGA Constructor
KpixFpga::KpixFpga ( ) {

   unsigned int  i;
   stringstream tempString;

   valid   = false;
   enDebug = false;

#ifdef ONLINE_EN
   // SID Link Object
   this->sidLink = NULL;
#endif

   // Init register data
   for ( i=0; i < 0x40; i++ ) {
      this->regData[i]      = 0;
      this->regWriteable[i] = false;
      this->regReset[i]     = false;
   }
}

#ifdef ONLINE_EN

// Kpix FPGA Constructor
// Pass SID Link Object
KpixFpga::KpixFpga ( SidLink *sidLink ) {

   unsigned int  i;
   stringstream tempString;

   // Copy version & address
   enDebug = false;
   valid   = true;

   // SID Link Object
   this->sidLink = sidLink;

   // Init register data
   for ( i=0; i < 0x40; i++ ) {
      regData[i]      = 0;
      regReset[i]     = 0;
      regWriteable[i] = false;
   }

   // Setup registers
   regWriteable[0x00] = false; // Version/Master Reset
   regReset[0x00]     = true;
   regWriteable[0x01] = false; // Jumper/Kpix Reset
   regReset[0x01]     = true;
   regWriteable[0x02] = true;  // Scratchpad Register
   regReset[0x02]     = false;
   regWriteable[0x03] = true;  // Clock Select Register
   regReset[0x03]     = false;
   regData[0x03]      = 0x00040404; 
   regWriteable[0x04] = true;  // Checksum error counter
   regReset[0x04]     = true;
   regWriteable[0x08] = true;  // Kpix Control Register
   regReset[0x08]     = false;
   regWriteable[0x09] = true;  // Parity Error Register
   regReset[0x09]     = true;
   regWriteable[0x0B] = true;  // Trigger Control Register
   regReset[0x0B]     = false;
   regWriteable[0x0C] = true;  // Train Number Register
   regReset[0x0C]     = true;
   regWriteable[0x0D] = true;  // Dead counter register
   regReset[0x0D]     = true;
   regWriteable[0x0E] = true;  // External Run Register
   regReset[0x0E]     = false;
}


// Set SID Link
void KpixFpga::setSidLink ( SidLink *sidLink ) {
   this->sidLink = sidLink;
}

#endif


// Send master reset command to FPGA
// This command will reset the entire device include
// the clock generation logic of the FPGA
void KpixFpga::cmdResetMst ( ) { 
   if ( enDebug ) cout << "KpixFpga::cmdResetMst -> Sending Reset.\n";
   regWrite(0x00);
   usleep(100);
}


// Send reset command to KPIX logic
// This command will reset the Kpix interface logic and
// all registers except for the clock generation register
void KpixFpga::cmdResetKpix ( ) { 
   if ( enDebug ) cout << "KpixFpga::cmdResetKpix -> Sending Reset.\n";
   regWrite(0x01);
   usleep(100);
}


// Method to set register value
// Pass the following values
// address = Register address
// value   = 32-Bit register value
// writeEn = Flag to perform actual write
void KpixFpga::regSetValue ( unsigned char address, unsigned int value, bool writeEn ) {

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regSetValue -> Address out of range");

   // Don't set value if register is read only
   if ( regWriteable[address] ) {

      // Set Ddata
      regData[address] = value;

      // Write register if write flag is set
      if ( writeEn ) regWrite ( address );
   }
}


// Method to get register value
// Pass the following values
// address = Register address
// read    = Flag to perform actual write
unsigned int KpixFpga::regGetValue ( unsigned char address, bool readEn ) {

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regGetValue -> Address out of range");

   // Read if read enable flag is set
   if ( readEn ) regRead ( address );
   return(regData[address]);
}


// Method to set register bit
// Pass the following values
// address = Register address
// bit     = Bit to set
// value   = Value to set, true or false
// writeEn = Flag to perform actual write
void KpixFpga::regSetBit ( unsigned char address, unsigned char bit, bool value, bool writeEn ){

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(address,false);

   // Setting bit
   if ( value ) temp |= (1 << bit);

   // Clearing bit
   else temp &= ((1 << bit) ^ 0xFFFFFFFF);

   // Set new value
   regSetValue ( address, temp, writeEn );
}


// Method to get register bit
// Pass the following values
// address = Register address
// bit     = Bit to get
// read    = Flag to perform actual write
bool KpixFpga::regGetBit ( unsigned char address, unsigned char bit, bool readEn ) {

   // Get value
   unsigned int temp = regGetValue(address,readEn);
   return((temp & (1 << bit)) != 0);
}


// Method to return register name
// Pass the register address
string KpixFpga::regGetName ( unsigned char address ) {

   string temp;
   stringstream tempString;

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regGetName -> Address out of range");

   // Set default value
   temp = "Unused";

   // Return register name
   if ( address == 0x00 ) temp = "Version/Master Reset Reg";
   if ( address == 0x01 ) temp = "Jumper/Kpix Reset Reg";
   if ( address == 0x02 ) temp = "Scratchpad Reg";
   if ( address == 0x03 ) temp = "Clock Select Reg";
   if ( address == 0x04 ) temp = "CheckSum Error Count Reg";
   if ( address == 0x05 ) temp = "USB Delay Reg";
   if ( address == 0x07 ) temp = "Temperature Value Reg";
   if ( address == 0x08 ) temp = "Kpix Control Reg";
   if ( address == 0x09 ) temp = "Parity Error Reg";
   if ( address == 0x0A ) temp = "Run Control Reg";
   if ( address == 0x0B ) temp = "Trigger Control Reg";
   if ( address == 0x0C ) temp = "Train Number Reg";
   if ( address == 0x0D ) temp = "Dead Counter Reg";
   if ( address == 0x0E ) temp = "External Run Reg";

   // Return value
   return(temp);
}


// Method to return register writable flag
// Pass the register address
bool KpixFpga::regGetWriteable ( unsigned char address ) {

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regGetWritable -> Address out of range");
   return(regWriteable[address]);
}


// Method to return register reset on write flag
// Pass the register address
bool KpixFpga::regGetReset ( unsigned char address ) {

   // Check for valid address
   if ( address >= 0x40 ) throw string("KpixFpga::regGetReset -> Address out of range");
   return(regReset[address]);
}


// Method to get FPGA Version
// Set readEn to false to disable real read from FPGA.
unsigned int KpixFpga::getVersion ( bool readEn ) { 
   unsigned int ret = regGetValue ( 0x00, readEn );
   if ( enDebug ) {
      cout << "KpixFpga::getVersion -> Version=";
      cout << hex << setfill('0') << setw(8) << ret << ".\n";
   }
   return(ret);
}


// Method to get FPGA Jumper Inputs.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getJumpers ( bool readEn ) { 
   unsigned int ret = regGetValue ( 0x01, readEn ) & 0x0F;
   if ( enDebug ) {
      cout << "KpixFpga::getJumpers -> Jumpers=";
      cout << hex << setfill('0') << setw(1) << ret << ".\n";
   }
   return(ret);
}


// Method to set FPGA scratchpad register contents.
// Default value = 0x00000000
// Pass integer data
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setScratchPad ( unsigned int value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setScatchPad -> Set ScarchPad=";
      cout << setw(8) << setfill('0') << hex << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetValue(0x02,value,writeEn);
}


// Method to get FPGA scratchpad register contents.
// Set readEn to false to disable real read from FPGA.
unsigned int KpixFpga::getScratchPad ( bool readEn ) {
   unsigned int ret = regGetValue ( 0x02, readEn );
   if ( enDebug ) {
      cout << "KpixFpga::getScratchPad -> ScratchPad=";
      cout << hex << setfill('0') << setw(1) << ret << ".\n";
   }
   return(ret);
}


// Method to set FPGA clock control register.
// Default value = 50ns (20Mhz)
// Pass value containing the desired clock period. Valid values are
// multiples of 10ns from 10ns to 320 ns.
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setClockPeriod ( unsigned short period, bool writeEn ) {

   unsigned int set;
   unsigned int value;

   // Get register
   value = regGetValue(0x03,false);

   // Verify range
   if ( period < 10 || period > 320 || (period % 10) != 0 ) 
      throw string("KpixFpga::setClockPeriod -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setClockPeriod -> Set ClockPeriod=";
      cout << setw(3) << setfill('0') << dec << period << " ns";
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Convert value
   set = ((period / 10) - 1);

   // Set proper bits
   value &= 0xFFFFFF00;
   value |= (set & 0xFF);

   // Set register
   regSetValue(0x03,value,writeEn);
}


// Method to set FPGA clock period.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getClockPeriod ( bool readEn ) {

   // Get Value
   unsigned int val = regGetValue ( 0x03, readEn ) & 0x1F;

   // Convert value
   unsigned short ret = ((val&0xFF) + 1) * 10;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getClockPeriod -> ClockPeriod=";
      cout << hex << setfill('0') << setw(1) << ret << ".\n";
   }
   return(ret);
}


// Method to set FPGA digization clock control register.
// Default value = 50ns (20Mhz)
// Pass value containing the desired clock period. Valid values are
// multiples of 10ns from 10ns to 320 ns.
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setClockPeriodDig ( unsigned short period, bool writeEn ) {

   unsigned int set;
   unsigned int value;

   // Get register
   value = regGetValue(0x03,false);

   // Verify range
   if ( period < 10 || period > 320 || (period % 10) != 0 ) 
      throw string("KpixFpga::setClockPeriodDig -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setClockPeriodDig -> Set ClockPeriodDig=";
      cout << setw(3) << setfill('0') << dec << period << " ns";
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Convert value
   set = ((period / 10) - 1);

   // Set proper bits
   value &= 0xFFFF00FF;
   value |= ((set << 8) & 0xFF00);

   // Set register
   regSetValue(0x03,value,writeEn);
}


// Method to set FPGA digization clock period.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getClockPeriodDig ( bool readEn ) {

   // Get Value
   unsigned int val = regGetValue ( 0x03, readEn );

   // Convert value
   unsigned short ret = (((val>>8)&0xFF) + 1) * 10;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getClockPeriodDig -> ClockPeriodDig=";
      cout << hex << setfill('0') << setw(1) << ret << ".\n";
   }
   return(ret);
}


// Method to set FPGA readout clock control register.
// Default value = 50ns (20Mhz)
// Pass value containing the desired clock period. Valid values are
// multiples of 10ns from 10ns to 320 ns.
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setClockPeriodRead ( unsigned short period, bool writeEn ) {

   unsigned int set;
   unsigned int value;

   // Get register
   value = regGetValue(0x03,false);

   // Verify range
   if ( period < 10 || period > 320 || (period % 10) != 0 ) 
      throw string("KpixFpga::setClockPeriodRead -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setClockPeriodRead -> Set ClockPeriodRead=";
      cout << setw(3) << setfill('0') << dec << period << " ns";
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Convert value
   set = ((period / 10) - 1);

   // Set proper bits
   value &= 0xFF00FFFF;
   value |= ((set << 16) & 0xFF0000);

   // Set register
   regSetValue(0x03,value,writeEn);
}


// Method to set FPGA readout clock period.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getClockPeriodRead ( bool readEn ) {

   // Get Value
   unsigned int val = regGetValue ( 0x03, readEn );

   // Convert value
   unsigned short ret = (((val>>16)&0xFF) + 1) * 10;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getClockPeriodRead -> ClockPeriodRead=";
      cout << hex << setfill('0') << setw(1) << ret << ".\n";
   }
   return(ret);
}


// Method to get FPGA receive checksum error counter
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getCheckSumErrors ( bool readEn ) {

   // Get Value
   unsigned char ret = regGetValue ( 0x04, readEn ) & 0xFF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getCheckSumErrors -> CheckSum Errors=";
      cout << hex << setfill('0') << setw(1) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to reset FPGA receive checksum error counter
void KpixFpga::cmdRstCheckSumErrors () {
   if ( enDebug ) cout << "KpixFpga::cmdRstCheckSumErrors -> Sending Reset.\n";
   regWrite(0x04);
}


// Method to set BNC A output source.
// Default value = 0 (RegClock)
// Valid range of values are 0 - 31
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setBncSourceA ( unsigned char value, bool writeEn ) {

   // Verify range
   if ( value > 31  ) throw string("KpixFpga::setBncSourceA -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setBncSourceA -> Set BncSourceA=";
      cout << setw(3) << setfill('0') << dec << (int)value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x08,false);

   // Set value
   temp &= 0xFFE0FFFF;
   temp |= (value << 16) & 0x001F0000;

   // Set new value
   regSetValue ( 0x08, temp, writeEn );
}


// Method to get BNC A output source.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getBncSourceA ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x08, readEn );

   // Convert value
   unsigned char ret = (temp >> 16) & 0x1F;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getBncSourceA -> BncSourceA=";
      cout << hex << setfill('0') << setw(3) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to set BNC B output source.
// Default value = 0 (RegClock)
// Valid range of values are 0 - 31
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setBncSourceB ( unsigned char value, bool writeEn ) {

   // Verify range
   if ( value > 31  ) throw string("KpixFpga::setBncSourceB -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setBncSourceB -> Set BncSourceB=";
      cout << setw(3) << setfill('0') << dec << (int)value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x08,false);

   // Set value
   temp &= 0xFC1FFFFF;
   temp |= (value << 21) & 0x03E00000;

   // Set new value
   regSetValue ( 0x08, temp, writeEn );
}


// Method to get BNC B output source.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getBncSourceB ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x08, readEn );

   // Convert value
   unsigned char ret = (temp >> 21) & 0x1F;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getBncSourceB -> BncSourceB=";
      cout << hex << setfill('0') << setw(3) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to set Drop Data Flag, this drops all received data.
// Default value = False
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setDropData ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setDropData -> Set DropData=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,4,value,writeEn);
}


// Method to get Drop Data Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getDropData ( bool readEn ) {
   bool ret = regGetBit(0x08,4,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getDropData -> Get DropData=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Kpix Version Flag. false = 0-7, true = 8+
// Default value = False
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setKpixVer ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setKpixVer -> Set KpixVer=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,28,value,writeEn);
}


// Method to get Kpix Version Flag, false = 0-7, true = 8+
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getKpixVer ( bool readEn ) {
   bool ret = regGetBit(0x08,28,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getKpixVer -> Get KpixVer=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Raw Data Flag.
// Default value = False
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setRawData ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setRawData -> Set RawData=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,5,value,writeEn);
}


// Method to get Raw Data Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getRawData ( bool readEn ) {
   bool ret = regGetBit(0x08,5,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getRawData -> Get RawData=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Kpix A Disable Flag. (Kpix Address 0)
// Default value = True
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setDisKpixA ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setDisKpixA -> Set DisKpixA=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,0,value,writeEn);
}


// Method to get Kpix A Disable Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getDisKpixA ( bool readEn ) {
   bool ret = regGetBit(0x08,0,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getDisKpixA -> Get DisKpixA=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Kpix B Disable Flag. (Kpix Address 0)
// Default value = True
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setDisKpixB ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setDisKpixB -> Set DisKpixB=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,1,value,writeEn);
}


// Method to get Kpix B Disable Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getDisKpixB ( bool readEn ) {
   bool ret = regGetBit(0x08,1,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getDisKpixB -> Get DisKpixB=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Kpix C Disable Flag. (Kpix Address 0)
// Default value = True
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setDisKpixC ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setDisKpixC -> Set DisKpixC=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,2,value,writeEn);
}


// Method to get Kpix C Disable Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getDisKpixC ( bool readEn ) {
   bool ret = regGetBit(0x08,2,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getDisKpixC -> Get DisKpixC=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set Kpix D Disable Flag. (Kpix Address 0)
// Default value = True
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setDisKpixD ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setDisKpixD -> Set DisKpixD=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x08,3,value,writeEn);
}


// Method to get Kpix D Disable Flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getDisKpixD ( bool readEn ) {
   bool ret = regGetBit(0x08,3,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getDisKpixD -> Get DisKpixD=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to get KPIX response parity error counter.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getRspParErrors ( bool readEn ) {
   unsigned int temp = regGetValue ( 0x09, readEn );
   unsigned char ret = ((temp >> 8) & 0xFF);
   if ( enDebug ) {
      cout << "KpixFpga::getRspParErrors -> RspParErrors=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to get KPIX data parity error counter.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getDataParErrors ( bool readEn ) {
   unsigned int temp = regGetValue ( 0x09, readEn );
   unsigned char ret = (temp & 0xFF);
   if ( enDebug ) {
      cout << "KpixFpga::getDataParErrors -> DataParErrors=";
      cout << hex << setfill('0') << setw(2) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to reset KPIX response/data parity error counters.
void KpixFpga::cmdRstParErrors () {
   if ( enDebug ) cout << "KpixFpga::cmdRstParErrors -> Sending Reset.\n";
   regWrite(0x09);
}


// Method to set source for external run trigger
// Valid values are 0-4
// Default value = 0 None.
// Pass source index.
//  0x0 = None. Disable.
//  0x1 = NIMA Input
//  0x2 = NIMB Input
//  0x3 = BncA Input
//  0x4 = BncB Input
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setExtRunSource ( unsigned char value, bool writeEn ) {

   // Verify range
   if ( value > 4 ) throw string("KpixFpga::setExtRunSource -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setExtRunSource -> Set ExtRunSource=";
      cout << setw(2) << setfill('0') << dec << (int)value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0E,false);

   // Set value
   temp &= 0xFFF8FFFF;
   temp |= (value << 16) & 0x00070000;

   // Set new value
   regSetValue ( 0x0E, temp, writeEn );
}


// Method to get source for external run trigger
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getExtRunSource ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0E, readEn );

   // Convert value
   unsigned char ret = ((temp >> 16) & 0x7);

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getExtRunSource -> ExtRunSource=";
      cout << hex << setfill('0') << setw(2) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to set delay in clock counts between external
// trigger signal and sending of acquisition command.
// Valid values are 0-65535
// Default value = 0 None.
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setExtRunDelay ( unsigned short value, bool writeEn ) {

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setExtRunDelay -> Set ExtRunDelay=";
      cout << setw(2) << setfill('0') << dec << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0E,false);

   // Set value
   temp &= 0xFFFF0000;
   temp |= value & 0x0000FFFF;

   // Set new value
   regSetValue ( 0x0E, temp, writeEn );
}


// Method to get delay in clock counts between external
// trigger signal and sending of acquisition command.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getExtRunDelay ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0E, readEn );

   // Convert value
   unsigned short ret = temp  & 0xFFFF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getExtRunDelay -> ExtRunDelay=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to choose external train type, True=Calibrate, False=Acquire
// Default value = False
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setExtRunType ( bool value, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixFpga::setExtRunType -> Set ExtRunType=" << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x0E,19,value,writeEn);
}


// Method to get auto train type flag.
// Set readEn to false to disable real read from FPGA.
bool KpixFpga::getExtRunType ( bool readEn ) {
   bool ret = regGetBit(0x0E,19,readEn); 
   if ( enDebug ) {
      cout << "KpixFpga::getExtRunType -> Get ExtRunType=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set source for external records.
// Valid values are 0-4
// Default value = 0 None.
// Pass source index.
//  0x0 = None. Disable.
//  0x1 = NIMA Input
//  0x2 = NIMB Input
//  0x3 = BncA Input
//  0x4 = BncB Input
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setExtRecord ( unsigned char value, bool writeEn ) {

   // Verify range
   if ( value > 4 ) throw string("KpixFpga::setExtRecord -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setExtRecord -> Set ExtRecord=";
      cout << setw(2) << setfill('0') << dec << (int)value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0E,false);

   // Set value, bits 22-20
   temp &= 0xFF8FFFFF;
   temp |= (value << 20) & 0x00700000;

   // Set new value
   regSetValue ( 0x0E, temp, writeEn );
}


// Method to get source for external records
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getExtRecord ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0E, readEn );

   // Convert value, bits 22-20
   unsigned char ret = (temp >> 20) & 0x7;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getExtRecord -> ExtRecord=";
      cout << hex << setfill('0') << setw(2) << (int)ret << ".\n";
   }
   return(ret);
}


// Method to set external trigger enable windows
// Pass bit mask (8-bits) to define which portions of the bunch
// clock period are enabled for external trigger. Each bit 
// represents on clock period.
// Default value = 0x00
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setTrigEnable ( unsigned char mask, bool writeEn ) {

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setTrigEnable -> Set TrigEnable=";
      cout << setw(2) << setfill('0') << dec << mask;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0B,false);

   // Set value
   temp &= 0xFFFFFF00;
   temp |= mask & 0x000000FF;

   // Set new value
   regSetValue ( 0x0B, temp, writeEn );
}


// Method to get external trigger enable windows
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getTrigEnable ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0B, readEn );

   // Convert value
   unsigned short ret = temp & 0x000000FF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getTrigEnable -> TrigEnable=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to set the number of clock periods to expand the
// force trigger signal. Set to 0 for no expansion. 
// Valid values are 0-255
// Default value = 0
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setTrigExpand ( unsigned char count, bool writeEn ) {

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setTrigExpand -> Set TrigExpand=";
      cout << setw(2) << setfill('0') << dec << count;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0B,false);

   // Set value
   temp &= 0xFFFF00FF;
   temp |= (count << 8) & 0x0000FF00;

   // Set new value
   regSetValue ( 0x0B, temp, writeEn );
}


// Method to get the number of clock periods to expand the
// force trigger signal. Set to 0 for no expansion. 
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getTrigExpand ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0B, readEn );

   // Convert value
   unsigned short ret = (temp >> 8) & 0xFF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getTrigExpand -> TrigExpand=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to set the number of clock periods to expand the
// cal_strobe signal for the CalStrobeDelay signal.
// Valid values are 0-255
// Default value = 0
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setCalDelay ( unsigned char count, bool writeEn ) {

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setCalDelay -> Set CalDelay=";
      cout << setw(2) << setfill('0') << dec << count;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0B,false);

   // Set value
   temp &= 0xFF00FFFF;
   temp |= (count << 16) & 0x00FF0000;

   // Set new value
   regSetValue ( 0x0B, temp, writeEn );
}


// Method to get the number of clock periods to expand the
// cal_strobe signal for the CalStrobeDelay signal.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getCalDelay ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0B, readEn );

   // Convert value
   unsigned short ret = (temp >> 16) & 0x000000FF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getCalDelay -> CalDelay=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to set the force trigger source.
// Valid values are 0-15
// Default value = 0 None.
// Set writeEn to false to disable real write to KPIX
void KpixFpga::setTrigSource ( unsigned char value, bool writeEn ) {

   // Verify range
   if ( value > 15 ) throw string("KpixFpga::setTrigSource -> Invalid Value");

   // Output value
   if ( enDebug ) {
      cout << "KpixFpga::setTrigSource -> Set TrigSource=";
      cout << setw(2) << setfill('0') << dec << value;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(0x0B,false);

   // Set value
   temp &= 0xF0FFFFFF;
   temp |= (value << 24) & 0x0F000000;

   // Set new value
   regSetValue ( 0x0B, temp, writeEn );
}


// Method to get BNC B output source.
// Set readEn to false to disable real read from FPGA.
unsigned char KpixFpga::getTrigSource ( bool readEn ) {

   // Get Value
   unsigned int temp = regGetValue ( 0x0B, readEn );

   // Convert value
   unsigned short ret = (temp >> 24) & 0xF;

   // Debug
   if ( enDebug ) {
      cout << "KpixFpga::getTrigSource -> TrigSource=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to get KPIX train number value.
// Set readEn to false to disable real read from FPGA.
unsigned int KpixFpga::getTrainNumber ( bool readEn ) {
   unsigned int ret = regGetValue ( 0x0C, readEn );
   if ( enDebug ) {
      cout << "KpixFpga::getTrainNumber -> TrainNumber=";
      cout << hex << setfill('0') << setw(8) << ret << ".\n";
   }
   return(ret);
}


// Method to reset KPIX train number value.
void KpixFpga::cmdRstTrainNumber () {
   if ( enDebug ) cout << "KpixFpga::cmdRstTrainNumbers -> Sending Reset.\n";
   regWrite(0x0C);
}


// Method to get KPIX dead time counter.
// Set readEn to false to disable real read from FPGA.
unsigned short KpixFpga::getDeadCount ( bool readEn ) {
   unsigned short ret = regGetValue ( 0x0D, readEn ) & 0xFFFF;
   if ( enDebug ) {
      cout << "KpixFpga::getDeadCount -> DeadCount=";
      cout << hex << setfill('0') << setw(2) << ret << ".\n";
   }
   return(ret);
}


// Method to reset KPIX dead time counter.
void KpixFpga::cmdRstDeadCount () {
   if ( enDebug ) cout << "KpixFpga::cmdRstDeadCount -> Sending Reset.\n";
   regWrite(0x0D);
}


// Deconstructor
KpixFpga::~KpixFpga ( ) { }


// Turn on or off debugging for the class
void KpixFpga::fpgaDebug ( bool debug ) { 

   // Debug if enabled
   if ( enDebug ) 
      cout << "KpixFpga::fpgaDebug -> updating debug to " << debug << "\n";
   else if ( debug ) 
      cout << "KpixFpga::fpgaDebug -> enabling debug\n";

   // Local debug flag
   enDebug = debug;
}


// Get valid flag
bool KpixFpga::getValid ( ) { return(valid); }


// Get debug flag
bool KpixFpga::fpgaDebug ( ) { return(enDebug); }


// Set Defaults
void KpixFpga::setDefaults ( unsigned int clkPeriod, bool kpixVer, bool writeEn ) {

   // Send resets if write is enabled
   if ( writeEn ) cmdResetMst();
   setClockPeriod(clkPeriod,writeEn );
   setClockPeriodDig(clkPeriod,writeEn );
   setClockPeriodRead(clkPeriod,writeEn );
   if ( writeEn ) cmdResetKpix();

   // Other defaults
   setKpixVer  ( kpixVer, writeEn ); // Not On Gui
   setBncSourceA ( 0x03, writeEn );
   setBncSourceB ( 0x03, writeEn );
   setDropData ( false, writeEn );
   setRawData ( false, writeEn );
   setDisKpixA ( false, writeEn ); // Not On Gui
   setDisKpixB ( false, writeEn ); // Not On Gui
   setDisKpixC ( false, writeEn ); // Not On Gui
   setDisKpixD ( false, writeEn ); // Not On Gui
   setExtRunSource ( 0, writeEn);
   setExtRunDelay ( 0, writeEn);
   setExtRunType ( false, writeEn);
   setExtRecord ( 0, writeEn);
   setTrigEnable ( 0xFF, writeEn);
   setTrigExpand ( 0, writeEn);
   setCalDelay ( 0, writeEn);
   setTrigSource ( 0, writeEn);
}


#ifdef ONLINE_EN
// Return SID Link Object Pointer
SidLink * KpixFpga::getSidLink () { return(sidLink); }
#endif


// Read from all registers will debug enabled to display all of the current settings
void KpixFpga::dumpSettings () {

   // Display data
   cout << "             Valid = " << getValid() << "\n";
   cout << "        ScratchPad = " << getScratchPad(false)  << "\n";
   cout << "       ClockPeriod = " << getClockPeriod(false) << "\n";
   cout << "    ClockPeriodDig = " << getClockPeriodDig(false)  << "\n";
   cout << "   ClockPeriodRead = " << getClockPeriodRead(false) << "\n";
   cout << "        BncSourceA = " << (int)getBncSourceA(false) << "\n";
   cout << "        BncSourceB = " << (int)getBncSourceB(false) << "\n";
   cout << "           KpixVer = " << getKpixVer(false)  << "\n";
   cout << "          DropData = " << getDropData(false) << "\n";
   cout << "           RawData = " << getRawData(false)  << "\n";
   cout << "          DisKpixA = " << getDisKpixA(false) << "\n";
   cout << "          DisKpixB = " << getDisKpixB(false) << "\n";
   cout << "          DisKpixC = " << getDisKpixC(false) << "\n";
   cout << "          DisKpixD = " << getDisKpixD(false) << "\n";
   cout << "      ExtRunSource = " << (int)getExtRunSource(false) << "\n";
   cout << "       ExtRunDelay = " << getExtRunDelay(false)       << "\n";
   cout << "        ExtRunType = " << getExtRunType(false)        << "\n";
   cout << "         ExtRecord = " << (int)getExtRecord(false) << "\n";
   cout << "        TrigEnable = " << (int)getTrigEnable(false)   << "\n";
   cout << "        TrigExpand = " << (int)getTrigExpand(false)   << "\n";
   cout << "          CalDelay = " << (int)getCalDelay(false)     << "\n";
   cout << "        TrigSource = " << (int)getTrigSource(false)   << "\n";
}
