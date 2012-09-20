
#include "VhpiGeneric.h"
#include <vhpi_user.h>
#include <stdlib.h>
#include <time.h>
#include "SimLinkTx.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

// Init function
void SimLinkTxInit(vhpiHandleT compInst) { 

   // Create new port data structure
   portDataT     *portData  = (portDataT *)     malloc(sizeof(portDataT));
   SimLinkTxData *txData    = (SimLinkTxData *) malloc(sizeof(SimLinkTxData));

   // Get port count
   portData->portCount = 27;

   // Set port directions and widths
   portData->portDir[txClk]            = vhpiIn;  portData->portWidth[txClk]            = 1;
   portData->portDir[txReset]          = vhpiIn;  portData->portWidth[txReset]          = 1;
   portData->portDir[vc0FrameTxValid]  = vhpiIn;  portData->portWidth[vc0FrameTxValid]  = 1;
   portData->portDir[vc0FrameTxReady]  = vhpiOut; portData->portWidth[vc0FrameTxReady]  = 1;
   portData->portDir[vc0FrameTxSOF]    = vhpiIn;  portData->portWidth[vc0FrameTxSOF]    = 1;
   portData->portDir[vc0FrameTxEOF]    = vhpiIn;  portData->portWidth[vc0FrameTxEOF]    = 1;
   portData->portDir[vc0FrameTxEOFE]   = vhpiIn;  portData->portWidth[vc0FrameTxEOFE]   = 1;
   portData->portDir[vc0FrameTxData]   = vhpiIn;  portData->portWidth[vc0FrameTxData]   = 16;
   portData->portDir[vc1FrameTxValid]  = vhpiIn;  portData->portWidth[vc1FrameTxValid]  = 1;
   portData->portDir[vc1FrameTxReady]  = vhpiOut; portData->portWidth[vc1FrameTxReady]  = 1;
   portData->portDir[vc1FrameTxSOF]    = vhpiIn;  portData->portWidth[vc1FrameTxSOF]    = 1;
   portData->portDir[vc1FrameTxEOF]    = vhpiIn;  portData->portWidth[vc1FrameTxEOF]    = 1;
   portData->portDir[vc1FrameTxEOFE]   = vhpiIn;  portData->portWidth[vc1FrameTxEOFE]   = 1;
   portData->portDir[vc1FrameTxData]   = vhpiIn;  portData->portWidth[vc1FrameTxData]   = 16;
   portData->portDir[vc2FrameTxValid]  = vhpiIn;  portData->portWidth[vc2FrameTxValid]  = 1;
   portData->portDir[vc2FrameTxReady]  = vhpiOut; portData->portWidth[vc2FrameTxReady]  = 1;
   portData->portDir[vc2FrameTxSOF]    = vhpiIn;  portData->portWidth[vc2FrameTxSOF]    = 1;
   portData->portDir[vc2FrameTxEOF]    = vhpiIn;  portData->portWidth[vc2FrameTxEOF]    = 1;
   portData->portDir[vc2FrameTxEOFE]   = vhpiIn;  portData->portWidth[vc2FrameTxEOFE]   = 1;
   portData->portDir[vc2FrameTxData]   = vhpiIn;  portData->portWidth[vc2FrameTxData]   = 16;
   portData->portDir[vc3FrameTxValid]  = vhpiIn;  portData->portWidth[vc3FrameTxValid]  = 1;
   portData->portDir[vc3FrameTxReady]  = vhpiOut; portData->portWidth[vc3FrameTxReady]  = 1;
   portData->portDir[vc3FrameTxSOF]    = vhpiIn;  portData->portWidth[vc3FrameTxSOF]    = 1;
   portData->portDir[vc3FrameTxEOF]    = vhpiIn;  portData->portWidth[vc3FrameTxEOF]    = 1;
   portData->portDir[vc3FrameTxEOFE]   = vhpiIn;  portData->portWidth[vc3FrameTxEOFE]   = 1;
   portData->portDir[vc3FrameTxData]   = vhpiIn;  portData->portWidth[vc3FrameTxData]   = 16;
   portData->portDir[ethMode]          = vhpiIn;  portData->portWidth[ethMode]          = 1;

   // Create data structure to hold state
   portData->stateData = txData;

   // State update function
   portData->stateUpdate = *SimLinkTxUpdate;

   // Init data structure
   txData->currClk   = 0;
   txData->txActive  = 0;
   txData->txCount   = 0;
   txData->txVc      = 0;
   txData->toCount   = 0;
   txData->sampCount = 0;

   // Create shared memory filename
   sprintf(txData->smemFile,"simlink_%s_%i", getlogin(), SHM_ID);

   // Open shared memory
   txData->smemFd = shm_open(txData->smemFile, (O_CREAT | O_RDWR), (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH));
   txData->smem = NULL;

   // Failed to open shred memory
   if ( txData->smemFd > 0 ) {

      // Force permissions regardless of umask
      fchmod(txData->smemFd, (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH));

      // Set the size of the shared memory segment
      ftruncate(txData->smemFd, sizeof(SimLinkTxMemory));

      // Map the shared memory
      if((txData->smem = (SimLinkTxMemory *)mmap(0, sizeof(SimLinkTxMemory),
                (PROT_READ | PROT_WRITE), MAP_SHARED, txData->smemFd, 0)) == MAP_FAILED) {
         txData->smemFd = -1;
         txData->smem   = NULL;
      }

      // Init records
      if ( txData->smem != NULL ) {
         txData->smem->usReqCount = 0;
         txData->smem->usAckCount = 0;
      }
   }

   if ( txData->smem != NULL ) vhpi_printf("SimLinkTx: Opened shared memory file: %s\n", txData->smemFile);
   else vhpi_printf("SimLinkTx: Failed to open shared memory file: %s\n", txData->smemFile);

   // Call generic Init
   VhpiGenericInit(compInst,portData);
}


// User function to update state based upon a signal change
void SimLinkTxUpdate ( portDataT *portData ) {
   int tsCount;

   SimLinkTxData *txData = (SimLinkTxData*)(portData->stateData);

   // Detect clock edge
   if ( txData->currClk != getInt(txClk) ) {
      txData->currClk = getInt(txClk);

      // Rising edge
      if ( txData->currClk == 1 ) {

         // Get ethernet mode flag
         txData->smem->usEthMode = getInt(ethMode);

         // Reset is asserted
         if ( getInt(txReset) == 1 ) {
            setInt(vc0FrameTxReady,0);
            setInt(vc1FrameTxReady,0);
            setInt(vc2FrameTxReady,0);
            setInt(vc3FrameTxReady,0);
            txData->txCount = 0;
         }
         else {

            // Receive is idle. check for new frame
            if ( txData->txActive == 0 ) {
               txData->txCount   = 0;
               txData->sampCount = 0;
              
               // VC0 is ready
               if ( getInt(vc0FrameTxValid) == 1 ) {
                  vhpi_printf("SimLinkTx: Frame Start. Vc=0, Time=%lld\n",portData->simTime);
                  if ( getInt(vc0FrameTxSOF) == 0 ) vhpi_printf("SimLinkTx: SOF error in VC 0\n");
                  setInt(vc0FrameTxReady,1);
                  txData->txActive = 1;
                  txData->txVc     = 0;
               }

               // VC1 is ready
               if ( getInt(vc1FrameTxValid) == 1 ) {
                  vhpi_printf("SimLinkTx: Frame Start. Vc=1, Time=%lld\n",portData->simTime);
                  if ( getInt(vc1FrameTxSOF) == 0 ) vhpi_printf("SimLinkTx: SOF error in VC 1\n");
                  setInt(vc1FrameTxReady,1);
                  txData->txActive = 1;
                  txData->txVc     = 1;
               }

               // VC2 is ready
               if ( getInt(vc2FrameTxValid) == 1 ) {
                  vhpi_printf("SimLinkTx: Frame Start. Vc=2, Time=%lld\n",portData->simTime);
                  if ( getInt(vc2FrameTxSOF) == 0 ) vhpi_printf("SimLinkTx: SOF error in VC 2\n");
                  setInt(vc2FrameTxReady,1);
                  txData->txActive = 1;
                  txData->txVc     = 2;
               }

               // VC3 is ready
               if ( getInt(vc3FrameTxValid) == 1 ) {
                  vhpi_printf("SimLinkTx: Frame Start. Vc=3, Time=%lld\n",portData->simTime);
                  if ( getInt(vc3FrameTxSOF) == 0 ) vhpi_printf("SimLinkTx: SOF error in VC 3\n");
                  setInt(vc3FrameTxReady,1);
                  txData->txActive = 1;
                  txData->txVc     = 3;
               }
            }

            // Transmit is active
            else {

               // Valid is asserted
               if ( (txData->txVc == 0 && getInt(vc0FrameTxValid) == 1 ) ||
                    (txData->txVc == 1 && getInt(vc1FrameTxValid) == 1 ) ||
                    (txData->txVc == 2 && getInt(vc2FrameTxValid) == 1 ) ||
                    (txData->txVc == 3 && getInt(vc3FrameTxValid) == 1 ) ) {

                  // Store data
                  switch (txData->txVc) {
                     case 0: txData->txData = getInt(vc0FrameTxData); break;
                     case 1: txData->txData = getInt(vc1FrameTxData); break;
                     case 2: txData->txData = getInt(vc2FrameTxData); break;
                     case 3: txData->txData = getInt(vc3FrameTxData); break;
                     default: break;
                  }

                  // Update data
                  if ( (txData->txCount % 2) == 0 ) txData->smem->usData[txData->txCount/2] = txData->txData;
                  else txData->smem->usData[txData->txCount/2] |= (txData->txData << 16) & 0xFFFF0000;
                  if ( (txData->txCount/2) < SIM_LINK_TX_BUFF_SIZE ) txData->txCount++;

                  // EOF is asserted
                  if ( (txData->txVc == 0 && getInt(vc0FrameTxEOF) == 1 ) ||
                       (txData->txVc == 1 && getInt(vc1FrameTxEOF) == 1 ) ||
                       (txData->txVc == 2 && getInt(vc2FrameTxEOF) == 1 ) ||
                       (txData->txVc == 3 && getInt(vc3FrameTxEOF) == 1 ) ) {

                     // Store EOFE
                     switch (txData->txVc) {
                        case 0: txData->smem->usEofe = getInt(vc0FrameTxEOFE); break;
                        case 1: txData->smem->usEofe = getInt(vc1FrameTxEOFE); break;
                        case 2: txData->smem->usEofe = getInt(vc2FrameTxEOFE); break;
                        case 3: txData->smem->usEofe = getInt(vc3FrameTxEOFE); break;
                        default: break;
                     }
                     setInt(vc0FrameTxReady,0);
                     setInt(vc1FrameTxReady,0);
                     setInt(vc2FrameTxReady,0);
                     setInt(vc3FrameTxReady,0);

                     // Force EOF for bad frame size
                     if ( (txData->txCount % 2) != 0 ) txData->smem->usEofe = 1;

                     // Send data
                     txData->smem->usVc   = txData->txVc;
                     txData->smem->usSize = txData->txCount/2;
                     txData->smem->usReqCount++;

                     vhpi_printf("SimLinkTx: Frame Done. Size=%i, Vc=%i, Time=%lld\n",
                        txData->smem->usSize,txData->smem->usVc,portData->simTime);

                     // Wait for other end
                     txData->toCount  = 0;
                     while ( txData->smem->usReqCount != txData->smem->usAckCount ) {
                        usleep(100);
                        if ( ++(txData->toCount) > 10000 ) {
                           vhpi_printf("SimLinkTx: Timeout waiting\n");
                           break;
                        }
                     }

                     // Init
                     txData->txActive = 0;
                     txData->txCount  = 0;
                  }
                  else {

                     if ( ((txData->txCount)/2) > 8 ) tsCount = (((txData->txCount)/2)-8) / 2;
                     else tsCount = 0;
                     
                     if ( txData->sampCount != tsCount ) {
                        txData->sampCount = tsCount;

                        vhpi_printf("SimLinkTx: Frame In Progress. Size=%i, Vc=%i, Samples=%i, Time=%lld\n",
                           ((txData->txCount)/2),txData->txVc,tsCount,portData->simTime);
                     }
                  }
               }
            }
         }
      }
   }
}

