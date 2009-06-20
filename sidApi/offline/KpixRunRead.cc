//-----------------------------------------------------------------------------
// File          : KpixRunRead.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/08/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class used to read KPIX run data.
// This class is not actually stored in the root file.
// Four tress with a single branch each are accessed in the root file. 
// The branches accessed are:
//    AsicTree /     = Tree/Branch containing objects of KpixAsic class which 
//      AsicBranch     describe the ASIC configuration at the time of the start 
//                     of the run.
//    EventVarBranch = Branch containing objects of KpixEventVar class. This 
//                     branch is used to associate the variable values stored
//                     in the sample class with a variable name, index and
//                     description.
//    RunVarBranch   = Branch containing objects of KpixRunVar class. This 
//                     branch is used to store values associated with the    
//                     current run.
//    EventTree /    = Tree/Branch containing objects of KpixSample class which 
//      EventBranch    contain the actual data stored in the run.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/08/2007: created
// 03/12/2007: Removed event display from dump function.
// 03/19/2007: Changed for new format with four seperate trees.
// 04/04/2007: Added support for run end timestamp.
// 04/12/2007: Added method to return run duration in seconds
// 04/30/2007: Added support for KpixFpga class.
// 04/30/2007: Modified to throw strings instead of const char *
// 07/31/2007: Fixed bug in routine to get run variable by index.
// 10/20/2008: Added support for calibration source dir.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <TString.h>
#include <TFile.h>
#include <TTree.h>
#include "KpixSample.h"
#include "KpixAsic.h"
#include "KpixFpga.h"
#include "KpixRunVar.h"
#include "KpixEventVar.h"
#include "KpixRunRead.h"
using namespace std;
using namespace sidApi::offline;

// Create run read object. Opens tree file for reading
// Pass the following values:
//   rootFile  = Root file containing data
//   debug     = Optional debug flag, true to enable debugging
KpixRunRead::KpixRunRead ( string rootFile, bool debug ) {

   KpixAsic *tempAsic;
   KpixFpga *tempFpga;
   int      x;

   // Init sample id value, store debug
   enDebug  = debug;

   // Attempt to open root file
   if ( (treeFile = new TFile(rootFile.c_str(),"READ")) == NULL )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open File"));

   // Detect if file is stale
   if ( treeFile->IsZombie() )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open File"));

   // Open individual trees
   if ( (asicTree = (TTree *) treeFile->Get("AsicTree")) == NULL )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open 'AsicTree' Tree"));
   if ( (eventVarTree = (TTree *) treeFile->Get("EventVarTree")) == NULL )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open 'EventVarTree' Tree"));
   if ( (runVarTree = (TTree *) treeFile->Get("RunVarTree")) == NULL )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open 'RunVarTree' Tree"));
   if ( (sampleTree = (TTree *) treeFile->Get("SampleTree")) == NULL )
      throw(string("KpixRunRead::KpixRunRead -> Unable To Open 'SampleTree' Tree"));

   // Open Branches
   asicBranch     = asicTree->GetBranch("AsicBranch");
   eventVarBranch = eventVarTree->GetBranch("EventVarBranch");
   runVarBranch   = runVarTree->GetBranch("RunVarBranch");
   sampleBranch   = sampleTree->GetBranch("SampleBranch");

   // Get Variables
   treeFile->GetObject("RunName",runName);
   treeFile->GetObject("RunTime",runTime);
   treeFile->GetObject("EndTime",endTime);
   treeFile->GetObject("RunDesc",runDesc);
   treeFile->GetObject("RunCalib",runCalib);

   // Missing strings
   if ( runName  == NULL ) runName  = &blankString;
   if ( runTime  == NULL ) runTime  = &blankString;
   if ( endTime  == NULL ) endTime  = &blankString;
   if ( runDesc  == NULL ) runDesc  = &blankString;
   if ( runCalib == NULL ) runCalib = &blankString;

   // Debug open attempt
   if ( enDebug ) {
      cout << "KpixRunRead::KpixRunRead -> Opened Root File " << rootFile << "\n";
      cout << "        Asic Branch Count = " << dec << asicTree->GetEntries() << "\n";
      cout << "   Event Var Branch Count = " << dec << eventVarTree->GetEntries() << "\n";
      cout << "     Run Var Branch Count = " << dec << runVarTree->GetEntries() << "\n";
      cout << "      Sample Branch Count = " << dec << sampleTree->GetEntries() << "\n";
   }

   // Create objects for returning data
   if ( asicBranch != NULL ) {
      tempAsic = new KpixAsic();  
      asicBranch->SetAddress(&tempAsic);
   }
   if ( sampleBranch != NULL ) {
      kpixSample = new KpixSample(); 
      sampleBranch->SetAddress(&kpixSample);
   }
   if ( runVarBranch != NULL ) {
      kpixRunVar = new KpixRunVar(); 
      runVarBranch->SetAddress(&kpixRunVar);
   }
   if ( eventVarBranch != NULL ) {
      kpixEventVar = new KpixEventVar(); 
      eventVarBranch->SetAddress(&kpixEventVar);
   }

   // Get Fpga data
   tempFpga = NULL;
   treeFile->GetObject("KpixFpga",tempFpga);
   if ( tempFpga == NULL ) kpixFpga = new KpixFpga();
   else kpixFpga = new KpixFpga(*tempFpga);

   // Get Asics
   asicCount = asicTree->GetEntries();
   kpixAsic = (KpixAsic **) malloc(sizeof(KpixAsic *)*asicCount);
   if ( kpixAsic == NULL ) throw(string("KpixRunRead::KpixRunRead -> Malloc Error"));

   for (x=0; x<asicCount; x++) {
      asicBranch->GetEntry(x);
      kpixAsic[x] = new KpixAsic(*tempAsic);
   }
}


// Return pointer to tree in the data file
TTree * KpixRunRead::getAsicTree ()     { return(asicTree); }
TTree * KpixRunRead::getEventVarTree () { return(eventVarTree); }
TTree * KpixRunRead::getRunVarTree ()   { return(runVarTree); }
TTree * KpixRunRead::getSampleTree ()   { return(sampleTree); }


// Return pointer to branch in the data file
TBranch * KpixRunRead::getAsicBranch ()     { return(asicBranch); }
TBranch * KpixRunRead::getEventVarBranch () { return(eventVarBranch); }
TBranch * KpixRunRead::getRunVarBranch ()   { return(runVarBranch); }
TBranch * KpixRunRead::getSampleBranch ()   { return(sampleBranch); }


// Get Run Name
TString KpixRunRead::getRunName () { return(*runName); }


// Get Run Timestamp
TString KpixRunRead::getRunTime () { return(*runTime); }


// Get End Timestamp
TString KpixRunRead::getEndTime () { return(*endTime); }


// Get Run Duration In Seconds
Int_t KpixRunRead::getRunDuration() {

   struct tm    tm_start;
   struct tm    tm_end;
   stringstream tempString;
   int          duration;
   char         tempChar[100];

   if ( *runTime == "" || *endTime == "" ) return(0);

   // Convert start time into start time structure
   tempString.str("");
   tempString << *runTime;
   strcpy(tempChar,tempString.str().c_str());
   tm_start.tm_isdst = 1;
   tm_start.tm_year  = atoi(strtok(tempChar,"_")) - 1900;
   tm_start.tm_mon   = atoi(strtok(NULL,"_"));
   tm_start.tm_mday  = atoi(strtok(NULL,"_"));
   tm_start.tm_hour  = atoi(strtok(NULL,"_"));
   tm_start.tm_min   = atoi(strtok(NULL,"_"));
   tm_start.tm_sec   = atoi(strtok(NULL,"_"));

   // Convert end time into end time structure
   tempString.str("");
   tempString << *endTime;
   strcpy(tempChar,tempString.str().c_str());
   tm_end.tm_isdst = 1;
   tm_end.tm_year  = atoi(strtok(tempChar,"_")) - 1900;
   tm_end.tm_mon   = atoi(strtok(NULL,"_"));
   tm_end.tm_mday  = atoi(strtok(NULL,"_"));
   tm_end.tm_hour  = atoi(strtok(NULL,"_"));
   tm_end.tm_min   = atoi(strtok(NULL,"_"));
   tm_end.tm_sec   = atoi(strtok(NULL,"_"));

   // Calculate run duration
   duration = mktime(&tm_end) - mktime(&tm_start);
   return(duration);
}


// Get Run Description
TString KpixRunRead::getRunDescription () { return(*runDesc); }


// Get Run Calibration
TString KpixRunRead::getRunCalib () { return(*runCalib); }


// Return number of ASIC objects
Int_t KpixRunRead::getAsicCount() { return(asicTree->GetEntries()); }


// Return ASIC by index
KpixAsic *KpixRunRead::getAsic( Int_t index ) { return(kpixAsic[index]); }


// Return ASIC by index
KpixAsic **KpixRunRead::getAsicList( ) { return(kpixAsic); }


// Return FPGA
KpixFpga *KpixRunRead::getFpga( ) { return(kpixFpga); }


// Return number of sample objects
Int_t KpixRunRead::getSampleCount() { return(sampleTree->GetEntries()); }


// Return Event by index
KpixSample *KpixRunRead::getSample( Int_t index ) {

   // Is index in range?
   if ( index >= sampleTree->GetEntries() ) return(NULL);

   // Read data and return
   sampleBranch->GetEntry(index);
   return(kpixSample);
}


// Return number of Event Variables
Int_t KpixRunRead::getEventVarCount() { return(eventVarTree->GetEntries()); }


// Return Event Variable by index
KpixEventVar *KpixRunRead::getEventVar( Int_t index ) {

   // Is index in range?
   if ( index >= eventVarTree->GetEntries() ) return(NULL);

   // Read data and return
   eventVarBranch->GetEntry(index);
   return(kpixEventVar);
}


// Return Event Variable by name
KpixEventVar *KpixRunRead::getEventVar( string name ) {

   int x;
   bool found=false;

   // Loop through entries and attempt to find variable
   for (x=0; x < eventVarTree->GetEntries(); x++) {
      eventVarBranch->GetEntry(x);
      if ( kpixEventVar->name() == name ) {
         found=true;
         break;
      }
   }

   if ( found ) return(kpixEventVar);
   return(NULL);
}


// Return number of Run Variables
Int_t KpixRunRead::getRunVarCount() { return(runVarTree->GetEntries()); }


// Return Run Variable by index
KpixRunVar *KpixRunRead::getRunVar( Int_t index ) {

   // Is index in range?
   if ( index >= runVarTree->GetEntries() ) return(NULL);

   // Read data and return
   runVarBranch->GetEntry(index);
   return(kpixRunVar);
}


// Return Run Variable by name
KpixRunVar *KpixRunRead::getRunVar( string name ) {

   int x;
   bool found=false;

   // Loop through entries and attempt to find variable
   for (x=0; x < runVarTree->GetEntries(); x++) {
      runVarBranch->GetEntry(x);
      if ( kpixRunVar->name() == name ) {
         found=true;
         break;
      }
   }

   if ( found ) return(kpixRunVar);
   return(NULL);
}


// Dump Run Data
void KpixRunRead::dumpRunData ( ) {

   int x,count;

   // Dump event count
   cout << "\n";
   cout << "---------- Dumping Run Data ----------\n";
   count = getSampleCount();
   cout << "      Run Name: " << *runName << "\n";
   cout << "      Run Time: " << *runTime << "\n";
   cout << "      End Time: " << *endTime << "\n";
   cout << "    Run Length: " << getRunDuration() << " Seconds\n";
   cout << "      Run Desc: " << *runDesc << "\n";
   cout << "  Sample Count: " << dec << count << "\n";

   // Dump Fpga
   cout << "\n";
   cout << "---------- Dumping Fpga Settings ----------\n";
   kpixFpga->dumpSettings();

   // Dump Tree Contents
   count = getAsicCount();
   for ( x=0; x < count; x++ ) {
      cout << "\n";
      cout << "---------- Dumping Kpix " << dec << x << " Settings ----------\n";
      getAsic(x)->dumpSettings();
   }

   cout << "\n";
   cout << "---------- Dumping Run Variables ----------\n";
   count = getRunVarCount();
   for ( x=0; x < count; x++ ) {
      getRunVar(x);
      cout << "Run Variable " << dec << x << ": ";
      cout << kpixRunVar->name() << "=" << kpixRunVar->value() << ", ";
      cout << kpixRunVar->description() << "\n";
   }

   cout << "\n";
   cout << "---------- Dumping Event Variables ----------\n";
   count = getEventVarCount();
   for ( x=0; x < count; x++ ) {
      cout << "Event Variable " << dec << x << ": ";
      getEventVar(x);
      cout << kpixEventVar->name() << ", ";
      cout << kpixEventVar->description() << "\n";
   }
   cout << "\n";
}


// Deconstructor
KpixRunRead::~KpixRunRead ( ) {

   int x;

   // Delete Branch Variables
   if ( sampleBranch   != NULL ) { delete kpixSample;   }
   if ( runVarBranch   != NULL ) { delete kpixRunVar;   } 
   if ( eventVarBranch != NULL ) { delete kpixEventVar; }

   // Delete FPGA
   if ( kpixFpga != NULL ) delete kpixFpga;

   // Delete Asics
   for (x=0; x<asicCount; x++) delete kpixAsic[x];
   free(kpixAsic);
   treeFile->Close();
   delete treeFile;
}

