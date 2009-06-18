//-----------------------------------------------------------------------------
// File          : KpixGuiStatus.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX FPGA & ASIC Status
// This is a class which builds off of the class created in
// KpixGuiStatusForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 04/29/2009: Seperate methods for display update and data read.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include "KpixGuiStatus.h"
using namespace std;


// Constructor
KpixGuiStatus::KpixGuiStatus ( QWidget *parent ) : KpixGuiStatusForm(parent) {
   this->asicCnt = 0;
   this->asic    = NULL;
   this->fpga    = NULL;
}


// Set Asics
void KpixGuiStatus::setAsics (KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga) {

   stringstream temp;
   unsigned int x;

   // Delete old columns
   if ( this->asicCnt > 0 ) for ( x=0; x < (this->asicCnt-1); x++ ) {
      statusTable->removeRow(x);
   }

   // Store new list
   this->asicCnt = asicCnt;
   this->asic    = asic;
   this->fpga    = fpga;

   // Set column Widths
   statusTable->setColumnWidth(0,60);
   statusTable->setColumnWidth(1,60);
   statusTable->setColumnWidth(2,115);
   statusTable->setColumnWidth(3,70);
   statusTable->setColumnWidth(4,70);

   // Asic Count is non zero
   if ( asicCnt > 1 ) {

      // Set number of rows
      statusTable->setNumRows(asicCnt-1);

      // For Each Asic
      for (x=0; x < asicCnt-1; x++) {

         // Address;
         temp.str("");
         temp << "0x" << hex << setw(2) << setfill('0') << asic[x]->getAddress();
         statusTable->setText(x,0,temp.str());
      }
   }
}


// Update display
void KpixGuiStatus::updateDisplay() {

   stringstream  temp;
   bool          cmdPerr, dataPerr, tempEn;
   unsigned char tempValue;
   unsigned int  x;

   if ( fpga != NULL ) {
      temp.str("");
      temp << "0x" << hex << setw(8) << setfill('0') << fpga->getVersion(false);
      fpgaVersion->setText(temp.str());
      temp.str("");
      temp << "0x" << hex << setw(8) << setfill('0') << fpga->getJumpers(false);
      fpgaJumpers->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getCheckSumErrors(false);
      checkSumErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getRspParErrors(false);
      rspParErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getDataParErrors(false);
      dataParErrors->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getDeadCount(false);
      deadCount->setText(temp.str());
      temp.str("");
      temp << dec << (int)fpga->getTrainNumber(false);
      trainNumber->setText(temp.str());
   }

   if ( asicCnt > 0 ) for (x=0; x < asicCnt-1; x++) {
      asic[x]->getStatus(&cmdPerr,&dataPerr,&tempEn,&tempValue,false);

      // Temp / Version Flag
      if ( tempEn ) statusTable->setText(x,1,"Temp");
      else statusTable->setText(x,1,"Version");

      // Temp / Version Value
      temp.str("");
      temp << "0x" << hex << setw(2) << setfill('0') << (int)tempValue;
      if ( tempEn ) temp << " (" << KpixAsic::convertTemp(tempValue) << " degC)";
      statusTable->setText(x,2,temp.str());

      // Command Parity Error
      if ( cmdPerr ) statusTable->setText(x,3,"Error");
      else statusTable->setText(x,3,"Ok");

      // Data Parity Error
      if ( dataPerr ) statusTable->setText(x,4,"Error");
      else statusTable->setText(x,4,"Ok");
   }
}


// Read Counters
void KpixGuiStatus::readStatus() {

   bool          cmdPerr, dataPerr, tempEn;
   unsigned char tempValue;
   unsigned int  x;

   if ( fpga != NULL ) {
      fpga->getVersion();
      fpga->getJumpers();
      fpga->getCheckSumErrors();
      fpga->getRspParErrors();
      fpga->getDataParErrors();
      fpga->getDeadCount();
      fpga->getTrainNumber();
   }

   if ( asicCnt > 0 ) for (x=0; x < asicCnt-1; x++) 
      asic[x]->getStatus(&cmdPerr,&dataPerr,&tempEn,&tempValue);
}

