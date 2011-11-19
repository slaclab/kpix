//-----------------------------------------------------------------------------
// File          : KpixChannel.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/17/2011
// Project       : Kpix ASIC
//-----------------------------------------------------------------------------
// Description :
// Kpix channel container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/17/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_CHANNEL_H__
#define __KPIX_CHANNEL_H__

#include <Device.h>
using namespace std;

//! Class to contain Kpix ASIC
class KpixChannel : public Device {

   public:

      //! Constructor
      /*! 
       * \param index       Device index
       * \param parent      Parent device
      */
      KpixChannel ( uint index, Device *parent );

      //! Deconstructor
      ~KpixChannel ( );

};
#endif
