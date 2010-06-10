//-----------------------------------------------------------------------------
// File          : AdcFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 07/06/2009
//-----------------------------------------------------------------------------
// Description :
// ADC Test FPGA drive code.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/06/2009: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_FPGA_H__
#define __KPIX_FPGA_H__

#include <string>

class SidLink;


class AdcFpga {

      // Link object
      SidLink *sidLink;

      // Private method to write register value to Fpga
      void regWrite (unsigned int address, unsigned int data);

      // Private method to read register value from Fpga
      unsigned int regRead (unsigned int address);

   public:

      // Kpix FPGA Constructor
      // Pass SID Link Object
      AdcFpga ( SidLink *sidLink );

      // Method to get FPGA Version
      unsigned int getVersion ( );

      // Method to set ADC select flag
      void setAdcSelect ( unsigned int adcSel );

      // Method to get ADC select flag
      unsigned int getAdcSelect ( );

      // Method to get ADC value and generate an iteration
      unsigned int getAdcValue ( bool debug=false );
};
#endif
