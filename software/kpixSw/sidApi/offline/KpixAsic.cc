//-----------------------------------------------------------------------------
// File          : KpixAsic.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class for managing the KPIX ASIC. This class is used for
// register access & command control. This class contains individual functions
// which hide the details of the individual registers and differences
// between ASIC versions. Direct register access is still possible using the
// pubilic kpixRegister array.
// This class can be serialized into a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 11/10/2006: Added functions to support Kpix4,
// 12/01/2006: Removed set dac by voltages, added class variables to support dac
//             value to voltage and voltage to dac value conversions. Also 
//             created class method to convert settings to calibration charge.
// 12/19/2006: Added root support, got rid of register class to store
//             register values. Shadow register values are now incorporated
//             in this class. A location exists for all possible register
//             locations in order to ensure portability of data stored in
//             a root tree. Removed support to set dac by voltage, added
//             class methods to convert between voltage and dac value.
// 03/19/2007: Added HE_EN define flag. This must be defined in order to
//             compile in hardware support. Otherwise SidLink class will not
//             be used.
// 04/09/2007: Fixed bug in the setCalibMaskArray and setThreshRangeArray routines 
//             which could cause an error in setting the thresholds.
// 04/27/2007: Fixed bug in the setCalibMaskChan 
// 04/27/2007: Modified for new communication protocol, added kpix version 0
//             for FPGA based digital core.
// 04/30/2007: Modified to throw strings instead of const char *
// 08/05/2007: Added ability to pass bunch clock count instead of true ns delay.
//             This allows the user to keep a constant value in this field for
//             different CLOCK_PERIOD settings.
// 11/12/2007: Replaced thershold select and cal mask functions with channel mode
//             settings to support KPIX 6.
// 02/01/2008: Added setCntrlDisPerRst and setCntrlEnDcRst methods.
// 07/03/2008: Changed timing setting readback to return trigger inhibit as
//             bunch clock counts.
// 09/26/2008: Added method to set serial number and method to set defaults.
// 10/21/2008: Added method to return channel count.
// 10/23/2008: Added method to return max supported version.
// 10/23/2008: Added method to set sidLink object.
// 10/27/2008: Added method to get trigger inhibit time.
// 10/29/2008: Added dac to volt conversion with double input
// 02/06/2009: Added KPIX version 8 support
// 02/23/2009: Changed default timing values.
// 04/08/2009: Added flag in timing methods to set mode for trigger inhibit time
// 04/29/2009: Added readEn flag to some read calls.
// 05/15/2009: Added method to get bunch clock count.
// 06/09/2009: Added constructor flag to enable dummy kpix.
// 06/10/2009: Added method to convert temp adc value to a celcias value
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
// 07/07/2009: Fixed bug in getCntrlDisPwrCycle.
// 07/07/2009: Added support for KPIX9, put in forced timing values for Kpix 8.
// 04/22/2010: Added force power on for DAC accesses in KPIX 9.
// 05/18/2010: Adjusted default calibration spacing.
// 02/24/2011: KPIX A support
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include "KpixAsic.h"
using namespace std;

#ifdef ONLINE_EN
#include "../online/SidLink.h"
#endif


ClassImp(KpixAsic)

// Private method to send a command frame to the KPIX
// Pass command field and broadcast flag
void KpixAsic::sendCommand ( unsigned char command, bool bcast ) {

#ifdef ONLINE_EN
   unsigned short frameData[4];

   // Link has not been set
   if ( sidLink == NULL ) throw string("KpixAsic::sendCommand -> KPIX Link Not Open");

   // Debug write
   if ( enDebug ) 
      cout << "KpixAsic::sendCommand -> Sending Cmd=0x" << setw(2) << setfill('0') 
           << hex << (int)command << ", Kpix Address=0x" << setw(4) << setfill('0') 
           << hex << kpixAddress << ", Bcast=" << bcast << "\n";

   // Format command, word 0
   frameData[0]  = (command & 0x007F);
   frameData[0] |= 0x0080; // Write
   frameData[0] |= 0x0000; // Command
   frameData[0] |= ((kpixAddress << 9)  & 0x0600); // Assign lower 2-bits of kpixAddress
   frameData[0] |= ((kpixAddress << 10) & 0xF000); // Assign upper 4-bits of kpixAddress

   if ( bcast ) frameData[0] |= 0x0800;

   // word 1 & 2 are 0
   frameData[1] = 0;
   frameData[2] = 0;

   // Checksum equals first
   frameData[3] = frameData[0];

   // Write data
   sidLink->linkKpixWrite(frameData,4);
#endif
}


// Private method to write register value to Kpix
void KpixAsic::regWrite ( unsigned char address ) {

#ifdef ONLINE_EN
   unsigned short frameData[4];

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regWrite -> Address out of range");

   // Don't write if reg width is zero
   if ( regWidth[address] != 0 ) {

      // Link has not been set
      if ( sidLink == NULL ) throw string("KpixAsic::regWrite -> KPIX Link Not Open");

      // Debug write
      if ( enDebug ) cout << "KpixAsic::regWrite -> Kpix Address=0x" << setw(4) << setfill('0') 
           << hex << kpixAddress << ", Write '" << regGetName(address) << "' (0x"
         << hex << setw(2) << setfill('0') << (int)address << ") Data=0x" 
         << setw(8) << setfill('0') << hex << (int)regData[address] << "\n";

      // Format command, word 0
      frameData[0]  = (address & 0x007F);
      frameData[0] |= 0x0080; // Write
      frameData[0] |= 0x0100; // Reg Access
      frameData[0] |= ((kpixAddress << 9)  & 0x0600); // Assign lower 2-bits of kpixAddress
      frameData[0] |= ((kpixAddress << 10) & 0xF000); // Assign upper 4-bits of kpixAddress

      // word 1 & 2
      frameData[1] = (regData[address] & 0xFFFF);
      frameData[2] = ((regData[address] >> 16) & 0xFFFF);

      // Checksum 
      frameData[3] = ((frameData[0] + frameData[1] + frameData[2]) & 0xFFFF);

      // Write data
      sidLink->linkKpixWrite(frameData,4);
   }
#endif
}


// Private method to read register value from Kpix
void KpixAsic::regRead ( unsigned char address ) {

#ifdef ONLINE_EN
   unsigned short frameWrData[4];
   unsigned short frameRdData[4];

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regRead -> Address out of range");

   // Don't read if reg width is zero
   if ( regWidth[address] != 0 ) {

      // Link has not been set
      if ( sidLink == NULL ) throw string("KpixAsic::regRead -> KPIX Link Not Open");

      // Debug read start
      if ( enDebug ) cout << "KpixAsic::regRead -> Kpix Address=0x" << setw(4) << setfill('0') 
           << hex << kpixAddress << ", Reading '" << regGetName(address) << "' (0x"
         << hex << setw(2) << setfill('0') << (int)address << ")\n";

      // Format command, word 0
      frameWrData[0]  = (address & 0x007F);
      frameWrData[0] |= 0x0100; // Reg Access
      frameWrData[0] |= ((kpixAddress << 9)  & 0x0600); // Assign lower 2-bits of kpixAddress
      frameWrData[0] |= ((kpixAddress << 10) & 0xF000); // Assign upper 4-bits of kpixAddress

      // word 1 & 2 are 0
      frameWrData[1] = 0;
      frameWrData[2] = 0;

      // Checksum 
      frameWrData[3] = frameWrData[0];

      // Write data
      sidLink->linkKpixWrite(frameWrData,4);

      // Read response data
      sidLink->linkKpixRead(frameRdData,4);

      // Check for checksum error
      if ( frameRdData[3] != ((frameRdData[2] + frameRdData[1] + frameRdData[0]) & 0xFFFF) ) 
         throw string("KpixAsic::regRead -> Checksum Error");

      // Mark sure first word matches
      if ( frameRdData[0] != frameWrData[0] )
         throw string("KpixAsic::regRead -> Command Data Mismatch");

      // Update read data
      regData[address]  = (frameRdData[1] & 0x0000FFFF);
      regData[address] |= ((frameRdData[2] << 16) & 0xFFFF0000);

      // Debug read
      if ( enDebug ) cout << "KpixAsic::regRead -> Kpix Address=0x" << setw(4) 
         << setfill('0') << hex << kpixAddress << ", Read '" << regGetName(address)
         << "' (0x" << hex << setw(2) << setfill('0') << (int)address << ") Data=0x" 
         << setw(8) << setfill('0') << hex << (int)regData[address] << "\n";
   }
#endif
}


// Private method to verify register setting
void KpixAsic::regVerify ( unsigned char address ) {

#ifdef ONLINE_EN
   unsigned short frameWrData[4];
   unsigned short frameRdData[4];
   unsigned int   rdValue;
   stringstream   error;

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regVerify -> Address out of range");

   // Don't read if reg width is zero or is not writable
   if ( regWidth[address] != 0 && regWriteable[address] ) {

      // Link has not been set
      if ( sidLink == NULL ) throw string("KpixAsic::regVerify -> KPIX Link Not Open");

      // Debug read start
      if ( enDebug ) cout << "KpixAsic::regVerify -> Kpix Address=0x" << setw(4) << setfill('0') 
           << hex << kpixAddress << ", Reading '" << regGetName(address) << "' (0x"
         << hex << setw(2) << setfill('0') << (int)address << ")\n";

      // Format command, word 0
      frameWrData[0]  = (address & 0x007F);
      frameWrData[0] |= 0x0100; // Reg Access
      frameWrData[0] |= ((kpixAddress << 9) & 0x0600);
      frameWrData[0] |= ((kpixAddress << 10) & 0xF000);

      // word 1 & 2 are 0
      frameWrData[1] = 0;
      frameWrData[2] = 0;

      // Checksum 
      frameWrData[3] = frameWrData[0];

      // Write data
      sidLink->linkKpixWrite(frameWrData,4);

      // Read response data
      sidLink->linkKpixRead(frameRdData,4);

      // Check for checksum error
      if ( frameRdData[3] != ((frameRdData[2] + frameRdData[1] + frameRdData[0]) & 0xFFFF) ) 
         throw string("KpixAsic::regVerify -> Checksum Error");

      // Mark sure first word matches
      if ( frameRdData[0] != frameWrData[0] )
         throw string("KpixAsic::regVerify -> Command Data Mismatch");

      // Update read data
      rdValue  = (frameRdData[1] & 0x0000FFFF);
      rdValue |= ((frameRdData[2] << 16) & 0xFFFF0000);

      // Debug read
      if ( enDebug ) cout << "KpixAsic::regVerify -> Kpix Address=0x" << setw(4) 
         << setfill('0') << hex << kpixAddress << ", Read '" << regGetName(address)
         << "' (0x" << hex << setw(2) << setfill('0') << (int)address << ") Exp=0x" 
         << setw(8) << setfill('0') << hex << (int)regData[address] 
         << " Got=0x" << setw(8) << setfill('0') << hex << (int)rdValue << "\n";

      // Compare 
      if ( regData[address] != rdValue ) {
         error.str("");
         error << "KpixAsic::regVerify -> Verify Error Kpix Address=0x" << setw(4) 
         << setfill('0') << hex << kpixAddress << ", Read '" << regGetName(address)
         << "' (0x" << hex << setw(2) << setfill('0') << (int)address << ") Exp=0x" 
         << setw(8) << setfill('0') << hex << (int)regData[address] 
         << " Got=0x" << setw(8) << setfill('0') << hex << (int)rdValue;
         throw(error.str());
      }
   }
#endif
}


// Private method to write timing settings for versions 0-7
void KpixAsic::setTimingV7 ( unsigned int clkPeriod,  unsigned int resetOn,
                             unsigned int resetOff,   unsigned int leakNullOff,
                             unsigned int offNullOff, unsigned int threshOff,
                             unsigned int trigInhOff, unsigned int pwrUpOn,
                             unsigned int deselDly,   unsigned int bunchClkDly,
                             unsigned int digDelay,   bool enChecking,
                             bool writeEn,            bool trigInhRaw ) {

   // Additional times that are auto generated
   unsigned int pwrUpAcqOff;
   unsigned int pwrUpDigOff;
   unsigned int leakNullOn;
   unsigned int trigInhOn;
   unsigned int offNullOn;
   unsigned int threshOn;
   unsigned int tempLow[7];
   unsigned int tempHigh[7];
   unsigned int temp[8];
   int i;
   stringstream error;

   // Store clock period
   this->clkPeriod &= 0xFFFF0000;
   this->clkPeriod |= (clkPeriod & 0xFFFF);

   // Trigger inhibit mode
   if ( ! trigInhRaw ) trigInhOff = bunchClkDly + (clkPeriod * 8 * trigInhOff) + clkPeriod;

   // Timing ordering checks
   if ( enChecking && ! (

      // Leakage null comes first    - Then reset assertion
      (leakNullOff < resetOn)        && (resetOn < pwrUpOn)

      // Then power up               - Then deselect 
      && (pwrUpOn < deselDly)        && (deselDly < offNullOff)
      
      // Then offset null            - Then threshold offset
      && (offNullOff < threshOff)    && (threshOff < resetOff)

      // Then reset off              // Then bunch clock delay, trigger inhibit
      && (resetOff < bunchClkDly)    && (bunchClkDly < trigInhOff) ) ) {

      // Declare error
      throw string("KpixAsic::setTiming -> Timing sequence error detected!");
   }

   // Generate auto time values
   pwrUpAcqOff = bunchClkDly + 2891 * 8 * clkPeriod;
   leakNullOn  = pwrUpAcqOff;
   trigInhOn   = pwrUpAcqOff;
   pwrUpDigOff = bunchClkDly + 2890 * 8 * clkPeriod + digDelay + 32841 * clkPeriod;
   offNullOn   = pwrUpDigOff;
   threshOn    = pwrUpDigOff;

   // Copy data into an array
   tempLow[0]  = resetOn;     tempHigh[0] = resetOff;
   tempLow[1]  = leakNullOff; tempHigh[1] = leakNullOn;
   tempLow[2]  = offNullOff;  tempHigh[2] = offNullOn;
   tempLow[3]  = threshOff;   tempHigh[3] = threshOn;
   tempLow[4]  = trigInhOff;  tempHigh[4] = trigInhOn;
   tempLow[5]  = pwrUpOn;     tempHigh[5] = pwrUpAcqOff;
   tempLow[6]  = pwrUpOn;     tempHigh[6] = pwrUpDigOff;

   // Convert values and verify values are ok
   for (i=0; i < 7; i++) {

      // Check divide
      if ((tempLow[i] % clkPeriod) != 0 || (tempHigh[i] % clkPeriod) != 0)  {
         cout << "KpixAsic::setTiming -> ";
         cout << "Warning: Timing register ";
         cout << dec << i << " value not divisiable by clkPeriod. ";
         cout << "Values=" << dec << tempLow[i] << "/" << dec << tempHigh[i];
         cout << " clkPeriod=" << dec << clkPeriod << ".\n";
      }

      // Check range
      if ((tempLow[i] / clkPeriod) > 0xFFFF || (tempHigh[i] / clkPeriod) > 0xFFFF) {
         error << "KpixAsic::setTiming -> ";
         error << "Timing register " << dec << i << " value too large. ";
         error << "Values=" << dec << tempLow[i] << "/" << dec << tempHigh[i] << ".";
         throw(error.str()); 
      }

      // Convert to register value
      temp[i]  = (tempLow[i]  / clkPeriod) & 0x0000FFFF;
      temp[i] |= ((tempHigh[i] / clkPeriod) << 16) & 0xFFFF0000;
   }

   // Check clock period divide for register 7
   if ((deselDly%clkPeriod)!=0 || (bunchClkDly%clkPeriod)!=0 || (digDelay%clkPeriod)!=0 ) {
      cout << "KpixAsic::setTiming -> ";
      cout << "Warning: Timing register 7 value not divisiable by clkPeriod. ";
      cout << "Values=" << dec << deselDly << "/" << dec << bunchClkDly << "/";
      cout << dec << digDelay << " clkPeriod=" << dec << clkPeriod << ".\n";
   }

   // Convert register values
   if ((deselDly/clkPeriod)>0xFF || (bunchClkDly/clkPeriod)>0xFFFF || 
       (digDelay/clkPeriod>0xFF)) {
      error << "KpixAsic::setTiming -> ";
      error << "Timing register 7 value too large. " << "Values="; 
      error << dec << deselDly << "/" << dec << bunchClkDly << "/" << dec << digDelay << ".";
      throw(error.str()); 
   }

   // Convert to register value
   temp[7]  = (deselDly     / clkPeriod) & 0x000000FF;
   temp[7] |= ((bunchClkDly / clkPeriod) <<  8) & 0x00FFFF00;
   temp[7] |= ((digDelay    / clkPeriod) << 24) & 0xFF000000;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setTiming -> writing timing: \n";
      cout << "                       clkPeriod    = " << dec << clkPeriod    << "\n";
      cout << "                       resetOn      = " << dec << resetOn      << "\n";
      cout << "                       resetOff     = " << dec << resetOff     << "\n";
      cout << "                       leakNullOff  = " << dec << leakNullOff  << "\n";
      cout << "                       leakNullOn   = " << dec << leakNullOn   << " (auto)\n";
      cout << "                       offNullOff   = " << dec << offNullOff   << "\n";
      cout << "                       offNullOn    = " << dec << offNullOn    << " (auto)\n";
      cout << "                       threshOff    = " << dec << threshOff    << "\n";
      cout << "                       threshOn     = " << dec << threshOn     << " (auto)\n";
      cout << "                       trigInhOff   = " << dec << trigInhOff   << "\n";
      cout << "                       trigInhOn    = " << dec << trigInhOn    << " (auto)\n";
      cout << "                       pwrUpOn      = " << dec << pwrUpOn      << "\n";
      cout << "                       pwrUpAcqOff  = " << dec << pwrUpAcqOff  << " (auto)\n";
      cout << "                       pwrUpDigOff  = " << dec << pwrUpDigOff  << " (auto)\n";
      cout << "                       deselDly     = " << dec << deselDly     << "\n";
      cout << "                       bunchClkDly  = " << dec << bunchClkDly  << "\n";
      cout << "                       digDelay     = " << dec << digDelay     << "\n";
   }

   // Write registers
   for (i=0; i<8; i++) regSetValue(0x08+i,temp[i],writeEn);
}


// Private method to read timing settings for versions 0-7
void KpixAsic::getTimingV7 ( unsigned int *clkPeriod,  unsigned int *resetOn,
                             unsigned int *resetOff,   unsigned int *leakNullOff,
                             unsigned int *offNullOff, unsigned int *threshOff,
                             unsigned int *trigInhOff, unsigned int *pwrUpOn,
                             unsigned int *deselDly,   unsigned int *bunchClkDly,
                             unsigned int *digDelay,   bool readEn,
                             bool trigInhRaw ) {

   // Local variables
   unsigned int pwrUpAcqOff;
   unsigned int pwrUpDigOff;
   unsigned int leakNullOn;
   unsigned int trigInhOn;
   unsigned int offNullOn;
   unsigned int threshOn;
   unsigned int tempLow[7];
   unsigned int tempHigh[7];
   unsigned int temp[8];
   int i;
   stringstream error;

   // Store clock period
   *clkPeriod = (this->clkPeriod & 0xFFFF);

   // Read register value
   for (i=0; i<8; i++) temp[i] = regGetValue(0x08+i,readEn);

   // Convert values for registers 0-6
   for (i=0; i<8; i++) {
      tempLow[i]  = temp[i] & 0x0000FFFF;
      tempHigh[i] = (temp[i] >> 16) & 0x0000FFFF;
   }

   // Extract values
   *resetOn     = tempLow[0]  * *clkPeriod; *resetOff   = tempHigh[0] * *clkPeriod;
   *leakNullOff = tempLow[1]  * *clkPeriod; leakNullOn  = tempHigh[1] * *clkPeriod;
   *offNullOff  = tempLow[2]  * *clkPeriod; offNullOn   = tempHigh[2] * *clkPeriod;
   *threshOff   = tempLow[3]  * *clkPeriod; threshOn    = tempHigh[3] * *clkPeriod;
   *trigInhOff  = tempLow[4]  * *clkPeriod; trigInhOn   = tempHigh[4] * *clkPeriod;
   *pwrUpOn     = tempLow[5]  * *clkPeriod; pwrUpAcqOff = tempHigh[5] * *clkPeriod;
   pwrUpDigOff  = tempHigh[6] * *clkPeriod;

   // Extract state timing signals
   *deselDly    = (temp[7] & 0xFF) * *clkPeriod;
   *bunchClkDly = ((temp[7] >> 8) & 0xFFFF) * *clkPeriod;
   *digDelay    = ((temp[7] >> 24) & 0xFF) * *clkPeriod;

   // Convert trigger inhibit
   if ( ! trigInhRaw ) *trigInhOff = ((*trigInhOff - *bunchClkDly - *clkPeriod) / *clkPeriod) / 8;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getTiming -> read timing: \n";
      cout << "                       clkPeriod    = " << dec << *clkPeriod    << "\n";
      cout << "                       resetOn      = " << dec << *resetOn      << "\n";
      cout << "                       resetOff     = " << dec << *resetOff     << "\n";
      cout << "                       leakNullOff  = " << dec << *leakNullOff  << "\n";
      cout << "                       leakNullOn   = " << dec << leakNullOn    << " (auto)\n";
      cout << "                       offNullOff   = " << dec << *offNullOff   << "\n";
      cout << "                       offNullOn    = " << dec << offNullOn     << " (auto)\n";
      cout << "                       threshOff    = " << dec << *threshOff    << "\n";
      cout << "                       threshOn     = " << dec << threshOn      << " (auto)\n";
      cout << "                       trigInhOff   = " << dec << *trigInhOff   << "\n";
      cout << "                       trigInhOn    = " << dec << trigInhOn     << " (auto)\n";
      cout << "                       pwrUpOn      = " << dec << *pwrUpOn      << "\n";
      cout << "                       pwrUpAcqOff  = " << dec << pwrUpAcqOff   << " (auto)\n";
      cout << "                       pwrUpDigOff  = " << dec << pwrUpDigOff   << " (auto)\n";
      cout << "                       deselDly     = " << dec << *deselDly     << "\n";
      cout << "                       bunchClkDly  = " << dec << *bunchClkDly  << "\n";
      cout << "                       digDelay     = " << dec << *digDelay     << "\n";
      cout << "                       bunchCount   = 2890                          \n";
   }
}


// Private method to write timing settings for versions 8+
void KpixAsic::setTimingV8 ( unsigned int clkPeriod,  unsigned int resetOn,
                             unsigned int resetOff,   unsigned int leakNullOff,
                             unsigned int offNullOff, unsigned int threshOff,
                             unsigned int trigInhOff, unsigned int pwrUpOn,
                             unsigned int deselDly,   unsigned int bunchClkDly,
                             unsigned int digDelay,   unsigned int bunchCount,
                             bool enChecking,         bool writeEn,
                             bool trigInhRaw ) {

   unsigned int temp[6];
   int i;
   stringstream error;

   // Overwrite some values for KPIX8
   if ( kpixVersion == 8 ) {
      deselDly    = 0x8A;
      bunchClkDly = 0xC000;
      digDelay    = 0xFF;
      resetOn     = 0x000E;
      resetOff    = 0x0960;
      leakNullOff = 0x0004;
      offNullOff  = 0x07DA;
      enChecking  = false;
      cout << "KpixAsic::setTiming -> Warning! Overwriting passed timing values for KPIX 8. Disabling checks.\n";
      cout << "                       resetOn      = " << dec << resetOn      << "\n";
      cout << "                       resetOff     = " << dec << resetOff     << "\n";
      cout << "                       leakNullOff  = " << dec << leakNullOff  << "\n";
      cout << "                       offNullOff   = " << dec << offNullOff   << "\n";
      cout << "                       deselDly     = " << dec << deselDly     << "\n";
      cout << "                       bunchClkDly  = " << dec << bunchClkDly  << "\n";
      cout << "                       digDelay     = " << dec << digDelay     << "\n";
   }

   // Store clock period
   this->clkPeriod &= 0xFFFF0000;
   this->clkPeriod |= (clkPeriod & 0xFFFF);

   // Trigger inhibit mode
   if ( ! trigInhRaw ) trigInhOff = bunchClkDly + (clkPeriod * 8 * trigInhOff) + clkPeriod;

/*
   // Timing ordering checks
   if ( enChecking && ! (

      // Leakage null comes first    - Then reset assertion
      (leakNullOff < resetOn)        && (resetOn < pwrUpOn)

      // Then power up               - Then deselect 
      && (pwrUpOn < deselDly)        && (deselDly < offNullOff)
      
      // Then offset null            - Then threshold offset
      && (offNullOff < threshOff)    && (threshOff < resetOff)

      // Then reset off              - Then bunch clock delay, trigger inhibit
      && (resetOff < bunchClkDly)    && (bunchClkDly < trigInhOff) ) ) {

      // Declare error
      throw string("KpixAsic::setTiming -> Timing sequence error detected!");
   }

*/

   // Check clock period divide
   if ( ((resetOn     % clkPeriod) != 0 ) || ((resetOn     / clkPeriod) > 0xFFFF ) ||
        ((resetOff    % clkPeriod) != 0 ) || ((resetOff    / clkPeriod) > 0xFFFF ) ||
        ((leakNullOff % clkPeriod) != 0 ) || ((leakNullOff / clkPeriod) > 0xFFFF ) ||
        ((offNullOff  % clkPeriod) != 0 ) || ((offNullOff  / clkPeriod) > 0xFFFF ) ||
        ((threshOff   % clkPeriod) != 0 ) || ((threshOff   / clkPeriod) > 0xFFFF ) ||
        ((trigInhOff  % clkPeriod) != 0 ) || 
        ((pwrUpOn     % clkPeriod) != 0 ) || ((pwrUpOn     / clkPeriod) > 0xFFFF ) ||
        ((deselDly    % clkPeriod) != 0 ) || ((deselDly    / clkPeriod) > 0xFF   ) ||
        ((bunchClkDly % clkPeriod) != 0 ) || ((bunchClkDly / clkPeriod) > 0xFFFF ) ||
        ((digDelay    % clkPeriod) != 0 ) || ((digDelay    / clkPeriod) > 0xFF   ) ||
        (bunchCount   > 8191) ) 
      cout << "KpixAsic::setTiming -> Warning: Bad Timing Value" << endl;

   // Copy data into an array
   temp[0]  = (resetOn      / clkPeriod) & 0xFFFF; 
   temp[0] |= ((resetOff    / clkPeriod) << 16) & 0xFFFF0000;
   temp[1]  = (offNullOff   / clkPeriod) & 0xFFFF; 
   temp[1] |= ((leakNullOff / clkPeriod) << 16) & 0xFFFF0000;
   temp[2]  = (pwrUpOn      / clkPeriod) & 0xFFFF; 
   temp[2] |= ((threshOff   / clkPeriod) << 16) & 0xFFFF0000;
   temp[3]  = (trigInhOff   / clkPeriod);
   temp[4]  = bunchCount & 0xFFFF;
   temp[4] |= ((pwrUpOn     / clkPeriod) << 16) & 0xFFFF0000;
   temp[5]  = (deselDly     / clkPeriod) & 0x000000FF;
   temp[5] |= ((bunchClkDly / clkPeriod) <<  8) & 0x00FFFF00;
   temp[5] |= ((digDelay    / clkPeriod) << 24) & 0xFF000000;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setTiming -> writing timing: \n";
      cout << "                       clkPeriod    = " << dec << clkPeriod    << "\n";
      cout << "                       resetOn      = " << dec << resetOn      << "\n";
      cout << "                       resetOff     = " << dec << resetOff     << "\n";
      cout << "                       leakNullOff  = " << dec << leakNullOff  << "\n";
      cout << "                       offNullOff   = " << dec << offNullOff   << "\n";
      cout << "                       threshOff    = " << dec << threshOff    << "\n";
      cout << "                       trigInhOff   = " << dec << trigInhOff   << "\n";
      cout << "                       pwrUpOn      = " << dec << pwrUpOn      << "\n";
      cout << "                       deselDly     = " << dec << deselDly     << "\n";
      cout << "                       bunchClkDly  = " << dec << bunchClkDly  << "\n";
      cout << "                       digDelay     = " << dec << digDelay     << "\n";
      cout << "                       bunchCount   = " << dec << bunchCount   << "\n";
   }

   // Write registers
   for (i=0; i<6; i++) regSetValue(0x08+i,temp[i],writeEn);
}


// Private method to read timing settings for versions 0-8
void KpixAsic::getTimingV8 ( unsigned int *clkPeriod,  unsigned int *resetOn,
                             unsigned int *resetOff,   unsigned int *leakNullOff,
                             unsigned int *offNullOff, unsigned int *threshOff,
                             unsigned int *trigInhOff, unsigned int *pwrUpOn,
                             unsigned int *deselDly,   unsigned int *bunchClkDly,
                             unsigned int *digDelay,   unsigned int *bunchCount,
                             bool readEn,              bool trigInhRaw ) {

   // Local variables
   unsigned int temp[6];
   int i;

   if ( readEn && kpixVersion == 8 ) {
      cout << "KpixAsic::getTiming -> Warning! Readback not allowed in KPIX 8.\n";
      readEn = false;
   }

   // Store clock period
   *clkPeriod = (this->clkPeriod & 0xFFFF);

   // Read register value
   for (i=0; i<6; i++) temp[i] = regGetValue(0x08+i,readEn);

   // Extract values
   *resetOn     = ((temp[0]      ) & 0xFFFF) * *clkPeriod; 
   *resetOff    = ((temp[0] >> 16) & 0xFFFF) * *clkPeriod;
   *offNullOff  = ((temp[1]      ) & 0xFFFF) * *clkPeriod; 
   *leakNullOff = ((temp[1] >> 16) & 0xFFFF) * *clkPeriod;
   *pwrUpOn     = ((temp[2]      ) & 0xFFFF) * *clkPeriod; 
   *threshOff   = ((temp[2] >> 16) & 0xFFFF) * *clkPeriod;
   *trigInhOff  = ( temp[3]                ) * *clkPeriod; 
   *bunchCount  = ( temp[4]        & 0xFFFF);
   *deselDly    = ((temp[5]      ) & 0x00FF) * *clkPeriod;
   *bunchClkDly = ((temp[5] >>  8) & 0xFFFF) * *clkPeriod;
   *digDelay    = ((temp[5] >> 24) & 0x00FF) * *clkPeriod;

   // Convert trigger inhibit
   if ( ! trigInhRaw ) *trigInhOff = ((*trigInhOff - *bunchClkDly - *clkPeriod) / *clkPeriod) / 8;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getTiming -> read timing: \n";
      cout << "                       clkPeriod    = " << dec << *clkPeriod    << "\n";
      cout << "                       resetOn      = " << dec << *resetOn      << "\n";
      cout << "                       resetOff     = " << dec << *resetOff     << "\n";
      cout << "                       leakNullOff  = " << dec << *leakNullOff  << "\n";
      cout << "                       offNullOff   = " << dec << *offNullOff   << "\n";
      cout << "                       threshOff    = " << dec << *threshOff    << "\n";
      cout << "                       trigInhOff   = " << dec << *trigInhOff   << "\n";
      cout << "                       pwrUpOn      = " << dec << *pwrUpOn      << "\n";
      cout << "                       deselDly     = " << dec << *deselDly     << "\n";
      cout << "                       bunchClkDly  = " << dec << *bunchClkDly  << "\n";
      cout << "                       digDelay     = " << dec << *digDelay     << "\n";
      cout << "                       bunchCount   = " << dec << *bunchCount   << "\n";
   }
}


// Kpix ASIC Constructor
KpixAsic::KpixAsic ( ) {

   unsigned int  i;
   stringstream tempString;

   // Init version & address
   kpixVersion = 0;
   kpixAddress = 0;
   kpixSerial  = 0;
   clkPeriod   = 50;
   enDebug     = false;

#ifdef ONLINE_EN
   // SID Link Object
   this->sidLink = NULL;
#endif

   // Init register data
   for ( i=0; i < 0x80; i++ ) {
      regData[i]      = 0;
      regWidth[i]     = 0;
      regWriteable[i] = false;
   }
}

#ifdef ONLINE_EN

// Kpix ASIC Constructor
// Pass SID Link Object, KPIX version, 2,3,4,etc, KPIX Address & Serial number
KpixAsic::KpixAsic ( SidLink *sidLink, unsigned short version, unsigned short address, 
                     unsigned short serial, bool dummy ) {

   unsigned int  i;
   stringstream tempString;

   // Ensure version is valid
   if ( version > maxVersion() ) throw(string("KpixAsic::KpixAsic -> Unsupported Version"));

   // Copy version & address
   kpixVersion = version;
   kpixAddress = address;
   kpixSerial  = serial;
   clkPeriod   = 50;
   enDebug     = false;

   // SID Link Object
   this->sidLink = sidLink;

   // Init register data
   for ( i=0; i < 0x80; i++ ) {
      regData[i]      = 0;
      regWidth[i]     = 0;
      regWriteable[i] = false;
   }

   // Setup registers
   regWriteable[0x00] = false; // Status Register
   regWidth[0x00]     = 32;
   regWriteable[0x01] = true; // Config Register
   regWidth[0x01]     = 32;
   regWriteable[0x08] = true; // Reset Timer REg
   regWidth[0x08]     = 32;
   regWriteable[0x09] = true; // LeakageNull Timer Reg
   regWidth[0x09]     = 32;
   regWriteable[0x0A] = true; // OffsetNull Timer Reg
   regWidth[0x0A]     = 32;
   regWriteable[0x0B] = true; // ThreshOff Timer Reg
   regWidth[0x0B]     = 32;
   regWriteable[0x0C] = true; // TrigInh Timer Reg
   regWidth[0x0C]     = 32;
   regWriteable[0x0D] = true; // PwrUpAcq Timer Reg
   regWidth[0x0D]     = 32;

   // Determine version
   if ( version < 8 ) {
      regWriteable[0x0E] = true; // PwrUpDig Timer Reg
      regWidth[0x0E]     = 32;
      regWriteable[0x0F] = true; // State Timer Reg
      regWidth[0x0F]     = 32;
   }

   regWriteable[0x10] = true; // Cal Delay 0 Reg
   regWidth[0x10]     = 32;
   regWriteable[0x11] = true; // Cal Delay 1 Reg
   regWidth[0x11]     = 32;

   // Dummy KPIX only has digital core registers, no analog registers
   if ( ! dummy ) {

      regWriteable[0x20] = true; // Event A Reset Dac Reg
      regWidth[0x20]     = 8;
      regWriteable[0x21] = true; // Event B Reset Dac Reg
      regWidth[0x21]     = 8;
      regWriteable[0x22] = true; // Ramp Thresh Dac Reg
      regWidth[0x22]     = 8;
      regWriteable[0x23] = true; // Range Threshold Dac Reg
      regWidth[0x23]     = 8;
      regWriteable[0x24] = true; // Calibration Dac Reg
      regWidth[0x24]     = 8;
      regWriteable[0x25] = true; // Event Thold Ref Dac Reg
      regWidth[0x25]     = 8;
      regWriteable[0x26] = true; // Shaper Bias Dac Reg
      regWidth[0x26]     = 8;
      regWriteable[0x27] = true; // Default Analog Dac Reg
      regWidth[0x27]     = 8;
      regWriteable[0x28] = true; // Event A Trig Dac Reg
      regWidth[0x28]     = 8;
      regWriteable[0x29] = true; // Event B Trig Dac Reg
      regWidth[0x29]     = 8;

      // Control register width depends on KPIX version
      regWriteable[0x30] = true;
      regWidth[0x30]     = ((version<3)?8:((version<8)?16:32));

      // Calibration Mask Register
      for (i=0; i< (getChCount()/32); i++) {
         regWriteable[0x40+i] = true;
         regWidth[0x40+i]     = 32;
      }

      // Range Select Register
      for (i=0; i< (getChCount()/32); i++) {
         regWriteable[0x60+i] = true;
         regWidth[0x60+i]     = 32;
      }
   }
}


// Set SID Link
void KpixAsic::setSidLink ( SidLink *sidLink ) {
   this->sidLink = sidLink;
}

#endif


// Max Kpix Version
unsigned short KpixAsic::maxVersion() { return(11); }


// Send reset command to KPIX
// Pass optional broadcast flag, default=true
void KpixAsic::cmdReset ( bool bcast ) { 
   sendCommand(0x01, bcast );
   usleep(100);
}


// Send acquire command to KPIX
// Pass optional broadcast flag, default=true
void KpixAsic::cmdAcquire ( bool bcast ) { sendCommand(0x02,bcast); }


// Send calibrate command to KPIX
// Pass optional broadcast flag, default=true
void KpixAsic::cmdCalibrate ( bool bcast ) { sendCommand(0x03,bcast); }


// Method to set register value
// Pass the following values
// address = Register address
// value   = 32-Bit register value
// writeEn = Flag to perform actual write
// Function will auto adjust for register width
void KpixAsic::regSetValue ( unsigned char address, unsigned int value, bool writeEn, bool verifyEn ) {

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regSetValue -> Address out of range");

   // Don't set value if width is zero or register is read only
   if ( regWriteable[address] && regWidth[address] != 0 ) {

      // Set according to register width
      switch (regWidth[address]) {
         case 32: regData[address] = value; break;
         case 16:
            regData[address]  = value & 0x0000FFFF;
            regData[address] += (value << 16) & 0xFFFF0000;
            break;
         case 8:
            regData[address]  =  value        & 0x000000FF;
            regData[address] += (value <<  8) & 0x0000FF00;
            regData[address] += (value << 16) & 0x00FF0000;
            regData[address] += (value << 24) & 0xFF000000;
            break;
         default: regData[address] = 0; break;
      }

      // Write register if write flag is set
      if ( writeEn ) {
         regWrite ( address );
         if ( verifyEn && (clkPeriod & 0x80000000) == 0) {
            regVerify(address);
            regVerify(address);
         }
      }
   }
}


// Method to get register value
// Pass the following values
// address = Register address
// read    = Flag to perform actual write
// Function will auto adjust for register width
unsigned int KpixAsic::regGetValue ( unsigned char address, bool readEn ) {

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regGetValue -> Address out of range");

   // Read if read enable flag is set
   if ( readEn ) regRead ( address );

   // Return according to register width
   switch (regWidth[address]) {
      case 32: return(regData[address]); break;
      case 16: return(regData[address] & 0x0000FFFF); break;
      case  8: return(regData[address] & 0x000000FF); break;
      default: return(0); break;
   }
}


// Method to set register bit
// Pass the following values
// address = Register address
// bit     = Bit to set
// value   = Value to set, true or false
// writeEn = Flag to perform actual write
// Function will auto adjust for register width
void KpixAsic::regSetBit ( unsigned char address, unsigned char bit, bool value, bool writeEn, bool verifyEn){

   // Get current value from shadow register, don't read from device
   unsigned int temp = regGetValue(address,false);

   // Setting bit
   if ( value ) temp |= (1 << bit);

   // Clearing bit
   else temp &= ((1 << bit) ^ 0xFFFFFFFF);

   // Set new value
   regSetValue ( address, temp, writeEn, verifyEn );
}


// Method to get register bit
// Pass the following values
// address = Register address
// bit     = Bit to get
// read    = Flag to perform actual write
// Function will auto adjust for register width
bool KpixAsic::regGetBit ( unsigned char address, unsigned char bit, bool readEn ) {

   // Get value
   unsigned int temp = regGetValue(address,readEn);
   return((temp & (1 << bit)) != 0);
}


// Method to return register width
// Pass the register address
unsigned char KpixAsic::regGetWidth ( unsigned char address ) {

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regGetWidth -> Address out of range");
   return(regWidth[address]);
}


// Method to return register name
// Pass the register address
string KpixAsic::regGetName ( unsigned char address ) {

   string temp;
   stringstream tempString;

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regGetName -> Address out of range");

   // Set default value
   temp = "Unused";

   // Return register name
   if ( address == 0x00 ) temp = "Status Reg";
   if ( address == 0x01 ) temp = "Config Reg";
   if ( address == 0x08 ) temp = "Reset Timer Reg";
   if ( address == 0x09 ) temp = "LeakageNull Timer Reg";
   if ( address == 0x0A ) temp = "OffsetNull Timer Reg";
   if ( address == 0x0B ) temp = "ThreshOff Timer Reg";
   if ( address == 0x0C ) temp = "TrigInh Timer Reg";
   if ( address == 0x0D ) temp = "PwrUpAcq Timer Reg";
   if ( address == 0x0E ) temp = "PwrUpDig Timer Reg";
   if ( address == 0x0F ) temp = "State Timer Reg";
   if ( address == 0x10 ) temp = "Cal Delay 0 Reg";
   if ( address == 0x11 ) temp = "Cal Delay 1 Reg";
   if ( address == 0x20 ) temp = "Event A Reset Dac Reg";
   if ( address == 0x21 ) temp = "Event B Reset Dac Reg";
   if ( address == 0x22 ) temp = "Ramp Thresh Dac Reg";
   if ( address == 0x23 ) temp = "Range Threshold Dac Reg";
   if ( address == 0x24 ) temp = "Calibration Dac Reg";
   if ( address == 0x25 ) temp = "Event Thold Ref Dac Reg";
   if ( address == 0x26 ) temp = "Shaper Bias Dac Reg";
   if ( address == 0x27 ) temp = "Default Analog Dac Reg";
   if ( address == 0x28 ) temp = "Event A Trig Dac Reg";
   if ( address == 0x29 ) temp = "Event B Trig Dac Reg";
   if ( address == 0x30 ) temp = "Control Reg";

   // Calibration Mask Registers
   if ( address >= 0x40 && address <= 0x5F ) {
      tempString.str("");
      tempString << "Calibration Mask Reg 0x" << setw(2) << setfill('0') << hex << (address-0x40);
      temp = tempString.str();
   }

   // Range Select Registers
   if ( address >= 0x60 && address <= 0x7F ) {
      tempString.str("");
      tempString << "Range Select Reg 0x" << setw(2) << setfill('0') << hex << (address-0x60);
      temp = tempString.str();
   }

   // Return value
   return(temp);
}


// Method to return register writable flag
// Pass the register address
bool KpixAsic::regGetWriteable ( unsigned char address ) {

   // Check for valid address
   if ( address >= 0x80 ) throw string("KpixAsic::regGetWriteable -> Address out of range");
   return(regWriteable[address]);
}


// Method to get KPIX Status
// Pass location pointers in which to store the following status flags:
// cmdPerr  - Command parity error flag
// dataPerr - Data parity error flag
void KpixAsic::getStatus ( bool *cmdPerr, bool *dataPerr, bool *tempEn, unsigned char *tempValue, bool readEn ) {

   // Get values, read once only
   *cmdPerr   = regGetBit(0x00,0,readEn);
   *dataPerr  = regGetBit(0x00,1,false);
   *tempEn    = regGetBit(0x00,2,false);
   *tempValue = (regGetValue(0x00,false) >> 24) & 0xFF;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getStatus -> read status:";
      cout << " CmdPerr  = " << *cmdPerr;
      cout << ", DataPerr = " << *dataPerr;
      cout << ", TempEn = " << *tempEn;
      cout << ", TempValue = " << dec << (int)(*tempValue) << "\n";
   }
}

// Method to set testData mode in Config Register
// Pass testData flag
// Set writeEn to false to disable real write to KPIX
// Currently a hold time of 1 is the longest but this needs to
// be verified through testing. 
void KpixAsic::setCfgTestData ( bool testData, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixAsic::setCfgTestData -> Set TestData=" << testData;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   regSetBit(0x01,0,testData,writeEn);
}


// Method to get status of testData mode in Config Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCfgTestData (  bool readEn ) {
   bool ret = regGetBit(0x01,0,readEn); 
   if ( enDebug ) {
      cout << "KpixAsic::getCfgTestData -> Get TestData=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set auto readout disable flag in Config Register
// Pass autoReadDis flag
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCfgAutoReadDis ( bool autoReadDis, bool writeEn ) {
   if ( kpixVersion >= 8 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCfgAutoReadDis -> Set AutoReadDis=" << autoReadDis;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x01,2,autoReadDis,writeEn);
   }
}


// Method to get status of auto readout disable flag in Config Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCfgAutoReadDis ( bool readEn ) {
   if ( kpixVersion >= 8 ) {
      bool ret = regGetBit(0x01,2,readEn); 
      if ( enDebug ) {
         cout << "KpixAsic::getCfgAutoReadDis -> Get AutoReadDis=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(0);
}


// Method to set force temperature on flag in Config Register
// Pass forceTemp flag
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCfgForceTemp ( bool forceTemp, bool writeEn ) {
   if ( kpixVersion >= 8 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCfgForceTemp -> Set ForceTemp=" << forceTemp;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x01,3,forceTemp,writeEn);
   }
}


// Method to get status of force temperature on flag in Config Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCfgForceTemp ( bool readEn ) {
   if ( kpixVersion >= 8 ) {
      bool ret = regGetBit(0x01,3,readEn); 
      if ( enDebug ) {
         cout << "KpixAsic::getCfgForceTemp -> Get ForceTemp=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(0);
}


// Method to set disable temperature flag in Config Register
// Pass disableTemp flag
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCfgDisableTemp ( bool disableTemp, bool writeEn ) {
   if ( kpixVersion >= 8 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCfgDisableTemp -> Set DisableTemp=" << disableTemp;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x01,4,disableTemp,writeEn);
   }
}


// Method to get status of disable temperature flag in Config Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCfgDisableTemp ( bool readEn ) {
   if ( kpixVersion >= 8 ) {
      bool ret = regGetBit(0x01,4,readEn); 
      if ( enDebug ) {
         cout << "KpixAsic::getCfgDisableTemp -> Get DisableTemp=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(0);
}


// Method to set auto status message flag in Config Register
// Pass autoStatus flag
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCfgAutoStatus ( bool autoStatus, bool writeEn ) {
   if ( kpixVersion >= 8 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCfgAutoStatus -> Set AutoStatus=" << autoStatus;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x01,5,autoStatus,writeEn);
   }
}


// Method to set auto status message flag in Config Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCfgAutoStatus ( bool readEn ) {
   if ( kpixVersion >= 8 ) {
      bool ret = regGetBit(0x01,5,readEn); 
      if ( enDebug ) {
         cout << "KpixAsic::getCfgAutoStatus -> Get AutoStatus=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(0);
}


// Method to set hold time value in Control Register
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCntrlHoldTime ( KpixHoldTime holdTime, bool writeEn ) {

   unsigned short bit;
   unsigned short shift;

   if ( enDebug ) {
      cout << "KpixAsic::setCntrlHoldTime -> Set HoldTime=" << holdTime;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Older Kpix Versions
   if ( kpixVersion < 8 ) {

      // Determine shift
      switch ( holdTime ) {
         case HoldTime_64x: shift = 0; break;
         case HoldTime_40x: shift = 1; break;
         case HoldTime_32x: shift = 2; break;
         default: throw string("KpixAsic::setCntrlHoldTime -> Invalid Value"); break;
      }

      // Start bit depends on version
      if ( kpixVersion >= 3 ) bit = 8; else bit = 0;

      // Clear bits by default, don't write
      regSetBit(0x30,bit,false,false);
      regSetBit(0x30,bit+1,false,false);
      regSetBit(0x30,bit+2,false,false);

      // Set proper bit
      regSetBit(0x030,bit+shift,true,writeEn);
   }

   // New Kpix Versions
   else {

      // Set Bits
      regSetBit(0x30,8,(((int)holdTime&0x1)!=0),false);
      regSetBit(0x30,9,(((int)holdTime&0x2)!=0),false);
      regSetBit(0x30,10,(((int)holdTime&0x4)!=0),writeEn);
   }
}


// Method to get hold time value from Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
KpixAsic::KpixHoldTime KpixAsic::getCntrlHoldTime (  bool readEn ) {

   KpixHoldTime   ret;
   unsigned int   val;
   unsigned short bit;

   // Older Kpix Versions
   if ( kpixVersion < 8 ) {

      // Start bit depends on version
      if ( kpixVersion >= 3 ) bit = 8; else bit = 0;

      // Set default return
      ret = HoldTime_64x;

      // Determine return, read only once
      if ( regGetBit(0x30,bit,readEn)  ) ret = HoldTime_64x;
      if ( regGetBit(0x30,bit+1,false) ) ret = HoldTime_40x;
      if ( regGetBit(0x30,bit+2,false) ) ret = HoldTime_32x;
   }

   // Newer Version
   else {
      val = 0;
      if ( regGetBit(0x30,8,readEn)) val += 0x1;
      if ( regGetBit(0x30,9,false))  val += 0x2;
      if ( regGetBit(0x30,10,false)) val += 0x4;
      ret = KpixHoldTime(val);
   }

   if ( enDebug ) {
      cout << "KpixAsic::getCntrlHoldTime -> Get HoldTime=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set calibration pulse 0 high range mode in Control Register
// Pass calibHigh flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlCalibHigh ( bool calibHigh, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixAsic::setCntrlCalibHigh -> Set CalibHigh=" << calibHigh;
      cout << ", WriteEn=" << writeEn << ".\n";
   }

   // Bit depends on version
   regSetBit(0x30,((kpixVersion>=3)?11:3),calibHigh,writeEn);
}


// Method to get status of calibration pulse 0 high range mode in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic:: getCntrlCalibHigh (  bool readEn ) {

   // Bit depends on version
   bool ret = regGetBit(0x30,((kpixVersion>=3)?11:3),readEn);
   if ( enDebug ) {
      cout << "KpixAsic::getCntrlCalibHigh -> Get CalibHigh=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to select internal calibration dac in Control Register
// Pass calDacInt flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlCalDacInt ( bool calDacInt, bool writeEn ) {
   if ( kpixVersion < 8 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlCalDacInt -> Set CalDacInt=" << calDacInt;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      // Bit depends on version
      regSetBit(0x30,((kpixVersion>=3)?12:4),calDacInt,writeEn);
   }
}


// Method to get status of internal calibration dac select in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic:: getCntrlCalDacInt ( bool readEn ) {
   if ( kpixVersion < 8 ) {
      // Bit depends on version
      bool ret = regGetBit(0x30,((kpixVersion>=3)?12:4),readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlCalDacInt -> Get CalDacInt=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(true);
}


// Method to set force log gain mode in Control Register
// Pass forceLowGain flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlForceLowGain ( bool forceLowGain, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixAsic::setCntrlForceLowGain -> Set ForceLowGain=" << forceLowGain;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   // Bit depends on version
   regSetBit(0x30,((kpixVersion>=3)?13:5),forceLowGain,writeEn);
}


// Method to get status of force low gain mode in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic:: getCntrlForceLowGain (  bool readEn ) {
   // Bit depends on version
   bool ret = regGetBit(0x30,((kpixVersion>=3)?13:5),readEn);
   if ( enDebug ) {
      cout << "KpixAsic::getCntrlForceLowGain -> Get ForceLowGain=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set leakage null disable in Control Register
// Pass leakNullDis flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlLeakNullDis ( bool leakNullDis, bool writeEn ) {
   if ( enDebug ) {
      cout << "KpixAsic::setCntrlLeakNullDis -> Set LeakNullDis=" << leakNullDis;
      cout << ", WriteEn=" << writeEn << ".\n";
   }
   // Bit depends on version
   regSetBit(0x30,((kpixVersion>=3)?14:6),leakNullDis,writeEn);
}


// Method to get status of leakage null disable in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic:: getCntrlLeakNullDis (  bool readEn ) {
   // Bit depends on version
   bool ret = regGetBit(0x30,((kpixVersion>=3)?14:6),readEn);
   if ( enDebug ) {
      cout << "KpixAsic::getCntrlLeakNullDis -> Get LeakNullDis=" << ret;
      cout << ", ReadEn=" << readEn << ".\n";
   }
   return(ret);
}


// Method to set positive pixel mode in Control Register
// Pass posPixel flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlPosPixel ( bool posPixel, bool writeEn ) {
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlPosPixel -> Set PosPixel=" << posPixel;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x30,15,posPixel,writeEn);
   }
}


// Method to get status of positive pixel mode in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic:: getCntrlPosPixel (  bool readEn ) {
   bool ret=true;;
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {
      ret = regGetBit(0x30,15,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlPosPixel -> Get PosPixel=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set calibration source in Control Register
// Pass KpixCalTrigSrc enum
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlCalSrc ( KpixAsic::KpixCalTrigSrc calSrc, bool writeEn ) {
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {

      // Disable not allowed below KPIX 10
      if ( kpixVersion < 10 && calSrc == KpixDisable ) calSrc = KpixExternal;

      if ( enDebug ) {
         cout << "KpixAsic::setCntrlCalSrcCore -> Set CalSrc=" << calSrc;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Only write once
      regSetBit(0x30,6,(calSrc==KpixInternal)?1:0,false);
      regSetBit(0x30,4,(calSrc==KpixExternal)?1:0,writeEn);
   }
}


// Method to get status of calibration source in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
KpixAsic::KpixCalTrigSrc KpixAsic::getCntrlCalSrc (  bool readEn ) {
   KpixAsic::KpixCalTrigSrc ret=KpixDisable;
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {
      if ( regGetBit(0x30,6,readEn) ) ret = KpixInternal;
      if ( regGetBit(0x30,4,readEn) ) ret = KpixExternal;
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlCalSrcCore -> Get CalSrcCore=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set force trigger source in Control Register
// Pass KpixCalTrigSrc enum
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlTrigSrc ( KpixCalTrigSrc trigSrc, bool writeEn ) {
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {

      // Disable not allowed below KPIX 10
      if ( kpixVersion < 10 && trigSrc == KpixDisable ) trigSrc = KpixExternal;

      if ( enDebug ) {
         cout << "KpixAsic::setCntrlTrigSrcCore -> Set TrigSrc=" << trigSrc;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Only write once
      regSetBit(0x30,7,(trigSrc==KpixInternal)?1:0,false);
      regSetBit(0x30,5,(trigSrc==KpixExternal)?1:0,writeEn);
   }
}


// Method to get status of force trigger source in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
KpixAsic::KpixCalTrigSrc KpixAsic:: getCntrlTrigSrc (  bool readEn ) {
   KpixAsic::KpixCalTrigSrc ret=KpixDisable;
   // Only exists in later versions
   if ( kpixVersion >= 3 ) {
      if ( regGetBit(0x30,7,readEn) ) ret = KpixInternal;
      if ( regGetBit(0x30,5,readEn) ) ret = KpixExternal;
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlTrigSrcCore -> Get TrigSrcCore=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set enable nearest neighbor triggering in Control Register
// Pass nearNeighbor flag, true = enable, false = disable
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlNearNeighbor ( bool nearNeighbor, bool writeEn ) {
   // Only exists in later versions
   if ( kpixVersion >= 4 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlNearNeighbor -> Set NearNeighbor=" << nearNeighbor;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x30,3,nearNeighbor,writeEn);
   }
}


// Method to get status of nearest neighbor triggering enable in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlNearNeighbor (  bool readEn ) {
   bool ret=false;
   // Only exists in later versions
   if ( kpixVersion >= 4 ) {
      ret = regGetBit(0x30,3,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlNearNeighbor -> Get NearNeighbor=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set charge amplifier double gain in Control Register
// Pass doubleGain flag, true = enable, false = disable
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlDoubleGain ( bool doubleGain, bool writeEn ) {
   // Only exists in later versions
   if ( kpixVersion >= 4 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlDoubleGain -> Set DoubleGain=" << doubleGain;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x30,2,doubleGain,writeEn);
   }
}


// Method to get status of charge amplifier double gain in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlDoubleGain (  bool readEn ) {
   bool ret=false;
   // Only exists in later versions
   if ( kpixVersion >= 4 ) {
      ret = regGetBit(0x30,2,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlDoubleGain -> Get DoubleGain=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set disable periodic reset in Control Register
// Pass disPerRst flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlDisPerRst ( bool disPerRst, bool writeEn ) {

   // Only exists in later versions
   if ( kpixVersion >= 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlDisPerRst -> Set DisPerRst=" << disPerRst;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x30,0,disPerRst,writeEn);
   }
}


// Method to get status of disable periodic reset in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlDisPerRst (  bool readEn ) {

   bool ret=false;

   // Only exists in later versions
   if ( kpixVersion >= 7 ) {
      ret = regGetBit(0x30,0,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlDisPerRst -> Get DisPerRst=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to set enable DC reset in Control Register
// Pass enDcRst flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlEnDcRst ( bool enDcRst, bool writeEn ) {

   // Only exists in later versions
   if ( kpixVersion >= 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlEnDcRst -> Set EnDcRst=" << enDcRst;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      regSetBit(0x30,1,enDcRst,writeEn);
   }
}


// Method to get status of enable DC reset in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlEnDcRst (  bool readEn ) {

   bool ret=false;

   // Only exists in later versions
   if ( kpixVersion >= 7 ) {
      ret = regGetBit(0x30,1,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlEnDcRst -> Get EnDcRst=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to select short integration time
// Pass shortIntEn flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlShortIntEn ( bool shortIntEn, bool writeEn ) {
   if ( kpixVersion > 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlShortIntEn -> Set ShortIntEn = " << shortIntEn;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      // Bit depends on version
      regSetBit(0x30,12,shortIntEn,writeEn);
   }
}


// Method to get status of short integration time enable bit in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlShortIntEn (  bool readEn ) {
   if ( kpixVersion > 7 ) {
      bool ret = regGetBit(0x30,12,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlShortIntEn -> Get ShortIntEn = " << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(false);
}


// Method to disable power cycling
// Pass disPwrCycle flag
// Set writeEn to false to disable real write to KPIX, this flag can be used
// to allow the individual register bits to be set before performing a write
// to the device.
void KpixAsic::setCntrlDisPwrCycle ( bool disPwrCycle, bool writeEn ) {
   if ( kpixVersion > 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlDisPwrCycle -> Set DisPwrCycle =" << disPwrCycle;
         cout << ", WriteEn=" << writeEn << ".\n";
      }
      // Bit depends on version
      regSetBit(0x30,24,disPwrCycle,writeEn);
      usleep(100);
   }
}


// Method to get status of disable power cycle bit in Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
bool KpixAsic::getCntrlDisPwrCycle (  bool readEn ) {
   if ( kpixVersion > 7 ) {
      bool ret = regGetBit(0x30,24,readEn);
      if ( enDebug ) {
         cout << "KpixAsic::getCntrlDisPwrCycle -> Get DisPwrCycle = " << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   } else return(false);
}


// Method to set front end current value in Control Register
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCntrlFeCurr ( KpixFeCurr feCurr, bool writeEn ) {
   if ( kpixVersion > 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlFeCurr -> Set FeCurr=" << feCurr;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Set Bits
      regSetBit(0x30,25,(((int)feCurr&0x4)!=0),false);
      regSetBit(0x30,26,(((int)feCurr&0x2)!=0),false);
      regSetBit(0x30,27,(((int)feCurr&0x1)!=0),writeEn);
   }
}


// Method to get front end current value from Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
KpixAsic::KpixFeCurr KpixAsic::getCntrlFeCurr ( bool readEn ) {
   unsigned short val;
   KpixFeCurr     ret;
   if ( kpixVersion > 7 ) {

      val = 0;
      if ( regGetBit(0x30,25,readEn)) val += 0x4;
      if ( regGetBit(0x30,26,false))  val += 0x2;
      if ( regGetBit(0x30,27,false))  val += 0x1;
      ret = (KpixFeCurr)val;

      if ( enDebug ) {
         cout << "KpixAsic::getCntrlFeCurr -> Get FeCurr=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   }
   else return(FeCurr_121uA);
}


// Method to set shaper diff time value in Control Register
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCntrlDiffTime ( KpixDiffTime diffTime, bool writeEn ) {
   if ( kpixVersion > 7 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlDiffTime -> Set FeCurr=" << diffTime;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Set Bits
      regSetBit(0x30,28,(((int)diffTime&0x1)!=0),false);
      regSetBit(0x30,29,(((int)diffTime&0x2)!=0),writeEn);
   }
}


// Method to get shaper diff time value from Control Register
// Set readEn to false to disable real read from KPIX, this flag allows
// the user to get the currently set status without actually accessing
// the device.
KpixAsic::KpixDiffTime KpixAsic::getCntrlDiffTime ( bool readEn ) {
   unsigned short val;
   KpixDiffTime   ret;

   if ( kpixVersion > 7 ) {
      val = 0;
      if ( regGetBit(0x30,28,readEn)) val += 0x1;
      if ( regGetBit(0x30,29,false))  val += 0x2;
      ret = (KpixDiffTime)val;

      if ( enDebug ) {
         cout << "KpixAsic::getCntrlDiffTime -> Get DiffTime=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   }
   else return(FeDiffNormal);
}


// Method to set global trigger disable bit.
void KpixAsic::setCntrlTrigDisable ( bool trigDisable, bool writeEn ) {
   if ( kpixVersion >= 10 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlTrigDisable -> Set trigDisable=" << trigDisable;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Set Bits
      regSetBit(0x30,16,trigDisable,writeEn);
   }
}


// Method to get global trigger disable bit.
bool KpixAsic::getCntrlTrigDisable ( bool readEn ) {
   bool ret;

   if ( kpixVersion >= 10 ) {
      ret = regGetBit(0x30,16,readEn);

      if ( enDebug ) {
         cout << "KpixAsic::getCntrlTrigDisable -> Get trigDisable=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
      return(ret);
   }
   else return(false);
}


// Method to set monitor output source
// Set monitor output source
void KpixAsic::setCntrlMonSrc ( KpixAsic::KpixMonSrc monSrc, bool writeEn ) {
   if ( kpixVersion >= 10 ) {
      if ( enDebug ) {
         cout << "KpixAsic::setCntrlMonSrc -> Set monSrc=" << monSrc;
         cout << ", WriteEn=" << writeEn << ".\n";
      }

      // Set Bits
      regSetBit(0x30,31,(monSrc==KpixMonAmp)?1:0,false);
      regSetBit(0x30,30,(monSrc==KpixMonShape)?1:0,writeEn);
   }
}


// Method to get monitor output source
// Get monitor output source
KpixAsic::KpixMonSrc KpixAsic::getCntrlMonSrc ( bool readEn ) {
   KpixAsic::KpixMonSrc ret = KpixMonNone;

   if ( kpixVersion >=10 ) {
      if ( regGetBit(0x30,31,readEn) ) ret = KpixMonAmp;
      if ( regGetBit(0x30,30,readEn) ) ret = KpixMonShape;

      if ( enDebug ) {
         cout << "KpixAsic::getCntrlMonSrc -> Get monSrc=" << ret;
         cout << ", ReadEn=" << readEn << ".\n";
      }
   }
   return(ret);
}


// Method to update KPIX timing configuration
// If the passed timing values are not evenly divisable by the
// clkPeriod the value will be rounded and a warning will be generated.
// Pass the following values (in nanoseconds) for update:
// clkPeriod    - Clock period to use for timing in nS
// resetOn      - Reset_Load set on time in nS
// resetOff     - Reset_Load set off time in nS
// leakNullOff  - Leagage_Null set off time in nS
// offNullOff   - Offset_Null set off time in nS
// threshOff    - Threshold_Offset set off time in nS
// trigInhOff   - Trigger_Inhibit set off time in nS or in bunch clock count
// pwrUpOn      - Power_up ACQ/DIG set on time in nS
// deselDly     - Deselect/select sequence delay in nS
// bunchClkDly  - Bunch clock start delay in nS
// digDelay     - Delete between bunch clocks & digitization in nS
// bunchCount   - Number of bunch crossings, 0 based count, 0-8191
// enChecking   - Enable/disable timing sanity checks
// Set writeEn to false to disable real write to KPIX
// Set trigInhRaw to set raw trigger inhibit value
void KpixAsic::setTiming ( unsigned int clkPeriod,  unsigned int resetOn,
                           unsigned int resetOff,   unsigned int leakNullOff,
                           unsigned int offNullOff, unsigned int threshOff,
                           unsigned int trigInhOff, unsigned int pwrUpOn,
                           unsigned int deselDly,   unsigned int bunchClkDly,
                           unsigned int digDelay,   unsigned int bunchCount,
                           bool enChecking,         bool writeEn,
                           bool trigInhRaw ) {

   // Earlier versions
   if ( kpixVersion <= 7 ) 
      setTimingV7 ( clkPeriod,  resetOn, resetOff,   leakNullOff,
                    offNullOff, threshOff, trigInhOff, pwrUpOn,
                    deselDly,   bunchClkDly, digDelay, enChecking,
                    writeEn, trigInhRaw);

   // Later Versions
   else 
      setTimingV8 ( clkPeriod,  resetOn, resetOff,   leakNullOff,
                    offNullOff, threshOff, trigInhOff, pwrUpOn,
                    deselDly,   bunchClkDly, digDelay,   bunchCount, 
                    enChecking, writeEn, trigInhRaw );
}


// Method to read KPIX timing configuration
// Pass location pointers in which to store the following values:
// clkPeriod    - Clock period to use for timing in nS
// resetOn      - Reset_Load set on time in nanoseconds
// resetOff     - Reset_Load set off time in nanoseconds
// leakNullOff  - Leagage_Null set off time in nanoseconds
// offNullOff   - Offset_Null set off time in nanoseconds
// threshOff    - Threshold_Offset set off time in nanoseconds
// trigInhOff   - Trigger_Inhibit set off time in nanoseconds
// pwrUpOn      - Power_up_ACQ/DIG set on time in nanoseconds
// deselDly     - Deselect/select sequence delay in nanoseconds
// bunchClkDly  - Bunch clock start delay in nanoseconds
// digDelay     - Delete between bunch clocks & digitization in nanoseconds
// bunchCount   - Number of bunch crossings, 0 based count, 0-8191
// Set readEn to false to disable real read from KPIX
// Set trigInhRaw to return raw trigger inhibit value
void KpixAsic::getTiming ( unsigned int *clkPeriod,  unsigned int *resetOn,
                           unsigned int *resetOff,   unsigned int *leakNullOff,
                           unsigned int *offNullOff, unsigned int *threshOff,
                           unsigned int *trigInhOff, unsigned int *pwrUpOn,
                           unsigned int *deselDly,   unsigned int *bunchClkDly,
                           unsigned int *digDelay,   unsigned int *bunchCount,
                           bool readEn,              bool trigInhRaw ) {

   // Earlier versions
   if ( kpixVersion <= 7 ) {
      getTimingV7 ( clkPeriod,  resetOn, resetOff,   leakNullOff,
                    offNullOff, threshOff, trigInhOff, pwrUpOn,
                    deselDly,   bunchClkDly, digDelay, 
                    readEn, trigInhRaw);
      *bunchCount=2889;
   }

   // Later Versions
   else 
      getTimingV8 ( clkPeriod,  resetOn, resetOff,   leakNullOff,
                    offNullOff, threshOff, trigInhOff, pwrUpOn,
                    deselDly,   bunchClkDly, digDelay,   bunchCount, 
                    readEn, trigInhRaw);
}


// Method to get trigger inhibit bucket
unsigned int KpixAsic::getTrigInh ( bool readEn, bool trigInhRaw ) {

   // Local variables
   unsigned int clkPeriod;
   unsigned int temp;
   unsigned int trigInh;
   unsigned int bunchClkDly;

   // Store clock period
   clkPeriod = this->clkPeriod & 0xFFFF;

   // Version 0-7
   if ( kpixVersion <= 7 ) {

      // Get Trigger Inhibit Value
      temp = regGetValue(0x08+4,readEn);
      trigInh = (temp&0xFFFF) * clkPeriod;

      // Get Bunch Clock Delay Value
      temp = regGetValue(0x08+7,readEn);
      bunchClkDly = ((temp>>8)&0xFFFF) * clkPeriod;
   }

   // Version 8+
   else {

      // Get Trigger Inhibit Value
      temp = regGetValue(0x08+3,readEn);
      trigInh = temp * clkPeriod;

      // Get Bunch Clock Delay Value
      temp = regGetValue(0x08+5,readEn);
      bunchClkDly = ((temp>>8)&0xFFFF) * clkPeriod;
   }

   // Convert trigger inhibit
   if ( ! trigInhRaw ) trigInh = ((trigInh - bunchClkDly - clkPeriod) / clkPeriod) / 8;

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getTrigInh -> read timing: \n";
      cout << "                        clkPeriod    = " << dec << clkPeriod    << "\n";
      cout << "                        trigInhOff   = " << dec << trigInh      << "\n";
      cout << "                        bunchClkDly  = " << dec << bunchClkDly  << "\n";
   }
   return(trigInh);
}


// Method to get number of bunch crossings
unsigned int KpixAsic::getBunchCount ( bool readEn ) {

   // Local variables
   unsigned int temp;
   unsigned int bunchCount;

   // Version 0-7
   if ( kpixVersion <= 7 ) { bunchCount = 2889; }

   // Version 8+
   else {

      // Get Bunch Count Value
      temp = regGetValue(0x08+4,readEn);
      bunchCount = ( temp & 0xFFFF);
   }

   return(bunchCount);
}


// Method to update KPIX calibration pulse settings
// Pass the following values for update:
// calCount     - Number of calibration pulses to assert, 0-4
// cal0Delay    - Cal pulse 0 delay 0-8191 bunch clocks
// cal1Delay    - Cal pulse 1 delay 0-8191 bunch clocks
// cal2Delay    - Cal pulse 2 delay 0-8191 bunch clocks
// cal3Delay    - Cal pulse 3 delay 0-8191 bunch clocks
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setCalibTime ( unsigned int calCount,  unsigned int cal0Delay,
                              unsigned int cal1Delay, unsigned int cal2Delay,
                              unsigned int cal3Delay, bool writeEn ) {

   unsigned int temp;

   // Check for valid input
   if ( calCount  >    4 ) 
      throw string("KpixAsic::setCalibTime -> calCount  out of range");
   if (( cal0Delay > 2880 && kpixVersion <= 7) ||  cal0Delay > 8191 ) 
      throw string("KpixAsic::setCalibTime -> cal0Delay out of range");
   if ((( cal0Delay + cal1Delay ) > 2880 && kpixVersion <= 7) || (( cal0Delay + cal1Delay ) > 8191 )) 
      throw string("KpixAsic::setCalibTime -> cal1Delay out of range");
   if ((( cal0Delay + cal1Delay + cal2Delay ) > 2880 && kpixVersion <= 7) || 
       (( cal0Delay + cal1Delay + cal2Delay ) > 8191 ))
      throw string("KpixAsic::setCalibTime -> cal2Delay out of range");
   if ((( cal0Delay + cal1Delay + cal2Delay + cal3Delay ) > 2880 && kpixVersion <= 7) || 
       (( cal0Delay + cal1Delay + cal2Delay + cal3Delay ) > 8191 )) 
      throw string("KpixAsic::setCalibTime -> cal3Delay out of range");

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setCalibTime -> setting values: \n";
      cout << "                          calCount  = " << dec << calCount  << "\n";
      cout << "                          cal0Delay = 0x" << setw(2) << setfill('0');
      cout << hex << cal0Delay << "\n";
      cout << "                          cal1Delay = 0x" << setw(2) << setfill('0');
      cout << hex << cal1Delay << "\n";
      cout << "                          cal2Delay = 0x" << setw(2) << setfill('0');
      cout << hex << cal2Delay << "\n";
      cout << "                          cal3Delay = 0x" << setw(2) << setfill('0');
      cout << hex << cal3Delay << "\n";
   }

   // Kpix versions 0-7
   if ( kpixVersion <= 7 ) {

      // Set cal delay register 0
      temp = 0;
      if ( calCount >= 1 ) temp |= 0x00001000;
      if ( calCount >= 2 ) temp |= 0x10000000;
      temp |= cal0Delay & 0x00000FFF;
      temp |= (cal1Delay << 16) & 0x0FFF0000;
      regSetValue(0x10,temp,writeEn);

      // Set cal delay register 1
      temp = 0;
      if ( calCount >= 3 ) temp |= 0x00001000;
      if ( calCount == 4 ) temp |= 0x10000000;
      temp |= cal2Delay & 0x00000FFF;
      temp |= (cal3Delay << 16) & 0x0FFF0000;
      regSetValue(0x11,temp,writeEn);
   } 

   // Version 8+
   else {

      // Set cal delay register 0
      temp = 0;
      if ( calCount >= 1 ) temp |= 0x00008000;
      if ( calCount >= 2 ) temp |= 0x80000000;
      temp |= cal0Delay & 0x00001FFF;
      temp |= (cal1Delay << 16) & 0x1FFF0000;
      regSetValue(0x10,temp,writeEn);

      // Set cal delay register 1
      temp = 0;
      if ( calCount >= 3 ) temp |= 0x00008000;
      if ( calCount == 4 ) temp |= 0x80000000;
      temp |= cal2Delay & 0x00001FFF;
      temp |= (cal3Delay << 16) & 0x1FFF0000;
      regSetValue(0x11,temp,writeEn);
   }
}


// Method to read KPIX calibration pulse settings
// Pass location pointers in which to store the following values:
// calCount     - Number of calibration pulses to assert, 0-4
// cal0Delay    - Cal pulse 0 delay 0-8191 bunch clocks
// cal1Delay    - Cal pulse 1 delay 0-8191 bunch clocks
// cal2Delay    - Cal pulse 2 delay 0-8191 bunch clocks
// cal3Delay    - Cal pulse 3 delay 0-8191 bunch clocks
// Set readEn to false to disable real read from KPIX
void KpixAsic::getCalibTime ( unsigned int *calCount,  unsigned int *cal0Delay,
                              unsigned int *cal1Delay, unsigned int *cal2Delay,
                              unsigned int *cal3Delay, bool readEn ) {

   unsigned int temp1;
   unsigned int temp2;
   unsigned int count;

   // Read from both registers
   temp1 = regGetValue(0x10,readEn);
   temp2 = regGetValue(0x11,readEn);

   // Kpix Version 0-7
   if ( kpixVersion <= 7 ) {

      // Generate cal count
      count = 0;
      if ( (temp1 & 0x10000000) != 0 ) count++;
      if ( (temp1 & 0x00001000) != 0 ) count++;
      if ( (temp2 & 0x10000000) != 0 ) count++;
      if ( (temp2 & 0x00001000) != 0 ) count++;
      *calCount = count;

      // Extract delay values
      *cal0Delay = temp1 & 0x00000FFF;
      *cal1Delay = (temp1 >> 16) & 0x00000FFF;
      *cal2Delay = temp2 & 0x00000FFF;
      *cal3Delay = (temp2 >> 16) & 0x00000FFF;
   }

   // Kpix version 8+
   else {

      // Generate cal count
      count = 0;
      if ( (temp1 & 0x80000000) != 0 ) count++;
      if ( (temp1 & 0x00008000) != 0 ) count++;
      if ( (temp2 & 0x80000000) != 0 ) count++;
      if ( (temp2 & 0x00008000) != 0 ) count++;
      *calCount = count;

      // Extract delay values
      *cal0Delay = temp1 & 0x00001FFF;
      *cal1Delay = (temp1 >> 16) & 0x00001FFF;
      *cal2Delay = temp2 & 0x00001FFF;
      *cal3Delay = (temp2 >> 16) & 0x00001FFF;
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getCalibTime -> read values: \n";
      cout << "                          calCount  = " << *calCount         << "\n";
      cout << "                          cal0Delay = 0x" << setw(2) << setfill('0');
      cout << hex << *cal0Delay << "\n";
      cout << "                          cal1Delay = 0x" << setw(2) << setfill('0');
      cout << hex << *cal1Delay << "\n";
      cout << "                          cal2Delay = 0x" << setw(2) << setfill('0');
      cout << hex << *cal2Delay << "\n";
      cout << "                          cal3Delay = 0x" << setw(2) << setfill('0');
      cout << hex << *cal3Delay << "\n";
   }
}


// Method to update KPIX Reset/Trigger Threshold A values
// Pass the following values for update:
// rstTholdA  - Range A reset threshold, 0x00-0xFF
// trigTholdA - Range A trig  threshold, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacThreshRangeA ( unsigned char rstTholdA, unsigned char trigTholdA,
                                    bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true , true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacThreshRangeA -> setting thresholds: \n";
      cout << "                                rstTholdA  = 0x" << setw(2) << setfill('0'); 
      cout << hex << (int)rstTholdA  << "\n";
      cout << "                                trigTholdA = 0x" << setw(2) << setfill('0'); 
      cout << hex << (int)trigTholdA << "\n";
   }

   // Set registers
   regSetValue(0x20,rstTholdA,writeEn);
   regSetValue(0x28,trigTholdA,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Reset/Trigger Threshold A values
// Pass location pointers in which to store the following values:
// rstTholdA  - Range A reset threshold, 0x00-0xFF
// trigTholdA - Range A trig  threshold, 0x00-0xFF
// Set readEn to false to disable real read from KPIX
void KpixAsic::getDacThreshRangeA ( unsigned char *rstTholdA, unsigned char *trigTholdA,
                                    bool readEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   *rstTholdA  = regGetValue(0x20,readEn);
   *trigTholdA = regGetValue(0x28,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacThreshRangeA -> read thresholds: \n";
      cout << "                                rstTholdA  = 0x" << setw(2) << setfill('0');
      cout << hex << (int)*rstTholdA  << "\n";
      cout << "                                trigTholdA = 0x" << setw(2) << setfill('0');
      cout << hex << (int)*trigTholdA << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to update KPIX Reset/Trigger Threshold B values
// Pass the following values for update:
// rstTholdB  - Range B reset threshold, 0x00-0xFF
// trigTholdB - Range B trig  threshold, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacThreshRangeB ( unsigned char rstTholdB, unsigned char trigTholdB,
                                    bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacThreshRangeB -> setting thresholds: \n";
      cout << "                                rstTholdB  = 0x" << setw(2) << setfill('0'); 
      cout << hex << (int)rstTholdB  << "\n";
      cout << "                                trigTholdB = 0x" << setw(2) << setfill('0'); 
      cout << hex << (int)trigTholdB << "\n";
   }

   // Set registers
   regSetValue(0x21,rstTholdB,writeEn);
   regSetValue(0x29,trigTholdB,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Reset/Trigger Threshold B values
// Pass location pointers in which to store the following values:
// rstTholdB  - Range B reset threshold, 0x00-0xFF
// trigTholdB - Range B trig  threshold, 0x00-0xFF
// Set readEn to false to disable real read from KPIX
void KpixAsic::getDacThreshRangeB ( unsigned char *rstTholdB, unsigned char *trigTholdB,
                                    bool readEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   *rstTholdB  = regGetValue(0x21,readEn);
   *trigTholdB = regGetValue(0x29,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacThreshRangeB -> read thresholds: \n";
      cout << "                                rstTholdB  = 0x" << setw(2) << setfill('0');
      cout << hex << (int)*rstTholdB  << "\n";
      cout << "                                trigTholdB = 0x" << setw(2) << setfill('0');
      cout << hex << (int)*trigTholdB << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to update KPIX calibration DAC value
// Pass the following values for update:
// calValue   - Calibration hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacCalib ( unsigned char calValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacCalib -> writing calib value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)calValue << "\n";
   }

   // Set registers
   regSetValue(0x24,calValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX calibration DAC value
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacCalib ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x24,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacCalib -> read calib value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
   return(ret);
}


// Method to update KPIX Ramp Threshold DAC value
// Pass the following values for update:
// dacValue - DAC hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacRampThresh ( unsigned char dacValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacRampThresh -> writing value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)dacValue << "\n";
   }

   // Set registers
   regSetValue(0x22,dacValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Ramp Threshold DAC value
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacRampThresh ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x22,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacRampThresh -> read value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );

   return(ret);
}


// Method to update KPIX Range Threshold DAC value
// Pass the following values for update:
// dacValue - DAC hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacRangeThresh ( unsigned char dacValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacRangeThresh -> writing value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)dacValue << "\n";
   }

   // Set registers
   regSetValue(0x23,dacValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Range Threshold DAC value
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacRangeThresh ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x23,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacRangeThresh -> read value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
   return(ret);
}


// Method to update KPIX Event Threshold Reference DAC value
// Pass the following values for update:
// dacValue - DAC hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacEventThreshRef ( unsigned char dacValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacEventThreshRef -> writing value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)dacValue << "\n";
   }

   // Set registers
   regSetValue(0x25,dacValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Event Threshold Reference DAC value
// Set readEn to false to disable real read from KPIX
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacEventThreshRef ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x25,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacEventThreshRef -> read value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
   return(ret);
}


// Method to update KPIX Shaper Bias DAC value
// Pass the following values for update:
// dacValue - DAC hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacShaperBias ( unsigned char dacValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacShaperBias -> writing value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)dacValue << "\n";
   }

   // Set registers
   regSetValue(0x26,dacValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Shaper Bias DAC value
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacShaperBias ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x26,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacShaperBias -> read value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
   return(ret);
}


// Method to update KPIX Default Analog DAC value
// Pass the following values for update:
// dacValue - DAC hex value, 0x00-0xFF
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setDacDefaultAnalog ( unsigned char dacValue, bool writeEn ) {

   bool oldPwr;

   // Force power on for Kpix 9
   if ( writeEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setDacDefaultAnalog -> writing value=0x"<< setw(2) << setfill('0');
      cout <<  hex << (int)dacValue << "\n";
   }

   // Set registers
   regSetValue(0x27,dacValue,writeEn);

   // Restore power for Kpix 9
   if ( writeEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
}


// Method to read KPIX Default Analog DAC value
// Set readEn to false to disable real read from KPIX
unsigned char KpixAsic::getDacDefaultAnalog ( bool readEn ) {

   unsigned char ret;
   bool oldPwr;

   // Force power on for Kpix 9
   if ( readEn && kpixVersion == 9 ) {
      oldPwr = getCntrlDisPwrCycle  ( false );
      setCntrlDisPwrCycle  ( true, true );
   }

   // Read registers
   ret = regGetValue(0x27,readEn);

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getDacDefaultAnalog -> read value=0x" << setw(2) << setfill('0');
      cout << hex << (int)ret << "\n";
   }

   // Restore power for Kpix 9
   if ( readEn && kpixVersion == 9 ) setCntrlDisPwrCycle ( oldPwr, true );
   return(ret);
}


// Method to set channel mode according to a passed array
// Pass array of integers (1024) to select the mode of
// each channel. The modes enabled are KpixChanThreshACal, KpixChanThreshA, KpixChanThreshB, KpixChanDisable
// If KpixChanDisable is passed for a KPIX earlier than 6, KpixChanThreshB will be selected.
// Set writeEn to false to disable real write to KPIX
void KpixAsic::setChannelModeArray (KpixChanMode *modes, bool writeEn ) {

   unsigned int x, y;
   unsigned int temp[2];

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::setChannelModeArray -> writing channels\n";
   }

   // Loop through each register 
   for (x=0; x < 32; x++) {

      // Generate new temp value
      temp[0] = 0;
      temp[1] = 0;
      for (y=0; y < 32; y++)  {

         // Disable not supported before KPIX 6, set to ChanThreshB
         if ( modes[32*x+y] == KpixChanDisable && kpixVersion < 6 ) modes[32*x+y] = KpixChanThreshB;

         // Determine mode
         if ( modes[32*x+y] == KpixChanThreshACal ) { // CalMask = 1, Thresh = 1
            temp[0] |= 1 << y;
            temp[1] |= 1 << y;
         }
         else if ( modes[32*x+y] == KpixChanDisable ) // CalMask = 1, Thresh = 0
            temp[0] |= 1 << y;
         else if ( modes[32*x+y] == KpixChanThreshA ) // CalMask = 0, Thresh = 1
            temp[1] |= 1 << y;

         // ChanThreshB = CalMask=0, Thresh=0
      }

      // Write register
      regSetValue(0x40+x,temp[0],writeEn);
      regSetValue(0x60+x,temp[1],writeEn);
   }
}


// Method to update the passed array with the current mode of each channel
// Pass array of integers (1024) to update. Each location will be updated
// with one of the following values: ChanThreshACal, ChanThreshA, ChanThreshB, ChanDisable
// Set readEn to false to disable real read from KPIX
void KpixAsic::getChannelModeArray ( KpixChanMode *modes, bool readEn ) {

   unsigned int x, y;
   unsigned int temp[2];

   // Loop through each register 
   for (x=0; x < 32; x++) {

      // Read register from device
      temp[0] = regGetValue(0x40+x,readEn);
      temp[1] = regGetValue(0x60+x,readEn);

      // Go through each bit value
      for (y=0; y < 32; y++) {

         // CalMask=1, Thresh=1, ChanThreshACal
         if ( (temp[0] & (1<<y)) != 0 && (temp[1] & (1<<y)) != 0 ) modes[32*x+y] = KpixChanThreshACal;

         // CalMask=1, Thresh=0, KpixChanDisable
         else if ( (temp[0] & (1<<y)) != 0 && (temp[1] & (1<<y)) == 0 ) modes[32*x+y] = KpixChanDisable;

         // CalMask=0, Thresh=1, KpixChanDisable
         else if ( (temp[0] & (1<<y)) == 0 && (temp[1] & (1<<y)) != 0 ) modes[32*x+y] = KpixChanThreshA;

         // CalMask=0, Thresh=0, KpixChanThreshB
         else modes[32*x+y] = KpixChanThreshB;
      }
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "KpixAsic::getChannelModeArray -> reading channels\n";
   }
}


// Class Method To Convert DAC value to voltage
double KpixAsic::dacToVolt(unsigned char dacValue) {

   // Convert value
   if ( dacValue >= 0xf6 ) return(2.5 - ((double)(0xff-dacValue))*50.0*0.0001);
   else return((double)dacValue * 100.0 * 0.0001);
}


// Class Method To Convert DAC value to voltage
double KpixAsic::dacToVolt(double dacValue) {

   // Convert value
   if ( dacValue >= 246.0 ) return(2.5 - (255.0-dacValue)*50.0*0.0001);
   else return((double)dacValue * 100.0 * 0.0001);
}


// Convert DAC voltage to value
unsigned char KpixAsic::voltToDac ( double dacVoltage ) {

   // Verify range
   if ( dacVoltage > 2.5 || dacVoltage < 0 ) 
      throw string("KpixAsic::voltToDac -> Voltage Out Of Range");

   // Upper values are 5mv steps
   if ( dacVoltage > 2.45 ) return(0xff - (int)((2.5 - dacVoltage) / 0.0050));

   // Lower values are 10mv steps
   else return((unsigned char)(dacVoltage / 0.01));
}


// Class Method to retrieve the current value of the calibration charge
// For settings provided by external code.
// Pass the following values
// bucket    - Bucket number for conversion
// calDac    - Calibration DAC value
// posPixel  - State of posPixel flag
// calibHigh - State of high range calibration flag
double KpixAsic::computeCalibCharge ( unsigned char bucket, unsigned char calDac,
                                             bool posPixel,  bool calibHigh ) {

   double temp;
   double charge;

   // Get value from DAC4 register
   temp = dacToVolt(calDac);

   // Compute charge based on posPix
   if ( posPixel ) charge = (2.5 - temp) * 200e-15;
   else charge = temp * 200e-15;

   // Expanded range for channel 0
   if ( bucket == 0 && calibHigh ) charge = charge * 22;
   return(charge);
}


// Method to retrieve the current value of the calibration charges
// This method will determine the calibartion charge for each 
// bucket based upon the current settings of the Kpix ASIC.
// Pass 4 position array to store values
void KpixAsic::getCalibCharges ( double calCharge[] ) {

   unsigned char x;
   unsigned char calDac;
   bool          posPixel;
   bool          calibHigh;

   // get configuration state
   calDac    = getDacCalib(false);
   posPixel  = getCntrlPosPixel(false);
   calibHigh = getCntrlCalibHigh(false);

   // Get Charge for each bucket
   for (x=0; x < 4; x++) 
      calCharge[x] = computeCalibCharge(x,calDac,posPixel,calibHigh);
}


// Deconstructor
KpixAsic::~KpixAsic ( ) { }


// Turn on or off debugging for the class
void KpixAsic::kpixDebug ( bool debug ) { 

   // Debug if enabled
   if ( enDebug ) 
      cout << "KpixAsic::kpixDebug -> updating debug to " << debug << "\n";
   else if ( debug ) 
      cout << "KpixAsic::kpixDebug -> enabling debug\n";

   // Local debug flag
   enDebug = debug;
}


// Disable register verification
void KpixAsic::disableVerify ( bool disable ) { 
   clkPeriod &= 0x7FFFFFFF;
   if ( disable ) clkPeriod |= 0x80000000;
}


// Get debug flag
bool KpixAsic::kpixDebug ( ) { return(enDebug); }


// Return current KPIX Version
unsigned short KpixAsic::getVersion ( ) { return(kpixVersion); }

// Return current KPIX Address
unsigned short KpixAsic::getAddress ( ) { return(kpixAddress); }

// Return current KPIX Serial Number
unsigned short KpixAsic::getSerial ( ) { return(kpixSerial); }

// Change KPIX Serial Number
void KpixAsic::setSerial ( unsigned short serial ) { kpixSerial=serial; }

#ifdef ONLINE_EN
// Return SID Link Object Pointer
SidLink * KpixAsic::getSidLink () { return(sidLink); }
#endif


// Set Defaults
// Pass clock period to use
void KpixAsic::setDefaults ( unsigned int clkPeriod, bool writeEn ) {

   unsigned int x;
   KpixChanMode modes[1024];

   // Configure Control Registers
   setCfgTestData       ( false,          false   );
   setCfgAutoReadDis    ( false,          false   );
   setCfgForceTemp      ( false,          false   );
   setCfgDisableTemp    ( false,          false   );
   setCfgAutoStatus     ( false,          writeEn );
   setCntrlCalibHigh    ( false,          false   );
   setCntrlCalDacInt    ( true,           false   );
   setCntrlForceLowGain ( false,          false   );
   setCntrlLeakNullDis  ( true,           false   );
   setCntrlDoubleGain   ( false,          false   );
   setCntrlNearNeighbor ( false,          false   );
   setCntrlPosPixel     ( true,           false   );
   setCntrlDisPerRst    ( true,           false   );
   setCntrlEnDcRst      ( true,           false   );
   setCntrlCalSrc       ( KpixDisable,    false   );
   setCntrlTrigSrc      ( KpixDisable,    false   );
   setCntrlShortIntEn   ( false,          false   );
   setCntrlDisPwrCycle  ( false,          false   );
   setCntrlFeCurr       ( FeCurr_121uA,   false   );
   setCntrlHoldTime     ( HoldTime_64x,   false   );
   setCntrlTrigDisable  ( true,           false   );
   setCntrlMonSrc       ( KpixMonNone,    writeEn );

   // Set timing values
   setTiming ( clkPeriod, // Clock Period
               700,       // Reset On Time
               120000,    // Reset off Time
               200,       // Leakage Null Off
               100500,    // Offset Null Off
               101500,    // Thresh Off
               0,         // Trig Inhibit Off (bunch periods)
               900,       // Power Up On
               6900,      // Desel Sequence
               467500,    // Bunch Clock Delay
               10000,     // Digitization Delay
               2890,      // Bunch Clock Count
               true,      // Checking Enable
               writeEn
             );

   // Setup DACs
   setDacCalib          ( (unsigned char)0x00, writeEn );
   setDacRampThresh     ( (unsigned char)0xE0, writeEn );
   setDacRangeThresh    ( (unsigned char)0x00, writeEn );
   setDacDefaultAnalog  ( (unsigned char)0xBD, writeEn );
   setDacEventThreshRef ( (unsigned char)0x50, writeEn );
   setDacShaperBias     ( (unsigned char)0x78, writeEn );

   // Set Threshold DACs
   setDacThreshRangeA ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                        (unsigned char)0x00, // Range A Trigger Threshold
                        writeEn);
   setDacThreshRangeB ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                        (unsigned char)0x00, // Range A Trigger Threshold
                        writeEn);

   // Init Channel Modes
   for(x=0; x < 1024; x++) modes[x] = KpixChanDisable;
   setChannelModeArray(modes,writeEn);

   // Setup calibration strobes
   setCalibTime ( 4,      // Calibration Count
                  0x28A,  // Calibration 0 Delay
                  0x28A,  // Calibration 1 Delay
                  0x28A,  // Calibration 2 Delay
                  0x28A,  // Calibration 3 Delay
                  writeEn);
}


// Read from all registers will debug enabled to display all of the current settings
void KpixAsic::dumpSettings () {

   unsigned int  clkPeriod;
   unsigned int  resetOn;
   unsigned int  resetOff;
   unsigned int  leakNullOff;
   unsigned int  offNullOff;
   unsigned int  threshOff;
   unsigned int  trigInhOff;
   unsigned int  pwrUpOn;
   unsigned int  deselDly;
   unsigned int  bunchClkDly;
   unsigned int  digDelay;
   unsigned int  bunchCount;
   unsigned int  calCount;
   unsigned int  cal0Delay;
   unsigned int  cal1Delay;
   unsigned int  cal2Delay;
   unsigned int  cal3Delay;
   unsigned char rstTholdA;
   unsigned char trigTholdA;
   unsigned char rstTholdB;
   unsigned char trigTholdB;
   KpixChanMode  modes[1024];
   unsigned int  x;

   // Get some values
   getTiming ( &clkPeriod,  &resetOn, &resetOff,   &leakNullOff,
               &offNullOff, &threshOff, &trigInhOff, &pwrUpOn,
               &deselDly,   &bunchClkDly, &digDelay, &bunchCount, false, false);
   getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, false );
   getDacThreshRangeA ( &rstTholdA, &trigTholdA, false );
   getDacThreshRangeB ( &rstTholdB, &trigTholdB, false );

   // Display data
   cout << "       KpixAddress = " << dec << kpixAddress << "\n";
   cout << "        KpixSerial = " << dec << kpixSerial  << "\n";
   cout << "       KpixVersion = " << dec << kpixVersion << "\n";
   cout << "       CfgTestData = " << getCfgTestData(false) << "\n";
   cout << "    CfgAutoReadDis = " << getCfgAutoReadDis(false) << "\n";
   cout << "      CfgForceTemp = " << getCfgForceTemp(false) << "\n";
   cout << "    CfgDisableTemp = " << getCfgDisableTemp(false) << "\n";
   cout << "     CfgAutoStatus = " << getCfgAutoStatus(false) << "\n";
   cout << "     CntrlHoldTime = " << getCntrlHoldTime(false) << "\n";
   cout << "    CntrlCalibHigh = " << getCntrlCalibHigh(false) << "\n";
   cout << "    CntrlCalDacInt = " << getCntrlCalDacInt(false) << "\n";
   cout << " CntrlForceLowGain = " << getCntrlForceLowGain(false) << "\n";
   cout << "  CntrlLeakNullDis = " << getCntrlLeakNullDis(false) << "\n";
   cout << "     CntrlPosPixel = " << getCntrlPosPixel(false) << "\n";
   cout << "       CntrlCalSrc = " << getCntrlCalSrc(false) << "\n";
   cout << "      CntrlTrigSrc = " << getCntrlTrigSrc(false) << "\n";
   cout << " CntrlNearNeighbor = " << getCntrlNearNeighbor(false) << "\n";
   cout << "   CntrlDoubleGain = " << getCntrlDoubleGain(false) << "\n";
   cout << "    CntrlDisPerRst = " << getCntrlDisPerRst(false) << "\n";
   cout << "      CntrlEnDcRst = " << getCntrlEnDcRst(false) << "\n";
   cout << "   CntrlShortIntEn = " << getCntrlShortIntEn(false) << "\n";
   cout << "  CntrlDisPwrCycle = " << getCntrlDisPwrCycle(false) << "\n";
   cout << "       CntrlFeCurr = " << getCntrlFeCurr(false) << "\n";
   cout << "  CntrlTrigDisable = " << getCntrlTrigDisable(false) << "\n";
   cout << "       CntrlMonSrc = " << getCntrlMonSrc(false) << "\n";
   cout << "          DacCalib = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacCalib(false) << "\n";
   cout << "     DacRampThresh = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacRampThresh(false) << "\n";
   cout << "    DacRangeThresh = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacRangeThresh(false) << "\n";
   cout << " DacEventThreshRef = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacEventThreshRef(false) << "\n";
   cout << "     DacShaperBias = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacShaperBias(false) << "\n";
   cout << "  DacDefaultAnalog = 0x" << hex << setw(2) << setfill('0');
   cout << (int)getDacDefaultAnalog(false) << "\n";
   cout << "         ClkPeriod = " << dec << clkPeriod << "ns\n";
   cout << "           ResetOn = " << dec << resetOn << "ns\n";
   cout << "          ResetOff = " << dec << resetOff << "ns\n";
   cout << "       LeakNullOff = " << dec << leakNullOff << "ns\n";
   cout << "        OffNullOff = " << dec << offNullOff << "ns\n";
   cout << "         ThreshOff = " << dec << threshOff << "ns\n";
   cout << "        TrigInhOff = " << dec << trigInhOff << "(bunch clock)\n";
   cout << "        TrigInhOff = " << dec << getTrigInh ( false, true ) << "ns\n";
   cout << "           PwrUpOn = " << dec << pwrUpOn << "ns\n";
   cout << "          DeselDly = " << dec << deselDly << "ns\n";
   cout << "       BunchClkDly = " << dec << bunchClkDly << "ns\n";
   cout << "          DigDelay = " << dec << digDelay << "ns\n";
   cout << "        BunchCount = " << dec << bunchCount << "\n";
   cout << "          CalCount = " << dec << setw(1) << setfill('0') << (int)calCount << "\n";
   cout << "         Cal0Delay = 0x" << hex << setw(3) << setfill('0') << cal0Delay << "\n";
   cout << "         Cal1Delay = 0x" << hex << setw(3) << setfill('0') << cal1Delay << "\n";
   cout << "         Cal2Delay = 0x" << hex << setw(3) << setfill('0') << cal2Delay << "\n";
   cout << "         Cal3Delay = 0x" << hex << setw(3) << setfill('0') << cal3Delay << "\n";
   cout << "         RstTholdA = 0x" << hex << setw(2) << setfill('0') << (int)rstTholdA << "\n";
   cout << "        TrigTholdA = 0x" << hex << setw(2) << setfill('0') << (int)trigTholdA << "\n";
   cout << "         RstTholdB = 0x" << hex << setw(2) << setfill('0') << (int)rstTholdB << "\n";
   cout << "        TrigTholdB = 0x" << hex << setw(2) << setfill('0') << (int)trigTholdB << "\n";

   // Get channel modes
   getChannelModeArray(modes,false);
   for ( x=0; x < getChCount(); x++) {
      if ( x % 32 == 0 ) {
         cout << " Chan Mode ";
         cout << dec << setfill('0') << setw(3) << x;
         cout << ":";
         cout << dec << setfill('0') << setw(3) << x+31;
         cout << " = ";
      }
      if ( x % 4 == 0 && x % 32 != 0 ) cout << " ";
      if ( modes[x] == KpixChanDisable    ) cout << "D";
      if ( modes[x] == KpixChanThreshACal ) cout << "C";
      if ( modes[x] == KpixChanThreshA    ) cout << "A";
      if ( modes[x] == KpixChanThreshB    ) cout << "B";
      if ( x % 32 == 31 ) cout << "\n";
   }
}


// Get Channel COunt
unsigned int KpixAsic::getChCount() { 
   if ( kpixVersion < 8 ) return(64);
   if ( kpixVersion < 9 ) return(256);
   if ( kpixVersion < 10 ) return(512);
   if ( kpixVersion == 11 ) return(128);
   else return(1024);
}


// Class Method To Convert DAC value to temperature
double KpixAsic::convertTemp(unsigned int tempAdc, unsigned int* decimalValue) {
   int    g[8];
   int    d[8];
   int    de;
   int    i;
   double temp;

   // Convert number to binary
   for (i=7; i >= 0; i--) {
      if ( tempAdc >= (unsigned int)pow(2,i) ) {
         g[i] = 1;
         tempAdc -= (unsigned int)pow(2,i);
      }
      else g[i] = 0;
   }

   // Convert grey code to decimal
   d[7] = g[7];
   for (i=6; i >= 0; i--) d[i]=d[i+1]^g[i];

   // Convert back to an integer
   de = 0;
   for (i=0; i<8; i++) if ( d[i] != 0 ) de += (int)pow(2,i);
   cout << "Decimal=0x" << hex << de << "," << dec << de << endl;

   // Convert to temperature
   temp=-30.2+127.45/233*(255-de-20.75);
   //if ( (object)decimalValue != NULL ) { 
   if ( decimalValue != NULL ) { 
	   decimalValue = (unsigned int*) (255 - de); 
	   //cout << "in decimal: " << dec << decimalValue << endl;
	   }
   return(temp);
}
