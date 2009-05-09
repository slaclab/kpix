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

   // Delete hold time values
   cntrlHoldTime->clear();

   // Setup hold time values based upon Kpix version
   if ( asicCnt != 0 ) {
      if ( asic[0]->getVersion() < 8 ) {
         cntrlHoldTime->insertItem("64 * clkPeriod",0);
         cntrlHoldTime->insertItem("40 * clkPeriod",1);
         cntrlHoldTime->insertItem("32 * clkPeriod",2);
      } else {
         cntrlHoldTime->insertItem("8  * clkPeriod",0);
         cntrlHoldTime->insertItem("16 * clkPeriod",1);
         cntrlHoldTime->insertItem("24 * clkPeriod",2);
         cntrlHoldTime->insertItem("32 * clkPeriod",3);
         cntrlHoldTime->insertItem("40 * clkPeriod",4);
         cntrlHoldTime->insertItem("48 * clkPeriod",5);
         cntrlHoldTime->insertItem("56 * clkPeriod",6);
         cntrlHoldTime->insertItem("64 * clkPeriod",7);
      }
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


// Read Settings From Asic/Fpga class
void KpixGuiConfig::readConfig(bool readEn) {
   if ( asicCnt != 0 ) {
      cfgAutoReadDis->setChecked(asic[0]->getCfgAutoReadDis(readEn));
      cfgForceTemp->setChecked(asic[0]->getCfgForceTemp(readEn));
      cfgDisableTemp->setChecked(asic[0]->getCfgDisableTemp(readEn));
      cfgAutoStatus->setChecked(asic[0]->getCfgAutoStatus(readEn));
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
      cntrlShortIntEn->setChecked(asic[0]->getCntrlShortIntEn(readEn));
      cntrlDisPwrCycle->setChecked(asic[0]->getCntrlDisPwrCycle(readEn));
      cntrlFeCurr->setCurrentItem(asic[0]->getCntrlFeCurr(readEn));
      cntrlDiffTime->setCurrentItem(asic[0]->getCntrlDiffTime(readEn));
      if ( asic[0]->getVersion() < 8 ) 
         cntrlHoldTime->setCurrentItem(asic[0]->getCntrlHoldTime(readEn)-1);
      else
         cntrlHoldTime->setCurrentItem(asic[0]->getCntrlHoldTime(readEn));
      dacValueChanged();
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiConfig::writeConfig(bool writeEn) {

   unsigned int x;

   // Asic
   for (x=0; x < asicCnt; x++) {
      asic[x]->setCfgAutoReadDis(cfgAutoReadDis->isChecked(),writeEn);
      asic[x]->setCfgForceTemp(cfgForceTemp->isChecked(),writeEn);
      asic[x]->setCfgDisableTemp(cfgDisableTemp->isChecked(),writeEn);
      asic[x]->setCfgAutoStatus(cfgAutoStatus->isChecked(),writeEn);
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
      asic[x]->setCntrlShortIntEn(cntrlShortIntEn->isChecked(),writeEn);
      asic[x]->setCntrlDisPwrCycle(cntrlDisPwrCycle->isChecked(),writeEn);
      asic[x]->setCntrlFeCurr(cntrlFeCurr->currentItem(),writeEn);
      asic[x]->setCntrlDiffTime(cntrlDiffTime->currentItem(),writeEn);

      // Older kpix versions have valid hold time values of 1,2,3 while newer
      // version supports 0-7
      if ( asic[x]->getVersion() < 8 )
         asic[x]->setCntrlHoldTime(cntrlHoldTime->currentItem()+1,writeEn);
      else
         asic[x]->setCntrlHoldTime(cntrlHoldTime->currentItem(),writeEn);
   }
}


