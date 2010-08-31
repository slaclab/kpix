//-----------------------------------------------------------------------------
// File          : KpixThreshScan.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 03/07/2007
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to perform a threshold scan
// A scan is performed on a target channel or on all channels.
// Threshold range A is scanned while a pulse is injected into the selected
// channel. 
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 03/06/2007: created
// 03/20/2007: Modified for new root tree structures
// 04/05/2007: Added ability to set how pre-trigger threshold setting tacks
//             trigger threshold setting.
// 04/05/2007: Added ability to choose the threshold (A or B) to use for test.
// 05/01/2007: Added support for multiple KPIX devices
// 07/31/2007: Changed iteration count to int from unsigned char.
// 11/12/2007: Removed set threshold method
// 10/10/2008: Added support for progress updates to calling class. Added
//             iteration count variable.
// 10/26/2008: Added support for plot generation.
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespaces.
//-----------------------------------------------------------------------------
#ifndef __KPIX_THRESH_SCAN_H__
#define __KPIX_THRESH_SCAN_H__

#include <string>

// Forward declarations
class KpixRunWrite;
class KpixProgress;
class KpixAsic;

/** \ingroup online */

//! This class is used to store and set threshold scan settings
/*!
*/

class KpixThreshScan {

      // Locations to store asic and run objects to use
      KpixAsic     *tempAsic;
      KpixAsic     **kpixAsic;
      KpixRunWrite *kpixRunWrite;

      // Numer of Kpix devices
      int kpixCount;

      // Enable debug
      bool enDebug;

      // Enables for each gain range
      bool enNormal;
      bool enDouble;
      bool enLow;

      // Plot and raw data enable
      bool rawEn;
      bool plotEn;

      // Plot Directory
      std::string plotDir;

      // Calibration charge enable
      bool calEnable;

      // Range for calibration
      unsigned char calStart;
      unsigned char calEnd;
      unsigned char calStep;

      // Range for threshold
      unsigned char threshStart;
      unsigned char threshEnd;
      unsigned char threshStep;
      int           threshCount;

      // Pre-trigger threshold offset
      char threshOffset;

      // Progress class for reporting status
      KpixProgress *kpixProgress;

   public:

      //! Constructor for single KPIX. 
      /*! Pass a pointer to the Kpix Asic and the Run object*/
      KpixThreshScan ( KpixAsic *asic, KpixRunWrite *run );

      //! Constructor for multiple KPIX devices. 
      /*! Pass a pointer to the Kpix Asic and the Run object*/
      KpixThreshScan ( KpixAsic **asic, unsigned int count, KpixRunWrite *run );

      //! Enable disable charge injection
      void setCalibEn ( bool enable );

      //! Set calibration DAC steps for threshold scan
      void setCalibRange ( unsigned char start, unsigned char end, unsigned char step );

      //! Set threshold range of threshold scan
      void setThreshRange (unsigned char start, unsigned char end, unsigned char step);

      //! Set pre-trigger threshold offset
      /*!Set a negative value to track the pre-trigger threshold below
      the trigger threshold. Set to zero to keep the same as
      the trigger threshold. Set to a positive value to set 
      pre-trigger to always be 0xB0.
		*/
      void setPreTrigger ( char diff );

      //! Set number of iterations to run at each step
      void setThreshCount ( int count );

      //! Enable/Disable normal amplifier gain iteration
      void enNormalGain ( bool enable );

      //! Enable/Disable double amplifier gain iteration
      void enDoubleGain ( bool enable );

      //! Enable/Disable low amplifier gain iteration
      void enLowGain ( bool enable );

      //! Turn on or off debugging for the class
      void threshDebug ( bool debug );

      //! Enable raw scan data storage
      void enableRawData( bool enable );

      //! Enable plot generation during a scan
      void enablePlots( bool enable );

      //! Pass name of the TFile directory in which to store the plots
      void setPlotDir( std::string plotDir );

      //! Execute threshold scan, pass target channel
      /*! Or pass -1 to enable all channels*/
      void runThreshold ( short channel );

      //! Deconstructor
      virtual ~KpixThreshScan ();

      //! Set progress Callback
      void setKpixProgress(KpixProgress *progress);

};
#endif
