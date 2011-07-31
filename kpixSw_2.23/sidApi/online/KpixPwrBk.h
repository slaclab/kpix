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
#ifndef __KPIX_PWR_BK_H__
#define __KPIX_PWR_BK_H__

#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include <unistd.h>
using namespace std;

// PGP Front End Class
class KpixPwrBk {

      // Serial port
      string serialPort;

      // Open socket
      int    sockFd;

   public:

      // Constructor
      KpixPwrBk ( );

      // Deconstructor
      ~KpixPwrBk ( );

      // Open the connection
      int open(string serial);

      // Close the connection
      void close();

      // Initialize supply
      void init();

      // Set output state
      void setOutput(bool enable);

      // Set output voltate
      void setVolt(unsigned int voltage);

      // Get output state
      bool getOutput();

      // Get output voltate
      float getVolt();

      // Read the current
      float getCurrent();
};

#endif
