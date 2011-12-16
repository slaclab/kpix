//-----------------------------------------------------------------------------
// File          : HistWindow.h
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
#ifndef __HIST_WINDOW_H__
#define __HIST_WINDOW_H__

#include <QWidget>
#include <QMap>
#include <QDomDocument>
#include <QLineEdit>
#include <QSpinBox>
#include <QTimer>
#include <qwt_plot.h>
#include <qwt_plot_item.h>
#include <qwt_plot_histogram.h>
#include <KpixEvent.h>
#include "KpixHistogram.h"
using namespace std;

class HistWindow : public QWidget {
   Q_OBJECT

      QwtPlotHistogram *hist_[4][2];
      QwtPlot          *plot_[4];

      void setHistData(uint x, uint y, KpixHistogram *hist);

      KpixHistogram data_[32][1024][4][2];

   public:

      // Window
      HistWindow ( QWidget *parent = NULL );

      // Delete
      ~HistWindow ( );

      void rxData (KpixEvent *event);
      void rePlot(uint kpix, uint chan);
      void resetPlot();

   public slots:

      void showItem( QwtPlotItem *item, bool on );

};

#endif
