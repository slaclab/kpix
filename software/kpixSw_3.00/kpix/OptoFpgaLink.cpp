//-----------------------------------------------------------------------------
// File          : OptoFpgaLink.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/01/2011
// Project       : General Purpose
//-----------------------------------------------------------------------------
// Description :
// USB link for opto FPGA board
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/01/2011: created
//-----------------------------------------------------------------------------
#include <OptoFpgaLink.h>
#include <sstream>
#include "Register.h"
#include "Command.h"
#include "Data.h"
#include <fcntl.h>
#include <iostream>
#include <iomanip>
#include <string.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <termio.h>

using namespace std;

// Receive frame
int OptoFpgaLink::rxFrame ( ushort *frame, uint size, uint *type, uint *err ) {
   ulong         rcount;
   uint          rstate;
   ulong         toCount;
   int           ret;
   unsigned char qbuffer[size*3];
   int           x;

   toCount = 0;
   rcount  = 0;
   rstate  = 0;
   *err    = 0;
   while (1) {

      // Receive data
      ret = read(fd_,qbuffer,size*3);

      // No data, not in frame
      if ( ret <= 0 && rcount == 0 ) return(0);

      // Got data
      if ( ret > 0 ) {

         // Process each byte
         for (x=0; x < ret; x++) {
 
            // Three byte packets
            switch(rstate) {

               // Byte 0
               case 0:

                  // Misalignment, allow to re-align if no data has been received
                  if ( (qbuffer[x] & 0x80) == 0 ) {
                     if ( rcount != 0 ) {
                        *err = 1;
                        return(0);
                     }
                     // else process next byte
                  }

                  // SOF should match
                  else if ( rcount == 0 && (qbuffer[x] & 0x40 ) == 0 ) return(0);
                  else if ( rcount != 0 && (qbuffer[x] & 0x40 ) != 0 ) {
                     *err = 1;
                     return(0);
                  }

                  // First charactor
                  else {
                     frame[rcount] = (qbuffer[x] & 0x000F);    
                     rstate = 1;
                     if ( rcount == 0 ) *type = ((qbuffer[x] >> 4) & 0x3);
                  }
                  break;

               // Byte 1
               case 1:

                  // Misalignment
                  if ( (qbuffer[x] & 0xC0) != 0 ) {
                     *err = 1;
                     return(0);
                  }

                  // second charactor
                  else {
                     frame[rcount] |= ((qbuffer[x] << 4) & 0x03F0);
                     rstate = 2;
                  }
                  break;

               // Byte 3
               case 2:

                  // Misalignment
                  if ( (qbuffer[x] & 0xC0) != 0x40 ) {
                     *err = 1;
                     return(0);
                  }

                  // third charactor
                  else {
                     frame[rcount] |= ((qbuffer[x] << 10) & 0xFC00);
                     rcount++;
                     rstate = 0;

                     // KPIX registed or FPGA register done after 4 words
                     if ( (*type == 0) || (*type == 2) ) {
                        if ( rcount == 4 ) return(4);
                     }

                     // Data is done when last marker is set data frame consists of 2 header words
                     // followed by groups of 3 words. If the last word of the 3 has bit 15 set
                     // then the frame is done
                     else {
                        if ( (rcount > 2) && (((rcount - 3) % 3) == 2) && ((frame[rcount-3] & 0x8000) != 0) )
                           return(rcount);
                     }
                  }
                  break;

               default:
                  rstate = 0;
                  break;
            }
         }
      }
      else {
         toCount++;
         if ( toCount >= 1000 ) {
            *err = 1;
            return(0);
         }
         usleep(10);
      }
   }
   *err = 0;
   return(0);
}

// transmit frame
int OptoFpgaLink::txFrame ( ushort *frame, uint size, uint type ) {
   unsigned char qbuffer[size*3];
   uint          x;
   uint          y;

   // Convert each word into a three byte string
   y=0;
   for (x=0; x < size; x++) {

      // Byte 0
      qbuffer[y] = 0x80;
      if ( x == 0 ) qbuffer[y] |= 0x40; // SOF 
      qbuffer[y] |= ((type << 4) & 0x30);
      qbuffer[y] |= (frame[x] & 0x0F);
      y++;

      // Byte 1
      qbuffer[y] = 0x00;
      qbuffer[y] |= ((frame[x] >> 4 ) & 0x3F);
      y++;

      // Byte 2
      qbuffer[y] = 0x40;
      qbuffer[y] |= ((frame[x] >> 10 ) & 0x3F);
      y++;
   }

   // Write to USB
   write(fd_, qbuffer, y);
   return(size);
}

// IO Thread
void OptoFpgaLink::ioHandler() {
   ushort    cmdBuff[4];
   ushort    runBuff[4];
   uint      type;
   uint      err;
   int       rxRet;
   int       txRet;
   int       cmdRet;
   int       runRet;
   uint      lastReqCnt;
   uint      lastCmdCnt;
   uint      lastRunCnt;
   uint      txType;
   uint      cmdType;
   uint      runType;
   bool      txPend;
   Data      *rxData;
   uint      maskRx;
   uint      mask;
   uint      dataSize;
   ushort    *lrxBuff;
   ushort    *ltxBuff;
   uint      *rxBuff;
   uint      *txBuff;

   // Init buffer
   rxBuff = (uint *) malloc(sizeof(uint)*maxRxTx_);
   txBuff = (uint *) malloc(sizeof(uint)*maxRxTx_);

   // Point to buffers as ushorts
   lrxBuff = (ushort *)rxBuff;
   ltxBuff = (ushort *)txBuff;

   // While enabled
   lastReqCnt = regReqCnt_;
   lastCmdCnt = cmdReqCnt_;
   lastRunCnt = runReqCnt_;
   txPend     = false;
   while ( runEnable_ ) {

      // Setup and attempt receive
      rxRet = rxFrame(lrxBuff, maxRxTx_, &type, &err);

      // Data is ready and large enough to be a real packet
      if ( rxRet > 0 ) {

         // An error occured
         if ( rxRet < 4 || err ) {
            if ( debug_ ) 
               cout << "OptoFpgaLink::ioHandler -> Error in data receive. Rx=" << dec << rxRet << endl;
            errorCount_++;
         }

         // Frame was valid
         else {

            // Setup mask values
            maskRx = (0x1 << type);
            mask   = (dataSource_ & 0xF);

            // Check for data packet, adjust to 32-bit length
            if ( (maskRx & dataSource_) != 0 ) {
               if ( (rxRet % 2) != 0 ) dataSize = (rxRet + 1) / 2;
               else dataSize = rxRet / 2;
               rxData = new Data(rxBuff,dataSize);
               if ( ! dataQueue_.push(rxData) ) {
                  unexpCount_++;
                  delete rxData;
               }
            }

            // Data matches outstanding register request
            else if ( (rxRet == 4) && txPend && (type == ((regReqEntry_->address()>>24) & 0xF))) {
               if ( ! regReqWrite_ ) {
                  regReqEntry_->set(lrxBuff[1],0,0xFFFF);
                  regReqEntry_->set(lrxBuff[2],16,0xFFFF);
               }
               regReqEntry_->setStatus(0);
               txPend = false;
               regRespCnt_++;
            }

            // Unexpected frame
            else {
               unexpCount_++;
               if ( debug_ ) 
                  cout << "OptoFpgaLink::ioHandler -> Unuexpected frame received" << " Pend=" <<  txPend << endl;
            }
         }
      }
  
      // Register TX is pending
      if ( lastReqCnt != regReqCnt_ ) {

         // Extract lane
         txType = (regReqEntry_->address()>>24) & 0xF;

         // Setup tx buffer for kpix write
         if ( txType == 0 ) {
            ltxBuff[0]  = (regReqEntry_->address() & 0x007F);
            if ( regReqWrite_ ) ltxBuff[0] |= 0x0080; // Write
            ltxBuff[0] |= 0x0100; // Reg Access
            ltxBuff[0] |= (regReqEntry_->address() << 1) & 0x0600; // Assign lower 2-bits of kpixAddress
            ltxBuff[0] |= (regReqEntry_->address() << 2) & 0xF000; // Assign upper 4-bits of kpixAddress
         }

         // Setup tx buffer for fpga write
         else {
            ltxBuff[0]  = (regReqEntry_->address() & 0x00FF);
            if ( regReqWrite_ ) ltxBuff[0] |= 0x0100; // Write
         }

         // Write has data
         if ( regReqWrite_ ) {
            ltxBuff[1] = regReqEntry_->get(0,0xFFFF);
            ltxBuff[2] = regReqEntry_->get(16,0xFFFF);
            txPend = false;
         }

         // Read is always small
         else {
            ltxBuff[1] = 0;
            ltxBuff[2] = 0;
            txPend     = true;
         }

         // Checksum 
         ltxBuff[3] = ((ltxBuff[0] + ltxBuff[1] + ltxBuff[2]) & 0xFFFF);

         // Send data, write has no response
         txRet = txFrame ( ltxBuff, 4, txType);
         if ( regReqWrite_ ) {
            usleep(1000);
            regRespCnt_++;
         }

         // Match request count
         lastReqCnt = regReqCnt_;
      }
      else txRet = 0;

      // Command TX is pending
      if ( lastCmdCnt != cmdReqCnt_ ) {
         cmdBuff[0]  = (cmdReqEntry_->opCode() & 0x007F);
         cmdBuff[0] |= 0x0080; // Write
         cmdBuff[0] |= 0x0000; // Command
         cmdBuff[0] |= 0x0800; // Bcast
         cmdBuff[1] = 0;
         cmdBuff[2] = 0;
         cmdBuff[3] = cmdBuff[0];

         // Extract lane
         cmdType = (cmdReqEntry_->opCode()>>8) & 0xF;

         // Send data
         cmdRet = txFrame ( cmdBuff, 4, cmdType);

         // Match request count
         lastCmdCnt = cmdReqCnt_;
         cmdRespCnt_++;
      }
      else cmdRet = 0;

      // Run Command TX is pending
      if ( lastRunCnt != runReqCnt_ ) {
         runBuff[0]  = (runReqEntry_->opCode() & 0x007F);
         runBuff[0] |= 0x0080; // Write
         runBuff[0] |= 0x0000; // Command
         runBuff[0] |= 0x0800; // Bcast
         runBuff[1] = 0;
         runBuff[2] = 0;
         runBuff[3] = runBuff[0];

         // Extract lane
         runType = (runReqEntry_->opCode()>>8) & 0xF;

         // Send data
         runRet = txFrame ( runBuff, 4, runType);

         // Match request count
         lastRunCnt = runReqCnt_;
      }
      else runRet = 0;

      // Pause if nothing was done
      if ( rxRet <= 0 && txRet <= 0 && cmdRet <= 0 && runRet <= 0 ) usleep(1);
   }

   free(rxBuff);
   free(txBuff);
}

// Constructor
OptoFpgaLink::OptoFpgaLink ( ) : CommLink() {
   device_    = "";
   fd_        = -1;
}

// Deconstructor
OptoFpgaLink::~OptoFpgaLink ( ) {
   close();
}

// Open link and start threads
void OptoFpgaLink::open ( string device ) {
   stringstream  error;
   struct termio svbuf;
   error.str("");

   // Make sure no links are open
   if ( fd_ >= 0 ) throw string("OptoFpgaLink::open -> Link Already Open");

   // Attempt to open serial port
   if ((fd_=::open(device.c_str(), O_RDWR|O_NOCTTY|O_NONBLOCK)) < 0) {
      error << "OptoFpgaLink::open -> Error opening VCP USB device " << device;
      cout << error.str() << endl;
      throw(error.str());
   }

   // Setup serial port
   ioctl(fd_,TCGETA,&svbuf);
   svbuf.c_iflag = 0;
   svbuf.c_oflag = 0;
   svbuf.c_lflag = 0;
   svbuf.c_cflag = B38400 | CS8 | CLOCAL | CREAD;
   ioctl(fd_,TCSETA,&svbuf);

   if ( debug_ ) cout << "OptoFpgaLink::open -> Opened VCP USB device " << device << endl;

   // Set device variable
   device_ = device;
   CommLink::open();
}

// Stop threads and close link
void OptoFpgaLink::close () {

   // Close vcp link
   if ( fd_ >= 0 ) {
      CommLink::close();
      usleep(100);
      ::close(fd_);
      fd_ = -1;
   }
}

