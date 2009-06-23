//-----------------------------------------------------------------------------
// File          : KpixGuiRun.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/25/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class for running KPIX ASIC data runs.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 07/02/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_RUN_H__
#define __KPIX_GUI_RUN_H__

#include <string>
#include "KpixGuiRunForm.h"
#include <qthread.h>

// Forward Declarations
class KpixAsic;
class KpixFpga;
class KpixRunVar;
class KpixRunRead;
class KpixGuiTop;
class KpixGuiTop;
class KpixGuiError;
class KpixGuiRunView;
class TH1F;


class KpixGuiRun : public KpixGuiRunForm, public QThread {

      // ASIC & FPGA Containers
      unsigned int  asicCnt;
      KpixAsic      **asic;
      KpixFpga      *fpga;
      KpixGuiTop    *parent;
      KpixGuiError  *errorMsg;
      bool          enRun;
      bool          pRun;
      bool          isRunning;
      std::string   baseDir, desc, outDataDir, outDataFile, calFile;
      TH1F          *plots[32];
      KpixRunVar    **runVars;
      unsigned int  runVarCount;
      int           dispKpix[16];
      int           dispChan[16];
      int           dispBucket[16];

   public:

      // Creation Class
      KpixGuiRun ( KpixGuiTop *parent );

      // Delete
      ~KpixGuiRun ( );

      // Control Enable Of Buttons/Edits
      void setEnabled ( bool enable );

      // Set Configurations
      void setAsics ( KpixAsic **asic, unsigned int asicCnt, KpixFpga *fpga, KpixRunRead *runRead=NULL );

      // Window was closed
      void closeEvent(QCloseEvent *e);

      // Run Data Viewer
      KpixGuiRunView *runView;

      // Close is called
      bool close();

      // Show is called
      void show();

   protected:

      void run();

   private slots:

      void startRun_pressed();
      void stopRun_pressed();
      void pauseRun_stateChanged(int state);
      void viewData_pressed();
      void customEvent ( QCustomEvent *event );
      void addEvent_pressed();
      void delEvent_pressed();

   public slots:

};

#endif
