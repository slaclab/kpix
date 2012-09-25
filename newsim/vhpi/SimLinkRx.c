
#include "VhpiGeneric.h"
#include <vhpi_user.h>
#include <stdlib.h>
#include <time.h>
#include "SimLinkRx.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/mman.h>

// Init function
void SimLinkRxInit(vhpiHandleT compInst) { 

   // Create new port data structure
   portDataT     *portData  = (portDataT *)     malloc(sizeof(portDataT));
   SimLinkRxData *rxData    = (SimLinkRxData *) malloc(sizeof(SimLinkRxData));

   // Get port count
   portData->portCount = 15;

   // Set port directions and widths
   portData->portDir[rxClk]           = vhpiIn;  portData->portWidth[rxClk]            = 1;
   portData->portDir[rxReset]         = vhpiIn;  portData->portWidth[rxReset]          = 1;
   portData->portDir[vcFrameRxSOF]    = vhpiOut; portData->portWidth[vcFrameRxSOF]     = 1;
   portData->portDir[vcFrameRxEOF]    = vhpiOut; portData->portWidth[vcFrameRxEOF]     = 1;
   portData->portDir[vcFrameRxEOFE]   = vhpiOut; portData->portWidth[vcFrameRxEOFE]    = 1;
   portData->portDir[vcFrameRxData]   = vhpiOut; portData->portWidth[vcFrameRxData]    = 16;
   portData->portDir[vc0FrameRxValid] = vhpiOut; portData->portWidth[vc0FrameRxValid]  = 1;
   portData->portDir[vc0LocBuffAFull] = vhpiIn;  portData->portWidth[vc0LocBuffAFull]  = 1;
   portData->portDir[vc1FrameRxValid] = vhpiOut; portData->portWidth[vc1FrameRxValid]  = 1;
   portData->portDir[vc1LocBuffAFull] = vhpiIn;  portData->portWidth[vc1LocBuffAFull]  = 1;
   portData->portDir[vc2FrameRxValid] = vhpiOut; portData->portWidth[vc2FrameRxValid]  = 1;
   portData->portDir[vc2LocBuffAFull] = vhpiIn;  portData->portWidth[vc2LocBuffAFull]  = 1;
   portData->portDir[vc3FrameRxValid] = vhpiOut; portData->portWidth[vc3FrameRxValid]  = 1;
   portData->portDir[vc3LocBuffAFull] = vhpiIn;  portData->portWidth[vc3LocBuffAFull]  = 1;
   portData->portDir[ethMode]         = vhpiIn;  portData->portWidth[ethMode]          = 1;

   // Create data structure to hold state
   portData->stateData = rxData;

   // State update function
   portData->stateUpdate = *SimLinkRxUpdate;

   // Init data structure
   rxData->currClk       = 0;

   // Create shared memory filename
   sprintf(rxData->smemFile,"simlink.%s.%s.%i", getlogin(), SHM_NAME, SHM_ID);

   // Open shared memory
   rxData->smemFd = shm_open(rxData->smemFile, (O_CREAT | O_RDWR), (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH));
   rxData->smem = NULL;

   // Failed to open shred memory
   if ( rxData->smemFd > 0 ) {

      // Force permissions regardless of umask
      fchmod(rxData->smemFd, (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH));

      // Set the size of the shared memory segment
      ftruncate(rxData->smemFd, sizeof(SimLinkRxMemory));

      // Map the shared memory
      if((rxData->smem = (SimLinkRxMemory *)mmap(0, sizeof(SimLinkRxMemory),
                (PROT_READ | PROT_WRITE), MAP_SHARED, rxData->smemFd, 0)) == MAP_FAILED) {
         rxData->smemFd = -1;
         rxData->smem   = NULL;
      }

      // Init records
      if ( rxData->smem != NULL ) {
         rxData->smem->dsReqCount = 0;
         rxData->smem->dsAckCount = 0;
      }
   }

   if ( rxData->smem != NULL ) vhpi_printf("SimLinkRx: Opened shared memory file: %s\n", rxData->smemFile);
   else vhpi_printf("SimLinkRx: Failed to open shared memory file: %s\n", rxData->smemFile);

   // Call generic Init
   VhpiGenericInit(compInst,portData);
}


// User function to update state based upon a signal change
void SimLinkRxUpdate ( portDataT *portData ) {

   SimLinkRxData *rxData = (SimLinkRxData*)(portData->stateData);

   // Detect clock edge
   if ( rxData->currClk != getInt(rxClk) ) {
      rxData->currClk = getInt(rxClk);

      // Rising edge
      if ( rxData->currClk == 1 ) {

         // Get ethernet mode flag
         rxData->smem->dsEthMode = getInt(ethMode);

         // Reset is asserted
         if ( getInt(rxReset) == 1 ) {
            setInt(vcFrameRxSOF,0);
            setInt(vcFrameRxEOF,0);
            setInt(vcFrameRxData,0);
            setInt(vc0FrameRxValid,0);
            setInt(vc1FrameRxValid,0);
            setInt(vc2FrameRxValid,0);
            setInt(vc3FrameRxValid,0);
         } 
         else {

            // Receive is idle. check for new frame
            if ( rxData->rxCount == 0 ) {
               
               // Data is ready in FIFO, start frame
               if ( rxData->smem->dsReqCount != rxData->smem->dsAckCount ) {
                  vhpi_printf("SimLinkRx: Frame Start. Size=%i, Vc=%i, Time=%lld\n",
                     rxData->smem->dsSize,rxData->smem->dsVc,portData->simTime);
                  setInt(vcFrameRxSOF,1);
                  setInt(vcFrameRxEOF,0);
                  setInt(vcFrameRxData,rxData->smem->dsData[0] & 0xFFFF);
                  setInt(vc0FrameRxValid,(rxData->smem->dsVc==0)?1:0);
                  setInt(vc1FrameRxValid,(rxData->smem->dsVc==1)?1:0);
                  setInt(vc2FrameRxValid,(rxData->smem->dsVc==2)?1:0);
                  setInt(vc3FrameRxValid,(rxData->smem->dsVc==3)?1:0);
                  rxData->rxCount = 1;
               } else {
                  setInt(vcFrameRxSOF,0);
                  setInt(vcFrameRxEOF,0);
                  setInt(vcFrameRxData,0);
                  setInt(vc0FrameRxValid,0);
                  setInt(vc1FrameRxValid,0);
                  setInt(vc2FrameRxValid,0);
                  setInt(vc3FrameRxValid,0);
               }
            }

            // In Frame
            else {

               // Output current data
               if ( (rxData->rxCount % 2) == 0 ) setInt(vcFrameRxData,rxData->smem->dsData[(rxData->rxCount)/2] & 0xFFFF);
               else setInt(vcFrameRxData,(rxData->smem->dsData[(rxData->rxCount)/2] >> 16) & 0xFFFF);
               setInt(vcFrameRxSOF,0);
               
               // Backpressure
               if ( ( rxData->smem->dsVc == 0 && getInt(vc0LocBuffAFull) == 1 ) ||
                    ( rxData->smem->dsVc == 1 && getInt(vc1LocBuffAFull) == 1 ) ||
                    ( rxData->smem->dsVc == 2 && getInt(vc2LocBuffAFull) == 1 ) ||
                    ( rxData->smem->dsVc == 3 && getInt(vc3LocBuffAFull) == 1 ) ) {

                  // Stop valid assertion
                  setInt(vc0FrameRxValid,0);
                  setInt(vc1FrameRxValid,0);
                  setInt(vc2FrameRxValid,0);
                  setInt(vc3FrameRxValid,0);
               }

               // Non backpressure
               else {

                  // Output valid
                  setInt(vc0FrameRxValid,(rxData->smem->dsVc==0)?1:0);
                  setInt(vc1FrameRxValid,(rxData->smem->dsVc==1)?1:0);
                  setInt(vc2FrameRxValid,(rxData->smem->dsVc==2)?1:0);
                  setInt(vc3FrameRxValid,(rxData->smem->dsVc==3)?1:0);

                  // End of frame?
                  if ( ++(rxData->rxCount) >= ((rxData->smem->dsSize)*2) ) {
                     vhpi_printf("SimLinkRx: Frame Done. Size=%i, Vc=%i, Time=%lld\n",
                        rxData->smem->dsSize,rxData->smem->dsVc,portData->simTime);
                     rxData->smem->dsAckCount = rxData->smem->dsReqCount;
                     setInt(vcFrameRxEOF,1);
                     rxData->rxCount = 0;
                  } else {
                     setInt(vcFrameRxEOF,0);
                  }
               }
            }
         }
      }
   }
}

