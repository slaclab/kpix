//-----------------------------------------------------------------------------
// File          : KpixGuiEventData.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating plot update events.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_EVENT_DATA_H__
#define __KPIX_GUI_EVENT_DATA_H__

#include <qevent.h>

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
