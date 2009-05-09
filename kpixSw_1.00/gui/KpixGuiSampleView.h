//-----------------------------------------------------------------------------
// File          : KpixGuiSampleView.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class to view KPIX samples.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_SAMPLE_VIEW_H__
#define __KPIX_GUI_SAMPLE_VIEW_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiSampleViewForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixEventVar.h>
#include <KpixRunRead.h>
#include <KpixCalibRead.h>
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


class KpixGuiSampleView : public KpixGuiSampleViewForm {

      // Run Reader
      KpixRunRead   *kpixRunRead;
      KpixCalibRead *kpixCalibRead;

      // List of event variables
      KpixEventVar **eventVar;
      unsigned int eventCount;

      // Lookup Table For Kpix Index
      unsigned int *kpixIdxLookup;

   public:

      // Creation Class
      KpixGuiSampleView ( );

      // Desconstructor Class
      ~KpixGuiSampleView ( );

      // Set Run Data
      void setRunData ( KpixRunRead *kpixRunRead);

   public slots:

      void updateDisplay();

};

#endif
