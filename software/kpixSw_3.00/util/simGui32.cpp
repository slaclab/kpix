#include <SimLink.h>
#include <KpixControl.h>
#include <ControlServer.h>
#include <Device.h>
#include <iomanip>
#include <fstream>
#include <iostream>
#include <signal.h>
using namespace std;

// Run flag for sig catch
bool stop;

// Function to catch cntrl-c
void sigTerm (int) { 
   cout << "Got Signal!" << endl;
   stop = true; 
}

int main (int argc, char **argv) {
   ControlServer cntrlServer;
   string        defFile;
   uint          shmId;
   int           port;
   stringstream  cmd;

   if ( argc == 1 ) {
      cout << "Usage: simGui smem_id [default.xml]" << endl;
      return(1);
   }
   shmId = atoi(argv[1]);

   if ( argc > 2 ) defFile = argv[2];
   else defFile = "";

   // Catch signals
   signal (SIGINT,&sigTerm);

   try {
      SimLink       simLink; 
      KpixControl   kpix(&simLink,defFile,32);
      int           pid;

      // Setup top level device
      kpix.setDebug(true);

      // Create and setup PGP link
      simLink.setMaxRxTx(500000);
      simLink.setDebug(true);
      simLink.open("kpix",shmId);
      usleep(100);

      // Setup control server
      cntrlServer.enableSharedMemory("kpix",1);
      cntrlServer.setDebug(true);
      port = cntrlServer.startListen(0);
      cntrlServer.setSystem(&kpix);
      cout << "Control id = 1" << endl;

      // Fork and start gui
      stop = false;
      switch (pid = fork()) {

         // Error
         case -1:
            cout << "Error occured in fork!" << endl;
            return(1);
            break;

         // Child
         case 0:
            usleep(100);
            cout << "Starting GUI" << endl;
            cmd.str("");
            cmd << "cntrlGui localhost " << dec << port;
            system(cmd.str().c_str());
            cout << "GUI stopped" << endl;
            kill(getppid(),SIGINT);
            break;

         // Server
         default:
            cout << "Starting server at port" << dec << port << endl;
            while ( ! stop ) cntrlServer.receive(100);
            cntrlServer.stopListen();
            cout << "Stopped server" << endl;
            break;
      }

   } catch ( string error ) {
      cout << "Caught Error: " << endl;
      cout << error << endl;
      cntrlServer.stopListen();
   }
}

