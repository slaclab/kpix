//-----------------------------------------------------------------------------
// File          : KpixGuiFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX FPGA Settings.
// This is a class which builds off of the class created in
// KpixGuiFpgaForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_FPGA_H__
#define __KPIX_GUI_FPGA_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiFpgaForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiFpga : public KpixGuiFpgaForm {

      // ASIC & FPGA Containers
      KpixFpga     *fpga;

   public:

      // Creation Class
      KpixGuiFpga ( QWidget *parent = 0 );

      // Set FPGA
      void setFpga ( KpixFpga *fpga );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

   private slots:

   public slots:

      void readConfig(bool readEn);
      void writeConfig(bool writeEn);
      void readCounters();

};

#endif
