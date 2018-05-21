//-----------------------------------------------------------------------------
// File          : KpixHistogram.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/15/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Class to track histograms generated in KPIX runs.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/15/2008: created
// 03/03/2009: changed container values to unsigned int
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_HISTOGRAM_H__
#define __KPIX_HISTOGRAM_H__

/** \ingroup online */


//! This class is used to update KPIX histogram information.

class KpixHistogram {

      // Histogram contents
      unsigned int *data;

      // Number of entries in histogram
      unsigned int entries;

      // Min Value
      unsigned int min;
      unsigned int max;

   public:

      //! Constructor
      KpixHistogram ( );

      //! Constructor
      ~KpixHistogram ( );

      //! Init histogram
      void init();

      //! Add an entry
      void fill(unsigned int value);

      //! Get Number Of Entries
      unsigned int binCount();

      //! Get Min Value
      unsigned int minValue();

      //! Get Max Value
      unsigned int maxValue();

      //! Get Bin Value
      unsigned int value(unsigned int bin);

      //! Get Bin Count
      unsigned int count(unsigned int bin);
};
#endif
