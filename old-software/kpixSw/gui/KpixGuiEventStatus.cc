//-----------------------------------------------------------------------------
// File          : KpixGuiEventStatus.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating status events to main thread.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
//-----------------------------------------------------------------------------

#include "KpixGuiEventStatus.h"
using namespace std;


// Pass Message & Progress
KpixGuiEventStatus::KpixGuiEventStatus ( unsigned int statusType, string statusMsg, 
                                         unsigned int prgValue,   unsigned int prgTotal ) :
                                         QCustomEvent ( KPIX_GUI_EVENT_STATUS ) {

   this->statusType = statusType;
   this->prgValue   = prgValue;
   this->prgTotal   = prgTotal;
   this->iterations = 0;
   this->rate       = 0;
   this->triggers   = 0;
   this->statusMsg  = statusMsg;
}


// Pass Progress
KpixGuiEventStatus::KpixGuiEventStatus ( unsigned int statusType, 
                                         unsigned int prgValue,   unsigned int prgTotal ) :
                                         QCustomEvent ( KPIX_GUI_EVENT_STATUS ) {
   this->statusType = statusType;
   this->prgValue   = prgValue;
   this->prgTotal   = prgTotal;
   this->iterations = 0;
   this->rate       = 0;
   this->triggers   = 0;
   this->statusMsg  = "";

}


// Pass Message
KpixGuiEventStatus::KpixGuiEventStatus ( unsigned int statusType, string statusMsg ) :
                                         QCustomEvent ( KPIX_GUI_EVENT_STATUS ) {
   this->statusType = statusType;
   this->prgValue   = 0;
   this->prgTotal   = 0;
   this->iterations = 0;
   this->rate       = 0;
   this->triggers   = 0;
   this->statusMsg  = statusMsg;
}


// Pass Message, ierations, rate & trigger count
KpixGuiEventStatus::KpixGuiEventStatus ( unsigned int statusType, string statusMsg,
                                         unsigned int iterations, unsigned int rate,
                                         unsigned int triggers ) :
                                         QCustomEvent ( KPIX_GUI_EVENT_STATUS ) {
   this->statusType = statusType;
   this->prgValue   = 0;
   this->prgTotal   = 0;
   this->iterations = iterations;
   this->rate       = rate;
   this->triggers   = triggers;
   this->statusMsg  = statusMsg;


}


// Pass Only Status Type
KpixGuiEventStatus::KpixGuiEventStatus ( unsigned int statusType ) :
                                         QCustomEvent ( KPIX_GUI_EVENT_STATUS ) {
   this->statusType = statusType;
   this->prgValue   = 0;
   this->prgTotal   = 0;
   this->iterations = 0;
   this->rate       = 0;
   this->triggers   = 0;
   this->statusMsg  = "";
}


