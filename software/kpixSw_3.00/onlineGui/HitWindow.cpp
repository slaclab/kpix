//-----------------------------------------------------------------------------
// File          : HitWindow.cpp
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General purpose
//-----------------------------------------------------------------------------
// Description :
// Timestamp window
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
#include <qwt_plot_layout.h>
#include <qwt_plot_histogram.h>
#include "HitWindow.h"
using namespace std;

// Constructor
HitWindow::HitWindow ( QWidget *parent ) : QWidget (parent) {
   QString tmp;

   QGridLayout *top = new QGridLayout;
   this->setLayout(top);

   plot_ = new QwtPlot;
   top->addWidget(plot_,0,0);

   hits_ = new QwtPlotHistogram("Hits");
   hits_->attach(plot_);
   hits_->setStyle(QwtPlotHistogram::Columns);
   hits_->setPen( QPen( Qt::black ) ); 
   hits_->setBrush( QBrush( Qt::blue ) ); 
 
   QwtColumnSymbol *symbol1 = new QwtColumnSymbol( QwtColumnSymbol::Box ); 
   symbol1->setFrameStyle( QwtColumnSymbol::Raised ); 
   symbol1->setLineWidth( 2 ); 
   symbol1->setPalette( QPalette( Qt::blue ) ); 
   hits_->setSymbol( symbol1 ); 

   plot_->setAutoReplot( true );

   plot_->setTitle("Hits");
   plot_->setAxisTitle(QwtPlot::yLeft,"Events");
   plot_->setAxisTitle(QwtPlot::xBottom,"Channel");
   plot_->plotLayout()->setAlignCanvasToScales(true);
}

// Delete
HitWindow::~HitWindow ( ) { 

}

void HitWindow::setHistData(KpixHistogram *data) {
   QVector<QwtIntervalSample> samples( data->binCount() );
   for ( uint i = 0; i < data->binCount(); i++ ) {
      QwtInterval interval( double( data->value(i) ), double(data->value(i)) + 1.0 );
      interval.setBorderFlags( QwtInterval::ExcludeMaximum );
      samples[i] = QwtIntervalSample( data->count(i), interval );
    }
    hits_->setData( new QwtIntervalSeriesData( samples ) );
}

void HitWindow::rxData (KpixEvent *event) {
   uint       x;
   uint       channel;
   uint       kpix;
   uint       type;
   KpixSample *sample;

   for (x=0; x < event->count(); x++) {
      sample  = event->sample(x);
      channel = sample->getKpixChannel();
      kpix    = sample->getKpixAddress();
      type    = sample->getSampleType();

      if ( type == 0 ) data_[kpix].fill(channel);
   }
}

void HitWindow::rePlot(uint kpix) {
   setHistData(&(data_[kpix]));
   plot_->replot();
}

void HitWindow::resetPlot() {
   uint kpix;

   for (kpix=0; kpix < 32; kpix++) data_[kpix].init();
}

void HitWindow::showItem( QwtPlotItem *item, bool on ) {
   item->setVisible(on);
}

