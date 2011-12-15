//-----------------------------------------------------------------------------
// File          : OptoFpgaLink.h
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
#ifndef __OPTO_FPGA_LINK_H__
#define __OPTO_FPGA_LINK_H__

#include <sys/types.h>
#include <string>
#include <sstream>
#include <map>
#include <pthread.h>
#include <unistd.h>
#include <CommLink.h>
using namespace std;

//! Class to contain PGP communications link
class OptoFpgaLink : public CommLink {

   protected:

      // Device info
      string device_;
      int    fd_;

      // Receive frame
      int rxFrame ( ushort *frame, uint size, uint *type, uint *err );

      // transmit frame
      int txFrame ( ushort *frame, uint size, uint type );

   public:

      //! Constructor
      OptoFpgaLink ( );

      //! Deconstructor
      ~OptoFpgaLink ( );

      //! IO handling thread
      void ioHandler();

      //! Open link and start threads
      /*! 
       * Throw string on error.
       * \param device virtual com port device
      */
      void open ( string device );

      //! Stop threads and close link
      void close ();

};
#endif
