-------------------------------------------------------------------------------
-- Title         : Kpix Data Formatter module
-- Project       : SID, KPIX ASIC
-------------------------------------------------------------------------------
-- File          : KpixDataFrmtr.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 11/12/2010
-------------------------------------------------------------------------------
-- Description:
-- This module converts the 8-bit data it receives and transmits
-- data as 16-bit words. The RX/TX words include a start of frame marker 
-- as well as 2-bit type flag.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 2/17/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixDataFrmtr is port ( 

      -- System clock, reset
      sysClk        : in     std_logic;                     -- 200Mhz system clock
      sysRst        : in     std_logic;                     -- System reset
      
      -- Ethernet clock & reset
      emacClk       : in     std_logic;
      emacClkRst    : in     std_logic;
      
      -- RX FIFO Interface
      rxFifoData    : out    std_logic_vector(15 downto 0); -- RX FIFO Data
      rxFifoSOF     : out    std_logic;                     -- RX FIFO Start of Frame
      rxFifoType    : out    std_logic_vector(1  downto 0); -- RX FIFO Data Type
      rxFifoWr      : out    std_logic;                     -- RX FIFO Write
      rxFifoFull    : in     std_logic;                     -- RX FIFO Full

      -- MAC Interface Signals, Receiver
      -- UDP Receive interface
      ethRxValid    : in     std_logic;
      ethRxData     : in     std_logic_vector(7 downto 0);
      ethRxGood     : in     std_logic;
      ethRxError    : in     std_logic;

      -- Debug
      csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      
   );

end KpixDataFrmtr;


-- Define architecture for USB module
architecture KpixDataFrmtr of KpixDataFrmtr is 

   -- Local signals
   signal locRxFifoData  : std_logic_vector(7  downto 0);
   signal locRxFifoDin   : std_logic_vector(7  downto 0);
   signal locRxFifoRd    : std_logic;
   signal locRxFifoWr    : std_logic;
   signal locRxFifoFull  : std_logic;
   signal locRxFifoEmpty : std_logic;
   signal intRxFifoData  : std_logic_vector(15 downto 0);
   signal intRxFifoSOF   : std_logic;
   signal intRxFifoType  : std_logic_vector(1  downto 0);
   signal intRxFifoWr    : std_logic;
   signal writeRx        : std_logic;
   
   -- Chip Scope signals
   constant enChipScope  : integer := 0;
   signal   ethDebug     : std_logic_vector(63 downto 0);
   
begin

   ----------------------------------------------------------
   ------------------ Debug Block ---------------------------
   
   ethDebug (20)          <= intRxFifoSOF;
   ethDebug (18)          <= intRxFifoWr;
   ethDebug (17 downto 16)<= intRxFifoType;
   ethDebug (15 downto 0) <= intRxFifoData;

   chipscope : if (enChipScope = 1) generate   
      U_KpixDataFrmtr_EmacClk_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => emacClk,
         TRIG0   => ethDebug
      );
   end generate chipscope;
   
   ---------------------- Debug Block ----------------------------
   ---------------------------------------------------------------
   
   rxFifoSOF              <= intRxFifoSOF;
   rxFifoType             <= intRxFifoType;
   rxFifoWr               <= intRxFifoWr;
   rxFifoData             <= intRxFifoData;

   -- Receiver Data Fifo
   U_RxDataFifo : afifo_20x8k port map (
      wr_clk            => emacClk,
      rd_clk            => sysClk,
      rst               => sysRst,
      din(19 downto 8)  => (OTHERS => '0'),
      din(7  downto 0)  => locRxFifoDin,
      wr_en             => locRxFifoWr,
      rd_en             => locRxFifoRd,
      dout(19 downto 8) => open,
      dout(7  downto 0) => locRxFifoData,
      full              => locRxFifoFull,
      empty             => locRxFifoEmpty,
      wr_data_count     => open
   );
   -- Forward FIFO status
   locRxFifoRd  <= not locRxFifoEmpty after tpd;
   locRxFifoWr  <= ethRxValid         after tpd;
   locRxFifoDin <= ethRxData          after tpd;
   
   -- Convert byte data into 16-bit words
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         intRxFifoData <= (others=>'0') after tpd;
         intRxFifoSOF  <= '0'           after tpd;
         intRxFifoType <= "00"          after tpd;
         intRxFifoWr   <= '0'           after tpd;
         writeRx       <= '0'           after tpd;
         
      elsif rising_edge(sysClk) then

         -- FIFO Write
         writeRx     <= locRxFifoRd        after tpd;
         
         if (writeRx = '1' and rxFifoFull = '0') then
            -- Byte 0
            if locRxFifoData(7) = '1' then
               intRxFifoData(3 downto 0) <= locRxFifoData(3 downto 0) after tpd;
               intRxFifoType             <= locRxFifoData(5 downto 4) after tpd;
               intRxFifoSOF              <= locRxFifoData(6)          after tpd;
               intRxFifoWr               <= '0'                       after tpd;
               
           else

               -- Byte 1 
               if locRxFifoData(6) = '0' then
                  intRxFifoData(9 downto 4) <= locRxFifoData(5 downto 0) after tpd;
                  intRxFifoWr               <= '0'                       after tpd;
                  
              -- Byte 2
               else 
                  intRxFifoData(15 downto 10) <= locRxFifoData(5 downto 0) after tpd;
                  intRxFifoWr                 <= '1'                       after tpd;
                  
               end if;
            end if;
         else
            intRxFifoData <= (others=>'0') after tpd;
            intRxFifoSOF  <= '0'           after tpd;
            intRxFifoType <= "00"          after tpd;
            intRxFifoWr   <= '0'           after tpd;
        end if;
      end if;
   end process;

end KpixDataFrmtr;
