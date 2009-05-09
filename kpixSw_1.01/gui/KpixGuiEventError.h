//-----------------------------------------------------------------------------
// File          : KpixGuiEventError.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating error events to main thread.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_EVENT_ERROR_H__
#define __KPIX_GUI_EVENT_ERROR_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qevent.h>
using namespace std;

#define KPIX_GUI_EVENT_ERROR 4001

class KpixGuiEventError : public QCustomEvent {

   public:

      string       errorMsg;

      // Creation Class
      KpixGuiEventError ( string errorMsg );
};

#endif
