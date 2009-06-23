//-----------------------------------------------------------------------------
// File          : KpixGuiRunNetwork.cc
// Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
// Created       : 10/14/2008
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
//-----------------------------------------------------------------------------

#include <sstream>
#include <iostream>
#include <string>
#include <qsocket.h>
#include "KpixGuiRunNetwork.h"
using namespace std;


// Creation Class
KpixGuiRunNetwork::KpixGuiRunNetwork ( short unsigned int port ) : QServerSocket(port,1,(QObject*)0) {
   client  = NULL;
   message = "";

   // Check status
   if ( !ok() ) {
      qWarning("Failed To Bind To Port");
      exit(1);
   }
   status = "Waiting For Network Client Connection";
}


// Delete
KpixGuiRunNetwork::~KpixGuiRunNetwork ( ) {
   if ( client != NULL ) delete client;
}


// Get Command String If Any
unsigned int KpixGuiRunNetwork::getCommand(double *vars, unsigned int count) {

   QString      temp;
   unsigned int ret, x;

   if ( message == "" ) return(0);

   // Get Count As First Value
   temp = message.section(' ',0,0);
   if ( temp.toInt() < 0 ) ret = 0;
   else ret = temp.toInt();

   // Process next values
   for ( x=0; x < count; x++ ) {
      temp = message.section(' ',x+1,x+1);
      vars[x] = temp.toDouble();
   }
   message = "";
   return(ret);
}


// Get Status String
string KpixGuiRunNetwork::getStatus() { return(status); }


// Send a string to the client
void KpixGuiRunNetwork::ackCommand() {
   if ( client != NULL ) client->writeBlock("Ready\n",6);
}


// Handle New Client
void KpixGuiRunNetwork::newConnection(int socket) {
   stringstream ts;
   QSocket      *temp;
   
   temp = new QSocket(this); 
   temp->setSocket(socket);

   // Can we accept this client
   if ( client != NULL ) {
      cout << endl << "KpixGuiRunNetwork::newConnection -> Rejected Connection From ";
      cout << temp->peerAddress().toString();
      cout << ":" << temp->peerPort() << endl;
      temp->close();
      delete temp;
   }

   // Accept client
   else {
      cout << endl << "KpixGuiRunNetwork::newConnection -> Accepted Connection From ";
      cout << temp->peerAddress().toString();
      cout << ":" << temp->peerPort() << endl;
      temp->writeBlock("Ready\n",6);
      client = temp;
      connect(client,SIGNAL(readyRead()),SLOT(readClient()));
      connect(client,SIGNAL(connectionClosed()),SLOT(closeClient()));

      // Update Status
      ts.str("");
      ts << "Waiting For Network Command From ";
      ts << temp->peerAddress().toString();
      ts << ":" << temp->peerPort() << endl;
      status = ts.str();
   }
}


// Read text from client
void KpixGuiRunNetwork::readClient() {
   message = client->readLine();
}


// Close Client
void KpixGuiRunNetwork::closeClient() {
   cout << endl << "KpixGuiRunNetwork::closeClient -> Client Closed Connection" << endl;
   delete client;
   client = NULL;

   // Update Status
   status = "Waiting For Client Connection";
}


