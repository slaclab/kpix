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
#include <iomanip>
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

   time_ = new TimeWindow;
   tab->addTab(time_,"Timestamp Plots");

   QHBoxLayout *hbox = new QHBoxLayout;
   top->addLayout(hbox);
   
   dText_ = new QLineEdit;
   dText_->setReadOnly(true);
   hbox->addWidget(new QLabel("Events:"));
   hbox->addWidget(dText_);

   tempLine_ = new QLineEdit;
   tempLine_->setReadOnly(true);
   hbox->addWidget(new QLabel("Temperature:"));
   hbox->addWidget(tempLine_);
 
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

   for(uint x=0; x < 32; x++) tempValues_[x] = 0;

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
   KpixSample *sample;
   uint       x;
   uint       kpix;
   uint       type;
   uint       value;

   event_.copy(data,size);
   if ( calInject_ ) calib_->rxData (&event_, calChannel_, calDac_, kpixPol_, kpixCalHigh_);
   else hist_->rxData(&event_);
   time_->rxData(&event_);

   // Extract temperatures
   for (x=0; x < event_.count(); x++) {
      sample  = event_.sample(x);
      kpix    = sample->getKpixAddress();
      type    = sample->getSampleType();
      value   = sample->getSampleValue();

      if ( type == 1 ) tempValues_[kpix] = value;
   }
   dCount_++;
}

void MainWindow::selChanged() {
   uint         kpix;
   uint         chan;
   uint         tempAdc;
   double       temp;
   int          g[8];
   int          d[8];
   int          de;
   int          i;
   stringstream tmp;

   kpix = kpix_->value();
   chan = chan_->value();

   hist_->rePlot(kpix,chan);
   calib_->rePlot(kpix,chan);
   time_->rePlot(kpix,chan);

   dText_->setText(QString().setNum(dCount_));

   // Convert temperature
   tempAdc = tempValues_[kpix];

   // Convert number to binary
   for (i=7; i >= 0; i--) {
      if ( tempAdc >= (unsigned int)pow(2,i) ) {
         g[i] = 1;
         tempAdc -= (unsigned int)pow(2,i);
      }
      else g[i] = 0;
   }

   // Convert grey code to decimal
   d[7] = g[7];
   for (i=6; i >= 0; i--) d[i]=d[i+1]^g[i];

   // Convert back to an integer
   de = 0;
   for (i=0; i<8; i++) if ( d[i] != 0 ) de += (int)pow(2,i);

   // Convert to temperature
   temp=-30.2+127.45/233*(255-de-20.75);

   tmp.str("");
   tmp << temp << " C (0x" << hex << setw(2) << setfill('0') << tempValues_[kpix] << ")";
   tempLine_->setText(tmp.str().c_str());
}

void MainWindow::resetPressed() {
   hist_->resetPlot();
   calib_->resetPlot();
   dCount_ = 0;
   selChanged();
}




