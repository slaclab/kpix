//-----------------------------------------------------------------------------
// File          : KpixRunWrite.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/01/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Source file for class used to save KPIX run data.
// This class is used to data is to be stored into a root file using a tree.
// Four tress with a single branch each are stored in the root file. 
// The branches accessed are:
//    AsicTree /     = Tree/Branch containing objects of KpixAsic class which 
//    AsicBranch       describe the ASIC configuration at the time of the start 
//                     of the run.
//    EventVarTree / = Branch containing objects of KpixEventVar class. This 
//    EventVarBranch   branch is used to associate the variable values stored
//                     in the sample class with a variable name, index and
//                     description.
//    RunVarTree /   = Branch containing objects of KpixRunVar class. This 
//    RunVarBranch     branch is used to store values associated with the    
//                     current run.
//    EventTree /    = Tree/Branch containing objects of KpixSample class which 
//    EventBranch      contain the actual data stored in the run.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/01/2006: created
// 03/19/2007: Modified for new root tree structure.
// 04/04/2007: Added internal generation of timestamp and storage of run stop
//             timestamp. Modified constructor.
// 04/29/2007: Sequence number is no longer kept locally. It is now generated by
//             hardware.
// 04/30/2007: Added support for KpixFpga class.
// 04/30/2007: Modified to throw strings instead of const char *
// 02/29/2008: Added support for storing histogram & charts along with run data.
// 10/20/2008: Added support for calibration file string.
// 10/21/2008: Added support for run times to be passed along.
// 10/22/2008: Removed close function.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
// 06/15/2010: Added calibration data string to run file
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <TFile.h>
#include <TTree.h>
#include <TBranch.h>
#include <TString.h>
#include "KpixBunchTrain.h"
#include "KpixRunWrite.h"
#include "../offline/KpixSample.h"
#include "../offline/KpixEventVar.h"
#include "../offline/KpixRunVar.h"
#include "../offline/KpixAsic.h"
#include "../offline/KpixFpga.h"
using namespace std;

// Function to generate and return current timestamp.
string KpixRunWrite::genTimestamp () {

   long         tme;
   struct tm    *tm_data;
   stringstream dateString;

   // Generate directory name based on time
   time(&tme);
   tm_data = localtime(&tme);
   dateString << dec << (tm_data->tm_year + 1900) << "_";
   dateString << dec << setw(2) << setfill('0') << (tm_data->tm_mon+1) << "_";
   dateString << dec << setw(2) << setfill('0') << tm_data->tm_mday    << "_";
   dateString << dec << setw(2) << setfill('0') << tm_data->tm_hour    << "_";
   dateString << dec << setw(2) << setfill('0') << tm_data->tm_min     << "_";
   dateString << dec << setw(2) << setfill('0') << tm_data->tm_sec;
   return(dateString.str());
}


// Create run write structure. Opens tree file for writing
// Run timestamp is generated internally.
// Pass the following values:
//   runFile   = Filename for root file to create.
//   runName   = Name of the run
//   runDesc   = Description of the run
//   debug     = Optional debug flag, true to enable debugging
KpixRunWrite::KpixRunWrite (string runFile, TString runName, TString runDesc, 
                            TString runCalib, TString runTime,
                            TString endTime , bool debug ) {
   int i;

   // Init sample id value, store debug
   enDebug  = debug;

   // Init event variable count
   eventVarCount = 0;
   for(i=0; i < 256; i++) {
      eventVar[i]      = NULL;
      eventVarValue[i] = 0;
   }

   // Init run variable count
   runVarCount = 0;
   for(i=0; i < 256; i++) runVar[i]  = NULL;

   // Init record pointers
   kpixAsic       = NULL;
   kpixFpga       = NULL;
   kpixSample     = NULL;
   kpixEventVar   = NULL;
   kpixRunVar     = NULL;
   sampleBranch   = NULL;
   asicBranch     = NULL;
   runVarBranch   = NULL;
   eventVarBranch = NULL;

   // Update run time
   if ( runTime == "" ) runTime = genTimestamp();

   // Store passed values
   this->runName   = runName;
   this->runTime   = runTime;
   this->endTime   = endTime;
   this->runDesc   = runDesc;
   this->runCalib  = runCalib;
   this->calibData = "";

   // Open root file
   if ( (treeFile = new TFile(runFile.c_str(),"recreate")) == NULL ) 
      throw(string("KpixRunWrite::KpixRunWrite -> Could not open root file!"));

   // Detect if file is stale
   if ( treeFile->IsZombie() )
      throw(string("KpixRunWrite::KpixRunWrite -> Unable To Open File"));

   // Create trees
   asicTree     = new TTree("AsicTree","Tree Containing KpixAsic Objects");
   eventVarTree = new TTree("EventVarTree","Tree Containing KpixEventVar Objects");
   runVarTree   = new TTree("RunVarTree","Tree Containing KpixRunVar Objects");
   sampleTree   = new TTree("SampleTree","Tree Containing KpixSample Objects");

   // Store Variables
   treeFile->WriteObject(&runName,"RunName");
   treeFile->WriteObject(&runTime,"RunTime");
   treeFile->WriteObject(&runDesc,"RunDesc");
   treeFile->WriteObject(&runCalib,"RunCalib");

   // Set autosave for tree file
   asicTree->SetAutoSave(1024);
   eventVarTree->SetAutoSave(1024);
   runVarTree->SetAutoSave(1024);
   sampleTree->SetAutoSave(1024);
}


// Create a new event variable. This value will be added to
// all stored sample objects. A KpixEventVar object will be created and stored
// in the root tree. Pass the following values:
// name  = Name of the variable
// desc  = Description of the variable
// value = Optional initial value
void KpixRunWrite::addEventVar ( TString name, TString desc, Double_t value ) {

   int i;
   bool found=false;

   // Determine if variable exists
   for ( i=0; i < eventVarCount; i++ )
      if ( eventVar[i]->name() == name ) found = true;

   // Record was not found, create new record
   if ( ! found ) {

      // Max count reached
      if ( eventVarCount == 256 ) 
         throw (string("KpixRunWrite::addEventVar -> Max variable count reached"));
     
      // Add variable
      kpixEventVar = new KpixEventVar(eventVarCount,name,desc);
      eventVar[eventVarCount]      = kpixEventVar;
      eventVarValue[eventVarCount] = value;
      eventVarCount++;

      // Store variable to root tree
      if ( eventVarBranch == NULL )
         eventVarBranch = eventVarTree->Branch("EventVarBranch","KpixEventVar",&kpixEventVar);

      // Fill tree
      eventVarTree->Fill();
   }
}


// Set event variable value, will be used as value in event records stored from
// this point on.  Pass the following values:
// name  = Name of the variable
// value = New variable value
void KpixRunWrite::setEventVar ( TString name, Double_t value ) {

   int i;
   bool found = false;

   // Determine if variable exists
   for ( i=0; i < eventVarCount; i++ ) {
      if ( eventVar[i]->name() == name ) {
         eventVarValue[i] = value;
         found=true;
      }
   }

   // Variable was not found 
   if ( ! found ) throw (string("KpixRunWrite::setEventVar -> Variable not found"));
}


// Create a new run variable to hold run data. A KpixRunVar object will be created 
// and stored in the root tree. Pass the following values:
// name  = Name of the variable
// desc  = Description of the variable
// value = Optional initial value
void KpixRunWrite::addRunVar ( TString name, TString desc, Double_t value ) {

   int i;
   bool found=false;

   // Determine if variable exists
   for ( i=0; i < runVarCount; i++ ) 
      if ( runVar[i]->name() == name ) found = true;

   // Record was not found, create new record
   if ( ! found ) {

      // Max count reached
      if ( runVarCount == 256 ) 
         throw (string("KpixRunWrite::addRunVar -> Max variable count reached"));
     
      // Add variable
      kpixRunVar          = new KpixRunVar(name,desc,value);
      runVar[runVarCount] = kpixRunVar;
      runVarCount++;

      // Store variable to root tree
      if ( runVarBranch == NULL )
         runVarBranch = runVarTree->Branch("RunVarBranch","KpixRunVar",&kpixRunVar);

      // Fill tree
      runVarTree->Fill();
   }
}


// Add Bunch Train Data Class To Run,
void KpixRunWrite::addBunchTrain ( KpixBunchTrain *train ) {

   KpixSample   **sampleList;
   unsigned int sampleCount;
   unsigned int i;

   // Get sample list and count from bunch train
   sampleCount = train->getSampleCount();
   sampleList  = train->getSampleList();

   // Go through each event in the sample and add it to tree
   for ( i=0; i < sampleCount; i++ ) {

      // Set variable values and sample number, set pointer
      sampleList[i]->setVariables(eventVarCount,eventVarValue);
      kpixSample = sampleList[i];

      // Create event branch if it does not already exist
      if ( sampleBranch == NULL )
         sampleBranch = sampleTree->Branch("SampleBranch","KpixSample",&kpixSample);

      // Fill tree
      sampleTree->Fill();
   }
}


// Add Asic Data Class To Run,
void KpixRunWrite::addAsic ( KpixAsic *asic ) {

   // Set pointer
   kpixAsic = asic;

   // Create event branch if it does not already exist
   if ( asicBranch == NULL ) 
      asicBranch = asicTree->Branch("AsicBranch","KpixAsic",&kpixAsic);

   // Fill tree
   asicTree->Fill();
}


// Add FPGA Data Class To Run,
void KpixRunWrite::addFpga ( KpixFpga *fpga ) {

   // Set pointer
   kpixFpga = fpga;

   // Add object to tree
   treeFile->WriteObject(kpixFpga,"KpixFpga");
}


// Set current directory for storing plots
// Directory is created if it does not exist
void KpixRunWrite::setDir ( string directory ) {

   // Return to the base directory
   treeFile->cd("/");

   // Attempt to change to the directory
   if ( ! treeFile->cd(directory.c_str()) ) {

      // Create it if it does not exist
      treeFile->mkdir(directory.c_str());

      // Change to directory
      treeFile->cd(directory.c_str());
   }
}


// Add calibData xml string to run file
void KpixRunWrite::addCalibData ( TString calibData ) {
   this->calibData = calibData;
}


// Close open tree file. 
// Must be called to ensure all data is written to file
KpixRunWrite::~KpixRunWrite () {

   int i;

   // Add calib data to file
   treeFile->WriteObject(&calibData,"CalibData");

   // Delete event variables
   for (i=0; i < eventVarCount; i++) delete eventVar[i];

   // Add run variable names as string branch
   for (i=0; i < runVarCount; i++) delete runVar[i];

   // Add end timestamp
   if ( endTime == "" ) endTime = genTimestamp();
   treeFile->WriteObject(&endTime,"EndTime");

   // Write header and close
   asicTree->Write();
   eventVarTree->Write();
   runVarTree->Write();
   sampleTree->Write();
   treeFile->Close();
   delete treeFile;
}


