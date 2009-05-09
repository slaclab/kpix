//-----------------------------------------------------------------------------
// File          : KpixGuiTiming.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Timing Settings.
// This is a class which builds off of the class created in
// KpixGuiTimingForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_TIMING_H__
#define __KPIX_GUI_TIMING_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiTimingForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qlabel.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiTiming : public KpixGuiTimingForm {

      // ASIC & FPGA Containers
      unsigned int asicCnt;
      KpixAsic     **asic;
      KpixFpga     *fpga;

   public:

      // Creation Class
      KpixGuiTiming ( unsigned int rateLimit, QWidget *parent = 0 );

      // Set Asics
      void setAsics (KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga);

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable, bool calEnable );

      // Get rate limit value, zero for none
      unsigned int getRateLimit();

   private slots:

      void timeValueChanged();

   public slots:

      void readConfig(bool readEn);
      void writeConfig(bool writeEn);
      void rawTrigInh_stateChanged();

};

#endif
