-------------------------------------------------------------------------------
-- Title         : Ethernet Interface Module, 16-bit word receive / transmit
-- Project       : SID, KPIX ASIC
-------------------------------------------------------------------------------
-- File          : EthTestCounter.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 1/18/2011
-------------------------------------------------------------------------------
-- Description:
-- This module converts the 8-bit data it receives and transmits
-- data as 16-bit words. The RX/TX words include a start of frame marker 
-- as well as 2-bit type flag.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/12/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity EthTestCounter is port ( 
      -- Ethernet clock & reset
      emacClk       : in  std_logic;
      emacClkRst    : in  std_logic;
      sysClk        : in  std_logic;
      sysRst        : in  std_logic;
      cScopeCtrl    : inout std_logic_vector(35 downto 0);
      
      -- TX FIFO Interface
      txFifoData    : out    std_logic_vector(15 downto 0); -- TX FIFO Data
      txFifoSOF     : out    std_logic;                     -- TX FIFO Start of Frame
      txFifoEOF     : out    std_logic;                     -- TX FIFO End of Frame
      txFifoType    : out    std_logic_vector(1  downto 0); -- TX FIFO Data Type
      txFifoRd      : in     std_logic;                     -- TX FIFO Read
      txFifoEmpty   : out    std_logic;                     -- TX FIFO Empty

      -- RX FIFO Interface
      rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
      rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
      rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
      rxFifoWr      : in     std_logic;                     -- RX FIFO Write
      rxFifoFull    : out    std_logic                      -- RX FIFO Full

   );

end EthTestCounter;

architecture EthTestCounter of EthTestCounter is 

   -- Local Signals
   signal dataCount      : std_logic_vector(31 downto 0);
   signal counter        : std_logic_vector(31 downto 0);
   signal msbCounter     : std_logic;
   signal msbData        : std_logic;
   signal txStart        : std_logic;
   signal txStop         : std_logic;
   signal txState        : std_logic_vector(1 downto 0);
   signal rxState        : std_logic_vector(1 downto 0);
   signal locTxFifoData  : std_logic_vector(15 downto 0);
   signal locTxFifoSOF   : std_logic;
   signal locTxFifoEOF   : std_logic;
   signal locTxFifoType  : std_logic_vector(1  downto 0);
   signal locTxFifoEmpty : std_logic;
   signal fifoData       : std_logic_vector(19 downto 0);
   signal fifoWrEn       : std_logic;
   signal fifoFull       : std_logic;
   
   -- Chip Scope signals
   constant enChipScope  : integer := 0;
   signal   ethDebug     : std_logic_vector(63 downto 0);

begin
   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
   ethDebug (63 downto 56) <= fifoData(7 downto 0);
   ethDebug (55)           <= txStop;
   ethDebug (54)           <= rxFifoWr;
   ethDebug (53)           <= fifoWrEn;
   ethDebug (52)           <= txStart;
   ethDebug (51)           <= txFifoRd;
   ethDebug (50)           <= locTxFifoEmpty;
   ethDebug (49)           <= locTxFifoEOF;
   ethDebug (48)           <= locTxFifoSOF;
   ethDebug (47 downto 32) <= locTxFifoData;
   ethDebug (31 downto 16) <= dataCount(15 downto 0);
   ethDebug (15 downto 0)  <= counter(15 downto 0);
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = 1) generate
   U_EthTestCounter_ila : v5_ila port map ( control => cScopeCtrl,
                                            clk     => emacClk,
                                            trig0   => ethDebug);
   end generate chipscope;

   rxFifoFull  <= '0';
   txFifoData  <= locTxFifoData;
   txFifoSOF   <= locTxFifoSOF;
   txFifoEOF   <= locTxFifoEOF;
   txFifoType  <= locTxFifoType;
   txFifoEmpty <= locTxFifoEmpty;
   
   U_EthTestCounter_fifo : afifo_20x8k port map (
      rst    => sysRst,
      wr_clk => emacClk,
      rd_clk => sysClk,
      din    => fifoData,
      wr_en  => fifoWrEn,
      rd_en  => txFifoRd,
      dout(15 downto 0 ) => locTxFifoData,
      dout(17 downto 16) => locTxFifoType,
      dout(18) => locTxFifoSOF,
      dout(19) => locTxFifoEOF,
      full   => fifoFull,
      empty  => locTxFifoEmpty);
      
   -------------- Rx Block -----------------------
   
   process (sysClk, sysRst) begin
      if (sysRst = '1') then
         dataCount <= (OTHERS=>'0') after tpd;
         rxState   <= (OTHERS=>'0') after tpd;
         txStart   <= '0'           after tpd;
         msbData   <= '0'           after tpd;
      elsif rising_edge(sysClk) then
         if (msbData = '0') then
            if (rxFifoWr = '1') then
               dataCount(15 downto 0) <= rxFifoData after tpd;
               msbData                <= '1'       after tpd;
            end if;
         else
            if (rxFifoWr = '1') then
               dataCount(31 downto 16)<= rxFifoData after tpd;
               msbData                <= '0'        after tpd;
               txStart                <= '1'        after tpd;
            end if;
         end if;
         
         if (txStop = '1') then
            dataCount <= (OTHERS=>'0') after tpd;
            txStart   <= '0'           after tpd;
         end if;
      end if;
   end process;
        
   ---------------- Tx Block --------------------------
   
   process (emacClk, emacClkRst) begin
      if (emacClkRst = '1') then
         fifoData  <= (OTHERS=>'0') after tpd;
         fifoWrEn  <= '0'           after tpd;
         msbCounter<= '0'           after tpd;
         counter   <= x"00000001"   after tpd;
         txState   <= (OTHERS=>'0') after tpd;
         txStop    <= '0'           after tpd;
      elsif rising_edge(emacClk) then
         if txStart = '1' and dataCount > 0 then
            if msbCounter = '0' then
               fifoData(15 downto 0)<= counter (15 downto 0) after tpd;
               fifoData(18) <= '1'           after tpd; -- SOF
               fifoWrEn     <= '1'           after tpd;
               msbCounter   <= '1'           after tpd;
            else
               fifoData(18) <= '0'           after tpd; -- SOF
               fifoData(19) <= '0'           after tpd; -- EOF
               fifoData(15 downto 0)<= counter (31 downto 16) after tpd;
               counter      <= counter + 1   after tpd;
               fifoWrEn     <= '1'           after tpd;
               msbCounter   <= '0'           after tpd;
               
--                if ((dataCount-1) = counter) then
--                   fifoWrEn     <= '1'           after tpd;
--                   fifoData(19) <= '1'           after tpd; -- EOF
               if (dataCount = counter) then
                  fifoWrEn     <= '1'           after tpd;
                  fifoData(19) <= '1'           after tpd; -- EOF
--                   fifoWrEn     <= '0'           after tpd;
--                   fifoData(19) <= '0'           after tpd; -- EOF
                  msbCounter   <= '0'           after tpd;
                  counter      <= x"00000001"   after tpd;
                  txStop       <= '1'           after tpd;
               end if;
            end if;
         else
            fifoData(18) <= '0'           after tpd; -- SOF
            fifoData(19) <= '0'           after tpd; -- EOF
            fifoWrEn     <= '0'           after tpd;
            msbCounter   <= '0'           after tpd;
            counter      <= x"00000001"   after tpd;
            txStop       <= '0'           after tpd;
         end if;
      end if;
   end process;
end EthTestCounter;