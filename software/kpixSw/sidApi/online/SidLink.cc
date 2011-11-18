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
// 10/14/2010: Added UDP support.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <lockdev.h>
#include <sys/ioctl.h>
#include <termio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include "../ftdi/ftd2xx.h"
#include "SidLink.h"
using namespace std;


// Internal queue functions
bool SidLink::qpush ( unsigned short value, unsigned int type, bool sof, bool eof ) {
   unsigned int next;
   unsigned int word;

   word  = value;
   word += (type << 16) & 0x30000;
   if ( sof ) word += 0x40000;
   if ( eof ) word += 0x80000;

   next = (qwrite + 1) % qsize;
   if ( next != qread ) {
      qdata[qwrite] = word;
      qwrite = next;
      return true;
   } else return false;
}

bool SidLink::qpop  ( unsigned short *value, unsigned int *type, bool *sof, bool *eof ) {
   unsigned int next;
   unsigned int word;

   if ( qread == qwrite ) return false;
   next = (qread + 1) % qsize;
   word = qdata[qread];
   qread = next;

   *value = word & 0xFFFF;
   *type  = (word >> 16) & 0x3;
   *sof = (word & 0x40000) != 0;
   *eof = (word & 0x80000) != 0;
   return true;
}

bool SidLink::qready () {
   return(qread != qwrite);
}

void SidLink::qinit () {
   qread  = 0;
   qwrite = 0;
}

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
   maxRxSize = 0;
   udpHost   = "";
   udpPort   = 0;
   udpFd     = -1;
   udpAddr   = malloc(sizeof(struct sockaddr_in));
   qinit();
}


// Deconstructor
SidLink::~SidLink ( ) { 
   if ( serFd >= 0 || usbDevice >= 0 || udpFd >= 0 ) linkClose(); 
   free(udpAddr);
}


// Open link to SID devices, VCP driver version
// Pass path to serial device for VCP driver
// Throws exception on device open failure
void SidLink::linkOpen ( string device ) {

   stringstream  error;
   struct termio svbuf;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 || udpFd >= 0 ) 
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
   cout << "SidLink::linkOpen -> Opened VCP USB device " << device << ".\n";

   // Set device variable
   serDevice = device;
   maxRxSize = 0;
}


// Open link to SID devices, UDP Version
// Pass hostname and port of UDP host
// Throws exception on device open failure
void SidLink::linkOpen ( string host, int port ) {
   struct addrinfo*   aiList=0;
   struct addrinfo    aiHints;
   const sockaddr_in* addr;
   int                error;
   unsigned int       size;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 || udpFd >= 0 ) 
      throw string("SidLink::linkOpen -> SID Link Already Open");

   if ( enDebug ) 
      cout << "SidLink::linkOpen -> Attempting to open UDP device " << host << ":" << port << "\n";
 
   // Create socket
   udpFd = socket(AF_INET,SOCK_DGRAM,0);
   if ( udpFd == -1 ) throw string("SidLink::linkOpen -> Could Not Create Socket");

   // Lookup host address
   aiHints.ai_flags    = AI_CANONNAME;
   aiHints.ai_family   = AF_INET;
   aiHints.ai_socktype = SOCK_DGRAM;
   aiHints.ai_protocol = IPPROTO_UDP;
   error = ::getaddrinfo(host.c_str(), 0, &aiHints, &aiList);
   if (error || !aiList) throw string("SidLink::linkOpen -> Error Getting Resolving Hostname");
   addr = (const sockaddr_in*)(aiList->ai_addr);

   // Setup Remote Address
   memset(udpAddr,0,sizeof(struct sockaddr_in));
   ((sockaddr_in *)udpAddr)->sin_family=AF_INET;
   ((sockaddr_in *)udpAddr)->sin_addr.s_addr=addr->sin_addr.s_addr;
   ((sockaddr_in *)udpAddr)->sin_port=htons(port);

   // Set receive size
   size = 2000000;
   setsockopt(udpFd, SOL_SOCKET, SO_RCVBUF, (char*)&size, sizeof(size));

   // Debug
   cout << "SidLink::linkOpen -> Opened UDP device " << host << ":" << port << ". Fd=" << udpFd << "\n";

   // Set device variable
   udpHost = host;
   udpPort = port;
   maxRxSize = 0;
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
   if ( serFd >= 0 || usbDevice >= 0 || udpFd >= 0 ) 
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

   cout << "SidLink::linkOpen -> Opened direct USB device " << device << "\n";

   // Copy variables
   usbDevice = device;
   maxRxSize = 0;
}


// Open link to SID Devices, Simulation Version
// Pass path to named pipes (read & write directions) for simulation
// Throws exception on device open failure
void SidLink::linkOpen ( string rdPipe, string wrPipe ) {

   stringstream error;

   // Make sure no links are open
   if ( serFd >= 0 || usbDevice >= 0 || udpFd >= 0 ) 
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
   maxRxSize = 0;
}


// Flush any pending data from the link.
// Returns number of bytes flushed
int SidLink::linkFlush ( ) {
   FT_STATUS      ftStatus;
   int            count = 0;
   unsigned long  rcount = 0;
   int            total = 0;
   int            fdes;
   unsigned char  buffer[1000];
   stringstream   error;
   unsigned int   udpAddrLength;
   struct timeval timeout;
   fd_set         fds;
   int            ret;

   if ( enDebug ) cout << "SidLink::linkFlush -> Flushing Link.\n";

   // Determine link for read, sim uses a seperate file descriptor
   if ( serFdRd > 0 ) fdes = serFdRd;
   else fdes = serFd;

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

      // UDP device is open
      if ( udpFd >= 0 ) {
         do {
            timeout.tv_sec=0;
            timeout.tv_usec=1;
            FD_ZERO(&fds);
            FD_SET(udpFd,&fds);

            // Is data waiting?
            ret = select(udpFd+1,&fds,NULL,NULL,&timeout);
            if ( ret < 0 || FD_ISSET(udpFd,&fds) == 0 ) ret = 0;
            else {
               udpAddrLength = sizeof(struct sockaddr_in);
               ret = recvfrom(udpFd,buffer,1000,0,(struct sockaddr *)udpAddr,&udpAddrLength);
            }
            if ( ret > 0 ) {
               rcount = ret;
               total += ret;
            }
         } while ( ret > 0 );
         qinit();
      }

      // USB device is open
      if ( usbDevice >= 0 ) {
         if ((ftStatus = FT_Purge((FT_HANDLE)usbHandle,FT_PURGE_RX | FT_PURGE_TX)) != FT_OK ) {
            error << "SidLink::linkFlush -> Error purging device";
            error << usbDevice << ", status=" << ftStatus;
            throw error.str();
         }
      }
   } while (rcount > 0);
   maxRxSize = 0;

   // Debug
   cout << "SidLink::linkFlush -> Flushed " << dec << total << " bytes\n";
   return(total);
}

// Reset the device
void SidLink::linkReset ( ) {
   FT_STATUS      ftStatus;
   stringstream   error;

   // USB device is open
   if ( usbDevice >= 0 ) {
      if ((ftStatus = FT_ResetDevice((FT_HANDLE)usbHandle)) != FT_OK ) {
         error << "SidLink::linkFlush -> Error resetting device";
         error << usbDevice << ", status=" << ftStatus;
         throw error.str();
      }
   }
}

// Method to close the link
// Throws exception on device close failure
void SidLink::linkClose () {

   FT_STATUS ftStatus;
   stringstream error;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 && udpFd < 0 ) return;

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
         serFd     = -1;
         serDevice = "";
         throw error.str();
      }
      serFd     = -1;
      serDevice = "";
   }

   // UDP Device is open
   if ( udpFd >= 0 ) {
      if ( close(udpFd) != 0 ) {
         udpFd     = -1;
         throw("sidLink::linkClose -> Could not close UDP device ");
      }
      udpFd     = -1;
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


// Method to write a word array to a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkRawWrite (unsigned short *data, short int size, unsigned char type, bool sof){

   unsigned char *byteData;
   unsigned int  i,y;
   FT_STATUS     ftStatus;
   stringstream  error;
   int           ret;
   unsigned long wtotal;
   unsigned long newSize;

   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 && udpFd < 0 ) 
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

   // UDP Data
   // UDP device is open
   if ( udpFd >= 0 ) {

      byteData[0]  = (sof << 7) & 0x80;
      byteData[0] += (type << 4) & 0x30;
      byteData[0] += (size >> 8) & 0xF;
      byteData[1]  = (size+1) & 0xFF;
      if ( enDebug ) {
         cout << "Data: 0x" << hex << setw(2) << setfill('0') << (uint)byteData[0];
         cout << " 0x" << hex << setw(2) << setfill('0') << (uint)byteData[1];
      }

      y = 2;
      for (i=0; i < (unsigned short int)size; i++) {
         byteData[y] = (data[i] >> 8) & 0xFF;
         if ( enDebug ) cout << " 0x" << hex << setw(2) << setfill('0') << (uint)byteData[y];
         y++;
         byteData[y] = data[i] & 0xFF;
         if ( enDebug ) cout << " 0x" << hex << setw(2) << setfill('0') << (uint)byteData[y];
         y++;
      }
      if ( enDebug ) cout << endl;

      ret = sendto(udpFd,byteData,y,0,(struct sockaddr *)(udpAddr),sizeof(struct sockaddr_in));
      if ( ret > 0 ) wtotal = ret;
   }

   else {

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


      // USB device is open
      if ( usbDevice >= 0 ) {

         // Attempt to write to direct usb device
         if((ftStatus = FT_Write((FT_HANDLE)usbHandle, byteData, newSize, &wtotal)) != FT_OK) {
            error << "SidLink::linkRawWrite -> Error writing to direct USB device " << usbDevice 
               << ", status=" << ftStatus;
            free(byteData);
            throw error.str();
         }
      }

      // Check size
      //if ( wtotal != newSize ) throw string("SidLink::linkRawWrite -> Write Size Error");
   }
   free(byteData);

   if ( enDebug ) cout << "SidLink::linkRawWrite -> Write Done!\n";
   return(size);
}

// Method to read a word array from a KPIX device, raw interface
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkRawRead ( unsigned short *data, short int size, unsigned char type, bool sof, int *eof ){
   // Check if no links are open
   if ( serFd < 0 && usbDevice < 0 && udpFd < 0 ) throw string("SidLink::linkRawRead -> KPIX Link Not Open");

   // UDP device is open
   if ( udpFd >= 0 )
      return(linkRawReadUdp(data, size, type, sof, eof));
   else {
      *eof = -1;
      return(linkRawReadUsb(data, size, type, sof));
   }
}

// Method to read a word array from a KPIX device using UDP interface
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkRawReadUdp ( unsigned short *data, short int size, unsigned char type, bool sof, int *eof ){
   unsigned long  rcount;
   unsigned long  toCount;
   int            ret;
   stringstream   error;
   unsigned int   udpAddrLength;
   struct timeval timeout;
   fd_set         fds;
   unsigned char  qbuffer[8192];
   bool           rSof;
   bool           rEof;
   unsigned int   rType;
   unsigned short value;
   unsigned int   x;
   unsigned int   lcount;
   unsigned int   udpx;
   unsigned int   udpcnt;

   // Debug
   if ( enDebug ) cout << "SidLink::linkRawReadUdp -> Reading!\n";

   rcount = 0;
   toCount = 0;
   do {

      // First read any data waiting in UDP queue
      timeout.tv_sec=0;
      timeout.tv_usec=1;
      FD_ZERO(&fds);
      FD_SET(udpFd,&fds);

      // Is data waiting?
      if ( ! qready() ) {
         ret = select(udpFd+1,&fds,NULL,NULL,&timeout);
         if ( ret > 0 && FD_ISSET(udpFd,&fds) ) {
            udpAddrLength = sizeof(struct sockaddr_in);
            ret = recvfrom(udpFd,&qbuffer,8192,0,(struct sockaddr *)udpAddr,&udpAddrLength);
            if ( ret > 0 ) {
               udpx = 0;
               while ( udpx < (uint)ret ) {
                  rSof    = (qbuffer[udpx] >> 7) & 0x1;
                  rEof    = (qbuffer[udpx] >> 6) & 0x1;
                  rType   = (qbuffer[udpx] >> 4) & 0x3;
                  udpcnt  = (qbuffer[udpx] << 8) & 0xF00;
                  udpx++;
                  udpcnt += (qbuffer[udpx]     ) & 0xFF;
                  udpcnt -= 1;
                  udpx++;

                  if ( udpcnt > 4001 ) break;

                  for ( x=0; x < udpcnt; x++ ) {
                     value  = (qbuffer[udpx] << 8) & 0xFF00;
                     udpx++;
                     value += (qbuffer[udpx] & 0xFF);
                     udpx++;
                     qpush(value,rType,(rSof&&x==0),(rEof && x == (udpcnt-1)));
                  }
                  if ( enDebug ) {
                     cout << "SidLink::linkRawReadUdp -> Read " << dec << x << " words from UDP. ";
                     cout << "Type=" << dec << rType << ", SOF=" << dec << rSof << ", EOF=" << dec << rEof;
                     cout << ", Ret=" << dec << ret << endl;
                  }
               }
            }
         }
      }

      // Next pass queue data to user
      lcount = 0;
      while ( rcount < (uint)size && qready() ) {
         qpop(&value,&rType,&rSof,&rEof);
         *eof = rEof;
         data[rcount] = value;
         if ( rType != type ) {
            cout << "Expected Word Type : " << hex << (int)type << ", Got : " << (int)rType << endl;
            throw(string("SidLink::linkRawReadUdp -> Word Type Mimsatch"));
         }
         if ( rcount == 0 && sof != rSof ) {
            throw(string("SidLink::linkRawReadUdp -> SOF Mimsatch"));
         }
         toCount = 0;
         lcount++;
         rcount++;
      }
      if ( enDebug && lcount > 0 ) cout << "SidLink::linkRawReadUdp -> Read " << dec << lcount << " words from buffer\n";

      if ( timeoutEn && lcount == 0 ) {
         toCount++;
         if ( toCount >= Timeout ) {
            error << "SidLink::linkRawReadUdp -> Read Timeout. Read ";
            error << dec << rcount << " Bytes. Max Buffer=" << dec << maxRxSize;
            error << ", Flush=" << dec << linkFlush();
            error << ", Size=" << dec << size;
            if ( enDebug ) cout << error.str() << endl;
            throw error.str();
         }
         usleep(1000);
      }
   } while ( rcount < (uint)size );

   // Debug if enabled
   if ( enDebug ) {
      cout << "SidLink::linkRawReadUdp -> Read data from UDP:";
      cout << " Sof=" << sof << ", Eof=" << dec << *eof << ", Type=" << (int)type << ", Size=" << size << endl;
      cout << "Data:";
      for ( x=0; x < rcount && x < 10; x++ ) cout << " 0x" << hex << setfill('0') << setw(4) << data[x];
      cout << endl;
   }

   return(rcount);
}

// Method to read a word array from a KPIX device using USB interface
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkRawReadUsb ( unsigned short *data, short int size, unsigned char type, bool sof ){

   unsigned char  *byteData;
   unsigned long  newSize;
   unsigned long  rcount;
   unsigned long  rxBytes;
   unsigned long  txBytes;
   unsigned long  eventWord;
   int            ret;
   FT_STATUS      ftStatus;
   stringstream   error;
   unsigned int   i;
   unsigned long  rtotal;
   unsigned int   toCount;
   int            fdes;
   unsigned int   wordCnt;

   // First create byte array to contain byte
   newSize = size * 3;
   byteData = (unsigned char *) malloc(newSize);
   if (byteData == NULL ) throw(string("SidLink::linkRawRead -> Malloc Error"));

   // Determine link for read, sim uses a seperate file descriptor
   if ( serFdRd > 0 ) fdes = serFdRd;
   else fdes = serFd;

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

      // USB device is open
      rxBytes = 0;
      if ( usbDevice >= 0 ) {

         // How many bytes are ready
         if ((ftStatus = FT_GetStatus((FT_HANDLE)usbHandle,&rxBytes,&txBytes,&eventWord)) != FT_OK ) {
            error << "SidLink::linkRawRead -> Error getting status from direct USB device ";
            error << usbDevice << ", status=" << ftStatus;
            free(byteData);
            throw error.str();
         }

         // Data is ready
         if ( rxBytes >= newSize ) {
            if ( rxBytes > maxRxSize ) maxRxSize = rxBytes;

            // Read from usb device
            if((ftStatus = FT_Read((FT_HANDLE)usbHandle, byteData, newSize, &rcount)) != FT_OK) {
               error << "SidLink::linkRawRead -> Error reading from direct USB device ";
               error << usbDevice << ", status=" << ftStatus;
               free(byteData);
               throw error.str();
            }
         }
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
         linkFlush();
         throw(string("SidLink::linkRawRead -> Alignment Error"));
      }

      // Check word type
      if ( ((byteData[i] >> 4) & 0x03) != type ) {
         free(byteData);
         linkFlush();
         throw(string("SidLink::linkRawRead -> Word Type Mimsatch"));
      }

      // Check SOF
      if ( i == 0 && (sof != ((byteData[i] & 0x40) != 0)) ) {
         free(byteData);
         linkFlush();
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


// Method to write a word array to a KPIX device
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkKpixWrite ( unsigned short int *data, short int size) {

  // Sim Mode, all bytes are echoed
  if ( serFdRd > 0 ) {
     int eof;
     linkRawWrite (data, size, 0, true);
     return(linkRawRead  (data, size, 0, true, &eof));
  }

  // Normal Mode
  else return(linkRawWrite (data, size, 0, true));
}


// Method to read a word array from a KPIX device
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkKpixRead ( unsigned short int *data, short int size ) {
  int eof;
  return(linkRawRead (data, size, 0, true, &eof));
}


// Method to read a word array from a KPIX device, sample data
// Pass word (16-bit) array, length and first read flag
// Return number of words read
int SidLink::linkDataRead ( unsigned short int *data, short int size, bool first, int *last ) {
  return(linkRawRead (data, size, 1, first, last));
}


// Method to write a word array to the FPGA device
// Pass word (16-bit) array and length
// Return number of words written
int SidLink::linkFpgaWrite ( unsigned short int *data, short int size) {

  // Sim Mode, all bytes are echoed
  if ( serFdRd > 0 ) {
     int eof;
     linkRawWrite (data, size, 2, true);
     return(linkRawRead  (data, size, 2, true, &eof));
  }

  // Normal Mode
  else return(linkRawWrite (data, size, 2, true));
}


// Method to read a word array from the FPGA device
// Pass word (16-bit) array and length
// Return number of words read
int SidLink::linkFpgaRead ( unsigned short int *data, short int size ) {
  int eof;
  return(linkRawRead (data, size, 2, true, &eof));
}


// Turn on or off debugging for the class
void SidLink::linkDebug ( bool debug ) { enDebug = debug; }

