//-----------------------------------------------------------------------------
// File          : KpixGuiList.cc
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
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <qtextedit.h>
#include <qtable.h>
#include <KpixRunVar.h>
#include <KpixAsic.h>
#include <KpixRunRead.h>
#include <KpixEventVar.h>
#include "KpixGuiList.h"
using namespace std;
using namespace sidApi::offline;


// Constructor
KpixGuiList::KpixGuiList ( QWidget *parent ) : KpixGuiListForm(parent) { }


// Set Run Read
void KpixGuiList::setRunRead ( KpixRunRead *kpixRunRead ) {

   unsigned int x;
   stringstream temp;
   string       temp2;
   KpixRunVar   *runVar;
   KpixEventVar *eventVar;

   // Delete old table entries
   kpixList->setNumRows(0);

   if ( kpixRunRead != NULL ) {

      // Run Data
      this->runDesc->setText(string(kpixRunRead->getRunDescription()));
      this->runTime->setText(string(kpixRunRead->getRunTime()));
      this->endTime->setText(string(kpixRunRead->getEndTime()));
      this->runCalib->setText(string(kpixRunRead->getRunCalib()));
      this->runName->setText(string(kpixRunRead->getRunName()));

      // Adjust column widths
      kpixList->setColumnWidth(0,75);
      kpixList->setColumnWidth(1,75);
      kpixList->setColumnWidth(2,75);
      kpixList->setColumnWidth(3,75);

      // For Each Asic
      kpixList->setNumRows(kpixRunRead->getAsicCount());
      for (x=0; x < (unsigned int)kpixRunRead->getAsicCount(); x++ ) {

         // Row Header
         temp.str("");
         temp << "Kpix " << dec << x;
         kpixList->verticalHeader()->setLabel(x,temp.str());

         // Address
         temp.str("");
         temp << "0x" << hex << setw(2) << setfill('0') << kpixRunRead->getAsic(x)->getAddress();
         kpixList->setText(x,0,temp.str());

         // Serial
         temp.str("");
         temp << dec << kpixRunRead->getAsic(x)->getSerial();
         kpixList->setText(x,1,temp.str());

         // Version
         temp.str("");
         temp << dec << kpixRunRead->getAsic(x)->getVersion();
         kpixList->setText(x,2,temp.str());

         // Pos Pixel
         if ( kpixRunRead->getAsic(x)->getCntrlPosPixel(false) ) 
            kpixList->setText(x,3,"True");
         else
            kpixList->setText(x,3,"False");
      }

      // For Each Run Variable
      runVarTable->setNumRows(kpixRunRead->getRunVarCount());
      for (x=0; x < (unsigned int)kpixRunRead->getRunVarCount(); x++ ) {
         runVar = kpixRunRead->getRunVar(x);
         temp2 = runVar->name(); runVarTable->setText(x,0,temp2);
         temp2 = runVar->description(); runVarTable->setText(x,2,temp2);
         temp.str(""); temp << runVar->value(); runVarTable->setText(x,1,temp.str());
      }
      runVarTable->adjustColumn(0);
      runVarTable->adjustColumn(1);
      runVarTable->adjustColumn(2);

      // For Each Event Variable
      eventVarTable->setNumRows(kpixRunRead->getEventVarCount());
      for (x=0; x < (unsigned int)kpixRunRead->getEventVarCount(); x++ ) {
         eventVar = kpixRunRead->getEventVar(x);
         temp2 = eventVar->name(); eventVarTable->setText(x,0,temp2);
         temp2 = eventVar->description(); eventVarTable->setText(x,1,temp2);
      }
      eventVarTable->adjustColumn(0);
      eventVarTable->adjustColumn(1);
      update();
   }
}


