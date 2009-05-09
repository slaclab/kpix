//-----------------------------------------------------------------------------
// File          : if_test.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/07/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for simple interface test.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <sstream>
#include <string>
#include <TROOT.h>
#include <TRint.h>
using namespace std;

int main ( int argc, char **argv ) {

    // Create interactive interface
    TRint *theApp = new TRint("ROOT example", &argc, argv, NULL, 0);

    // Run interactive interface
    theApp->Run();

    return(0);
}
