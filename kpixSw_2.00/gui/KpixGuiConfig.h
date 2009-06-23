//-----------------------------------------------------------------------------
// File          : KpixGuiConfig.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Configuration Settings.
// This is a class which builds off of the class created in
// KpixGuiConfigForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_CONFIG_H__
#define __KPIX_GUI_CONFIG_H__

#include "KpixGuiConfigForm.h"

// Forward declarations
namespace sidApi {
   namespace offline {
      class KpixAsic;
   }
}


class KpixGuiConfig : public KpixGuiConfigForm {

      // ASIC & FPGA Containers
      unsigned int              asicCnt;
      sidApi::offline::KpixAsic **asic;

   public:

      // Creation Class
      KpixGuiConfig ( QWidget *parent = 0 );

      // Set Asics
      void setAsics (sidApi::offline::KpixAsic **asic, unsigned int asicCnt);

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable, bool calEnable );

   private slots:

      void dacValueChanged();

   public slots:

      void updateDisplay();
      void readConfig();
      void writeConfig();

};

#endif
