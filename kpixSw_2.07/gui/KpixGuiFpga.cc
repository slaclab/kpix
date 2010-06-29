//-----------------------------------------------------------------------------
// File          : KpixGuiFpga.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX FPGA Settings.
// This is a class which builds off of the class created in
// KpixGuiFpgaForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
// 05/13/2009: Changed name of accept source to extRecord 
// 05/13/2009: Removed auto train generation.
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
#include <qcheckbox.h>
#include <qcombobox.h>
#include <qspinbox.h>
#include <KpixFpga.h>
#include "KpixGuiFpga.h"
using namespace std;


// Constructor
KpixGuiFpga::KpixGuiFpga ( QWidget *parent ) : KpixGuiFpgaForm(parent) {
   this->fpga = NULL;
}


// Set FPGA
void KpixGuiFpga::setFpga ( KpixFpga *fpga ) {
   this->fpga = fpga;
}


// Control Enable Of Buttons/Edits
void KpixGuiFpga::setEnabled ( bool enable ) {
   if ( fpga == NULL ) enable = false;
   bncSourceA->setEnabled(enable);
   bncSourceB->setEnabled(enable);
   extRecord->setEnabled(enable);
   extRunSource->setEnabled(enable);
   extRunDelay->setEnabled(enable);
   extRunType->setEnabled(enable);
   calDelay->setEnabled(enable);
   rawData->setEnabled(enable);
   dropData->setEnabled(enable);
   disKpixA->setEnabled(enable);
   disKpixB->setEnabled(enable);
   disKpixC->setEnabled(enable);
}


// Read Settings From Asic/Fpga class
void KpixGuiFpga::readConfig() {
   if ( fpga != NULL ) {
      fpga->getBncSourceA();
      fpga->getBncSourceB();
      fpga->getExtRecord();
      fpga->getExtRunSource();
      fpga->getExtRunDelay();
      fpga->getExtRunType();
      fpga->getCalDelay();
      fpga->getRawData();
      fpga->getDropData();
      fpga->getDisKpixA();
      fpga->getDisKpixB();
      fpga->getDisKpixC();
   }
}


// Update display values
void KpixGuiFpga::updateDisplay() {
   if ( fpga != NULL ) {
      bncSourceA->setCurrentItem(fpga->getBncSourceA(false));
      bncSourceB->setCurrentItem(fpga->getBncSourceB(false));
      extRecord->setCurrentItem(fpga->getExtRecord(false));
      extRunSource->setCurrentItem(fpga->getExtRunSource(false));
      extRunDelay->setValue(fpga->getExtRunDelay(false));
      extRunType->setChecked(fpga->getExtRunType(false));
      calDelay->setValue(fpga->getCalDelay(false));
      rawData->setChecked(fpga->getRawData(false));
      dropData->setChecked(fpga->getDropData(false));
      disKpixA->setChecked(fpga->getDisKpixA(false));
      disKpixB->setChecked(fpga->getDisKpixB(false));
      disKpixC->setChecked(fpga->getDisKpixC(false));
   }
}



// Write Settings To Asic/Fpga class
void KpixGuiFpga::writeConfig() {
   if ( fpga != NULL ) {
      fpga->setBncSourceA(bncSourceA->currentItem());
      fpga->setBncSourceB(bncSourceB->currentItem());
      fpga->setExtRecord(extRecord->currentItem());
      fpga->setExtRunSource(extRunSource->currentItem());
      fpga->setExtRunDelay(extRunDelay->value());
      fpga->setExtRunType(extRunType->isChecked());
      fpga->setCalDelay(calDelay->value());
      fpga->setRawData(rawData->isChecked());
      fpga->setDropData(dropData->isChecked());
      fpga->setDisKpixA(disKpixA->isChecked());
      fpga->setDisKpixB(disKpixB->isChecked());
      fpga->setDisKpixC(disKpixC->isChecked());
   }
}


