//-----------------------------------------------------------------------------
// File          : KpixGuiTiming.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Timing Settings.
// This is a class which builds off of the class created in
// KpixGuiTimingForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
// 04/29/2009: Seperate methods for display update and data read.
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
// 12/07/2009: Moved KPIX8 adjustments to API.
// 04/22/2010: Added idle clock rate
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qcombobox.h>
#include <qlabel.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include "KpixGuiTiming.h"
using namespace std;


// Constructor
KpixGuiTiming::KpixGuiTiming ( unsigned int rateLimit, QWidget *parent ) : KpixGuiTimingForm(parent) {
   this->asicCnt = 0;
   this->asic    = NULL;
   this->fpga    = NULL;

   // Set default rate limit
   switch(rateLimit) {
      case  0: this->rateLimit->setCurrentItem(0); break;
      case  5: this->rateLimit->setCurrentItem(1); break;
      case 10: this->rateLimit->setCurrentItem(2); break;
      case 15: this->rateLimit->setCurrentItem(3); break;
      case 20: this->rateLimit->setCurrentItem(4); break;
      default: this->rateLimit->setCurrentItem(0); break;
   }
   setEnabled(false,false);
}


// Set Asics
void KpixGuiTiming::setAsics (KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga) {
   this->asicCnt = asicCnt;
   this->asic    = asic;
   this->fpga    = fpga;
}


// Control Enable Of Buttons/Edits
void KpixGuiTiming::setEnabled ( bool enable, bool calEnable ) {
   if ( asicCnt == 0 ) enable = false;

   if ( asicCnt != 0 && asic[0]->getVersion() == 8 ) {  
      acqClkPeriod->setEnabled(false);
      digClkPeriod->setEnabled(false);
      idleClkPeriod->setEnabled(false);
      readClkPeriod->setEnabled(false);
      resetOn->setEnabled(false);
      resetOff->setEnabled(false);
      leakNullOff->setEnabled(false);
      offNullOff->setEnabled(false);
      disChecks->setEnabled(false);
   }

   else {
      acqClkPeriod->setEnabled(enable&&calEnable);
      digClkPeriod->setEnabled(enable&&calEnable);
      readClkPeriod->setEnabled(enable);
      idleClkPeriod->setEnabled(enable);
      resetOn->setEnabled(enable&&calEnable);
      resetOff->setEnabled(enable&&calEnable);
      leakNullOff->setEnabled(enable&&calEnable);
      offNullOff->setEnabled(enable&&calEnable);
   }

   threshOff->setEnabled(enable&&calEnable);
   trigInhOff->setEnabled(enable);
   pwrUpOn->setEnabled(enable&&calEnable);
   deselDly->setEnabled(enable&&calEnable);
   bunchClkDly->setEnabled(enable&&calEnable);
   digDelay->setEnabled(enable&&calEnable);
   bunchCount->setEnabled(enable&&(asic[0]->getVersion()>7));
   rateLimit->setEnabled(enable);
}


// Update Clock Period & Timing Settings
// Ensure values are acceptable
void KpixGuiTiming::timeValueChanged() {

   int round,x,valOld[12],valNew[12];

   // Read values
   valOld[0]  = acqClkPeriod->value();
   valOld[1]  = digClkPeriod->value();
   valOld[2]  = readClkPeriod->value();
   valOld[3]  = idleClkPeriod->value();
   valOld[4]  = resetOn->value();
   valOld[5]  = resetOff->value();
   valOld[6]  = leakNullOff->value();
   valOld[7]  = offNullOff->value();
   valOld[8]  = threshOff->value();
   valOld[9]  = pwrUpOn->value();
   valOld[10] = deselDly->value();
   valOld[11] = bunchClkDly->value();
   valOld[12] = digDelay->value();

   // Process clock period values
   // Valid clock period values are 10ns - 320ns in 10ns increments
   for (x=0; x < 4; x++) {
      round = (valOld[x] / 10) * 10;
      if ( (valOld[x] - round) < 5 && valOld[x] != round ) valNew[x] = round + 10;
      else valNew[x] = round;
      if ( valNew[x] < 10  ) valNew[x] = 10;
      if ( valNew[x] > 320 ) valNew[x] = 320;
   }

   // Process timing settings
   // Must be a multiple of the acquisition clock period delay
   for (x=4; x < 13; x++) {
      round = (valOld[x] / valNew[0]) * valNew[0];
      if ( (valOld[x] - round) < 5 && valOld[x] != round ) valNew[x] = round + valNew[0];
      else valNew[x] = round;
   }

   // Set values back
   if ( valOld[0]  != valNew[0]  ) acqClkPeriod->setValue(valNew[0]);
   if ( valOld[1]  != valNew[1]  ) digClkPeriod->setValue(valNew[1]);
   if ( valOld[2]  != valNew[2]  ) readClkPeriod->setValue(valNew[2]);
   if ( valOld[3]  != valNew[3]  ) idleClkPeriod->setValue(valNew[3]);

   if ( valOld[4]  != valNew[4]  ) resetOn->setValue(valNew[4]);
   if ( valOld[5]  != valNew[5]  ) resetOff->setValue(valNew[5]);
   if ( valOld[6]  != valNew[6]  ) leakNullOff->setValue(valNew[6]);
   if ( valOld[7]  != valNew[7]  ) offNullOff->setValue(valNew[7]);
   if ( valOld[8]  != valNew[8]  ) threshOff->setValue(valNew[8]);
   if ( valOld[9]  != valNew[9]  ) pwrUpOn->setValue(valNew[9]);
   if ( valOld[10] != valNew[10] ) deselDly->setValue(valNew[10]);
   if ( valOld[11] != valNew[11] ) bunchClkDly->setValue(valNew[11]);
   if ( valOld[12] != valNew[12] ) digDelay->setValue(valNew[12]);
}


// Update Display
void KpixGuiTiming::updateDisplay() {

   unsigned int  clkPeriodVal;
   unsigned int  resetOnVal;
   unsigned int  resetOffVal;
   unsigned int  leakNullOffVal;
   unsigned int  offNullOffVal;
   unsigned int  threshOffVal;
   unsigned int  trigInhOffVal;
   unsigned int  pwrUpOnVal;
   unsigned int  deselDlyVal;
   unsigned int  bunchClkDlyVal;
   unsigned int  digDelayVal;
   unsigned int  bunchCountVal;

   // Fpga
   if ( fpga != NULL ) {
      acqClkPeriod->setValue(fpga->getClockPeriod(false));
      digClkPeriod->setValue(fpga->getClockPeriodDig(false));
      readClkPeriod->setValue(fpga->getClockPeriodRead(false));
      idleClkPeriod->setValue(fpga->getClockPeriodIdle(false));
   }

   if ( asicCnt != 0 ) {

      // Asic
      asic[0]->getTiming ( &clkPeriodVal,  &resetOnVal,     &resetOffVal,   &leakNullOffVal,
                           &offNullOffVal, &threshOffVal,   &trigInhOffVal, &pwrUpOnVal,
                           &deselDlyVal,   &bunchClkDlyVal, &digDelayVal,   &bunchCountVal,
                           false, rawTrigInh->isChecked());

      resetOn->setValue(resetOnVal);
      resetOff->setValue(resetOffVal);
      leakNullOff->setValue(leakNullOffVal);
      offNullOff->setValue(offNullOffVal);
      deselDly->setValue(deselDlyVal);
      bunchClkDly->setValue(bunchClkDlyVal);
      digDelay->setValue(digDelayVal);
      threshOff->setValue(threshOffVal);
      trigInhOff->setValue(trigInhOffVal);
      pwrUpOn->setValue(pwrUpOnVal);
      bunchCount->setValue(bunchCountVal);
   }
}


// Read Settings From Asic/Fpga class
void KpixGuiTiming::readConfig() {

   unsigned int  clkPeriodVal;
   unsigned int  resetOnVal;
   unsigned int  resetOffVal;
   unsigned int  leakNullOffVal;
   unsigned int  offNullOffVal;
   unsigned int  threshOffVal;
   unsigned int  trigInhOffVal;
   unsigned int  pwrUpOnVal;
   unsigned int  deselDlyVal;
   unsigned int  bunchClkDlyVal;
   unsigned int  digDelayVal;
   unsigned int  bunchCountVal;

   // Fpga
   if ( fpga != NULL ) {
      fpga->getClockPeriod();
      fpga->getClockPeriodDig();
      fpga->getClockPeriodRead();
      fpga->getClockPeriodIdle();
   }

   if ( asicCnt != 0 ) {

      // Asic
      asic[0]->getTiming ( &clkPeriodVal,  &resetOnVal,     &resetOffVal,   &leakNullOffVal,
                           &offNullOffVal, &threshOffVal,   &trigInhOffVal, &pwrUpOnVal,
                           &deselDlyVal,   &bunchClkDlyVal, &digDelayVal,   &bunchCountVal,
                           true,rawTrigInh->isChecked());
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiTiming::writeConfig() {

   unsigned int x;

   // Fpga
   if ( fpga != NULL ) {
      fpga->setClockPeriod(acqClkPeriod->value());
      fpga->setClockPeriodDig(digClkPeriod->value());
      fpga->setClockPeriodRead(readClkPeriod->value());
      fpga->setClockPeriodIdle(idleClkPeriod->value());
   }

   // Asic
   for (x=0; x < asicCnt; x++)
      asic[x]->setTiming ( acqClkPeriod->value(), resetOn->value(),    resetOff->value(),   
                        leakNullOff->value(), offNullOff->value(), threshOff->value(),   
                        trigInhOff->value(),  pwrUpOn->value(),    deselDly->value(),    
                        bunchClkDly->value(), digDelay->value(),   bunchCount->value(),
                        !disChecks->isChecked(), true, rawTrigInh->isChecked() );
}


// Get rate limit value, zero for none
// Returned value is in uS
unsigned int KpixGuiTiming::getRateLimit() {
   switch(rateLimit->currentItem()) {
      case 0:  return(0);      
      case 1:  return(200000); // 5Hz
      case 2:  return(100000); // 10Hz
      case 3:  return(66666);  // 15Hz
      case 4:  return(50000);  // 20Hz
      default: return(0);
   }
}



// Raw trigger inhibit check box changed, update range for 
// trigger inhibit box
void KpixGuiTiming::rawTrigInh_stateChanged() {

   // Raw Mode
   if ( rawTrigInh->isChecked() ) {
      trigInhOff->setMaxValue(1000000000);
      bcLabel->setText("nS");
   }

   // Bunch Count Mode
   else {
      trigInhOff->setMaxValue(8191);
      bcLabel->setText("Bunches");
   }

   // Update display
   updateDisplay();
}

