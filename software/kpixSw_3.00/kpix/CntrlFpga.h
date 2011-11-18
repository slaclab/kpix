//-----------------------------------------------------------------------------
// File          : CntrlFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Heavy Photon Tracker
//-----------------------------------------------------------------------------
// Description :
// Control FPGA container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __CNTRL_FPGA_H__
#define __CNTRL_FPGA_H__

#include <Device.h>
using namespace std;

//! Class to contain APV25 
class CntrlFpga : public Device {

   public:

      //! Constructor
      /*! 
       * \param destination Device destination
       * \param index       Device index
      */
      CntrlFpga ( uint destination, uint index );

      //! Deconstructor
      ~CntrlFpga ( );

      //! Method to process a command
      /*!
       * Returns status string if locally processed. Otherwise
       * an empty string is returned.
       * \param name     Command name
       * \param arg      Optional arg
      */
      string command ( string name, string arg );

      //! Method to read status registers and update variables
      /*! 
       * Throws string on error.
       * \param subEnable Read registers in sub devices if true
      */
      void readStatus ( bool subEnable );

      //! Method to read configuration registers and update variables
      /*! 
       * Throws string on error.
       * \param subEnable Read registers in sub devices if true
      */
      void readConfig ( bool subEnable );

      //! Method to write configuration registers
      /*! 
       * Throws string on error.
       * \param force Write all registers if true, only stale if false
       * \param subEnable Write registers in sub devices if true
      */
      void writeConfig ( bool force, bool subEnable );

      //! Verify hardware state of configuration
      /*!
       * Returns list of failed registers if any
       * \param subEnable Write registers in sub devices if true
       * \param input     Input fail list from child-object
       */
      string verifyConfig ( bool subEnable, string input );

};
#endif
