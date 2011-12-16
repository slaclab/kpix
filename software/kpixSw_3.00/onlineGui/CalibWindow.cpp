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
#include <qwt_legend.h>
#include <qwt_legend_item.h>
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
   QPen   p1, p2;
   QBrush b1, b2;

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

      curve_[x][0] = new QwtPlotCurve("R0");
      curve_[x][0]->attach(plot_[x]);
      p1 = curve_[x][0]->pen();
      b1 = curve_[x][0]->brush();
      p1.setColor(Qt::blue);
      b1.setColor(Qt::blue);
      curve_[x][0]->setPen(p1);
      curve_[x][0]->setBrush(b1);

      QwtSymbol *symbol1 = new QwtSymbol( QwtSymbol::XCross );
      symbol1->setPen( QPen( Qt::blue, 2 ) );
      symbol1->setSize( 7 );
      curve_[x][0]->setSymbol( symbol1 );

      curve_[x][1] = new QwtPlotCurve("R1");
      curve_[x][1]->attach(plot_[x]);
      p2 = curve_[x][1]->pen();
      b2 = curve_[x][1]->brush();
      p2.setColor(Qt::yellow);
      b2.setColor(Qt::yellow);
      curve_[x][1]->setPen(p2);
      curve_[x][1]->setBrush(b2);

      QwtSymbol *symbol2 = new QwtSymbol( QwtSymbol::XCross );
      symbol2->setPen( QPen( Qt::yellow, 2 ) );
      symbol2->setSize( 7 );
      curve_[x][1]->setSymbol( symbol2 );

      QwtLegend *legend = new QwtLegend;
      legend->setItemMode( QwtLegend::CheckableItem );
      plot_[x]->insertLegend( legend, QwtPlot::RightLegend );

      connect( plot_[x], SIGNAL( legendChecked( QwtPlotItem *, bool ) ),
                         SLOT( showItem( QwtPlotItem *, bool ) ) );

      QwtPlotItemList items = plot_[x]->itemList( QwtPlotItem::Rtti_PlotCurve );
      for ( int i = 0; i < items.size(); i++ ) {
         QwtLegendItem *legendItem = qobject_cast<QwtLegendItem *>( legend->find( items[i] ) );
         if ( legendItem ) legendItem->setChecked( true );
         items[i]->setVisible( true );
      }
      plot_[x]->setAutoReplot( true );
   }
   resetPlot();
}

// Delete
CalibWindow::~CalibWindow ( ) { 

}

void CalibWindow::setCalibData(uint kpix, uint chan, uint bucket) {
   uint   i;
   uint   r;
   uint   count;

   for (r=0; r < 2; r++) {
      count = 0;
      for (i=0; i < 256; i++) {
         if ( valid_[kpix][chan][bucket][r][i] ) {
            plotX[bucket][r][count] = charge_[kpix][chan][bucket][r][i];
            plotY[bucket][r][count] = value_[kpix][chan][bucket][r][i];
            count++;
         }
      }
      curve_[bucket][r]->setRawSamples(plotX[bucket][r],plotY[bucket][r],count);
   }
}

void CalibWindow::rxData (KpixEvent *event, uint calChan, uint calDac, bool calPos, bool calHigh) {
   uint       x;
   uint       channel;
   uint       bucket;
   uint       value;
   uint       kpix;
   uint       range;
   KpixSample *sample;

   for (x=0; x < event->count(); x++) {
      sample  = event->sample(x);
      channel = sample->getKpixChannel();
      bucket  = sample->getKpixBucket();
      kpix    = sample->getKpixAddress();
      value   = sample->getSampleValue();
      range   = sample->getSampleRange();

      if ( calChan == channel ) {
         charge_[kpix][calChan][bucket][range][calDac] = dacToCharge ( calDac, calPos, (calHigh && bucket==0));
         value_[kpix][calChan][bucket][range][calDac]  = value;
         valid_[kpix][calChan][bucket][range][calDac]  = true;
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
               valid_[kpix][chan][buck][0][x] = false;
               valid_[kpix][chan][buck][1][x] = false;
            }
         }
      }
   }
}

void CalibWindow::showItem( QwtPlotItem *item, bool on ) {
   item->setVisible(on);
}

