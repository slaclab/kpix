//-----------------------------------------------------------------------------
// File          : KpixGuiThreshScan.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC threshold scans.
// This is a class which builds off of the class created in
// KpixGuiThreshScanForm.ui
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_THRESH_SCAN_H__
#define __KPIX_GUI_THRESH_SCAN_H__

#include "KpixGuiThreshScanForm.h"
#include <KpixProgress.h>
#include <qthread.h>
#include <string>


// Forward Declarations
namespace sidApi {
   namespace offline {
      class KpixAsic;
      class KpixFpga;
      class KpixRunVar;
   }
}
class KpixGuiTop;
class KpixGuiError;
class KpixGuiThreshView;
class TH2F;


class KpixGuiThreshScan : public KpixGuiThreshScanForm, public QThread, public sidApi::online::KpixProgress {

      // ASIC & FPGA Containers
      unsigned int                asicCnt;
      sidApi::offline::KpixAsic   **asic;
      sidApi::offline::KpixFpga   *fpga;
      KpixGuiTop                  *parent;
      KpixGuiError                *errorMsg;
      bool                        running;
      bool                        enRun;
      bool                        isRunning;
      std::string                 baseDir, desc, outDataDir, outDataFile;
      sidApi::offline::KpixRunVar **runVars;
      unsigned int                runVarCount;
      TH2F                        *plot;
      KpixGuiThreshView           *threshView;

   public:

      // Creation Class
      KpixGuiThreshScan (KpixGuiTop *parent );

      // Delete
      ~KpixGuiThreshScan ( );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Set Configurations
      void setAsics ( sidApi::offline::KpixAsic **asic, unsigned int asicCnt, 
                      sidApi::offline::KpixFpga *fpga );

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
      void stopTest_pressed();
      void viewPlots_pressed();
      void customEvent ( QCustomEvent *event );

   public slots:


};

#endif
