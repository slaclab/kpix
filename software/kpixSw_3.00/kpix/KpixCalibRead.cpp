//-----------------------------------------------------------------------------
// File          : KpixCalibRead.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 05/31/2012
// Project       : KPIX Control Software
//-----------------------------------------------------------------------------
// Description :
// This class is used to extract calibration constants from an XML file.
//-----------------------------------------------------------------------------
// Copyright (c) 2012 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 05/31/2012: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include "KpixCalibRead.h"
using namespace std;

// Calib Data Class Constructor
// Pass path to calibration data or
KpixCalibRead::KpixCalibRead ( string calibFile ) {
   xmlDocPtr    doc;
   xmlNodePtr   node;
   ifstream     is;
   stringstream buffer;

   asicList_.clear();  

   // Open file
   is.open(calibFile.c_str());
   if ( ! is.is_open() ) cout << "Error opening xml file for read: " << calibFile << endl;
   else {
      buffer.str("");
      buffer << is.rdbuf();
      is.close();

      // Parse string
      doc = xmlReadMemory(buffer.str().c_str(), strlen(buffer.str().c_str()), "config.xml", NULL, 0);
      if (doc != NULL) {

         // get the root element node
         node = xmlDocGetRootElement(doc);

         // Process
         parseXmlLevel(node,0,0,0);

         // Cleanup
         xmlFreeDoc(doc);
      }
   }
   xmlCleanupParser();
   xmlMemoryDump();
}

// Parse XML level
void KpixCalibRead::parseXmlLevel ( xmlNode *node, string kpix, uint channel, uint bucket ) {
   xmlNode    *childNode;
   string     topStr;
   string     nameStr;
   char       *attrValue;
   uint       idxNum;
   string     idxStr;
   string     kpixLocal;
   char       *nodeValue;
   double     value;
   //string     valStr;

   kpixLocal = kpix;

   // Top level node name
   topStr = (char *)node->name;

   // Look for child nodes
   for ( childNode = node->children; childNode; childNode = childNode->next ) {

      // Process element
      if ( childNode->type == XML_ELEMENT_NODE ) {

         // Get name
         nameStr = (char *)childNode->name;

         // Get index
         attrValue = (char *)xmlGetProp(childNode,(const xmlChar*)"index");
         if ( attrValue != NULL ) {
            idxNum = atoi(attrValue);
            idxStr = attrValue;
         }
         else {
            idxNum = 0;
            idxStr = "";
         }

         // Look for tags
         if ( nameStr == "kpixAsic" ) kpixLocal = idxStr;
         if ( nameStr == "Channel"  ) channel   = idxNum;
         if ( nameStr == "Bucket"   ) bucket    = idxNum;

         if ( channel > 1023 ) channel = 0;
         if ( bucket  > 3    ) bucket  = 0;

         // Process next level
         parseXmlLevel(childNode,kpixLocal,channel,bucket);
      }

      // Process text value
      else if ( childNode->type == XML_TEXT_NODE ) {
         nodeValue = (char *)childNode->content;
         if ( nodeValue != NULL ) {

            // Convert to double
            value = sscanf(nodeValue,"%lf",&value);

            // What do we do with this value
            if ( topStr == "baseMean" )          findKpix(kpix,true)->baseMean[channel][bucket] = value;
            if ( topStr == "baseRms" )           findKpix(kpix,true)->baseRms[channel][bucket] = value;
            if ( topStr == "baseFitMean" )       findKpix(kpix,true)->baseFitMean[channel][bucket] = value;
            if ( topStr == "baseFitSigma" )      findKpix(kpix,true)->baseFitSigma[channel][bucket] = value;
            if ( topStr == "baseFitMeanErr" )    findKpix(kpix,true)->baseFitMeanErr[channel][bucket] = value;
            if ( topStr == "baseFitSigmaErr" )   findKpix(kpix,true)->baseFitSigmaErr[channel][bucket] = value;
            if ( topStr == "calibGain" )         findKpix(kpix,true)->calibGain[channel][bucket] = value;
            if ( topStr == "calibIntercept" )    findKpix(kpix,true)->calibIntercept[channel][bucket] = value;
            if ( topStr == "calibGainErr" )      findKpix(kpix,true)->calibGainErr[channel][bucket] = value;
            if ( topStr == "calibInterceptErr" ) findKpix(kpix,true)->calibInterceptErr[channel][bucket] = value;
         }
      }
   }
}

// Return pointer to ASIC, optional creation
KpixCalibReadStruct *KpixCalibRead::findKpix ( string kpix, bool create ) {
   AsicMap::iterator   asicMapIter;
   KpixCalibReadStruct *asic;
   stringstream        err;

   asic = NULL;

   asicMapIter = asicList_.find(kpix);

   if ( asicMapIter == asicList_.end() ) {
      if ( create ) {
         asic = new KpixCalibReadStruct;
         asicList_.insert(pair<string,KpixCalibReadStruct*>(kpix,asic));
      }
   }
   else asic = asicMapIter->second;

   return(asic);
}

// Get Calibration Graph Fit Results
bool KpixCalibRead::getCalibData ( string kpix, uint channel, uint bucket,
                                   double *calibGain, double *calibIntercept,
                                   double *calibGainErr, double *calibInterceptErr ) {

   KpixCalibReadStruct *asic = findKpix ( kpix, false);

   if ( asic == NULL ) return false;

   *calibGain      = asic->calibGain[channel][bucket];
   *calibIntercept = asic->calibIntercept[channel][bucket];

   if ( calibGainErr      != NULL ) *calibGainErr      = asic->calibGainErr[channel][bucket];
   if ( calibInterceptErr != NULL ) *calibInterceptErr = asic->calibInterceptErr[channel][bucket];

   return(true);
}

// Get Baseline Fit Results
bool KpixCalibRead::getHistData ( string kpix, uint channel, uint bucket,
                                  double *mean, double *rms, 
                                  double *fitMean, double *fitSigma,
                                  double *fitMeanErr, double *fitSigmaErr) {

   KpixCalibReadStruct *asic = findKpix ( kpix, false);

   if ( asic == NULL ) return false;

   *mean = asic->baseMean[channel][bucket];
   *rms  = asic->baseRms[channel][bucket];

   if ( fitMean     != NULL ) *fitMean     = asic->baseFitMean[channel][bucket];
   if ( fitSigma    != NULL ) *fitSigma    = asic->baseFitSigma[channel][bucket];
   if ( fitMeanErr  != NULL ) *fitMeanErr  = asic->baseFitMeanErr[channel][bucket];
   if ( fitSigmaErr != NULL ) *fitSigmaErr = asic->baseFitSigmaErr[channel][bucket];

   return(true);
}

