//-----------------------------------------------------------------------------
// File          : KpixGuiViewConfig.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the KPIX ASIC Configuration
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_VIEW_CONFIG_H__
#define __KPIX_GUI_VIEW_CONFIG_H__

#include "KpixGuiViewConfigForm.h"

// Forward declarations
class KpixGuiList;
class KpixGuiConfig;
class KpixGuiTiming;
class KpixGuiTrig;
class KpixGuiInject;
class KpixRunRead;


class KpixGuiViewConfig : public KpixGuiViewConfigForm {

      // Widgets In the Tabs
      KpixGuiList       *kpixGuiList;
      KpixGuiConfig     *kpixGuiConfig;
      KpixGuiTiming     *kpixGuiTiming;
      KpixGuiTrig       *kpixGuiTrig;
      KpixGuiInject     *kpixGuiInject;

   public:

      // Creation Class
      KpixGuiViewConfig ( );

      // Set Run Data
      void setRunData ( KpixRunRead *kpixRunRead);

};

#endif
