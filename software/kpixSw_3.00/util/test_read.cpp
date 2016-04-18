#include "DataSharedMem.h"
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

int main ( int argc, char **argv ) {
   DataSharedMemory *smem;
   uint8_t * data;
   uint32_t  size;
   uint32_t  flag;
   uint32_t  firstFlag;
   time_t    curr;
   time_t    last;
   uint32_t  count;
   uint32_t  rdCount;
   uint32_t  rdAddr;

   if ( dataSharedOpenAndMap ( &smem, "kpix" , 1 ) < 0 ) {
      printf("Failed to open shared memory\n");
      return(-1);
   }

   time(&curr);
   last = curr;
   count = 0;
   firstFlag = 0;

   while (1) {
      if ( dataSharedRead(smem,&rdAddr,&rdCount,&flag,&data) ) {
         count++;
         if ( firstFlag == 0 ) firstFlag = flag;
      }
      usleep(100);
      time(&curr);
      if ( curr != last ) {
         printf("Got %i frames. Flag diff=%i\n",count,(flag-firstFlag));
         last = curr;
      }
   }
}

