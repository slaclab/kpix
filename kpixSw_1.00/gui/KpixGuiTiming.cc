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
#include "KpixGuiTiming.h"
using namespace std;


// Constructor
KpixGuiTiming::KpixGuiTiming ( QWidget *parent ) : KpixGuiTimingForm(parent) {
   this->asicCnt = 0;
   this->asic    = NULL;
   this->fpga    = NULL;
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
   acqClkPeriod->setEnabled(enable&&calEnable);
   digClkPeriod->setEnabled(false&&calEnable);
   readClkPeriod->setEnabled(false);
   resetOn->setEnabled(enable&&calEnable);
   resetOff->setEnabled(enable&&calEnable);
   leakNullOff->setEnabled(enable&&calEnable);
   offNullOff->setEnabled(enable&&calEnable);
   threshOff->setEnabled(enable&&calEnable);
   trigInhOff->setEnabled(enable);
   pwrUpOn->setEnabled(enable&&calEnable);
   deselDly->setEnabled(enable&&calEnable);
   bunchClkDly->setEnabled(enable&&calEnable);
   digDelay->setEnabled(enable&&calEnable);
}


// Update Clock Period & Timing Settings
// Ensure values are acceptable
void KpixGuiTiming::timeValueChanged() {

   int round,x,valOld[12],valNew[12];

   // Read values
   valOld[0]  = acqClkPeriod->value();
   valOld[1]  = digClkPeriod->value();
   valOld[2]  = readClkPeriod->value();
   valOld[3]  = resetOn->value();
   valOld[4]  = resetOff->value();
   valOld[5]  = leakNullOff->value();
   valOld[6]  = offNullOff->value();
   valOld[7]  = threshOff->value();
   valOld[8]  = pwrUpOn->value();
   valOld[9]  = deselDly->value();
   valOld[10] = bunchClkDly->value();
   valOld[11] = digDelay->value();

   // Process clock period values
   // Valid clock period values are 10ns - 320ns in 10ns increments
   for (x=0; x < 3; x++) {
      round = (valOld[x] / 10) * 10;
      if ( (valOld[x] - round) < 5 && valOld[x] != round ) valNew[x] = round + 10;
      else valNew[x] = round;
      if ( valNew[x] < 10  ) valNew[x] = 10;
      if ( valNew[x] > 320 ) valNew[x] = 320;
   }

   // Process timing settings
   // Must be a multiple of the acquisition clock period delay
   for (x=3; x < 12; x++) {
      round = (valOld[x] / valNew[0]) * valNew[0];
      if ( (valOld[x] - round) < 5 && valOld[x] != round ) valNew[x] = round + valNew[0];
      else valNew[x] = round;
   }

   // Set values back
   if ( valOld[0]  != valNew[0]  ) acqClkPeriod->setValue(valNew[0]);
   if ( valOld[1]  != valNew[1]  ) digClkPeriod->setValue(valNew[1]);
   if ( valOld[2]  != valNew[2]  ) readClkPeriod->setValue(valNew[2]);
   if ( valOld[3]  != valNew[3]  ) resetOn->setValue(valNew[3]);
   if ( valOld[4]  != valNew[4]  ) resetOff->setValue(valNew[4]);
   if ( valOld[5]  != valNew[5]  ) leakNullOff->setValue(valNew[5]);
   if ( valOld[6]  != valNew[6]  ) offNullOff->setValue(valNew[6]);
   if ( valOld[7]  != valNew[7]  ) threshOff->setValue(valNew[7]);
   if ( valOld[8]  != valNew[8]  ) pwrUpOn->setValue(valNew[8]);
   if ( valOld[9]  != valNew[9]  ) deselDly->setValue(valNew[9]);
   if ( valOld[10] != valNew[10] ) bunchClkDly->setValue(valNew[10]);
   if ( valOld[11] != valNew[11] ) digDelay->setValue(valNew[11]);
}


// Read Settings From Asic/Fpga class
void KpixGuiTiming::readConfig(bool readEn) {

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

   // Fpga
   if ( fpga != NULL ) {
      acqClkPeriod->setValue(fpga->getClockPeriod(readEn));
      digClkPeriod->setValue(fpga->getClockPeriod(readEn));
      readClkPeriod->setValue(fpga->getClockPeriod(readEn));
   }

   if ( asicCnt != 0 ) {

      // Asic
      asic[0]->getTiming ( &clkPeriodVal,  &resetOnVal,     &resetOffVal,   &leakNullOffVal,
                           &offNullOffVal, &threshOffVal,   &trigInhOffVal, &pwrUpOnVal,
                           &deselDlyVal,   &bunchClkDlyVal, &digDelayVal,   readEn);

      // Set Values
      resetOn->setValue(resetOnVal);
      resetOff->setValue(resetOffVal);
      leakNullOff->setValue(leakNullOffVal);
      offNullOff->setValue(offNullOffVal);
      threshOff->setValue(threshOffVal);
      trigInhOff->setValue(trigInhOffVal);
      pwrUpOn->setValue(pwrUpOnVal);
      deselDly->setValue(deselDlyVal);
      bunchClkDly->setValue(bunchClkDlyVal);
      digDelay->setValue(digDelayVal);
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiTiming::writeConfig(bool writeEn) {

   unsigned int x;

   // Fpga
   if ( fpga != NULL ) fpga->setClockPeriod(acqClkPeriod->value(),writeEn);

   // Asic
   for (x=0; x < asicCnt; x++)
      asic[x]->setTiming ( acqClkPeriod->value(), resetOn->value(),    resetOff->value(),   
                        leakNullOff->value(), offNullOff->value(), threshOff->value(),   
                        trigInhOff->value(),  pwrUpOn->value(),    deselDly->value(),    
                        bunchClkDly->value(), digDelay->value(),   true, writeEn);
}


