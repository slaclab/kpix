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
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
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
   acceptSource->setEnabled(enable);
   extRunSource->setEnabled(enable);
   extRunDelay->setEnabled(enable);
   extRunType->setEnabled(enable);
   autoTrainEnable->setEnabled(enable);
   autoTrainType->setEnabled(enable);
   autoTrainSpacing->setEnabled(enable);
   calDelay->setEnabled(enable);
   rawData->setEnabled(enable);
   dropData->setEnabled(enable);
   rxPolarity->setEnabled(enable);
}


// Read Settings From Asic/Fpga class
void KpixGuiFpga::readConfig() {
   if ( fpga != NULL ) {
      fpga->getBncSourceA();
      fpga->getBncSourceB();
      fpga->getAcceptSource();
      fpga->getExtRunSource();
      fpga->getExtRunDelay();
      fpga->getExtRunType();
      fpga->getAutoTrainEnable();
      fpga->getAutoTrainType();
      fpga->getAutoTrainSpacing();
      fpga->getCalDelay();
      fpga->getRawData();
      fpga->getDropData();
      fpga->getRxPolarity();
   }
}


// Update display values
void KpixGuiFpga::updateDisplay() {
   if ( fpga != NULL ) {
      bncSourceA->setCurrentItem(fpga->getBncSourceA(false));
      bncSourceB->setCurrentItem(fpga->getBncSourceB(false));
      acceptSource->setCurrentItem(fpga->getAcceptSource(false));
      extRunSource->setCurrentItem(fpga->getExtRunSource(false));
      extRunDelay->setValue(fpga->getExtRunDelay(false));
      extRunType->setChecked(fpga->getExtRunType(false));
      autoTrainEnable->setChecked(fpga->getAutoTrainEnable(false));
      autoTrainType->setChecked(fpga->getAutoTrainType(false));
      autoTrainSpacing->setValue(fpga->getAutoTrainSpacing(false));
      calDelay->setValue(fpga->getCalDelay(false));
      rawData->setChecked(fpga->getRawData(false));
      dropData->setChecked(fpga->getDropData(false));
      rxPolarity->setChecked(fpga->getRxPolarity(false));
   }
}



// Write Settings To Asic/Fpga class
void KpixGuiFpga::writeConfig() {
   if ( fpga != NULL ) {
      fpga->setBncSourceA(bncSourceA->currentItem());
      fpga->setBncSourceB(bncSourceB->currentItem());
      fpga->setAcceptSource(acceptSource->currentItem());
      fpga->setExtRunSource(extRunSource->currentItem());
      fpga->setExtRunDelay(extRunDelay->value());
      fpga->setExtRunType(extRunType->isChecked());
      fpga->setAutoTrainEnable(autoTrainEnable->isChecked());
      fpga->setAutoTrainType(autoTrainType->isChecked());
      fpga->setAutoTrainSpacing(autoTrainSpacing->value());
      fpga->setCalDelay(calDelay->value());
      fpga->setRawData(rawData->isChecked());
      fpga->setDropData(dropData->isChecked());
      fpga->setRxPolarity(rxPolarity->isChecked());
   }
}


