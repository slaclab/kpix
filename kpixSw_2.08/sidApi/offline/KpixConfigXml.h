//-----------------------------------------------------------------------------
// File          : KpixConfigXml.h
// Author        : Raghuveer Ausoori  <ausoori@slac.stanford.edu>
// Created       : 06/30/2010
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// Header file for class that manages the configuration settings. This class is
// used for parsing an XML file and store the values as default for variables in
// KpixFpga and KpixAsic classes. This class can also dump the settings in an
// XML file.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 06/30/2010: created

#include <TSAXParser.h>
#include "KpixAsic.h"

// Forward Declarations
class KpixFpga;

class KpixConfigXml : public TSAXParser {

      // String to store variable names while XML parsing
      char                   currVar[25];
      bool                   xmlWriteEn, checkingEn;
      int                    currAsic, currChannel, currBucket;
      unsigned int           clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff;
      unsigned int           trigInhibitOff, pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount;
      unsigned int           calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay;
      unsigned char          rstThreshA, trigThreshA, rstThreshB, trigThreshB;
      KpixAsic::KpixChanMode modes[1024];

      // Pointer for FPGA class
      KpixFpga *fpga;
 
      // Pointer for ASIC class
      KpixAsic     **asic;  //! Root: Don't stream
      unsigned int asicCnt;

   public:
   
      // Constructor
      KpixConfigXml ();

      // Functions to parse the xml tags 
      void OnStartElement ( const char *name, const TList *attributes );
      void OnEndElement ( const char *name );
      void OnCharacters ( const char *value );
      
      // Functions to set the variables of classes KpixFpga and KpixAsic
      void readConfig ( char *xmlFile, KpixFpga *kpixFpga, KpixAsic **kpixAsic, unsigned int asicCount, int writeEn );
      void readConfig ( char *xmlFile, KpixFpga *kpixFpga, int writeEn );
      void readConfig ( char *xmlFile, KpixAsic **KpixAsic, unsigned int asicCount, int writeEn );
      
      // Function to dump the settings in an XML file
      void writeConfig ( char *xmlFile, KpixFpga *fpga, KpixAsic **asic, unsigned int asicCount);
      
      ClassDef(KpixConfigXml,1)
};

