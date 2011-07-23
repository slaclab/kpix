//-----------------------------------------------------------------------------
// File          : Device.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic device container.
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------
#ifndef __DEVICE_H__
#define __DEVICE_H__

#include <string>
#include <sstream>
#include <map>
#include <vector>
#include <libxml/parser.h>
using namespace std;

class Variable;
class Register;

//! Class to contain generic device data.
class Device {

   protected:

      // Device name
      string name_;

      // Device address
      uint address_;

      // Map of variables
      map<string,Variable*> variables_;

      // Vector of registers
      map<string,Register *> registers_;

      // Debug flag
      bool debug_;

      // Device is present
      bool enabled_;

      // XML Variables
      xmlParserCtxtPtr ctxt_;
      xmlSAXHandler    xmlHandler_;

      // XML Callback Functions
      static void startElement ( void *userData, const xmlChar* name, const xmlChar** attrs );
      static void endElement ( void *userData, const xmlChar* name );
      static void characters ( void *userData, const xmlChar* ch, int len );

      // XML State
      bool   inDevice_;
      string str_;

   public:

      //! Constructor
      /*! 
       * \param name Device name
       * \param address Device address
      */
      Device ( string name, uint address );

      //! Deconstructor
      ~Device ( );

      //! Set debug flag
      void debug( bool enable );

      //! Get enabled flag
      bool enabled();

      //! Disable device
      void disable();

      //! Method to get name
      string name ();

      //! Method to get address
      uint address();

      //! Method to set variable
      void set ( string variable, string value );

      //! Method to get variable
      string get ( string variable );

      //! Return a vector of registers
      map<string,Register *> registers();

      //! Method to read variables from registers
      /*! 
       * Return string containing variables in XML format
      */
      string read();

      //! Method to write variables to registers
      /*! 
       * /param xml Optional string containing variable settings in XML format
      */
      void write( string xml = "");

};
#endif
