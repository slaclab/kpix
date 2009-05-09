//-----------------------------------------------------------------------------
// File          : KpixGuiRunNetwork.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/29/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class to listen for remote commands on a socket.
//-----------------------------------------------------------------------------
// Copyright (c) 2006 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/29/2008: created
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_RUN_NETWORK_H__
#define __KPIX_GUI_RUN_NETWORK_H__

#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <qevent.h>
#include <qsocket.h>
#include <qserversocket.h>
using namespace std;

class KpixGuiRunNetwork : public QServerSocket {

      Q_OBJECT
      QSocket *client;
      QString message;
      string  status;

   public:

      // Creation Class
      KpixGuiRunNetwork ( unsigned short int port );

      // Delete
      ~KpixGuiRunNetwork ( );

      // Get Command If Any.
      // Pass list of event variables and count
      // Returns number of iterations to run or 0 if none
      unsigned int getCommand(double *vars, unsigned int count);

      // Send ack
      void ackCommand();
  
      // Get Status String
      string getStatus();

      // Process new connection
      void newConnection(int socket);

   public slots:

      // Read text from client
      void readClient();

      // Client is closed
      void closeClient();
};

#endif
