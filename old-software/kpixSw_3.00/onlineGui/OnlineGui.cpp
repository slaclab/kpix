//-----------------------------------------------------------------------------
// File          : OnlineGui.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/22/2011
// Project       : General purpose
//-----------------------------------------------------------------------------
// Description :
// Main program
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/22/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <signal.h>
#include <unistd.h>
#include <QApplication>
#include <QErrorMessage>
#include <QObject>
#include "../generic/DataRead.h"
#include "../kpix/KpixEvent.h"
#include "MainWindow.h"
#include "SharedMem.h"
using namespace std;

// Main Function
int main ( int argc, char **argv ) {
   DataRead  *data  = new DataRead;
   KpixEvent *event = new KpixEvent;

   data->openShared("kpix",1);

   // Start application
   QApplication a( argc, argv );

   // Shared memory
   SharedMem smem(data,event);

   MainWindow mainWin(data,event);
   mainWin.show();

   // Udp signals
   QObject::connect(&smem,SIGNAL(event()),&mainWin,SLOT(event()));
   QObject::connect(&mainWin,SIGNAL(ack()),&smem,SLOT(ack()));

   // Exit on window close
   QObject::connect(&a,SIGNAL(lastWindowClosed()), &a, SLOT(quit())); 

   // Run application
   return(a.exec());
}

