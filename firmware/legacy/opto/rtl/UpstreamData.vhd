-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Upstream Data Buffer
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : UpstreamData.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the upstream data frame buffer.
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

entity UpstreamData is 
   port ( 

      -- Kpix clock, reset
      sysClk        : in    std_logic;                       -- 20Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- Kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz system clock
      kpixRst       : in    std_logic;                       -- System reset

      -- Train data receiver, kpix clock
      trainFifoReq  : in    std_logic;                       -- FIFO Write Request
      trainFifoAck  : out   std_logic;                       -- FIFO Write Grant
      trainFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      trainFifoWr   : in    std_logic;                       -- FIFO Write Strobe
      trainFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix A Response receiver, kpix clock
      kpixAFifoReq  : in    std_logic;                       -- FIFO Write Request
      kpixAFifoAck  : out   std_logic;                       -- FIFO Write Grant
      kpixAFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      kpixAFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix B Response receiver, kpix clock
      kpixBFifoReq  : in    std_logic;                       -- FIFO Write Request
      kpixBFifoAck  : out   std_logic;                       -- FIFO Write Grant
      kpixBFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      kpixBFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix C Response receiver, kpix clock
      kpixCFifoReq  : in    std_logic;                       -- FIFO Write Request
      kpixCFifoAck  : out   std_logic;                       -- FIFO Write Grant
      kpixCFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      kpixCFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix D Response receiver, kpix clock
      kpixDFifoReq  : in    std_logic;                       -- FIFO Write Request
      kpixDFifoAck  : out   std_logic;                       -- FIFO Write Grant
      kpixDFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      kpixDFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Local Data Response receiver, kpix clock
      locFifoReq    : in    std_logic;                       -- FIFO Write Request
      locFifoAck    : out   std_logic;                       -- FIFO Write Grant
      locFifoSOF    : in    std_logic;                       -- FIFO Word SOF
      locFifoData   : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Interface to USB word transmitter, sysclock
      txFifoData    : out   std_logic_vector(15 downto 0);   -- TX FIFO Data
      txFifoSOF     : out   std_logic;                       -- TX FIFO Start of Frame
      txFifoType    : out   std_logic_vector(1  downto 0);   -- TX FIFO Data Type
      txFifoRd      : in    std_logic;                       -- TX FIFO Read
      txFifoEmpty   : out   std_logic;                       -- TX FIFO Empty

      -- Flag indicating if there is space for another train of data
      trainFifoFull : out   std_logic                        -- Train FIFO is full
   );
end UpstreamData;


-- Define architecture
architecture UpstreamData of UpstreamData is

   -- ASYNC FIFO
   component afifo_19x8k port (
      din:           IN std_logic_VECTOR(18 downto 0);
      rd_clk:        IN std_logic;
      rd_en:         IN std_logic;
      rst:           IN std_logic;
      wr_clk:        IN std_logic;
      wr_en:         IN std_logic;
      dout:          OUT std_logic_VECTOR(18 downto 0);
      empty:         OUT std_logic;
      full:          OUT std_logic;
      wr_data_count: OUT std_logic_VECTOR(12 downto 0));
   end component;


   -- Local signals
   signal fifoDin      : std_logic_vector(18 downto 0);
   signal fifoDout     : std_logic_vector(18 downto 0);
   signal fifoCount    : std_logic_vector(12 downto 0);
   signal muxFifoWr    : std_logic;
   signal muxFifoReq   : std_logic;
   signal muxFifoSOF   : std_logic;
   signal muxFifoType  : std_logic_vector(1  downto 0);
   signal muxFifoData  : std_logic_vector(15 downto 0);
   signal muxEn        : std_logic;
   signal muxSel       : std_logic_vector(2  downto 0);
   signal nxtSrc       : std_logic_vector(2  downto 0);
   signal nxtReq       : std_logic;

   -- State machine, reciever
   constant ST_IDLE  : std_logic := '0';
   constant ST_MOVE  : std_logic := '1';
   signal   curState : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin


   -- Combinitorial source selector
   process ( muxEn, muxSel, trainFifoWr, trainFifoData, trainFifoSOF,
             kpixAFifoData, kpixAFifoSOF, kpixBFifoData, kpixBFifoSOF, 
             kpixCFifoData, kpixCFifoSOF, kpixDFifoData, kpixDFifoSOF,
             locFifoData, locFifoSOF, trainFifoReq, kpixAFifoReq, 
             kpixBFifoReq, kpixCFifoReq, kpixDFifoReq, locFifoReq ) begin
      if muxEn = '1' then
         case muxSel is 
            when "000" =>
               muxFifoWr    <= trainFifoWr;
               muxFifoData  <= trainFifoData;
               muxFifoSOF   <= trainFifoSOF;
               muxFifoType  <= "01";
               muxFifoReq   <= trainFifoReq;
               trainFifoAck <= '1';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '0';
               locFifoAck   <= '0';
            when "001" =>
               muxFifoWr    <= kpixAFifoReq;
               muxFifoData  <= kpixAFifoData;
               muxFifoSOF   <= kpixAFifoSOF;
               muxFifoReq   <= kpixAFifoReq;
               muxFifoType  <= "00";
               trainFifoAck <= '0';
               kpixAFifoAck <= '1';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '0';
               locFifoAck   <= '0';
            when "010" =>
               muxFifoWr    <= kpixBFifoReq;
               muxFifoData  <= kpixBFifoData;
               muxFifoSOF   <= kpixBFifoSOF;
               muxFifoReq   <= kpixBFifoReq;
               muxFifoType  <= "00";
               trainFifoAck <= '0';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '1';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '0';
               locFifoAck   <= '0';
            when "011" =>
               muxFifoWr    <= kpixCFifoReq;
               muxFifoData  <= kpixCFifoData;
               muxFifoSOF   <= kpixCFifoSOF;
               muxFifoReq   <= kpixCFifoReq;
               muxFifoType  <= "00";
               trainFifoAck <= '0';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '1';
               kpixDFifoAck <= '0';
               locFifoAck   <= '0';
            when "100" =>
               muxFifoWr    <= kpixDFifoReq;
               muxFifoData  <= kpixDFifoData;
               muxFifoSOF   <= kpixDFifoSOF;
               muxFifoReq   <= kpixDFifoReq;
               muxFifoType  <= "00";
               trainFifoAck <= '0';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '1';
               locFifoAck   <= '0';
            when "101" =>
               muxFifoWr    <= locFifoReq;
               muxFifoData  <= locFifoData;
               muxFifoSOF   <= locFifoSOF;
               muxFifoReq   <= locFifoReq;
               muxFifoType  <= "10";
               trainFifoAck <= '0';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '0';
               locFifoAck   <= '1';
            when others =>
               muxFifoWr    <= '0';
               muxFifoData  <= (others=>'0');
               muxFifoSOF   <= '0';
               muxFifoReq   <= '0';
               muxFifoType  <= "00";
               trainFifoAck <= '0';
               kpixAFifoAck <= '0';
               kpixBFifoAck <= '0';
               kpixCFifoAck <= '0';
               kpixDFifoAck <= '0';
               locFifoAck   <= '0';
         end case;
      else
         muxFifoWr    <= '0';
         muxFifoData  <= (others=>'0');
         muxFifoSOF   <= '0';
         muxFifoReq   <= '0';
         muxFifoType  <= "00";
         trainFifoAck <= '0';
         kpixAFifoAck <= '0';
         kpixBFifoAck <= '0';
         kpixCFifoAck <= '0';
         kpixDFifoAck <= '0';
         locFifoAck   <= '0';
      end if;
   end process;


   -- Arbitrate for the next source based upon the current source
   -- and status of valid inputs
   process ( muxSel, trainFifoReq, kpixAFifoReq, kpixBFifoReq,
         kpixCFifoReq, kpixDFifoReq, locFifoReq ) begin
      case muxSel is
         when "000" =>
            if    kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            elsif kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            elsif kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            elsif kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "001" =>
            if    kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            elsif kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            elsif kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            elsif kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "010" =>
            if    kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            elsif kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            elsif kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            elsif kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "011" =>
            if    kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            elsif kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            elsif kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            elsif kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "100" =>
            if    locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            elsif kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            elsif kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            elsif kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            elsif kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "101" =>
            if    trainFifoReq = '1' then nxtSrc <= "000"; nxtReq <= '1';
            elsif kpixAFifoReq = '1' then nxtSrc <= "001"; nxtReq <= '1';
            elsif kpixBFifoReq = '1' then nxtSrc <= "010"; nxtReq <= '1';
            elsif kpixCFifoReq = '1' then nxtSrc <= "011"; nxtReq <= '1';
            elsif kpixDFifoReq = '1' then nxtSrc <= "100"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "101"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when others =>
            nxtSrc <= muxSel; nxtReq <= '0';
      end case;
   end process;


   -- Data movement state machine
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         muxSel   <= (others=>'0') after tpd;
         muxEn    <= '0'           after tpd;
         curState <= ST_IDLE       after tpd;
      elsif rising_edge(kpixClk) then

         -- State machine
         case curState is

            -- Idle, wait for requester
            when ST_IDLE =>

               -- New source
               if nxtReq = '1' then
                  muxSel   <= nxtSrc  after tpd;
                  muxEn    <= '1'     after tpd;
                  curState <= ST_MOVE after tpd;
               else
                  muxEn <= '0' after tpd;
               end if;

            -- Moving data into FIFO
            when ST_MOVE =>

               -- Request has gone away
               if muxFifoReq = '0' then
                  curState <= ST_IDLE after tpd;
                  muxEn    <= '0'     after tpd;
               end if;

            when others => curState <= ST_IDLE;
         end case;
      end if;
   end process;


   -- Connect data to FIFO
   fifoDin(18)           <= muxFifoSOF;
   fifoDin(17 downto 16) <= muxFifoType;
   fifoDin(15 downto  0) <= muxFifoData;

   -- Async FIFO
   U_UsFifo : afifo_19x8k port map (
      din    => fifoDin,
      rd_clk => sysClk,
      rd_en  => txFifoRd,
      rst    => sysRst,
      wr_clk => kpixClk,
      wr_en  => muxFifoWr,
      dout   => fifoDout,
      empty  => txFifoEmpty,
      full   => open,
      wr_data_count => fifoCount
   );

   -- FIFO Full Indication
   trainFifoFull <= '0' when fifoCount = 0 else '1';

   -- Connect outgoing FIFO data
   txFifoData <= fifoDout(15 downto 0);
   txFifoType <= fifoDout(17 downto 16);
   txFifoSOF  <= fifoDout(18);

end UpstreamData;

