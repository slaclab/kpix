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

#ifndef __USB_CHIP_H__
#define __USB_CHIP_H__

#include <vhpi_user.h>

#define RX_PIPE "sim_link.rx"
#define TX_PIPE "sim_link.tx"


// Structure to track state of USB
typedef struct usbStateDataS {

   // Current state of clock & reset
   int sysClk;
   int sysReset;
   
   // Wait for next ready counters, up(to pc) & dn(from pc)
   unsigned int upWait; 
   unsigned int dnWait; 

   // Byte to PC
   unsigned char upData;

   // Byte from PC
   unsigned char dnData;
   unsigned char dnValid;

   // File descriptors for up and down
   int upFd;
   int dnFd;

   // Last value of read and write strobes
   unsigned int lastWr;
   unsigned int lastRd;

} usbStateDataT;


// Init function
void UsbChipInit(vhpiHandleT compInst);


// Callback function for updating
void UsbChipUpdate ( portDataT *portData );

#endif
