//-----------------------------------------------------------------------------
// File          : KpixGuiList.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the list of KPIX ASICs
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_LIST_H__
#define __KPIX_GUI_LIST_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiListForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixRunRead.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>


class KpixGuiList : public KpixGuiListForm {

   public:

      // Creation Class
      KpixGuiList ( QWidget *parent = 0 );

      // Set Run Read
      void setRunRead ( KpixRunRead *kpixRunRead );

};

#endif
