//-----------------------------------------------------------------------------
// File          : KpixGuiStatus.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX FPGA & ASIC Status
// This is a class which builds off of the class created in
// KpixGuiStatusForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_STATUS_H__
#define __KPIX_GUI_STATUS_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiStatusForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiStatus : public KpixGuiStatusForm {

      // ASIC & FPGA Containers
      unsigned int asicCnt;
      KpixAsic     **asic;
      KpixFpga     *fpga;

   public:

      // Creation Class
      KpixGuiStatus ( QWidget *parent = 0 );

      // Set FPGA
      void setAsics (KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga);

   private slots:

   public slots:

      void updateDisplay();
      void readStatus();

};

#endif
