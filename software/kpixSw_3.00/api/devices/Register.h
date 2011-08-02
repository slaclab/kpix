//-----------------------------------------------------------------------------
// File          : Register.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic register container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __REGISTER_H__
#define __REGISTER_H__

#include <string>
#include <sys/types.h>
using namespace std;

//! Class to contain generic register data.
class Register {

      // Register address
      uint address_;

      // Current register value
      uint value_;

      // Register writable
      bool writeEn_;

      // Register testable
      bool testEn_;

      // Register stale
      bool stale_;

   public:

      //! Constructor
      /*! 
       * \param address Register address
       * \param writeEn Register is writable
       * \param testEn Register is testable
      */
      Register ( uint address, bool writeEn, bool testEn );

      //! Method to get register address
      uint address ();

      //! Method to get register write enable state
      bool writeEn ();

      //! Method to get register test enable state
      bool testEn ();

      //! Method to get stale flag
      bool stale ();

      //! Method to force stale flag
      void setStale ();

      //! Method to clear stale flag
      void clrStale ();

      //! Method to set register value
      /*!
       * Update the shadow register with the new value. Optional start
       * bit and mask to set a field within the register. Register state
       * will be set to stale.
       * /param value register value
       * /param bit start bit for field
       * /param mask mask for field
      */
      void set ( uint value, uint bit=0, uint mask=0xFFFFFFFF );

      //! Method to get register value
      /*!
       * Return the value of the register as a whole or a field within
       * the register. Optional start bit and mask to set a field within 
       * the register.
       * /param bit start bit for field
       * /param mask mask for field
      */
      uint get ( uint bit=0, uint mask=0xFFFFFFFF );

      //! Method called when writing data to device. 
      /*! 
       * Returns register value and clears stale flag.
       */
      uint write ();

      //! Method called when reading data from device
      /*!
       * /param value Value read from device
       */
      void read (uint value);

      //! Method called when verifying register
      /*!
       * /param value Value read from device
       * Returns true if value matches
       */
      bool verify (uint value);

};
#endif
