//-----------------------------------------------------------------------------
// File          : KpixPwrBk.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 09/21/2010
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// This class is for accessing the BK power supply.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 09/21/2010: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <netdb.h>
#include <sys/time.h>
#include "KpixPwrBk.h"
using namespace std;


// Constructor
KpixPwrBk::KpixPwrBk ( ) {
   sockFd     = -1;
   serialPort = "";
}


// Deconstructor
KpixPwrBk::~KpixPwrBk ( ) {
   close();
}


// Open the connection
int KpixPwrBk::open(string serial) {
   struct termios svbuf;

   if ( sockFd > 0 ) return(sockFd);

   serialPort = serial;

   // Attempt to open device
   sockFd = ::open(serial.c_str(),O_RDWR|O_NOCTTY|O_NONBLOCK);
   if ( sockFd < 0 ) {
      cout << "KpixPwrBk::open -> Could not open device " << serial << endl;
      return(-1);
   }

   // Setup port attributes
   tcgetattr(sockFd,&svbuf);
   cfmakeraw(&svbuf);
   cfsetispeed(&svbuf,B9600);
   cfsetospeed(&svbuf,B9600);
   tcsetattr(sockFd,TCSANOW,&svbuf);

   return(sockFd);
}


// Close the connection
void KpixPwrBk::close() {
   if ( sockFd > 0 ) {
      usleep(1000);
      ::close(sockFd);
      usleep(1000);
      cout << "BK Closed" << endl;
   }
   sockFd = -1;
}


// Initialize supply
void KpixPwrBk::init() {
   string command;
   char   rxBuffer[500];

   if ( sockFd > 0 ) {

      command = "SESS00\r";
      write(sockFd,command.c_str(),command.length());
      usleep(250000);
      read(sockFd,rxBuffer,500);

      command = "SOUT001\r";
      write(sockFd,command.c_str(),command.length());
      usleep(250000);
      read(sockFd,rxBuffer,500);

      command = "VOLT00065\r";
      write(sockFd,command.c_str(),command.length());
      usleep(250000);
      read(sockFd,rxBuffer,500);

      command = "CURR00500\r";
      write(sockFd,command.c_str(),command.length());
      usleep(250000);
      read(sockFd,rxBuffer,500);
   }
}


// Set output state
void KpixPwrBk::setOutput(bool enable) {
   string command;
   char   rxBuffer[500];

   if ( sockFd > 0 ) {

      if ( enable ) command = "SOUT000\r";
      else command = "SOUT001\r";
      write(sockFd,command.c_str(),command.length());
      usleep(250000);
      read(sockFd,rxBuffer,500);
   }
}


// Set output voltate
void KpixPwrBk::setVolt(unsigned int voltage) {
   stringstream command;
   char   rxBuffer[500];

   if ( sockFd > 0 ) {

      command.str("");
      command << "VOLT00" << dec << setw(3) << setfill('0') << (voltage*10) << "\r";
      write(sockFd,command.str().c_str(),command.str().length());
      usleep(250000);
      read(sockFd,rxBuffer,500);
   }
}


// Get output state
bool KpixPwrBk::getOutput() { return(false); }


// Get output voltate
float KpixPwrBk::getVolt() {
   string command;
   string resp;
   char   rxBuffer[500];
   float  voltage;

   if ( sockFd < 0 ) return(0);

   command = "GETD00\r";
   write(sockFd,command.c_str(),command.length());
   usleep(250000);
   if ( read(sockFd,rxBuffer,500) <= 0 ) return(0);
   resp = rxBuffer;
   voltage = (float)atoi(resp.substr(0,4).c_str())/100.0;

   return(voltage);
}


// Read the current
float KpixPwrBk::getCurrent() {
   string command;
   string resp;
   char   rxBuffer[500];
   float  current;

   if ( sockFd < 0 ) return(0);

   command = "GETD00\r";
   write(sockFd,command.c_str(),command.length());
   usleep(250000);
   if ( read(sockFd,rxBuffer,500) <= 0 ) return(0);
   resp = rxBuffer;

   current = (float)atoi(resp.substr(4,4).c_str())/1000.0;

   return(current);
}

