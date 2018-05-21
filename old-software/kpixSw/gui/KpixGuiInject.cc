//-----------------------------------------------------------------------------
// File          : KpixGuiInject.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Injection Settings.
// This is a class which builds off of the class created in
// KpixGuiInjectForm.ui
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
#include <qspinbox.h>
#include <qcombobox.h>
#include <qcheckbox.h>
#include <KpixAsic.h>
#include "KpixGuiInject.h"
using namespace std;


// Constructor
KpixGuiInject::KpixGuiInject ( QWidget *parent ) : KpixGuiInjectForm(parent) {

   this->asicCnt = 0;
   this->asic    = NULL;

   cal0Delay->setMaxValue(8191);
   cal1Delay->setMaxValue(8191);
   cal2Delay->setMaxValue(8191);
   cal3Delay->setMaxValue(8191);
}


// Set Asics
void KpixGuiInject::setAsics( KpixAsic **asic, unsigned int asicCnt ) {
   this->asicCnt = asicCnt;
   this->asic    = asic;
}


// Control Enable Of Buttons/Edits
void KpixGuiInject::setEnabled ( bool enable ) {
   if ( asicCnt == 0 ) enable = false;
   calCount->setEnabled(enable);
   cal0Delay->setEnabled(enable);
   cal1Delay->setEnabled(enable);
   cal2Delay->setEnabled(enable);
   cal3Delay->setEnabled(enable);
   dacCalib->setEnabled(enable);
   cntrlCalibHigh->setEnabled(enable);
   cntrlCalSrc->setEnabled(enable);
}


// Update DAC Setting
void KpixGuiInject::dacValueChanged() {

   stringstream temp;
   unsigned int value;

   value = dacCalib->value();

   // Display Values
   temp.str("");
   temp.precision(4);
   temp << (1e15*KpixAsic::computeCalibCharge(0,value,true,false)) << " fC";
   posChargeValue->setText(temp.str());
   temp.str("");
   temp.precision(4);
   temp << (1e15*KpixAsic::computeCalibCharge(0,value,true,true)) << " fC";
   posChargeHighValue->setText(temp.str());
   temp.str("");
   temp.precision(4);
   temp << (1e15*KpixAsic::computeCalibCharge(0,value,false,false)) << " fC";
   negChargeValue->setText(temp.str());
   temp.str("");
   temp.precision(4);
   temp << (1e15*KpixAsic::computeCalibCharge(0,value,false,true)) << " fC";
   negChargeHighValue->setText(temp.str());
}


// Update Display
void KpixGuiInject::updateDisplay() {

   unsigned int  calCountVal;
   unsigned int  cal0DelayVal;
   unsigned int  cal1DelayVal;
   unsigned int  cal2DelayVal;
   unsigned int  cal3DelayVal;

   if ( asicCnt != 0 ) {

      // Cal Data
      asic[0]->getCalibTime(&calCountVal,&cal0DelayVal,&cal1DelayVal,
                                         &cal2DelayVal,&cal3DelayVal,false);
      calCount->setValue(calCountVal);
      cal0Delay->setValue(cal0DelayVal);
      cal1Delay->setValue(cal1DelayVal);
      cal2Delay->setValue(cal2DelayVal);
      cal3Delay->setValue(cal3DelayVal);

      // Other Settings
      dacCalib->setValue(asic[0]->getDacCalib(false));
      cntrlCalSrc->setCurrentItem(asic[0]->getCntrlCalSrc(false));
      cntrlCalibHigh->setChecked(asic[0]->getCntrlCalibHigh(false));
      dacValueChanged();
   }
}


// Read Settings From Asic/Fpga class
void KpixGuiInject::readConfig() {

   unsigned int  calCountVal;
   unsigned int  cal0DelayVal;
   unsigned int  cal1DelayVal;
   unsigned int  cal2DelayVal;
   unsigned int  cal3DelayVal;

   if ( asicCnt != 0 ) {

      // Cal Data
      asic[0]->getCalibTime(&calCountVal,&cal0DelayVal,&cal1DelayVal,
                                         &cal2DelayVal,&cal3DelayVal);

      // Other Settings
      asic[0]->getDacCalib();
      asic[0]->getCntrlCalSrc();
      asic[0]->getCntrlCalibHigh();
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiInject::writeConfig() {

   unsigned int x;

   // Asic
   for (x=0; x < asicCnt; x++) {
      asic[x]->setCalibTime(calCount->value(), cal0Delay->value(), cal1Delay->value(),
                            cal2Delay->value(), cal3Delay->value());
      asic[x]->setDacCalib(dacCalib->value());
      asic[x]->setCntrlCalSrc((KpixAsic::KpixCalTrigSrc)(cntrlCalSrc->currentItem()));
      asic[x]->setCntrlCalibHigh(cntrlCalibHigh->isChecked());
   }
}


