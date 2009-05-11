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
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 09/26/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_PROGRESS_H__
#define __KPIX_PROGRESS_H__
using namespace std;

// Plot Types
#define KPRG_TH1F      0
#define KPRG_TGRAPH    1
#define KPRG_TGRAPH2D  2
#define KPRG_TH2F      3
#define KPRG_STRING    4
#define KPRG_INT       5
#define KPRG_UINT      6
#define KPRG_DOUBLE    7

// KPIX Progress Class
class KpixProgress {
   public:
      virtual void updateProgress(unsigned int count, unsigned int total) = 0;
      virtual void updateData(unsigned int type, unsigned int count, void **data) = 0;
      virtual ~KpixProgress() {};
};

#endif
