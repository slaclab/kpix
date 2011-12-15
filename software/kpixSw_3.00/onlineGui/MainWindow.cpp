//-----------------------------------------------------------------------------
// File          : MainWindow.cpp
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
#include <iostream>
#include <sstream>
#include <string>
#include <QObject>
#include <QLabel>
#include <QPushButton>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QTabWidget>
#include "MainWindow.h"
using namespace std;

// Constructor
MainWindow::MainWindow ( QWidget *parent ) : QWidget (parent) {
   setWindowTitle("KPIX Live Display");
  
   QVBoxLayout *top = new QVBoxLayout; 
   this->setLayout(top);

   QTabWidget *tab = new QTabWidget;
   top->addWidget(tab);

   hist_ = new HistWindow;
   tab->addTab(hist_,"Histograms");

   calib_ = new CalibWindow;
   tab->addTab(calib_,"Calibration Plots");

   QHBoxLayout *hbox = new QHBoxLayout;
   top->addLayout(hbox);
   
   dText_ = new QLineEdit;
   dText_->setReadOnly(true);
   hbox->addWidget(new QLabel("Events:"));
   hbox->addWidget(dText_);
 
   kpix_ = new QSpinBox;
   kpix_->setMinimum(0); 
   kpix_->setMaximum(32); 
   connect(kpix_,SIGNAL(valueChanged(int)),this,SLOT(selChanged()));
   hbox->addWidget(new QLabel("Kpix:"));
   hbox->addWidget(kpix_);

   chan_ = new QSpinBox;
   chan_->setMinimum(0); 
   chan_->setMaximum(1023); 
   connect(chan_,SIGNAL(valueChanged(int)),this,SLOT(selChanged()));
   hbox->addWidget(new QLabel("Channel:"));
   hbox->addWidget(chan_);

   follow_ = new QCheckBox("Follow Calib Channel");
   hbox->addWidget(follow_);

   QPushButton *btn = new QPushButton("Reset Plot Data");
   connect(btn,SIGNAL(pressed()),this,SLOT(resetPressed()));
   hbox->addWidget(btn);

   dCount_ = 0;
   connect(&timer_,SIGNAL(timeout()),this,SLOT(selChanged()));
   timer_.start(500);

   calChannel_  = 0;
   calDac_      = 0;
   calInject_   = false;
   kpixPol_     = true;
   kpixCalHigh_ = false;

   status_.clear();
   config_.clear();
}

// Delete
MainWindow::~MainWindow ( ) { 
   status_.clear();
   config_.clear();
}

void MainWindow::xmlLevel (QDomNode node, QString level, bool config) {
   QString      local;
   QString      index;
   QString      value;
   QString      temp;

   while ( ! node.isNull() ) {

      // Process element
      if ( node.isElement() ) {
         local = level;

         // Append node name to id
         if ( local != "" ) local.append(":");
         local.append(node.nodeName());

         // Node has index
         if ( node.hasAttributes() ) {
            index = node.attributes().namedItem("index").nodeValue();
            local.append("(");
            local.append(index);
            local.append(")");
         }

         // Process child
         xmlLevel(node.firstChild(),local,config);
      }

      // Process text
      else if ( node.isText() ) {
         local = level;
         value = node.nodeValue();
         temp = value;

         // Strip all spaces and newlines
         temp.remove(QChar(' '));
         temp.remove(QChar('\n'));

         // Resulting string is non-blank
         if ( temp != "" ) {

            // Config
            if ( config ) config_[local] = value;

            // Status
            else status_[local] = value;
         }
      }

      // Next node
      node = node.nextSibling();
   }
}

void MainWindow::xmlStatus (QDomNode node) {
   bool ok;

   xmlLevel(node,"",false);

   calInject_  = (status_["CalState"] == "Inject");
   calChannel_ = status_["CalChannel"].toUInt(&ok,0);
   calDac_     = status_["CalDac"].toUInt(&ok,0);

   if ( follow_->isChecked() && calInject_ && ((uint)chan_->value() != calChannel_ ) ) 
      chan_->setValue(calChannel_);
}

void MainWindow::xmlConfig (QDomNode node) {
   xmlLevel(node,"",true);

   kpixCalHigh_ = ( config_["kpixFpga:kpixAsic:CntrlCalibHigh"] == "True" );

   if ( config_["kpixFpga:kpixAsic:CntrlPolarity"] == "Negative" ) kpixPol_ = false;
   else kpixPol_ = true;

}

void MainWindow::rxData (uint size, uint *data) {

   event_.copy(data,size);
   if ( calInject_ ) calib_->rxData (&event_, calChannel_, calDac_, kpixPol_, kpixCalHigh_);
   else hist_->rxData(&event_);
   dCount_++;
}

void MainWindow::selChanged() {
   uint kpix;
   uint chan;

   kpix = kpix_->value();
   chan = chan_->value();

   hist_->rePlot(kpix,chan);
   calib_->rePlot(kpix,chan);

   dText_->setText(QString().setNum(dCount_));
}

void MainWindow::resetPressed() {
   hist_->resetPlot();
   calib_->resetPlot();
   dCount_ = 0;
   selChanged();
}

