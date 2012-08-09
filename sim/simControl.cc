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
#include <KpixRunWrite.h>
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
   KpixRunWrite   *kpixRunWrite;
   uint           gain;
   uint           cal;
   bool           cmdPerr, dataPerr, tempEn;
   unsigned char  tempValue;
   KpixAsic::KpixChanMode   modes[1024];
   unsigned int   x;
   char           *eptr;

   if ( argc != 3 ) {
      cout << "Usage: simControl gain cal" << endl;
      cout << "       gain = 1 for high, 0 for normal" << endl;
      cout << "       cal  = cal input dac value" << endl;
      return 1;
   }

   gain = (uint)strtoul(argv[1],&eptr,0);
   cal  = (uint)strtoul(argv[2],&eptr,0);

   cout << "Using gain=" << dec << gain << ", cal=0x" << hex << cal << endl;

   try {

      // Create simulation link
      sidLink = new SidLink();
      sidLink->linkOpen ( OUT_DIR "/sim_link.rx", OUT_DIR "/sim_link.tx" );

      // Create FPGA object, set defaults
      kpixFpga = new KpixFpga(sidLink);
      kpixFpga->fpgaDebug(true);

      // Send resets 
      kpixFpga->cmdResetMst();
      kpixFpga->setClockPeriod(50);
      kpixFpga->setClockPeriodDig(50);
      kpixFpga->setClockPeriodRead(50);
      kpixFpga->setClockPeriodIdle(50);
      kpixFpga->cmdResetKpix();

      // Setup Kpix Version
      kpixFpga->setKpixVer  ( false, true ); // False = 1024 channels, true = 512 channels
      kpixFpga->setRawData  ( true,  true );

      // Create the KPIX Devices
      kpixAsic[0] = new KpixAsic(sidLink,11,2,900,false);
      kpixAsic[1] = new KpixAsic(sidLink,11,3,0,true);

      // Enable debugging
      kpixAsic[0]->kpixDebug(true);
      kpixAsic[1]->kpixDebug(true);
      kpixAsic[0]->disableVerify(false);
      kpixAsic[1]->disableVerify(false);
      //kpixAsic[0]->disableVerify(true);
      //kpixAsic[1]->disableVerify(true);

      kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);


      // Set Defaults
      kpixAsic[0]->setCfgTestData       ( false,          false   );
      kpixAsic[0]->setCfgAutoReadDis    ( false,          false   );
      kpixAsic[0]->setCfgForceTemp      ( false,          false   );
      kpixAsic[0]->setCfgDisableTemp    ( false,          false   );
      kpixAsic[0]->setCfgAutoStatus     ( true,           true    );

      // Set timing values
      for (x=0; x<2; x++) {
         kpixAsic[x]->setTiming ( 50,        // Clock Period
                                  700,       // Reset On Time
                                  120000,    // Reset off Time
                                  200,       // Leakage Null Off
                                  100500,    // Offset Null Off
                                  101500,    // Thresh Off
                                  100,       // Trig Inhibit Off (bunch periods)
                                  900,       // Power Up On
                                  6900,      // Desel Sequence
                                  467500,    // Bunch Clock Delay
                                  10000,     // Digitization Delay
                                  2890,      // Bunch Clock Count
                                  true,      // Checking Enable
                                  true       // Write
                                );
      }


      // Real asic only settings, don't write to fpga core
      kpixAsic[0]->setCntrlDoubleGain   ( (gain==1),  false );
      kpixAsic[0]->setCntrlCalibHigh    ( false,  false );
      kpixAsic[0]->setCntrlCalDacInt    ( true,   false );
      kpixAsic[0]->setCntrlForceLowGain ( false,  false );
      kpixAsic[0]->setCntrlLeakNullDis  ( true,   false );
      kpixAsic[0]->setCntrlNearNeighbor ( false,  false );
      kpixAsic[0]->setCntrlPosPixel     ( true,   false );
      kpixAsic[0]->setCntrlDisPerRst    ( true,   false );
      kpixAsic[0]->setCntrlEnDcRst      ( true,   false );
      kpixAsic[0]->setCntrlCalSrc       ( KpixAsic::KpixInternal, false );
      kpixAsic[0]->setCntrlTrigSrc      ( KpixAsic::KpixDisable,  false );
      kpixAsic[0]->setCntrlShortIntEn   ( false,  false );
      kpixAsic[0]->setCntrlDisPwrCycle  ( false,  false );
      kpixAsic[0]->setCntrlTrigDisable  ( false,  false );
      kpixAsic[0]->setCntrlMonSrc       ( KpixAsic::KpixMonNone,  false );
      kpixAsic[0]->setCntrlFeCurr       ( KpixAsic::FeCurr_121uA, false );
      kpixAsic[0]->setCntrlHoldTime     ( KpixAsic::HoldTime_64x, true  ); // Only write control register once

      // Setup DACs
      kpixAsic[0]->setDacRampThresh     ( (unsigned char)0xE0, true );
      kpixAsic[0]->setDacRangeThresh    ( (unsigned char)0x3E, true );
      kpixAsic[0]->setDacDefaultAnalog  ( (unsigned char)0xBD, true );
      kpixAsic[0]->setDacEventThreshRef ( (unsigned char)0x50, true );
      kpixAsic[0]->setDacShaperBias     ( (unsigned char)0x78, true );
      kpixAsic[0]->setDacCalib          ( (unsigned char)cal,  true );

      // Set Threshold DACs
      kpixAsic[0]->setDacThreshRangeA ( (unsigned char)0xF0, // Range A Reset Inhibit Threshold
                                        (unsigned char)0xF0, // Range A Trigger Threshold
                                        true);
      kpixAsic[0]->setDacThreshRangeB ( (unsigned char)0x00, // Range A Reset Inhibit Threshold
                                        (unsigned char)0x00, // Range A Trigger Threshold
                                        true);

      // Init Channel Modes
      for(x=0; x < 1024; x++) {
         modes[x] = KpixAsic::KpixChanThreshACal;
      }
      //modes[31]  = KpixAsic::KpixChanDisable;
      //modes[62]  = KpixAsic::KpixChanDisable;
      //modes[95]  = KpixAsic::KpixChanDisable;
      //modes[126] = KpixAsic::KpixChanDisable;
      //modes[159] = KpixAsic::KpixChanDisable;
      //modes[191] = KpixAsic::KpixChanDisable;
      //modes[223] = KpixAsic::KpixChanDisable;
      //modes[255] = KpixAsic::KpixChanDisable;
      //modes[286] = KpixAsic::KpixChanDisable;
      //modes[319] = KpixAsic::KpixChanDisable;
      //modes[350] = KpixAsic::KpixChanDisable;
      kpixAsic[0]->setChannelModeArray(modes,true);

      // Setup calibration strobes
      kpixAsic[0]->setCalibTime ( 4,      // Calibration Count
                                  0x28A,  // Calibration 0 Delay
                                  0x28A,  // Calibration 1 Delay
                                  0x28A,  // Calibration 2 Delay
                                  0x28A,  // Calibration 3 Delay
                                  true);

      // Get Status
      kpixAsic[0]->getStatus (&cmdPerr, &dataPerr, &tempEn, &tempValue);

      // Create Run Write Class To Store Data & Settings
      kpixRunWrite = new KpixRunWrite ("sim_data.root","run","simulation","");
      kpixRunWrite->addFpga  ( kpixFpga );
      for (x=0; x<2; x++) kpixRunWrite->addAsic (kpixAsic[x]);

      // Send start command
      kpixAsic[0]->cmdCalibrate(true);

      // Get bunch train data
      trainData = new KpixBunchTrain ( sidLink, true );
      kpixRunWrite->addBunchTrain(trainData);

      // Clean Up
      delete kpixRunWrite;
      delete trainData;
      delete kpixAsic[0];
      delete kpixAsic[1];
      delete kpixFpga;
      delete sidLink;

   } catch(string error) { cout << "Got Error: " << error << endl; }
}

