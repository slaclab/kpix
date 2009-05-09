//-----------------------------------------------------------------------------
// File          : KpixGuiConfig.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Configuration Settings.
// This is a class which builds off of the class created in
// KpixGuiConfigForm.ui
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
#include "KpixGuiConfig.h"
using namespace std;


// Constructor
KpixGuiConfig::KpixGuiConfig ( QWidget *parent ) : KpixGuiConfigForm(parent) {
   this->asicCnt = 0;
   this->asic    = NULL;
   setEnabled(false,false);
}


// Set Asics
void KpixGuiConfig::setAsics (KpixAsic **asic, unsigned int asicCnt) {
   this->asicCnt = asicCnt;
   this->asic    = asic;
}


// Control Enable Of Buttons/Edits
void KpixGuiConfig::setEnabled ( bool enable, bool calEnable ) {
   if ( asicCnt == 0 ) enable = false;
   cntrlHoldTime->setEnabled(enable&&calEnable);
   dacRampThresh->setEnabled(enable&&calEnable);
   dacRangeThresh->setEnabled(enable&&calEnable);
   dacEventThreshRef->setEnabled(enable&&calEnable);
   dacShaperBias->setEnabled(enable&&calEnable);
   dacDefaultAnalog->setEnabled(enable&&calEnable);
   cntrlForceLowGain->setEnabled(enable);
   cntrlLeakNullDis->setEnabled(enable);
   cntrlDoubleGain->setEnabled(enable);
   cntrlDisPerRst->setEnabled(enable&&calEnable);
   cntrlEnDcRst->setEnabled(enable&&calEnable);
}


// Update DAC Setting
void KpixGuiConfig::dacValueChanged() {
   int          x; 
   int          values[5];
   stringstream disp[5];

   // Get current values
   values[0] = dacRampThresh->value();
   values[1] = dacRangeThresh->value();
   values[2] = dacEventThreshRef->value();
   values[3] = dacShaperBias->value();
   values[4] = dacDefaultAnalog->value();

   // Convert each value 
   for (x=0; x < 5; x++) {
      disp[x].str("");
      disp[x].precision(4);
      disp[x] << KpixAsic::dacToVolt((unsigned char)values[x]) << " Volts";
   }

   // Set LCD Values
   dacRampThreshValue->setText(disp[0].str());
   dacRangeThreshValue->setText(disp[1].str());
   dacEventThreshRefValue->setText(disp[2].str());
   dacShaperBiasValue->setText(disp[3].str());
   dacDefaultAnalogValue->setText(disp[4].str());
}


// Read Settings From Asic/Fpga class
void KpixGuiConfig::readConfig(bool readEn) {
   if ( asicCnt != 0 ) {
      cntrlHoldTime->setCurrentItem(asic[0]->getCntrlHoldTime(readEn)-1);
      dacRampThresh->setValue(asic[0]->getDacRampThresh(readEn));
      dacRangeThresh->setValue(asic[0]->getDacRangeThresh(readEn));
      dacEventThreshRef->setValue(asic[0]->getDacEventThreshRef(readEn));
      dacShaperBias->setValue(asic[0]->getDacShaperBias(readEn));
      dacDefaultAnalog->setValue(asic[0]->getDacDefaultAnalog(readEn));
      cntrlForceLowGain->setChecked(asic[0]->getCntrlForceLowGain(readEn));
      cntrlLeakNullDis->setChecked(asic[0]->getCntrlLeakNullDis(readEn));
      cntrlDoubleGain->setChecked(asic[0]->getCntrlDoubleGain(readEn));
      cntrlDisPerRst->setChecked(asic[0]->getCntrlDisPerRst(readEn));
      cntrlEnDcRst->setChecked(asic[0]->getCntrlEnDcRst(readEn));
      dacValueChanged();
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiConfig::writeConfig(bool writeEn) {

   unsigned int x;

   // Asic
   for (x=0; x < asicCnt; x++) {
      asic[x]->setCntrlHoldTime(cntrlHoldTime->currentItem()+1,writeEn);
      asic[x]->setDacRampThresh(dacRampThresh->value(),writeEn);
      asic[x]->setDacRangeThresh(dacRangeThresh->value(),writeEn);
      asic[x]->setDacEventThreshRef(dacEventThreshRef->value(),writeEn);
      asic[x]->setDacShaperBias(dacShaperBias->value(),writeEn);
      asic[x]->setDacDefaultAnalog(dacDefaultAnalog->value(),writeEn);
      asic[x]->setCntrlForceLowGain(cntrlForceLowGain->isChecked(),writeEn);
      asic[x]->setCntrlLeakNullDis(cntrlLeakNullDis->isChecked(),writeEn);
      asic[x]->setCntrlDoubleGain(cntrlDoubleGain->isChecked(),writeEn);
      asic[x]->setCntrlDisPerRst(cntrlDisPerRst->isChecked(),writeEn);
      asic[x]->setCntrlEnDcRst(cntrlEnDcRst->isChecked(),writeEn);
   }
}


