//-----------------------------------------------------------------------------
// File          : CalibWindow.h
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
#ifndef __CALIB_WINDOW_H__
#define __CALIB_WINDOW_H__

#include <QWidget>
#include <QMap>
#include <QDomDocument>
#include <QLineEdit>
#include <QSpinBox>
#include <QTimer>
#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <KpixEvent.h>
#include "KpixHistogram.h"
using namespace std;

class CalibWindow : public QWidget {
   Q_OBJECT

      QwtPlot      *plot_[4];
      QwtPlotCurve *curve_[4];

      double   charge_[32][1024][4][256];
      double   value_[32][1024][4][256];
      bool     valid_[32][1024][4][256];

      double plotX[4][256];
      double plotY[4][256];
      uint   plotCount[4];

      static double dacToCharge ( uint dac, bool pos, bool high );
      void setCalibData(uint kpix, uint chan, uint bucket);

   public:

      // Window
      CalibWindow ( QWidget *parent = NULL );

      // Delete
      ~CalibWindow ( );

      void rxData (KpixEvent *event, uint calChan, uint calDac, bool calPos, bool calHigh);
      void rePlot(uint kpix, uint chan);
      void resetPlot();
};

#endif
