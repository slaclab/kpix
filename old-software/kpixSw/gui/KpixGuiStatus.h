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
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_STATUS_H__
#define __KPIX_GUI_STATUS_H__

#include "KpixGuiStatusForm.h"

// Forward Declarations
class KpixAsic;
class KpixFpga;


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
