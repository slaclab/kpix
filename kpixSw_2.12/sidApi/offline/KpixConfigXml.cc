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
#include "KpixFpga.h"
#include "KpixAsic.h"
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
   currVar[0]  = '\0';
   currAsic    = -1;
   currChannel = -1;
   fpga        = NULL;
   asic        = NULL;
   asicCnt     = 0;
   xmlWriteEn  = 0;
}

// Set Defaults by parsing the xml file
void KpixConfigXml::OnStartElement ( const char *name, const TList *attributes ) {

   TXMLAttr     *attr;
   unsigned int tmpPrd;
   unsigned int x;
   int          id;

   strcpy (currVar, name ); // Store the variable

   // Find id
   id = -1;
   TIter next (attributes);
   while ((attr = (TXMLAttr*) next())) {
      if ( !strcmp(attr->GetName(), "id") ) id = atoi( attr->GetValue () );
   }
     
   // Start of ASIC
   if ( !strcmp(name, "asic") ) {
      currAsic = id;

      if ( currAsic == -1 ) {
         asic[0]->getTiming ( &tmpPrd, &rstOnTime, &rstOffTime, &leakageNullOff, &offsetNullOff,
                              &threshOff, &trigInhibitOff, &pwrUpOn, &deselSequence, &bunchClkDly, 
                              &digitizationDly, &bunchClockCount,0);
         asic[0]->getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, 0);
         asic[0]->getDacThreshRangeA ( &rstThreshA, &trigThreshA, 0);
         asic[0]->getDacThreshRangeB ( &rstThreshB, &trigThreshB, 0);
         asic[0]->getChannelModeArray ( modes, 0 );
      }
      else for ( x=0; x < asicCnt; x++ ) {
         if ( asic[x]->getAddress() == currAsic ) {
            asic[x]->getTiming ( &clkPrd, &rstOnTime, &rstOffTime, &leakageNullOff, &offsetNullOff,
                                 &threshOff, &trigInhibitOff, &pwrUpOn, &deselSequence, &bunchClkDly, 
                                 &digitizationDly, &bunchClockCount,0);
            asic[x]->getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, 0);
            asic[x]->getDacThreshRangeA ( &rstThreshA, &trigThreshA, 0);
            asic[x]->getDacThreshRangeB ( &rstThreshB, &trigThreshB, 0);
            asic[x]->getChannelModeArray ( modes, 0 );
         }
      }
   }
   else if ( !strcmp(name, "kpixChanMode") ) currChannel = id;
}

// CLear current values when a tag element ends
void KpixConfigXml::OnEndElement ( const char *name ) { 
   unsigned int x;

   if ( !strcmp(name, "asic")) {
      for (x=0; x < asicCnt; x++) {
         if ( currAsic == -1 || asic[x]->getAddress() == currAsic ) {
            asic[x]->setTiming ( clkPrd, rstOnTime, rstOffTime, leakageNullOff, offsetNullOff,
                                 threshOff, trigInhibitOff, pwrUpOn, deselSequence, bunchClkDly, 
                                 digitizationDly, bunchClockCount,true,xmlWriteEn,0);
            asic[x]->setCalibTime ( calCount, cal0Delay, cal1Delay, cal2Delay, cal3Delay, xmlWriteEn);
            asic[x]->setDacThreshRangeA ( rstThreshA, trigThreshA, xmlWriteEn);
            asic[x]->setDacThreshRangeB ( rstThreshB, trigThreshB, xmlWriteEn);
            asic[x]->setChannelModeArray ( modes, xmlWriteEn );
         }
      }
      currAsic = -1;
   }
   else if ( !strcmp(name, "kpixChanMode") ) currChannel = -1;
   strcpy (currVar, "" );
} 

// Set Defaults by parsing the xml file
void KpixConfigXml::OnCharacters ( const char *value ) {
   unsigned int x;

   if ( strncmp(value, "\n", 1) != 0 ) { // Ignores carriage returns

      // FPGA defaults
      if ( !strcmp(currVar, "clkPrd") ) {
         clkPrd = atoi(value);
         fpga->setClockPeriod(clkPrd, xmlWriteEn);
      }
      else if ( !strcmp(currVar, "clkPrdDig") )
         fpga->setClockPeriodDig(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "clkPrdRd") )
         fpga->setClockPeriodRead(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "clkPrdIdle") )
         fpga->setClockPeriodIdle(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "bncSrcA") ) 
         fpga->setBncSourceA((KpixFpga::KpixBncOut)(atoi(value)), xmlWriteEn);
      else if ( !strcmp(currVar, "bncSrcB") ) 
         fpga->setBncSourceB((KpixFpga::KpixBncOut)(atoi(value)), xmlWriteEn);
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
      else if ( !strcmp(currVar, "runSrc") ) 
         fpga->setExtRunSource((KpixFpga::KpixExtRun)(atoi(value)), xmlWriteEn);
      else if ( !strcmp(currVar, "runDly") )
         fpga->setExtRunDelay(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "runType") )
         fpga->setExtRunType(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "extRec") ) 
         fpga->setExtRecord((KpixFpga::KpixExtRec)(atoi(value)), xmlWriteEn);
      else if ( !strcmp(currVar, "trigEn") )
         fpga->setTrigEnable(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "trigExpand") )
         fpga->setTrigExpand(atoi(value), xmlWriteEn);
      else if ( !strcmp(currVar, "trigSrc") ) 
         fpga->setTrigSource((KpixFpga::KpixTrigSource)(atoi(value)), xmlWriteEn);
      else if ( !strcmp(currVar, "calDly") )
         fpga->setCalDelay(atoi(value), xmlWriteEn);

      // ASIC defaults
      else if ( !strcmp(currVar, "cfgTestData") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgTestData( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cfgAutoReadDis") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgAutoReadDis ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cfgForceTemp") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgForceTemp ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cfgDisableTemp") )
         for(x=0; x<asicCnt; x++) asic[x]->setCfgDisableTemp ( atoi(value), xmlWriteEn );
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

      else if ( !strcmp(currVar, "cntrlPosPixel") ) {
         for(x=0; x<asicCnt; x++) {
            if ( currAsic == -1 || asic[x]->getAddress() == currAsic ) 
               asic[x]->setCntrlPosPixel ( atoi(value), xmlWriteEn );
         }
      }

      else if ( !strcmp(currVar, "cntrlDisPerRst") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDisPerRst ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlEnDcRst") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlEnDcRst ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlCalSrc") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlCalSrc ( (KpixAsic::KpixCalTrigSrc)(atoi(value)), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlTrigSrc") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlTrigSrc ( (KpixAsic::KpixCalTrigSrc)(atoi(value)), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlShortIntEn") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlShortIntEn ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlDisPwrCycle") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDisPwrCycle ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlFeCurr") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlFeCurr ( (KpixAsic::KpixFeCurr)(atoi(value)), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlDiffTime") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlDiffTime ( (KpixAsic::KpixDiffTime)(atoi(value)), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlTrigDisable") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlTrigDisable ( atoi(value), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlMonSrc") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlMonSrc ( (KpixAsic::KpixMonSrc)(atoi(value)), xmlWriteEn );
      else if ( !strcmp(currVar, "cntrlHoldTime") )
         for(x=0; x<asicCnt; x++) asic[x]->setCntrlHoldTime ( (KpixAsic::KpixHoldTime)(atoi(value)), xmlWriteEn );
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

      // Store timings for later
      else if ( !strcmp(currVar, "rstOnTime") ) rstOnTime = atoi(value);
      else if ( !strcmp(currVar, "rstOffTime") ) rstOffTime = atoi(value);
      else if ( !strcmp(currVar, "leakageNullOff") ) leakageNullOff = atoi(value);
      else if ( !strcmp(currVar, "offsetNullOff") ) offsetNullOff = atoi(value);
      else if ( !strcmp(currVar, "threshOff") ) threshOff = atoi(value);
      else if ( !strcmp(currVar, "trigInhibitOff") ) trigInhibitOff = atoi(value);
      else if ( !strcmp(currVar, "pwrUpOn") ) pwrUpOn = atoi(value);
      else if ( !strcmp(currVar, "deselSequence") ) deselSequence = atoi(value);
      else if ( !strcmp(currVar, "bunchClkDly") ) bunchClkDly = atoi(value);
      else if ( !strcmp(currVar, "digitizationDly") ) digitizationDly = atoi(value);
      else if ( !strcmp(currVar, "bunchClockCount") ) bunchClockCount = atoi(value);

      // Calibration settings for later
      else if ( !strcmp(currVar, "calCount") ) calCount = atoi(value);
      else if ( !strcmp(currVar, "cal0Delay") ) cal0Delay = atoi(value);
      else if ( !strcmp(currVar, "cal1Delay") ) cal1Delay = atoi(value);
      else if ( !strcmp(currVar, "cal2Delay") ) cal2Delay = atoi(value);
      else if ( !strcmp(currVar, "cal3Delay") ) cal3Delay = atoi(value);

      // Threshold settings for later
      else if ( !strcmp(currVar, "rstThreshA") ) rstThreshA = atoi(value);
      else if ( !strcmp(currVar, "trigThreshA") ) trigThreshA = atoi(value);
      else if ( !strcmp(currVar, "rstThreshB") ) rstThreshB = atoi(value);
      else if ( !strcmp(currVar, "trigThreshB") ) trigThreshB = atoi(value);

      // Channel modes for later
      if ( currChannel == -1 ) for (x=0; x < 1024; x++) modes[x] = (KpixAsic::KpixChanMode)atoi(value); 
      else modes[currChannel] = (KpixAsic::KpixChanMode)atoi(value); 
   }
}
// Reads and stores the values for FPGA
void KpixConfigXml::readConfig ( char *xmlFile, KpixFpga *kpixFpga, KpixAsic **kpixAsic, 
                                 unsigned int asicCount, int writeEn ) {
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
void KpixConfigXml::readConfig ( char *xmlFile, KpixAsic **kpixAsic, unsigned int asicCount, int writeEn ) {
   fpga = NULL;
   asic = kpixAsic;
   asicCnt = asicCount;
   xmlWriteEn = writeEn;
   ParseFile ( xmlFile );
}

void KpixConfigXml::writeConfig ( char *xmlFile, KpixFpga *fpga, KpixAsic **asic, unsigned int asicCount) {
   unsigned int           x;
   ofstream               xml;
   KpixAsic::KpixChanMode modeDef;

   xml.open(xmlFile);
   if ( ! xml.is_open() ) cout << "Error opening " << xmlFile << "\n";
   xml << "<default_config>\n";
   
   if (fpga != NULL) {
      xml << "   <fpga>\n";
      xml << "      <clkPrd>" << fpga->getClockPeriod(0) << "</clkPrd>\n";
      xml << "      <clkPrdDig>" << fpga->getClockPeriodDig(0) << "</clkPrdDig>\n";
      xml << "      <clkPrdRd>" << fpga->getClockPeriodRead(0) << "</clkPrdRd>\n";
      xml << "      <clkPrdIdle>" << fpga->getClockPeriodIdle(0) << "</clkPrdIdle>\n";
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
      xml << "      <trigEn>" << (int)(fpga->getTrigEnable(0)) << "</trigEn>\n";
      xml << "      <trigExpand>" << (int)(fpga->getTrigExpand(0)) << "</trigExpand>\n";
      xml << "      <trigSrc>" << fpga->getTrigSource(0) << "</trigSrc>\n";
      xml << "      <calDly>" << (int)(fpga->getCalDelay(0)) << "</calDly>\n";
      xml << "   </fpga>\n";
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
      xml << "      <cntrlCalSrc>" << asic[0]->getCntrlCalSrc(0) << "</cntrlCalSrc>\n";
      xml << "      <cntrlTrigSrc>" << asic[0]->getCntrlTrigSrc(0) << "</cntrlTrigSrc>\n";
      xml << "      <cntrlShortIntEn>" << asic[0]->getCntrlShortIntEn(0) << "</cntrlShortIntEn>\n";
      xml << "      <cntrlDisPwrCycle>" << asic[0]->getCntrlDisPwrCycle(0) << "</cntrlDisPwrCycle>\n";
      xml << "      <cntrlFeCurr>" << asic[0]->getCntrlFeCurr(0) << "</cntrlFeCurr>\n";
      xml << "      <cntrlDiffTime>" << asic[0]->getCntrlDiffTime(0) << "</cntrlDiffTime>\n";
      xml << "      <cntrlHldTime>" << asic[0]->getCntrlHoldTime(0) << "</cntrlHldTime>\n";
      xml << "      <cntrlTrigDisable>" << asic[0]->getCntrlTrigDisable(0) << "</cntrlTrigDisable>\n";
      xml << "      <cntrlMonSrc>" << asic[0]->getCntrlMonSrc(0) << "</cntrlMonSrc>\n";

      asic[0]->getTiming ( &clkPrd, &rstOnTime, &rstOffTime, &leakageNullOff, &offsetNullOff,
          &threshOff, &trigInhibitOff, &pwrUpOn, &deselSequence, &bunchClkDly, &digitizationDly, &bunchClockCount,0);
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

      xml << "      <dacCalib>" <<  (int)(asic[0]->getDacCalib(0)) << "</dacCalib>\n";
      xml << "      <dacRampThresh>" <<  (int)(asic[0]->getDacRampThresh(0)) << "</dacRampThresh>\n";
      xml << "      <dacRangeThresh>" << (int)(asic[0]->getDacRangeThresh(0)) << "</dacRangeThresh>\n";
      xml << "      <dacDefaultAnalog>" << (int)(asic[0]->getDacDefaultAnalog(0)) << "</dacDefaultAnalog>\n";
      xml << "      <dacEventThreshRef>" <<  (int)(asic[0]->getDacEventThreshRef(0)) << "</dacEventThreshRef>\n";
      xml << "      <dacShaperBias>" << (int)(asic[0]->getDacShaperBias(0)) << "</dacShaperBias>\n";

      asic[0]->getCalibTime ( &calCount, &cal0Delay, &cal1Delay, &cal2Delay, &cal3Delay, 0);
      xml << "      <calCount>" << calCount << "</calCount>\n";
      xml << "      <cal0Delay>" << cal0Delay << "</cal0Delay>\n";
      xml << "      <cal1Delay>" << cal1Delay << "</cal1Delay>\n";
      xml << "      <cal2Delay>" << cal2Delay << "</cal2Delay>\n";
      xml << "      <cal3Delay>" << cal3Delay << "</cal3Delay>\n";

      asic[0]->getDacThreshRangeA ( &rstThreshA, &trigThreshA, 0);
      xml << "      <rstThreshA>" << (int)rstThreshA << "</rstThreshA>\n";
      xml << "      <trigThreshA>" << (int)trigThreshA << "</trigThreshA>\n";

      asic[0]->getDacThreshRangeB ( &rstThreshB, &trigThreshB, 0);
      xml << "      <rstThreshB>" << (int)rstThreshB << "</rstThreshB>\n";
      xml << "      <trigThreshB>" << (int)trigThreshB << "</trigThreshB>\n";

      // Get default channel mode
      asic[0]->getChannelModeArray ( modes, 0 );
      modeDef = modes[0];
      xml << "      <kpixChanMode>" << modeDef << "</kpixChanMode>\n";
      xml << "   </asic>\n";

      // Each ASIC
      for (x=0; x < asicCount; x++) {
         xml << "   <asic id=\"" << asic[x]->getAddress() << "\">\n";
         xml << "      <cntrlPosPixel>" << asic[x]->getCntrlPosPixel(0) << "</cntrlPosPixel>\n";

         asic[x]->getDacThreshRangeA ( &rstThreshA, &trigThreshA, 0);
         xml << "      <rstThreshA>" << (int)rstThreshA << "</rstThreshA>\n";
         xml << "      <trigThreshA>" << (int)trigThreshA << "</trigThreshA>\n";

         asic[x]->getDacThreshRangeB ( &rstThreshB, &trigThreshB, 0);
         xml << "      <rstThreshB>" << (int)rstThreshB << "</rstThreshB>\n";
         xml << "      <trigThreshB>" << (int)trigThreshB << "</trigThreshB>\n";

         asic[x]->getChannelModeArray ( modes, 0 );
         for (x=0; x<1024; x++) {
            if (modes[x] != modeDef) xml << "      <kpixChanMode id=\""<< x <<"\">" << modes[x] << "</kpixChanMode>\n";
         }
         xml << "   </asic>\n";
      }
   }
   xml << "</default_config>\n";
   xml.close();
}
