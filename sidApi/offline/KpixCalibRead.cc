//-----------------------------------------------------------------------------
// File          : KpixCalibRead.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 11/30/2006
// Project       : SID Electronics API
//-----------------------------------------------------------------------------
// Description :
// This class is used to extract calibration constants from the root
// file generated by the calib_dist_plot.cc software. 
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 11/30/2006: created
// 12/12/2008: Added RMS value extraction from histogram.
// 04/29/2009: Histograms copied along with calibration data.
//             Parameter errors now read as well.
// 06/22/2009: Added namespaces.
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <TH1F.h>
#include <TF1.h>
#include <TFile.h>
#include <TDirectory.h>
#include <TKey.h>
#include <TGraph.h>
#include "KpixCalibRead.h"
#include "KpixRunRead.h"
#include "KpixAsic.h"
using namespace std;
using namespace sidApi::offline;


// Private functin to create plot name
string KpixCalibRead::genPlotName ( int gain, int kpix, int channel, int bucket, string prefix, int range ) {

   stringstream tempName;

   // Generate name
   tempName.str("");
   tempName << prefix << "_";
   if ( gain == 0 ) tempName << "norm_s";
   if ( gain == 1 ) tempName << "double_s";
   if ( gain == 2 ) tempName << "low_s";
   tempName << dec << setw(4) << setfill('0') << kpix << "_c";
   tempName << dec << setw(4) << setfill('0') << channel << "_b";
   tempName << dec << setw(1) << bucket;
   if ( range >= 0 ) tempName << "_r" << dec << setw(1) << range;
   return(tempName.str());
}


// Private functin to create plot title
string KpixCalibRead::genPlotTitle ( int gain, int kpix, int channel, int bucket, string prefix, int range ) {

   stringstream tempTitle;

   // Generate title
   tempTitle.str("");
   if ( gain == 0 ) tempTitle << "Norm";
   if ( gain == 1 ) tempTitle << "Double";
   if ( gain == 2 ) tempTitle << "Low";
   tempTitle << " " << prefix;
   tempTitle << ", KPIX=" << setfill('0') << dec << setw(4)  << kpix;
   tempTitle << ", Chan=" << setfill('0') << dec << setw(4)  << channel;
   tempTitle << ", Buck=" << setfill('0') << dec << setw(1)  << bucket;
   if ( range >= 0 ) tempTitle << ", Range=" << setfill('0') << dec << setw(1) << range;
   return(tempTitle.str());
}


// Calib Data Class Constructor
// Pass path to calibration data or
KpixCalibRead::KpixCalibRead ( string calibFile, bool debug ) {
   this->kpixRunRead = new KpixRunRead(calibFile, debug);
   delRunRead = true;
}


// Calib Data Class Constructor
// Pass already open run read class
KpixCalibRead::KpixCalibRead ( KpixRunRead *kpixRunRead ) {
   this->kpixRunRead = kpixRunRead;
   delRunRead = false;
}


// Deconstructor
KpixCalibRead::~KpixCalibRead () {
   if ( delRunRead ) delete kpixRunRead;
}

 
// Get and make copy of Value Histogam
TH1F *KpixCalibRead::getHistValue ( string dir, int gain, int kpix, int channel, int bucket ) {
   TH1F *hist;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"dist_value");
   kpixRunRead->treeFile->GetObject(name.c_str(),hist);

   // Entry is valid
   if ( hist != NULL ) hist->SetDirectory(0);
   return(hist);
}


// Get and make copy of Time Histogam
TH1F *KpixCalibRead::getHistTime ( string dir, int gain, int kpix, int channel, int bucket ) {
   TH1F *hist;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"dist_time");
   kpixRunRead->treeFile->GetObject(name.c_str(),hist);

   // Entry is valid
   if ( hist != NULL )hist->SetDirectory(0);
   return(hist);
}


// Get and make copy of Value Graph
TGraph *KpixCalibRead::getGraphValue ( string dir, int gain, int kpix, int channel, 
                                       int bucket, int range ) {
   TGraph *gr;
   TGraph *ret;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_value",range);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);

   // Return New Entry
   if ( gr != NULL ) {
      //ret = new TGraph(*gr);
      ret = gr;
      //delete gr;
   } else ret = NULL;
   return(ret);
}


// Get and make copy of Time Graph
TGraph *KpixCalibRead::getGraphTime ( string dir, int gain, int kpix, int channel, 
                                      int bucket, int range ) {
   TGraph *gr;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_time",range);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);
   return(gr);
}


// Get and make copy of Residual Graph
TGraph *KpixCalibRead::getGraphResid ( string dir, int gain, int kpix, int channel, 
                                       int bucket, int range ) {
   TGraph *gr;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_resid",range);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);
   return(gr);
}


// Get and make copy of Filtered Graph
TGraph *KpixCalibRead::getGraphFilt ( string dir, int gain, int kpix, int channel, 
                                      int bucket, int range ) {
   TGraph *gr;

   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_filt",range);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);
   return(gr);
}


// Get Calibration Graph Fit Results If They Exist
bool KpixCalibRead::getCalibData ( double *fitGain, double *fitIntercept,
                                   string dir, int gain, int kpix, int channel, int bucket,
                                   double *fitGainErr, double *fitInterceptErr ) {

   TGraph *gr;
   string name;

   // Defaults
   *fitGain      = 0;
   *fitIntercept = 0;

   // First try filtered gain
   name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_filt",(gain==2)?1:0);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);

   // Next try non-filtered gain
   if ( gr == NULL ) {
      name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_value",(gain==2)?1:0);
      kpixRunRead->treeFile->GetObject(name.c_str(),gr);
   }

   // Get gain value
   if ( gr != NULL && gr->GetFunction("pol1") != NULL ) {
      *fitGain      = gr->GetFunction("pol1")->GetParameter(1);
      *fitIntercept = gr->GetFunction("pol1")->GetParameter(0);
      if ( fitGainErr      != NULL ) *fitGainErr      = gr->GetFunction("pol1")->GetParError(1);
      if ( fitInterceptErr != NULL ) *fitInterceptErr = gr->GetFunction("pol1")->GetParError(0);
   }
   if ( gr != NULL ) delete gr;

   // Return Value
   if ( *fitGain == 0 || *fitIntercept == 0 ) return(false);
   else return(true);
}


// Get Calibration Graph Fit RMS Value
bool KpixCalibRead::getCalibRms ( double *rms, string dir, int gain, int kpix, int channel, int bucket) {

   TGraph *gr;
   string name;

   // Default
   *rms = 0;

   // Get RMS
   name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"calib_resid",(gain==2)?1:0);
   kpixRunRead->treeFile->GetObject(name.c_str(),gr);

   // Get value
   if ( gr != NULL ) {
      *rms = gr->GetRMS(2);
      delete gr;
   }

   // Return Value
   if ( *rms == 0 ) return(false);
   else return(true);
}


// Get Histogram Graph Fit Results If They Exist
bool KpixCalibRead::getHistData ( double *fitMean, double *fitSigma, double *fitRms, 
                                  string dir, int gain, int kpix, int channel, int bucket,
                                  double *fitMeanErr, double *fitSigmaErr ) {

   TH1F *hist;

   // Defaults
   *fitMean  = 0;
   *fitSigma = 0;

   // Get Plot
   string name = "/" + dir + "/" + genPlotName(gain,kpix,channel,bucket,"dist_value");
   kpixRunRead->treeFile->GetObject(name.c_str(),hist);

   // Get Values
   if ( hist != NULL && hist->GetFunction("gaus") != NULL ) {
      *fitMean = hist->GetFunction("gaus")->GetParameter(1);
      *fitSigma = hist->GetFunction("gaus")->GetParameter(2);
      *fitRms   = hist->GetRMS();
      if ( fitMeanErr  != NULL ) *fitMeanErr  = hist->GetFunction("gaus")->GetParError(1);
      if ( fitSigmaErr != NULL ) *fitSigmaErr = hist->GetFunction("gaus")->GetParError(2);
   }
   if ( hist != NULL ) delete hist;

   // Return Value
   if ( *fitMean == 0 || *fitSigma == 0 ) return(false);
   else return(true);
}


// Copy calibration data to a new root file
// Only copy plots reqired to retrieve gain & intercept.
void KpixCalibRead::copyCalibData ( TFile *newFile, string directory, KpixAsic **asic, int asicCnt ) {
   unsigned int idx, kpix, chan, buck, gain, range;
   TGraph *tg;
   TH1F   *th;
   
   // make the directory in the new file
   newFile->cd("/");
   if ( ! newFile->cd(directory.c_str()) ) {
      newFile->mkdir(directory.c_str());
      newFile->cd(directory.c_str());
   }

   for (idx=0; idx < (unsigned int)asicCnt; idx++) {
      kpix = asic[idx]->getSerial();
      for (gain=0; gain < 3; gain++) {
         for (chan=0; chan < asic[idx]->getChCount(); chan++) {
            for (buck=0; buck < 4; buck++) {

               // Choose range
               range = gain==2?1:0;

               // First try filtered with the proper range
               if ( (tg = getGraphFilt (directory,gain,kpix,chan,buck,range) ) != NULL ) {
                  tg->Write(genPlotName (gain,kpix,chan,buck,"calib_filt",range).c_str());
                  delete tg;
               }

               // Otherwise keep raw value plot
               else if ( (tg = getGraphValue (directory,gain,kpix,chan,buck,range) ) != NULL ) {
                  tg->Write(genPlotName (gain,kpix,chan,buck,"calib_value",range).c_str());
                  delete tg;
               }

               // Copy histogram as well
               if ( (th = getHistValue (directory,gain,kpix,chan,buck) ) != NULL ) {
                  th->Write();
                  delete th;
               }
            }
         }
      }
   }

   // Always go back to the base directory
   newFile->cd("/");
}

