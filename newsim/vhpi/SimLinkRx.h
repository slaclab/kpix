
#ifndef __SIM_LINK_RX_H__
#define __SIM_LINK_RX_H__

#include <vhpi_user.h>

// Signals
#define rxClk            0
#define rxReset          1
#define vcFrameRxSOF     2
#define vcFrameRxEOF     3
#define vcFrameRxEOFE    4
#define vcFrameRxData    5
#define vc0FrameRxValid  6
#define vc0LocBuffAFull  7
#define vc1FrameRxValid  8
#define vc1LocBuffAFull  9
#define vc2FrameRxValid  10
#define vc2LocBuffAFull  11
#define vc3FrameRxValid  12
#define vc3LocBuffAFull  13
#define ethMode          14

// Constant
#define SIM_LINK_RX_BUFF_SIZE 1000000

// Shared memory structure
typedef struct {

   // Upstream
   uint        usReqCount;
   uint        usAckCount;
   uint        usData[SIM_LINK_RX_BUFF_SIZE];
   uint        usSize;
   uint        usVc;
   uint        usEofe;
   uint        usEthMode;
   
   // Downstream
   uint        dsReqCount;
   uint        dsAckCount;
   uint        dsData[SIM_LINK_RX_BUFF_SIZE];
   uint        dsSize;
   uint        dsVc;
   uint        dsEthMode;

} SimLinkRxMemory;


// Structure to track state
typedef struct {

   // Shared memory
   uint            smemFd;
   SimLinkRxMemory *smem;
   char            smemFile[1000];

   // Current state of clock
   int currClk;
   int rxCount;
  
} SimLinkRxData;


// Init function
void SimLinkRxInit(vhpiHandleT compInst);


// Callback function for updating
void SimLinkRxUpdate ( portDataT *portData );

#endif
