//-----------------------------------------------------------------------------
// File          : root_sidapi.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/07/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for compiling root executable with sidApi library support.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 06/22/2009: Moved to root directory.
//-----------------------------------------------------------------------------
#include <iostream>
#include <sstream>
#include <string>
#include <TROOT.h>
#include <TRint.h>
using namespace std;

int main ( int argc, char **argv ) {

    // Create interactive interface
    TRint *theApp = new TRint("SidAPI Root", &argc, argv, NULL, 0);

    // Run interactive interface
    theApp->Run();

    return(0);
}
