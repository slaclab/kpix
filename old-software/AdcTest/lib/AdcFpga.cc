//-----------------------------------------------------------------------------
// File          : AdcFpga.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 07/06/2009
//-----------------------------------------------------------------------------
// Description :
// ADC Test FPGA drive code.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/06/2009: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <unistd.h>
#include <stdlib.h>
#include "AdcFpga.h"
#include "SidLink.h"
using namespace std;


// Private method to write register value to Fpga
void AdcFpga::regWrite ( unsigned int address, unsigned int data ) {

   unsigned short frameData[4];

   // Link has not been set
   if ( sidLink == NULL ) throw string("AdcFpga::regWrite -> FPGA Link Not Open");

   // Format command, word 0
   frameData[0]  = (address & 0x00FF);
   frameData[0] |= 0x0100; // Write

   // Set data portion
   frameData[1] = (data & 0xFFFF);
   frameData[2] = (data >> 16) & 0xFFFF;

   // Checksum 
   frameData[3] = ((frameData[0] + frameData[1] + frameData[2]) & 0xFFFF);

   // Write data
   sidLink->linkFpgaWrite(frameData,4);
}


// Private method to read register value from Kpix
unsigned int AdcFpga::regRead ( unsigned int address ) {

   unsigned short frameWrData[4];
   unsigned short frameRdData[4];
   unsigned int   data;

   // Link has not been set
   if ( sidLink == NULL ) throw string("AdcFpga::regRead -> FPGA Link Not Open");

   // Format command, word 0
   frameWrData[0] = (address & 0x00FF);

   // word 1 & 2 are 0
   frameWrData[1] = 0;
   frameWrData[2] = 0;

   // Checksum 
   frameWrData[3] = frameWrData[0];

   // Write data
   sidLink->linkFpgaWrite(frameWrData,4);

   // Read response data
   sidLink->linkFpgaRead(frameRdData,4);

   // Check for checksum error
   if ( frameRdData[3] != ((frameRdData[2] + frameRdData[1] + frameRdData[0]) & 0xFFFF) ) 
      throw string("AdcFpga::regRead -> Checksum Error");

   // Mark sure first word matches
   if ( frameRdData[0] != frameWrData[0] )
      throw string("AdcFpga::regRead -> Command Data Mismatch");

   // Update read data
   data  = (frameRdData[1] & 0x0000FFFF);
   data |= ((frameRdData[2] << 16) & 0xFFFF0000);

   return(data);
}


// Kpix FPGA Constructor
// Pass SID Link Object
AdcFpga::AdcFpga ( SidLink *sidLink ) {

   // SID Link Object
   this->sidLink = sidLink;
}


// Method to get FPGA Version
unsigned int AdcFpga::getVersion ( ) { 
   unsigned int ret = regRead(0x0);
   cout << "AdcFpga::getVersion -> Version=";
   cout << hex << setfill('0') << setw(8) << ret << ".\n";
   return(ret);
}


// Method to set ADC select flag
void AdcFpga::setAdcSelect ( unsigned int adcSel ) {
   regWrite(0x1,adcSel);
   cout << "AdcFpga::setAdcSelect -> Value=";
   cout << hex << setfill('0') << setw(8) << adcSel << ".\n";
}


// Method to get ADC select flag
unsigned int AdcFpga::getAdcSelect ( ) {

   unsigned int ret = regRead(0x1);
   cout << "AdcFpga::getAdcSelect -> Value=";
   cout << hex << setfill('0') << setw(8) << ret << ".\n";
   return(ret);
}


// Method to get ADC value and generate an iteration
unsigned int AdcFpga::getAdcValue ( bool debug ) {

   unsigned int ret = regRead(0x7);

   if ( debug ) {
      cout << "AdcFpga::getAdcValue -> Value=";
      cout << hex << setfill('0') << setw(8) << ret << ".\n";
   }
   return(ret);
}


