//-----------------------------------------------------------------------------
// Title         : USB Chip Software Backend
// Project       : W-SI KPIX
//-----------------------------------------------------------------------------
// File          : UsbChip.h
// Author        : Ryan Herbst, rherbst@slac.stanford.edu
// Created       : 05/11/2007
//-----------------------------------------------------------------------------
// Description:
// This code emulates the function of the FT245BM USB Link
//-----------------------------------------------------------------------------
// Copyright (c) 2007 by Ryan Herbst. All rights reserved.
//-----------------------------------------------------------------------------
// Modification history:
// 05/11/2007: created.
//-----------------------------------------------------------------------------

#include "VhpiGeneric.h"
#include <vhpi_user.h>
#include <stdlib.h>
#include <time.h>
#include "UsbChip.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

// Init function
void UsbChipInit(vhpiHandleT compInst) { 

   // Create new port data structure
   portDataT     *portData  = (portDataT *)     malloc(sizeof(portDataT));
   usbStateDataT *usbState  = (usbStateDataT *) malloc(sizeof(usbStateDataT));

   // Get port count
   portData->portCount = 8;

   // Set port directions and widths
   portData->portDir[0]  = vhpiIn;    portData->portWidth[0]  = 1;  // sysClk
   portData->portDir[1]  = vhpiIn;    portData->portWidth[1]  = 1;  // sysReset
   portData->portDir[2]  = vhpiIn;    portData->portWidth[2]  = 8;  // usbDin
   portData->portDir[3]  = vhpiOut;   portData->portWidth[3]  = 8;  // usbDout
   portData->portDir[4]  = vhpiIn;    portData->portWidth[4]  = 1;  // usbRdL
   portData->portDir[5]  = vhpiIn;    portData->portWidth[5]  = 1;  // usbWr
   portData->portDir[6]  = vhpiOut;   portData->portWidth[6]  = 1;  // usbTxeL
   portData->portDir[7]  = vhpiOut;   portData->portWidth[7]  = 1;  // usbRxfL
   portData->portDir[8]  = vhpiOut;   portData->portWidth[8]  = 1;  // usbPwrEnL

   // Create data structure to hold state
   portData->stateData = usbState;

   // State update function
   portData->stateUpdate = *UsbChipUpdate;

   // Init data structure
   usbState->sysClk       = 0;
   usbState->sysReset     = 0;
   usbState->upWait       = 10;
   usbState->dnWait       = 10;
   usbState->upData       = 0;
   usbState->dnData       = 0;
   usbState->dnValid      = 0;
   usbState->upFd         = -1;
   usbState->dnFd         = -1;
   usbState->lastWr       = 0;
   usbState->lastRd       = 1;

   // Call generic Init
   VhpiGenericInit(compInst,portData);
}


// User function to update state based upon a signal change
void UsbChipUpdate ( portDataT *portData ) {

   usbStateDataT *usbState = (usbStateDataT*)(portData->stateData);
   int ret;

   // Detect clock edge
   if ( usbState->sysClk != portData->intValue[0] ) {
      usbState->sysClk = portData->intValue[0];

      // Rising edge
      if ( usbState->sysClk == 1 ) {

         // Detect change of reset signal
         if ( usbState->sysReset != portData->intValue[1] ) {
            usbState->sysReset = portData->intValue[1];
            vhpi_printf("%s: Time=%lld: sysReset=%i\n",
               portData->blockName,portData->simTime, usbState->sysReset);
         }

         // Reset is asserted
         if ( usbState->sysReset == 1 ) {
            portData->intValue[3]  = 0; // usbDout
            portData->intValue[6]  = 1; // usbTxeL
            portData->intValue[7]  = 1; // usbRxfL
            portData->intValue[8]  = 1; // usbPwrEnL
         }

         // Reset not asserted
         else {

            // Open up link if they are not open
            if ( usbState->upFd < 0 ) {

               // Attempt to open serial port
               if ((usbState->upFd=open(RX_PIPE, O_WRONLY | O_NONBLOCK)) > 0) {
                  vhpi_printf("%s: Time=%lld: Opened Upstream %s\n",
                     portData->blockName,portData->simTime, RX_PIPE);
               }
            }

            // Open down link if they are not open
            if ( usbState->dnFd < 0 ) {

               // Attempt to open serial port
               if ((usbState->dnFd=open(TX_PIPE, O_RDONLY | O_NONBLOCK)) > 0) {
                  vhpi_printf("%s: Time=%lld: Opened Downstream %s\n",
                     portData->blockName,portData->simTime, TX_PIPE);
               }
            }

            // Enable power
            portData->intValue[8]  = 0; // usbPwrEnL

            // Determine state of tx eanble (data to PC)
            if ( usbState->upWait == 0 ) portData->intValue[6]  = 0; // usbTxeL
            else usbState->upWait--;

            // Detect falling edge of write strobe
            if ( usbState->lastWr == 1 && portData->intValue[5] == 0 ) {

               // Get value
               usbState->upData = portData->intValue[2];

               // Write data
               if ( write (usbState->upFd, &(usbState->upData), 1) < 1 ) {
                  vhpi_printf("%s: Time=%lld: Failed to write upstream data.\n",
                     portData->blockName,portData->simTime);
               }
               usbState->upWait = 4;
               portData->intValue[6] = 1; // Clear TXE
            }
            usbState->lastWr = portData->intValue[5]; 

            // Attempt to get byte from PC if we don't already have one
            if ( usbState->dnValid == 0 && usbState->dnWait == 0 ) {

               // Attempt to read data
               ret = read (usbState->dnFd, &(usbState->dnData), 1);

               // Read one byte
               if ( ret == 1 ) {

                  // Output data
                  portData->intValue[3] = usbState->dnData;

                  // Mark as valid
                  usbState->dnValid = 1;

                  // Assert rxf low
                  portData->intValue[7] = 0; // usbRxfL

                  // Echo Data
                  if ( write (usbState->upFd, &(usbState->dnData), 1) < 1 ) {
                     vhpi_printf("%s: Time=%lld: Failed to write upstream data.\n",
                        portData->blockName,portData->simTime);
                  }
               }
            }
            if ( usbState->dnWait > 0 ) usbState->dnWait--;

            // Detect rising edge of rd strobe
            if ( usbState->lastRd == 0 && portData->intValue[4] == 1 ) {

               // Clear valid, set counter
               usbState->dnValid     = 0;
               usbState->dnWait      = 4;
               portData->intValue[7] = 1; // usbRxfL
            }
            usbState->lastRd = portData->intValue[4];
         }
      }
   }
}

