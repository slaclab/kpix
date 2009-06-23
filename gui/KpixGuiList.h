//-----------------------------------------------------------------------------
// File          : KpixGuiList.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the list of KPIX ASICs
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_LIST_H__
#define __KPIX_GUI_LIST_H__

#include "KpixGuiListForm.h"

namespace sidApi {
   namespace offline {
      class KpixRunRead;
   }
}

class KpixGuiList : public KpixGuiListForm {

   public:

      // Creation Class
      KpixGuiList ( QWidget *parent = 0 );

      // Set Run Read
      void setRunRead ( sidApi::offline::KpixRunRead *kpixRunRead );

};

#endif
