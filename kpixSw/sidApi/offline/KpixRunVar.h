//-----------------------------------------------------------------------------
// File          : KpixRunVar.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/26/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class to store a KPIX run variable.
// All values will be stored as doubles. 
// This object can be stored in a root tree
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 12/18/2006: created
// 03/19/2007: Changed variables to root specific types.
// 06/18/2009: Added namespace.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_RUN_VAR_H__
#define __KPIX_RUN_VAR_H__

#include <TObject.h>
#include <TString.h>

/** \ingroup offline */

//! This class is used to hold and update Run Variable information

class KpixRunVar : public TObject {

      // Char string containing name, NULL terminated
      TString varName;

      // Char string containing description, NULL terminated
      TString varDesc;

      // Value
      Double_t varValue;

   public:

      //! Variable class constructor
      KpixRunVar ( );

      //! Variable class constructor
      /*! Pass the following values for construction
      name      = Variable name string
      desc      = Variable description string
      value     = Initial value
		*/
      KpixRunVar ( TString name, TString desc, Double_t value );

      //! Return variable name
      TString name ();

      //! Return variable description
      TString description ();

      //! Return Value
      Double_t value();

      //! Set Value
      void value( Double_t value );

      //! Deconstructor
      virtual ~KpixRunVar (); 

      ClassDef(KpixRunVar,2)
};
#endif
