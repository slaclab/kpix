//-----------------------------------------------------------------------------
// File          : KpixGuiSampleView.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/16/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class to view KPIX samples.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/16/2008: created
// 05/11/2009: Added range checking on serial number lookup.
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_SAMPLE_VIEW_H__
#define __KPIX_GUI_SAMPLE_VIEW_H__

#include "KpixGuiSampleViewForm.h"


// Forward declarations
class KpixRunRead;
class KpixCalibRead;
class KpixEventVar;


class KpixGuiSampleView : public KpixGuiSampleViewForm {

      // Run Reader
      KpixRunRead   *kpixRunRead;
      KpixCalibRead *kpixCalibRead;

      // List of event variables
      KpixEventVar **eventVar;
      unsigned int eventCount;

      // Lookup Table For Kpix Index
      unsigned int *kpixIdxLookup;
      unsigned int maxAddress;

   public:

      // Creation Class
      KpixGuiSampleView ( );

      // Desconstructor Class
      ~KpixGuiSampleView ( );

      // Set Run Data
      void setRunData ( KpixRunRead *kpixRunRead);

   public slots:

      void updateDisplay();

};

#endif
