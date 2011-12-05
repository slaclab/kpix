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
#include <CommLink.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
KpixControl::KpixControl ( uint type, CommLink *commLink ) : System("KpixControl",commLink) {

   // Description
   desc_ = "Kpix Control";
   
   // Data mask, lane 0, vc/type 1
   commLink->setDataMask(0x12);

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

   // Data file nameing controls
   addVariable(new Variable("DataBase",Variable::Configuration));
   variables_["DataBase"]->setDescription("Base directory for auto data data files");

   addVariable(new Variable("DataAuto",Variable::Configuration));
   variables_["DataAuto"]->setDescription("Enable automatic data name generation");
   variables_["DataAuto"]->setTrueFalse();

   // Calib/dist control variables
   addVariable(new Variable("CalGainHigh",Variable::Configuration));
   variables_["CalGainHigh"]->setDescription("Enable high gain for calibration");
   variables_["CalGainHigh"]->setTrueFalse();

   addVariable(new Variable("CalGainNorm",Variable::Configuration));
   variables_["CalGainNorm"]->setDescription("Enable normal gain for calibration");
   variables_["CalGainNorm"]->setTrueFalse();

   addVariable(new Variable("CalGainLow",Variable::Configuration));
   variables_["CalGainLow"]->setDescription("Enable low gain for calibration");
   variables_["CalGainLow"]->setTrueFalse();

   addVariable(new Variable("CalMeanCount",Variable::Configuration));
   variables_["CalMeanCount"]->setDescription("Set number of iterations for mean fitting");
   variables_["CalMeanCount"]->setRange(0,10000);

   addVariable(new Variable("CalMeanEnable",Variable::Configuration));
   variables_["CalMeanEnable"]->setDescription("Enable calibration mean generation");
   variables_["CalMeanEnable"]->setTrueFalse();

   addVariable(new Variable("CalDacMin",Variable::Configuration));
   variables_["CalDacMin"]->setDescription("Min DAC value for calibration");
   variables_["CalDacMin"]->setRange(0,255);

   addVariable(new Variable("CalDacMax",Variable::Configuration));
   variables_["CalDacMax"]->setDescription("Max DAC value for calibration");
   variables_["CalDacMax"]->setRange(0,255);

   addVariable(new Variable("CalDacStep",Variable::Configuration));
   variables_["CalDacStep"]->setDescription("DAC increment value for calibration");
   variables_["CalDacStep"]->setRange(0,255);

   addVariable(new Variable("CalChanMin",Variable::Configuration));
   variables_["CalChanMin"]->setDescription("Calibration channel min");
   variables_["CalChanMin"]->setRange(0,255);

   addVariable(new Variable("CalChanMax",Variable::Configuration));
   variables_["CalChanMax"]->setDescription("Calibration channel max");
   variables_["CalChanMax"]->setRange(0,255);

   // Add sub-devices
   switch(type) {
      case Opto: 
         cout << "KpixControl::KpixControl -> Using Opto FPGA" << endl;
         addDevice(new OptoFpga(0, 0, this));
         break;
      case Con: 
         cout << "KpixControl::KpixControl -> Using Con FPGA" << endl;
         //addDevice(new FpgaCon(0, 0, this));
         break;
      default: cout << "KpixControl::KpixControl -> Invalid FPGA Type" << endl; break;
   }
}

// Deconstructor
KpixControl::~KpixControl ( ) { }

void KpixControl::swRunThread() {
   struct timespec tme;
   ulong           ctime;
   ulong           ltime;
   uint            runTotal;
   //uint            lastData;

   swRunning_ = true;
   clock_gettime(CLOCK_REALTIME,&tme);
   ltime = (tme.tv_sec * 1000000) + (tme.tv_nsec/1000);

   // Get run attributes
   runTotal  = 0;

   if ( debug_ ) {
      cout << "KpixControl::runThread -> Name: " << name_ 
           << ", Run Started"
           << ", RunCount=" << dec << swRunCount_
           << ", RunPeriod=" << dec << swRunPeriod_ << endl;
   }

   // Save run count
   //if ( 
   //lastData = 

   // Run
   while ( swRunEnable_ && runTotal < swRunCount_ ) {

      // Delay
      do {
         usleep(1);
         clock_gettime(CLOCK_REALTIME,&tme);
         ctime = (tme.tv_sec * 1000000) + (tme.tv_nsec/1000);
      } while ( (ctime-ltime) < swRunPeriod_);

      // Check that we received a data frame
      //while (                ) {

          //if ( !swRunEnable_ ) break;
      //}

      // Execute command
      ltime = ctime;
      commLink_->queueRunCommand();
      runTotal++;
      variables_["RunProgress"]->setInt((uint)(((double)runTotal/(double)swRunCount_)*100.0));
   }

   if ( debug_ ) {
      cout << "KpixControl::runThread -> Name: " << name_ 
           << ", Run Stopped, RunTotal = " << dec << runTotal << endl;
   }

   // Set run
   sleep(1);
   variables_["RunProgress"]->setInt((uint)(((double)runTotal/(double)swRunCount_)*100.0));
   variables_["RunState"]->set(swRunRetState_);
   swRunning_    = false;
   allStatusReq_ = true;
   pthread_exit(NULL);
}

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
      device("kpixFpga",0)->set("RunEnable","True");
      writeConfig(false);

      // Determine run command 
      if ( state == "Running Without Internal Trig/Cal" )
         device("kpixFpga",0)->setRunCommand("RunAcquire");
      if ( state == "Running With Internal Trig/Cal" ) 
         device("kpixFpga",0)->setRunCommand("RunCalibrate");

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

   // Run has stopped
   if ( variables_["RunState"]->get() == "Stopped" && device("kpixFpga",0)->get("RunEnable") == "True" ) {
      device("kpixFpga",0)->set("RunEnable","False");
      writeConfig(false);
   }

   return(loc);
}

//! Method to perform soft reset
void KpixControl::softReset ( ) {
   System::softReset();

   device("kpixFpga",0)->command("CountReset","");
}

//! Method to perform hard reset
void KpixControl::hardReset ( ) {
   bool gotVer = false;
   uint count = 0;

   System::hardReset();

   device("kpixFpga",0)->command("MasterReset","");
   do {
      sleep(1);
      try { 
         gotVer = true;
         device("kpixFpga",0)->readSingle("VersionMastReset");
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
   device("kpixFpga",0)->command("KpixCmdReset","");
}

