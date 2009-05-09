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
void KpixGuiFpga::readConfig(bool readEn) {
   if ( fpga != NULL ) {
      bncSourceA->setCurrentItem(fpga->getBncSourceA(readEn));
      bncSourceB->setCurrentItem(fpga->getBncSourceB(readEn));
      acceptSource->setCurrentItem(fpga->getAcceptSource(readEn));
      extRunSource->setCurrentItem(fpga->getExtRunSource(readEn));
      extRunDelay->setValue(fpga->getExtRunDelay(readEn));
      extRunType->setChecked(fpga->getExtRunType(readEn));
      autoTrainEnable->setChecked(fpga->getAutoTrainEnable(readEn));
      autoTrainType->setChecked(fpga->getAutoTrainType(readEn));
      autoTrainSpacing->setValue(fpga->getAutoTrainSpacing(readEn));
      calDelay->setValue(fpga->getCalDelay(readEn));
      rawData->setChecked(fpga->getRawData(readEn));
      dropData->setChecked(fpga->getDropData(readEn));
      rxPolarity->setChecked(fpga->getRxPolarity(readEn));
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiFpga::writeConfig(bool writeEn) {
   if ( fpga != NULL ) {
      fpga->setBncSourceA(bncSourceA->currentItem(),writeEn);
      fpga->setBncSourceB(bncSourceB->currentItem(),writeEn);
      fpga->setAcceptSource(acceptSource->currentItem(),writeEn);
      fpga->setExtRunSource(extRunSource->currentItem(),writeEn);
      fpga->setExtRunDelay(extRunDelay->value(),writeEn);
      fpga->setExtRunType(extRunType->isChecked(),writeEn);
      fpga->setAutoTrainEnable(autoTrainEnable->isChecked(),writeEn);
      fpga->setAutoTrainType(autoTrainType->isChecked(),writeEn);
      fpga->setAutoTrainSpacing(autoTrainSpacing->value(),writeEn);
      fpga->setCalDelay(calDelay->value(),writeEn);
      fpga->setRawData(rawData->isChecked(),writeEn);
      fpga->setDropData(dropData->isChecked(),writeEn);
      fpga->setRxPolarity(rxPolarity->isChecked(),writeEn);
   }
}


// Update Counters
void KpixGuiFpga::readCounters() {

   stringstream temp;

   if ( fpga != NULL ) {
      temp.str("");
      temp << "0x" << hex << setw(8) << setfill('0') << fpga->getVersion();
      fpgaVersion->setText(temp.str());
      temp.str("");
      temp << "0x" << hex << setw(8) << setfill('0') << fpga->getJumpers();
      fpgaJumpers->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getCheckSumErrors();
      checkSumErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getRspParErrors();
      rspParErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getDataParErrors();
      dataParErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getDeadCount();
      deadCount->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getTrainNumber();
      trainNumber->setText(temp.str());
   }
}

