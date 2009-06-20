//-----------------------------------------------------------------------------
// File          : KpixEventVar.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to store a KPIX event variable.
// This class is used to match a variable value stored in a KpixSample object
// to a variable name and description. The number stored in this class will
// correspnd to an index for an array of doubles in which the value is stored.
// All values will be stored as doubles. 
// This object can be stored in a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/18/2006: created
// 03/19/2007: Changed variables to root specific types.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <unistd.h>
#include <TString.h>
#include "KpixEventVar.h"
using namespace std;
using namespace sidApi::offline;

ClassImp(KpixEventVar)


// Variable class constructor
KpixEventVar::KpixEventVar ( ) {
   varNumber = 0;
   varName   = "";
   varName   = "";
}


// Variable class constructor
// Pass the following values for construction
// number    = Variable number
// name      = Variable name
// name      = Variable description
KpixEventVar::KpixEventVar (Int_t number, TString name, TString desc ) {
   varNumber = number; 
   varName   = name;
   varDesc   = desc;
}


// Return variable name
TString KpixEventVar::name () { return(varName); }


// Return variable description
TString KpixEventVar::description () { return(varDesc); }


// Return variable number
Int_t KpixEventVar::number () { return(varNumber); }


// Deconstructor
KpixEventVar::~KpixEventVar() {}
