//-----------------------------------------------------------------------------
// File          : KpixGuiError.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for showing KPIX API errors.
// This is a class which builds off of the class created in
// KpixGuiErrorForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qtextedit.h>
#include "KpixGuiError.h"
using namespace std;


// Constructor
KpixGuiError::KpixGuiError ( QWidget *parent ) : KpixGuiErrorForm(parent) { }


// Show
void KpixGuiError::showMessage(string error) { 
   errorBox->setText(error);
   KpixGuiErrorForm::show();
}


