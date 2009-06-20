//-----------------------------------------------------------------------------
// File          : KpixGuiMain.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the list of KPIX ASICs
// This is a class which builds off of the class created in
// KpixGuiMainForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_MAIN_H__
#define __KPIX_GUI_MAIN_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiMainForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <KpixRunVar.h>
#include <KpixRunRead.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qlcdnumber.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiMain : public KpixGuiMainForm {

      // ASIC & FPGA Containers
      unsigned int asicCnt;
      KpixAsic     **asic;

      // Threshold Table Entries
      QComboBox **posPixel;

   public:

      // Creation Class
      KpixGuiMain ( QWidget *parent = 0 );

      // Delete
      ~KpixGuiMain();

      // Set Asics
      void setAsics (KpixAsic **asic, unsigned int asicCnt);

      // Set Calib Read File For Run Var List
      void setRunRead ( KpixRunRead *kpixRunRead );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable, bool calEnable );

      // Get Run Description
      string getRunDescription();

      // Get Run Variable List
      KpixRunVar **getRunVarList(unsigned int *count);

   private slots:

   public slots:

      void updateDisplay();
      void readConfig();
      void writeConfig();
      void addRunVar_pressed();
      void delRunVar_pressed();
};

#endif
