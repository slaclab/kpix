-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Response Data Receiver
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixRespData.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the response data receiver.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 3/25/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixRespData is 
   port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                       -- 125Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- Kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
      kpixRst       : in    std_logic;                       -- System reset

      -- RspRx Interface, req/ack type interface
      kpixRspReq    : out   std_logic;                       -- FIFO Write Request
      kpixRspAck    : in    std_logic;                       -- FIFO Write Grant
      kpixRspWr     : out   std_logic;                       -- FIFO Write
      kpixRspSOF    : out   std_logic;                       -- FIFO Word SOF
      kpixRspEOF    : out   std_logic;                       -- FIFO Word EOF
      kpixRspData   : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Parity error output
      parErrCount   : out   std_logic_vector(7 downto 0);    -- Parity error detected
      parErrRst     : in    std_logic;                       -- Parity error count reset

      -- Incoming serial data
      rspData       : in    std_logic_vector(31 downto 0);   -- Incoming serial data
      rspDataL      : in    std_logic ;                      -- Incoming serial data

      -- Status Data
      statusValue   : out   array32x32;                      -- KPIX status register
      statusRx      : out   std_logic_vector(31 downto 0);   -- KPIX status received

      -- Kpix version
      kpixVer       : in    std_logic ;                      -- Kpix Version

      -- Debug
      csControl     : inout std_logic_vector(35 downto 0)    -- Chip Scope Control
   );
end KpixRespData;

-- Define architecture
architecture KpixRespData of KpixRespData is

   -- Local Signals
   signal kpxRspReq     : std_logic_vector(31 downto 0);
   signal kpxRspAck     : std_logic_vector(31 downto 0);
   signal kpxRspSOF     : std_logic_vector(31 downto 0);
   signal kpxRspEOF     : std_logic_vector(31 downto 0);
   signal kpxRspData    : array32x16;
   signal kpixLRspReq   : std_logic;
   signal kpixLRspAck   : std_logic;
   signal kpixLRspSOF   : std_logic;
   signal kpixLRspEOF   : std_logic;
   signal kpixLRspData  : std_logic_vector(15 downto 0);
   signal parErrorL     : std_logic;
   signal muxEn         : std_logic;
   signal muxSel        : std_logic_vector(5  downto 0);
   signal nxtSrc        : std_logic_vector(5  downto 0);
   signal nxtReq        : std_logic;
   signal fifoWr        : std_logic;
   signal fifoRd        : std_logic;
   signal fifoEOFout    : std_logic;
   signal fifoSOFout    : std_logic;
   signal fifoEOFin     : std_logic;
   signal fifoSOFin     : std_logic;
   signal fifoEmpty     : std_logic;
   signal fifoFull      : std_logic;
   signal fifoDin       : std_logic_vector(15 downto 0);
   signal fifoDout      : std_logic_vector(15 downto 0);
   signal intErrCount   : std_logic_vector(7  downto 0);
   signal parError      : std_logic_vector(31 downto 0);
   
begin

   -- Response error counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intErrCount <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then
         if parErrRst = '1' then
            intErrCount <= (others=>'0') after tpd;
         elsif (intErrCount /= 255 and (parError > 0 or parErrorL = '1')) then
               intErrCount <= intErrCount + 1 after tpd;
         end if;
      end if;
   end process;
   
   parErrCount <= intErrCount;
   kpixRspReq  <= not fifoEmpty;
   kpixRspWr   <= kpixRspAck and (not fifoEmpty);
   kpixRspEOF  <= fifoEOFout;
   kpixRspSOF  <= fifoSOFout;
   kpixRspData <= fifoDout;
   fifoRd      <= kpixRspAck and (not fifoEmpty);
   
   U_RspFifo : afifo_18x1k port map(
      rd_clk             => sysClk,
      rd_en              => fifoRd,
      dout(17)           => fifoEOFout,
      dout(16)           => fifoSOFout,
      dout(15 downto 0)  => fifoDout,
      rst                => kpixRst,
      wr_clk             => kpixClk,
      wr_en              => fifoWr,
      din(17)            => fifoEOFin,
      din(16)            => fifoSOFin,
      din(15 downto 0)   => fifoDin ,
      empty              => fifoEmpty,
      full               => fifoFull);

   -- Arbitrate for the next source based upon the current source
   -- and status of valid inputs
   process ( muxSel, kpxRspReq, kpixLRspReq) begin
      if (kpxRspReq > 0 or kpixLRspReq = '1') then
         nxtSrc <= priority_encoder (muxSel, kpxRspReq, kpixLRspReq, '0', '0');
         nxtReq <= '1';
      else
         nxtSrc <= muxSel;
         nxtReq <= '0';
      end if;
   end process;

   -- Combinitorial source selector
   process ( muxEn, muxSel, kpxRspData, kpxRspSOF, kpixLRspData,
             kpixLRspSOF, kpxRspReq, kpixLRspReq, kpxRspEOF, kpixLRspEOF) begin
      if muxEn = '1' then
         if muxSel = "100000" then
               fifoWr      <= kpixLRspReq;
               fifoDin     <= kpixLRspData;
               fifoSOFin   <= kpixLRspSOF;
               fifoEOFin   <= kpixLRspEOF;
               kpixLRspAck <= '1';
               kpxRspAck   <= (OTHERS=>'0');
         elsif muxSel < 32 then
               fifoWr      <= kpxRspReq (conv_integer(muxSel));
               fifoDin     <= kpxRspData(conv_integer(muxSel));
               fifoSOFin   <= kpxRspSOF (conv_integer(muxSel));
               fifoEOFin   <= kpxRspEOF (conv_integer(muxSel));
               kpixLRspAck <= '0';
               kpxRspAck   <= conv_5to32(muxSel(4 downto 0));
         end if;
      else
         fifoWr      <= '0';
         fifoDin     <= (others=>'0');
         fifoSOFin   <= '0';
         fifoEOFin   <= '0';
         kpixLRspAck <= '0';
         kpxRspAck   <= (OTHERS=>'0');
      end if;
   end process;

   -- Data movement state machine
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         muxSel   <= (others=>'0') after tpd;
         muxEn    <= '0'           after tpd;
      elsif rising_edge(kpixClk) then
         if nxtReq = '1' then
            muxSel   <= nxtSrc  after tpd;
            muxEn    <= '1'     after tpd;
         else
            muxEn <= '0' after tpd;
         end if;
      end if;
   end process;

   -- Local Kpix Response Processor
   U_RespRxL: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,      kpixRst     => kpixRst,
      fifoReq    => kpixLRspReq,  fifoAck     => kpixLRspAck,
      fifoSOF    => kpixLRspSOF,  fifoData    => kpixLRspData,
      parError   => parErrorL,    kpixAddr    => "100000",
      rspData    => rspDataL,
      kpixVer    => kpixVer,      statusValue => open,
      statusRx   => open,         fifoEOF     => kpixLRspEOF
   );

   -- Kpix 0 Response Processor
   U_RespRx0: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(0),   fifoAck     => kpxRspAck(0),
      fifoSOF    => kpxRspSOF(0),   fifoData    => kpxRspData(0),
      parError   => parError(0),    kpixAddr    => "000000",
      rspData    => rspData(0),
      kpixVer    => kpixVer,        statusValue => statusValue(0),
      statusRx   => statusRx(0),    fifoEOF     => kpxRspEOF(0),
      csControl  => csControl
   );

   -- Kpix 1 Response Processor
   U_RespRx1: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(1),   fifoAck     => kpxRspAck(1),
      fifoSOF    => kpxRspSOF(1),   fifoData    => kpxRspData(1),
      parError   => parError(1),    kpixAddr    => "000001",
      rspData    => rspData(1),
      kpixVer    => kpixVer,        statusValue => statusValue(1),
      statusRx   => statusRx(1),    fifoEOF     => kpxRspEOF(1),
      csControl  => csControl
   );

   -- Kpix 2 Response Processor
   U_RespRx2: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(2),   fifoAck     => kpxRspAck(2),
      fifoSOF    => kpxRspSOF(2),   fifoData    => kpxRspData(2),
      parError   => parError(2),    kpixAddr    => "000010",
      rspData    => rspData(2),
      kpixVer    => kpixVer,        statusValue => statusValue(2),
      statusRx   => statusRx(2),    fifoEOF     => kpxRspEOF(2)
   );

   -- Kpix 3 Response Processor
   U_RespRx3: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(3),   fifoAck     => kpxRspAck(3),
      fifoSOF    => kpxRspSOF(3),   fifoData    => kpxRspData(3),
      parError   => parError(3),    kpixAddr    => "000011",
      rspData    => rspData(3),
      kpixVer    => kpixVer,        statusValue => statusValue(3),
      statusRx   => statusRx(3),    fifoEOF     => kpxRspEOF(3)
   );

   -- Kpix 4 Response Processor
   U_RespRx4: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(4),   fifoAck     => kpxRspAck(4),
      fifoSOF    => kpxRspSOF(4),   fifoData    => kpxRspData(4),
      parError   => parError(4),    kpixAddr    => "000100",
      rspData    => rspData(4),
      kpixVer    => kpixVer,        statusValue => statusValue(4),
      statusRx   => statusRx(4),    fifoEOF     => kpxRspEOF(4)
   );

   -- Kpix 5 Response Processor
   U_RespRx5: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(5),   fifoAck     => kpxRspAck(5),
      fifoSOF    => kpxRspSOF(5),   fifoData    => kpxRspData(5),
      parError   => parError(5),    kpixAddr    => "000101",
      rspData    => rspData(5),
      kpixVer    => kpixVer,        statusValue => statusValue(5),
      statusRx   => statusRx(5),    fifoEOF     => kpxRspEOF(5)
   );

   -- Kpix 6 Response Processor
   U_RespRx6: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(6),   fifoAck     => kpxRspAck(6),
      fifoSOF    => kpxRspSOF(6),   fifoData    => kpxRspData(6),
      parError   => parError(6),    kpixAddr    => "000110",
      rspData    => rspData(6),
      kpixVer    => kpixVer,        statusValue => statusValue(6),
      statusRx   => statusRx(6),    fifoEOF     => kpxRspEOF(6)
   );

   -- Kpix 7 Response Processor
   U_RespRx7: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(7),   fifoAck     => kpxRspAck(7),
      fifoSOF    => kpxRspSOF(7),   fifoData    => kpxRspData(7),
      parError   => parError(7),    kpixAddr    => "000111",
      rspData    => rspData(7),
      kpixVer    => kpixVer,        statusValue => statusValue(7),
      statusRx   => statusRx(7),    fifoEOF     => kpxRspEOF(7)
   );

   -- Kpix 8 Response Processor
   U_RespRx8: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(8),   fifoAck     => kpxRspAck(8),
      fifoSOF    => kpxRspSOF(8),   fifoData    => kpxRspData(8),
      parError   => parError(8),    kpixAddr    => "001000",
      rspData    => rspData(8),
      kpixVer    => kpixVer,        statusValue => statusValue(8),
      statusRx   => statusRx(8),    fifoEOF     => kpxRspEOF(8),
      csControl  => csControl
   );

   -- Kpix 9 Response Processor
   U_RespRx9: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,        kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(9),   fifoAck     => kpxRspAck(9),
      fifoSOF    => kpxRspSOF(9),   fifoData    => kpxRspData(9),
      parError   => parError(9),    kpixAddr    => "001001",
      rspData    => rspData(9),
      kpixVer    => kpixVer,        statusValue => statusValue(9),
      statusRx   => statusRx(9),    fifoEOF     => kpxRspEOF(9)
   );

   -- Kpix 10 Response Processor
   U_RespRx10: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(10),   fifoAck     => kpxRspAck(10),
      fifoSOF    => kpxRspSOF(10),   fifoData    => kpxRspData(10),
      parError   => parError(10),    kpixAddr    => "001010",
      rspData    => rspData(10),
      kpixVer    => kpixVer,         statusValue => statusValue(10),
      statusRx   => statusRx(10),    fifoEOF     => kpxRspEOF(10)
   );

   -- Kpix 11 Response Processor
   U_RespRx11: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(11),   fifoAck     => kpxRspAck(11),
      fifoSOF    => kpxRspSOF(11),   fifoData    => kpxRspData(11),
      parError   => parError(11),    kpixAddr    => "001011",
      rspData    => rspData(11),
      kpixVer    => kpixVer,         statusValue => statusValue(11),
      statusRx   => statusRx(11),    fifoEOF     => kpxRspEOF(11)
   );

   -- Kpix 12 Response Processor
   U_RespRx12: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(12),   fifoAck     => kpxRspAck(12),
      fifoSOF    => kpxRspSOF(12),   fifoData    => kpxRspData(12),
      parError   => parError(12),    kpixAddr    => "001100",
      rspData    => rspData(12),
      kpixVer    => kpixVer,         statusValue => statusValue(12),
      statusRx   => statusRx(12),    fifoEOF     => kpxRspEOF(12)
   );

   -- Kpix 13 Response Processor
   U_RespRx13: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(13),   fifoAck     => kpxRspAck(13),
      fifoSOF    => kpxRspSOF(13),   fifoData    => kpxRspData(13),
      parError   => parError(13),    kpixAddr    => "001101",
      rspData    => rspData(13),
      kpixVer    => kpixVer,         statusValue => statusValue(13),
      statusRx   => statusRx(13),    fifoEOF     => kpxRspEOF(13)
   );

   -- Kpix 14 Response Processor
   U_RespRx14: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(14),   fifoAck     => kpxRspAck(14),
      fifoSOF    => kpxRspSOF(14),   fifoData    => kpxRspData(14),
      parError   => parError(14),    kpixAddr    => "001110",
      rspData    => rspData(14),
      kpixVer    => kpixVer,         statusValue => statusValue(14),
      statusRx   => statusRx(14),    fifoEOF     => kpxRspEOF(14)
   );

   -- Kpix 15 Response Processor
   U_RespRx15: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(15),   fifoAck     => kpxRspAck(15),
      fifoSOF    => kpxRspSOF(15),   fifoData    => kpxRspData(15),
      parError   => parError(15),    kpixAddr    => "001111",
      rspData    => rspData(15),
      kpixVer    => kpixVer,         statusValue => statusValue(15),
      statusRx   => statusRx(15),    fifoEOF     => kpxRspEOF(15)
   );

   -- Kpix 16 Response Processor
   U_RespRx16: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(16),   fifoAck     => kpxRspAck(16),
      fifoSOF    => kpxRspSOF(16),   fifoData    => kpxRspData(16),
      parError   => parError(16),    kpixAddr    => "010000",
      rspData    => rspData(16),
      kpixVer    => kpixVer,         statusValue => statusValue(16),
      statusRx   => statusRx(16),    fifoEOF     => kpxRspEOF(16)
   );

   -- Kpix 17 Response Processor
   U_RespRx17: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(17),   fifoAck     => kpxRspAck(17),
      fifoSOF    => kpxRspSOF(17),   fifoData    => kpxRspData(17),
      parError   => parError(17),    kpixAddr    => "010001",
      rspData    => rspData(17),
      kpixVer    => kpixVer,         statusValue => statusValue(17),
      statusRx   => statusRx(17),    fifoEOF     => kpxRspEOF(17)
   );

   -- Kpix 18 Response Processor
   U_RespRx18: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(18),   fifoAck     => kpxRspAck(18),
      fifoSOF    => kpxRspSOF(18),   fifoData    => kpxRspData(18),
      parError   => parError(18),    kpixAddr    => "010010",
      rspData    => rspData(18),
      kpixVer    => kpixVer,         statusValue => statusValue(18),
      statusRx   => statusRx(18),    fifoEOF     => kpxRspEOF(18)
   );

   -- Kpix 19 Response Processor
   U_RespRx19: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(19),   fifoAck     => kpxRspAck(19),
      fifoSOF    => kpxRspSOF(19),   fifoData    => kpxRspData(19),
      parError   => parError(19),    kpixAddr    => "010011",
      rspData    => rspData(19),
      kpixVer    => kpixVer,         statusValue => statusValue(19),
      statusRx   => statusRx(19),    fifoEOF     => kpxRspEOF(19)
   );

   -- Kpix 20 Response Processor
   U_RespRx20: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(20),   fifoAck     => kpxRspAck(20),
      fifoSOF    => kpxRspSOF(20),   fifoData    => kpxRspData(20),
      parError   => parError(20),    kpixAddr    => "010100",
      rspData    => rspData(20),
      kpixVer    => kpixVer,         statusValue => statusValue(20),
      statusRx   => statusRx(20),    fifoEOF     => kpxRspEOF(20)
   );

   -- Kpix 21 Response Processor
   U_RespRx21: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(21),   fifoAck     => kpxRspAck(21),
      fifoSOF    => kpxRspSOF(21),   fifoData    => kpxRspData(21),
      parError   => parError(21),    kpixAddr    => "010101",
      rspData    => rspData(21),
      kpixVer    => kpixVer,         statusValue => statusValue(21),
      statusRx   => statusRx(21),    fifoEOF     => kpxRspEOF(21)
   );

   -- Kpix 22 Response Processor
   U_RespRx22: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(22),   fifoAck     => kpxRspAck(22),
      fifoSOF    => kpxRspSOF(22),   fifoData    => kpxRspData(22),
      parError   => parError(22),    kpixAddr    => "010110",
      rspData    => rspData(22),
      kpixVer    => kpixVer,         statusValue => statusValue(22),
      statusRx   => statusRx(22),    fifoEOF     => kpxRspEOF(22)
   );

   -- Kpix 23 Response Processor
   U_RespRx23: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(23),   fifoAck     => kpxRspAck(23),
      fifoSOF    => kpxRspSOF(23),   fifoData    => kpxRspData(23),
      parError   => parError(23),    kpixAddr    => "010111",
      rspData    => rspData(23),
      kpixVer    => kpixVer,         statusValue => statusValue(23),
      statusRx   => statusRx(23),    fifoEOF     => kpxRspEOF(23)
   );

   -- Kpix 24 Response Processor
   U_RespRx24: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(24),   fifoAck     => kpxRspAck(24),
      fifoSOF    => kpxRspSOF(24),   fifoData    => kpxRspData(24),
      parError   => parError(24),    kpixAddr    => "011000",
      rspData    => rspData(24),
      kpixVer    => kpixVer,         statusValue => statusValue(24),
      statusRx   => statusRx(24),    fifoEOF     => kpxRspEOF(24)
   );

   -- Kpix 25 Response Processor
   U_RespRx25: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(25),   fifoAck     => kpxRspAck(25),
      fifoSOF    => kpxRspSOF(25),   fifoData    => kpxRspData(25),
      parError   => parError(25),    kpixAddr    => "011001",
      rspData    => rspData(25),
      kpixVer    => kpixVer,         statusValue => statusValue(25),
      statusRx   => statusRx(25),    fifoEOF     => kpxRspEOF(25)
   );

   -- Kpix 26 Response Processor
   U_RespRx26: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(26),   fifoAck     => kpxRspAck(26),
      fifoSOF    => kpxRspSOF(26),   fifoData    => kpxRspData(26),
      parError   => parError(26),    kpixAddr    => "011010",
      rspData    => rspData(26),
      kpixVer    => kpixVer,         statusValue => statusValue(26),
      statusRx   => statusRx(26),    fifoEOF     => kpxRspEOF(26)
   );

   -- Kpix 27 Response Processor
   U_RespRx27: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(27),   fifoAck     => kpxRspAck(27),
      fifoSOF    => kpxRspSOF(27),   fifoData    => kpxRspData(27),
      parError   => parError(27),    kpixAddr    => "011011",
      rspData    => rspData(27),
      kpixVer    => kpixVer,         statusValue => statusValue(27),
      statusRx   => statusRx(27),    fifoEOF     => kpxRspEOF(27)
   );

   -- Kpix 28 Response Processor
   U_RespRx28: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(28),   fifoAck     => kpxRspAck(28),
      fifoSOF    => kpxRspSOF(28),   fifoData    => kpxRspData(28),
      parError   => parError(28),    kpixAddr    => "011100",
      rspData    => rspData(28),
      kpixVer    => kpixVer,         statusValue => statusValue(28),
      statusRx   => statusRx(28),    fifoEOF     => kpxRspEOF(28)
   );

   -- Kpix 29 Response Processor
   U_RespRx29: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(29),   fifoAck     => kpxRspAck(29),
      fifoSOF    => kpxRspSOF(29),   fifoData    => kpxRspData(29),
      parError   => parError(29),    kpixAddr    => "011101",
      rspData    => rspData(29),
      kpixVer    => kpixVer,         statusValue => statusValue(29),
      statusRx   => statusRx(29),    fifoEOF     => kpxRspEOF(29)
   );

   -- Kpix 30 Response Processor
   U_RespRx30: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(30),   fifoAck     => kpxRspAck(30),
      fifoSOF    => kpxRspSOF(30),   fifoData    => kpxRspData(30),
      parError   => parError(30),    kpixAddr    => "011110",
      rspData    => rspData(30),
      kpixVer    => kpixVer,         statusValue => statusValue(30),
      statusRx   => statusRx(30),    fifoEOF     => kpxRspEOF(30)
   );

   -- Kpix 31 Response Processor
   U_RespRx31: kpixRspRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,         kpixRst     => kpixRst,
      fifoReq    => kpxRspReq(31),   fifoAck     => kpxRspAck(31),
      fifoSOF    => kpxRspSOF(31),   fifoData    => kpxRspData(31),
      parError   => parError(31),    kpixAddr    => "011111",
      rspData    => rspData(31),
      kpixVer    => kpixVer,         statusValue => statusValue(31),
      statusRx   => statusRx(31),    fifoEOF     => kpxRspEOF(31)
   );

end KpixRespData;


