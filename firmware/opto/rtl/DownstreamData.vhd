-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Downstream Data Buffer
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : DownstreamData.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the downstream data frame buffer.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity DownstreamData is 
   port ( 

      -- USB Word Interface
      rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
      rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
      rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
      rxFifoWr      : in     std_logic;                     -- RX FIFO Write
      rxFifoFull    : out    std_logic;                     -- RX FIFO Full

      -- Out to KPIX Command transmitter
      kpixData      : out    std_logic_vector(15 downto 0); -- RX FIFO Data
      kpixSOF       : out    std_logic;                     -- RX FIFO Start of Frame
      kpixWr        : out    std_logic;                     -- RX FIFO Write
      kpixFull      : in     std_logic;                     -- RX FIFO Full

      -- Out to local command processor
      locData       : out    std_logic_vector(15 downto 0); -- RX FIFO Data
      locSOF        : out    std_logic;                     -- RX FIFO Start of Frame
      locWr         : out    std_logic;                     -- RX FIFO Write
      locFull       : in     std_logic                      -- RX FIFO Full
   );
end DownstreamData;


-- Define architecture
architecture DownstreamData of DownstreamData is
begin

   -- Pass on FIFO full
   rxFifoFull <= kpixFull or locFull;

   -- Pass on data
   kpixData <= rxFifoData;
   locData  <= rxFifoData;
   kpixSOF  <= rxFifoSOF;
   locSOF   <= rxFifoSOF;

   -- Select which destination to pass write to depending on type
   kpixWr <= rxFifoWr when rxFifoType = "00" else '0';
   locWr  <= rxFifoWr when rxFifoType = "10" else '0';

end DownstreamData;

