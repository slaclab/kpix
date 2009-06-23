//-----------------------------------------------------------------------------
// File          : KpixGuiRegTest.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC register tests.
// This is a class which builds off of the class created in
// KpixGuiRegTestForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
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
#include <qprogressbar.h>
#include <qapplication.h>
#include <qpushbutton.h>
#include <qcombobox.h>
#include <qspinbox.h>
#include <qcheckbox.h>
#include <qtable.h>
#include <KpixAsic.h>
#include <KpixRegisterTest.h>
#include "KpixGuiRegTest.h"
#include "KpixGuiTop.h"
#include "KpixGuiError.h"
#include "KpixGuiEventStatus.h"
#include "KpixGuiEventError.h"
#include "KpixGuiEventData.h"
using namespace std;


// Constructor
KpixGuiRegTest::KpixGuiRegTest ( KpixGuiTop *parent ) : KpixGuiRegTestForm() {

   this->asicCnt = 0;
   this->asic    = NULL;
   this->parent  = parent;
   isRunning     = false;

   // Create error window
   errorMsg = new KpixGuiError(this);

   // Default status
   status->setText("Idle");
}


// Control Enable Of Buttons/Edits
void KpixGuiRegTest::setEnabled ( bool enable ) {
   runTest->setEnabled(enable);
   iterations->setEnabled(enable);
   testDirection->setEnabled(enable);
   endOnError->setEnabled(enable);
   readCount->setEnabled(enable);
   k8Dbg->setEnabled(enable);
   testValue->setEnabled(enable);
   regValue->setEnabled(enable);
   showProgress->setEnabled(enable);
   verbose->setEnabled(enable);
   runTest->setEnabled(enable);
   closeWindow->setEnabled(enable);
}


// Set Asics
void KpixGuiRegTest::setAsics ( KpixAsic **asic, unsigned int asicCnt ) {
   unsigned int x;
   stringstream temp;

   this->asicCnt = asicCnt;
   this->asic    = asic;

   // Update Table
   resultTable->setNumRows(asicCnt);
   for (x=0; x < asicCnt; x++ ) {
      temp.str("");
      temp << "Kpix " << dec << x;
      resultTable->verticalHeader()->setLabel(x,temp.str());
   }
}


// Run Register Test
void KpixGuiRegTest::runTest_pressed ( ) {
   parent->setEnabled(false);
   isRunning = true;
   QThread::start();
}


// Thread for register test
void KpixGuiRegTest::run() {
 
   unsigned int        x;
   KpixRegisterTest    *regTest;
   bool                res;
   bool                errors;
   KpixGuiEventStatus  *event;
   KpixGuiEventError   *error;
   KpixGuiEventData    *eData;
   stringstream        temp;
   void                *eventData[4];
   unsigned int        mainProgress;
   unsigned int        mainTotal;
   unsigned int        reg;
   unsigned int        wval;

   errors       = false;
   mainProgress = 0;
   mainTotal    = asicCnt;

   // Init status display
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusStart,"Starting");
   QApplication::postEvent(this,event);

   // Debug mode
   if ( k8Dbg->isChecked() ) {

      reg  = regValue->text().toUInt(0,16);
      wval = testValue->text().toUInt(0,16);

      cout << "Writing Register 0x" << setw(2) << setfill('0') << hex << reg << ". Value 0x"
      << setw(8) << setfill('0') << hex << wval << "\n";
      asic[0]->regSetValue(reg,wval,true);

      for (x=0; x<10; x++) {
         cout << "Reading Register 0x" << setw(2) << setfill('0') << hex << reg << ". Value 0x"
         << setw(8) << setfill('0') << hex << asic[0]->regGetValue(reg,true) << endl;
      }
   }

   else try {
      for (x=0; x < asicCnt; x++) {

         // Create and setup test
         regTest = new KpixRegisterTest(asic[x]);
         regTest->setEndOnError(endOnError->isChecked());
         regTest->setIterations(iterations->value());
         regTest->setReadCount(readCount->value());
         regTest->setShowProgress(showProgress->isChecked());
         regTest->setDirection(testDirection->currentItem()==1);
         regTest->setDebug(verbose->isChecked());
         regTest->setKpixProgress(this);

         // Update Text
         temp.str("");
         temp << "Running Kpix " << dec << x;
         temp << " (" << dec << asicCnt << " Total)";

         // Update status display
         event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgMain,temp.str(),mainProgress,mainTotal);
         QApplication::postEvent(this,event);

         // Run Test
         res = regTest->runTest();

         // Mark result
         if ( ! res ) errors = true;

         // Display Counts
         eventData[0] = (void *)x;
         eventData[1] = (void *)res;
         eventData[2] = (void *)regTest->getReadErrors();
         eventData[3] = (void *)regTest->getStatusErrors();
         eData = new KpixGuiEventData(DataUInt,4,eventData);
         QApplication::postEvent(this,eData);

         // Cleanup
         delete regTest;
         mainProgress++;
      }
   } catch ( string errorMsg ) {
      error = new KpixGuiEventError(errorMsg);
      QApplication::postEvent(this,error);
   }

   // Final Update
   event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusDone,(errors?"Done With Errors":"Done"));
   QApplication::postEvent(this,event);
}


// Update progress callback
void KpixGuiRegTest::updateProgress(unsigned int count, unsigned int total) {
   KpixGuiEventStatus *event = new KpixGuiEventStatus(KpixGuiEventStatus::StatusPrgSub,count,total);
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiRegTest::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError   *eventError;
   KpixGuiEventStatus  *eventStatus;
   KpixGuiEventData    *eventData;
   stringstream        temp;
   unsigned int        x;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_STATUS ) {
      eventStatus = (KpixGuiEventStatus *)event;

      // Status Type
      switch (eventStatus->statusType) {

         // Run is starting
         case KpixGuiEventStatus::StatusStart:
            status->setText(eventStatus->statusMsg);

            // Update Results Table
            for (x=0; x < asicCnt; x++) {
               resultTable->setText(x,0,"");
               resultTable->setText(x,1,"");
               resultTable->setText(x,2,"");
            }
            break;

         // Run is Stopping
         case KpixGuiEventStatus::StatusDone:

            // Update flags
            isRunning = false;

            // Clear progress bars
            runProgress->setProgress(-1,0);
            totProgress->setProgress(-1,0);

            // Read back settings
            parent->readConfig_pressed();
            break;

         // Main progress update
         case KpixGuiEventStatus::StatusPrgMain:
            runProgress->setProgress(-1,0);
            totProgress->setProgress(eventStatus->prgValue,eventStatus->prgTotal);
            status->setText(eventStatus->statusMsg);
            break;

         // Sub progress update
         case KpixGuiEventStatus::StatusPrgSub:
            runProgress->setProgress(eventStatus->prgValue,eventStatus->prgTotal);
            break;
      }
      update();
   }

   // Error Event
   if ( event->type() == KPIX_GUI_EVENT_ERROR ) {
      eventError = (KpixGuiEventError *)event;
      errorMsg->showMessage(eventError->errorMsg);
      update();
   }

   // Reg Test Update Event
   if ( event->type() == KPIX_GUI_EVENT_DATA ) {
      eventData = (KpixGuiEventData *)event;
      if ( eventData->id == DataUInt && eventData->count == 4 ) {

         // Extract data
         x = (unsigned int)eventData->data[0];
         if ( (unsigned int)eventData->data[1] == 1 ) resultTable->setText(x,0,"Pass");
         else resultTable->setText(x,0,"Fail");
         temp.str("");
         temp << dec << (unsigned int)eventData->data[2];
         resultTable->setText(x,1,temp.str());
         temp.str("");
         temp << dec << (unsigned int)eventData->data[3];
         resultTable->setText(x,2,temp.str());
         update();
      }
   }
}


// Unused
void KpixGuiRegTest::updateData(unsigned int id, unsigned int count, void **data) {
   cout << "KpixGuiRegTest::updateData->Unsupported Call, ";
   cout << "Id=" << dec << id << ", ";
   cout << "Count=" << dec << count << ", ";
   cout << "Pointer=" << hex << data << endl;
}


void KpixGuiRegTest::closeEvent(QCloseEvent *e) {
   if ( isRunning ) e->ignore();
   else e->accept();
}


bool KpixGuiRegTest::close() { return(KpixGuiRegTestForm::close()); }
