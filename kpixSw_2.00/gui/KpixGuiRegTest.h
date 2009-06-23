//-----------------------------------------------------------------------------
// File          : KpixGuiRegTest.h
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
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_REG_TEST_H__
#define __KPIX_GUI_REG_TEST_H__

#include "KpixGuiRegTestForm.h"
#include <KpixProgress.h>
#include <qthread.h>

// Forward declarations
namespace sidApi {
   namespace offline {
      class KpixAsic;
   }
}
class KpixGuiTop;
class KpixGuiError;
class KpixGuiTop;

class KpixGuiRegTest : public QThread, public sidApi::online::KpixProgress, public KpixGuiRegTestForm {

      // ASIC & FPGA Containers
      unsigned int              asicCnt;
      sidApi::offline::KpixAsic **asic;
      KpixGuiTop                *parent;
      KpixGuiError              *errorMsg;
      bool                      isRunning;

   public:

      // Creation Class
      KpixGuiRegTest ( KpixGuiTop *parent );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Set Asics
      void setAsics ( sidApi::offline::KpixAsic **asic, unsigned int asicCnt );

      // Update progress
      void updateProgress(unsigned int count, unsigned int total);
      void updateData(unsigned int id, unsigned int count, void **data);

      // Window was closed
      void closeEvent(QCloseEvent *e);

      // Close is called
      bool close();

   protected:

      void run();

   private slots:

      void runTest_pressed();
      void customEvent ( QCustomEvent *event );

   public slots:

};

#endif
