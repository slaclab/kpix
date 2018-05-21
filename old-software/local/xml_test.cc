//-----------------------------------------------------------------------------
// File          : read_example.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/31/2008
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// Example file to demonstrate reading from a KPIX root file.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/31/2008: created
// 06/22/2009: Added namespace.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <KpixRunRead.h>
#include <KpixCalibRead.h>
#include <KpixFpga.h>
#include <KpixAsic.h>
#include <KpixRunVar.h>
#include <KpixSample.h>
#include <KpixEventVar.h>
#include <TFile.h>
#include <Riostream.h>
#include <TList.h>
#include <TSAXParser.h>
#include <TXMLEngine.h>
#include <TXMLParser.h>
#include <TXMLAttr.h>
using namespace std;

class OurHandler : public TSAXParser {
public:
   OurHandler() { }
   void     OnStartElement(const char*, const TList*);
   void     OnEndElement(const char*);
   void     OnCharacters(const char*);
};

void OurHandler::OnStartElement(const char *name, const TList *attributes)
{
   cout << "<" << name;

   TXMLAttr *attr;

   TIter next(attributes);
   while ((attr = (TXMLAttr*) next())) {
      cout << " " << attr->GetName() << "=\"" << attr->GetValue() << "\"";
   }

   cout  << ">";
}

void OurHandler::OnEndElement(const char *name)
{
   cout << "</" << name << ">";
}

void OurHandler::OnCharacters(const char *characters)
{
   cout << characters;
}


// Process the data
// Pass root file to open as first and only arg.
int main ( int argc, char **argv ) {

   KpixRunRead     *runRead;
   OurHandler     *xmlParser;
   TString         xmlString;

   // Root file is the first and only arg
   if ( argc != 2 ) {
      cout << "Usage: xml_test file.root\n";
      return(1);
   }

   // Attempt to open root file using KpixRunRead class
   // The second arg to the run read file controls debugging.
   try {
      runRead  = new KpixRunRead(argv[1],false);
   } catch ( string error ) {
      cout << "Error opening run file:\n";
      cout << error << "\n";
      return(2);
   }

   // Create XML engine
   xmlString = runRead->getCalibData();
   xmlParser = new OurHandler;
   //xmlParser->ConnectToHandler("CalibData",&xmlParser);
   xmlParser->ParseBuffer(xmlString.Data(),xmlString.Length());

   // Delete the created classes when done
   delete(runRead);
}
