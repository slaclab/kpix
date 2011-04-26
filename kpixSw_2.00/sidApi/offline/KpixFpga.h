//-----------------------------------------------------------------------------
// File          : KpixFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/30/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class for managing the KPIX FPGA. This class is used for
// register access & command control. This class contains individual functions
// which hide the details of the individual registers and differences
// between FPGA versions. Direct register access is still possible using the
// pubilic fpgaRegister array.
// This class can be serialized into a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/30/2007: created
// 07/24/2007: Added support for USB delay.
// 08/07/2007: Added auto run type flag, added support for external run start
//             signal.
// 08/12/2007: Added temperature readback
// 08/13/2007: Added trigger accept input selection
// 09/19/2007: Added raw data control flag
// 10/11/2007: Added select polarity flag
// 12/17/2007: Added reset pulse extension
// 09/26/2008: Added method to set FPGA defaults.
// 10/23/2008: Added method to set sidLink object.
// 02/06/2009: Added methods to set digization and readout clocks & Kpix Version
// 04/29/2009: Added readEn flag to some read calls.
// 05/13/2009: Changed name of accept source to extRecord 
// 05/13/2009: Removed auto train generation logic.
// 06/18/2009: Added namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_FPGA_H__
#define __KPIX_FPGA_H__

#include <string>
#include <TObject.h>


#ifdef ONLINE_EN
namespace sidApi {
   namespace online {
      class SidLink;
   }
}
#endif


namespace sidApi {
   namespace offline {
      class KpixFpga : public TObject {

            // Register values & configuration
            unsigned int  regData[0x40];      // Show data
            bool          regWriteable[0x40]; // Register is writable
            bool          regReset[0x40];     // Register is a reset on write register

            // Debug flag
            bool enDebug;

            // Valid flag
            bool valid;

#ifdef ONLINE_EN
            // Link object
            sidApi::online::SidLink *sidLink; //! Root:Don't stream link object to file
#else
            void    *sidLink; //! Root:Don't stream link object to file
#endif

            // Private method to write register value to Fpga
            void regWrite (unsigned char address);

            // Private method to read register value from Fpga
            void regRead (unsigned char address);

         public:

            // Kpix FPGA Constructor
            KpixFpga ( );

#ifdef ONLINE_EN
            // Kpix FPGA Constructor
            // Pass SID Link Object
            KpixFpga ( sidApi::online::SidLink *sidLink );

            // Set SID Link
            void setSidLink ( sidApi::online::SidLink *sidLink );
#endif

            // Send master reset command to FPGA
            // This command will reset the entire device include
            // the clock generation logic of the FPGA
            void cmdResetMst ( );

            // Send reset command to KPIX logic
            // This command will reset the Kpix interface logic and
            // all registers except for the clock generation register
            void cmdResetKpix ( );

            // Method to set register value
            // Pass the following values
            // address = Register address
            // value   = 32-Bit register value
            // writeEn = Flag to perform actual write
            void regSetValue ( unsigned char address, unsigned int value, bool writeEn=true );

            // Method to get register value
            // Pass the following values
            // address = Register address
            // read    = Flag to perform actual write
            unsigned int regGetValue ( unsigned char address, bool readEn=true );

            // Method to set register bit
            // Pass the following values
            // address = Register address
            // bit     = Bit to set
            // value   = Value to set, true or false
            // writeEn = Flag to perform actual write
            void regSetBit ( unsigned char address, unsigned char bit, bool value, bool writeEn=true);

            // Method to get register bit
            // Pass the following values
            // address = Register address
            // bit     = Bit to get
            // read    = Flag to perform actual write
            bool regGetBit ( unsigned char address, unsigned char bit, bool readEn=true);

            // Method to return register name
            // Pass the register address
            std::string regGetName ( unsigned char address );

            // Method to return register writable flag
            // Pass the register address
            bool regGetWriteable ( unsigned char address );

            // Method to return register reset on write flag
            // Pass the register address
            bool regGetReset ( unsigned char address );

            // Method to get FPGA Version
            unsigned int getVersion ( bool readEn = true );

            // Method to get FPGA Jumper Inputs.
            unsigned short getJumpers ( bool readEn = true );

            // Method to set FPGA scratchpad register contents.
            // Default value = 0x00000000
            // Pass integer data
            // Set writeEn to false to disable real write to KPIX
            void setScratchPad ( unsigned int value, bool writeEn=true );

            // Method to get FPGA scratchpad register contents.
            // Set readEn to false to disable real read from FPGA.
            unsigned int getScratchPad ( bool readEn=true );

            // Method to set FPGA clock control register.
            // Default value = 50ns (20Mhz)
            // Pass value containing the desired clock period. Valid values are
            // multiples of 10ns from 10ns to 320 ns.
            // Set writeEn to false to disable real write to KPIX
            void setClockPeriod ( unsigned short period, bool writeEn=true );

            // Method to set FPGA clock period.
            // Set readEn to false to disable real read from FPGA.
            unsigned short getClockPeriod ( bool readEn=true );

            // Method to set FPGA digiization clock register.
            // Default value = 50ns (20Mhz)
            // Pass value containing the desired clock period. Valid values are
            // multiples of 10ns from 10ns to 320 ns.
            // Set writeEn to false to disable real write to KPIX
            void setClockPeriodDig ( unsigned short period, bool writeEn=true );

            // Method to set FPGA digitization clock period.
            // Set readEn to false to disable real read from FPGA.
            unsigned short getClockPeriodDig ( bool readEn=true );

            // Method to set FPGA readout clock register.
            // Default value = 50ns (20Mhz)
            // Pass value containing the desired clock period. Valid values are
            // multiples of 10ns from 10ns to 320 ns.
            // Set writeEn to false to disable real write to KPIX
            void setClockPeriodRead ( unsigned short period, bool writeEn=true );

            // Method to set FPGA readout clock period.
            // Set readEn to false to disable real read from FPGA.
            unsigned short getClockPeriodRead ( bool readEn=true );

            // Method to get FPGA receive checksum error counter
            // Set readEn to false to disable real read from FPGA.
            unsigned char getCheckSumErrors ( bool readEn=true );

            // Method to reset FPGA receive checksum error counter
            void cmdRstCheckSumErrors ();

            // Method to set BNC A output source.
            // Default value = 0 (RegClock)
            // Valid range of values are 0 - 31
            // Pass source index.
            //  0x0 = RegClock
            //  0x1 = RegSel1
            //  0x2 = RegSel0
            //  0x3 = PwrUpAcq
            //  0x4 = ResetLoad
            //  0x5 = LeakageNull
            //  0x6 = OffsetNull
            //  0x7 = ThreshOff
            //  0x8 = TrigInh
            //  0x9 = CalStrobe
            // 0x0A = PwrUpAcqDig
            // 0x0B = SelCell
            // 0x0C = DeselAllCells
            // 0x0D = RampPeriod
            // 0x0E = PrechargeBus
            // 0x0F = RegData
            // 0x10 = RegWrEn
            // 0x11 = KpixClk
            // 0x12 = ForceTrig
            // 0x13 = TrigEnable
            // 0x14 = CalStrobeDelay
            // 0x15 = NIM A Input
            // 0x16 = NIM B Input
            // 0x17 = BNC A Input
            // 0x18 = BNC B Input
            // 0x19 = Bunch Clock Phase
            // Set writeEn to false to disable real write to KPIX
            void setBncSourceA ( unsigned char  value, bool writeEn=true );

            // Method to get BNC A output source.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getBncSourceA ( bool readEn=true );

            // Method to set BNC B output source.
            // Default value = 0 (RegClock)
            // Valid range of values are 0 - 31
            // Pass source index. Same as above
            // Set writeEn to false to disable real write to KPIX
            void setBncSourceB ( unsigned char value, bool writeEn=true );

            // Method to get BNC B output source.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getBncSourceB ( bool readEn=true );

            // Method to set Drop Data Flag, this drops all received data.
            // Default value = False
            // Set writeEn to false to disable real write to KPIX
            void setDropData ( bool value, bool writeEn=true );

            // Method to get Drop Data Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getDropData ( bool readEn=true );

            // Method to set Kpix Version Flag. false = 0-7, true = 8+
            // Default value = False
            // Set writeEn to false to disable real write to KPIX
            void setKpixVer ( bool value, bool writeEn=true );

            // Method to get Kpix Version Flag, false = 0-7, true = 8+
            // Set readEn to false to disable real read from FPGA.
            bool getKpixVer ( bool readEn=true );

            // Method to set Raw Data Flag.
            // Default value = False
            // Set writeEn to false to disable real write to KPIX
            void setRawData ( bool value, bool writeEn=true );

            // Method to get Raw Data Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getRawData ( bool readEn=true );

            // Method to set Kpix A Disable Flag. (Kpix Address 0)
            // Default value = True
            // Set writeEn to false to disable real write to KPIX
            void setDisKpixA ( bool value, bool writeEn=true );

            // Method to get Kpix A Disable Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getDisKpixA ( bool readEn=true );

            // Method to set Kpix B Disable Flag. (Kpix Address 1)
            // Default value = True
            // Set writeEn to false to disable real write to KPIX
            void setDisKpixB ( bool value, bool writeEn=true );

            // Method to get Kpix B Disable Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getDisKpixB ( bool readEn=true );

            // Method to set Kpix C Disable Flag. (Kpix Address 2)
            // Default value = True
            // Set writeEn to false to disable real write to KPIX
            void setDisKpixC ( bool value, bool writeEn=true );

            // Method to get Kpix C Disable Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getDisKpixC ( bool readEn=true );

            // Method to set Kpix D Disable Flag. (Kpix Address 3)
            // Default value = True
            // Set writeEn to false to disable real write to KPIX
            void setDisKpixD ( bool value, bool writeEn=true );

            // Method to get Kpix D Disable Flag.
            // Set readEn to false to disable real read from FPGA.
            bool getDisKpixD ( bool readEn=true );

            // Method to get KPIX response parity error counter.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getRspParErrors (bool readEn = true );

            // Method to get KPIX data parity error counter.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getDataParErrors (bool readEn = true );

            // Method to reset KPIX response/data parity error counters.
            void cmdRstParErrors ();

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
            void setExtRunSource ( unsigned char value, bool writeEn=true );

            // Method to get source for external run trigger
            // Set readEn to false to disable real read from FPGA.
            unsigned char getExtRunSource ( bool readEn=true );

            // Method to set delay in clock counts between external
            // trigger signal and sending of acquisition command.
            // Valid values are 0-65535
            // Default value = 0 None.
            // Set writeEn to false to disable real write to KPIX
            void setExtRunDelay ( unsigned short value, bool writeEn=true );

            // Method to get delay in clock counts between external
            // trigger signal and sending of acquisition command.
            // Set readEn to false to disable real read from FPGA.
            unsigned short getExtRunDelay ( bool readEn=true );

            // Method to choose external train type, True=Calibrate, False=Acquire
            // Default value = False
            // Set writeEn to false to disable real write to KPIX
            void setExtRunType ( bool value, bool writeEn=true );

            // Method to get auto train type flag.
            // Set readEn to false to disable real read from FPGA.
            bool getExtRunType ( bool readEn=true );

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
            void setExtRecord ( unsigned char value, bool writeEn=true );

            // Method to get source for external records.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getExtRecord ( bool readEn=true );

            // Method to set external trigger enable windows
            // Pass bit mask (8-bits) to define which portions of the bunch
            // clock period are enabled for external trigger. Each bit 
            // represents on clock period.
            // Default value = 0x00
            // Set writeEn to false to disable real write to KPIX
            void setTrigEnable ( unsigned char mask, bool writeEn=true );

            // Method to get external trigger enable windows
            // Set readEn to false to disable real read from FPGA.
            unsigned char getTrigEnable ( bool readEn=true );

            // Method to set the number of clock periods to expand the
            // force trigger signal. Set to 0 for no expansion. 
            // Valid values are 0-255
            // Default value = 0
            // Set writeEn to false to disable real write to KPIX
            void setTrigExpand ( unsigned char count, bool writeEn=true );

            // Method to get the number of clock periods to expand the
            // force trigger signal. Set to 0 for no expansion. 
            // Set readEn to false to disable real read from FPGA.
            unsigned char getTrigExpand ( bool readEn=true );

            // Method to set the number of clock periods to expand the
            // cal_strobe signal for the CalStrobeDelay signal.
            // Starting Delay is 1 clock for a value of 0.
            // Valid values are 0-255
            // Default value = 0
            // Set writeEn to false to disable real write to KPIX
            void setCalDelay ( unsigned char count, bool wrteEn=true );

            // Method to get the number of clock periods to expand the
            // cal_strobe signal for the CalStrobeDelay signal.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getCalDelay ( bool readEn=true );

            // Method to set the force trigger source.
            // Valid values are 0-15
            // Default value = 0 None.
            // Pass source index.
            //  0x0 = None.
            //  0x1 = CalStrobe from internal core
            //  0x2 = NIMA Input
            //  0x3 = NIMB Input
            //  0x4 = BncA Input
            //  0x5 = BncB Input
            //  0x6 = NIMA Input, Masked by trigger window
            //  0x7 = NIMB Input, Masked by trigger window
            //  0x8 = BncA Input, Masked by trigger window
            //  0x9 = BncB Input, Masked by trigger window
            //  0xA = CalStrobeDelay
            // Set writeEn to false to disable real write to KPIX
            void setTrigSource ( unsigned char value, bool writeEn=true );

            // Method to get BNC B output source.
            // Set readEn to false to disable real read from FPGA.
            unsigned char getTrigSource ( bool readEn=true );

            // Method to get KPIX train number value.
            // Set readEn to false to disable real read from FPGA.
            unsigned int getTrainNumber ( bool readEn=false );

            // Method to reset KPIX train number value.
            void cmdRstTrainNumber ();

            // Method to get KPIX dead time counter.
            // Set readEn to false to disable real read from FPGA.
            unsigned short getDeadCount ( bool readEn=true );

            // Method to reset KPIX dead time counter.
            void cmdRstDeadCount ();

            // Deconstructor
            virtual ~KpixFpga ( );

            // Turn on or off debugging for the class
            void fpgaDebug ( bool debug );

            // Get debug flag
            bool fpgaDebug ( );

            // Get valid flag
            bool getValid ( );

            // Set Defaults
            void setDefaults ( unsigned int clkPeriod, bool kpixVer=false, bool writeEn=true );

#ifdef ONLINE_EN
            // Return SID Link Object Pointer
            sidApi::online::SidLink * getSidLink ();
#endif

            // Read from all registers will debug enabled to display all of the current settings
            void dumpSettings ();

            ClassDef(KpixFpga,1)
      };
   }
}
#endif