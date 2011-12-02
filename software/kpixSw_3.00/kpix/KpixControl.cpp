//-----------------------------------------------------------------------------
// File          : KpixControl.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : Heavy Photon KpixControl
//-----------------------------------------------------------------------------
// Description :
// Control FPGA container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#include <KpixControl.h>
#include <OptoFpga.h>
#include <Register.h>
#include <Variable.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixControl::KpixControl ( uint type ) : System("KpixControl") {

   // Description
   desc_ = "Kpix Control";
   
   // Data mask, lane 0, vc/type 1
   dataMask_ = 0x12;

   // Set run states
   vector<string> states;
   states.resize(3);
   states[0] = "Stopped";
   states[1] = "Running Without Internal Trig/Cal";
   states[2] = "Running With Internal Trig/Cal";
   variables_["RunState"]->setEnums(states);

   // Set run rates
   vector<string> rates;
   rates.resize(4);
   rates[0] = "1Hz";
   rates[1] = "10Hz";
   rates[2] = "20Hz";
   rates[3] = "30Hz";
   variables_["RunRate"]->setEnums(rates);

   addVariable(new Variable("DataBase",Variable::Configuration));
   variables_["DataBase"]->setDescription("Base directory for auto data data files");

   addVariable(new Variable("DataAuto",Variable::Configuration));
   variables_["DataAuto"]->setDescription("Enable automatic data name generation");
   variables_["DataAuto"]->setTrueFalse();

   // Add sub-devices
   switch(type) {
      case Opto: 
         cout << "KpixControl::KpixControl -> Using Opto FPGA" << endl;
         addDevice(new OptoFpga(0, 0, this));
         fpga_ = "optoFpga";
         break;
      case Con: 
         cout << "KpixControl::KpixControl -> Using Con FPGA" << endl;
         //addDevice(new FpgaCon(0, 0, this));
         fpga_ = "conFpga";
         break;
      default: cout << "KpixControl::KpixControl -> Invalid FPGA Type" << endl; break;
   }
}

// Deconstructor
KpixControl::~KpixControl ( ) { }

// Method to process a command
void KpixControl::command ( string name, string arg ) {
   stringstream tmp;
   stringstream dateString;
   long         tme;
   struct tm    *tm_data;

   // Intercept file open command, overwrite data file variable
   if ( name == "OpenDataFile" && variables_["DataAuto"]->get() == "True" ) {
      time(&tme);
      tm_data = localtime(&tme);
      tmp.str("");
      tmp << variables_["DataBase"]->get() << "/";
      tmp << dec << (tm_data->tm_year + 1900) << "_";
      tmp << dec << setw(2) << setfill('0') << (tm_data->tm_mon+1) << "_";
      tmp << dec << setw(2) << setfill('0') << tm_data->tm_mday    << "_";
      tmp << dec << setw(2) << setfill('0') << tm_data->tm_hour    << "_";
      tmp << dec << setw(2) << setfill('0') << tm_data->tm_min     << "_";
      tmp << dec << setw(2) << setfill('0') << tm_data->tm_sec;
      tmp << ".bin";
      variables_["DataFile"]->set(tmp.str());
   }
   System::command(name,arg);
}

// Method to set run state
void KpixControl::setRunState ( string state ) {
   stringstream err;

   // Stopped state is requested
   if ( state == "Stopped" ) swRunEnable_ = false;

   // Running state is requested
   else if ( !swRunning_ && ( state == "Running Without Internal Trig/Cal" ||
                              state == "Running With Internal Trig/Cal" ) ) {
      swRunRetState_ = "Stopped";
      swRunEnable_   = true;
      variables_["RunState"]->set(state);

      // Determine run command 
      if ( state == "Running Without Internal Trig/Cal" )
         device(fpga_,0)->setRunCommand("RunAcquire");
      if ( state == "Running With Internal Trig/Cal" ) 
         device(fpga_,0)->setRunCommand("RunCalibrate");

      // Setup run parameters
      swRunCount_ = getInt("RunCount");
      if      ( get("RunRate") == "30Hz") swRunPeriod_ =   33333;
      else if ( get("RunRate") == "20Hz") swRunPeriod_ =   50000;
      else if ( get("RunRate") == "10Hz") swRunPeriod_ =  100000;
      else if ( get("RunRate") ==  "1Hz") swRunPeriod_ = 1000000;
      else swRunPeriod_ = 1000000;

      // Start thread
      if ( swRunCount_ > 0 && pthread_create(&swRunThread_,NULL,swRunStatic,this) ) {
         err << "KpixControl::startRun -> Failed to create ioThread" << endl;
         if ( debug_ ) cout << err.str();
         variables_["RunState"]->set(swRunRetState_);
         throw(err.str());
      }
   }
}

//! Method to return state string
string KpixControl::localState ( ) {
   string loc = "";

   loc = "System Ready To Take Data.\n";

   return(loc);
}

//! Method to perform soft reset
void KpixControl::softReset ( ) {
   System::softReset();

   device(fpga_,0)->command("CountReset","");
}

//! Method to perform hard reset
void KpixControl::hardReset ( ) {
   bool gotVer = false;
   uint count = 0;

   System::hardReset();

   device(fpga_,0)->command("MasterReset","");
   do {
      sleep(1);
      try { 
         gotVer = true;
         device(fpga_,0)->readSingle("Version");
      } catch ( string err ) { 
         if ( count > 5 ) {
            gotVer = true;
            throw(string("KpixControl::hardReset -> Error contacting fpga"));
         }
         else {
            count++;
            gotVer = false;
         }
      }
   } while ( !gotVer );
   device(fpga_,0)->command("KpixCmdReset","");
}

