//-----------------------------------------------------------------------------
// File          : KpixSample.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/26/2006: created
// 11/13/2006: Added debug for event creation
// 12/01/2006: Added 32-bit sample ID for linking
// 12/19/2006: Added support for run variables, added root support
// 03/19/2007: Changed variable types to root specific values. 
//             Changed name to KpixSample.
// 04/29/2007: Train number now passed during creation
// 02/27/2008: Added ability to store/read empty & bad count flags.
// 04/27/2009: Added trigger type flag.
// 05/13/2009: Added special flag.
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespace.
// 06/25/2009: Added doxygen tags.
//-----------------------------------------------------------------------------
#ifndef __KPIX_SAMPLE_H__
#define __KPIX_SAMPLE_H__

#include <TObject.h>

/** \defgroup offline
 * Classes used in offline data processing.
 */

/** \ingroup offline */
//! Class to hold Kpix sample data.
/*!
   This class can either store sample data from a KPIX pixel, temperature data from
   a KPIX or trigger timestamps from the concentrator FPGA. This class is stored in
   a tree in a root file and is read using the KpixRunRead class.
*/
class KpixSample : public TObject {

   public:

      //! Serial number of the train in which this sample was stored.
      /*!
         This serial number associates this sample with an acquisition cycle, also
         refered to as a bunch train in the ILC.
         \see getTrainNum()
      */
      Int_t trainNum;

      //! Address of the KPIX which originated this sample.
      /*!
         This is the physical address of the KPIX which generated this sample.
         The root file which stores samples will contain a tree of KPIX objects, 
         one for each KPIX in the system. This address can be used to associate
         this sample with a given KPIX in the tree.
         \see getKpixAddress()
      */
      Int_t kpixAddress;

      //! Channel number of the pixel which originated this sample.
      /*!
         The KPIX contains 1024 pixels organized in an array of 32 rows x
         32 columns. Bits [4:0] of the channel define the row, while bits [9:5]
         define the column.
         \see getKpixChannel()
      */
      Int_t kpixChannel;

      //! Sample bucket number within the pixel which originated this sample.
      /*!
         Each pixel in the KPIX device can store up to 4 samples. Each sample
         is stored in a location refered to as a bucket. This value defines 
         which bucket, numbered 0-3, contained this sample.
         \see getKpixBucket()
      */
      Int_t kpixBucket;

      //! Field containing sample flags
      /*!
         This field originally contained the range bit value but was expanded
         to store additional sample information as the KPIX design eveolved. 
         This field now serves as a bit field defined as follows:
            - Bit 0 = Range Flag. Defines normal or low gain.
               - 0 = Normal
               - 1 = Low Gain
               .
            - Bit 1 = Empty Flag. Used when the hardware is configured to return raw sample data.
               - 0 = Normal
               - 1 = Empty Record
               .
            - Bit 2 = Bad Count. Set when the KPIX returned a bad value for the channel's sample count.
            Is only used when the hardware is configured to return raw sample data.
               - 0 = Normal
               - 1 = Bad Count
               .
            - Bit 3 = Trigger. Defines the trigger soruce for the sample.
               - 0 = External
               - 1 = Local
               .
            - Bit 4 = Special Flag. Used to distinguish between normal KPIX sample data and special 
            sample data. Special sample records contain either an external trigger timestamp or KPIX 
            temperature data. Trigger timestamps have a channel number of 1, and contain the trigger 
            timestamp in the sampleTime field. The KPIX address associated with trigger timestamps
            is the same as the KPIX core contained in the concentrator FPGA. Temperature records 
            have a channel number of 0 and contain the temperatue value in the sampleValue field.
               - 0 = Normal
               - 1 = Special Record
               .
            .
         \see getSampleRange()
         \see getEmpty()
         \see getBadCount()
         \see getTrigType()
         \see getSpecial()
      */
      Int_t sampleRange;

      //! 13-bit timestamp of sample.
      /*!
         This sample time value contains a timestamp identifying the relative
         time of the sample within the bunch train. Each bunch period, or crossing,
         in a bunch train has a unique time value. Each train can contain between
         1 and 8191 bunch crossing periods, each one with a period of 8 acquisition
         clock cycles.
         \see getSampleTime()
      */
      Int_t sampleTime;

      //! 13-bit ADC value of sample.
      /*!
         The sample value is the ADC value of the sample, between 0 and 8191. 
         \see getSampleValue()
      */
      Int_t sampleValue;

      //! Number of event variables associated with this sample. 
      /*!
         The storage of event variables in each sample record allows the DAQ 
         system to associate one or more setting values with each sample. These 
         values may change from cycle to cycle. An example of a usefull event 
         variable is the amount of charge injected at each step during calibration.  
         The var count field defines the number of variable values stored in this sample.
         The root file for a run will store a tree of KpixEventVar objects, one for
         each of the values stored in each sample. These objects serve as a key to define
         each entry in the variable array by index. 
         \see getVarCount()
         \see varValue
      */
      Int_t     varCount;

      //! Array of event variable values associated with this sample.
      /*!
         This array contains a variable number of double values which are associated with
         this sample. Each of these values is associated by index with a KpixEventVar 
         object in the root file.
         \see getVarValue()
         \see varCount
      */
      Double_t  *varValue; //[varCount] : Root Length definition

      //! Constructor for empty sample.
      /*!
         This constructor is used to create an initlized object. All fields are set to
         a default value of 0.
      */
      KpixSample ( );


      //! Constructor for non-empty sample.
      /*!
         This constructor is used by the KpixBunchTrain class to create a sample object
         using data received from the hardware. 
         \param address  KPIX address
         \param channel  KPIX channel
         \param bucket   KPIX bucket
         \param range    Range value for sample.
         \param time     Timestamp for KPIX sample.
         \param value    ADC value for KPIX sample.
         \param train    Serial number of the bunch train.
         \param empty    Flag indicating that the sample is empty.
         \param badCount Flag indicating the channel had a bad count.
         \param trigType Trigger type flag.
         \param special  Special sample flag.
         \param debug    Display debug information if set.
      */
      KpixSample ( Int_t address, Int_t channel, Int_t bucket, Int_t range, 
                   Int_t time, Int_t value, Int_t train, Int_t empty, Int_t badCount, 
                   Int_t trigType, Int_t special, bool debug );

      // Set variable values
      // Pass number of values to store and an array containing
      // a list of those variables. The passed array pointer value
      // should be persistant for the life of this event object.


      //! Set the array of event variables in the sample.
      /*!
         This method is used to set the current values of the event variables to the
         newly created sample object. This method is called by the KpixBunchTrain class
         after the sample is created.
         \param count   Number of event variables in the array.
         \param *values Array of event variables.
         \see varCount
         \see varValue
         \see getVarCount()
         \see getVarValue()
      */
      void setVariables ( Int_t count, Double_t *values );

      // 
      //! Get sample train number.
      /*!
         Method to return sample train number. This serial number associates this sample 
         with an acquisition cycle, also refered to as a bunch train in the ILC.
         \return Sample Train Number.
         \see trainNum
      */
      Int_t getTrainNum();

      //! Get KPIX address from sample.
      /*!
         Method to return KPIX address from sample. This is the physical address of the KPIX 
         which generated this sample.  The root file which stores samples will contain a tree of 
         KPIX objects, one for each KPIX in the system. This address can be used to associate
         this sample with a given KPIX in the tree.
         \see kpixAddress
         \return KPIX Address.
      */
      Int_t getKpixAddress();

      //! Get KPIX channel.
      /*!
         Method to return KPIX channel number from sample.  The KPIX contains 1024 pixels organized in an 
         array of 32 rows x 32 columns. Bits [4:0] of the channel value define the row, while bits [9:5]
         define the column.
         \see kpixChannel
         \return Kpix Channel Number, masked to ensure it lies between 0 and 1023.
      */
      Int_t getKpixChannel();

      //! Get KPIX bucket.
      /*!
         Method to return KPIX bucket number from sample.  Each pixel in the KPIX device can store 
         up to 4 samples. Each sample is stored in a location refered to as a bucket. This value 
         defines which bucket, numbered 0-3, contained this sample.
         \see kpixBucket
         \return Kpix Bucket Number, masked to ensure it lies between 0 and 3.
      */
      Int_t getKpixBucket();

      //! Get sample range.
      /*!
         The range flag determines if the sample is normal gain or low gain.
         \see sampleRange
         \return Sample Range.
               - 0 = Normal
               - 1 = Low Gain
               .
      */
      Int_t getSampleRange();

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
      Int_t getSampleTime();

      //! Get sample value.
      /*!
         The sample value is the ADC value of the sample, between 0 and 8191. 
         \see sampleValue
         \return Sample value, masked to ensure it lies between 0 and 8191.
      */
      Int_t getSampleValue();

      //! Get variable count.
      /*!
         Return the number of event variables in the sample.
         The storage of event variables in each sample record allows the DAQ 
         system to associate one or more setting values with each sample. These 
         values may change from cycle to cycle. An example of a usefull event 
         variable is the amount of charge injected at each step during calibration.  
         The var count field defines the number of variable values stored in this sample.
         The root file for a run will store a tree of KpixEventVar objects, one for
         each of the values stored in each sample. These objects serve as a key to define
         each entry in the variable array by index. 
         \see varCount
         \see varValue
         \see getVarValue()
         \return Event Variable Count
      */
      Int_t getVarCount();

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
      Int_t getEmpty();

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
      Int_t getBadCount();

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
      Int_t getTrigType();

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
      Int_t getSpecial();

      //! Get variable value.
      /*!
         This array contains a variable number of double values which are associated with
         this sample. Each of these values is associated by index with a KpixEventVar 
         object in the root file.
         \see varCount
         \see varValue
         \see getVarCount()
         \param var The index of the variable to return.
         \throws string Error string if var is out of range.
         \return The event variable value for the passed index.
      */
      Double_t getVarValue(Int_t var);

      //! Deconstructor
      virtual ~KpixSample();

      ClassDef(KpixSample,2)
};

#endif
