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
   states.resize(4);
   states[0] = "Stopped";
   states[1] = "Running Without Internal Trig/Cal";
   states[2] = "Running With Internal Trig/Cal";
   states[3] = "Running Calibration";
   variables_["RunState"]->setEnums(states);

   // Set run rates
   vector<string> rates;
   rates.resize(6);
   rates[0] = "1Hz";
   rates[1] = "10Hz";
   rates[2] = "20Hz";
   rates[3] = "30Hz";
   rates[4] = "40Hz";
   rates[5] = "40Hz";
   variables_["RunRate"]->setEnums(rates);

   // Data file nameing controls
   addVariable(new Variable("DataBase",Variable::Configuration));
   variables_["DataBase"]->setDescription("Base directory for auto data data files");

   addVariable(new Variable("DataAuto",Variable::Configuration));
   variables_["DataAuto"]->setDescription("Enable automatic data name generation");
   variables_["DataAuto"]->setTrueFalse();

   // Calib/dist control variables
   addVariable(new Variable("CalMeanCount",Variable::Configuration));
   variables_["CalMeanCount"]->setDescription("Set number of iterations for mean fitting");
   variables_["CalMeanCount"]->setRange(1,10000);
   variables_["CalMeanCount"]->setInt(4000);

   addVariable(new Variable("CalDacMin",Variable::Configuration));
   variables_["CalDacMin"]->setDescription("Min DAC value for calibration");
   variables_["CalDacMin"]->setRange(0,255);
   variables_["CalDacMin"]->setInt(0);

   addVariable(new Variable("CalDacMax",Variable::Configuration));
   variables_["CalDacMax"]->setDescription("Max DAC value for calibration");
   variables_["CalDacMax"]->setRange(0,255);
   variables_["CalDacMax"]->setInt(255);

   addVariable(new Variable("CalDacStep",Variable::Configuration));
   variables_["CalDacStep"]->setDescription("DAC increment value for calibration");
   variables_["CalDacStep"]->setRange(0,255);
   variables_["CalDacStep"]->setInt(0);

   addVariable(new Variable("CalChanMin",Variable::Configuration));
   variables_["CalChanMin"]->setDescription("Calibration channel min");
   variables_["CalChanMin"]->setRange(0,1023);
   variables_["CalChanMin"]->setInt(0);

   addVariable(new Variable("CalChanMax",Variable::Configuration));
   variables_["CalChanMax"]->setDescription("Calibration channel max");
   variables_["CalChanMax"]->setRange(0,1023);
   variables_["CalChanMax"]->setInt(1023);

   addVariable(new Variable("CalState",Variable::Status));
   variables_["CalState"]->setDescription("Calibration state");
   vector<string> calState;
   calState.resize(3);
   calState[0] = "Idle";
   calState[1] = "Baseline";
   calState[2] = "Inject";
   variables_["CalState"]->setEnums(calState);

   addVariable(new Variable("CalChannel",Variable::Status));
   variables_["CalChannel"]->setDescription("Calibration channel");
   variables_["CalChannel"]->setComp(0,1,0,"");
   variables_["CalChannel"]->setInt(0);

   addVariable(new Variable("CalDac",Variable::Status));
   variables_["CalDac"]->setDescription("Calibration DAC value");
   variables_["CalDac"]->setComp(0,1,0,"");
   variables_["CalDac"]->setInt(0);

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

// Setup config for calibration
void KpixControl::calibConfig ( uint channel, uint dac ) {
   uint            x;
   uint            col;
   uint            row;
   string          modeString;
   stringstream    newConfig;
   newConfig.str("");

   // Row column index
   col = (channel>1023)?32:(channel/32);
   row = channel%32;

   // Disable self trigger. Set forced trigger
   newConfig << "<system><config><kpixFpga><kpixAsic>";
   newConfig << "<CntrlCalSource>Internal</CntrlCalSource>";
   newConfig << "<CntrlForceTrigSource>Internal</CntrlForceTrigSource>";
   newConfig << "<CntrlTrigDisable>True</CntrlTrigDisable>";
   newConfig << "<DacCalibration>"<< dec << dac << "</DacCalibration>";
   for (x=0; x < 32; x++) {
      newConfig << "<ColMode_" << setw(2) << setfill('0') << dec << x << ">";
      modeString = "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD";
      if ( col == x ) modeString[row] = 'C';
      newConfig << modeString;
      newConfig << "</ColMode_" << setw(2) << setfill('0') << dec << x << ">";
   }
   newConfig << "</kpixAsic></kpixFpga></config></system>\n";
   parseXml(newConfig.str(),false);

   // Update a few status variables in data file
   newConfig.str("");
   newConfig << "<status>" << endl;
   newConfig << "<CalState>"   << variables_["CalState"]->get()   << "</CalState>" << endl;
   newConfig << "<CalChannel>" << variables_["CalChannel"]->get() << "</CalChannel>" << endl;
   newConfig << "<CalDac>"     << variables_["CalDac"]->get()     << "</CalDac>" << endl;
   newConfig << "</status>" << endl;
   commLink_->addStatus(newConfig.str());
   usleep(100);
}

void KpixControl::swRunThread() {
   struct timespec tme;
   ulong           ctime;
   ulong           ltime;
   uint            runTotal;
   uint            lastData;
   uint            calMeanCount;
   uint            calDacMin;
   uint            calDacMax;
   uint            calDacStep;
   uint            calChanMin;
   uint            calChanMax;
   uint            calTotal;
   uint            calChan;
   uint            calDac;
   bool            gotEvent;
   stringstream    oldConfig;
   oldConfig.str("");

   // Setup run status and init clock
   lastData    = commLink_->dataRxCount();
   runTotal    = 0;
   swRunning_  = true;
   swRunError_ = "";
   clock_gettime(CLOCK_REALTIME,&tme);
   ltime = (tme.tv_sec * 1000000) + (tme.tv_nsec/1000);

   // Show start
   if ( debug_ ) {
      cout << "KpixControl::runThread -> Name: " << name_ 
           << ", Run Started"
           << ", RunState=" << dec << variables_["RunState"]->get()
           << ", RunCount=" << dec << swRunCount_
           << ", RunPeriod=" << dec << swRunPeriod_ << endl;
   }

   try {

      // Enable run counter register
      device("kpixFpga",0)->set("RunEnable","True");
      writeConfig(false);

      // Calibration run enabled
      if ( variables_["RunState"]->get() == "Running Calibration" ) {
         calMeanCount = variables_["CalMeanCount"]->getInt();
         calDacMin    = variables_["CalDacMin"]->getInt();
         calDacMax    = variables_["CalDacMax"]->getInt();
         calDacStep   = variables_["CalDacStep"]->getInt();
         calChanMin   = variables_["CalChanMin"]->getInt();
         calChanMax   = variables_["CalChanMax"]->getInt();
         calTotal     = calMeanCount + ((calChanMax - calChanMin + 1) * ((calDacMax - calDacMin + 1)/calDacStep));
         calChan      = calChanMin;
         calDac       = calDacMin;

         // Save old configuration
         oldConfig << "<system>" << endl << configString(true) << "</system>" << endl;

         // Update variables
         variables_["CalState"]->set("Baseline");
         variables_["CalChannel"]->setInt(0);
         variables_["CalDac"]->setInt(0);

         // Update config
         calibConfig(9999,calDac);
      }
      else variables_["CalState"]->set("Idle");

      // Run
      while ( swRunEnable_ ) {

         // Delay between attempts
         do {
            usleep(1);
            clock_gettime(CLOCK_REALTIME,&tme);
            ctime = (tme.tv_sec * 1000000) + (tme.tv_nsec/1000);
         } while ( (ctime-ltime) < swRunPeriod_);

         // Check that we received a data frame
         gotEvent = true;
         while ( commLink_->dataRxCount() == lastData ) {
            usleep(1);
            clock_gettime(CLOCK_REALTIME,&tme);
            ctime = (tme.tv_sec * 1000000) + (tme.tv_nsec/1000);

            // One second has passed. event was missed.
            if ( (ctime-ltime) > 1000000) {
               gotEvent = false;
               if ( debug_ ) cout << "KpixControl::runThread -> Missed data event. Retrying" << endl;

               // Verify and re-configure here

               break;
            }
            if ( !swRunEnable_ ) break;
         }
         if ( !swRunEnable_ ) break;

         // Setup next calibration data point
         if ( variables_["RunState"]->get() == "Running Calibration" ) {
            if ( gotEvent ) runTotal++;
            variables_["RunProgress"]->setInt((uint)(((double)runTotal/(double)calTotal)*100.0));

            // running baseline
            if ( gotEvent && variables_["CalState"]->get() == "Baseline" ) {

               // Mean run is done
               if ( runTotal >= calMeanCount ) {
                  usleep(100000);
                  variables_["CalState"]->set("Inject");
                  calChan = calChanMin;
                  calDac  = calDacMin;
                  variables_["CalChannel"]->setInt(calChan);
                  variables_["CalDac"]->setInt(calDac);
                  calibConfig(calChan,calDac);
               }
            }

            // running calibration
            else if ( gotEvent && variables_["CalState"]->get() == "Inject" ) {

               // Increment cal dac
               calDac += calDacStep;
               if ( calDac > calDacMax ) {
                  usleep(100000);
                  calDac = calDacMin;
                  calChan++;
               }

               // Are we done?
               if ( calChan > calChanMax ) break;

               // Write config
               variables_["CalChannel"]->setInt(calChan);
               variables_["CalDac"]->setInt(calDac);
               calibConfig(calChan,calDac);
            }
         }
         else {
            if ( gotEvent ) runTotal++;
            variables_["RunProgress"]->setInt((uint)(((double)runTotal/(double)swRunCount_)*100.0));
            if ( runTotal >= swRunCount_ ) break;
         }

         // Execute command
         lastData = commLink_->dataRxCount();
         ltime = ctime;
         commLink_->queueRunCommand();
      }

      // Restore configuration here
      if ( variables_["RunState"]->get() == "Running Calibration" ) {
         variables_["CalState"]->set("Idle");
         variables_["CalChannel"]->setInt(0);
         parseXml(oldConfig.str(),false);
         usleep(100);
      }

      // Set run
      usleep(100);
      device("kpixFpga",0)->set("RunEnable","False");
      writeConfig(false);

   } catch (string error) { swRunError_ = error; }

   // Cleanup
   sleep(1);
   variables_["RunState"]->set(swRunRetState_);
   swRunning_ = false;
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
   uint         toCount;

   // Stopped state is requested
   if ( state == "Stopped" ) swRunEnable_ = false;

   // Running state is requested
   else if ( !swRunning_ && ( state == "Running Without Internal Trig/Cal" ||
                              state == "Running With Internal Trig/Cal"    ||
                              state == "Running Calibration" ) ) {
      swRunRetState_ = "Stopped";
      swRunEnable_   = true;
      variables_["RunState"]->set(state);

      // Determine run command 
      if ( state == "Running Without Internal Trig/Cal" )
         device("kpixFpga",0)->setRunCommand("RunAcquire");
      else 
         device("kpixFpga",0)->setRunCommand("RunCalibrate");

      // Setup run parameters
      swRunCount_ = getInt("RunCount");
      if      ( get("RunRate") == "50Hz") swRunPeriod_ =   20000;
      else if ( get("RunRate") == "40Hz") swRunPeriod_ =   25000;
      else if ( get("RunRate") == "30Hz") swRunPeriod_ =   33333;
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

      // Wait for thread to start
      toCount = 0;
      while ( !swRunning_ ) {
         usleep(100);
         toCount++;
         if ( toCount > 1000 ) {
            swRunEnable_ = false;
            err << "KpixControl::startRun -> Timeout waiting for runthread" << endl;
            if ( debug_ ) cout << err.str();
            variables_["RunState"]->set(swRunRetState_);
            throw(err.str());
         }
      }
   }
}

//! Method to return state string
string KpixControl::localState ( ) {
   string loc = "";

   loc = "System Ready To Take Data.\n";

   if ( variables_["RunState"]->get() == "Running Calibration" ) {
      loc.append("Calibration running: ");
      loc.append(variables_["CalState"]->get());
      if ( variables_["CalState"]->get() == "Inject" ) {
         loc.append(" Channel: ");
         loc.append(variables_["CalChannel"]->get());
      }
      loc.append("\n");
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

