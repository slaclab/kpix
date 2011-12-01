//-----------------------------------------------------------------------------
// File          : KpixControl.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/20/2011
// Project       : KPIX Asic
//-----------------------------------------------------------------------------
// Description :
// KpixControl Top Device
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/20/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_CONTROL_H__
#define __KPIX_CONTROL_H__

#include <System.h>
using namespace std;

//! Class to contain APV25 
class KpixControl : public System {

   public:

      //! Constructor
      KpixControl ( );

      //! Deconstructor
      ~KpixControl ( );

      //! Method to process a command
      /*!
       * Returns status string if locally processed. Otherwise
       * an empty string is returned.
       * Throws string on error
       * \param name     Command name
       * \param arg      Optional arg
      */
      virtual void command ( string name, string arg );

      //! Method to return state string
      string getState ( );

      //! Method to perform soft reset
      void softReset ( );

      //! Method to perform hard reset
      void hardReset ( );

};
#endif
