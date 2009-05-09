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
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_ERROR_H__
#define __KPIX_GUI_ERROR_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qwidget.h>
#include "KpixGuiErrorForm.h"
#include <KpixAsic.h>
#include <KpixFpga.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qtable.h>
#include <qspinbox.h>


class KpixGuiError : public KpixGuiErrorForm {

   public:

      // Creation Class
      KpixGuiError ( QWidget *parent = 0 );

      // Display Message
      void showMessage(string error);
};

#endif
