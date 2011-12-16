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
#include <qwt_legend.h>
#include <qwt_legend_item.h>
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
      top->addWidget(plot_[x],x/2,x%2);

      hist_[x][0] = new QwtPlotHistogram("R0");
      hist_[x][0]->attach(plot_[x]);
      hist_[x][0]->setStyle(QwtPlotHistogram::Columns);
      hist_[x][0]->setPen( QPen( Qt::black ) ); 
      hist_[x][0]->setBrush( QBrush( Qt::blue ) ); 
 
      QwtColumnSymbol *symbol1 = new QwtColumnSymbol( QwtColumnSymbol::Box ); 
      symbol1->setFrameStyle( QwtColumnSymbol::Raised ); 
      symbol1->setLineWidth( 2 ); 
      symbol1->setPalette( QPalette( Qt::blue ) ); 
      hist_[x][0]->setSymbol( symbol1 ); 

      hist_[x][1] = new QwtPlotHistogram("R1");
      hist_[x][1]->attach(plot_[x]);
      hist_[x][1]->setStyle(QwtPlotHistogram::Columns);
      hist_[x][1]->setPen( QPen( Qt::black ) ); 
      hist_[x][1]->setBrush( QBrush( Qt::yellow ) ); 
 
      QwtColumnSymbol *symbol2 = new QwtColumnSymbol( QwtColumnSymbol::Box ); 
      symbol2->setFrameStyle( QwtColumnSymbol::Raised ); 
      symbol2->setLineWidth( 2 ); 
      symbol2->setPalette( QPalette( Qt::yellow ) ); 
      hist_[x][1]->setSymbol( symbol2 ); 

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
      plot_[x]->setAxisTitle(QwtPlot::xBottom,"ADC Value");
      plot_[x]->plotLayout()->setAlignCanvasToScales(true);
   }
}

// Delete
HistWindow::~HistWindow ( ) { 

}

void HistWindow::setHistData(uint x, uint y, KpixHistogram *hist) {
   QVector<QwtIntervalSample> samples( hist->binCount() );
   for ( uint i = 0; i < hist->binCount(); i++ ) {
      QwtInterval interval( double( hist->value(i) ), double(hist->value(i)) + 1.0 );
      interval.setBorderFlags( QwtInterval::ExcludeMaximum );
      samples[i] = QwtIntervalSample( hist->count(i), interval );
    }
    hist_[x][y]->setData( new QwtIntervalSeriesData( samples ) );
}

void HistWindow::rxData (KpixEvent *event) {
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

      data_[kpix][channel][bucket][range].fill(value);
   }
}

void HistWindow::rePlot(uint kpix, uint chan) {
   uint x;

   for (x=0; x<4; x++) {
      setHistData(x,0,&(data_[kpix][chan][x][0]));
      setHistData(x,1,&(data_[kpix][chan][x][1]));
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
            data_[kpix][chan][buck][0].init();
            data_[kpix][chan][buck][1].init();
         }
      }
   }
}

void HistWindow::showItem( QwtPlotItem *item, bool on ) {
   item->setVisible(on);
}

