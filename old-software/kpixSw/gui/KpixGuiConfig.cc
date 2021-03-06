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
#include <qcombobox.h>
#include <qcheckbox.h>
#include <qspinbox.h>
#include <KpixAsic.h>
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

   // Delete hold time values
   cntrlHoldTime->clear();

   // Setup hold time values
   if ( asicCnt != 0 ) {
      cntrlHoldTime->insertItem("8  * clkPeriod (8+)",0);
      cntrlHoldTime->insertItem("16 * clkPeriod (8+)",1);
      cntrlHoldTime->insertItem("24 * clkPeriod (8+)",2);
      cntrlHoldTime->insertItem("32 * clkPeriod",3);
      cntrlHoldTime->insertItem("40 * clkPeriod",4);
      cntrlHoldTime->insertItem("48 * clkPeriod (8+)",5);
      cntrlHoldTime->insertItem("56 * clkPeriod (8+)",6);
      cntrlHoldTime->insertItem("64 * clkPeriod",7);
      cntrlHoldTime->setCurrentItem(7);
   }
}


// Control Enable Of Buttons/Edits
void KpixGuiConfig::setEnabled ( bool enable, bool calEnable ) {
   if ( asicCnt == 0 ) enable = false;
   cfgAutoReadDis->setEnabled(enable&&asic[0]->getVersion()>7);
   cfgForceTemp->setEnabled(enable&&asic[0]->getVersion()>7);
   cfgDisableTemp->setEnabled(enable&&asic[0]->getVersion()>7);
   cfgAutoStatus->setEnabled(enable&&asic[0]->getVersion()>7);
   cntrlHoldTime->setEnabled(enable&&calEnable);
   cntrlMonSrc->setEnabled(enable);
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
   cntrlShortIntEn->setEnabled(enable&&asic[0]->getVersion()>7);
   cntrlDisPwrCycle->setEnabled(enable&&asic[0]->getVersion()>7);
   cntrlFeCurr->setEnabled(enable&&asic[0]->getVersion()>7);
   cntrlDiffTime->setEnabled(enable&&asic[0]->getVersion()>7);
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


// Update Display
void KpixGuiConfig::updateDisplay() {
   if ( asicCnt != 0 ) {
      cfgAutoReadDis->setChecked(asic[0]->getCfgAutoReadDis(false));
      cfgForceTemp->setChecked(asic[0]->getCfgForceTemp(false));
      cfgDisableTemp->setChecked(asic[0]->getCfgDisableTemp(false));
      cfgAutoStatus->setChecked(asic[0]->getCfgAutoStatus(false));
      dacRampThresh->setValue(asic[0]->getDacRampThresh(false));
      dacRangeThresh->setValue(asic[0]->getDacRangeThresh(false));
      dacEventThreshRef->setValue(asic[0]->getDacEventThreshRef(false));
      dacShaperBias->setValue(asic[0]->getDacShaperBias(false));
      dacDefaultAnalog->setValue(asic[0]->getDacDefaultAnalog(false));
      cntrlForceLowGain->setChecked(asic[0]->getCntrlForceLowGain(false));
      cntrlLeakNullDis->setChecked(asic[0]->getCntrlLeakNullDis(false));
      cntrlDoubleGain->setChecked(asic[0]->getCntrlDoubleGain(false));
      cntrlDisPerRst->setChecked(asic[0]->getCntrlDisPerRst(false));
      cntrlEnDcRst->setChecked(asic[0]->getCntrlEnDcRst(false));
      cntrlShortIntEn->setChecked(asic[0]->getCntrlShortIntEn(false));
      cntrlDisPwrCycle->setChecked(asic[0]->getCntrlDisPwrCycle(false));
      cntrlFeCurr->setCurrentItem(asic[0]->getCntrlFeCurr(false));
      cntrlDiffTime->setCurrentItem(asic[0]->getCntrlDiffTime(false));
      cntrlHoldTime->setCurrentItem(asic[0]->getCntrlHoldTime(false));
      cntrlMonSrc->setCurrentItem(asic[0]->getCntrlMonSrc(false));
      dacValueChanged();
   }
}


// Read Settings From Asic/Fpga class
void KpixGuiConfig::readConfig() {
   if ( asicCnt != 0 ) {
      asic[0]->getCfgAutoReadDis();
      asic[0]->getCfgForceTemp();
      asic[0]->getCfgDisableTemp();
      asic[0]->getCfgAutoStatus();
      asic[0]->getDacRampThresh();
      asic[0]->getDacRangeThresh();
      asic[0]->getDacEventThreshRef();
      asic[0]->getDacShaperBias();
      asic[0]->getDacDefaultAnalog();
      asic[0]->getCntrlForceLowGain();
      asic[0]->getCntrlLeakNullDis();
      asic[0]->getCntrlDoubleGain();
      asic[0]->getCntrlDisPerRst();
      asic[0]->getCntrlEnDcRst();
      asic[0]->getCntrlShortIntEn();
      asic[0]->getCntrlDisPwrCycle();
      asic[0]->getCntrlFeCurr();
      asic[0]->getCntrlDiffTime();
      asic[0]->getCntrlHoldTime();
      asic[0]->getCntrlMonSrc();
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiConfig::writeConfig() {

   unsigned int x;

   // Asic
   for (x=0; x < asicCnt; x++) {
      asic[x]->setCfgAutoReadDis(cfgAutoReadDis->isChecked());
      asic[x]->setCfgForceTemp(cfgForceTemp->isChecked());
      asic[x]->setCfgDisableTemp(cfgDisableTemp->isChecked());
      asic[x]->setCfgAutoStatus(cfgAutoStatus->isChecked());
      asic[x]->setDacRampThresh(dacRampThresh->value());
      asic[x]->setDacRangeThresh(dacRangeThresh->value());
      asic[x]->setDacEventThreshRef(dacEventThreshRef->value());
      asic[x]->setDacShaperBias(dacShaperBias->value());
      asic[x]->setDacDefaultAnalog(dacDefaultAnalog->value());
      asic[x]->setCntrlForceLowGain(cntrlForceLowGain->isChecked());
      asic[x]->setCntrlLeakNullDis(cntrlLeakNullDis->isChecked());
      asic[x]->setCntrlDoubleGain(cntrlDoubleGain->isChecked());
      asic[x]->setCntrlDisPerRst(cntrlDisPerRst->isChecked());
      asic[x]->setCntrlEnDcRst(cntrlEnDcRst->isChecked());
      asic[x]->setCntrlShortIntEn(cntrlShortIntEn->isChecked());
      asic[x]->setCntrlDisPwrCycle(cntrlDisPwrCycle->isChecked());
      asic[x]->setCntrlFeCurr((KpixAsic::KpixFeCurr)cntrlFeCurr->currentItem());
      asic[x]->setCntrlDiffTime((KpixAsic::KpixDiffTime)cntrlDiffTime->currentItem());
      asic[x]->setCntrlHoldTime((KpixAsic::KpixHoldTime)cntrlHoldTime->currentItem());
      asic[x]->setCntrlMonSrc((KpixAsic::KpixMonSrc)cntrlMonSrc->currentItem());
   }
}


