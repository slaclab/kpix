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
use work.KpixConPkg.all;

entity UpstreamData is 
   port ( 

      -- Kpix clock, reset
      sysClk        : in    std_logic;                       -- 125Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- Ethernet clock & reset
      gtpClk        : in    std_logic;                       -- 125Mhz gtp clock
      gtpClkRst     : in    std_logic;                       -- Synchronous reset input

      -- Train data receiver, kpix clock
      trainFifoReq  : in    std_logic;                       -- FIFO Write Request
      trainFifoAck  : out   std_logic;                       -- FIFO Write Grant
      trainFifoSOF  : in    std_logic;                       -- FIFO Word SOF
      trainFifoEOF  : in    std_logic;                       -- FIFO Word EOF
      trainFifoWr   : in    std_logic;                       -- FIFO Write Strobe
      trainFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix Response receiver, kpix clock
      kpixRspReq    : in    std_logic;                       -- FIFO Write Request
      kpixRspAck    : out   std_logic;                       -- FIFO Write Grant
      kpixRspWr     : in    std_logic;                       -- FIFO Write
      kpixRspSOF    : in    std_logic;                       -- FIFO Word SOF
      kpixRspEOF    : in    std_logic;                       -- FIFO Word EOF
      kpixRspData   : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Local Data Response receiver, kpix clock
      locFifoReq    : in    std_logic;                       -- FIFO Write Request
      locFifoAck    : out   std_logic;                       -- FIFO Write Grant
      locFifoWr     : in    std_logic;                       -- FIFO Write
      locFifoSOF    : in    std_logic;                       -- FIFO Word SOF
      locFifoEOF    : in    std_logic;                       -- FIFO Word EOF
      locFifoData   : in    std_logic_vector(15 downto 0);   -- FIFO Word

      -- Interface to USB word transmitter, sysclock
      txFifoValid   : out   std_logic;
      txFifoReady   : in    std_logic;
      txFifoData    : out   std_logic_vector(15 downto 0);   -- TX FIFO Data
      txFifoSOF     : out   std_logic;                       -- TX FIFO Start of Frame
      txFifoEOF     : out   std_logic;                       -- TX FIFO End of Frame
      txFifoType    : out   std_logic_vector(1  downto 0);   -- TX FIFO Data Type

      -- Flag indicating if there is space for another train of data
      trainFifoFull : out   std_logic;                       -- Train FIFO is full

      -- Debug
      csControl   : inout std_logic_vector(35 downto 0)    -- Chip Scope Control
   );
end UpstreamData;


-- Define architecture
architecture UpstreamData of UpstreamData is

   -- Local signals
   signal fifoDin      : std_logic_vector(19 downto 0);
   signal fifoDout     : std_logic_vector(19 downto 0);
   signal fifoCount    : std_logic_vector(12 downto 0);
   signal fifoFull     : std_logic;
   signal fifoAFull    : std_logic;
   signal muxFifoWr    : std_logic;
   signal muxFifoReq   : std_logic;
   signal muxFifoSOF   : std_logic;
   signal muxFifoEOF   : std_logic;
   signal muxFifoType  : std_logic_vector(1  downto 0);
   signal muxFifoData  : std_logic_vector(15 downto 0);
   signal muxEn        : std_logic;
   signal muxSel       : std_logic_vector(1  downto 0);
   signal nxtSrc       : std_logic_vector(1  downto 0);
   signal nxtReq       : std_logic;
   signal intKpixRspAck: std_logic;
   signal intLocFifoAck: std_logic;
   signal pktNum       : std_logic_vector(4  downto 0);
   signal intValid     : std_logic;
   signal txFifoRd     : std_logic;
   signal txFifoEmpty  : std_logic;

   -- State machine, reciever
   constant ST_IDLE  : std_logic := '0';
   constant ST_MOVE  : std_logic := '1';
   signal   curState : std_logic;

   -- Chip Scope signals
   constant enableChipScope : integer := 0;
   signal sysDebug          : std_logic_vector(63 downto 0);
   
begin

   -- Debug Block
   --sysDebug (63 downto 32) <= kpixRspReq;
   sysDebug (36)           <= fifoAFull;
   sysDebug (35)           <= fifoFull;
   sysDebug (34 downto 30) <= pktNum;
   sysDebug (29)           <= locFifoReq;
   sysDebug (28)           <= kpixRspReq;
   sysDebug (27)           <= trainFifoReq;
   sysDebug (26)           <= nxtReq;
   sysDebug (25)           <= muxFifoWr;
   sysDebug (24)           <= locFifoWr;
   sysDebug (23)           <= kpixRspWr;
   sysDebug (22)           <= trainFifoWr;
   sysDebug (21 downto 20) <= muxSel;
   sysDebug (19)           <= muxEn;
   sysDebug (18)           <= muxFifoEOF;
   sysDebug (17)           <= muxFifoSOF;
   sysDebug (16)           <= muxFifoReq;
   sysDebug (15 downto 0)  <= muxFifoData;
   
   chipscope : if (enableChipScope = 1) generate   
      U_DataRx_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => sysClk,
         TRIG0   => sysDebug
      );
   end generate chipscope;

--    process (sysRst, sysClk) begin
--       if sysRst = '1' then
--          pktNum <= (OTHERS=>'0') after tpd;
--       elsif rising_edge(sysClk) then
--          if trainFifoEOF = '1' then
--             pktNum <= pktNum + 1 after tpd;
--          end if;
--       end if;
--    end process;

   locFifoAck <= intLocFifoAck;
   kpixRspAck <= intKpixRspAck;

   -- Combinitorial source selector
   process ( muxEn, muxSel, trainFifoWr, trainFifoData, trainFifoSOF,
             kpixRspData, kpixRspSOF, locFifoData, locFifoSOF,
             trainFifoReq, kpixRspReq, locFifoReq,
             trainFifoEOF, kpixRspEOF, locFifoEOF, fifoAFull ) begin
      if muxEn = '1' then
         if muxSel = "10" then
               muxFifoData   <= locFifoData;
               muxFifoSOF    <= locFifoSOF;
               muxFifoReq    <= locFifoReq;
               muxFifoEOF    <= locFifoEOF;
               muxFifoType   <= "10";
               intKpixRspAck <= '0';
               intLocFifoAck <= not fifoAFull;--'1';
               trainFifoAck  <= '0';
         elsif muxSel = "01" then
               muxFifoData   <= trainFifoData;
               muxFifoSOF    <= trainFifoSOF;
               muxFifoEOF    <= trainFifoEOF;
               muxFifoReq    <= trainFifoReq;
               muxFifoType   <= "01";
               intKpixRspAck <= '0';
               intLocFifoAck <= '0';
               trainFifoAck  <= not fifoAFull;--'1';
         elsif muxSel = "00" then
               muxFifoData   <= kpixRspData;
               muxFifoSOF    <= kpixRspSOF;
               muxFifoReq    <= kpixRspReq;
               muxFifoEOF    <= kpixRspEOF;
               muxFifoType   <= "00";
               intKpixRspAck <= not fifoAFull;--'1';
               intLocFifoAck <= '0';
               trainFifoAck  <= '0';
         else
               muxFifoData   <= (others=>'0');
               muxFifoSOF    <= '0';
               muxFifoReq    <= '0';
               muxFifoEOF    <= '0';
               muxFifoType   <= "00";
               trainFifoAck  <= '0';
               intKpixRspAck <= '0';
               intLocFifoAck <= '0';
         end if;
      else
         muxFifoData   <= (others=>'0');
         muxFifoSOF    <= '0';
         muxFifoEOF    <= '0';
         muxFifoReq    <= '0';
         muxFifoType   <= "00";
         trainFifoAck  <= '0';
         intKpixRspAck <= '0';
         intLocFifoAck <= '0';
      end if;
   end process;


   -- Arbitrate for the next source based upon the current source
   -- and status of valid inputs
   process ( muxSel, trainFifoReq, kpixRspReq, locFifoReq ) begin
      case muxSel is
         when "00" =>
            if    kpixRspReq   = '1' then nxtSrc <= "00"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "01"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "10"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "01" =>
            if    trainFifoReq = '1' then nxtSrc <= "01"; nxtReq <= '1';
            elsif locFifoReq   = '1' then nxtSrc <= "10"; nxtReq <= '1';
            elsif kpixRspReq   = '1' then nxtSrc <= "00"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when "10" =>
            if    locFifoReq   = '1' then nxtSrc <= "10"; nxtReq <= '1';
            elsif kpixRspReq   = '1' then nxtSrc <= "00"; nxtReq <= '1';
            elsif trainFifoReq = '1' then nxtSrc <= "01"; nxtReq <= '1';
            else  nxtSrc <= muxSel; nxtReq <= '0'; end if;
         when others =>
            nxtSrc <= muxSel; nxtReq <= '0';
      end case;
   end process;


   -- Data movement state machine
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         muxSel    <= (others=>'0') after tpd;
         muxEn     <= '0'           after tpd;
         muxfifoWr <= '0'           after tpd;
         fifoAFull  <= '0'           after tpd;
         curState  <= ST_IDLE       after tpd;
      elsif rising_edge(sysClk) then

         muxFifoWr <= kpixRspWr or locFifoWr or trainFifoWr after tpd;

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
         
         if fifoCount > 8000 then
            fifoAFull <= '1' after tpd;
         else
            fifoAFull <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Connect data to FIFO
   fifoDin(19)           <= muxFifoEOF;
   fifoDin(18)           <= muxFifoSOF;
   fifoDin(17 downto 16) <= muxFifoType;
   fifoDin(15 downto  0) <= muxFifoData;

   -- Async FIFO
   U_UsFifo : afifo_20x8k port map (
      din           => fifoDin,
      rd_clk        => gtpClk,
      rd_en         => txFifoRd,
      rst           => sysRst,
      wr_clk        => sysClk,
      wr_en         => muxFifoWr,
      dout          => fifoDout,
      empty         => txFifoEmpty,
      full          => fifoFull,
      wr_data_count => fifoCount
   );

   -- Ping pong between halfs
   process ( gtpClk, gtpClkRst ) begin
      if gtpClkRst = '1' then
         intValid <= '0' after tpd;
      elsif rising_edge(gtpClk) then
         if txFifoRd = '1' then
            intValid <= '1' after tpd;
         elsif txFifoReady = '1' then
            intValid <= '0' after tpd;
         end if;

      end if;
   end process;

   -- FIFO Full Indication
   trainFifoFull <= '0' when fifoCount = 0 else '1';

   -- Fifo ready control
   txFifoRd <= '1' when txFifoEmpty = '0' and (intValid = '0' or txFifoReady = '1') else '0';
   
   -- Connect outgoing FIFO data
   txFifoData  <= fifoDout(15 downto 0);
   txFifoType  <= fifoDout(17 downto 16);
   txFifoSOF   <= fifoDout(18);
   txFifoEOF   <= fifoDout(19);
   txFifoValid <= intValid;

end UpstreamData;

