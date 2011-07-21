//-----------------------------------------------------------------------------
// File          : SidGui.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/26/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Top level for SID GUI (KPIX)
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 09/26/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed sidApi namespace.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <qapplication.h>
#include <SidLink.h>
#include <KpixAsic.h>
#include "KpixGuiTop.h"
#include "KpixGuiCalFit.h"
#include "KpixGuiRunView.h"
#include "KpixGuiThreshView.h"
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
   string            portString;
   int               portInt;
   string            baseDir;
   string            verString;
   int               verInt;
   string            clkString;
   int               clkInt;
   string            calString;
   char              *env;
   char              oc;
   string            modeString;
   string            rateString;
   unsigned int      rateLimit;

   try { 

   // Set Default Options
   deviceString = "/dev/ttyUSB0";
   deviceInt    = -1;
   portInt      = -1;
   baseDir      = get_current_dir_name();
   verInt       = KpixAsic::maxVersion();
   verString    = "";
   clkInt       = 50;
   calString    = "";

   // Start X11 view
   QApplication a( argc, argv );

   // Get Environment Variables
   if ( (env = getenv("KPIX_DEVICE"))   != NULL ) deviceString.assign(env);
   if ( (env = getenv("KPIX_PORT")) != NULL ) portString.assign(env);
   if ( (env = getenv("KPIX_VERSION")) != NULL ) verString.assign(env);
   if ( (env = getenv("KPIX_BASE_DIR")) != NULL ) baseDir.assign(env);
   if ( (env = getenv("KPIX_CLK_PER"))  != NULL ) clkString.assign(env);
   if ( (env = getenv("KPIX_CAL_FILE"))  != NULL ) calString.assign(env);
   if ( (env = getenv("KPIX_RATE_LIMIT"))  != NULL ) rateString.assign(env);

   // Process Args
   while ((oc = getopt(argc, argv, ":hd:b:a:v:c:s:p:")) != -1) {
      switch (oc) {
         case 'l': deviceString.assign(optarg); break;
         case 'd': baseDir.assign(optarg);      break;
         case 'v': verString.assign(optarg);    break;
         case 'c': clkString.assign(optarg);    break;
         case 's': calString.assign(optarg);    break;
         case 'p': portString.assign(optarg);   break;
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

   // Convert rate limit
   if ( rateString != "" ) rateLimit = atoi(rateString.c_str());
   else rateLimit = 0;

   // Convert Version
   if ( verString != "" ) verInt = atoi(verString.c_str());

   // Convert Clock Period
   if ( clkString != "" ) clkInt = atoi(clkString.c_str());

   // Determine port
   if ( portString != "" ) portInt = atoi(portString.c_str());

   // Determine Device
   if ( deviceString.find("dev/") == 1 ) deviceInt = -1;
   else if ( portInt < 0 ) deviceInt = atoi(deviceString.c_str());

   // Show Operating Mode
   if ( deviceInt == -1 ) cout << "Using Device    = " << deviceString << endl;
   else cout << "Using Device    = " << deviceInt << endl;
   if ( portInt != -1 ) cout << "Using Port      = " << portInt   << endl;
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
         if ( portInt > 0 ) sidLink->linkOpen(deviceString,portInt);
         else if ( deviceInt == -1 ) sidLink->linkOpen(deviceString);
         else sidLink->linkOpen(deviceInt);
      } catch ( string error ) {
         cout << "Error opening link:\n";
         cout << error << "\n";
         cout << "Exiting!\n";
         return(1);
      }

      // Create Gui Windows
      kpixGuiTop = new KpixGuiTop(sidLink,clkInt,verInt,baseDir,calString,rateLimit);
      kpixGuiTop->show();
   }

   a.connect( &a, SIGNAL( lastWindowClosed() ), &a, SLOT( quit() ) );

   return a.exec(); 

   } catch (string error) {
      cout << "KpixGui -> An error was thrown: " << error << endl;
   }
}

