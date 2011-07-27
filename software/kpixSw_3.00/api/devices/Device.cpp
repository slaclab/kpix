//-----------------------------------------------------------------------------
// File          : Device.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 04/12/2011
// Project       : KPIX API
//-----------------------------------------------------------------------------
// Description :
// Generic device container
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 04/12/2011: created
//-----------------------------------------------------------------------------

#include "Device.h"
#include "Register.h"
#include "Variable.h"
#include <libxml/parser.h>
#include <sstream>
#include <string.h>
using namespace std;

//! Constructor
Device::Device ( string name, uint address ) {
   name_     = name;
   address_  = address;
   debug_    = false;
   enabled_  = false;
   inDevice_ = false;
   str_      = "";
   variables_.clear();
   registers_.clear();
   xmlHandler_.startElement = &Device::startElement;
   xmlHandler_.endElement   = &Device::endElement;
   xmlHandler_.characters   = &Device::characters;
   xmlCleanupParser();
}

//! Deconstructor
Device::~Device ( ) {
   variables_.clear();
   registers_.clear();
}

//! Set debug flag
void Device::debug( bool enable ) {
   debug_ = enable;
}

//! Get enabled flag
bool Device::enabled() { return(enabled_); }

//! Disable device
void Device::disable() { 
   enabled_ = false;
}

//! Method to get name
string Device::name () { return(name_); }

//! Method to get address
uint Device::address() { return(address_); }

//! Method to set variable
void Device::set ( string variable, string value ) {
   return(variables_[variable]->set(value));
}

//! Method to get variable
string Device::get ( string variable ) {
   return(variables_[variable]->get());
}

//! Return a vector of registers
map<string,Register *> Device::registers() {
   return(registers_);
}

//! Method to read variables from registers
string Device::read() {
   stringstream tmp;
   map<string,Variable*>::iterator iter;

   tmp << "<" << name_ << " address=\"" << dec << address_ << "\">" << endl;

   for (iter=variables_.begin(); iter != variables_.end(); ++iter) 
      tmp << "<" << iter->first << ">" << iter->second->get() << "</" << iter->first << ">" << endl;

   tmp << "</" << name_ << ">" << endl;
   return(tmp.str());
}

//! Method to write variables to registers
void Device::write( string xml ) {
   if ( xml != "" ) {

      inDevice_ = false;
      str_      = "";

      xmlCleanupParser();
      ctxt_ = xmlCreatePushParserCtxt(&xmlHandler_,this,xml.c_str(),xml.size(),NULL);
      xmlFreeParserCtxt(ctxt_);
      xmlCleanupParser();
   }
}

// XML Callback Functions
void Device::startElement ( void *userData, const xmlChar* name, const xmlChar** attrs ) {
   char *attrName;
   char *attrValue;
   uint x;
   uint addr;
   bool addrValid;
   string gName;
   gName.append((char *)name);

   // User data
   Device *dev = (Device *)userData;

   // Extract attributes
   addrValid = false;
   x = 0;
   while ( attrs != NULL && attrs[x] != NULL && attrs[x+1] != NULL ) {
      attrName  = (char *)attrs[x];
      attrValue = (char *)attrs[x+1];
      x += 2;

      // Address value
      if ( strcmp(attrName,"address") == 0 ) {
         addrValid = true;
         addr = (uint)atoi(attrValue);
      }
   }

   // Entering device config, address match or no address
   if ( gName == dev->name() && ( addr == dev->address() || !addrValid ) ) dev->inDevice_ = true;
   dev->str_ = "";
}

void Device::endElement ( void *userData, const xmlChar* name ) {
   string gName;
   gName.append((char *)name);

   // User data
   Device *dev = (Device *)userData;

   // Tag does not match name
   if ( gName != dev->name() ) dev->set(gName,dev->str_);
   dev->str_ = "";
}

void Device::characters ( void *userData, const xmlChar* ch, int len ) {
   ((Device*)userData)->str_.append((char *)ch,len);
}

