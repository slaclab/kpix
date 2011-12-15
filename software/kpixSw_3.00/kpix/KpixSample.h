//-----------------------------------------------------------------------------
// File          : KpixSample.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 12/02/2011
// Project       : Kpix DAQ
//-----------------------------------------------------------------------------
// Description :
// Sample Container
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
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/02/2011: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_SAMPLE_H__
#define __KPIX_SAMPLE_H__
#include <sys/types.h>
using namespace std;

//! Tracker Event Container Class
class KpixSample {

      // Local data
      ushort ldata_[3];

      // Data pointer
      ushort *data_;

      // Train number
      uint trainNumber_;

   public:

      //! Constructor for static pointer
      KpixSample ();

      //! Constructor with copy
      KpixSample ( ushort *data, uint trainNumber );

      //! DeConstructor
      ~KpixSample ( );

      //! Set data pointer.
      /*!
       * \param data Data pointer.
      */
      void setData ( ushort *data, uint trainNumber );

      //! Get sample train number.
      /*!
         Method to return sample train number. This serial number associates this sample 
         with an acquisition cycle, also refered to as a bunch train in the ILC.
         \return Sample Train Number.
         \see trainNum
      */
      uint getTrainNum();

      //! Get KPIX address from sample.
      /*!
         Method to return KPIX address from sample. This is the physical address of the KPIX 
         which generated this sample.  The root file which stores samples will contain a tree of 
         KPIX objects, one for each KPIX in the system. This address can be used to associate
         this sample with a given KPIX in the tree.
         \see kpixAddress
         \return KPIX Address.
      */
      uint getKpixAddress();

      //! Get KPIX channel.
      /*!
         Method to return KPIX channel number from sample.  The KPIX contains 1024 pixels organized in an 
         array of 32 rows x 32 columns. Bits [4:0] of the channel value define the row, while bits [9:5]
         define the column.
         \see kpixChannel
         \return Kpix Channel Number, masked to ensure it lies between 0 and 1023.
      */
      uint getKpixChannel();

      //! Get KPIX bucket.
      /*!
         Method to return KPIX bucket number from sample.  Each pixel in the KPIX device can store 
         up to 4 samples. Each sample is stored in a location refered to as a bucket. This value 
         defines which bucket, numbered 0-3, contained this sample.
         \see kpixBucket
         \return Kpix Bucket Number, masked to ensure it lies between 0 and 3.
      */
      uint getKpixBucket();

      //! Get sample range.
      /*!
         The range flag determines if the sample is normal gain or low gain.
         \see sampleRange
         \return Sample Range.
               - 0 = Normal
               - 1 = Low Gain
               .
      */
      uint getSampleRange();

      //! Get sample time
      /*!
         This sample time value contains a timestamp identifying the relative
         time of the sample within the bunch train. Each bunch period, or crossing,
         in a bunch train has a unique time value. Each train can contain between
         1 and 8191 bunch crossing periods, each one with a period of 8 acquisition
         clock cycles.
         \see sampleTime
         \return Sample Time, masked to ensure it lies between 0 and 8191.
      */
      uint getSampleTime();

      //! Get sample value.
      /*!
         The sample value is the ADC value of the sample, between 0 and 8191. 
         \see sampleValue
         \return Sample value, masked to ensure it lies between 0 and 8191.
      */
      uint getSampleValue();

      //! Get empty flag.
      /*!
         The empty flag defines that the sample does not contain real data. This may occur if
         the run was performed in a mode forcing all sample values to be returned, regardless of
         the channel's event count.
         \see sampleRange
         \return Empty Flag
            - 0 = Normal
            - 1 = Empty Record
            .
      */
      uint getEmpty();

      //! Get badCount flag.
      /*!
         The bad count flag is set when the channel's event count field contained an invalid value.
         This may occur if the run was performed in a mode forcing all sample values to be returned, 
         regardless of the channel's event count.
         \see sampleRange
         \return Bad Count Flag.
            - 0 = Normal
            - 1 = Bad Count
            .
      */
      uint getBadCount();

      //! Get trigger type flag.
      /*!
         The trigger type flag distinguishes between samples caused by the channel's local trigger
         logic or an external source. The external source can either be the external force trigger
         input or the neighboring channel if nearest neighbor triggering is enabled.
         \see sampleRange
         \return Trigger Type Flag.
            - 0 = External
            - 1 = Local
            .
      */
      uint getTrigType();

      //! Get special flag.
      /*!
         The special flag is used to distinguish between normal KPIX sample data and special 
         sample data. Special sample records contain either an external trigger timestamp or KPIX 
         temperature data. Trigger timestamps have a channel number of 1, and contain the trigger 
         timestamp in the sampleTime field. The KPIX address associated with trigger timestamps
         is the same as the KPIX core contained in the concentrator FPGA. Temperature records 
         have a channel number of 0 and contain the temperatue value in the sampleValue field.
         \see sampleRange
         \return Special Flag.
            - 0 = Normal
            - 1 = Special Record
            .
      */
      uint getSpecial();

};

#endif
