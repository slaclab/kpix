//-----------------------------------------------------------------------------
// File          : Variable.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic variable container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------

#include "Variable.h"
#include <sstream>
using namespace std;

//! Constructor
Variable::Variable ( ) {
   value_   = "";
   values_ .clear();
}

//! Constructor
Variable::Variable ( vector<string> values ) {
   value_   = "";
   values_  = values;
}

//! Get list of enums
vector<string> Variable::getEnums() {
   return(values_);
}

//! Method to set variable value
void Variable::set ( string value ) {
   value_ = value;
}

//! Method to set variable register value
void Variable::setReg ( uint value ) {
   if ( value < values_.size() ) value_ = values_.at(value);
   else value_ = value;
}

//! Method to get variable value
string Variable::get ( ) {
   return(value_);
}

//! Method to get variable register value
uint Variable::getReg (bool *ok) {
   *ok = true;
   if ( values_.size() != 0 ) {
      for (uint x; x < values_.size(); x++) {
         if (value_ == values_.at(x)) return(x);
      }
      *ok = false;
      return(0);
   }
   else {
      return((uint)atoi(value_.c_str()));
   }
}

