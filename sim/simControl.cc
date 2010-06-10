//-----------------------------------------------------------------------------
// File          : simContro.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/03/2009
// Project       : KPIX Simulation
//-----------------------------------------------------------------------------
// Description :
// Control the KPIX simulation
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/03/2009: created
//-----------------------------------------------------------------------------
#include <KpixFpga.h>
#include <KpixAsic.h>
#include <KpixBunchTrain.h>
#include <SidLink.h>
#include <iostream>
#include <iomanip>
using namespace std;

// Main Function
int main ( int argc, char **argv ) {

   SidLink        *sidLink;
   KpixFpga       *kpixFpga;
   KpixAsic       *kpixAsic[2];
   KpixBunchTrain *trainData;
   bool           cmdPerr, dataPerr, tempEn;
   unsigned char  tempValue;
   unsigned int   modes[1024];
   unsigned int   x;

   try {
      // Create simulation link
      sidLink = new SidLink();
      sidLink->linkOpen ( OUT_DIR "/sim_link.rx", OUT_DIR "/sim_link.tx" );

      // Create FPGA object, set defaults
      kpixFpga = new KpixFpga(sidLink);
      kpixFpga->fpgaDebug(true);

      // Send resets 
      kpixFpga->cmdResetMst();
      kpixFpga->cmdResetKpix();

      // Setup Kpix Version
      kpixFpga->setKpixVer  ( true, true );
      kpixFpga->setRawData  ( true, true );

      // Create the KPIX Devices
      kpixAsic[0] = new KpixAsic(sidLink,9,2,800,false);
      kpixAsic[1] = new KpixAsic(sidLink,9,3,0,true);

      // Enable debugging
      kpixAsic[0]->kpixDebug(true);
      kpixAsic[1]->kpixDebug(true);

      // Set Defaults
      kpixAsic[0]->setCfgAutoStatus ( true, true );

      // Set timing values
      kpixAsic[0]->setTiming ( 50,        // Clock Period
                               700,       // Reset On Time
                               120000,    // Reset off Time
                               200,       // Leakage Null Off
                               100500,    // Offset Null Off
                               101500,    // Thresh Off
                               0,         // Trig Inhibit Off (bunch periods)
                               900,       // Power Up On
                               6900,      // Desel Sequence
                               467500,    // Bunch Clock Delay
                               10000,     // Digitization Delay
                               2890,      // Bunch Clock Count
                               true,      // Checking Enable
                               true       // Write
                             );

      // Real asic only settings, don't write to fpga core
      kpixAsic[0]->setCntrlCalibHigh    ( false,  false );
      kpixAsic[0]->setCntrlCalDacInt    ( true,   false );
      kpixAsic[0]->setCntrlForceLowGain ( false,  false );
      kpixAsic[0]->setCntrlLeakNullDis  ( true,   false );
      kpixAsic[0]->setCntrlDoubleGain   ( false,  false );
      kpixAsic[0]->setCntrlNearNeighbor ( false,  false );
      kpixAsic[0]->setCntrlPosPixel     ( true,   false );
      kpixAsic[0]->setCntrlDisPerRst    ( true,   false );
      kpixAsic[0]->setCntrlEnDcRst      ( true,   false );
      kpixAsic[0]->setCntrlCalSrcCore   ( true,   false );
      kpixAsic[0]->setCntrlTrigSrcCore  ( false,  false );
      kpixAsic[0]->setCntrlShortIntEn   ( false,  false );
      kpixAsic[0]->setCntrlDisPwrCycle  ( false,  false );
      kpixAsic[0]->setCntrlFeCurr       ( 4,      false );
      kpixAsic[0]->setCntrlHoldTime     ( 7,      true  ); // Only write control register once

      // Setup DACs
      kpixAsic[0]->setDacCalib          ( (unsigned char)0x80, true ); // was 0x00, new 0x80
      kpixAsic[0]->setDacRampThresh     ( (unsigned char)0xE0, true );
      kpixAsic[0]->setDacRangeThresh    ( (unsigned char)0x3E, true );
      kpixAsic[0]->setDacDefaultAnalog  ( (unsigned char)0xBD, true );
      kpixAsic[0]->setDacEventThreshRef ( (unsigned char)0x50, true );
      kpixAsic[0]->setDacShaperBias     ( (unsigned char)0x78, true );

      // Set Threshold DACs
      kpixAsic[0]->setDacThreshRangeA ( (unsigned char)0xF0, // Range A Reset Inhibit Threshold
                                        (unsigned char)0xF0, // Range A Trigger Threshold
                                        true);
      kpixAsic[0]->setDacThreshRangeB ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                                        (unsigned char)0x00, // Range A Trigger Threshold
                                        true);

      // Init Channel Modes
      for(x=0; x < 1024; x++) {
         if ( x == 0x0A0  ) modes[x] = KpixChanDisable;
         else modes[x] = KpixChanThreshACal;
      }
      kpixAsic[0]->setChannelModeArray(modes,true);

      // Setup calibration strobes
      kpixAsic[0]->setCalibTime ( 4,      // Calibration Count
                                  0x100,  // Calibration 0 Delay
                                  0x20,   // Calibration 1 Delay
                                  0x20,   // Calibration 2 Delay
                                  0x20,   // Calibration 3 Delay
                                  true);

      // Get Status
      kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);

      // Send start command
      kpixAsic[0]->cmdCalibrate(true);

      // Get bunch train data
      trainData = new KpixBunchTrain ( sidLink, true );

      // Clean Up
      delete trainData;
      delete kpixAsic[0];
      delete kpixAsic[1];
      delete kpixFpga;
      delete sidLink;

   } catch(string error) { cout << "Got Error: " << error << endl; }
}

