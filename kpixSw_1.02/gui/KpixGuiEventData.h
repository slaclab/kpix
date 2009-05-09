//-----------------------------------------------------------------------------
// File          : KpixGuiEventData.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating plot update events.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_EVENT_DATA_H__
#define __KPIX_GUI_EVENT_DATA_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qevent.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TGraph.h>
#include <TGraph2D.h>
#include <KpixProgress.h>
using namespace std;

#define KPIX_GUI_EVENT_DATA 4003

class KpixGuiEventData : public QCustomEvent {

   public:

      void         **data;
      unsigned int id;
      unsigned int count;

      // Creation Class For Calib Plots
      KpixGuiEventData (unsigned int id, unsigned int count, void **data );

      // Deconstructor
      ~KpixGuiEventData();
};

#endif
