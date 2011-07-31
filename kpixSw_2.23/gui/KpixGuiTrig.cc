//-----------------------------------------------------------------------------
// File          : KpixGuiTrig.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of KPIX Trigger Settings.
// This is a class which builds off of the class created in
// KpixGuiTrigForm.ui
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
#include <stdlib.h>
#include <qlineedit.h>
#include <qtable.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include "KpixGuiTrig.h"
using namespace std;


// Constructor
KpixGuiTrig::KpixGuiTrig ( QWidget *parent ) : KpixGuiTrigForm(parent) {
   this->asicCnt = 0;
   this->asic    = NULL;
   this->fpga    = NULL;
   this->thold   = NULL;
   this->mode    = NULL;
   setEnabled(false);
}


// Set Asics
void KpixGuiTrig::setAsics (KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga) {

   unsigned int x,y,z;
   stringstream temp;

   // Delete old columns
   if ( this->asicCnt != 0 ) for ( x=0; x < (this->asicCnt-1); x++ ) {
      threshTable->removeColumn(x);
      channelMode->removeColumn(x);
   }
   if ( thold != NULL ) free(thold); thold=NULL;
   if ( mode  != NULL ) free(mode); mode=NULL;

   // Store new list
   this->asicCnt = asicCnt;
   this->asic    = asic;
   this->fpga    = fpga;

   // Asic Count is non zero
   if ( asicCnt > 1 ) {

      // Address Row Is Read Only
      threshTable->setRowReadOnly(0,true);

      // Create combo boxes
      thold = (QComboBox **) malloc(sizeof(QComboBox*)*(asicCnt-1)*4);
      mode  = (QComboBox **) malloc(sizeof(QComboBox*)*(asicCnt-1)*1024);
      if ( thold == NULL || mode == NULL ) throw(string("KpixGuiTrig::KpixGuiTrig -> Malloc error"));

      // Set number of columns
      threshTable->setNumCols(asicCnt-1);
      channelMode->setNumCols(asicCnt-1);
      channelMode->setNumRows(asic[0]->getChCount());

      // For Each Asic
      for (x=0; x < asicCnt-1; x++) {

         // Set Column Titles
         temp.str("");
         temp << "Kpix " << dec << x;
         threshTable->horizontalHeader()->setLabel(x,temp.str());
         channelMode->horizontalHeader()->setLabel(x,temp.str());

         // Adjust column widths
         channelMode->setColumnWidth(x,75);

         // Address;
         temp.str("");
         temp << "0x" << hex << setw(2) << setfill('0') << asic[x]->getAddress();
         threshTable->setText(0,x,temp.str());

         // Threshold Values
         for (y=0; y < 4; y++) {
            thold[x*4+y] = new QComboBox(threshTable);
            threshTable->setCellWidget(y+1,x,thold[x*4+y]);
            for (z=0; z < 256; z++) {
               temp.str("");
               temp << "0x" << hex << setw(2) << setfill('0') << z << " - ";
               temp.precision(4);
               temp << KpixAsic::dacToVolt((unsigned char)z) << " V";
               thold[x*4+y]->insertItem(temp.str(),z);
            }
         }

         // Mode Values
         for (y=0; y < asic[x]->getChCount(); y++) {
            temp.str("");
            temp << dec << y;
            channelMode->verticalHeader()->setLabel(y,temp.str());
            mode[x*1024+y] = new QComboBox(channelMode);
            channelMode->setCellWidget(y,x,mode[x*1024+y]);
            mode[x*1024+y]->insertItem("Thresh B",0);
            mode[x*1024+y]->insertItem("Disable",1);
            mode[x*1024+y]->insertItem("Thresh A",2);
            mode[x*1024+y]->insertItem("Calib",3);
         }
      }
   }
   setEnabled(false);
}


// Deconstructor
KpixGuiTrig::~KpixGuiTrig() {
   if ( thold != NULL ) free(thold);
   if ( mode  != NULL ) free(mode);
}


// Control Enable Of Buttons/Edits
void KpixGuiTrig::setEnabled ( bool enable ) {
   unsigned int x,y;
   if ( asicCnt == 0 ) enable = false;
   cntrlNearNeighbor->setEnabled(enable);
   cntrlTrigSrc->setEnabled(enable);
   cntrlTrigDisable->setEnabled(enable);
   trigSource->setEnabled(enable);
   trigExpand->setEnabled(enable);
   trigMask->setEnabled(enable);
   setAll->setEnabled(enable);
   setAllValue->setEnabled(enable);
   if ( asicCnt != 0 ) for (x=0; x < asicCnt-1; x++) {
      for (y=0; y < 4; y++) thold[x*4+y]->setEnabled(enable);
      for (y=0; y < asic[x]->getChCount(); y++) mode[x*1024+y]->setEnabled(enable);
   }
}


// Update Display
void KpixGuiTrig::updateDisplay() {

   stringstream           temp;
   unsigned int           x, y;
   KpixAsic::KpixChanMode chModes[1024];
   unsigned char          tholdVal[4];

   // FPGA
   if ( fpga != NULL ) {
      trigSource->setCurrentItem(fpga->getTrigSource(false));
      trigExpand->setValue(fpga->getTrigExpand(false));
      temp.str("");
      temp << "0x" << hex << setw(2) << setfill('0') << (int)fpga->getTrigEnable(false);
      trigMask->setText(temp.str());
   }

   if ( asicCnt > 0 ) {

      // Asic
      cntrlNearNeighbor->setChecked(asic[0]->getCntrlNearNeighbor(false));
      cntrlTrigSrc->setCurrentItem(asic[0]->getCntrlTrigSrc(false));
      cntrlTrigDisable->setChecked(asic[0]->getCntrlTrigDisable(false));

      // Table Entries
      for ( x=0; x < (asicCnt-1); x++ ) {

         // Get Asic Data Modes
         asic[x]->getChannelModeArray(chModes,false);

         // Get Threshold Values
         asic[x]->getDacThreshRangeA(&tholdVal[0],&tholdVal[1],false);
         asic[x]->getDacThreshRangeB(&tholdVal[2],&tholdVal[3],false);

         // Update tables
         for ( y=0; y <  4; y++ ) thold[x*4+y]->setCurrentItem(tholdVal[y]);
         for ( y=0; y < asic[x]->getChCount(); y++ ) mode[x*1024+y]->setCurrentItem(chModes[y]);
      }
   }
}


// Read Settings From Asic/Fpga class
void KpixGuiTrig::readConfig() {

   stringstream           temp;
   unsigned int           x;
   KpixAsic::KpixChanMode chModes[1024];
   unsigned char          tholdVal[4];

   // FPGA
   if ( fpga != NULL ) {
      fpga->getTrigSource();
      fpga->getTrigExpand();
      fpga->getTrigEnable();
   }

   if ( asicCnt > 0 ) {

      // Asic
      asic[0]->getCntrlNearNeighbor();
      asic[0]->getCntrlTrigSrc();

      // Table Entries
      for ( x=0; x < (asicCnt-1); x++ ) {

         // Get Asic Data Modes
         asic[x]->getChannelModeArray(chModes);

         // Get Threshold Values
         asic[x]->getDacThreshRangeA(&tholdVal[0],&tholdVal[1]);
         asic[x]->getDacThreshRangeB(&tholdVal[2],&tholdVal[3]);
      }
   }
}


// Write Settings To Asic/Fpga class
void KpixGuiTrig::writeConfig() {

   unsigned int           x, y;
   bool                   ok;
   KpixAsic::KpixChanMode chModes[1024];
   unsigned char          tholdVal[4];

   // FPGA
   if ( fpga != NULL ) {
      fpga->setTrigSource((KpixFpga::KpixTrigSource)trigSource->currentItem());
      fpga->setTrigExpand(trigExpand->value());
      fpga->setTrigEnable(trigMask->text().toInt(&ok,16));
   }

   // Asic
   for (x=0; x < asicCnt; x++) {
      asic[x]->setCntrlNearNeighbor(cntrlNearNeighbor->isChecked());
      asic[x]->setCntrlTrigSrc((KpixAsic::KpixCalTrigSrc)(cntrlTrigSrc->currentItem()));
      asic[x]->setCntrlTrigDisable(cntrlTrigDisable->isChecked());
   }

   // Table Entries
   if ( asicCnt != 0 ) for ( x=0; x < (asicCnt-1); x++ ) {

      // Get Table Values
      for ( y=0; y <  4; y++ ) tholdVal[y] = thold[x*4+y]->currentItem();
      for ( y=0; y < asic[x]->getChCount(); y++ ) chModes[y] = (KpixAsic::KpixChanMode)mode[x*1024+y]->currentItem();

      // Set Asic Data Modes
      asic[x]->setChannelModeArray(chModes);

      // Set Threshold Values
      asic[x]->setDacThreshRangeA(tholdVal[0],tholdVal[1]);
      asic[x]->setDacThreshRangeB(tholdVal[2],tholdVal[3]);
   }
}


// Update All Entries
void KpixGuiTrig::setAllPressed() {

   unsigned int x, y;

   // Update Table Entries
   if ( asicCnt != 0) for ( x=0; x < (asicCnt-1); x++ ) {
      for ( y=0; y < asic[x]->getChCount(); y++ ) mode[x*1024+y]->setCurrentItem(setAllValue->currentItem());
   }
}

