-------------------------------------------------------------------------------
-- Title      : KpixCon
-------------------------------------------------------------------------------
-- File       : KpixCon2.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2012-05-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.EthFrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;
library unisim;
use unisim.vcomponents.all;

entity KpixCon is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 5);

  port (
    -- System clock, reset
    fpgaRstL   : in std_logic;
    gtpRefClkP : in std_logic;
    gtpRefClkN : in std_logic;

    -- Ethernet Interface
    udpTxP : out std_logic;
    udpTxN : out std_logic;
    udpRxP : in  std_logic;
    udpRxN : in  std_logic;

    -- Internal Kpix debug
    debugOutA : out sl;
    debugOutB : out sl;

    -- Interface to KPiX modules
    kpixClkOut   : out slv(NUM_KPIX_MODULES_G-2 downto 0);
    kpixRstOut   : out slv(NUM_KPIX_MODULES_G-2 downto 0);
    kpixSerTxOut : out slv(NUM_KPIX_MODULES_G-2 downto 0);
    kpixSerRxIn  : in  slv(NUM_KPIX_MODULES_G-2 downto 0));

end entity KpixCon;

architecture rtl of KpixCon is

  signal fpgaRst      : sl;
  signal gtpRefClk    : sl;
  signal gtpRefClkOut : sl;
  signal sysClk125    : sl;
  signal sysRst125    : sl;
  signal clk200       : sl;
  signal rst200       : sl;
  signal dcmLocked    : sl;

  -- Eth Front End Signals
  signal ethRegCntlIn  : EthRegCntlInType;
  signal ethRegCntlOut : EthRegCntlOutType;
  signal ethCmdCntlOut : EthCmdCntlOutType;
  signal ethUsDataOut  : EthUsDataOutType;
  signal ethUsDataIn   : EthUsDataInType;

  -- Event Builder FIFO signals
  -- Optionaly pass this through as IO to external FIFO
  signal ebFifoOut : EventBuilderFifoOutType;
  signal ebFifoIn  : EventBuilderFifoInType;

  signal triggerIn : TriggerInType;

  -- Internal Kpix signals
  signal kpixClk         : sl;
  signal kpixRst         : sl;
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G-2 downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G-2 downto 0);

begin

  fpgaRst <= not fpgaRstL;

  -- Input clock buffer
  GtpRefClkIbufds : IBUFDS
    port map (
      I  => gtpRefClkP,
      IB => gtpRefClkN,
      O  => gtpRefClk);

  -- Generate clocks
  main_dcm_1 : entity work.main_dcm
    port map (
      CLKIN_IN   => gtpRefClkOut,
      RST_IN     => fpgaRst,
      CLKFX_OUT  => clk200,
      CLK0_OUT   => sysClk125,
      LOCKED_OUT => dcmLocked);

  -- Synchronize sysRst125
  SysRstSyncInst : entity work.RstSync
    generic map (
      DELAY_G    => DELAY_G,
      POLARITY_G => '1')
    port map (
      clk      => sysClk125,
      asyncRst => fpgaRst,
      syncRst  => sysRst125);

  -- Synchronize rst200
  Clk200RstSyncInst : entity work.RstSync
    generic map (
      DELAY_G    => DELAY_G,
      POLARITY_G => '1')
    port map (
      clk      => clk200,
      asyncRst => fpgaRst,
      syncRst  => rst200);  

  -- Ethernet module
  EthFrontEnd_1 : entity work.EthFrontEnd
    port map (
      gtpClk        => sysClk125,
      gtpClkRst     => sysRst125,
      gtpRefClk     => gtpRefClk,
      gtpRefClkOut  => gtpRefClkOut,
      cmdEn         => ethCmdCntlOut.cmdEn,
      cmdOpCode     => ethCmdCntlOut.cmdOpCode,
      regReq        => ethRegCntlOut.regReq,
      regOp         => ethRegCntlOut.regOp,
      regInp        => ethRegCntlOut.regInp,
      regAck        => ethRegCntlIn.regAck,
      regFail       => ethRegCntlIn.regFail,
      regAddr       => ethRegCntlOut.regAddr,
      regDataOut    => ethRegCntlOut.regDataOut,
      regDataIn     => ethRegCntlIn.regDataIn,
      frameTxEnable => ethUsDataIn.frameTxEnable,
      frameTxSOF    => ethUsDataIn.frameTxSOF,
      frameTxEOF    => ethUsDataIn.frameTxEOF,
      frameTxAfull  => ethUsDataOut.frameTxAfull,
      frameTxData   => ethUsDataIn.frameTxData,
      gtpRxN        => udpRxN,
      gtpRxP        => udpRxP,
      gtpTxN        => udpTxN,
      gtpTxP        => udpTxP);

  --------------------------------------------------------------------------------------------------
  -- KPIX Core
  --------------------------------------------------------------------------------------------------
  KpixCore_1 : entity work.KpixCore
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk        => sysClk125,
      sysRst        => sysRst125,
      clk200        => clk200,
      rst200        => rst200,
      ethRegCntlOut => ethRegCntlOut,
      ethRegCntlIn  => ethRegCntlIn,
      ethCmdCntlOut => ethCmdCntlOut,
      ethUsDataOut  => ethUsDataOut,
      ethUsDataIn   => ethUsDataIn,
      triggerIn     => triggerIn,
      ebFifoOut     => ebFifoOut,
      ebFifoIn      => ebFifoIn,
      debugOutA     => debugOutA,
      debugOutB     => debugOutB,
      kpixClkOut    => kpixClk,
      kpixResetOut    => kpixRst,
      kpixSerTxOut  => kpixSerTxOut,
      kpixSerRxIn   => kpixSerRxIn);

  --------------------------------------------------------------------------------------------------
  -- Event Builder FIFO
  --------------------------------------------------------------------------------------------------
  fifo_72x32k_fwft_1 : entity work.fifo_72x32k_fwft
    port map (
      clk   => sysClk125,
      rst   => sysRst125,
      din   => ebFifoIn.wrData,
      wr_en => ebFifoIn.wrEn,
      rd_en => ebFifoIn.rdEn,
      dout  => ebFifoOut.rdData,
      full  => ebFifoOut.full,
      empty => ebFifoOut.empty,
      valid => ebFifoOut.valid); 

  -- Output KPIX clocks
  GenClk : for i in NUM_KPIX_MODULES_G-2 downto 0 generate
    U_KpixClkDDR : ODDR
      port map (
      Q  => kpixClkOut(i),
      CE => '1',
      C  => kpixClk,
      D1 => '1',
      D2 => '0',
      R  => '0',
      S  => '0'
      );
  end generate;

  RstGen: for i in NUM_KPIX_MODULES_G-2 downto 0 generate
    OBUF_RST : OBUF
      port map (
        I => kpixRst,
        O => kpixRstOut(i));
  end generate RstGen;
  
end architecture rtl;
