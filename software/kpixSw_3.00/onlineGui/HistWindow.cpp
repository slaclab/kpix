//-----------------------------------------------------------------------------
// File          : HistWindow.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General purpose
//-----------------------------------------------------------------------------
// Description :
// Histogram window
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
#include <qwt_plot_layout.h>
#include <qwt_plot_histogram.h>
#include "HistWindow.h"
using namespace std;

// Constructor
HistWindow::HistWindow ( QWidget *parent ) : QWidget (parent) {
   QString tmp;
   uint x;

   QGridLayout *top = new QGridLayout;
   this->setLayout(top);

   for ( x=0; x < 4; x++ ) {
      plot_[x] = new QwtPlot;
      hist_[x] = new QwtPlotHistogram;
      hist_[x]->attach(plot_[x]);
      hist_[x]->setStyle(QwtPlotHistogram::Columns);
      top->addWidget(plot_[x],x/2,x%2);

      hist_[x]->setPen( QPen( Qt::black ) ); 
      hist_[x]->setBrush( QBrush( Qt::blue ) ); 
 
      QwtColumnSymbol *symbol = new QwtColumnSymbol( QwtColumnSymbol::Box ); 
      symbol->setFrameStyle( QwtColumnSymbol::Raised ); 
      symbol->setLineWidth( 2 ); 
      symbol->setPalette( QPalette( Qt::blue ) ); 
      hist_[x]->setSymbol( symbol ); 

      tmp = "Bucket ";
      tmp.append(QString().setNum(x));
      plot_[x]->setTitle(tmp);
      plot_[x]->setAxisTitle(QwtPlot::yLeft,"Events");
      plot_[x]->setAxisTitle(QwtPlot::xBottom,"ADC Value");
      plot_[x]->plotLayout()->setAlignCanvasToScales(true);
   }
}

// Delete
HistWindow::~HistWindow ( ) { 

}

void HistWindow::setHistData(uint x, KpixHistogram *hist) {
   QVector<QwtIntervalSample> samples( hist->binCount() );
   for ( uint i = 0; i < hist->binCount(); i++ ) {
      QwtInterval interval( double( hist->value(i) ), double(hist->value(i)) + 1.0 );
      interval.setBorderFlags( QwtInterval::ExcludeMaximum );
      samples[i] = QwtIntervalSample( hist->count(i), interval );
    }
    hist_[x]->setData( new QwtIntervalSeriesData( samples ) );
}

void HistWindow::rxData (KpixEvent *event) {
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

      data_[kpix][channel][bucket].fill(value);
   }
}

void HistWindow::rePlot(uint kpix, uint chan) {
   uint x;

   for (x=0; x<4; x++) {
      setHistData(x,&(data_[kpix][chan][x]));
      plot_[x]->replot();
   }
}

void HistWindow::resetPlot() {
   uint kpix;
   uint chan;
   uint buck;

   for (kpix=0; kpix < 32; kpix++) {
      for (chan=0; chan < 1024; chan++) {
         for (buck=0; buck < 4; buck++) {
            data_[kpix][chan][buck].init();
         }
      }
   }
}

