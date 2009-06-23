//-----------------------------------------------------------------------------
// File          : KpixGuiError.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for showing KPIX API errors.
// This is a class which builds off of the class created in
// KpixGuiErrorForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_ERROR_H__
#define __KPIX_GUI_ERROR_H__

#include <string>
#include "KpixGuiErrorForm.h"


class KpixGuiError : public KpixGuiErrorForm {

   public:

      // Creation Class
      KpixGuiError ( QWidget *parent = 0 );

      // Display Message
      void showMessage(std::string error);
};

#endif
