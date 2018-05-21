//-----------------------------------------------------------------------------
// File          : KpixGuiViewConfig.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the KPIX ASIC Configuration
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <qtabwidget.h>
#include "KpixGuiConfig.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"
#include "KpixGuiInject.h"
#include "KpixGuiList.h"
#include "KpixGuiConfig.h"
#include "KpixGuiTiming.h"
#include "KpixGuiTrig.h"
#include "KpixGuiInject.h"
#include <KpixRunRead.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include "KpixGuiViewConfig.h"
using namespace std;


// Constructor
KpixGuiViewConfig::KpixGuiViewConfig ( ) : KpixGuiViewConfigForm() { 
   kpixGuiList   = new KpixGuiList(this);
   kpixGuiConfig = new KpixGuiConfig(this);
   kpixGuiTiming = new KpixGuiTiming(0,this);
   kpixGuiTrig   = new KpixGuiTrig(this);
   kpixGuiInject = new KpixGuiInject(this);

   // Fill in the tabs
   kpixTabs->insertTab(kpixGuiList,"List",0);
   kpixTabs->insertTab(kpixGuiConfig,"Config",1);
   kpixTabs->insertTab(kpixGuiTiming,"Timing",2);
   kpixTabs->insertTab(kpixGuiTrig,"Trigger",3);
   kpixTabs->insertTab(kpixGuiInject,"Inject",4);
   kpixTabs->removePage(deleteTab);
   kpixTabs->setCurrentPage(0);

   // Disable
   kpixGuiConfig->setEnabled(false,false);
   kpixGuiTiming->setEnabled(false,false);
   kpixGuiTrig->setEnabled(false);
   kpixGuiInject->setEnabled(false);
}


// Update calib Data
void KpixGuiViewConfig::setRunData(KpixRunRead *kpixRunRead) { 

   if ( kpixRunRead == NULL ) {
      kpixGuiList->setRunRead(NULL);
      kpixGuiConfig->setAsics(NULL,0);
      kpixGuiTiming->setAsics(NULL,0,NULL);
      kpixGuiTrig->setAsics(NULL,0,NULL);
      kpixGuiInject->setAsics(NULL,0);
   } else {
      unsigned int asicCnt = kpixRunRead->getAsicCount();
      KpixAsic **asic      = kpixRunRead->getAsicList();
      KpixFpga *fpga       = kpixRunRead->getFpga();

      // Create Sub Windows
      kpixGuiList->setRunRead(kpixRunRead);
      kpixGuiConfig->setAsics(asic,asicCnt);
      kpixGuiTiming->setAsics(asic,asicCnt,fpga);
      kpixGuiTrig->setAsics(asic,asicCnt,fpga);
      kpixGuiInject->setAsics(asic,asicCnt);

      // Update display
      kpixGuiConfig->updateDisplay();
      kpixGuiTiming->updateDisplay();
      kpixGuiTrig->updateDisplay();
      kpixGuiInject->updateDisplay();
   }
}


