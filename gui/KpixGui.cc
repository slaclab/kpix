//-----------------------------------------------------------------------------
// File          : SidGui.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/26/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Top level for SID GUI (KPIX)
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 09/26/2008: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <signal.h>
#include <unistd.h>
#include <SidLink.h>
#include <qapplication.h>
#include "KpixGuiTop.h"
#include "KpixGuiCalFit.h"
#include "KpixGuiRunView.h"
using namespace std;


// Print command line usage
void printUsage ( char *name ) {
   cout << "Running " << name << " version 0.1" << endl;
   cout << "Usage: " << name << " [-h] [-l device] [-d base_dir] [-v version] [-c clk_period] [-s file.root] mode" << endl; 
   cout << "\t-h            Display This Message" << endl;
   cout << "\t-l device     Set SidLink Device Value" << endl;
   cout << "\t              /dev/ttyUSB# For Virtual Com Port Mode Or # For Direct USB Mode" << endl;
   cout << "\t              Default Is KPIX_DEVICE Environment Variable Or /dev/ttyUSB0" << endl;
   cout << "\t-d base_dir   Set Base Directory For Data" << endl;
   cout << "\t              Default Is KPIX_BASE_DIR Environment Variable Or Current Working Directory" << endl;
   cout << "\t-v version    Set KPIX Version." << endl;
   cout << "\t              Default Is KPIX_VERSION Environment Variable Or Max Supported Version=";
   cout << KpixAsic::maxVersion() << endl;
   cout << "\t-c clk_period Set Default Clock Period. " << endl;
   cout << "\t              Default Is KPIX_CLK_PER Environment Variable Or 50ns" << endl;
   cout << "\t-s file.root  Settings & Calibration File Default For Run Menus" << endl;
   cout << "\t              Default Is KPIX_CAL_FILE Environment Variable Or Empty" << endl;
   cout << "\tmode          One of The following:" << endl;
   cout << "\t                 run         = Run Control GUI For Runs, Calibrations & Threshold Scans" << endl;
   cout << "\t                 cal_view    = Calibration Plot Viewer" << endl;
   cout << "\t                 run_view    = Run Plot Viewer" << endl;
   cout << "\t                 thresh_view = Threshold Scan Viewer" << endl;
}


// Main Function
int main ( int argc, char **argv ) {

   SidLink           *sidLink;
   KpixGuiTop        *kpixGuiTop;
   KpixGuiCalFit     *kpixGuiCalFit;
   KpixGuiRunView    *kpixGuiRunView;
   KpixGuiThreshView *kpixGuiThreshView;
   string            deviceString;
   int               deviceInt;
   string            baseDir;
   string            verString;
   int               verInt;
   string            clkString;
   int               clkInt;
   string            calString;
   char              *env;
   char              oc;
   string            modeString;

   // Set Default Options
   deviceString = "/dev/ttyUSB0";
   deviceInt    = -1;
   baseDir      = get_current_dir_name();
   verInt       = KpixAsic::maxVersion();
   verString    = "";
   clkInt       = 50;
   calString    = "";

   // Start X11 view
   QApplication a( argc, argv );

   // Get Environment Variables
   if ( (env = getenv("KPIX_DEVICE"))   != NULL ) deviceString.assign(env);
   if ( (env = getenv("KPIX_VERSION")) != NULL ) verString.assign(env);
   if ( (env = getenv("KPIX_BASE_DIR")) != NULL ) baseDir.assign(env);
   if ( (env = getenv("KPIX_CLK_PER"))  != NULL ) clkString.assign(env);
   if ( (env = getenv("KPIX_CAL_FILE"))  != NULL ) calString.assign(env);

   // Process Args
   while ((oc = getopt(argc, argv, ":hd:b:a:v:c:s:")) != -1) {
      switch (oc) {
         case 'l': deviceString.assign(optarg); break;
         case 'd': baseDir.assign(optarg);      break;
         case 'v': verString.assign(optarg);    break;
         case 'c': clkString.assign(optarg);    break;
         case 's': calString.assign(optarg);    break;
         default:  printUsage(argv[0]);         return(1);
      }
   }

   // Get Mode String
   modeString = argv[argc-1];

   // Determine mode
   if ( modeString != "run" && modeString != "run_view" && 
        modeString != "cal_view" && modeString != "thresh_view" ) {
      printUsage(argv[0]); 
      return(1); 
   }

   // Convert Version
   if ( verString != "" ) verInt = atoi(verString.c_str());

   // Convert Clock Period
   if ( clkString != "" ) clkInt = atoi(clkString.c_str());

   // Determine Device
   if ( deviceString.find("dev/") == 1 ) deviceInt = -1;
   else deviceInt = atoi(deviceString.c_str());

   // Show Operating Mode
   if ( deviceInt == -1 ) cout << "Using Device    = " << deviceString << endl;
   else cout << "Using Device    = " << deviceInt << endl;
   cout << "Using Base Dir  = " << baseDir   << endl;
   cout << "Using Version   = " << verInt    << endl;
   cout << "Using Clock Per = " << clkInt    << endl;
   cout << "Using Settings  = " << calString << endl;

   // Determine Running Mode
   if ( modeString == "cal_view" ) {
      kpixGuiCalFit = new KpixGuiCalFit(baseDir);
      kpixGuiCalFit->show();
   }
   if ( modeString == "run_view" ) {
      kpixGuiRunView = new KpixGuiRunView(baseDir);
      kpixGuiRunView->show();
   }
   if ( modeString == "thresh_view" ) {
      kpixGuiThreshView = new KpixGuiThreshView(baseDir);
      kpixGuiThreshView->show();
   }
   if ( modeString == "run" ) {

      // Open serial link
      try {
         sidLink = new SidLink();
         if ( deviceInt == -1 ) sidLink->linkOpen(deviceString);
         else sidLink->linkOpen(deviceInt);
      } catch ( string error ) {
         cout << "Error opening serial link:\n";
         cout << error << "\n";
         cout << "Exiting!\n";
         return(1);
      }

      // Create Gui Windows
      kpixGuiTop = new KpixGuiTop(sidLink,clkInt,verInt,baseDir,calString);
      kpixGuiTop->show();
   }

   a.connect( &a, SIGNAL( lastWindowClosed() ), &a, SLOT( quit() ) );

   try { return a.exec(); }
   catch (string error) {
      cout << "KpixGui -> An error was thrown: " << error << endl;
   }
}

