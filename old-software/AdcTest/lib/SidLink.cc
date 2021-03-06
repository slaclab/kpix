//-----------------------------------------------------------------------------
// File          : SidLink.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Class to handle IO operations to and from the SID electronics device.  
// This module supports both direct USB drivers and VCP drivers.
// Link to the KPIX low level simulation is also supported.
// stty notes:
//    Noticed freeze up in some cases. It seemed the flag ignbrk was set on the
//    interface and was causing problems. running stty --file=/dev/ttyUSB0 -ignbrk
//    seemed to fix the problem.
//    known working stty settings:
//    stty --file=/dev/ttyUSB0 raw
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 11/09/2006: Added 0x before every hex value printed.
// 11/10/2006: Added support for link to  KPIX simulation.
// 04/27/2007: Modified for new communication protocol and add of fpga registers
// 04/30/2007: Modified to throw strings instead of const char *
// 07/31/2007: Fixed bug which was keeping direct mode USB device 0 from working
// 08/03/2007: Removed reset and purge from direct link open, added direct
//             mode access to flush, added read/write timeout to direct mode
// 01/10/2007: Added IOCTL call to set proper parameters to usb VCP interface.
// 03/09/2009: Added echo read for simulation mode.
// 06/18/2009: Changed read and write functions to save CPU cycles.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <termio.h>
#include <malloc.h>
#include <stdlib.h>
#include "SidLink.h"
using namespace std;

// Serial class constructor. This constructore
// does nothing but create the base object. Serial
// link must be opened.
SidLink::SidLink () {

   // Init device value
   serDevice = "";
   serFd     = -1;
   usbDevice = -1;
   enDebug   = false;
   timeoutEn = true;
   maxRxSize = 0;
}


// Deconstructor
SidLink::~SidLink ( ) { 
   if ( serFd >= 0 || usbDevice >= 0 ) linkClose(); 
}


// Open link to SID devices, VCP driver version
// Pass path to serial device for VCP driver
// Throws exception on device open failure
void SidLink::linkOpen ( string device ) {

   stringstream  error;
   struct termio svbuf;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 ) 
      throw string("SidLink::linkOpen -> SID Link Already Open");

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open VCP USB device " << device << "\n";

   // Attempt to open serial port
   if ((serFd=open(device.c_str(), O_RDWR|O_NOCTTY|O_NONBLOCK)) < 0) {
      error << "SidLink::linkOpen -> Error opening VCP USB device " << device;
      throw error.str();
   }

   // Setup serial port
   ioctl(serFd,TCGETA,&svbuf);
   svbuf.c_iflag = 0;
   svbuf.c_oflag = 0;
   svbuf.c_lflag = 0;
   svbuf.c_cflag = B38400 | CS8 | CLOCAL | CREAD;
   ioctl(serFd,TCSETA,&svbuf);

   // Debug
   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Opened VCP USB device " << device << ".\n";

   // Set device variable
   serDevice = device;
   maxRxSize = 0;
}


// Flush any pending data from the link.
// Returns number of bytes flushed
int SidLink::linkFlush ( ) {

   int           count = 0;
   unsigned long rcount = 0;
   int           total = 0;
   int           fdes;
   unsigned char buffer[1000];
   stringstream  error;

   if ( enDebug ) cout << "SidLink::linkOpen -> Flushing Link.\n";

   // Determine link for read, sim uses a seperate file descriptor
   fdes = serFd;

   // Read until we get 0 data returned
   do { 
      rcount = 0;
      usleep(100);

      // Serial device is open
      if ( fdes >= 0 ) {

         // Flush any residual data
         count = read(fdes,buffer,1000);
         if ( count > 0 ) {
            rcount = count;
            total += count;
         }
      }

   } while (rcount > 0);
   maxRxSize = 0;

   // Debug
   if ( enDebug ) cout << "SidLink::linkFlush -> Flushed " << total << " bytes\n";
   return(total);
}


// Method to close the link
// Throws exception on device close failure
void SidLink::linkClose () {

   stringstream error;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkClose -> Link Not Open");

   if ( enDebug ) 
      cout << "SidLink::linkClose -> Attempting to close USB device\n";

   // Serial device is open
   if ( serFd >= 0 ) {

      // Attempt to close
      if ( close(serFd) != 0 ) {
         error << "sidLink::linkClose -> Could not close VCP USB device " << serDevice;
         throw error.str();
         serFd     = -1;
         serDevice = "";
      }
      serFd     = -1;
      serDevice = "";
   }
}


// Method to write a word array to a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkRawWrite (unsigned short *data, short int size, unsigned char type, bool sof){

   unsigned char *byteData;
   unsigned int  i,y;
   stringstream  error;
   int           ret;
   unsigned long wtotal;
   unsigned long newSize;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkRawWrite -> KPIX Link Not Open");

   // Calc size
   newSize = size * 3;

   // First create byte array to contain converted data
   byteData = (unsigned char *) malloc(newSize);
   if (byteData == NULL ) throw(string("SidLink::linkRawWrite -> Malloc Error"));

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawWrite -> Writing data to USB:";
      cout << " Sof=" << sof << ", Type=" << (int)type << ":";
      for (i=0; i< (unsigned short int) size; i++) 
         cout << " 0x" << setw(4) << setfill('0') << hex << (int)data[i];
      cout << "\n";
   }

   // Convert each word into a three byte string
   y=0;
   for (i=0; i < (unsigned short int)size; i++) {

      // Byte 0
      byteData[y] = 0x80;
      if ( sof && i == 0 ) byteData[y] |= 0x40;
      byteData[y] |= ((type << 4) & 0x30);
      byteData[y] |= (data[i] & 0x0F);
      y++;

      // Byte 1
      byteData[y] = 0x00;
      byteData[y] |= ((data[i] >> 4 ) & 0x3F);
      y++;

      // Byte 2
      byteData[y] = 0x40;
      byteData[y] |= ((data[i] >> 10 ) & 0x3F);
      y++;
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawWrite -> Writing data to USB:";
      for (i=0; i< newSize; i++) 
         cout << " 0x" << setw(2) << setfill('0') << hex << (int)byteData[i];
      cout << "\n";
   }

   // Serial device is open
   if ( serFd >= 0 ) {
      ret = write(serFd, byteData, newSize);
      if ( ret > 0 ) wtotal = ret;
   }

   free(byteData);

   // Check size
   if ( wtotal != newSize ) throw string("SidLink::linkRawWrite -> Write Size Error");

   if ( enDebug ) cout << "SidLink::linkRawWrite -> Write Done!\n";
   return(size);
}


// Method to read a word array from a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkRawRead ( unsigned short *data, short int size, unsigned char type, bool sof){

   unsigned char  *byteData;
   unsigned long  newSize;
   unsigned long  rcount;
   unsigned long  rxBytes;
   int            ret;
   stringstream   error;
   unsigned int   i;
   unsigned long  rtotal;
   unsigned int   toCount;
   int            fdes;
   unsigned int   wordCnt;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) throw string("SidLink::linkRawRead -> KPIX Link Not Open");

   // First create byte array to contain byte
   newSize = size * 3;
   byteData = (unsigned char *) malloc(newSize);
   if (byteData == NULL ) throw(string("SidLink::linkRawRead -> Malloc Error"));

   // Determine link for read, sim uses a seperate file descriptor
   fdes = serFd;

   // Debug
   if ( enDebug ) cout << "SidLink::linkRawRead -> Reading!\n";

   // Read until we get amount of data we want
   rtotal  = 0;
   toCount = 0;
   while ( rtotal < newSize ) {

      // Serial device is open
      if ( fdes >= 0 ) {

         // Attempt to read from device
         ret = read(fdes, &(byteData[rtotal]), (newSize-rtotal));

         // Read returns -1 if no data is waiting
         if ( ret != -1 ) rcount = ret;
         else rcount = 0;

      }

      // Update total 
      if ( rcount != 0 ) {
         rtotal += rcount;
         toCount = 0;
      }

      // Check for timeout
      else if ( timeoutEn ) {
         toCount++;
         if ( toCount >= Timeout ) {
            free(byteData);

            // Flush the link
            ret = linkFlush();
            error << "SidLink::linkRawRead -> Read Timeout. Read ";
            error << dec << rtotal << " Bytes. Max Buffer=" << dec << maxRxSize;
            error << ", Flush=" << dec << ret;
            error << ", Size=" << dec << size;
            error << ", RxBytes=" << dec << rxBytes;
            throw error.str();
         }
         usleep(1000);
      }      

      // Wait longer for simulation, 10mS
      else usleep(10000);
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawRead -> Read data from USB:";
      for (i=0; i< rtotal; i++) 
         cout << " 0x" << setw(2) << setfill('0') << hex << (int)byteData[i];
      cout << "\n";
   }
      
   // Process each byte of read data
   wordCnt = 0;
   for (i=0; i < rtotal; i+=3) {

      // Check aligment
      if ( (byteData[i] & 0x80) == 0 || (byteData[i+1] & 0xC0) != 0 || (byteData[i+2] & 0xC0) != 0x40 ) {
         free(byteData);
         throw(string("SidLink::linkRawRead -> Alignment Error"));
      }

      // Check word type
      if ( ((byteData[i] >> 4) & 0x03) != type ) {
         free(byteData);
         throw(string("SidLink::linkRawRead -> Word Type Mimsatch"));
      }

      // Check SOF
      if ( i == 0 && (sof != ((byteData[i] & 0x40) != 0)) ) {
         free(byteData);
         throw(string("SidLink::linkRawRead -> SOF Mimsatch"));
      }

      // Extract Data
      data[wordCnt] = byteData[i] & 0x0F;
      data[wordCnt] |= (byteData[i+1] <<  4) & 0x03F0;
      data[wordCnt] |= (byteData[i+2] << 10) & 0xFC00;
      wordCnt++;
   }

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawRead -> Read data from USB:";
      cout << " Sof=" << sof << ", Type=" << (int)type << ", Size=" << size << ":";
      for (i=0; i< (unsigned int)size; i++) 
         cout << " 0x" << setw(4) << setfill('0') << hex << (int)data[i];
      cout << "\n";
   }
   free(byteData);
   return(wordCnt);
}


// Method to write a word array to the FPGA device
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkFpgaWrite ( unsigned short int *data, short int size) {

  // Normal Mode
  return(linkRawWrite (data, size, 2, true));
}


// Method to read a word array from the FPGA device
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkFpgaRead ( unsigned short int *data, short int size ) {
  return(linkRawRead (data, size, 2, true));
}


// Turn on or off debugging for the class
void SidLink::linkDebug ( bool debug ) { enDebug = debug; }

