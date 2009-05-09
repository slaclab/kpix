//-----------------------------------------------------------------------------
// File          : KpixGuiEventRun.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating run update events to main thread.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
//-----------------------------------------------------------------------------

#include "KpixGuiEventRun.h"
using namespace std;

// Constructor
KpixGuiEventRun::KpixGuiEventRun ( bool runStart, bool runStop, string statusMsg,
                                   unsigned int prgCurrent, unsigned int prgTotal,
                                   unsigned int totCurrent, unsigned int totTotal ) : 
                                   QCustomEvent ( KPIX_GUI_EVENT_RUN ) {

   this->runStart   = runStart;
   this->runStop    = runStop;
   this->statusMsg  = statusMsg;
   this->prgCurrent = prgCurrent;
   this->prgTotal   = prgTotal;
   this->totCurrent = totCurrent;
   this->totTotal   = totTotal;
}


