//-----------------------------------------------------------------------------
// File          : KpixEvent.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : KPIX DAQ Software
//-----------------------------------------------------------------------------
// Description :
// Event data container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//----------------------------------------------------------------------------
// Description :
// Event Container
// Event Data consists of the following: Z[xx:xx] = Zeros
//    Frame Size = 1 x 32-bits (32-bit dwords)
//    Header = 2 x 16-bits
//       Header[0] = TrainNumber[15:0]
//       Header[1] = TrainNumber[31:16]
//
//    Samples = N * 3 * 16-bits
//       Sample[0] = 0,1,Bucket[1:0],Kpix[1:0],Chan[9:0]
//       Sample[1] = S,Time[12],R,E,Time[11:0]
//       Sample[1] = F,T,C,AdcValue[12:0]
//       0 = Always '0'
//       1 = Always '1'
//       S = Sample is special
//       R = Range bit, '1' = low gain
//       E = Empty sample bit
//       F = Future use bit
//       T = Trigger bit, 1 = external trigger
//       C = Bad count flag
//
//    Tail = 3 x 16-bits
//       Tail[0] = 1, Count[14:0]
//       Tail[1] = A, 0, P, DeadCnt[12:0]
//       Tail[2] = CheckSum[15:0]
//       0 = Always '0'
//       1 = Always '1'
//       A = Is running Flag
//       P = Data parity error flag
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_EVENT_H__
#define __KPIX_EVENT_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <sys/types.h>
#include "KpixSample.h"
#include <Data.h>
using namespace std;

//! Tracker Event Container Class
class KpixEvent : public Data {

      // Frame Constants
      static const uint headSize_   = 2;
      static const uint tailSize_   = 3;
      static const uint sampleSize_ = 3;

      // Internal sample contrainer
      KpixSample sample_;

      // word pointer
      ushort *word_;

      // counters
      uint trainNumber_;
      uint count_;
      uint deadCount_;

      // Process frame
      void update();

   public:

      //! Constructor
      KpixEvent ();

      //! Deconstructor
      ~KpixEvent ();

      //! Get train number 
      uint trainNumber ( );

      //! Get sample count
      uint count ( );

      //! Get dead counter
      uint deadCount ( );

      //! Get sample at index
      /*!
       * Returns pointer to static sample object without memory allocation.
       * Contents of returned object will change next time sample() is called.
       * \param index Sample index. 0 - count()-1.
      */
      KpixSample *sample (uint index);

      //! Get sample at index
      /*!
       * Returns pointer to copy of sample object. A newly allocated sample object
       * is created and must be deleted after use.
       * \param index Sample index. 0 - count()-1.
      */
      KpixSample *sampleCopy (uint index);

};

#endif
