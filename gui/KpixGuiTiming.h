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
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_TIMING_H__
#define __KPIX_GUI_TIMING_H__

#include "KpixGuiTimingForm.h"

// Forward Declarations
namespace sidApi {
   namespace offline {
      class KpixAsic;
      class KpixFpga;
   }
}


class KpixGuiTiming : public KpixGuiTimingForm {

      // ASIC & FPGA Containers
      unsigned int              asicCnt;
      sidApi::offline::KpixAsic **asic;
      sidApi::offline::KpixFpga *fpga;

   public:

      // Creation Class
      KpixGuiTiming ( unsigned int rateLimit, QWidget *parent = 0 );

      // Set Asics
      void setAsics (sidApi::offline::KpixAsic **asic, unsigned int asicCnt, 
                     sidApi::offline::KpixFpga *fpga);

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable, bool calEnable );

      // Get rate limit value, zero for none
      unsigned int getRateLimit();

   private slots:

      void timeValueChanged();

   public slots:

      void updateDisplay();
      void readConfig();
      void writeConfig();
      void rawTrigInh_stateChanged();

};

#endif
