//-----------------------------------------------------------------------------
// File          : KpixAsic.h
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
// Copyright (c) 2006 by SLAC. All rights reserved.
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
// 04/29/2007: Added ability to read debug flag
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
// 04/08/2009: Added flag in timing methods to set mode for trigger inhibit time
// 04/29/2009: Added readEn flag to some read calls.
//-----------------------------------------------------------------------------
#ifndef __KPIX_ASIC_H__
#define __KPIX_ASIC_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <Rtypes.h>
#include <TObject.h>
using namespace std;

#ifdef ONLINE_EN
#include "../online/SidLink.h"
#endif

// Constants for channel mode
#define DISABLE 0x1
#define CAL_A   0x3
#define TH_A    0x2
#define TH_B    0x0


// KPIX ASIC Class
class KpixAsic : public TObject {

      // Address of Kpix ASIC
      unsigned short kpixAddress;

      // Kpix Serial Number
      unsigned short kpixSerial;

      // Kpix version
      unsigned short kpixVersion;

      // Clock period used for timing
      unsigned int clkPeriod;

      // Register values & configuration
      unsigned int  regData[0x80];
      unsigned char regWidth[0x80];
      bool          regWriteable[0x80];

      // Debug flag
      bool enDebug;

#ifdef ONLINE_EN
      // Link object
      SidLink *sidLink; //! Root:Don't stream link object to file
#else
      void    *sidLink; //! Root:Don't stream link object to file
#endif

      // Private method to send a command frame to the KPIX
      // Pass command field and broadcast flag
      void sendCommand ( unsigned char command, bool bcast );

      // Private method to write register value to Kpix
      void regWrite (unsigned char address);

      // Private method to read register value from Kpix
      void regRead (unsigned char address);

      // Private method to write timing settings for versions 0-7
      void setTimingV7 ( unsigned int clkPeriod,  unsigned int resetOn,
                         unsigned int resetOff,   unsigned int leakNullOff,
                         unsigned int offNullOff, unsigned int threshOff,
                         unsigned int trigInhOff, unsigned int pwrUpOn,
                         unsigned int deselDly,   unsigned int bunchClkDly,
                         unsigned int digDelay,   bool enChecking,
                         bool writeEn,            bool trigInhRaw );

      // Private method to read timing settings for versions 0-7
      void getTimingV7 ( unsigned int *clkPeriod,  unsigned int *resetOn,
                         unsigned int *resetOff,   unsigned int *leakNullOff,
                         unsigned int *offNullOff, unsigned int *threshOff,
                         unsigned int *trigInhOff, unsigned int *pwrUpOn,
                         unsigned int *deselDly,   unsigned int *bunchClkDly,
                         unsigned int *digDelay,   bool readEn,
                         bool trigInhRaw);

      // Private method to write timing settings for versions 8+
      void setTimingV8 ( unsigned int clkPeriod,  unsigned int resetOn,
                         unsigned int resetOff,   unsigned int leakNullOff,
                         unsigned int offNullOff, unsigned int threshOff,
                         unsigned int trigInhOff, unsigned int pwrUpOn,
                         unsigned int deselDly,   unsigned int bunchClkDly,
                         unsigned int digDelay,   unsigned int bunchCount, 
                         bool enChecking,         bool writeEn,
                         bool trigInhRaw);

      // Private method to read timing settings for versions 8+
      void getTimingV8 ( unsigned int *clkPeriod,  unsigned int *resetOn,
                         unsigned int *resetOff,   unsigned int *leakNullOff,
                         unsigned int *offNullOff, unsigned int *threshOff,
                         unsigned int *trigInhOff, unsigned int *pwrUpOn,
                         unsigned int *deselDly,   unsigned int *bunchClkDly,
                         unsigned int *digDelay,   unsigned int *bunchCount,
                         bool readEn,              bool trigInhRaw );

   public:

      // Max Kpix Version
      static unsigned short maxVersion();

      // Kpix ASIC Constructor
      KpixAsic ( );

#ifdef ONLINE_EN
      // Kpix ASIC Constructor
      // Pass SID Link Object, KPIX version, 2,3,4,etc, KPIX Address & Serial number
      KpixAsic ( SidLink *sidLink, unsigned short version, unsigned short address,
                 unsigned short serial );

      // Set SID Link
      void setSidLink ( SidLink *sidLink );
#endif

      // Send reset command to KPIX
      // Pass optional broadcast flag, default=false
      void cmdReset ( bool bcast = false );

      // Send acquire command to KPIX
      // Pass optional broadcast flag, default=false
      void cmdAcquire ( bool bcast = false );

      // Send calibrate command to KPIX
      // Pass optional broadcast flag, default=false
      void cmdCalibrate ( bool bcast = false );

      // Method to set register value
      // Pass the following values
      // address = Register address
      // value   = 32-Bit register value
      // writeEn = Flag to perform actual write
      // Function will auto adjust for register width
      void regSetValue ( unsigned char address, unsigned int value, bool writeEn=true );

      // Method to get register value
      // Pass the following values
      // address = Register address
      // read    = Flag to perform actual write
      // Function will auto adjust for register width
      unsigned int regGetValue ( unsigned char address, bool readEn=true );

      // Method to set register bit
      // Pass the following values
      // address = Register address
      // bit     = Bit to set
      // value   = Value to set, true or false
      // writeEn = Flag to perform actual write
      // Function will auto adjust for register width
      void regSetBit ( unsigned char address, unsigned char bit, bool value, bool writeEn=true);

      // Method to get register bit
      // Pass the following values
      // address = Register address
      // bit     = Bit to get
      // read    = Flag to perform actual write
      // Function will auto adjust for register width
      bool regGetBit ( unsigned char address, unsigned char bit, bool readEn=true);

      // Method to return register width
      // Pass the register address
      unsigned char regGetWidth ( unsigned char address );

      // Method to return register name
      // Pass the register address
      string regGetName ( unsigned char address );

      // Method to return register writable flag
      // Pass the register address
      bool regGetWriteable ( unsigned char address );

      // Method to get KPIX Status
      // Pass location pointers in which to store the following status flags:
      // cmdPerr  - Command parity error flag
      // dataPerr - Data parity error flag
      void getStatus ( bool *cmdPerr, bool *dataPerr, 
                       bool *tempEn, unsigned char *tempValue, bool readEn = true );

      // Method to set testData mode in Config Register
      // Pass testData flag
      // Set writeEn to false to disable real write to KPIX
      void setCfgTestData ( bool testData, bool writeEn=true );

      // Method to get status of testData mode in Config Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCfgTestData (  bool readEn=true );

      // Method to set auto readout disable flag in Config Register
      // Pass autoReadDis flag
      // Set writeEn to false to disable real write to KPIX
      void setCfgAutoReadDis ( bool autoReadDis, bool writeEn=true );

      // Method to get status of auto readout disable flag in Config Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCfgAutoReadDis (  bool readEn=true );

      // Method to set force temperature on flag in Config Register
      // Pass forceTemp flag
      // Set writeEn to false to disable real write to KPIX
      void setCfgForceTemp ( bool forceTemp, bool writeEn=true );

      // Method to get status of force temperature on flag in Config Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCfgForceTemp (  bool readEn=true );

      // Method to set disable temperature flag in Config Register
      // Pass disableTemp flag
      // Set writeEn to false to disable real write to KPIX
      void setCfgDisableTemp ( bool disableTemp, bool writeEn=true );

      // Method to get status of disable temperature flag in Config Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCfgDisableTemp (  bool readEn=true );

      // Method to set auto status message flag in Config Register
      // Pass autoStatus flag
      // Set writeEn to false to disable real write to KPIX
      void setCfgAutoStatus ( bool autoStatus, bool writeEn=true );

      // Method to set auto status message flag in Config Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCfgAutoStatus (  bool readEn=true );

      // Method to set hold time value in Control Register
      // Set writeEn to false to disable real write to KPIX
      // Hold Times For 20Mhz Clock In Kpix Versions 0-7:
      //    1 = 3.2uS 
      //    2 = 2.0uS
      //    3 = 1.6uS
      // Hold Times For 20Mhz Clock In Kpix Version 8+:
      //    0 = 0.4uS 
      //    1 = 0.8uS 
      //    2 = 1.2uS
      //    3 = 1.6uS
      //    4 = 2.0uS
      //    5 = 2.4uS
      //    6 = 2.8uS
      //    7 = 3.2uS
      void setCntrlHoldTime ( unsigned char holdTime, bool writeEn=true );

      // Method to get hold time value from Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      unsigned char getCntrlHoldTime ( bool readEn=true );

      // Method to set calibration pulse 0 high range mode in Control Register
      // Pass calibHigh flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlCalibHigh ( bool calibHigh, bool writeEn=true );

      // Method to get status of calibration pulse 0 high range mode in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlCalibHigh ( bool readEn=true );

      // Method to select internal calibration dac in Control Register
      // Pass calDacInt flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlCalDacInt ( bool calDacInt, bool writeEn=true );

      // Method to get status of internal calibration dac select in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlCalDacInt (  bool readEn=true );

      // Method to set force log gain mode in Control Register
      // Pass forceLowGain flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlForceLowGain ( bool forceLowGain, bool writeEn=true );

      // Method to get status of force low gain mode in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlForceLowGain (  bool readEn=true );

      // Method to set leakage null disable in Control Register
      // Pass leakNullDis flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlLeakNullDis ( bool leakNullDis, bool writeEn=true );

      // Method to get status of leakage null disable in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlLeakNullDis (  bool readEn=true );

      // Method to set positive pixel mode in Control Register
      // Pass posPixel flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlPosPixel ( bool cfgPosPixel, bool writeEn=true );

      // Method to get status of positive pixel mode in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlPosPixel (  bool readEn=true );

      // Method to set calibration source in Control Register
      // Pass calibSrcCore flag, true = Core, false = External
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlCalSrcCore ( bool calSrcCore, bool writeEn=true );

      // Method to get status of calibration source in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlCalSrcCore (  bool readEn=true );

      // Method to set force trigger source in Control Register
      // Pass trigSrcCore flag, true = Core, false = External
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlTrigSrcCore ( bool trigSrcCore, bool writeEn=true );

      // Method to get status of force trigger source in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlTrigSrcCore (  bool readEn=true );

      // Method to set enable nearest neighbor triggering in Control Register
      // Pass nearNeighbor flag, true = enable, false = disable
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlNearNeighbor ( bool nearNeighbor, bool writeEn=true );

      // Method to get status of nearest neighbor triggering enable in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlNearNeighbor (  bool readEn=true );

      // Method to set charge amplifier double gain in Control Register
      // Pass doubleGain flag, true = enable, false = disable
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlDoubleGain ( bool doubleGain, bool writeEn=true );

      // Method to get status of charge amplifier double gain in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlDoubleGain (  bool readEn=true );

      // Method to set disable periodic reset in Control Register
      // Pass disPerRst flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlDisPerRst ( bool disPerRst, bool writeEn=true );

      // Method to get status of disable periodic reset in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlDisPerRst (  bool readEn=true );

      // Method to set enable DC reset in Control Register
      // Pass enDcRst flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlEnDcRst ( bool enDcRst, bool writeEn=true );

      // Method to get status of enable DC reset in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlEnDcRst (  bool readEn=true );

      // Method to select short integration time
      // Pass shortIntEn flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlShortIntEn ( bool shortIntEn, bool writeEn=true );

      // Method to get status of short integration time enable bit in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlShortIntEn (  bool readEn=true );

      // Method to disable power cycling
      // Pass disPwrCycle flag
      // Set writeEn to false to disable real write to KPIX, this flag can be used
      // to allow the individual register bits to be set before performing a write
      // to the device.
      void setCntrlDisPwrCycle ( bool disPwrCycle, bool writeEn=true );

      // Method to get status of disable power cycle bit in Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      bool getCntrlDisPwrCycle (  bool readEn=true );

      // Method to set front end current value in Control Register
      // Set writeEn to false to disable real write to KPIX
      // Current values:
      //    0 = 1uA  
      //    1 = 31uA 
      //    2 = 61uA 
      //    3 = 91uA 
      //    4 = 121uA
      //    5 = 151uA
      //    6 = 181uA
      //    7 = 211uA
      void setCntrlFeCurr ( unsigned char feCurr, bool writeEn=true );

      // Method to get front end current value from Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      unsigned char getCntrlFeCurr ( bool readEn=true );

      // Method to set shaper diff time value in Control Register
      // Set writeEn to false to disable real write to KPIX
      // Current values:
      //    0 = Normal
      //    1 = 1/2
      //    2 = 1/3
      //    3 = 1/4
      void setCntrlDiffTime ( unsigned char diffTime, bool writeEn=true );

      // Method to get shaper diff time value from Control Register
      // Set readEn to false to disable real read from KPIX, this flag allows
      // the user to get the currently set status without actually accessing
      // the device.
      unsigned char getCntrlDiffTime ( bool readEn=true );

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
      //                Values larger than 2890 will be treated as ns delay.
      //                Values less than or equal to 2890 will be treated as bunch count
      // pwrUpOn      - Power_up ACQ/DIG set on time in nS
      // deselDly     - Deselect/select sequence delay in nS
      // bunchClkDly  - Bunch clock start delay in nS
      // digDelay     - Delete between bunch clocks & digitization in nS
      // bunchCount   - Number of bunch crossings, 0 based count, 0-8191
      // enChecking   - Enable/disable timing sanity checks
      // Set writeEn to false to disable real write to KPIX
      // Set trigInhRaw to set raw trigger inhibit value
      void setTiming ( unsigned int clkPeriod,  unsigned int resetOn,
                       unsigned int resetOff,   unsigned int leakNullOff,
                       unsigned int offNullOff, unsigned int threshOff,
                       unsigned int trigInhOff, unsigned int pwrUpOn,
                       unsigned int deselDly,   unsigned int bunchClkDly,
                       unsigned int digDelay,   unsigned int bunchCount,
                       bool enChecking=true,    bool writeEn=true,
                       bool trigInhRaw=false);

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
      void getTiming ( unsigned int *clkPeriod,  unsigned int *resetOn,
                       unsigned int *resetOff,   unsigned int *leakNullOff,
                       unsigned int *offNullOff, unsigned int *threshOff,
                       unsigned int *trigInhOff, unsigned int *pwrUpOn,
                       unsigned int *deselDly,   unsigned int *bunchClkDly,
                       unsigned int *digDelay,   unsigned int *bunchCount,
                       bool readEn=true,         bool trigInhRaw=false );

      // Method to get trigger inhibit bucket
      unsigned int getTrigInh ( bool readEn=true, bool trigInhRaw=false );

      // Method to update KPIX calibration pulse settings
      // Pass the following values for update:
      // calCount     - Number of calibration pulses to assert, 0-4
      // cal0Delay    - Cal pulse 0 delay 0-2889 bunch clocks
      // cal1Delay    - Cal pulse 1 delay 0-2889 bunch clocks
      // cal2Delay    - Cal pulse 2 delay 0-2889 bunch clocks
      // cal3Delay    - Cal pulse 3 delay 0-2889 bunch clocks
      // Set writeEn to false to disable real write to KPIX
      void setCalibTime ( unsigned int calCount,  unsigned int cal0Delay,
                          unsigned int cal1Delay, unsigned int cal2Delay,
                          unsigned int cal3Delay, bool writeEn=true );

      // Method to read KPIX calibration pulse settings
      // Pass location pointers in which to store the following values:
      // calCount     - Number of calibration pulses to assert, 0-4
      // cal0Delay    - Cal pulse 0 delay 0-2889 bunch clocks
      // cal1Delay    - Cal pulse 1 delay 0-2889 bunch clocks
      // cal2Delay    - Cal pulse 2 delay 0-2889 bunch clocks
      // cal3Delay    - Cal pulse 3 delay 0-2889 bunch clocks
      // Set readEn to false to disable real read from KPIX
      void getCalibTime ( unsigned int *calCount,  unsigned int *cal0Delay,
                          unsigned int *cal1Delay, unsigned int *cal2Delay,
                          unsigned int *cal3Delay, bool readEn=true  );

      // Method to update KPIX Reset/Trigger Threshold A values
      // Pass the following values for update:
      // rstTholdA  - Range A reset threshold, 0x00-0xFF
      // trigTholdA - Range A trig  threshold, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacThreshRangeA ( unsigned char rstTholdA, unsigned char trigTholdA,
                                bool writeEn=true );

      // Method to read KPIX Reset/Trigger Threshold A values
      // Pass location pointers in which to store the following values:
      // rstTholdA  - Range A reset threshold, 0x00-0xFF
      // trigTholdA - Range A trig  threshold, 0x00-0xFF
      // Set readEn to false to disable real read from KPIX
      void getDacThreshRangeA ( unsigned char *rstTholdA, unsigned char *trigTholdA,
                                bool readEn=true );

      // Method to update KPIX Reset/Trigger Threshold B values
      // Pass the following values for update:
      // rstTholdB  - Range B reset threshold, 0x00-0xFF
      // trigTholdB - Range B trig  threshold, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacThreshRangeB ( unsigned char rstTholdB, unsigned char trigTholdB,
                                bool writeEn=true );

      // Method to read KPIX Reset/Trigger Threshold B values
      // Pass location pointers in which to store the following values:
      // rstTholdB  - Range B reset threshold, 0x00-0xFF
      // trigTholdB - Range B trig  threshold, 0x00-0xFF
      // Set readEn to false to disable real read from KPIX
      void getDacThreshRangeB ( unsigned char *rstTholdB, unsigned char *trigTholdB,
                                bool readEn=true );

      // Method to update KPIX calibration DAC value
      // Pass the following values for update:
      // calValue   - Calibration hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacCalib ( unsigned char calValue, bool writeEn=true );

      // Method to read KPIX calibration DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacCalib ( bool readEn=true );

      // Method to update KPIX Ramp Threshold DAC value
      // Pass the following values for update:
      // dacValue - DAC hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacRampThresh ( unsigned char dacValue, bool writeEn=true );

      // Method to read KPIX Ramp Threshold DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacRampThresh ( bool readEn=true );

      // Method to update KPIX Range Threshold DAC value
      // Pass the following values for update:
      // dacValue - DAC hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacRangeThresh ( unsigned char dacValue, bool writeEn=true );

      // Method to read KPIX Range Threshold DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacRangeThresh ( bool readEn=true );

      // Method to update KPIX Event Threshold Reference DAC value
      // Pass the following values for update:
      // dacValue - DAC hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacEventThreshRef ( unsigned char dacValue, bool writeEn=true );

      // Method to read KPIX Event Threshold Reference DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacEventThreshRef ( bool readEn=true );

      // Method to update KPIX Shaper Bias DAC value
      // Pass the following values for update:
      // dacValue - DAC hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacShaperBias ( unsigned char dacValue, bool writeEn=true );

      // Method to read KPIX Shaper Bias DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacShaperBias ( bool readEn=true );

      // Method to update KPIX Default Analog DAC value
      // Pass the following values for update:
      // dacValue - DAC hex value, 0x00-0xFF
      // Set writeEn to false to disable real write to KPIX
      void setDacDefaultAnalog ( unsigned char dacValue, bool writeEn=true );

      // Method to read KPIX Default Analog DAC value
      // Set readEn to false to disable real read from KPIX
      unsigned char getDacDefaultAnalog ( bool readEn=true );

      // Method to set channel mode according to a passed array
      // Pass array of integers (1024) to select the mode of
      // each channel. The modes enabled are CAL_A, TH_A, TH_B, DISABLE
      // If DISABLE is passed for a KPIX earlier than 6, TH_B will be selected.
      // Set writeEn to false to disable real write to KPIX
      void setChannelModeArray (unsigned int *modes, bool writeEn=true );

      // Method to update the passed array with the current mode of each channel
      // Pass array of integers (1024) to update. Each location will be updated
      // with one of the following values: CAL_A, TH_A, TH_B, DISABLE
      // Set readEn to false to disable real read from KPIX
      void getChannelModeArray ( unsigned int *modes, bool readEn=true );

      // Class Method To Convert DAC value to voltage
      static double dacToVolt(unsigned char dacValue );

      // Class Method To Convert DAC value to voltage
      static double dacToVolt(double dacValue);

      // Class Method To Convert DAC voltage to value
      static unsigned char voltToDac ( double dacVoltage );

      // Class Method to retrieve the current value of the calibration charge
      // For settings provided by external code.
      // Pass the following values
      // bucket    - Bucket number for conversion
      // calDac    - Calibration DAC value
      // posPixel  - State of posPixel flag
      // calibHigh - State of high range calibration flag
      static double computeCalibCharge ( unsigned char bucket, unsigned char calDac,
                                         bool posPixel,  bool calibHigh );

      // Method to retrieve the current value of the calibration charges
      // This method will determine the calibartion charge for each 
      // bucket based upon the current settings of the Kpix ASIC.
      // Pass 4 position array to store values
      void getCalibCharges ( double calCharge[] );

      // Deconstructor
      virtual ~KpixAsic ( );

      // Turn on or off debugging for the class
      void kpixDebug ( bool debug );

      // Get debug flag
      bool kpixDebug ( );

      // Return current KPIX Version
      unsigned short getVersion ( );

      // Return current KPIX Address
      unsigned short getAddress ( );

      // Return current KPIX Serial Number
      unsigned short getSerial ( );

      // Change KPIX Serial Number
      void setSerial ( unsigned short serial );

      // Set Defaults
      // Pass clock period to use
      void setDefaults ( unsigned int clkPeriod, bool writeEn = true );

      // Get Channel Count
      unsigned int getChCount();

#ifdef ONLINE_EN
      // Return SID Link Object Pointer
      SidLink * getSidLink ();
#endif

      // Read from all registers will debug enabled to display all of the current settings
      void dumpSettings ();

      ClassDef(KpixAsic,2)
};

#endif
