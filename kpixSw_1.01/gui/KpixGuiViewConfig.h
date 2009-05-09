//-----------------------------------------------------------------------------
// File          : KpixGuiViewConfig.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the KPIX ASIC Configuration
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_VIEW_CONFIG_H__
#define __KPIX_GUI_VIEW_CONFIG_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiViewConfigForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <SidLink.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qerrormessage.h>
#include <qtable.h>
#include <qspinbox.h>
#include "KpixGuiInject.h"
#include "KpixGuiConfig.h"
#include "KpixGuiError.h"
#include "KpixGuiList.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"


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
