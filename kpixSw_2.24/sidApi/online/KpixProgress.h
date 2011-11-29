//-----------------------------------------------------------------------------
// File          : KpixProgress.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/26/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Parent class to allow KpixApi classes to update progress in calling 
// functions.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 09/26/2008: created
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_PROGRESS_H__
#define __KPIX_PROGRESS_H__

// Constants

class KpixProgress {
   public:
      enum KpixData { 
         KpixDataTH1F     = 0,
         KpixDataTGraph   = 1,
         KpixDataTGraph2D = 2,
         KpixDataTH2F     = 3,
         KpixDataString   = 4,
         KpixDataInt      = 5,
         KpixDataUInt     = 6,
         KpixDataDouble   = 7
      };
      virtual void updateProgress(unsigned int count, unsigned int total) = 0;
      virtual void updateData(unsigned int type, unsigned int count, void **data) = 0;
      virtual ~KpixProgress() {};
};
#endif
