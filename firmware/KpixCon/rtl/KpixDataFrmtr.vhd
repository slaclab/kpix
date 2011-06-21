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
      ethRxCount    : in     std_logic_vector(15 downto 0);

      -- Debug
      csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      
   );

end KpixDataFrmtr;


-- Define architecture for USB module
architecture KpixDataFrmtr of KpixDataFrmtr is 

   -- Local signals
   signal ethRxGoodError   : std_logic;
   signal dataFifoRd       : std_logic;
   signal dataFifoDout     : std_logic_vector(7 downto 0);
   signal countFifoRd      : std_logic;
   signal countFifoEmpty   : std_logic;
   signal countFifoDout    : std_logic_vector(15 downto 0);
   signal countFifoError   : std_logic;
   signal countFifoGood    : std_logic;
   signal rxCount          : std_logic_vector(15 downto 0);
   signal rxCntRst         : std_logic;
   signal intFifoData      : std_logic_vector(15 downto 0);
   signal intFifoSOF       : std_logic;
   signal intFifoType      : std_logic_vector(1  downto 0);
   signal intFifoWr        : std_logic;
   signal nxtFifoData      : std_logic_vector(15 downto 0);
   signal nxtFifoSOF       : std_logic;
   signal nxtFifoType      : std_logic_vector(1  downto 0);
   signal nxtFifoWr        : std_logic;
   signal intFirst         : std_logic;
   signal nxtFirst         : std_logic;
   
   -- Chip Scope signals
   constant enChipScope  : integer := 1;
   signal   ethDebug     : std_logic_vector(63 downto 0);

   -- RX States
   constant ST_RX_IDLE   : std_logic_vector(2 downto 0) := "000";
   constant ST_RX_READ   : std_logic_vector(2 downto 0) := "001";
   constant ST_RX_HEADA  : std_logic_vector(2 downto 0) := "010";
   constant ST_RX_HEADB  : std_logic_vector(2 downto 0) := "011";
   constant ST_RX_HIGH   : std_logic_vector(2 downto 0) := "100";
   constant ST_RX_LOW    : std_logic_vector(2 downto 0) := "101";
   constant ST_RX_DUMP   : std_logic_vector(2 downto 0) := "110";
   signal   curRXState   : std_logic_vector(2 downto 0);
   signal   nxtRXState   : std_logic_vector(2 downto 0);
   
begin

   ----------------------------------------------------------
   ------------------ Debug Block ---------------------------
   ethDebug(63 downto 32) <= (others=>'0');
   ethDebug(31 downto 16) <= intFifoData;
   ethDebug(15 downto  5) <= (others=>'0');
   ethDebug(4)            <= intFifoSOF;
   ethDebug(3 downto 2)   <= intFifoType;
   ethDebug(0)            <= intFifoWr;

   chipscope : if (enChipScope = 1) generate   
      U_KpixDataFrmtr_EmacClk_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => emacClk,
         TRIG0   => ethDebug
      );
   end generate chipscope;
   
   ---------------------- Debug Block ----------------------------
   ---------------------------------------------------------------
  
   -- Receiver Data Fifo
   U_RxDataFifo : afifo_20x8k port map (
      wr_clk            => emacClk,
      rd_clk            => sysClk,
      rst               => sysRst,
      din(19 downto 8)  => (OTHERS => '0'),
      din(7  downto 0)  => ethRxData,
      wr_en             => ethRxValid,
      rd_en             => dataFifoRd,
      dout(19 downto 8) => open,
      dout(7 downto 0)  => dataFifoDout,
      full              => open,
      empty             => open,
      wr_data_count     => open
   );

   -- Receiver Count Fifo
   U_RxCountFifo : afifo_20x8k port map (
      wr_clk             => emacClk,
      rd_clk             => sysClk,
      rst                => sysRst,
      din(19 downto 18)  => (OTHERS => '0'),
      din(17)            => ethRxError,
      din(16)            => ethRxGood,
      din(15 downto 0)   => ethRxCount,
      wr_en              => ethRxGoodError,
      rd_en              => countFifoRd,
      dout(19 downto 18) => open,
      dout(17)           => countFifoError,
      dout(16)           => countFifoGood,
      dout(15 downto 0)  => countFifoDout,
      full               => open,
      empty              => countFifoEmpty,
      wr_data_count      => open
   );
   ethRxGoodError <= ethRxError or ethRxGood;

   -- Data output
   rxFifoData <= intFifoData;
   rxFifoSOF  <= intFifoSOF;
   rxFifoType <= intFifoType;
   rxFifoWr   <= intFifoWr;

   -- Convert byte data into 16-bit words
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         intFifoData <= (others=>'0') after tpd;
         intFifoSOF  <= '0'           after tpd;
         intFifoType <= (others=>'0') after tpd;
         intFifoWr   <= '0'           after tpd;
         intFirst    <= '0'           after tpd;
         rxCount     <= (others=>'0') after tpd;
         curRxState  <= ST_RX_IDLE    after tpd;
      elsif rising_edge(sysClk) then

         -- Read counter
         if rxCntRst = '1' then
            rxCount <= (others=>'0') after tpd;
         elsif dataFifoRd = '1' then
            rxCount <= rxCount + 1 after tpd;
         end if;

         -- Track first
         intFirst <= nxtFirst after tpd;

         -- Output
         intFifoData <= nxtFifoData   after tpd;
         intFifoSOF  <= nxtFifoSOF    after tpd;
         intFifoType <= nxtFifoType   after tpd;
         intFifoWr   <= nxtFifoWr     after tpd;
         
         -- State
         curRxState <= nxtRxState after tpd;
      end if;
   end process;


   process ( dataFifoDout, countFifoEmpty, countFifoDout,
             countFifoError, countFifoGood, intFifoData, intFifoType ) begin
      case curRxState is

         when ST_RX_IDLE =>
            rxCntRst     <= '1';
            dataFifoRd   <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= '0';
            nxtFifoType  <= (others=>'0');
            nxtFifoWr    <= '0';
            nxtFirst     <= '0';

            -- Count fifo has data
            if countFifoEmpty = '0' then
               countFifoRd <= '1';
               nxtRxState  <= ST_RX_READ;
            else
               countFifoRd <= '0';
               nxtRxState  <= curRxState;
            end if;

         when ST_RX_READ =>
            rxCntRst     <= '0';
            countFifoRd  <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= '0';
            nxtFifoType  <= (others=>'0');
            nxtFifoWr    <= '0';
            dataFifoRd   <= '1';
            nxtFirst     <= '0';

            if countFifoError = '1' then
               nxtRxState <= ST_RX_DUMP;
            else
               nxtRxState <= ST_RX_HEADA;
            end if;

         when ST_RX_DUMP =>
            rxCntRst     <= '0';
            countFifoRd  <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= '0';
            nxtFifoType  <= (others=>'0');
            nxtFifoWr    <= '0';
            nxtFirst     <= '0';

            if rxCount = countFifoDout then
               nxtRxState <= ST_RX_IDLE;
               dataFifoRd <= '0';
            else
               nxtRxState <= curRxState;
               dataFifoRd <= '1';
            end if;

         when ST_RX_HEADA =>
            rxCntRst     <= '0';
            countFifoRd  <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= dataFifoDout(7);
            nxtFifoType  <= dataFifoDout(5 downto 4);
            nxtFifoWr    <= '0';
            nxtFirst     <= '1';

            if rxCount = countFifoDout then
               nxtRxState <= ST_RX_IDLE;
               dataFifoRd <= '0';
            else
               nxtRxState <= ST_RX_HEADB;
               dataFifoRd <= '1';
            end if;

         when ST_RX_HEADB =>
            rxCntRst     <= '0';
            countFifoRd  <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= intFifoSOF;
            nxtFifoType  <= intFifoType;
            nxtFifoWr    <= '0';
            nxtFirst     <= '1';

            if rxCount = countFifoDout then
               nxtRxState <= ST_RX_IDLE;
               dataFifoRd <= '0';
            else
               nxtRxState <= ST_RX_HIGH;
               dataFifoRd <= '1';
            end if;

         when ST_RX_HIGH =>
            rxCntRst                 <= '0';
            countFifoRd              <= '0';
            nxtFifoData(15 downto 8) <= dataFifoDout;
            nxtFifoData(7  downto 0) <= (others=>'0');
            nxtFifoSOF               <= intFifoSOF and intFirst;
            nxtFifoType              <= intFifoType;
            nxtFifoWr                <= '0';
            nxtFirst                 <= intFirst;

            if rxCount = countFifoDout then
               nxtRxState <= ST_RX_IDLE;
               dataFifoRd <= '0';
            else
               nxtRxState <= ST_RX_LOW;
               dataFifoRd <= '1';
            end if;

         when ST_RX_LOW  =>
            rxCntRst                 <= '0';
            countFifoRd              <= '0';
            nxtFifoData(15 downto 8) <= intFifoData(15 downto 8);
            nxtFifoData(7  downto 0) <= dataFifoDout;
            nxtFifoSOF               <= intFifoSOF and intFirst;
            nxtFifoType              <= intFifoType;
            nxtFirst                 <= '0';
            nxtFifoWr                <= '1';

            -- Detect last
            if rxCount = countFifoDout then
               nxtRxState <= ST_RX_IDLE;
               dataFifoRd <= '0';
            else
               nxtRxState <= ST_RX_HIGH;
               dataFifoRd <= '1';
            end if;

         when others =>
            rxCntRst     <= '0';
            dataFifoRd   <= '0';
            countFifoRd  <= '0';
            nxtFifoData  <= (others=>'0');
            nxtFifoSOF   <= '0';
            nxtFifoType  <= (others=>'0');
            nxtFifoWr    <= '0';
            nxtFirst     <= '0';
            nxtRxState   <= ST_RX_IDLE;
      end case;
   end process;

end KpixDataFrmtr;
