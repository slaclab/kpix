//-----------------------------------------------------------------------------
// File          : KpixGuiEventRun.h
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
#ifndef __KPIX_GUI_EVENT_RUN_H__
#define __KPIX_GUI_EVENT_RUN_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qevent.h>
using namespace std;

#define KPIX_GUI_EVENT_RUN 4000

class KpixGuiEventRun : public QCustomEvent {

   public:

      unsigned int prgCurrent;
      unsigned int prgTotal;
      unsigned int totCurrent;
      unsigned int totTotal;
      string       statusMsg;
      bool         runStart;
      bool         runStop;

      // Creation Class
      KpixGuiEventRun ( bool runStart, bool runStop, string statusMsg, 
                        unsigned int prgCurrent, unsigned int prgTotal,
                        unsigned int totCurrent, unsigned int totTotal
                        );

};

#endif
