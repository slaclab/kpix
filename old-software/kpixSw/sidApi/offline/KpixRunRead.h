//-----------------------------------------------------------------------------
// File          : KpixRunRead.h
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
// 03/08/2007: created
// 03/12/2007: Removed event display from dump function.
// 03/19/2007: Changed for new format with four seperate trees.
// 04/04/2007: Added support for run end timestamp.
// 04/12/2007: Added method to return run duration in seconds
// 04/30/2007: Added support for KpixFpga class.
// 10/16/2008: Tree pointer is now public for external access.
// 10/20/2008: Added support for calibration source dir.
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespace.
// 06/15/2010: Added calibration data string to run file
//-----------------------------------------------------------------------------
#ifndef __KPIX_RUN_READ_H__
#define __KPIX_RUN_READ_H__

#include <string>
#include <TString.h>

// Forward declarations
class KpixSample;
class KpixEventVar;
class KpixRunVar;
class KpixAsic;
class KpixFpga;
class TFile;
class TTree;
class TBranch;

/** \ingroup offline */

//! Kpix RunRead Class.
/*!
   This class is used to retrieve run data from a KPIX Asic device in a DAQ system. In online mode
   this device is used to communicate directly with the KPIX hardware, allowing the device
   to be configured and operated. In offline mode this class is used to read back the
   values from the device as it was operated in the run which generated the root
   data file.
*/

class KpixRunRead {

      // Pointer To Tree & Branches
      TTree   *asicTree;
      TBranch *asicBranch;
      TTree   *eventVarTree;
      TBranch *eventVarBranch;
      TTree   *runVarTree;
      TBranch *runVarBranch;
      TTree   *sampleTree;
      TBranch *sampleBranch;

      // Run variables
      TString *runName;
      TString *runTime;
      TString *endTime;
      TString *runDesc;
      TString *runCalib;
      TString *calibData;

      // Default TString
      TString blankString;

      // Pointers to hold elements that will be returned
      KpixSample   *kpixSample;
      KpixRunVar   *kpixRunVar;
      KpixEventVar *kpixEventVar;

      // Local copy of FPGA & Asics
      KpixFpga *kpixFpga;
      Int_t    asicCount;
      KpixAsic **kpixAsic;

      // Debug flag
      bool enDebug;

   public:

      // Pointer to tree file structure
      TFile *treeFile;

      //! Create run read object. Opens tree file for reading
      /*! Pass the following values:
		rootFile  = Root file containing data
		debug     = Optional debug flag, true to enable debugging
		*/
      KpixRunRead ( std::string rootFile, bool debug );

      // Return pointer to tree in the data file
      TTree * getAsicTree ();
      TTree * getEventVarTree ();
      TTree * getRunVarTree ();
      TTree * getSampleTree ();

      // Return pointer to branch in the data file
      TBranch * getAsicBranch ();
      TBranch * getEventVarBranch ();
      TBranch * getRunVarBranch ();
      TBranch * getSampleBranch ();

      //! Get Run Calibation Source
      TString getRunCalib ();

      //! Get Run Name
      TString getRunName ();

      //! Get Run Timestamp
      TString getRunTime ();

      //! Get End Timestamp
      TString getEndTime ();

      //! Get Calibration Data
      TString getCalibData ();

      //! Get Run Duration In Seconds
      Int_t getRunDuration();

      //! Get Run Description
      TString getRunDescription ();

      //! Return number of ASIC objects
      Int_t getAsicCount();

      //! Return ASIC by index
      KpixAsic *getAsic( Int_t index );

      //! Return ASIC List
      KpixAsic **getAsicList( );

      //! Return FPGA
      KpixFpga *getFpga( );

      //! Return number of sample objects
      Int_t getSampleCount();

      //! Return sample by index
      KpixSample *getSample( Int_t index );

      //! Return number of Event Variables
      Int_t getEventVarCount();

      //! Return Event Variable by index
      KpixEventVar *getEventVar( Int_t index );

      //! Return Event Variable by name
      KpixEventVar *getEventVar( std::string name );

      //! Return number of Run Variables
      Int_t getRunVarCount();

      //! Return Run Variable by index
      KpixRunVar *getRunVar( Int_t index );

      //! Return Run Variable by name
      KpixRunVar *getRunVar( std::string name );

      //! Dump Run Data
      void dumpRunData ( );

      //! Deconstructor
      virtual ~KpixRunRead ( );
};
#endif
