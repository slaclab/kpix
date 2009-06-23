//-----------------------------------------------------------------------------
// File          : KpixRunVar.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to store a KPIX run variable.
// All values will be stored as Double_ts. 
// This object can be stored in a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/18/2006: created
// 03/19/2007: Changed variables to root specific types.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <TString.h>
#include <unistd.h>
#include "KpixRunVar.h"
using namespace std;

ClassImp(KpixRunVar)


// Variable class constructor
KpixRunVar::KpixRunVar ( ) {
   varName  = "";
   varDesc  = "";
   varValue = 0.0;
}


// Variable class constructor
// Pass the following values for construction
// name      = Variable name
// desc      = Variable description
// value     = Variable value
KpixRunVar::KpixRunVar ( TString name, TString desc, Double_t value ) {
   varName  = name;
   varDesc  = desc;
   varValue = value;
}


// Return variable name
TString KpixRunVar::name () { return(varName); }


// Return variable description
TString KpixRunVar::description () { return(varDesc); }


// Return variable value
Double_t KpixRunVar::value () { return(varValue); }


// Set variable value
void KpixRunVar::value ( Double_t value ) { varValue = value; }


// Deconstructor
KpixRunVar::~KpixRunVar() {}
