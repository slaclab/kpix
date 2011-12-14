//-----------------------------------------------------------------------------
// File          : MainWindow.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/04/2011
// Project       : General purpose
//-----------------------------------------------------------------------------
// Description :
// Top level control window
//-----------------------------------------------------------------------------
// Copyright (c) 2011 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/04/2011: created
//-----------------------------------------------------------------------------
#ifndef __MAIN_WINDOW_H__
#define __MAIN_WINDOW_H__

#include <QWidget>
#include <QMap>
#include <QDomDocument>
#include <KpixEvent.h>
using namespace std;

class MainWindow : public QWidget {
  
      QMap <QString, QString> config_;
      QMap <QString, QString> status_;
      KpixEvent               event_;
 
   Q_OBJECT

      void xmlLevel (QDomNode node, QString level, bool config);

   public:

      // Window
      MainWindow ( QWidget *parent = NULL );

      // Delete
      ~MainWindow ( );

   public slots:

      void xmlStatus (QDomNode node);
      void xmlConfig (QDomNode node);
      void rxData (uint size, uint *data);
};

#endif
