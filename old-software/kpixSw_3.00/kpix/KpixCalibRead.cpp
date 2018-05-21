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
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include "KpixCalibRead.h"
using namespace std;

// Calib Data Class Constructor
KpixCalibRead::KpixCalibRead ( ) {
   xmlInitParser();
   asicList_.clear();  
}

// Calib Data Class DecConstructor
KpixCalibRead::~KpixCalibRead ( ) {
   xmlCleanupParser();
   xmlMemoryDump();
}

// Parse xml file
bool KpixCalibRead::parse ( string calibFile ) {
   xmlDocPtr    doc;
   xmlNodePtr   node;
   ifstream     is;
   stringstream buffer;
   bool         ret;

   // Open file
   is.open(calibFile.c_str());
   if ( ! is.is_open() ) {
      cout << "Error opening xml file for read: " << calibFile << endl;
      return(false);
   }

   buffer.str("");
   buffer << is.rdbuf();
   is.close();
   ret = false;

   // Parse string
   doc = xmlReadMemory(buffer.str().c_str(), strlen(buffer.str().c_str()), "calib.xml", NULL, 0);
   if (doc != NULL) {

      // get the root element node
      node = xmlDocGetRootElement(doc);

      // Process
      parseXmlLevel(node,"",0,0,0);

      // Cleanup
      xmlFreeDoc(doc);
      ret = true;
   }
   xmlCleanupParser();
   xmlMemoryDump();
   return(ret);
}

// Parse XML level
void KpixCalibRead::parseXmlLevel ( xmlNode *node, string kpix, uint channel, uint bucket, uint range ) {
   xmlNode    *childNode;
   string     topStr;
   string     nameStr;
   char       *attrValue;
   uint       idxNum;
   string     idxStr;
   string     kpixLocal;
   char       *nodeValue;
   double     value;

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
         attrValue = (char *)xmlGetProp(childNode,(const xmlChar*)"id");
         if ( attrValue != NULL ) {
            idxNum = atoi(attrValue);
            idxStr = attrValue;
         }
         else {
            idxNum = 0;
            idxStr = "";
         }

         // Look for tags
         if ( nameStr == "Channel"  ) channel   = idxNum;
         if ( nameStr == "Bucket"   ) bucket    = idxNum;
         if ( nameStr == "Range"    ) range     = idxNum;
         if ( nameStr == "kpixAsic" ) kpixLocal = idxStr;

         // Process next level
         parseXmlLevel(childNode,kpixLocal,channel,bucket,range);
      }

      // Process text value
      else if ( childNode->type == XML_TEXT_NODE ) {
         nodeValue = (char *)childNode->content;
         if ( nodeValue != NULL ) {

            // Convert to double
            sscanf(nodeValue,"%lf",&value);

            // What do we do with this value
            if ( bucket < 4 && channel < 1024 && range < 2 ) {
               if ( topStr == "BaseMean" )          findKpix(kpix,channel,bucket,range,true)->baseMean          = value;
               if ( topStr == "BaseRms" )           findKpix(kpix,channel,bucket,range,true)->baseRms           = value;
               if ( topStr == "BaseFitMean" )       findKpix(kpix,channel,bucket,range,true)->baseFitMean       = value;
               if ( topStr == "BaseFitSigma" )      findKpix(kpix,channel,bucket,range,true)->baseFitSigma      = value;
               if ( topStr == "BaseFitMeanErr" )    findKpix(kpix,channel,bucket,range,true)->baseFitMeanErr    = value;
               if ( topStr == "BaseFitSigmaErr" )   findKpix(kpix,channel,bucket,range,true)->baseFitSigmaErr   = value;
               if ( topStr == "BaseFitChisquare" )  findKpix(kpix,channel,bucket,range,true)->baseFitChisquare  = value;
               if ( topStr == "CalibGain" )         findKpix(kpix,channel,bucket,range,true)->calibGain         = value;
               if ( topStr == "CalibIntercept" )    findKpix(kpix,channel,bucket,range,true)->calibIntercept    = value;
               if ( topStr == "CalibGainErr" )      findKpix(kpix,channel,bucket,range,true)->calibGainErr      = value;
               if ( topStr == "CalibGainRms" )      findKpix(kpix,channel,bucket,range,true)->calibGainRms      = value;
               if ( topStr == "CalibInterceptErr" ) findKpix(kpix,channel,bucket,range,true)->calibInterceptErr = value;
               if ( topStr == "CalibChisquare" )    findKpix(kpix,channel,bucket,range,true)->calibChisquare    = value;
               if ( topStr == "CalibCrossTalk" )    findKpix(kpix,channel,bucket,range,true)->calibCrossTalk    = nodeValue;
               if ( topStr == "BadChannel"        ) findKpix(kpix,channel,0     ,0    ,true)->badChannel        = (uint)value;
            }
         }
      }
   }
}

// Return pointer to ASIC, optional creation
KpixCalibRead::KpixCalibData *KpixCalibRead::findKpix ( string kpix, uint channel, uint bucket, uint range, bool create ) {
   KpixCalibAsic *asic;

   map<string,KpixCalibAsic *>::iterator asicMapIter;

   if ( channel > 1024 ) return(NULL);
   if ( bucket  > 3    ) return(NULL);
   if ( range   > 1    ) return(NULL);

   asicMapIter = asicList_.find(kpix);

   if ( asicMapIter == asicList_.end() ) {
      if ( create ) {
         asic = new KpixCalibAsic;
         asicList_.insert(pair<string,KpixCalibAsic*>(kpix,asic));
         //cout << "KpixCalibRead::findKpix -> Creating entry for Kpix " << kpix << endl;
      }
      else {
         //cout << "KpixCalibRead::findKpix -> Could not find Kpix " << kpix << endl;
         return(NULL);
      }
   }
   else asic = asicMapIter->second;

   return(asic->data[channel][bucket][range]);
}

// Get baseline mean value
double KpixCalibRead::baseMean ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseMean);
}

// Get baseline rms value
double KpixCalibRead::baseRms ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseRms);
}

// Get baseline guassian fit mean
double KpixCalibRead::baseFitMean ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseFitMean);
}

// Get baseline guassian fit sigma
double KpixCalibRead::baseFitSigma ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseFitSigma);
}

// Get baseline guassian fit mean error
double KpixCalibRead::baseFitMeanErr ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseFitMeanErr);
}

// Get baseline guassian fit sigma error
double KpixCalibRead::baseFitSigmaErr ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseFitSigmaErr);
}

// Get baseline guassian fit chisquare   
double KpixCalibRead::baseFitChisquare ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->baseFitChisquare);
}

// Get calibration gain
double KpixCalibRead::calibGain ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibGain);
}

// Get calibration intercept
double KpixCalibRead::calibIntercept ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibIntercept);
}

// Get calibration gain error
double KpixCalibRead::calibGainErr ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibGainErr);
}

// Get calibration gain rms
double KpixCalibRead::calibGainRms ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibGainRms);
}

// Get calibration intercept error
double KpixCalibRead::calibInterceptErr ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibInterceptErr);
}

// Get calibration chisquare
double KpixCalibRead::calibChisquare ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return(0.0);
   return(data->calibChisquare);
}

// Get calibration crosstalk string
string KpixCalibRead::calibCrossTalk ( string kpix, uint channel, uint bucket, uint range ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,bucket,range,false)) == NULL ) return("");
   return(data->calibCrossTalk);
}

// Get bad channel
uint KpixCalibRead::badChannel ( string kpix, uint channel ) {
   KpixCalibData *data;

   if ( (data = findKpix(kpix,channel,0,0,false)) == NULL ) return(false);
   return(data->badChannel);
}

//! Get calibration value by name
double KpixCalibRead::calibByName ( string kpix, uint channel, uint bucket, uint range, string name ) {
   if      ( name == "baseMean"          ) return( baseMean ( kpix, channel, bucket, range ));
   else if ( name == "baseRms"           ) return( baseRms ( kpix, channel, bucket, range ));
   else if ( name == "baseFitMean"       ) return( baseFitMean ( kpix, channel, bucket, range ));
   else if ( name == "baseFitSigma"      ) return( baseFitSigma ( kpix, channel, bucket, range ));
   else if ( name == "baseFitMeanErr"    ) return( baseFitMeanErr ( kpix, channel, bucket, range ));
   else if ( name == "baseFitSigmaErr"   ) return( baseFitSigmaErr ( kpix, channel, bucket, range ));
   else if ( name == "baseFitChisquare"  ) return( baseFitChisquare ( kpix, channel, bucket, range ));
   else if ( name == "calibGain"         ) return( calibGain ( kpix, channel, bucket, range ));
   else if ( name == "calibIntercept"    ) return( calibIntercept ( kpix, channel, bucket, range ));
   else if ( name == "calibGainErr"      ) return( calibGainErr ( kpix, channel, bucket, range ));
   else if ( name == "calibGainRms"      ) return( calibGainRms ( kpix, channel, bucket, range ));
   else if ( name == "calibInterceptErr" ) return( calibInterceptErr ( kpix, channel, bucket, range ));
   else if ( name == "calibChisquare"    ) return( calibChisquare ( kpix, channel, bucket, range ));
   else return(0.0);
}

