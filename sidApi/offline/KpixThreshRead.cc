//-----------------------------------------------------------------------------
// File          : KpixThreshRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/27/2008
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// This class is used to read threshold scan plots.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/27/2008: created
// 06/22/2009: Added namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TGraphAsymmErrors.h>
#include <TF1.h>
#include <TFile.h>
#include <TH1D.h>
#include <TDirectory.h>
#include <TKey.h>
#include <TGraph.h>
#include "KpixThreshRead.h"
#include "KpixRunRead.h"
using namespace std;
using namespace sidApi::offline;


// Private functin to create plot name
string KpixThreshRead::genPlotName ( string prefix, int gain, int kpix, int channel, int cal ) {

   stringstream tempName;

   // Generate name
   tempName.str("");
   tempName << prefix << "_";
   if ( gain == 0 ) tempName << "norm_s";
   if ( gain == 1 ) tempName << "double_s";
   if ( gain == 2 ) tempName << "low_s";
   tempName << dec << setw(4) << setfill('0') << kpix << "_c";
   tempName << dec << setw(4) << setfill('0') << channel << "_i";
   if ( cal > 0 ) tempName << dec << setw(3) << setfill('0') << cal;
   return(tempName.str());
}


// Private functin to create plot title
string KpixThreshRead::genPlotTitle ( string prefix, int gain, int kpix, int channel, int cal ) {

   stringstream tempTitle;

   // Generate title
   tempTitle.str("");
   if ( gain == 0 ) tempTitle << "Norm";
   if ( gain == 1 ) tempTitle << "Double";
   if ( gain == 2 ) tempTitle << "Low";
   tempTitle << " " << prefix;
   tempTitle << ", KPIX=" << setfill('0') << dec << setw(4)  << kpix;
   tempTitle << ", Chan=" << setfill('0') << dec << setw(4)  << channel;
   if ( cal > 0 ) tempTitle << ", Cal=" << setfill('0') << dec << setw(3)  << cal;
   return(tempTitle.str());
}


// Calib Data Class Constructor
// Pass path to calibration data or
KpixThreshRead::KpixThreshRead ( string threshFile, bool debug ) {
   this->kpixRunRead = new KpixRunRead(threshFile, debug);
   delRunRead = true;
}


// Calib Data Class Constructor
// Pass already open run read class
KpixThreshRead::KpixThreshRead ( KpixRunRead *kpixRunRead ) {
   this->kpixRunRead = kpixRunRead;
   delRunRead = false;
}


// Deconstructor
KpixThreshRead::~KpixThreshRead () {
   if ( delRunRead ) delete kpixRunRead;
}


// Get Threshold Scan Histogram
TH2F *KpixThreshRead::getThreshScan ( string dir, int gain, int kpix, int channel, int cal ) {
   TH2F *hist;

   string name = "/" + dir + "/" + genPlotName("thresh_scan",gain,kpix,channel,cal);
   kpixRunRead->treeFile->GetObject(name.c_str(),hist);

   // Entry is valid
   if ( hist != NULL ) hist->SetDirectory(0);
   return(hist);
}


// Get Threshold Curve
TGraphAsymmErrors *KpixThreshRead::getThreshCurve ( string dir, int gain, int kpix, int channel) {
   TGraphAsymmErrors *plot;

   string name = "/" + dir + "/" + genPlotName("thresh_curve",gain,kpix,channel);
   kpixRunRead->treeFile->GetObject(name.c_str(),plot);
   return(plot);
}


// Get Threshold Cal
TGraphAsymmErrors *KpixThreshRead::getThreshCal ( string dir, int gain, int kpix, int channel, int cal) {
   TGraphAsymmErrors *plot;

   string name = "/" + dir + "/" + genPlotName("thresh_cal",gain,kpix,channel,cal);
   kpixRunRead->treeFile->GetObject(name.c_str(),plot);
   return(plot);
}


// Get Threshold Gain
TGraph *KpixThreshRead::getThreshGain ( string dir, int gain, int kpix, int channel) {
   TGraph *plot;

   string name = "/" + dir + "/" + genPlotName("thresh_gain",gain,kpix,channel);
   kpixRunRead->treeFile->GetObject(name.c_str(),plot);
   return(plot);
}


// Get Threshold Data
bool KpixThreshRead::getThreshData (double *meanVal, double *sigmaVal, double *gainVal,string dir,int gain,int serNum,int channel) {

   TGraphAsymmErrors *thresh;
   TGraph *cal;
   string name;

   // First read threshold histogram
   name = "/" + dir + "/" + genPlotName("thresh_curve",gain,serNum,channel);
   kpixRunRead->treeFile->GetObject(name.c_str(),thresh);

   // Threshold is valid
   if ( thresh != NULL && thresh->GetFunction("fit") != NULL ) {
      *meanVal = thresh->GetFunction("fit")->GetParameter(0);
      *sigmaVal = thresh->GetFunction("fit")->GetParameter(1);
   }
   else {
      *meanVal = 0;
      *sigmaVal = 0;
   }
   if ( thresh!=NULL ) delete thresh;

   // Next read calibration plot
   name = "/" + dir + "/" + genPlotName("thresh_gain",gain,serNum,channel);
   kpixRunRead->treeFile->GetObject(name.c_str(),cal);

   // Threshold is valid
   if ( cal != NULL && cal->GetFunction("pol1") != NULL )
      *gainVal = cal->GetFunction("pol1")->GetParameter(1);
   else *gainVal = 0;
   if ( cal!=NULL ) delete cal;

   // Return Value
   if ( *meanVal == 0 || *sigmaVal == 0 || *gainVal == 0) return(false);
   else return(true);
}


// Get Threshold Data
bool KpixThreshRead::getCalSigma (double *sigmaVal,string dir,int gain,int serNum,int channel,int cal) {

   TGraphAsymmErrors *thresh;
   string name;

   // First read threshold histogram
   name = "/" + dir + "/" + genPlotName("thresh_cal",gain,serNum,channel,cal);
   kpixRunRead->treeFile->GetObject(name.c_str(),thresh);

   // Threshold is valid
   if ( thresh != NULL && thresh->GetFunction("fit") != NULL ) *sigmaVal = thresh->GetFunction("fit")->GetParameter(1);
   else *sigmaVal = 0;
   if ( thresh!=NULL ) delete thresh;

   // Return Value
   if ( *sigmaVal == 0 ) return(false);
   else return(true);
}

