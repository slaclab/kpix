//-----------------------------------------------------------------------------
// File          : calibrationFitter.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 05/30/2012
// Project       : Kpix Software Package
//-----------------------------------------------------------------------------
// Description :
// Application to process and fit kpix calibration data
//-----------------------------------------------------------------------------
// Copyright (c) 2012 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 05/30/2012: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <TFile.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TMultiGraph.h>
#include <TApplication.h>
#include <TGraphErrors.h>
#include <TGraph.h>
#include <TStyle.h>
#include <stdarg.h>
#include <KpixEvent.h>
#include <KpixSample.h>
#include <Data.h>
#include <DataRead.h>
#include <math.h>
#include <fstream>
using namespace std;

// Channel data
class ChannelData {
   public:

      // Baseline Data
      uint         baseData[8192];
      uint         baseMin;
      uint         baseMax;
      double       baseCount;
      double       baseMean;
      double       baseSum;
      double       baseRms;

      // Baseline fit data
      double       baseFitMean;
      double       baseFitSigma;
      double       baseFitMeanErr;
      double       baseFitSigmaErr;
      double       baseFitChisquare;

      // Calib Data
      double       calibCount[256];
      double       calibMean[256];
      double       calibSum[256];
      double       calibRms[256];
      double       calibOtherValue[1024];
      double       calibOtherDac[1024];

      ChannelData() {
         uint x;

         for (x=0; x < 8192; x++) baseData[x] = 0;
         baseMin          = 8192;
         baseMax          = 0;
         baseCount        = 0;
         baseMean         = 0;
         baseSum          = 0;
         baseRms          = 0;
         baseFitMean      = 0;
         baseFitSigma     = 0;
         baseFitMeanErr   = 0;
         baseFitSigmaErr  = 0;
         baseFitChisquare = 0;

         for (x=0; x < 256; x++) {
            calibCount[x]  = 0;
            calibMean[x]   = 0;
            calibSum[x]    = 0;
            calibRms[x]    = 0;
         }
         for (x=0; x < 1024; x++) {
            calibOtherValue[x] = 0;
            calibOtherDac[x] = 0;
         }
      }

      void addBasePoint(uint data) {
         baseData[data]++;
         if ( data < baseMin ) baseMin = data;
         if ( data > baseMax ) baseMax = data;
         baseCount++;

         double tmpM = baseMean;
         double value = data;

         baseMean += (value - tmpM) / baseCount;
         baseSum  += (value - tmpM) * (value - baseMean);
      }

      void addCalibPoint(uint x, uint y) {
         calibCount[x]++;

         double tmpM = calibMean[x];
         double value = y;

         calibMean[x] += (value - tmpM) / calibCount[x];
         calibSum[x]  += (value - tmpM) * (value - calibMean[x]);
      }

      void addNeighborPoint(uint chan, uint x, uint y) {
         if ( y > calibOtherValue[chan] ) {
            calibOtherValue[chan] = y;
            calibOtherDac[chan] = x;
         }
      }

      void compute() {
         uint x;

         if ( baseCount > 0 ) baseRms = sqrt(baseSum / baseCount);
         for (x=0; x < 256; x++) {
            if ( calibCount[x] > 0 ) calibRms[x] = sqrt(calibSum[x] / calibCount[x]);
         }
      }
};

// Function to compute calibration charge
double calibCharge ( uint dac, bool positive, bool highCalib ) {
   double volt;
   double charge;

   if ( dac >= 0xf6 ) volt = 2.5 - ((double)(0xff-dac))*50.0*0.0001;
   else volt =(double)dac * 100.0 * 0.0001;

   if ( positive ) charge = (2.5 - volt) * 200e-15;
   else charge = volt * 200e-15;

   if ( highCalib ) charge *= 22.0;

   return(charge);
}

void addDoubleToXml ( ofstream *xml, uint indent, string variable, Double_t value ) {
   uint x;

   if ( ! isnan(value) ) {
      for (x=0; x < indent; x++) *xml << " ";
      *xml << "<" << variable << ">";
      *xml << value;
      *xml << "</" << variable << ">";
      *xml << endl;
   }
}

void addStringToXml ( ofstream *xml, uint indent, string variable, string value ) {
   uint x;

   for (x=0; x < indent; x++) *xml << " ";
   *xml << "<" << variable << ">";
   *xml << value;
   *xml << "</" << variable << ">";
   *xml << endl;
}


// Process the data
int main ( int argc, char **argv ) {
   DataRead               dataRead;
   off_t                  fileSize;
   off_t                  filePos;
   KpixEvent              event;
   KpixSample             *sample;
   string                 calState;
   uint                   calChannel;
   uint                   calDac;
   uint                   lastPct;
   uint                   currPct;
   bool                   chanFound[32][1024];
   ChannelData            *chanData[32][1024][4][2];
   bool                   badMean[32][1024];
   bool                   badGain[32][1024];
   bool                   kpixFound[32];
   uint                   kpixMax;
   uint                   minDac;
   uint                   minChan;
   uint                   maxChan;
   uint                   x;
   uint                   range;
   uint                   value;
   uint                   kpix;
   uint                   channel;
   uint                   bucket;
   uint                   tstamp;
   string                 serial;
   KpixSample::SampleType type;
   TH1F                   *hist;
   stringstream           tmp;
   ofstream               xml;
   ofstream               csv;
   double                 grX[256];
   double                 grY[256];
   double                 grYErr[256];
   double                 grXErr[256];
   double                 grRes[256];
   uint                   grCount;
   TGraphErrors           *grCalib;
   TGraph                 *grResid;
   bool                   positive;
   bool                   b0CalibHigh;
   uint                   injectTime[5];
   uint                   eventCount;
   string                 outRoot;
   string                 outXml;
   string                 outCsv;
   TFile                  *rFile;
   TCanvas                *c1;
   double                 fitMin[2];
   double                 fitMax[2];
   char                   tstr[200];
   struct tm              *timeinfo;
   time_t                 tme;
   uint                   crChan;
   stringstream           crossString;
   stringstream           crossStringCsv;
   double                 crossDiff;
   double                 meanMin[2];
   double                 meanMax[2];
   double                 gainMin[2];
   double                 gainMax[2];
   uint                   badGainCnt;
   uint                   badMeanCnt;
   uint                   badValue;

   // Range = 0 acceptable values
   meanMin[0] = 100;
   meanMax[0] = 300;
   gainMin[0] = 2e15;
   gainMax[0] = 7e15;

   // Range = 1 acceptable values
   meanMin[1] = 100;
   meanMax[1] = 300;
   gainMin[1] = 2e15;
   gainMax[1] = 7e15;

   // Init structure
   for (kpix=0; kpix < 32; kpix++) {
      for (channel=0; channel < 1024; channel++) {
         for (bucket=0; bucket < 4; bucket++) {
            chanData[kpix][channel][bucket][0] = NULL;
            chanData[kpix][channel][bucket][1] = NULL;
         }
         chanFound[kpix][channel] = false;
         badGain[kpix][channel] = false;
         badMean[kpix][channel] = false;
      }
      kpixFound[kpix] = false;
   }
   badGainCnt = 0;
   badMeanCnt = 0;

   // Data file is the first and only arg
   if ( (argc != 2) && (argc != 4) && (argc != 6) ) {
      cout << "Usage: calibrationFitter data_file [r0MinFit r0MaxFit] [r1MinFit r1MaxFit]\n";
      return(1);
   }

   // Open data file
   if ( ! dataRead.open(argv[1]) ) {
      cout << "Error opening data file " << argv[1] << endl;
      return(1);
   }

   // Normal range fit min/max
   if ( argc >= 4 ) {
      fitMin[0] = atof(argv[2]);
      fitMax[0] = atof(argv[3]);
   } else {
      fitMin[0] = 0.0;
      fitMax[0] = 0.0;
   }
      
   // Low range fit min/max
   if ( argc == 6 ) {
      fitMin[1] = atof(argv[4]);
      fitMax[1] = atof(argv[5]);
   } else {
      fitMin[1] = 0.0;
      fitMax[1] = 0.0;
   }

   // Create output names
   tmp.str("");
   tmp << argv[1] << ".root";
   outRoot = tmp.str();
   tmp.str("");
   tmp << argv[1] << ".xml";
   outXml = tmp.str();
   tmp.str("");
   tmp << argv[1] << ".csv";
   outCsv = tmp.str();

   //////////////////////////////////////////
   // Read Data
   //////////////////////////////////////////
   cout << "Opened data file: " << argv[1] << endl;
   fileSize = dataRead.size();
   filePos  = dataRead.pos();

   // Init
   currPct    = 0;
   lastPct    = 100;
   eventCount = 0;
   minChan    = 0;
   maxChan    = 0;

   cout << "\rReading File: 0 %" << flush;

   // Process each event
   while ( dataRead.next(&event) ) {

      // Get calibration state
      calState   = dataRead.getStatus("CalState");
      calChannel = dataRead.getStatusInt("CalChannel");
      calDac     = dataRead.getStatusInt("CalDac");

      // Get injection times
      if ( eventCount == 0 ) {
         minDac        = dataRead.getConfigInt("CalDacMin");
         minChan       = dataRead.getConfigInt("CalChanMin");
         maxChan       = dataRead.getConfigInt("CalChanMax");
         injectTime[0] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal0Delay");
         injectTime[1] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal1Delay") + injectTime[0] + 4;
         injectTime[2] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal2Delay") + injectTime[1] + 4;
         injectTime[3] = dataRead.getConfigInt("cntrlFpga:kpixAsic:Cal3Delay") + injectTime[2] + 4;
         injectTime[4] = 8192;
      }

      // get each sample
      for (x=0; x < event.count(); x++) {

         // Get sample
         sample  = event.sample(x);
         kpix    = sample->getKpixAddress();
         channel = sample->getKpixChannel();
         bucket  = sample->getKpixBucket();
         value   = sample->getSampleValue();
         type    = sample->getSampleType();
         tstamp  = sample->getSampleTime();
         range   = sample->getSampleRange();

         // Only process real samples in the expected range
         if ( type == KpixSample::Data ) {

            // Create entry if it does not exist
            if ( chanData[kpix][channel][bucket][range] == NULL ) chanData[kpix][channel][bucket][range] = new ChannelData;
            if ( chanData[kpix][calChannel][bucket][range] == NULL ) chanData[kpix][calChannel][bucket][range] = new ChannelData;
            kpixFound[kpix]    = true;
            chanFound[kpix][channel] = true;

            // Filter for time
            if ( tstamp > injectTime[bucket] && tstamp < injectTime[bucket+1] ) {

               // Baseline
               if ( calState == "Baseline" ) chanData[kpix][channel][bucket][range]->addBasePoint(value);

               // Injection
               else if ( calState == "Inject" && calDac != minDac ) {
                  if ( channel == calChannel ) chanData[kpix][channel][bucket][range]->addCalibPoint(calDac, value);
                  else chanData[kpix][calChannel][bucket][range]->addNeighborPoint(channel, calDac, value);
               }
            }
         }
      }

      // Show progress
      filePos  = dataRead.pos();
      currPct = (uint)(((double)filePos / (double)fileSize) * 100.0);
      if ( currPct != lastPct ) {
         cout << "\rReading File: " << currPct << " %      " << flush;
         lastPct = currPct;
      }
      eventCount++;
   }
   cout << "\rReading File: Done.               " << endl;

   //////////////////////////////////////////
   // Process Data
   //////////////////////////////////////////
   gStyle->SetOptFit(1111);

   // Default canvas
   c1 = new TCanvas("c1","c1");

   // Open root file
   rFile = new TFile(outRoot.c_str(),"recreate");

   // Open xml file
   xml.open(outXml.c_str(),ios::out | ios::trunc);
   xml << "<calibrationData>" << endl;

   // Open csv file
   csv.open(outCsv.c_str(),ios::out | ios::trunc);
   csv << "Kpix,Channel,Bucket,Range,BaseMean,BaseRms,BaseFitMean,BaseFitSigma,BaseFitMeanErr,BaseFitSigmaErr,BaseFitChisquare";
   csv << ",CalibGain,CalibIntercept,CalibGainErr,CalibInterceptErr,CalibChisquare,CalibGainRms,CrossTalkChan0,CrossTalkAmp0";
   csv << ",CrossTalkChan1,CrossTalkAmp1";
   csv << ",CrossTalkChan2,CrossTalkAmp2";
   csv << ",CrossTalkChan3,CrossTalkAmp3";
   csv << ",CrossTalkChan4,CrossTalkAmp4";
   csv << ",CrossTalkChan5,CrossTalkAmp5";
   csv << ",CrossTalkChan6,CrossTalkAmp6";
   csv << ",CrossTalkChan7,CrossTalkAmp7";
   csv << ",CrossTalkChan8,CrossTalkAmp8";
   csv << ",CrossTalkChan9,CrossTalkAmp9";
   csv << endl;

   // Add notes
   xml << "   <sourceFile>" << argv[1] << "</sourceFile>" << endl;
   xml << "   <user>" <<  getlogin() << "</user>" << endl;
   xml << "   <r0MinFit>" <<  fitMin[0] << "</r0MinFit>" << endl;
   xml << "   <r0MaxFit>" <<  fitMax[0] << "</r0MaxFit>" << endl;
   xml << "   <r1MinFit>" <<  fitMin[1] << "</r1MinFit>" << endl;
   xml << "   <r1MaxFit>" <<  fitMax[1] << "</r1MaxFit>" << endl;

   time(&tme);
   timeinfo = localtime(&tme);
   strftime(tstr,200,"%Y_%m_%d_%H_%M_%S",timeinfo);
   xml << "   <timestamp>" << tstr << "</timestamp>" << endl;

   // get calibration mode variables for charge computation
   positive    = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlPolarity") == "Positive");
   b0CalibHigh = (dataRead.getConfig("cntrlFpga:kpixAsic:CntrlCalibHigh") == "True");

   // Kpix count;
   for (kpix=0; kpix<32; kpix++) if ( kpixFound[kpix] ) kpixMax=kpix;

   //////////////////////////////////////////
   // Process Baselines 
   //////////////////////////////////////////

   // Process each kpix device
   for (kpix=0; kpix<32; kpix++) {
      if ( kpixFound[kpix] ) {

         // Get serial number
         tmp.str("");
         tmp << "cntrlFpga(0):kpixAsic(" << dec << kpix << "):SerialNumber";
         serial = dataRead.getConfig(tmp.str());

         // Process each channel
         for (channel=minChan; channel <= maxChan; channel++) {

            // Show progress
            cout << "\rProcessing baseline kpix " << dec << kpix << " / " << dec << kpixMax
                 << ", Channel " << channel << " / " << dec << maxChan
                 << "                 " << flush;

            // Channel is valid
            if ( chanFound[kpix][channel] ) {

               // Each bucket
               for (bucket = 0; bucket < 4; bucket++) {
               
                  // Bucket is valid
                  if ( chanData[kpix][channel][bucket][0] != NULL || chanData[kpix][channel][bucket][0] != NULL ) {

                     // Each range
                     for (range = 0; range < 2; range++) {
 
                        // Range is valid
                        if ( chanData[kpix][channel][bucket][range] != NULL ) {
                           chanData[kpix][channel][bucket][range]->compute();

                           // Create histogram
                           tmp.str("");
                           tmp << "hist_" << serial << "_c" << dec << setw(4) << setfill('0') << channel;
                           tmp << "_b" << dec << bucket;
                           tmp << "_r" << dec << range;
                           hist = new TH1F(tmp.str().c_str(),tmp.str().c_str(),8192,0,8192);

                           // Fill histogram
                           for (x=0; x < 8192; x++) hist->SetBinContent(x+1,chanData[kpix][channel][bucket][range]->baseData[x]);
                           hist->GetXaxis()->SetRangeUser(chanData[kpix][channel][bucket][range]->baseMin,
                                                          chanData[kpix][channel][bucket][range]->baseMax);
                           hist->Fit("gaus","q");
                           hist->Write();

                           if ( hist->GetFunction("gaus") ) {
                              chanData[kpix][channel][bucket][range]->baseFitMean      = hist->GetFunction("gaus")->GetParameter(1);
                              chanData[kpix][channel][bucket][range]->baseFitSigma     = hist->GetFunction("gaus")->GetParameter(2);
                              chanData[kpix][channel][bucket][range]->baseFitMeanErr   = hist->GetFunction("gaus")->GetParError(1);
                              chanData[kpix][channel][bucket][range]->baseFitSigmaErr  = hist->GetFunction("gaus")->GetParError(2);
                              chanData[kpix][channel][bucket][range]->baseFitChisquare = 
                                 (hist->GetFunction("gaus")->GetChisquare() / hist->GetFunction("gaus")->GetNDF() );

                              // Determine bad channel from fitted mean
                              if ( chanData[kpix][channel][bucket][range]->baseFitMean > meanMax[range] ) badMean[kpix][channel] = true;
                              else if ( chanData[kpix][channel][bucket][range]->baseFitMean < meanMin[range] ) badMean[kpix][channel] = true;
                           }
                           else badMean[kpix][channel] = true;

                           // Determine bad channel from histogram mean
                           if ( chanData[kpix][channel][bucket][range]->baseMean > meanMax[range] ) badMean[kpix][channel] = true;
                           else if ( chanData[kpix][channel][bucket][range]->baseMean < meanMin[range] ) badMean[kpix][channel] = true;
                        }
                     }
                  }
               }
            }
         }
      }
   }
   cout << endl;

   //////////////////////////////////////////
   // Process Calibration
   //////////////////////////////////////////

   // Process each kpix device
   for (kpix=0; kpix<32; kpix++) {
      if ( kpixFound[kpix] ) {

         // Get serial number
         tmp.str("");
         tmp << "cntrlFpga(0):kpixAsic(" << dec << kpix << "):SerialNumber";
         serial = dataRead.getConfig(tmp.str());
         xml << "   <kpixAsic id=\"" << serial << "\">" << endl;

         // Process each channel
         for (channel=minChan; channel <= maxChan; channel++) {

            // Show progress
            cout << "\rProcessing calibration kpix " << dec << kpix << " / " << dec << kpixMax
                 << ", Channel " << channel << " / " << dec << maxChan 
                 << "                 " << flush;

            // Channel is valid
            if ( chanFound[kpix][channel] ) {

               // Start channel marker
               xml << "      <Channel id=\"" << channel << "\">" << endl;

               // Each bucket
               for (bucket = 0; bucket < 4; bucket++) {
               
                  // Bucket is valid
                  if ( chanData[kpix][channel][bucket][0] != NULL || chanData[kpix][channel][bucket][0] != NULL ) {
                     xml << "         <Bucket id=\"" << bucket << "\">" << endl;

                     // Each range
                     for (range = 0; range < 2; range++) {
 
                        // Range is valid
                        if ( chanData[kpix][channel][bucket][range] != NULL ) {
                           xml << "            <Range id=\"" << range << "\">" << endl;
                           chanData[kpix][channel][bucket][range]->compute();
                           csv << serial << "," << dec << channel << "," << dec << bucket << "," << dec << range;

                           // Add baseline data to xml
                           addDoubleToXml(&xml,15,"BaseMean",chanData[kpix][channel][bucket][range]->baseMean);
                           addDoubleToXml(&xml,15,"BaseRms",chanData[kpix][channel][bucket][range]->baseRms);
                           if ( chanData[kpix][channel][bucket][range]->baseFitMean != 0 ) {
                              addDoubleToXml(&xml,15,"BaseFitMean",chanData[kpix][channel][bucket][range]->baseFitMean);
                              addDoubleToXml(&xml,15,"BaseFitSigma",chanData[kpix][channel][bucket][range]->baseFitSigma);
                              addDoubleToXml(&xml,15,"BaseFitMeanErr",chanData[kpix][channel][bucket][range]->baseFitMeanErr);
                              addDoubleToXml(&xml,15,"BaseFitSigmaErr",chanData[kpix][channel][bucket][range]->baseFitSigmaErr);
                              addDoubleToXml(&xml,15,"BaseFitChisquare",chanData[kpix][channel][bucket][range]->baseFitChisquare);
                           }

                           // Add baseline data to excel file
                           csv << "," << chanData[kpix][channel][bucket][range]->baseMean;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseRms;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseFitMean;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseFitSigma;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseFitMeanErr;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseFitSigmaErr;
                           csv << "," << chanData[kpix][channel][bucket][range]->baseFitChisquare;

                           // Create calibration graph
                           grCount = 0;
                           crossString.str("");
                           crossStringCsv.str("");
                           for (x=0; x < 256; x++) {
                           
                              // Calibration point is valid
                              if ( chanData[kpix][channel][bucket][range]->calibCount[x] > 0 ) {
                                 grX[grCount]    = calibCharge ( x, positive, ((bucket==0)?b0CalibHigh:false));
                                 grY[grCount]    = chanData[kpix][channel][bucket][range]->calibMean[x];
                                 grYErr[grCount] = chanData[kpix][channel][bucket][range]->calibRms[x];
                                 grXErr[grCount] = 0;
                                 grCount++;

                                 // Find crosstalk, value - base > 3 * sigma
                                 for (crChan=0; crChan < 1024; crChan++ ) {

                                    crossDiff = chanData[kpix][channel][bucket][range]->calibOtherValue[crChan] - 
                                                chanData[kpix][crChan][bucket][range]->baseMean;

                                    if ( (chanData[kpix][channel][bucket][range]->calibOtherDac[crChan] == x)  && 
                                         (crChan != channel) && 
                                         (chanData[kpix][channel][bucket][range] != NULL ) &&
                                         (crossDiff > (10.0 * chanData[kpix][crChan][bucket][range]->baseRms))) {

                                       if ( crossString.str() != "" ) crossString << " ";
                                       crossString << dec << crChan << ":" << dec << (uint)crossDiff;
                                       crossStringCsv << "," << dec << crChan << "," << dec << (uint)crossDiff;
                                    }
                                 }
                              }
                           }

                           // Create graph
                           if ( grCount > 0 ) {
                              grCalib = new TGraphErrors(grCount,grX,grY,grXErr,grYErr);
                              grCalib->Draw("Ap");
                              grCalib->Fit("pol1","eq","",fitMin[range],fitMax[range]);
                              grCalib->GetFunction("pol1")->SetLineWidth(1);

                              // Create name and write
                              tmp.str("");
                              tmp << "calib_" << serial << "_c" << dec << setw(4) << setfill('0') << channel;
                              tmp << "_b" << dec << bucket;
                              tmp << "_r" << dec << range;
                              grCalib->SetTitle(tmp.str().c_str());
                              grCalib->Write(tmp.str().c_str());

                              // Create and store residual plot
                              for (x=0; x < grCount; x++) grRes[x] = (grY[x] - grCalib->GetFunction("pol1")->Eval(grX[x]));
                              grResid = new TGraph(grCount,grX,grRes);
                              grResid->Draw("Ap");

                              // Create name and write
                              tmp.str("");
                              tmp << "resid_" << serial << "_c" << dec << setw(4) << setfill('0') << channel;
                              tmp << "_b" << dec << bucket;
                              tmp << "_r" << dec << range;
                              grResid->SetTitle(tmp.str().c_str());
                              grResid->Write(tmp.str().c_str());

                              // Add to xml
                              if ( grCalib->GetFunction("pol1") ) {
                                 addDoubleToXml(&xml,15,"CalibGain",grCalib->GetFunction("pol1")->GetParameter(1));
                                 addDoubleToXml(&xml,15,"CalibIntercept",grCalib->GetFunction("pol1")->GetParameter(0));
                                 addDoubleToXml(&xml,15,"CalibGainErr",grCalib->GetFunction("pol1")->GetParError(1));
                                 addDoubleToXml(&xml,15,"CalibInterceptErr",grCalib->GetFunction("pol1")->GetParError(0));
                                 addDoubleToXml(&xml,15,"CalibChisquare",(grCalib->GetFunction("pol1")->GetChisquare() / grCalib->GetFunction("pol1")->GetNDF()));
                                 csv << "," << grCalib->GetFunction("pol1")->GetParameter(1);
                                 csv << "," << grCalib->GetFunction("pol1")->GetParameter(0);
                                 csv << "," << grCalib->GetFunction("pol1")->GetParError(1);
                                 csv << "," << grCalib->GetFunction("pol1")->GetParError(0);
                                 csv << "," << (grCalib->GetFunction("pol1")->GetChisquare() / grCalib->GetFunction("pol1")->GetNDF);

                                 // Determine bad channel from fitted gain
                                 if ( grCalib->GetFunction("pol1")->GetParameter(1) > gainMax[range] ) badGain[kpix][channel] = true;
                                 else if ( grCalib->GetFunction("pol1")->GetParameter(1) < gainMin[range] ) badGain[kpix][channel] = true;
                              }
                              else {
                                 csv << ",0,0,0,0,0";
                                 badGain[kpix][channel] = true;
                              }

                              addDoubleToXml(&xml,15,"CalibGainRms",grCalib->GetRMS(2));
                              csv << "," << grCalib->GetRMS(2);

                              if ( crossString.str() != "" ) addStringToXml(&xml,15,"CalibCrossTalk",crossString.str());
                              csv << crossStringCsv.str();
                           }
                           csv << endl; 
                           xml << "            </Range>" << endl;
                        }
                     }
                     xml << "         </Bucket>" << endl;
                  }
               }

               // Determine if the channel is bad
               badValue = 0;
               if ( badMean[kpix][channel] ) {
                  badValue |= 0x1;
                  badMeanCnt++;
               }
               if ( badGain[kpix][channel] ) {
                  badValue |= 0x2;
                  badGainCnt++;
               }

               xml << "         <BadChannel>" << dec << badValue << "</BadChannel>" << endl;
               xml << "      </Channel>" << endl;
            }
         }
         xml << "   </kpixAsic>" << endl;
      }
   }
   cout << endl;
   cout << "Wrote root plots to " << outRoot << endl;
   cout << "Wrote xml data to " << outXml << endl;
   cout << "Wrote csv data to " << outCsv << endl;
   cout << endl;
   cout << "Marked " << dec << badMeanCnt << " channels as bad due to mean value" << endl;
   cout << "Marked " << dec << badGainCnt << " channels as bad due to gain value" << endl;

   xml << "</calibrationData>" << endl;
   xml.close();
   delete rFile;

   // Cleanup
   for (kpix=0; kpix < 32; kpix++) {
      for (channel=0; channel < 1024; channel++) {
         for (bucket=0; bucket < 4; bucket++) {
            if ( chanData[kpix][channel][bucket][0] != NULL ) delete chanData[kpix][channel][bucket][0];
            if ( chanData[kpix][channel][bucket][1] != NULL ) delete chanData[kpix][channel][bucket][1];
         }
      }
   }

   // Close file
   dataRead.close();
   return(0);
}

