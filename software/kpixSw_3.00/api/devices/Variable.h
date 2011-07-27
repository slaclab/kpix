//-----------------------------------------------------------------------------
// File          : Variable.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic variable container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __VARIABLE_H__
#define __VARIABLE_H__

#include <string>
#include <vector>
#include <sys/types.h>
using namespace std;

//! Class to contain generic variable data.
class Variable {

      // Current variable value
      string value_;

      // Enum vector
      vector<string> values_;

   public:

      //! Constructor
      /*! 
       * \param  values vector of enum values
      */
      Variable ( vector<string> values );

      //! Constructor
      Variable ( );

      //! Get list of enums
      vector<string> getEnums();

      //! Method to get variable name
      string name ();

      //! Method to set variable value
      void set ( string value );

      //! Method to set variable register value
      void setReg ( uint value );

      //! Method to get variable value
      string get ( );

      //! Method to get variable register value
      uint getReg ( bool *ok );

};
#endif
