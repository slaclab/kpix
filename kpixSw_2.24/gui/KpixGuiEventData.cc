//-----------------------------------------------------------------------------
// File          : KpixGuiEventData.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for generating plot update events.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/14/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
//-----------------------------------------------------------------------------

#include "KpixGuiEventData.h"
#include <stdlib.h>
using namespace std;


// Creation Class For Calib Plots
KpixGuiEventData::KpixGuiEventData ( unsigned int id, unsigned int count, void **data ) : 
   QCustomEvent ( KPIX_GUI_EVENT_DATA ) {

   unsigned int x;

   this->id      = id;
   this->count   = count;
   this->data    = NULL;

   // Allocate Space
   if ( count != 0 ) {
      this->data = (void **) malloc (sizeof(void *) * count);
      if ( this->data == NULL ) 
         throw(string("KpixGuiEventData::KpixGuiEventData -> Malloc Error"));
   }

   // Copy data
   for (x=0; x< count; x++) this->data[x] = data[x];
}


// Deconstructor
KpixGuiEventData::~KpixGuiEventData() {
   if ( count != 0 ) free(data);
}

