//-----------------------------------------------------------------------------
// File          : KpixGuiRunNetwork.h
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/29/2008
// Project       : SID Electronics API - GUI
//-----------------------------------------------------------------------------
// Description :
// Class to listen for remote commands on a socket.
//-----------------------------------------------------------------------------
// Copyright (c) 2009 by SLAC. All rights reserved.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 10/29/2008: created
// 06/22/2009: Changed structure to support sidApi namespaces.
// 06/23/2009: Removed namespace.
//-----------------------------------------------------------------------------
#ifndef __KPIX_GUI_RUN_NETWORK_H__
#define __KPIX_GUI_RUN_NETWORK_H__

#include <string>
#include <qserversocket.h>

// Forward declarations
class QSocket;
class QString;

class KpixGuiRunNetwork : public QServerSocket {

      Q_OBJECT
      QSocket     *client;
      QString     message;
      std::string status;

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
      std::string getStatus();

      // Process new connection
      void newConnection(int socket);

   public slots:

      // Read text from client
      void readClient();

      // Client is closed
      void closeClient();
};

#endif
