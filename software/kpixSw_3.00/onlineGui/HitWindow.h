//-----------------------------------------------------------------------------
// File          : HitWindow.h
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
#ifndef __HIT_WINDOW_H__
#define __HIT_WINDOW_H__

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

class HitWindow : public QWidget {
   Q_OBJECT

      QwtPlotHistogram *hits_;
      QwtPlot          *plot_;

      void setHistData(KpixHistogram *hits);

      KpixHistogram data_[32];

   public:

      // Window
      HitWindow ( QWidget *parent = NULL );

      // Delete
      ~HitWindow ( );

      void rxData (KpixEvent *event);
      void rePlot(uint kpix);
      void resetPlot();

   public slots:

      void showItem( QwtPlotItem *item, bool on );

};

#endif
