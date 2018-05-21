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
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_FPGA_H__
#define __KPIX_GUI_FPGA_H__

#include "KpixGuiFpgaForm.h"

// Forward declarations
class KpixFpga;


class KpixGuiFpga : public KpixGuiFpgaForm {

      // ASIC & FPGA Containers
      KpixFpga *fpga;

   public:

      // Creation Class
      KpixGuiFpga ( QWidget *parent = 0 );

      // Set FPGA
      void setFpga ( KpixFpga *fpga );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

   private slots:

   public slots:

      void updateDisplay();
      void readConfig();
      void writeConfig();

};

#endif
