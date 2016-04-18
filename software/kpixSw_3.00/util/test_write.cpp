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
   uint32_t  count;
   time_t    curr;
   time_t    last;

   size  = 1024*1024;
   data  = (uint8_t *)malloc(1024*1024);
   flag  = 0;

   if ( dataSharedOpenAndMap ( &smem, "kpix" , 1 ) < 0 ) {
      printf("Failed to open shared memory\n");
      return(-1);
   }
   dataSharedInit(smem);

   time(&curr);
   last = curr;
   count = 0;

   while (1) {
      flag = size & 0x0FFFFFFF;
      dataSharedWrite(smem,flag,data,size);
      usleep(10000);
      time(&curr);
      count ++;
      if ( curr != last ) {
         printf("Send %i frames\n",count);
         last = curr;
         count = 0;
      }
   }
}

