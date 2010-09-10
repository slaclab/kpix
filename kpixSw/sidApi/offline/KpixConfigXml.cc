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

#include "KpixConfigXml.h"
#include <TXMLAttr.h>
#include <TFile.h>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
using namespace std;

ClassImp(KpixConfigXml)

// Constructor
KpixConfigXml::KpixConfigXml () {

   currVar[0] = '\0';
   currAsic = currChannel = currBucket = -1;
   fpga = NULL;
   asic = NULL;
   asicCnt = 0;
   xmlWriteEn = 0;
   checkingEn = 1;
   clkPrd = 50;
   rstOnTime =700;
   rstOffTime = 120000;
   leakageNullOff = 200;
   offsetNullOff = 100500;
   threshOff = 101500;
   trigInhibitOff = 0;
   pwrUpOn = 900;
   deselSequence = 6900;
   bunchClkDly = 467500;
   digitizationDly = 10000;
   bunchClockCount = 2890;
   rstThreshA = 0;
   trigThreshA = 0;
   rstThreshB = 0;
   trigThreshB = 0;
   calCount = 4;
   cal0Delay = 1500;
   cal1Delay = cal2Delay = cal3Delay = 200;
}

// Set Defaults by parsing the xml file
void KpixConfigXml::OnStartElement ( const char *name, const TList *attributes ) {

   TXMLAttr *attr;
   strcpy (currVar, name ); // Store the variable
   
   TIter next (attributes);
   while ((attr = (TXMLAttr*) next())) {
      
      if ( !strcmp(name, "asic") && !strcmp(attr->GetName(), "id") ) 
	 { currAsic = atoi( attr->GetValue () ); } // Handle the ASIC
      else if ( !strcmp(name, "channel") && !strcmp(attr->GetName(), "id") ) 
	 { currChannel = atoi( attr->GetValue () ); } // Store the channel value
      else if ( !strcmp(name, "bucket") && !strcmp(attr->GetName(), "id") ) 
	 { currBucket = atoi( attr->GetValue() ); } // Store the bucket value
      else if ( !strcmp(name, "kpixChanMode") && !strcmp(attr->GetName(), "id") ) 
	 { currChannel = atoi( attr->GetValue () ); } // Store the channel value
      
   }
}

// CLear current values when a tag element ends
void KpixConfigXml::OnEndElement ( const char *name ) { 

   if ( !strcmp(name, "asic") )
      currAsic = -1;
   else if ( !strcmp(name, "channel") || !strcmp(name, "kpixChanMode") )
      currChannel = -1;
   else if ( !strcmp(name, "bucket") )
      currBucket = -1;
   
} 

// Set Defaults by parsing the xml file
void KpixConfigXml::OnCharacters ( const char *value ) {

   int x;
   
   if ( strncmp(value, "\n", 1) != 0 ) { // Ignores carriage returns
      // FPGA defaults
      if ( !strcmp(currVar, "clkPrd") )
         fpga->setClockPeriod(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "clkPrdDig") )
         fpga->setClockPeriodDig(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "clkPrdRd") )
         fpga->setClockPeriodRead(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "clkPrdIdle") )
         fpga->setClockPeriodIdle(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "kpixVer") )
         fpga->setKpixVer(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "bncSrcA") ) {
         if (strcmp(value, "0") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)0, xmlWriteEn);
         else if (strcmp(value, "1") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)1, xmlWriteEn);
         else if (strcmp(value, "2") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)2, xmlWriteEn);
         else if (strcmp(value, "3") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)3, xmlWriteEn);
         else if (strcmp(value, "4") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)4, xmlWriteEn);
         else if (strcmp(value, "5") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)5, xmlWriteEn);
         else if (strcmp(value, "6") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)6, xmlWriteEn);
         else if (strcmp(value, "7") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)7, xmlWriteEn);
         else if (strcmp(value, "8") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)8, xmlWriteEn);
         else if (strcmp(value, "9") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)9, xmlWriteEn);
         else if (strcmp(value, "10") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)10, xmlWriteEn);
         else if (strcmp(value, "11") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)11, xmlWriteEn);
         else if (strcmp(value, "12") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)12, xmlWriteEn);
         else if (strcmp(value, "13") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)13, xmlWriteEn);
         else if (strcmp(value, "14") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)14, xmlWriteEn);
         else if (strcmp(value, "15") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)15, xmlWriteEn);
         else if (strcmp(value, "16") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)16, xmlWriteEn);
         else if (strcmp(value, "17") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)17, xmlWriteEn);
         else if (strcmp(value, "18") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)18, xmlWriteEn);
         else if (strcmp(value, "19") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)19, xmlWriteEn);
         else if (strcmp(value, "20") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)20, xmlWriteEn);
         else if (strcmp(value, "21") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)21, xmlWriteEn);
         else if (strcmp(value, "22") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)22, xmlWriteEn);
         else if (strcmp(value, "23") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)23, xmlWriteEn);
         else if (strcmp(value, "24") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)24, xmlWriteEn);
         else if (strcmp(value, "25") == 0)
            fpga->setBncSourceA((KpixFpga::KpixBncOut)25, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "bncSrcB") ) {
         if (strcmp(value, "0") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)0, xmlWriteEn);
         else if (strcmp(value, "1") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)1, xmlWriteEn);
         else if (strcmp(value, "2") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)2, xmlWriteEn);
         else if (strcmp(value, "3") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)3, xmlWriteEn);
         else if (strcmp(value, "4") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)4, xmlWriteEn);
         else if (strcmp(value, "5") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)5, xmlWriteEn);
         else if (strcmp(value, "6") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)6, xmlWriteEn);
         else if (strcmp(value, "7") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)7, xmlWriteEn);
         else if (strcmp(value, "8") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)8, xmlWriteEn);
         else if (strcmp(value, "9") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)9, xmlWriteEn);
         else if (strcmp(value, "10") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)10, xmlWriteEn);
         else if (strcmp(value, "11") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)11, xmlWriteEn);
         else if (strcmp(value, "12") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)12, xmlWriteEn);
         else if (strcmp(value, "13") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)13, xmlWriteEn);
         else if (strcmp(value, "14") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)14, xmlWriteEn);
         else if (strcmp(value, "15") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)15, xmlWriteEn);
         else if (strcmp(value, "16") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)16, xmlWriteEn);
         else if (strcmp(value, "17") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)17, xmlWriteEn);
         else if (strcmp(value, "18") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)18, xmlWriteEn);
         else if (strcmp(value, "19") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)19, xmlWriteEn);
         else if (strcmp(value, "20") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)20, xmlWriteEn);
         else if (strcmp(value, "21") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)21, xmlWriteEn);
         else if (strcmp(value, "22") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)22, xmlWriteEn);
         else if (strcmp(value, "23") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)23, xmlWriteEn);
         else if (strcmp(value, "24") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)24, xmlWriteEn);
         else if (strcmp(value, "25") == 0)
            fpga->setBncSourceB((KpixFpga::KpixBncOut)25, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "dropData") )
         fpga->setDropData(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "rawData") )
         fpga->setRawData(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "disKpixA") )
         fpga->setDisKpixA(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "disKpixB") )
         fpga->setDisKpixB(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "disKpixC") )
         fpga->setDisKpixC(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "disKpixD") )
         fpga->setDisKpixD(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "runSrc") ) {
         if (strcmp(value, "0") == 0)
            fpga->setExtRunSource((KpixFpga::KpixExtRun)0, xmlWriteEn);
         else if (strcmp(value, "1") == 0)
            fpga->setExtRunSource((KpixFpga::KpixExtRun)1, xmlWriteEn);
         else if (strcmp(value, "2") == 0)
            fpga->setExtRunSource((KpixFpga::KpixExtRun)2, xmlWriteEn);
         else if (strcmp(value, "3") == 0)
            fpga->setExtRunSource((KpixFpga::KpixExtRun)3, xmlWriteEn);
         else if (strcmp(value, "4") == 0)
            fpga->setExtRunSource((KpixFpga::KpixExtRun)4, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "runDly") )
         fpga->setExtRunDelay(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "runType") )
         fpga->setExtRunType(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "extRec") ) {
         if (strcmp(value, "0") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)0, xmlWriteEn);
         else if (strcmp(value, "1") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)1, xmlWriteEn);
         else if (strcmp(value, "2") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)2, xmlWriteEn);
         else if (strcmp(value, "3") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)3, xmlWriteEn);
         else if (strcmp(value, "4") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)4, xmlWriteEn);
         else if (strcmp(value, "5") == 0)
            fpga->setExtRecord((KpixFpga::KpixExtRec)5, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "trigEn") )
         fpga->setTrigEnable(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "trigExpand") )
         fpga->setTrigExpand(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "trigSrc") ) {
         if (strcmp(value, "0") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)0, xmlWriteEn);
         else if (strcmp(value, "1") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)1, xmlWriteEn);
         else if (strcmp(value, "2") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)2, xmlWriteEn);
         else if (strcmp(value, "3") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)3, xmlWriteEn);
         else if (strcmp(value, "4") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)4, xmlWriteEn);
         else if (strcmp(value, "5") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)5, xmlWriteEn);
         else if (strcmp(value, "6") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)6, xmlWriteEn);
         else if (strcmp(value, "7") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)7, xmlWriteEn);
         else if (strcmp(value, "8") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)8, xmlWriteEn);
         else if (strcmp(value, "9") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)9, xmlWriteEn);
         else if (strcmp(value, "10") == 0)
            fpga->setTrigSource((KpixFpga::KpixTrigSource)10, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "calDly") )
         fpga->setCalDelay(atoi(value), xmlWriteEn);
      // ASIC defaults
      else if ( !strcmp(currVar, "cfgTestData") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgTestData( atoi(value), false );
      else if ( !strcmp(currVar, "cfgAutoReadDis") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgAutoReadDis ( atoi(value), false );
      else if ( !strcmp(currVar, "cfgForceTemp") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgForceTemp ( atoi(value), false );
      else if ( !strcmp(currVar, "cfgDisableTemp") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgDisableTemp ( atoi(value), false );
      else if ( !strcmp(currVar, "cfgAutoStatus") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgAutoStatus ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlCalibHigh") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlCalibHigh ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlCalDacInt") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlCalDacInt ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlForceLowGain") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlForceLowGain ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlLeakNullDis") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlLeakNullDis ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlDoubleGain") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDoubleGain ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlNearNeighbor") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlNearNeighbor ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlPosPixel") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlPosPixel ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlDisPerRst") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDisPerRst ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlEnDcRst") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlEnDcRst ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlCalSrcCore") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlCalSrcCore ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlTrigSrcCore") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlTrigSrcCore ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlShortIntEn") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlShortIntEn ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlDisPwrCycle") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDisPwrCycle ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlFeCurr") )
         for(x=0; x<asicCnt; x++) {
            if (strcmp(value,"0") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)0, xmlWriteEn );
            else if (strcmp(value,"1") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)1, xmlWriteEn );
            else if (strcmp(value,"2") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)2, xmlWriteEn );
            else if (strcmp(value,"3") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)3, xmlWriteEn );
            else if (strcmp(value,"4") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)4, xmlWriteEn );
            else if (strcmp(value,"5") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)5, xmlWriteEn );
            else if (strcmp(value,"6") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)6, xmlWriteEn );
            else if (strcmp(value,"7") == 0)
               asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)7, xmlWriteEn );
            }
      else if ( !strcmp(currVar, "cntrlHoldTime") )
         for(x=0; x<asicCnt; x++)  {
            if (strcmp(value,"0") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)0, xmlWriteEn );
            else if (strcmp(value,"1") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)1, xmlWriteEn );
            else if (strcmp(value,"2") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)2, xmlWriteEn );
            else if (strcmp(value,"3") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)3, xmlWriteEn );
            else if (strcmp(value,"4") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)4, xmlWriteEn );
            else if (strcmp(value,"5") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)5, xmlWriteEn );
            else if (strcmp(value,"6") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)6, xmlWriteEn );
            else if (strcmp(value,"7") == 0)
               asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)7, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "clkPrd") )
         for(x=0; x<asicCnt; x++) {
            clkPrd = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "rstOnTime") )
         for(x=0; x<asicCnt; x++) {
            rstOnTime = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "rstOffTime") )
         for(x=0; x<asicCnt; x++) {
            rstOffTime = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "leakageNullOff") )
         for(x=0; x<asicCnt; x++) {
            leakageNullOff = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "offsetNullOff") )
         for(x=0; x<asicCnt; x++) {
            offsetNullOff = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "threshOff") )
         for(x=0; x<asicCnt; x++) {
            threshOff = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "trigInhibitOff") )
         for(x=0; x<asicCnt; x++) {
            trigInhibitOff = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "pwrUpOn") )
         for(x=0; x<asicCnt; x++) {
            pwrUpOn = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "deselSequence") )
         for(x=0; x<asicCnt; x++) {
            deselSequence = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "bunchClkDly") )
         for(x=0; x<asicCnt; x++) {
            bunchClkDly = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "digitizationDly") )
         for(x=0; x<asicCnt; x++) {
            digitizationDly = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "bunchClockCount") )
         for(x=0; x<asicCnt; x++) {
            bunchClockCount = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "checkingEn") )
         for(x=0; x<asicCnt; x++) {
            checkingEn = atoi(value);
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff, threshOff, trigInhibitOff, 
            pwrUpOn, deselSequence, bunchClkDly, digitizationDly, bunchClockCount, checkingEn, xmlWriteEn );
         }
      else if ( !strcmp(currVar, "dacCalib") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacCalib ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "dacRampThresh") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacRampThresh ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "dacRangeThresh") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacRangeThresh ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "dacDefaultAnalog") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacDefaultAnalog ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "dacEventThreshRef") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacEventThreshRef ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "dacShaperBias") )
         for(x=0; x<asicCnt; x++) asic[x]->setDacShaperBias ( (unsigned char)atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "rstThreshA") )
         for(x=0; x<asicCnt; x++) {
            rstThreshA = atoi(value);
            asic[x]->setDacThreshRangeA ( (unsigned char)rstThreshA, (unsigned char)trigThreshA, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "trigThreshA") )
         for(x=0; x<asicCnt; x++) {
            trigThreshA = atoi(value);
            asic[x]->setDacThreshRangeA ( (unsigned char)rstThreshA, (unsigned char)trigThreshA, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "rstThreshB") )
         for(x=0; x<asicCnt; x++) {
            rstThreshB = atoi(value);
            asic[x]->setDacThreshRangeB ( (unsigned char)rstThreshB, (unsigned char)trigThreshB, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "trigThreshB") )
         for(x=0; x<asicCnt; x++) {
            trigThreshB = atoi(value);
            asic[x]->setDacThreshRangeA ( (unsigned char)rstThreshB, (unsigned char)trigThreshB, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "calCount") )
         for(x=0; x<asicCnt; x++) {
            calCount = atoi(value);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "cal0Delay") )
         for(x=0; x<asicCnt; x++) {
            cal0Delay = atoi(value);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "cal1Delay") )
         for(x=0; x<asicCnt; x++) {
            cal1Delay = atoi(value);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "cal2Delay") )
         for(x=0; x<asicCnt; x++) {
            cal2Delay = atoi(value);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "cal3Delay") )
         for(x=0; x<asicCnt; x++) {
            cal3Delay = atoi(value);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "kpixChanMode") && currChannel == -1 && currAsic == -1 )
         for(x=0; x<asicCnt; x++) {
            KpixAsic::KpixChanMode modes[1024];
            for (int i=0; i < 1024; i++) modes[i] = (KpixAsic::KpixChanMode)atoi(value); 
            asic[x]->setChannelModeArray ( modes, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "kpixChanMode") && currChannel != -1 && currAsic == -1 )
         for(x=0; x<asicCnt; x++) {
            KpixAsic::KpixChanMode modes[1024];
            asic[x]->getChannelModeArray ( modes, 0 );
            modes[currChannel] = (KpixAsic::KpixChanMode)atoi(value); 
            asic[x]->setChannelModeArray ( modes, xmlWriteEn);
         }
      else if ( !strcmp(currVar, "kpixChanMode") && currChannel != -1 && currAsic != -1 )
         for(x=0; x<asicCnt; x++) {
            if( asic[x]->getAddress() == currAsic ) {
               KpixAsic::KpixChanMode modes[1024];
               asic[x]->getChannelModeArray ( modes, 0 );
               modes[currChannel] = (KpixAsic::KpixChanMode)atoi(value); 
               asic[x]->setChannelModeArray ( modes, xmlWriteEn);
            }
         }
   }
}
// Reads and stores the values for FPGA
void KpixConfigXml::readConfig ( char *xmlFile, KpixFpga *kpixFpga, KpixAsic **kpixAsic, int asicCount, int writeEn ) {

   fpga = kpixFpga;
   asic = kpixAsic;
   asicCnt = asicCount;
   xmlWriteEn = writeEn;

   ParseFile ( xmlFile );
}
void KpixConfigXml::readConfig ( char *xmlFile, KpixFpga *kpixFpga, int writeEn ) {

   fpga = kpixFpga;
   asic = NULL;
   asicCnt = 0;
   xmlWriteEn = writeEn;

   ParseFile ( xmlFile );
}
void KpixConfigXml::readConfig ( char *xmlFile, KpixAsic **kpixAsic, int asicCount, int writeEn ) {

   fpga = NULL;
   asic = kpixAsic;
   asicCnt = asicCount;
   xmlWriteEn = writeEn;

   ParseFile ( xmlFile );
}

void KpixConfigXml::writeConfig ( KpixFpga *fpga, KpixAsic **asic, int asicCount) {

   int x;
   char *xmlFile = getenv("KPIX_BASE_DIR");
   char temp;
   sprintf (xmlFile, "%s/settings.xml", xmlFile);
   ofstream xml;
   xml.open(xmlFile);
   if ( ! xml.is_open() ) cout << "Error opening " << xmlFile << "\n";
   xml << "<dafault_data>\n";
   
   if (fpga != NULL) {
      xml << "   <kpix>\n";
      xml << "      <clkPrd>" << fpga->getClockPeriod(0) << "</clkPrd>\n";
      xml << "      <clkPrdDig>" << fpga->getClockPeriodDig(0) << "</clkPrdDig>\n";
      xml << "      <clkPrdRd>" << fpga->getClockPeriodRead(0) << "</clkPrdRd>\n";
      xml << "      <clkPrdIdle>" << fpga->getClockPeriodIdle(0) << "</clkPrdIdle>\n";
      xml << "      <kpixVer>" << fpga->getKpixVer(0) << "</kpixVer>\n";
      xml << "      <bncSrcA>" << fpga->getBncSourceA(0) << "</bncSrcA>\n";
      xml << "      <bncSrcB>" << fpga->getBncSourceB(0) << "</bncSrcB>\n";
      xml << "      <dropData>" << fpga->getDropData(0) << "</dropData>\n";
      xml << "      <rawData>" << fpga->getRawData(0) << "</rawData>\n";
      xml << "      <disKpixA>" << fpga->getDisKpixA(0) << "</disKpixA>\n";
      xml << "      <disKpixB>" << fpga->getDisKpixB(0) << "</disKpixB>\n";
      xml << "      <disKpixC>" << fpga->getDisKpixC(0) << "</disKpixC>\n";
      xml << "      <disKpixD>" << fpga->getDisKpixD(0) << "</disKpixD>\n";
      xml << "      <runSrc>" << fpga->getExtRunSource(0) << "</runSrc>\n";
      xml << "      <runDly>" << fpga->getExtRunDelay(0) << "</runDly>\n";
      xml << "      <runType>" << fpga->getExtRunType(0) << "</runType>\n";
      xml << "      <extRec>" << fpga->getExtRecord(0) << "</extRec>\n";
      temp = (char)fpga->getTrigEnable(0);
      xml << "      <trigEn>" << atoi((const char*)&temp) << "</trigEn>\n";
      temp = (char)fpga->getTrigExpand(0);
      xml << "      <trigExpand>" << atoi((const char*)&temp) << "</trigExpand>\n";
      xml << "      <trigSrc>" << fpga->getTrigSource(0) << "</trigSrc>\n";
      temp = (char)fpga->getCalDelay(0);
      xml << "      <calDly>" << atoi((const char*)&temp) << "</calDly>\n";
      xml << "      </kpix>\n";
   }
   if (asic != NULL) {
      xml << "   <asic>\n";
      xml << "      <cfgTstData>" << asic[0]->getCfgTestData(0) << "</cfgTstData>\n";
      xml << "      <cfgAutoReadDis>" << asic[0]->getCfgAutoReadDis(0) << "</cfgAutoReadDis>\n";
      xml << "      <cfgForceTemp>" << asic[0]->getCfgForceTemp(0) << "</cfgForceTemp>\n";
      xml << "      <cfgDisableTemp>" << asic[0]->getCfgDisableTemp(0) << "</cfgDisableTemp>\n";
      xml << "      <cfgAutoStatus>" << asic[0]->getCfgAutoStatus(0) << "</cfgAutoStatus>\n";
      xml << "      <cntrlCalibHigh>" << asic[0]->getCntrlCalibHigh(0) << "</cntrlCalibHigh>\n";
      xml << "      <cntrlCalDacInt>" << asic[0]->getCntrlCalDacInt(0) << "</cntrlCalDacInt>\n";
      xml << "      <cntrlForceLowGain>" << asic[0]->getCntrlForceLowGain(0) << "</cntrlForceLowGain>\n";
      xml << "      <cntrlLeakNullDis>" << asic[0]->getCntrlLeakNullDis(0) << "</cntrlLeakNullDis>\n";
      xml << "      <cntrlDoubleGain>" << asic[0]->getCntrlDoubleGain(0) << "</cntrlDoubleGain>\n";
      xml << "      <cntrlNearNeighbor>" << asic[0]->getCntrlNearNeighbor(0) << "</cntrlNearNeighbor>\n";
      xml << "      <cntrlPosPixel>" << asic[0]->getCntrlPosPixel(0) << "</cntrlPosPixel>\n";
      xml << "      <cntrlDisPerRst>" << asic[0]->getCntrlDisPerRst(0) << "</cntrlDisPerRst>\n";
      xml << "      <cntrlEnDcRst>" << asic[0]->getCntrlEnDcRst(0) << "</cntrlEnDcRst>\n";
      xml << "      <cntrlCalSrcCore>" << asic[0]->getCntrlCalSrcCore(0) << "</cntrlCalSrcCore>\n";
      xml << "      <cntrlTrigSrcCore>" << asic[0]->getCntrlTrigSrcCore(0) << "</cntrlTrigSrcCore>\n";
      xml << "      <cntrlShortIntEn>" << asic[0]->getCntrlShortIntEn(0) << "</cntrlShortIntEn>\n";
      xml << "      <cntrlDisPwrCycle>" << asic[0]->getCntrlDisPwrCycle(0) << "</cntrlDisPwrCycle>\n";
      xml << "      <cntrlFeCurr>" << asic[0]->getCntrlFeCurr(0) << "</cntrlFeCurr>\n";
      xml << "      <cntrlHldTime>" << asic[0]->getCntrlHoldTime(0) << "</cntrlHldTime>\n";
      asic[0]->getTiming ( &clkPrd, &rstOnTime, &rstOffTime, &leakageNullOff, &offsetNullOff,
          &threshOff, &trigInhibitOff, &pwrUpOn, &deselSequence, &bunchClkDly, &digitizationDly, &bunchClockCount,0);
      xml << "      <clkPrd>" << clkPrd << "</clkPrd>\n";
      xml << "      <rstOnTime>" << rstOnTime << "</rstOnTime>\n";
      xml << "      <rstOffTime>" << rstOffTime << "</rstOffTime>\n";
      xml << "      <leakageNullOff>" << leakageNullOff << "</leakageNullOff>\n";
      xml << "      <offsetNullOff>" << offsetNullOff << "</offsetNullOff>\n";
      xml << "      <threshOff>" << threshOff << "</threshOff>\n";
      xml << "      <trigInhibitOff>" << trigInhibitOff << "</trigInhibitOff>\n";
      xml << "      <pwrUpOn>" << pwrUpOn << "</pwrUpOn>\n";
      xml << "      <deselSequence>" << deselSequence << "</deselSequence>\n";
      xml << "      <bunchClkDly>" << bunchClkDly << "</bunchClkDly>\n";
      xml << "      <digitizationDly>" << digitizationDly << "</digitizationDly>\n";
      xml << "      <bunchClockCount>" << bunchClockCount << "</bunchClockCount>\n";
      temp = (char)asic[0]->getDacCalib(0);
      xml << "      <dacCalib>" << atoi((const char*)&temp) << "</dacCalib>\n";
      temp = (char)asic[0]->getDacRampThresh(0);
      xml << "      <dacRampThresh>" << atoi((const char*)&temp) << "</dacRampThresh>\n";
      temp = (char)asic[0]->getDacRangeThresh(0);
      xml << "      <dacRangeThresh>" << atoi((const char*)&temp) << "</dacRangeThresh>\n";
      temp = (char)asic[0]->getDacDefaultAnalog(0);
      xml << "      <dacDefaultAnalog>" << atoi((const char*)&temp) << "</dacDefaultAnalog>\n";
      temp = (char)asic[0]->getDacEventThreshRef(0);
      xml << "      <dacEventThreshRef>" << atoi((const char*)&temp) << "</dacEventThreshRef>\n";
      temp = (char)asic[0]->getDacShaperBias(0);
      xml << "      <dacShaperBias>" << atoi((const char*)&temp) << "</dacShaperBias>\n";
      unsigned char *rt, *tt;
      rt = new unsigned char;
      tt = new unsigned char;
      asic[0]->getDacThreshRangeA ( rt, tt, 0);
      xml << "      <rstThreshA>" << atoi((const char*)rt) << "</rstThreshA>\n";
      xml << "      <trigThreshA>" << atoi((const char*)tt) << "</trigThreshA>\n";
      asic[0]->getDacThreshRangeB ( rt, tt, 0);
      xml << "      <rstThreshB>" << atoi((const char*)rt) << "</rstThreshB>\n";
      xml << "      <trigThreshB>" << atoi((const char*)tt) << "</trigThreshB>\n";
      asic[0]->getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, 0);
      xml << "      <calCount>" << calCount << "</calCount>\n";
      xml << "      <cal0Delay>" << cal0Delay << "</cal0Delay>\n";
      xml << "      <cal1Delay>" << cal1Delay << "</cal1Delay>\n";
      xml << "      <cal2Delay>" << cal2Delay << "</cal2Delay>\n";
      xml << "      <cal3Delay>" << cal3Delay << "</cal3Delay>\n";
      KpixAsic::KpixChanMode modes[1024];
      asic[0]->getChannelModeArray ( modes, 0 );
      xml << "      <kpixChanMode>" << modes[0] << "</kpixChanMode>\n";
      for (x=1; x<1024; x++) 
         if (modes[x] != modes[0])
            xml << "      <kpixChanMode id=\""<< x <<"\">" << modes[x] << "</kpixChanMode>\n";
      xml << "   </asic>\n";
   
      for (x=0; x < asicCount; x++) {
         KpixAsic::KpixChanMode modesX[1024];
         asic[x]->getChannelModeArray ( modesX, 0 );
         for (int i=0; i<1024; i++) 
         if (modesX[i] != modes[i]) {
            xml << "   <asic id=\"" << asic[x]->getAddress() << "\">\n";
            xml << "      <kpixChanMode id=\""<< i <<"\">" << modesX[i] << "</kpixChanMode>\n";
            xml << "   </asic>\n";
         }
      }
   }
   xml << "</default_data>\n";
   xml.close();
}
