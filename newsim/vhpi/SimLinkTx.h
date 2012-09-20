
#ifndef __SIM_LINK_TX_H__
#define __SIM_LINK_TX_H__

#include <vhpi_user.h>

// Signals
#define txClk            0
#define txReset          1
#define vc0FrameTxValid  2
#define vc0FrameTxReady  3
#define vc0FrameTxSOF    4
#define vc0FrameTxEOF    5
#define vc0FrameTxEOFE   6
#define vc0FrameTxData   7
#define vc1FrameTxValid  8
#define vc1FrameTxReady  9
#define vc1FrameTxSOF    10
#define vc1FrameTxEOF    11
#define vc1FrameTxEOFE   12
#define vc1FrameTxData   13
#define vc2FrameTxValid  14
#define vc2FrameTxReady  15
#define vc2FrameTxSOF    16
#define vc2FrameTxEOF    17
#define vc2FrameTxEOFE   18
#define vc2FrameTxData   19
#define vc3FrameTxValid  20
#define vc3FrameTxReady  21
#define vc3FrameTxSOF    22
#define vc3FrameTxEOF    23
#define vc3FrameTxEOFE   24
#define vc3FrameTxData   25
#define ethMode          26

// Constant
#define SIM_LINK_TX_BUFF_SIZE 1000000

// Shared memory structure
typedef struct {

   // Upstream
   uint        usReqCount;
   uint        usAckCount;
   uint        usData[SIM_LINK_TX_BUFF_SIZE];
   uint        usSize;
   uint        usVc;
   uint        usEofe;
   uint        usEthMode;
   
   // Downstream
   uint        dsReqCount;
   uint        dsAckCount;
   uint        dsData[SIM_LINK_TX_BUFF_SIZE];
   uint        dsSize;
   uint        dsVc;
   uint        dsEthMode;

} SimLinkTxMemory;


// Structure to track state
typedef struct {

   // Shared memory
   uint            smemFd;
   SimLinkTxMemory *smem;
   char            smemFile[1000];

   // Current state of clock
   int currClk;
   int txActive;
   int txCount;
   int txVc;
   int toCount;
   int txData; 
   int sampCount;

} SimLinkTxData;


// Init function
void SimLinkTxInit(vhpiHandleT compInst);


// Callback function for updating
void SimLinkTxUpdate ( portDataT *portData );

#endif
