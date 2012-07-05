//-----------------------------------------------------------------------------
// File          : TimeWindow.cpp
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
#include "TimeWindow.h"
using namespace std;

// Constructor
TimeWindow::TimeWindow ( QWidget *parent ) : QWidget (parent) {
   QString tmp;
   uint x;

   QGridLayout *top = new QGridLayout;
   this->setLayout(top);

   for ( x=0; x < 4; x++ ) {
      plot_[x] = new QwtPlot;
      top->addWidget(plot_[x],x/2,x%2);

      time_[x] = new QwtPlotHistogram("Time");
      time_[x]->attach(plot_[x]);
      time_[x]->setStyle(QwtPlotHistogram::Columns);
      time_[x]->setPen( QPen( Qt::black ) ); 
      time_[x]->setBrush( QBrush( Qt::blue ) ); 
 
      QwtColumnSymbol *symbol1 = new QwtColumnSymbol( QwtColumnSymbol::Box ); 
      symbol1->setFrameStyle( QwtColumnSymbol::Raised ); 
      symbol1->setLineWidth( 2 ); 
      symbol1->setPalette( QPalette( Qt::blue ) ); 
      time_[x]->setSymbol( symbol1 ); 

      QwtLegend *legend = new QwtLegend;
      legend->setItemMode( QwtLegend::CheckableItem );
      plot_[x]->insertLegend( legend, QwtPlot::RightLegend );

      connect( plot_[x], SIGNAL( legendChecked( QwtPlotItem *, bool ) ),
                         SLOT( showItem( QwtPlotItem *, bool ) ) );

      QwtPlotItemList items = plot_[x]->itemList( QwtPlotItem::Rtti_PlotHistogram );
      for ( int i = 0; i < items.size(); i++ ) {
         QwtLegendItem *legendItem = qobject_cast<QwtLegendItem *>( legend->find( items[i] ) );
         if ( legendItem ) legendItem->setChecked( true );
         items[i]->setVisible( true );
      }
      plot_[x]->setAutoReplot( true );

      tmp = "Bucket ";
      tmp.append(QString().setNum(x));
      plot_[x]->setTitle(tmp);
      plot_[x]->setAxisTitle(QwtPlot::yLeft,"Events");
      plot_[x]->setAxisTitle(QwtPlot::xBottom,"Time Value");
      plot_[x]->plotLayout()->setAlignCanvasToScales(true);
   }
}

// Delete
TimeWindow::~TimeWindow ( ) { 

}

void TimeWindow::setHistData(uint x, KpixHistogram *time) {
   QVector<QwtIntervalSample> samples( time->binCount() );
   for ( uint i = 0; i < time->binCount(); i++ ) {
      QwtInterval interval( double( time->value(i) ), double(time->value(i)) + 1.0 );
      interval.setBorderFlags( QwtInterval::ExcludeMaximum );
      samples[i] = QwtIntervalSample( time->count(i), interval );
    }
    time_[x]->setData( new QwtIntervalSeriesData( samples ) );
}

void TimeWindow::rxData (KpixEvent *event) {
   uint       x;
   uint       channel;
   uint       bucket;
   uint       time;
   uint       kpix;
   uint       type;
   KpixSample *sample;

   for (x=0; x < event->count(); x++) {
      sample  = event->sample(x);
      channel = sample->getKpixChannel();
      bucket  = sample->getKpixBucket();
      kpix    = sample->getKpixAddress();
      time    = sample->getSampleTime();
      type    = sample->getSampleType();

      if ( type == 0 ) data_[kpix][channel][bucket].fill(time);
   }
}

void TimeWindow::rePlot(uint kpix, uint chan) {
   uint x;

   for (x=0; x<4; x++) {
      setHistData(x,&(data_[kpix][chan][x]));
      plot_[x]->replot();
   }
}

void TimeWindow::resetPlot() {
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

void TimeWindow::showItem( QwtPlotItem *item, bool on ) {
   item->setVisible(on);
}

