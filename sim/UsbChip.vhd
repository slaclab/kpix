-------------------------------------------------------------------------------
-- Title         : FTDI FT245BM USB Chip Emulation
-- Project       : KPIX Simulation
-------------------------------------------------------------------------------
-- File          : UsbChip.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/11/2007
-------------------------------------------------------------------------------
-- Description:
-- VHDL module to emulate USB Chip link to software.
-------------------------------------------------------------------------------
-- Copyright (c) 2007 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/11/2007: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity UsbChip is port (

      -- System clock, reset & control
      sysClk       : in  std_logic;  -- 0
      sysRst       : in  std_logic;  -- 1

      -- USB Interface
      usbDin       : in    std_logic_vector(7  downto 0); -- 2
      usbDout      : out   std_logic_vector(7  downto 0); -- 3
      usbRdL       : in    std_logic; -- 4
      usbWr        : in    std_logic; -- 5
      usbTxeL      : out   std_logic; -- 6
      usbRxfL      : out   std_logic; -- 7
      usbPwrEnL    : out   std_logic  -- 8
   );
end UsbChip;


-- Define architecture
architecture UsbChip of UsbChip is
   Attribute FOREIGN of UsbChip: architecture is 
      "vhpi:SimWsi_lib:VhpiGenericElab:UsbChipInit:UsbChip";
begin
end UsbChip;

