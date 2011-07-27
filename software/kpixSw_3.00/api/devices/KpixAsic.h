//-----------------------------------------------------------------------------
// File          : KpixAsic.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Kpix ASIC container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_ASIC_H__
#define __KPIX_ASIC_H__

#include "Device.h"
using namespace std;

//! Class to contain generic device data.
class KpixAsic : public Device {

      // Version
      uint version_;

      // Dummy
      bool dummy_;

      // Process channel mode settings
      string writeChanMode();
      void   readChanMode();

      // Process timing settings
      string writeTiming();
      void   readTiming();

      // Process DAC settings
      string writeDacs();
      void   readDacs();

      // Process calib settings
      string writeCalib();
      void   readCalib();

      // Process config settings
      string writeConfig();
      void   readConfig();

      // Process control settings
      string writeControl();
      void   readControl();

      // Process status
      void readStatus();

      // Method To Convert DAC Value To Voltage
      static string dacToVolt(string dacValue);

      // Update DAC voltages
      void updateDacVoltages();

      // Update calibration charge
      void updateCalibCharge();

      // Update temperature value
      void updateTemperature();

   public:

      //! Constructor
      /*! 
       * \param address KpixAsic address
      */
      KpixAsic ( uint version, uint address, bool dummy );

      //! Deconstructor
      ~KpixAsic ( );

      //! Method to read variables from registers
      /*! 
       * Return string containing variables in XML format
      */
      string read();

      //! Method to write variables to registers
      /*! 
       * /param xml Optional string containing variable settings in XML format
      */
      string write( string xml = "");

      //! Return version
      uint version();

      //! Dummy status
      bool dummy();

      //! Channel count
      uint channels();
};
#endif
