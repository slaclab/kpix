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
// Copyright (c) 2006 by SLAC. All rights reserved.
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
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <lockdev.h>
#include <sys/ioctl.h>
#include <termio.h>
#include "../ftdi/ftd2xx.h"
#include "SidLink.h"
using namespace std;

// Serial class constructor. This constructore
// does nothing but create the base object. Serial
// link must be opened.
SidLink::SidLink () {

   // Init device value
   serDevice = "";
   serFd     = -1;
   serFdRd   = -1;
   usbDevice = -1;
   usbHandle = NULL;
   enDebug   = false;
   timeoutEn = true;
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
   int           lock;
   struct termio svbuf;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 ) 
      throw string("SidLink::linkOpen -> SID Link Already Open");

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open VCP USB device " << device << "\n";

   // Attempt to lock device
   if ( (lock = dev_lock(device.c_str())) != 0 ) {
      error << "SidLink::linkOpen -> VCP USB device " << device << " is locked by Pid=" << lock;
      throw error.str();
   }

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
}


// Open link to KPIX, direct driver version
// Pass device ID for direct drivers
// Throws exception on device open failure
void SidLink::linkOpen ( int device ) {

   // Status variable
   FT_STATUS    ftStatus;
   stringstream error;
   FT_HANDLE    tmpHandle;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 ) 
      throw string("SidLink::linkOpen -> KPIX Link Already Open");

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open direct USB device " << device << "\n";

   // Attempt to open the USB interface
   if((ftStatus = FT_Open(device, &tmpHandle)) != FT_OK) {
      error << "SidLink::linkOpen -> Error opening direct USB device " << device 
         << ", status=" << ftStatus;
      usbDevice = -1;
      throw error.str();
   }
   usbHandle = (void *)tmpHandle;

   // Set read and write timeouts
   if((ftStatus = FT_SetTimeouts((FT_HANDLE)usbHandle, (SID_IO_TIMEOUT*10), (SID_IO_TIMEOUT*10))) != FT_OK) {
      error << "SidLink::linkOpen -> Error setting direct USB timeout"
         << ", status=" << ftStatus;
      FT_Close((FT_HANDLE)usbHandle);
      usbDevice = -1;
      throw error.str();
   }

   if ( enDebug ) cout << "SidLink::linkOpen -> Opened direct USB device " << device << "\n";

   // Copy variables
   usbDevice = device;
}


// Open link to SID Devices, Simulation Version
// Pass path to named pipes (read & write directions) for simulation
// Throws exception on device open failure
void SidLink::linkOpen ( string rdPipe, string wrPipe ) {

   stringstream error;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 ) 
      throw string("SidLink::linkOpen -> SID Link Already Open");

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open simulation write link " << wrPipe << "\n";

   // Attempt to open named pipe
   if ((serFd=open(wrPipe.c_str(), O_WRONLY )) < 0) {
      error << "SidLink::linkOpen -> Error opening simulation write link" << wrPipe;
      throw error.str();
   }

   // Debug
   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Opened simulation write link " << wrPipe << ".\n";

   // Set pipe variable
   serDevice = wrPipe;

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open simulation read link " << rdPipe << "\n";

   // Attempt to open named pipe
   if ((serFdRd=open(rdPipe.c_str(), O_RDONLY)) < 0) {
      error << "SidLink::linkOpen -> Error opening simulation read link" << rdPipe;
      throw error.str();
   }

   // Debug
   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Opened simulation read link " << rdPipe << ".\n";

   // Disable timeout
   timeoutEn = false;
}


// Flush any pending data from the link.
// Returns number of bytes flushed
int SidLink::linkFlush ( ) {

   FT_STATUS     ftStatus;
   int           count = 0;
   unsigned long rcount = 0;
   int           total = 0;
   int           fdes;
   unsigned char buffer[100];
   stringstream  error;

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Flushing Link.\n";

   // Determine link for read, sim uses a seperate file descriptor
   if ( serFdRd > 0 ) fdes = serFdRd;
   else fdes = serFd;

   // Serial device is open
   if ( fdes >= 0 ) {

      // Flush any residual data
      while ( (count = read(fdes,buffer,100)) > 0 ) {
         total += count;
         usleep(100);
      }
   }

   // USB device is open
   if ( usbDevice >= 0 ) {

      // Read until we get 0 data returned
      do { 

         // Read from usb device
         if((ftStatus = FT_Read((FT_HANDLE)usbHandle, buffer, 100, &rcount)) != FT_OK) {
            error << "SidLink::linkRawRead -> Error reading from direct USB device ";
            error << usbDevice << ", status=" << ftStatus;
            throw error.str();
         }
         total += rcount;
      } while (rcount > 0);
   }

   // Debug
   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Flushed " << total << " bytes\n";
   return(total);
}


// Method to close the link
// Throws exception on device close failure
void SidLink::linkClose () {

   FT_STATUS ftStatus;
   stringstream error;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkClose -> Link Not Open");

   if ( enDebug ) 
      cout << "SidLink::linkClose -> Attempting to close USB device\n";

   // Serial device is open
   if ( serFd >= 0 ) {

      // Attempt to unlock device
      if ( dev_unlock(serDevice.c_str(),0) != 0 ) {
         error << "SidLink::linkOpen -> Error unlocking VCP USB device " << serDevice << ".";
         throw error.str();
      }

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

   // Special simulation read fdes is open
   if ( serFdRd >= 0 ) {

      // Attempt to close
      if ( close(serFdRd) != 0 ) {
         error << "sidLink::linkClose -> Could not close simulation RD device ";
         throw error.str();
         serFd     = -1;
         serDevice = "";
      }
      serFdRd   = -1;
   }

   // USB device is open
   if ( usbDevice >= 0 ) {

      // Attempt to close the USB interface
      if((ftStatus = FT_Close((FT_HANDLE)usbHandle)) != FT_OK) {
         usbDevice = -1;
         usbHandle = NULL;
         error << "SidLink::linkClose -> Could not close direct USB device " << usbDevice 
            << ", status=" << ftStatus;
         throw error.str();
      }
      usbDevice = -1;
      usbHandle = NULL;
   }
}


// Method to write a single byte to the interface. Used for debug purposes
int SidLink::linkByteWrite ( unsigned char data ) {

   unsigned long wcount;
   FT_STATUS     ftStatus;
   stringstream  error;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkByteWrite -> KPIX Link Not Open");

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkByteWrite -> Writing data to USB:";
      cout << " 0x" << setw(2) << setfill('0') << hex << (int)data;
      cout << "\n";
   }

   // Serial device is open
   if ( serFd >= 0 ) return(write(serFd, &data, 1));

   // USB device is open
   if ( usbDevice >= 0 ) {

      // Attempt to write to direct usb device
      if((ftStatus = FT_Write((FT_HANDLE)usbHandle, &data, 1, &wcount)) != FT_OK) {
         error << "SidLink::linkByteWrite -> Error writing to direct USB device " << usbDevice 
            << ", status=" << ftStatus;
         throw error.str();
      }
      return(wcount);
   }
   return(0);
}


// Method to write a word array to a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkRawWrite (unsigned short *data, short int size, unsigned char type, bool sof){

   unsigned char *byteData;
   unsigned int  i,y;
   int           wcount;
   FT_STATUS     ftStatus;
   stringstream  error;
   int           toCount = 0;
   unsigned long wtotal = 0;
   unsigned long newSize;

   // Calc size
   newSize = size * 3;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkRawWrite -> KPIX Link Not Open");

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

      // Iterate until all data has been written
      while ( wtotal < newSize ) {

         // Attempt write
         wcount = write(serFd, &(byteData[wtotal]), (newSize-wtotal));

         // Write returns -1 if no data is waiting
         if ( wcount != -1 ) wtotal += wcount;
         if ( wtotal < newSize ) { 
            toCount++;
            if ( toCount > SID_IO_TIMEOUT && timeoutEn ) {
               free(byteData);
               throw string("SidLink::linkRawWrite -> Write Timeout");
            }
            usleep(10);
         }
      }
   }

   // USB device is open
   if ( usbDevice >= 0 ) {

      // Attempt to write to direct usb device
      if((ftStatus = FT_Write((FT_HANDLE)usbHandle, byteData, newSize, &wtotal)) != FT_OK) {
         error << "SidLink::linkRawWrite -> Error writing to direct USB device " << usbDevice 
            << ", status=" << ftStatus;
         free(byteData);
         throw error.str();
      }

      // Detect timeout
      if ( wtotal != newSize ) { 
         free(byteData);
         throw string("SidLink::linkRawWrite -> Write Timeout");
      }
      wcount = wtotal;
   }

   free(byteData);
   if ( enDebug ) cout << "SidLink::linkRawWrite -> Write Done!\n";
   return(wcount);
}


// Method to read a word array from a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkRawRead ( unsigned short *data, short int size, unsigned char type, bool sof){

   unsigned char  *byteData;
   int            newSize;
   int            rcount;
   FT_STATUS      ftStatus;
   stringstream   error;
   unsigned int   i;
   int            wordPos = 0;
   unsigned long  rtotal  = 0;
   int            toCount = 0;
   int            fdes;
   unsigned short word;
   unsigned char  wordType;
   bool           wordSof;
   unsigned int   remainder;
   int            dropCount = 0;

   // Debug
   if ( enDebug ) cout << "SidLink::linkRawRead -> Reading!\n";

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 ) 
      throw string("SidLink::linkRawRead -> KPIX Link Not Open");

   // First create byte array to contain byte
   newSize = size * 3;
   byteData = (unsigned char *) malloc(newSize);
   if (byteData == NULL ) throw(string("SidLink::linkRawRead -> Malloc Error"));

   // Determine link for read, sim uses a seperate file descriptor
   if ( serFdRd > 0 ) fdes = serFdRd;
   else fdes = serFd;

   // Loop while we still need data
   remainder = newSize;
   while ( remainder > 0 ) {

      // Total read
      rtotal = 0;

      // Serial device is open
      if ( fdes >= 0 ) {

         // Read until we get amount of data we want
         while ( rtotal < remainder ) {

            // Attempt to read from device
            rcount = read(fdes, &(byteData[rtotal]), (remainder-rtotal));

            // Read returns -1 if no data is waiting
            if ( rcount != -1 ) rtotal += rcount;
            if ( rtotal < remainder ) { 
               toCount++;
               if ( toCount > SID_IO_TIMEOUT && timeoutEn ) {
                  free(byteData);
                  error << "SidLink::linkRawRead -> Read Timeout. Dropped ";
                  error << dropCount << " Bytes.";
                  throw error.str();
               }
               usleep(10);
            }
         }
      }

      // USB device is open
      if ( usbDevice >= 0 ) {

         // Read from usb device
         if((ftStatus = FT_Read((FT_HANDLE)usbHandle, byteData, remainder, &rtotal)) != FT_OK) {
            error << "SidLink::linkRawRead -> Error reading from direct USB device ";
            error << usbDevice << ", status=" << ftStatus;
            free(byteData);
            throw error.str();
         }
         if ( rtotal != remainder ) {
            free(byteData);
            error << "SidLink::linkRawRead -> Read Timeout. Dropped ";
            error << dropCount << " Bytes.";
            throw error.str();
         }
      }

      // Debug if enabled
      if ( enDebug ) {
         cout << "SidLink::linkRawRead -> Read data from USB:";
         for (i=0; i< rtotal; i++) 
            cout << " 0x" << setw(2) << setfill('0') << hex << (int)byteData[i];
         cout << "\n";
      }
      
      // Process each byte of read data
      i = 0;
      while ( i < rtotal ) {

         // Find three byte packet
         word     = 0;
         wordType = 0;
         wordSof  = false;

         // First Char
         if ( (byteData[i] & 0x80) == 0 ) { 
            dropCount += 1;
            i++; 
            continue; 
         }
         word     = byteData[i] & 0x0F;
         wordType = (byteData[i] >> 4) & 0x03;
         wordSof  = ((byteData[i] & 0x40) != 0);
         i++;

         // Second char
         if ( (byteData[i] & 0xC0) != 0 ) { i++; dropCount+=2; continue; }
         word |= (byteData[i] << 4) & 0x3F0;
         i++;

         // Third char 
         if ( (byteData[i] & 0xC0) != 0x40 ) { i++; dropCount+=3; continue; }
         word |= (byteData[i] << 10) & 0xFC00;
         i++;

         // Looking for SOF and SOF is missing
         if ( wordPos == 0 && sof && !wordSof ) { dropCount +=3; continue; }

         // Make sure type matches
         if ( wordType != type ) { dropCount +=3; continue; }

         // If we go here then data is valid
         data[wordPos] = word;
         wordPos++;
         remainder -= 3;
      }
   }


   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawRead -> Read data from USB:";
      cout << " Sof=" << sof << ", Type=" << (int)type << ":";
      for (i=0; i< (unsigned int)size; i++) 
         cout << " 0x" << setw(4) << setfill('0') << hex << (int)data[i];
      cout << "\n";
   }
   free(byteData);
   return(wordPos);
}



// Method to write a word array to a KPIX device
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkKpixWrite ( unsigned short int *data, short int size) {

  // Sim Mode, all bytes are echoed
  if ( serFdRd > 0 ) {
     linkRawWrite (data, size, 0, true);
     return(linkRawRead  (data, size, 0, true));
  }

  // Normal Mode
  else return(linkRawWrite (data, size, 0, true));
}


// Method to read a word array from a KPIX device
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkKpixRead ( unsigned short int *data, short int size ) {
  return(linkRawRead (data, size, 0, true));
}


// Method to read a word array from a KPIX device, sample data
// Pass word (16-bit) array, length and first read flag
// Return number of words read
int SidLink::linkDataRead ( unsigned short int *data, short int size, bool first ) {
  return(linkRawRead (data, size, 1, first));
}


// Method to write a word array to the FPGA device
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkFpgaWrite ( unsigned short int *data, short int size) {

  // Sim Mode, all bytes are echoed
  if ( serFdRd > 0 ) {
     linkRawWrite (data, size, 2, true);
     return(linkRawRead  (data, size, 2, true));
  }

  // Normal Mode
  else return(linkRawWrite (data, size, 2, true));
}


// Method to read a word array from the FPGA device
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkFpgaRead ( unsigned short int *data, short int size ) {
  return(linkRawRead (data, size, 2, true));
}


// Turn on or off debugging for the class
void SidLink::linkDebug ( bool debug ) { enDebug = debug; }

