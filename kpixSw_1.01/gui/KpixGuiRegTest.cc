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
#include <qlineedit.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <KpixRegisterTest.h>
#include "KpixGuiRegTest.h"
#include "KpixGuiTop.h"
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
   QThread::start();
}


// Thread for register test
void KpixGuiRegTest::run() {
 
   unsigned int        x;
   KpixRegisterTest    *regTest;
   bool                res;
   bool                errors;
   KpixGuiEventRun     *event;
   KpixGuiEventError   *error;
   KpixGuiEventData    *eData;
   stringstream        temp;
   void                *eventData[4];

   errors     = false;
   prgCurrent = 0;
   prgTotal   = asicCnt;

   // Init status display
   event = new KpixGuiEventRun(true,false,"Starting",0,100,prgCurrent,prgTotal);
   QApplication::postEvent(this,event);

   try {
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
         event = new KpixGuiEventRun(false,false,temp.str(),0,iterations->value(),prgCurrent,prgTotal);
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
         eData = new KpixGuiEventData(KPRG_UINT,4,eventData);
         QApplication::postEvent(this,eData);

         // Cleanup
         delete regTest;
         prgCurrent++;
      }
   } catch ( string errorMsg ) {
      error = new KpixGuiEventError(errorMsg);
      QApplication::postEvent(this,error);
   }

   // Final Update
   event = new KpixGuiEventRun(false,true,(errors?"Done With Errors":"Done"),100,100,100,100);
   QApplication::postEvent(this,event);
}


// Update progress callback
void KpixGuiRegTest::updateProgress(unsigned int count, unsigned int total) {
   KpixGuiEventRun *event = new KpixGuiEventRun(false,false,"",count,total,prgCurrent,prgTotal);
   QApplication::postEvent(this,event);
}


// Receive Custom Events
void KpixGuiRegTest::customEvent ( QCustomEvent *event ) {

   KpixGuiEventError   *eventError;
   KpixGuiEventRun     *eventRun;
   KpixGuiEventData    *eventData;
   stringstream        temp;
   unsigned int        x;

   // Run Event
   if ( event->type() == KPIX_GUI_EVENT_RUN ) {
      eventRun = (KpixGuiEventRun *)event;

      // Run is starting
      if ( eventRun->runStart ) {
         parent->setEnabled(false);
         isRunning = true;

         // Update Results Table
         for (x=0; x < asicCnt; x++) {
            resultTable->setText(x,0,"");
            resultTable->setText(x,1,"");
            resultTable->setText(x,2,"");
         }
      }

      // Run is stopping
      if ( eventRun->runStop ) {
         try {
            parent->readConfig(true);
            parent->readStatus();
         } catch ( string error ) {
            errorMsg->showMessage(error);
         }
         parent->setEnabled(true);
         isRunning = false;
      }
            
      // Update status
      if ( eventRun->statusMsg != "" ) status->setText(eventRun->statusMsg);
      runProgress->setProgress(eventRun->prgCurrent,eventRun->prgTotal);
      totProgress->setProgress(eventRun->totCurrent,eventRun->totTotal);
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
      if ( eventData->id == KPRG_UINT && eventData->count == 4 ) {

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
