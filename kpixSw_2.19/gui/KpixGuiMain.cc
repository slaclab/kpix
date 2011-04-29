//-----------------------------------------------------------------------------
// File          : KpixGuiMain.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the list of KPIX ASICs
// This is a class which builds off of the class created in
// KpixGuiMainForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
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
#include <qcombobox.h>
#include <qpushbutton.h>
#include <KpixAsic.h>
#include <KpixRunVar.h>
#include <KpixRunRead.h>
#include "KpixGuiMain.h"
using namespace std;


// Constructor
KpixGuiMain::KpixGuiMain ( QWidget *parent ) : KpixGuiMainForm(parent) {
   this->asicCnt  = 0;
   this->asic     = NULL;
   this->posPixel = NULL;
}


// Set Asics
void KpixGuiMain::setAsics (KpixAsic **asic, unsigned int asicCnt) {

   unsigned int x;
   stringstream temp;

   // Delete old columns
   for ( x=0; x < this->asicCnt; x++ ) kpixList->removeRow(x);
   if ( posPixel != NULL ) free(posPixel); posPixel = NULL;

   // Store new list
   this->asicCnt = asicCnt;
   this->asic    = asic;

   if ( asicCnt > 0 ) {

      // Set number of Rows
      kpixList->setNumRows(asicCnt);

      // Adjust column widths
      kpixList->setColumnWidth(0,75);
      kpixList->setColumnWidth(1,75);
      kpixList->setColumnWidth(2,75);
      kpixList->setColumnWidth(3,75);

      // Create combo boxes
      posPixel = (QComboBox **) malloc(sizeof(QComboBox*)*asicCnt);

      // For Each Asic
      for (x=0; x < asicCnt; x++) {

         // Row Header
         temp.str("");
         temp << "Kpix " << dec << x;
         kpixList->verticalHeader()->setLabel(x,temp.str());

         // Address
         temp.str("");
         temp << "0x" << hex << setw(2) << setfill('0') << asic[x]->getAddress();
         kpixList->setText(x,0,temp.str());

         // Version
         temp.str("");
         temp << dec << asic[x]->getVersion();
         kpixList->setText(x,2,temp.str());

         // Pos Pixel Mode
         posPixel[x] = new QComboBox(kpixList);
         posPixel[x]->insertItem("False",0);
         posPixel[x]->insertItem("True",1);
         kpixList->setCellWidget(x,3,posPixel[x]);
         kpixList->setRowReadOnly(x,false);
      }

      // Address & Version Col Is Read Only
      kpixList->setColumnReadOnly(0,true);
      kpixList->setColumnReadOnly(1,false);
      kpixList->setColumnReadOnly(2,true);
      kpixList->setColumnReadOnly(3,true);
      kpixList->setRowReadOnly(asicCnt-1,true);
      posPixel[asicCnt-1]->setEnabled(false);
   }
}


// Set Calib Read File For Run Var List
void KpixGuiMain::setRunRead ( KpixRunRead *kpixRunRead ) {
   unsigned int x;
   stringstream temp;
   string       temp2;
   KpixRunVar   *runVar;

   // For Each Variable
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

   // Set description text
   runDesc->setText(string(kpixRunRead->getRunDescription()));
}


// Delete
KpixGuiMain::~KpixGuiMain() {
   if ( posPixel != NULL ) free(posPixel);
}


// Control Enable Of Buttons/Edits
void KpixGuiMain::setEnabled ( bool enable, bool calEnable ) {
   unsigned int x;

   if ( asicCnt == 0 ) enable = false;
   kpixList->setEnabled(enable);
   runDesc->setEnabled(enable);
   runVarTable->setEnabled(enable);
   addRunVar->setEnabled(enable);
   delRunVar->setEnabled(enable);

   // List Entries
   if ( asicCnt != 0 ) for (x=0; x < asicCnt -1; x++) posPixel[x]->setEnabled(calEnable);
   kpixList->setColumnReadOnly(1,!calEnable);
}


// Update display
void KpixGuiMain::updateDisplay() {

   stringstream  temp;
   unsigned int  x;

   // Table Entries
   for ( x=0; x < asicCnt; x++ ) {

      // Get Pos Pixel Mode
      posPixel[x]->setCurrentItem(asic[x]->getCntrlPosPixel(false));

      // Serial
      temp.str("");
      temp << dec << asic[x]->getSerial();
      if ( x == (asicCnt-1) ) kpixList->setText(x,1,"FPGA");
      else kpixList->setText(x,1,temp.str());
   }
}


// Read Settings From Asic/Fpga class
void KpixGuiMain::readConfig() {

   unsigned int  x;

   // Table Entries
   for ( x=0; x < asicCnt; x++ ) asic[x]->getCntrlPosPixel();
}


// Write Settings To Asic/Fpga class
void KpixGuiMain::writeConfig() {

   unsigned int  x;
   bool          ok;

   // Get Pos Pixel & Serial Numbers For Each ASICs
   if ( asicCnt != 0 ) for ( x=0; x < (asicCnt-1); x++ ) {
      if ( x != (asicCnt-1)) asic[x]->setSerial(kpixList->text(x,1).toInt(&ok,10));
      asic[x]->setCntrlPosPixel(posPixel[x]->currentItem());
   }
}


// Get Run Description
string KpixGuiMain::getRunDescription() {
   return(string(runDesc->text().ascii()));
}


// Get Run Variable List
KpixRunVar **KpixGuiMain::getRunVarList(unsigned int *count) {
   unsigned int x;
   KpixRunVar **vars;

   // Get count
   *count = runVarTable->numRows();
   vars   = NULL;

   // Create pointers
   if ( *count > 0 ) {
      vars = (KpixRunVar **) malloc(sizeof(KpixRunVar)*(*count));
      if (vars == NULL ) throw(string("KpixGuiMain::getRunVarList -> Malloc Error"));
      for (x=0; x< *count; x++) 
         vars[x] = new KpixRunVar(runVarTable->text(x,0).ascii(),
                                  runVarTable->text(x,2).ascii(),
                                  runVarTable->text(x,1).toDouble());
   } 
   return(vars);
}


void KpixGuiMain::addRunVar_pressed() {
   unsigned int count;
   stringstream temp;

   // Get current count
   count = runVarTable->numRows();

   // Create default Name
   temp.str("");
   temp << "new_var_" << count;

   // Add new column
   runVarTable->insertRows(count);

   // Set defaults
   runVarTable->setText(count,0,temp.str());
   runVarTable->setText(count,1,"0.0");
   runVarTable->setText(count,2,"New Variable");
}

void KpixGuiMain::delRunVar_pressed() {
   runVarTable->removeRow(runVarTable->currentRow());
}

