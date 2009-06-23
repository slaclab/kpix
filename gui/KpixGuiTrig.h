//-----------------------------------------------------------------------------
// File          : KpixGuiTrig.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Trigger Settings.
// This is a class which builds off of the class created in
// KpixGuiTrigForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_TRIG_H__
#define __KPIX_GUI_TRIG_H__

#include "KpixGuiTrigForm.h"

// Forward Declarations
namespace sidApi {
   namespace offline {
      class KpixAsic;
      class KpixFpga;
   }
}
class QComboBox;


class KpixGuiTrig : public KpixGuiTrigForm {

      // ASIC & FPGA Containers
      unsigned int              asicCnt;
      sidApi::offline::KpixAsic **asic;
      sidApi::offline::KpixFpga *fpga;

      // Threshold Table Entries
      QComboBox **thold;

      // Channel Table Entries
      QComboBox **mode;

   public:

      // Creation Class
      KpixGuiTrig ( QWidget *parent = 0 );

      // Set Asics
      void setAsics (sidApi::offline::KpixAsic **asic, unsigned int asicCnt, 
                     sidApi::offline::KpixFpga *fpga);

      // Deconstructor
      ~KpixGuiTrig();

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

   private slots:

      void setAllPressed();

   public slots:

      void updateDisplay();
      void readConfig();
      void writeConfig();
};

#endif
