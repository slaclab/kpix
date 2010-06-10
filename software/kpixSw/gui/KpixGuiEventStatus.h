//-----------------------------------------------------------------------------
// File          : KpixGuiEventStatus.h
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
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_EVENT_STATUS_H__
#define __KPIX_GUI_EVENT_STATUS_H__

#include <string>
#include <qevent.h>

#define KPIX_GUI_EVENT_STATUS 4000

class KpixGuiEventStatus : public QCustomEvent {

   public:

      // Constants To Define Update Type
      static const unsigned int StatusStart    = 1;
      static const unsigned int StatusPause    = 2;
      static const unsigned int StatusResume   = 3;
      static const unsigned int StatusDone     = 4;
      static const unsigned int StatusPrgMain  = 5;
      static const unsigned int StatusPrgSub   = 6;
      static const unsigned int StatusRun      = 7;
      static const unsigned int StatusMsg      = 8;
      
      // Method Variables
      unsigned int statusType;
      unsigned int prgValue;
      unsigned int prgTotal;
      unsigned int iterations;
      unsigned int rate;
      unsigned int triggers;
      std::string  statusMsg;

      // Pass Message & Progress
      KpixGuiEventStatus ( unsigned int statusType, std::string statusMsg, 
                           unsigned int prgValue,   unsigned int prgTotal );

      // Pass Progress
      KpixGuiEventStatus ( unsigned int statusType, 
                           unsigned int prgValue,   unsigned int prgTotal );

      // Pass Message
      KpixGuiEventStatus ( unsigned int statusType, std::string statusMsg );

      // Pass Message, ierations, rate & trigger count
      KpixGuiEventStatus ( unsigned int statusType, std::string statusMsg,
                           unsigned int iterations, unsigned int rate,
                           unsigned int triggers );

      // Pass Only Status Type
      KpixGuiEventStatus ( unsigned int statusType );

};

#endif
