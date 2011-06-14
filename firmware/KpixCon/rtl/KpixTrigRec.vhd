-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Trigger Record Generator
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixTrigRec.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Generates trigger records for sample stream.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 09/11/2009: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixTrigRec is port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                       -- 60Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
      kpixRst       : in    std_logic;                       -- System reset

      -- Trigger Input
      extRecord     : in    std_logic;                       -- External trigger accept input, To be implemented

      -- Bunch clock input
      kpixBunch     : in    std_logic_vector(12 downto 0);   -- Bunch count value

      -- FIFO Interface, req/ack type interface
      fifoReq       : out   std_logic;                       -- FIFO Write Request
      fifoAck       : in    std_logic;                       -- FIFO Write Grant
      fifoWr        : out   std_logic;                       -- FIFO Write Strobe
      fifoData      : out   std_logic_vector(15 downto 0)    -- FIFO Word
   );
end KpixTrigRec;


-- Define architecture
architecture KpixTrigRec of KpixTrigRec is

   -- Local signals
   signal trigDin      : std_logic_vector(12 downto 0);
   signal trigRd       : std_logic;
   signal trigWr       : std_logic;
   signal trigDout     : std_logic_vector(12 downto 0);
   signal trigEmpty    : std_logic;
   signal trigFull     : std_logic;
   signal nxtReq       : std_logic;
   signal nxtWr        : std_logic;
   signal nxtData      : std_logic_vector(15 downto 0);
   signal extRecordTmp : std_logic;
   signal extRecordInt : std_logic;
   signal extRecordDly : std_logic;

   -- State machine, FIFO read
   constant RD_IDLE    : std_logic_vector(2 downto 0) := "000";
   constant RD_REQ     : std_logic_vector(2 downto 0) := "001";
   constant RD_READ    : std_logic_vector(2 downto 0) := "010";
   constant RD_WORD0   : std_logic_vector(2 downto 0) := "011";
   constant RD_WORD1   : std_logic_vector(2 downto 0) := "100";
   constant RD_WORD2   : std_logic_vector(2 downto 0) := "101";
   constant RD_WORD3   : std_logic_vector(2 downto 0) := "110";
   constant RD_DONE    : std_logic_vector(2 downto 0) := "111";
   signal   curRdState : std_logic_vector(2 downto 0);
   signal   nxtRdState : std_logic_vector(2 downto 0);

begin


   -- Write Sync Logic
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         trigDin      <= (others=>'0') after tpd;
         trigWr       <= '0'           after tpd;
         extRecordTmp <= '0'           after tpd;
         extRecordInt <= '0'           after tpd;
         extRecordDly <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- Double sync input
         extRecordTmp <= extRecord    after tpd;
         extRecordInt <= extRecordTmp after tpd;

         -- Delay for edge detection
         extRecordDly <= extRecordInt after tpd;

         -- Data is always timestamp
         trigDin <= kpixBunch after tpd;

         -- Write timestamp to fifo if not full
         trigWr <= (not trigFull) and extRecordInt and (not extRecordDly) after tpd;

      end if;
   end process;


   -- FIFO
   U_TrigFifo: afifo_18x1k port map (
      wr_clk             => kpixClk,
      rd_clk             => kpixClk,
      din (17 downto 13) => (OTHERS=>'0'),
      din (12 downto  0) => trigDin,
      rd_en              => trigRd,
      rst                => kpixRst,
      wr_en              => trigWr,
      dout(17 downto 13) => open,
      dout(12 downto  0) => trigDout,
      empty              => trigEmpty,
      full               => trigFull
   );


   -- Read state sync logic
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         fifoReq    <= '0'           after tpd;
         fifoWr     <= '0'           after tpd;
         fifoData   <= (others=>'0') after tpd;
         curRdState <= RD_IDLE       after tpd;
      elsif rising_edge(kpixClk) then

         -- Fifo Control
         fifoReq    <= nxtReq  after tpd;
         fifoWr     <= nxtWr   after tpd;
         fifoData   <= nxtData after tpd;

         -- Current State
         curRdState <= nxtRdState after tpd;

      end if;
   end process;


   -- Read async state logic
   process ( curRdState, trigEmpty, trigDout, fifoAck ) begin
      case curRdState is

         -- Idle, wait for data in FIFO
         when RD_IDLE  => 
            nxtReq     <= '0';
            nxtWr      <= '0';
            nxtData    <= (others=>'0');
            trigRd     <= '0';

            -- FIFO has data
            if trigEmpty = '0' then
               nxtRdState <= RD_REQ;
            else
               nxtRdState <= curRdState;
            end if;

         -- Request read
         when RD_REQ   => 
            nxtReq     <= '1';
            nxtWr      <= '0';
            nxtData    <= (others=>'0');
            trigRd     <= '0';

            -- FIFO has data
            if fifoAck = '1' then
               nxtRdState <= RD_READ;
            else
               nxtRdState <= curRdState;
            end if;

         -- Assert read strobe, one clock
         when RD_READ  => 
            nxtReq     <= '1';
            nxtWr      <= '0';
            nxtData    <= (others=>'0');
            trigRd     <= '1';
            nxtRdState <= RD_WORD0;

         -- Generate sample word 0
         when RD_WORD0 => 
            nxtReq                <= '1';
            nxtWr                 <= '1';
            nxtData(15 downto 14) <= "01";          -- Marker
            nxtData(13 downto 12) <= "00";          -- Bucket = 0
            nxtData(11 downto 10) <= "00";          -- Lower 2-bit Kpix address
            nxtData(9  downto  0) <= (others=>'0'); -- Channel = 0
            trigRd                <= '0';
            nxtRdState            <= RD_WORD1;

         -- Generate sample word 1
         when RD_WORD1 => 
            nxtReq                <= '1';
            nxtWr                 <= '1';
            nxtData(15)           <= '1';                   -- Special Flag = 1
            nxtData(14)           <= trigDout(12);          -- Time Bit 12
            nxtData(13)           <= '0';                   -- Range Bit = 0
            nxtData(12)           <= '0';                   -- Empty Bit = 0
            nxtData(11 downto  0) <= trigDout(11 downto 0); -- Time, lower bits
            trigRd                <= '0';
            nxtRdState            <= RD_WORD2;

         -- Generate sample word 2
         when RD_WORD2 => 
            nxtReq                <= '1';
            nxtWr                 <= '1';
            nxtData(15)           <= '1';           -- Future Bit = 1
            nxtData(14)           <= '0';           -- Trig Bit = 0
            nxtData(13)           <= '0';           -- Bad Count = 0
            nxtData(12 downto  0) <= (others=>'0'); -- ADC Value = 0
            trigRd                <= '0';
            nxtRdState            <= RD_WORD3;

         -- Generate sample word 3
         when RD_WORD3 => 
            nxtReq                <= '1';
            nxtWr                 <= '1';
            nxtData(15 downto 12) <= "1000";        -- Upper 4-bit Kpix Address
            nxtData(11 downto  0) <= (others=>'0'); -- Empty Frame
            trigRd                <= '0';

            -- Any more samples?
            if trigEmpty = '0' then
               nxtRdState <= RD_READ;
            else
               nxtRdState <= RD_DONE;
            end if;

         -- Clear req, wait for ack to go away
         when RD_DONE => 
            nxtReq  <= '0';
            nxtWr   <= '0';
            nxtData <= (others=>'0');
            trigRd  <= '0';

            -- Any more samples?
            if fifoAck = '0' then
               nxtRdState <= RD_IDLE;
            else
               nxtRdState <= curRdState;
            end if;

         when others => 
            nxtReq     <= '0';
            nxtWr      <= '0';
            nxtData    <= (others=>'0');
            trigRd     <= '0';
            nxtRdState <= RD_IDLE;
      end case;
   end process;

end KpixTrigRec;

