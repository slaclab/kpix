//-----------------------------------------------------------------------------
// File          : SharedMem.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General Purpose
//-----------------------------------------------------------------------------
// Description :
// Shared memory interface for data
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/04/2011: created
//-----------------------------------------------------------------------------
#ifndef __SHARED_MEM_H__
#define __SHARED_MEM_H__

#include <QThread>
#include "../generic/DataSharedMem.h"
#include "../generic/DataRead.h"
#include "../kpix/KpixEvent.h"
using namespace std;

class SharedMem : public QThread {
   
   Q_OBJECT

      // Event counters
      uint eventCount;
      uint ackCount;

      // Data reader
      DataRead  *dread_;  
      KpixEvent *event_;

      // Run enable
      bool runEnable;

   public:

      // Creation Class
      SharedMem (DataRead *dataRead, KpixEvent *event);

      // Delete
      ~SharedMem ();

      // Main thread
      void run ();

   public slots:
      
      void ack();

   signals:

      // Data
      void event ();
};

#endif
