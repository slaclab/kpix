//-----------------------------------------------------------------------------
// File          : KpixBunchTrain.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to handle a Kpix bunch train contining samples.
// An array of sample objects is stored in this class. These samples
// can be retrieved either by direct channel/bucket addressing or by
// getting an list of samples sorted by time. 
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 12/01/2006: Added 32-bit sample ID, serial number as class variable
//             Add methods to store sample and sample data in file as well as
//             constructor meathod to build sample from data file.
// 03/07/2007: Added support for 4 KPIX devices. Added root support.
// 03/19/2007: Changed class name.
// 04/27/2007: Convert to new communication protocol
// 04/30/2007: Added local store of train number, ability to read.
// 08/13/2007: Added external accept flag.
// 05/13/2009: Added special data flag for Temp value and trigger log.
// 05/13/2009: Removed Accept Flag.
// 06/22/2009: Added namespaces.
// 06/23/2009: Removed namespaces.
// 09/11/2009: Added max sample constant.
//-----------------------------------------------------------------------------
#ifndef __KPIX_BUNCH_TRAIN_H__
#define __KPIX_BUNCH_TRAIN_H__


// Forward declarations
class SidLink;
class KpixSample;
class KpixAsic;

/** \ingroup online */

//! This class is used to hold KPIX bunch train information

class KpixBunchTrain {

      // Define max number of samples that can be received
      static const unsigned int MaxSamples = (1024*4+20) * 32;

      // Array of sample data sorted by sample time, pointers
      KpixSample *samplesByTime[MaxSamples+1];

      // Total number of samples
      unsigned int totalCount;

      // Dead count & parity error count
      unsigned int deadCount;
      unsigned int parErrors;

      // Sequence Number
      unsigned int trainNumber;

      // Is last
      bool lastTrain;

   public:

      //! Sample class constructor, received frame
      /*! Pass the following values for construction
      link      = SID Link to receive data
      debug     = Debug flag
      asicCnt   = Asic Count (optional)
      asics     = Asic List  (optional)
		*/
      KpixBunchTrain ( SidLink *link, bool debug, unsigned int asicCnt = 0, KpixAsic **asics = NULL );

      //! Method to return an sample by KPIX/channel/bucket
      /*! Pass KPIX serial, channel number & bucket number
		*/
      KpixSample * getSample ( unsigned short kpix, unsigned short channel, unsigned char bucket );

      //! Method to return an sample list sorted by time
      /*! Return pointer to array of 4*64*4 possible samples, unused locations point to NULL
		*/
      KpixSample ** getSampleList ( );

      //! Method to return total sample count
      unsigned int getSampleCount ( );

      //! Method to return sample count for a kpix/channel
      unsigned int getSampleCount ( unsigned short kpix, unsigned short channel );

      //! Get dead count
      unsigned int getDeadCount ();

      //! Get parity errors
      unsigned int getParErrors ();

      //! Get last train flag
      bool getLastTrain ();

      //! Get sequence number
      unsigned int getTrainNumber();

      //! Deconstructor, Will delete all associated samples stored in this sample.
      virtual ~KpixBunchTrain ( );

};
#endif
