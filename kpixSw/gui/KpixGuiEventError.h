//-----------------------------------------------------------------------------
// File          : KpixGuiEventError.h
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
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_EVENT_ERROR_H__
#define __KPIX_GUI_EVENT_ERROR_H__

#include <string>
#include <qevent.h>

#define KPIX_GUI_EVENT_ERROR 4001

class KpixGuiEventError : public QCustomEvent {

   public:

      std::string errorMsg;

      // Creation Class
      KpixGuiEventError ( std::string errorMsg );
};

#endif
