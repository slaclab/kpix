//-----------------------------------------------------------------------------
// File          : SidLink.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Class to handle IO operations to and from the SID electronics devices.
// This module supports both direct USB drivers and VCP drivers.
// For now this class is used to manage only the KPIX ASIC. In the future 
// this class will be used to manage the test FPGA and eventual concentrator 
// chips used to flow traffic between the ASIC and the data flow PC.
// Link to the KPIX low level simulation is also supported.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 11/10/2006: Added support for link to  KPIX simulation.
// 04/27/2007: Modified for new communication protocol and add of fpga registers
// 05/01/2007: Added flush command.
// 08/03/2007: Adjusted timeout value
// 06/18/2009: Removed link flush and byte write routines.
//-----------------------------------------------------------------------------
#ifndef __SID_LINK_H__
#define __SID_LINK_H__

#include <iostream>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <Rtypes.h>
using namespace std;


// Read & Write Timeouts in mS
#define SID_IO_TIMEOUT 100


// Link class for communicating to KPIX
class SidLink {

      // Values used for USB version 
      int   usbDevice;
      void *usbHandle;

      // Flag to control timeout
      bool timeoutEn;

      // Values used for serial version
      string serDevice;
      int    serFd;
      int    serFdRd;

      // Max count in buffer 
      unsigned int maxRxSize;

      // Debug flag
      bool enDebug;

   public:

      // Serial class constructor. This constructore
      // does nothing but create the base object. Serial
      // link must be opened before read/write access.
      SidLink ( );

      // Deconstructor, closes link if open
      virtual ~SidLink ( );

      // Open link to SID Devices, VCP driver version
      // Pass path to serial device for VCP driver, "/dev/ttyUSB0"
      // Throws exception on device open failure
      void linkOpen ( string device );

      // Open link to SID Devices, direct driver version
      // Pass device ID for direct drivers, 0,1,2 etc
      // Throws exception on device open failure
      // Do not use, not yet fully tested.
      void linkOpen ( int device );

      // Open link to SID Devices, Simulation Version
      // Pass path to named pipes (read & write directions) for simulation
      // Throws exception on device open failure
      void linkOpen ( string rdPipe, string wrPipe );

      // Flush any pending data from the link.
      // Returns number of bytes flushed
      int linkFlush ( );

      // Method to close the link
      void linkClose ();

      // Method to write a word array to a KPIX device, raw interface
      // Pass word (16-bit) array and length
      // Return number of words written
      int linkRawWrite ( unsigned short int *data, short int size, unsigned char type, bool sof);

      // Method to read a word array from a KPIX device, raw interface
      // Pass word (16-bit) array and length
      // Return number of words read
      int linkRawRead ( unsigned short int *data, short int size, unsigned char type, bool sof);

      // Method to write a word array to a KPIX device
      // Pass word (16-bit) array and length
      // Return number of words written
      int linkKpixWrite ( unsigned short int *data, short int size);

      // Method to read a word array from a KPIX device
      // Pass word (16-bit) array and length
      // Return number of words read
      int linkKpixRead ( unsigned short int *data, short int size );

      // Method to read a word array from a KPIX device, sample data
      // Pass word (16-bit) array, length and first read flag
      // Return number of words read
      int linkDataRead ( unsigned short int *data, short int size, bool first );

      // Method to write a word array to the FPGA device
      // Pass word (16-bit) array and length
      // Return number of words written
      int linkFpgaWrite ( unsigned short int *data, short int size);

      // Method to read a word array from the FPGA device
      // Pass word (16-bit) array and length
      // Return number of words read
      int linkFpgaRead ( unsigned short int *data, short int size );

      // Turn on or off debugging for the class
      void linkDebug ( bool debug );
      
};

#endif
