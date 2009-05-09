//-----------------------------------------------------------------------------
// File          : KpixGuiTop.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for graphical representation of the KPIX ASICs
// This is a class which builds off of the class created in
// KpixGuiTopForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 03/05/2009: Added rate limit function.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <qlineedit.h>
#include <qtabwidget.h>
#include <TError.h>
#include <qfiledialog.h>
#include <KpixRunRead.h>
#include "KpixGuiTop.h"
#include "KpixGuiError.h"
#include "KpixGuiRegTest.h"
#include "KpixGuiCalibrate.h"
#include "KpixGuiThreshScan.h"
using namespace std;


// Constructor
KpixGuiTop::KpixGuiTop ( SidLink *sidLink, unsigned int clkPeriod, unsigned int version, 
                         string baseDir, string calString, unsigned int rateLimit, 
                         QWidget *parent ) : KpixGuiTopForm(parent) {

   this->asicCnt       = 0;
   this->fpga          = NULL;
   this->sidLink       = sidLink;
   this->asicVersion   = version;
   this->defClkPeriod  = clkPeriod;

   // Set base directory
   baseDirBox->setText(baseDir);
   calSetFile->setText(calString);

   // Create error window
   errorMsg = new KpixGuiError(this);

   // Create Tab Widgets
   kpixGuiMain   = new KpixGuiMain(this);
   kpixGuiFpga   = new KpixGuiFpga(this);
   kpixGuiConfig = new KpixGuiConfig(this);
   kpixGuiTiming = new KpixGuiTiming(rateLimit,this);
   kpixGuiTrig   = new KpixGuiTrig(this);
   kpixGuiInject = new KpixGuiInject(this);
   kpixGuiStatus = new KpixGuiStatus(this);

   // Fill in the tabs
   kpixTabs->insertTab(kpixGuiMain,"Main",0);
   kpixTabs->insertTab(kpixGuiFpga,"FPGA",1);
   kpixTabs->insertTab(kpixGuiConfig,"Config",2);
   kpixTabs->insertTab(kpixGuiTiming,"Timing",3);
   kpixTabs->insertTab(kpixGuiTrig,"Trigger",4);
   kpixTabs->insertTab(kpixGuiInject,"Inject",5);
   kpixTabs->insertTab(kpixGuiStatus,"Status",6);
   kpixTabs->removePage(deleteTab);
   kpixTabs->setCurrentPage(0);

   // Create Sub menus but don't display
   kpixGuiRegTest    = new KpixGuiRegTest(this);
   kpixGuiCalibrate  = new KpixGuiCalibrate(this);
   kpixGuiThreshScan = new KpixGuiThreshScan(this);
   kpixGuiRun        = new KpixGuiRun(this);

   // Update display
   readConfig(false);
   setEnabled(true);
}

// Delete
KpixGuiTop::~KpixGuiTop ( ) {
   unsigned int x;
   delete fpga;
   for (x=0; x < asicCnt; x++) delete asic[x];
   delete kpixGuiRegTest;
   delete kpixGuiCalibrate;
   delete kpixGuiThreshScan;
   delete kpixGuiRun;
}


// Control Enable Of Buttons/Edits
void KpixGuiTop::setEnabled ( bool enable ) {

   bool calEn = calEnable->isChecked();
   bool asicEn = (asicCnt != 0);

   // Setup Display
   kpixGuiMain->setEnabled(enable,calEn);
   kpixGuiFpga->setEnabled(enable);
   kpixGuiConfig->setEnabled(enable,calEn);
   kpixGuiTiming->setEnabled(enable,calEn);
   kpixGuiTrig->setEnabled(enable);
   kpixGuiInject->setEnabled(enable);

   // Sub windows
   kpixGuiCalibrate->setEnabled(enable&&asicEn);
   calibMenu->setEnabled(enable&&asicEn);
   kpixGuiThreshScan->setEnabled(enable&&asicEn);
   threshScanMenu->setEnabled(enable&&asicEn);
   kpixGuiRegTest->setEnabled(enable&&asicEn);
   regTest->setEnabled(enable&&asicEn);
   kpixGuiRun->setEnabled(enable&&asicEn);
   runMenu->setEnabled(enable&&asicEn);

   // Local Stuff
   updateStatus->setEnabled(enable&&asicEn);
   clearCounters->setEnabled(enable&&asicEn);
   readConfiguration->setEnabled(enable&&asicEn);
   writeConfiguration->setEnabled(enable&&asicEn);
   kpixAsicDebug->setEnabled(enable&&asicEn);
   kpixFpgaDebug->setEnabled(enable&&asicEn);
   dumpSettings->setEnabled(enable&&asicEn);
   setDefaults->setEnabled(enable&&asicEn);
   baseDirBrowse->setEnabled(enable);
   baseDirBox->setEnabled(enable);
   calSetBrowse->setEnabled(enable);
   calSetFile->setEnabled(enable);
   clearFile->setEnabled(enable);
   loadSettings->setEnabled(enable);
   sidLinkDebug->setEnabled(enable);
   kpixReScan->setEnabled(enable);
   quit->setEnabled(enable);
   update();
}


void KpixGuiTop::readStatus() {
   kpixGuiStatus->readStatus();
}


// Read Configuration
void KpixGuiTop::readConfig(bool readEn) {
   kpixGuiMain->readConfig(readEn);
   kpixGuiFpga->readConfig(readEn);
   kpixGuiConfig->readConfig(readEn);
   kpixGuiTiming->readConfig(readEn);
   kpixGuiTrig->readConfig(readEn);
   kpixGuiInject->readConfig(readEn);
   kpixGuiStatus->readStatus();
}


// Write Configuration
void KpixGuiTop::writeConfig(bool writeEn) {
   kpixGuiMain->writeConfig(writeEn);
   kpixGuiFpga->writeConfig(writeEn);
   kpixGuiConfig->writeConfig(writeEn);
   kpixGuiTiming->writeConfig(writeEn);
   kpixGuiTrig->writeConfig(writeEn);
   kpixGuiInject->writeConfig(writeEn);
}


void KpixGuiTop::setDefaults_pressed( ) {
   unsigned int x;
   try {
      fpga->setDefaults(defClkPeriod,(asicVersion>7));
      for(x=0; x<asicCnt; x++) asic[x]->setDefaults(defClkPeriod);
      readConfig(false);
      update();
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
}


void KpixGuiTop::kpixReScan_pressed() {
   cout << "ReScan Started" << endl;
   try {
      findConnectedAsics();
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
   cout << "ReScan Done" << endl;
}


void KpixGuiTop::calibMenu_pressed() {
   unsigned int x;
   bool         ok;

   // Verify Serial Numbers
   ok = true;
   for (x=0; x < (asicCnt-1); x++)
      if ( asic[x]->getSerial() == 0 ) ok = false;
   if ( ! ok ) errorMsg->showMessage("KPIX Serial Numbers Must Be Set!");
   else kpixGuiCalibrate->show();
}


void KpixGuiTop::threshScanMenu_pressed() {
   unsigned int x;
   bool         ok;

   // Verify Serial Numbers
   ok = true;
   for (x=0; x < (asicCnt-1); x++)
      if ( asic[x]->getSerial() == 0 ) ok = false;
   if ( ! ok ) errorMsg->showMessage("KPIX Serial Numbers Must Be Set!");
   else kpixGuiThreshScan->show();
}


void KpixGuiTop::runMenu_pressed() {
   unsigned int x;
   bool         ok;

   // Verify Serial Numbers
   ok = true;
   for (x=0; x < (asicCnt-1); x++)
      if ( asic[x]->getSerial() == 0 ) ok = false;
   if ( ! ok ) errorMsg->showMessage("KPIX Serial Numbers Must Be Set!");
   else kpixGuiRun->show();
}


void KpixGuiTop::regTest_pressed() {
   kpixGuiRegTest->show();
}


void KpixGuiTop::readStatus_pressed() {
   try {
      readStatus();
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
}


void KpixGuiTop::clearCounters_pressed() {
   try {
      fpga->cmdRstCheckSumErrors();
      fpga->cmdRstParErrors();
      fpga->cmdRstDeadCount();
      fpga->cmdRstTrainNumber();
      readStatus();
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
}


void KpixGuiTop::readConfig_pressed() {
   try {
      readConfig(true);
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
}


void KpixGuiTop::writeConfig_pressed() {
   try {
      writeConfig(true);
      readConfig(false);
   } catch ( string error ) {
      errorMsg->showMessage(error);
      cout << "Caught Exception: " << error << endl;
   }
}


void KpixGuiTop::kpixAsicDebug_toggled( bool checked ) {
   unsigned int x;
   for (x=0; x<asicCnt; x++) asic[x]->kpixDebug(checked);
}

void KpixGuiTop::kpixFpgaDebug_toggled( bool checked ) {  
   fpga->fpgaDebug(checked);
}

void KpixGuiTop::sidLinkDebug_toggled( bool checked ) {
   sidLink->linkDebug(checked);
}


void KpixGuiTop::calEnable_toggled( ) {
   setEnabled(true);
}


void KpixGuiTop::dumpSettings_pressed( ) {
   unsigned int x;
   cout << endl << "Dumping FPGA Settings: " << endl;
   fpga->dumpSettings();
   for (x=0; x<asicCnt; x++) {
      cout << endl << "Dumping Asic " << x << " Settings: " << endl;
      asic[x]->dumpSettings();
   }
}


void KpixGuiTop::findConnectedAsics() {
   bool          temp1,temp2,temp3;
   unsigned char temp4;
   unsigned int  x;

   // Delete ASICs
   for (x=0; x < asicCnt; x++) delete asic[x];
   asicCnt = 0;

   // Delete FPGA
   if ( fpga != NULL ) delete fpga;

   // Create object
   fpga = new KpixFpga(sidLink);

   // Set defaults
   fpga->setDefaults(defClkPeriod,(asicVersion>7));

   // Find Each Address
   cout << "Searching For ASICs" << endl;
   for (x=0; x <= KPIX_MAX_ADDR; x++) {

      // Create an ASIC object for test
      asic[asicCnt] = new KpixAsic(sidLink,(x==KPIX_MAX_ADDR?0:asicVersion),x,0);

      // Attempt to find each ASIC
      try {

         // Send reset command
         asic[asicCnt]->cmdReset();

         // Attempt to read from device
         asic[asicCnt]->getStatus(&temp1,&temp2,&temp3,&temp4);

         // If we got here asic was found
         asic[asicCnt]->setDefaults(defClkPeriod);
         asicCnt++;
         cout << "Found ASIC at address 0x" << hex << x << endl;
      }
      catch ( string error ) {
         cout << "No ASIC at address 0x" << hex << x << endl;
         delete asic[asicCnt];
      }
   }

   // Pass asics to sub classes
   kpixGuiCalibrate->setAsics(asic,asicCnt,fpga);
   kpixGuiThreshScan->setAsics(asic,asicCnt,fpga);
   kpixGuiRegTest->setAsics(asic,asicCnt);
   kpixGuiRun->setAsics(asic,asicCnt,fpga);
   kpixGuiMain->setAsics(asic,asicCnt);
   kpixGuiFpga->setFpga(fpga);
   kpixGuiConfig->setAsics(asic,asicCnt);
   kpixGuiTiming->setAsics(asic,asicCnt,fpga);
   kpixGuiTrig->setAsics(asic,asicCnt,fpga);
   kpixGuiInject->setAsics(asic,asicCnt);
   kpixGuiStatus->setAsics(asic,asicCnt,fpga);

   // Update display
   calEnable->setChecked(true);
   readConfig(false);
   kpixGuiStatus->readStatus();
   setEnabled(true);
}


// Get Run Description
string KpixGuiTop::getRunDescription() {
   return(kpixGuiMain->getRunDescription());
}


// Get Base Directory
string KpixGuiTop::getBaseDir() { 
   if ( baseDirBox->text() == "" ) return(string(""));
   else return(string(baseDirBox->text().ascii()));
}


// Get Base Directory
string KpixGuiTop::getCalFile() { 
   if ( calSetFile->text() == "" ) return(string(""));
   else return(string(calSetFile->text().ascii()));
}


// Get Run Variable List
KpixRunVar **KpixGuiTop::getRunVarList(unsigned int *count){
   return(kpixGuiMain->getRunVarList(count));
}


// Get rate limit value, zero for none
unsigned int KpixGuiTop::getRateLimit() {
   return(kpixGuiTiming->getRateLimit());
}


void KpixGuiTop::baseDirBrowse_pressed() {

   // Select Input File
   QFileDialog *fd = new QFileDialog(this,"Data Directory",TRUE);
   fd->setViewMode(QFileDialog::Detail);
   fd->setMode(QFileDialog::DirectoryOnly);

   // Set Default
   if ( baseDirBox->text() != "" ) fd->setSelection(baseDirBox->text());

   // File Was selected
   if ( fd->exec() == QDialog::Accepted ) baseDirBox->setText(fd->selectedFile());
   delete(fd);
   baseDirBrowse->setDown(false);
}


void KpixGuiTop::calSetBrowse_pressed() {

   // Select Input File
   QFileDialog *fd = new QFileDialog(this,"Calibration & Settings File",TRUE);
   fd->setViewMode(QFileDialog::Detail);
   fd->setFilter("Root Files (*.root)");

   // Set Default
   if ( calSetFile->text() != "" ) fd->setSelection(calSetFile->text());
   else if ( baseDirBox->text() != "" ) fd->setSelection(baseDirBox->text());

   // File Was selected
   if ( fd->exec() == QDialog::Accepted ) calSetFile->setText(fd->selectedFile());
   delete(fd);
   calSetBrowse->setDown(false);
}


void KpixGuiTop::clearFile_pressed() {
   calSetFile->setText("");
}


void KpixGuiTop::loadSettings_pressed() {

   KpixRunRead  *runRead;
   unsigned int x;

   try {
      runRead = new KpixRunRead(calSetFile->text().ascii(),false);
      gErrorIgnoreLevel = 5000; 

      // Delete ASICs
      for (x=0; x < asicCnt; x++) delete asic[x];
      asicCnt = 0;

      // Delete FPGA
      if ( fpga != NULL ) delete fpga; fpga = NULL;

      // Copy FPGA object
      fpga = new KpixFpga(*(runRead->getFpga()));
      fpga->setSidLink(sidLink);

      // Get Asic Count
      asicCnt = runRead->getAsicCount();

      // Set asic pointers
      for (x=0; x < asicCnt; x++) {
         asic[x] = new KpixAsic(*(runRead->getAsic(x)));
         asic[x]->setSidLink(sidLink);
      }

      // Pass asics to sub classes
      kpixGuiCalibrate->setAsics(asic,asicCnt,fpga);
      kpixGuiThreshScan->setAsics(asic,asicCnt,fpga);
      kpixGuiRegTest->setAsics(asic,asicCnt);
      kpixGuiRun->setAsics(asic,asicCnt,fpga,runRead);
      kpixGuiMain->setAsics(asic,asicCnt);
      kpixGuiFpga->setFpga(fpga);
      kpixGuiConfig->setAsics(asic,asicCnt);
      kpixGuiTiming->setAsics(asic,asicCnt,fpga);
      kpixGuiTrig->setAsics(asic,asicCnt,fpga);
      kpixGuiInject->setAsics(asic,asicCnt);
      kpixGuiStatus->setAsics(asic,asicCnt,fpga);

      // Pass run read to main
      kpixGuiMain->setRunRead(runRead);

      // Close input file
      delete runRead;

      // Update
      readConfig(false);
      writeConfig(true);
   } catch (string error) {
      errorMsg->showMessage(error);
   }

   // Update
   calEnable->setChecked(false);
   kpixGuiStatus->readStatus();
   setEnabled(true);
}


void KpixGuiTop::closeEvent(QCloseEvent *e) {
   if ( kpixGuiRegTest->close() &&
        kpixGuiCalibrate->close() &&
        kpixGuiRun->close() &&
        kpixGuiThreshScan->close() ) e->accept();
   else e->ignore();
}

