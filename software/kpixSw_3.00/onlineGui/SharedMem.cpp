//-----------------------------------------------------------------------------
// File          : SharedMem.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General Purpose
//-----------------------------------------------------------------------------
// Description :
// Shared memor for data connections.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/04/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <sstream>
#include <string>
#include <QDomDocument>
#include <QMessageBox>
#include "SharedMem.h"
using namespace std;

// Constructor
SharedMem::SharedMem (DataRead *dataRead, KpixEvent *event) {
   this->dread_ = dataRead;
   this->event_ = event;

   eventCount = 0;
   ackCount   = 0;

   runEnable = true;
   QThread::start();
}

// Delete
SharedMem::~SharedMem ( ) { 
   runEnable = false;
   usleep(100);
}

// Ack
void SharedMem::ack() {
   ackCount = eventCount;
}

// Run
void SharedMem::run () {
   while (runEnable) {

      if ( ackCount == eventCount ) {
         if ( dread_->next(event_)) {
            event();
            eventCount++;
         }
         else usleep(1);
      }
      else usleep(1);
   }
}

