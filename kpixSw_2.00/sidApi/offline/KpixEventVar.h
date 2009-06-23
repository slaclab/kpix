//-----------------------------------------------------------------------------
// File          : KpixEventVar.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to store a KPIX event variable.
// This class is used to match a variable value stored in a KpixSample object
// to a variable name and description. The number stored in this class will
// correspnd to an index for an array of doubles in which the value is stored.
// All values will be stored as doubles. 
// This object can be stored in a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/18/2006: created
// 03/19/2007: Changed variables to root specific types.
// 06/18/2009: Added namespace
//-----------------------------------------------------------------------------
#ifndef __KPIX_EVENT_VAR_H__
#define __KPIX_EVENT_VAR_H__

#include <TObject.h>
#include <TString.h>


namespace sidApi {
   namespace offline {
      class KpixEventVar : public TObject {

            // Variable number to match to sample records
            Int_t varNumber;

            // Variable Name
            TString varName;

            // Variable Description
            TString varDesc;

         public:

            // Variable class constructor
            KpixEventVar ( );

            // Variable class constructor
            // Pass the following values for construction
            // number    = Variable number
            // name      = Variable name string
            // desc      = Variable description string
            KpixEventVar ( Int_t number, TString name, TString desc );

            // Return variable name
            TString name ();

            // Return variable description
            TString description ();

            // Return variable number
            Int_t number ();

            // Deconstructor 
            virtual ~KpixEventVar();

            ClassDef(KpixEventVar,3)
      };
   }
}
#endif
