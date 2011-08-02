//-----------------------------------------------------------------------------
// File          : KpixFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Kpix FPGA container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_FPGA_H__
#define __KPIX_FPGA_H__

#include "Device.h"
using namespace std;

//! Class to contain generic device data.
class KpixFpga : public Device {

      // Version
      uint version_;

   public:

      //! Constructor
      /*! 
       * \param address KpixFpga address
      */
      KpixFpga ( uint version );

      //! Deconstructor
      ~KpixFpga ( );

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

      //! Set Master Reset
      void setMasterReset();

      //! Set KPIX Reset
      void setKpixReset();

      //! Set Counter Reset
      void setCountReset();
};
#endif
