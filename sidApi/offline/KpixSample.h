//-----------------------------------------------------------------------------
// File          : KpixSample.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to handle a KPIX sample. This class stored a single
// sample at a specific time for a specific channel and bucket. The sample time,
// value and range is stored.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
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
//-----------------------------------------------------------------------------
#ifndef __KPIX_SAMPLE_H__
#define __KPIX_SAMPLE_H__

#include <TObject.h>
using namespace std;


// KPIX Event Data Class
namespace sidApi {
   namespace offline {
      class KpixSample : public TObject {

         public:

            // Serial number of the train this sample is related ot.
            Int_t trainNum;

            // Event address, channel & bucket
            Int_t kpixAddress;
            Int_t kpixChannel;
            Int_t kpixBucket;

            // Sample Range Value, Used to map multiple bits
            // Bit 0 = Range Flag, 0 = Normal, 1 = Low Gain
            // Bit 1 = Empty Flag, 0 = Normal, 1 = Empty Record
            // Bit 2 = Bad Count,  0 = Normal, 1 = Bad Count
            // Bit 3 = Trigger,    1 = Local,  0 = External
            // Bit 4 = Special,    0 = Normal, 1 = Special Record
            Int_t sampleRange;

            // Event Data, time & amplitude
            Int_t sampleTime;
            Int_t sampleValue;

            // Variables associated with the event, the name of the variable
            // and its description are stored in the KpixVariable class
            Int_t     varCount;
            Double_t  *varValue; //[varCount] : Root Length definition

            // Event class constructor
            KpixSample ( );

            // Event class constructor
            // Pass the following values for construction
            // address      = KPIX Address
            // channel      = KPIX Channel
            // bucket       = KPIX Bucket
            // range        = Range Flag
            // time         = Timestamp
            // value        = Value
            // train        = Train Number
            // empty        = Sample is empty
            // badCount     = Channel counter was bad
            // trigType     = 0=Local, 1=Neighbor
            // special      = 0=Normal Data, 1=Special Data Type
            KpixSample ( Int_t address, Int_t channel, Int_t bucket, Int_t range, 
                         Int_t time, Int_t value, Int_t train, Int_t empty, Int_t badCount, 
                         Int_t trigType, Int_t special, bool debug );

            // Set variable values
            // Pass number of values to store and an array containing
            // a list of those variables. The passed array pointer value
            // should be persistant for the life of this event object.
            void setVariables ( Int_t count, Double_t *values );

            // Get train number
            Int_t getTrainNum();

            // Get KPIX address
            Int_t getKpixAddress();

            // Get KPIX channel
            Int_t getKpixChannel();

            // Get KPIX bucket
            Int_t getKpixBucket();

            // Get sample range, 0 = Normal, 1 = Low Gain
            Int_t getSampleRange();

            // Get sample time
            Int_t getSampleTime();

            // Get sample value
            Int_t getSampleValue();

            // Get variable count
            Int_t getVarCount();

            // Get empty flag, 0 = Normal, 1 = Empty Record
            Int_t getEmpty();

            // Get badCount flag, 0 = Normal, 1 = Bad Count
            Int_t getBadCount();

            // Get trigger type flag, 1 = Local, 0 = External or neighbor
            Int_t getTrigType();

            // Get special flag, 0 = Normal, 1 = Special Data
            Int_t getSpecial();

            // Get variable value
            Double_t getVarValue(Int_t var);

            // Deconstructor
            virtual ~KpixSample();

            ClassDef(KpixSample,2)
      };
   }
}
#endif
