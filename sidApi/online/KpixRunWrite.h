//-----------------------------------------------------------------------------
// File          : KpixRunWrite.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/01/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class used to save KPIX run data.
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
//             timestamp. Added new constructor method that generates timestamp
//             internally.
// 04/30/2007: Added support for KpixFpga class.
// 02/29/2008: Added support for storing histogram & charts along with run data.
// 10/20/2008: Added support for calibration file string.
// 10/21/2008: Added support for run times to be passed along.
// 10/22/2008: Removed close function.
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_RUN_WRITE_H__
#define __KPIX_RUN_WRITE_H__

#include <string>
#include <TString.h>

// Forward declarations
class KpixBunchTrain;
class KpixSample;
class KpixEventVar;
class KpixRunVar;
class KpixAsic;
class KpixFpga;
class TFile;
class TTree;
class TBranch;

class KpixRunWrite {

      // Pointer Tree & Branches
      TTree   *asicTree;
      TBranch *asicBranch;
      TTree   *eventVarTree;
      TBranch *eventVarBranch;
      TTree   *runVarTree;
      TBranch *runVarBranch;
      TTree   *sampleTree;
      TBranch *sampleBranch;

      // Run variables
      TString runName;
      TString runTime;
      TString endTime;
      TString runDesc;
      TString runCalib;

      // Pointers to hold elements that will be returned
      KpixAsic     *kpixAsic;
      KpixFpga     *kpixFpga;
      KpixSample   *kpixSample;
      KpixRunVar   *kpixRunVar;
      KpixEventVar *kpixEventVar;

      // Event Variables 
      Int_t        eventVarCount;
      Double_t     eventVarValue[256];
      KpixEventVar *eventVar[256];

      // Run Variables
      Int_t      runVarCount;
      KpixRunVar *runVar[256];

      // Debug flag
      bool enDebug;

   public:

      // Tree File Is Public
      TFile *treeFile;

      // Function to generate and return timestamp.
      static std::string genTimestamp (); 

      // Create run write structure. Opens tree file for writing
      // Run timestamp is generated internally.
      // Pass the following values:
      //   runFile   = Filename for root file to create.
      //   runName   = Name of the run
      //   runDesc   = Description of the run
      //   runCalib  = Optional calibration file used for the run.
      //   runTime   = Optional run timestamp to pass along.
      //   endTime   = Optional end timestamp to pass along.
      //   debug     = Optional debug flag, true to enable debugging
      KpixRunWrite ( std::string runFile, TString runName, TString runDesc, 
                     TString runCalib = "", TString runTime = "",
                     TString endTime = "", bool debug=false );

      // Create a new event variable. This value will be added to
      // all stored sample objects. A KpixEventVar object will be created and stored
      // in the root tree. Pass the following values:
      // name  = Name of the variable.
      // desc  = Description of the variable.
      // value = Optional initial value
      void addEventVar ( TString name, TString desc, Double_t value = 0.0 );

      // Set event variable value, will be used as value in sample records stored from
      // this point on.  Pass the following values:
      // name  = Name of the variable
      // value = New variable value
      void setEventVar ( TString name, Double_t value );

      // Create a new run variable to hold run data. A KpixRunVar object will be created 
      // and stored in the root tree. Pass the following values:
      // name  = Name of the variable
      // desc  = Description of the variable
      // value = Optional initial value
      void addRunVar ( TString name, TString desc, Double_t value = 0.0 );

      // Add Bunch Train Data Class To Run,
      void addBunchTrain ( KpixBunchTrain *train );

      // Add Asic Data Class To Run,
      void addAsic ( KpixAsic *asic );

      // Add Fpga Data Class To Run,
      void addFpga ( KpixFpga *fpga );

      // Set current directory for storing plots
      // Directory is created if it does not exist
      void setDir ( std::string directory );

      // Deconstructor.
      virtual ~KpixRunWrite ();

};
#endif
