//-----------------------------------------------------------------------------
// File          : KpixGuiInject.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Injection Settings.
// This is a class which builds off of the class created in
// KpixGuiInjectForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_INJECT_H__
#define __KPIX_GUI_INJECT_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiInjectForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiInject : public KpixGuiInjectForm {

      // ASIC & FPGA Containers
      unsigned int asicCnt;
      KpixAsic     **asic;

   public:

      // Creation Class
      KpixGuiInject ( QWidget *parent = 0 );

      // Set Asics
      void setAsics( KpixAsic **asic, unsigned int asicCnt );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

   private slots:

      void dacValueChanged();

   public slots:

      void readConfig(bool readEn);
      void writeConfig(bool writeEn);

};

#endif
