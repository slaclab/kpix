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
#include "MainWindow.h"
using namespace std;

// Constructor
MainWindow::MainWindow ( QWidget *parent ) : QWidget (parent) {


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
   xmlLevel(node,"",false);
}

void MainWindow::xmlConfig (QDomNode node) {
   xmlLevel(node,"",true);
}

void MainWindow::rxData (uint size, uint *data) {
   event_.copy(data,size);
}

