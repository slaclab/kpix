//-----------------------------------------------------------------------------
// File          : KpixGuiEventError.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating error events to main thread.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------

#include "KpixGuiEventError.h"
using namespace std;

// Constructor
KpixGuiEventError::KpixGuiEventError ( string errorMsg ) :
                                   QCustomEvent (KPIX_GUI_EVENT_ERROR) {

   this->errorMsg  = errorMsg;
}


