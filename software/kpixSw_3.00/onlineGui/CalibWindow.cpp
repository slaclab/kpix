//-----------------------------------------------------------------------------
// File          : CalibWindow.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General purpose
//-----------------------------------------------------------------------------
// Description :
// Calibration window
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/04/2011: created
//-----------------------------------------------------------------------------
#include <iostream>
#include <sstream>
#include <string>
#include <QObject>
#include <QLabel>
#include <QVBoxLayout>
#include <QFormLayout>
#include <QPushButton>
#include <qwt_plot.h>
#include <qwt_symbol.h>
#include <qwt_plot_layout.h>
#include <qwt_plot_histogram.h>
#include "CalibWindow.h"
using namespace std;

double CalibWindow::dacToCharge ( uint dac, bool pos, bool high ) {
   double volt;
   double mult;
   double charge;

   // Change to voltage
   if ( dac >= 0xf6 ) volt = 2.5 - ((double)(0xff-dac))*50.0*0.0001;
   else volt =(double)dac * 100.0 * 0.0001;

   if ( high ) mult = 22.0;
   else mult = 1;

   // Compute charge
   if ( pos ) charge = (2.5 - volt) * 200e-15 * mult;
   else charge = volt * 200e-15 * mult;
   
   return(charge);
}

// Constructor
CalibWindow::CalibWindow ( QWidget *parent ) : QWidget (parent) {
   QString tmp;
   uint x;

   QGridLayout *top = new QGridLayout;
   this->setLayout(top);

   for ( x=0; x < 4; x++ ) {
      plot_[x] = new QwtPlot;
      top->addWidget(plot_[x],x/2,x%2);

      tmp = "Bucket ";
      tmp.append(QString().setNum(x));
      plot_[x]->setTitle(tmp);
      plot_[x]->setAxisTitle(QwtPlot::yLeft,"ADC Value");
      plot_[x]->setAxisTitle(QwtPlot::xBottom,"Charge");
      plot_[x]->plotLayout()->setAlignCanvasToScales(true);

      curve_[x] = new QwtPlotCurve;
      curve_[x]->attach(plot_[x]);

      QwtSymbol *symbol = new QwtSymbol( QwtSymbol::XCross );
      symbol->setPen( QPen( Qt::darkBlue, 2 ) );
      symbol->setSize( 7 );
      curve_[x]->setSymbol( symbol );
   }
}

// Delete
CalibWindow::~CalibWindow ( ) { 

}

void CalibWindow::setCalibData(uint kpix, uint chan, uint bucket) {
   uint   i;

   plotCount[bucket] = 0;
   for (i=0; i < 256; i++) {
      if ( valid_[kpix][chan][bucket][i] ) {
         plotX[bucket][plotCount[bucket]] = charge_[kpix][chan][bucket][i];
         plotY[bucket][plotCount[bucket]] = value_[kpix][chan][bucket][i];
         plotCount[bucket]++;
      }
   }
   curve_[bucket]->setRawSamples(plotX[bucket],plotY[bucket],plotCount[bucket]);
   plot_[bucket]->replot();
}

void CalibWindow::rxData (KpixEvent *event, uint calChan, uint calDac, bool calPos, bool calHigh) {
   uint       x;
   uint       channel;
   uint       bucket;
   uint       value;
   uint       kpix;
   KpixSample *sample;

   for (x=0; x < event->count(); x++) {
      sample  = event->sample(x);
      channel = sample->getKpixChannel();
      bucket  = sample->getKpixBucket();
      kpix    = sample->getKpixAddress();
      value   = sample->getSampleValue();

      if ( calChan == channel ) {
         charge_[kpix][calChan][bucket][calDac] = dacToCharge ( calDac, calPos, (calHigh && bucket==0));
         value_[kpix][calChan][bucket][calDac]  = value;
         valid_[kpix][calChan][bucket][calDac]  = true;
      }
   }
}

void CalibWindow::rePlot(uint kpix, uint chan) {
   uint x;

   for (x=0; x<4; x++) {
      setCalibData(kpix,chan,x);
      plot_[x]->replot();
   }
}

void CalibWindow::resetPlot() {
   uint kpix;
   uint chan;
   uint buck;
   uint x;

   for (kpix=0; kpix < 32; kpix++) {
      for (chan=0; chan < 1024; chan++) {
         for (buck=0; buck < 4; buck++) {
            for (x=0; x < 256; x++) {
               valid_[kpix][chan][buck][x] = false;
            }
         }
      }
   }
}

