//-----------------------------------------------------------------------------
// File          : KpixAsic.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/17/2011
// Project       : Kpix ASIC
//-----------------------------------------------------------------------------
// Description :
// Kpix ASIC container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/17/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_ASIC_H__
#define __KPIX_ASIC_H__

#include <Device.h>
using namespace std;

//! Class to contain Kpix ASIC
class KpixAsic : public Device {

      // Kpix is dummy
      bool dummy_;

      // Kpix version
      uint version_;

   public:

      //! Constructor
      /*! 
       * \param destination Device destination
       * \param baseAddress Device base address
       * \param index       Device index
       * \param dummy       Kpix is a dummy device
      */
      KpixAsic ( uint destination, uint baseAddress, uint index, bool dummy );

      //! Deconstructor
      ~KpixAsic ( );

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
