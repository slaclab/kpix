-------------------------------------------------------------------------------
-- Title      : KpixCon
-------------------------------------------------------------------------------
-- File       : KpixCon2.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2012-09-28
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
use work.FrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;
use work.EvrPkg.all;
library unisim;
use unisim.vcomponents.all;

entity KpixCon is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 4);

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

    -- External Trigger
    triggerExtIn : in TriggerExtInType;

    -- Interface to KPiX modules
    kpixClkOut     : out sl;
    kpixRstOut     : out sl;
    kpixTriggerOut : out sl;
    kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G-1 downto 0);
    kpixSerRxIn    : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixCon;

architecture rtl of KpixCon is

  signal fpgaRst       : sl;
  signal gtpRefClk     : sl;
  signal gtpRefClkOut  : sl;
  signal gtpRefClkBufg : sl;
  signal sysClk125     : sl;
  signal sysRst125     : sl;
  signal clk200        : sl;
  signal rst200        : sl;
  signal dcmLocked     : sl;

  -- Eth Front End Signals
  signal frontEndRegCntlIn  : FrontEndRegCntlInType;
  signal frontEndRegCntlOut : FrontEndRegCntlOutType;
  signal frontEndCmdCntlOut : FrontEndCmdCntlOutType;
  signal frontEndUsDataOut  : FrontEndUsDataOutType;
  signal frontEndUsDataIn   : FrontEndUsDataInType;

  -- No EVR interface, will be undriven
  signal evrOut : EvrOutType;
  
  signal intTriggerExtIn : TriggerExtInType;

  -- Event Builder FIFO signals
  -- Optionaly pass this through as IO to external FIFO
  signal ebFifoOut : EventBuilderFifoOutType;
  signal ebFifoIn  : EventBuilderFifoInType;

  signal kpixTrigger : sl;

  -- Internal Kpix signals
  signal intKpixResetOut : sl;
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G-1 downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G-1 downto 0);
  signal kpixClk         : sl;
  signal kpixRst         : sl;

    -- Stupid XST forces component declarations for generated cores
  component main_dcm is
    port (
      CLKIN_IN   : in  std_logic;
      RST_IN     : in  std_logic;
      CLKFX_OUT  : out std_logic;
      CLK0_OUT   : out std_logic;
      LOCKED_OUT : out std_logic);
  end component main_dcm;

  component EventBuilderFifo
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(71 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(71 downto 0);
      full  : out std_logic;
      empty : out std_logic;
      valid : out std_logic
      );
  end component;


begin

  fpgaRst <= '0';                       --not fpgaRstL;

  -- Input clock buffer
  GtpRefClkIbufds : IBUFDS
    port map (
      I  => gtpRefClkP,
      IB => gtpRefClkN,
      O  => gtpRefClk);

--  GtpRefClkBufgInst : BUFG
--    port map (
--      I => gtpRefClkOut,
--      O => gtpRefClkBufg);

  -- Generate clocks
  main_dcm_1 : main_dcm
    port map (
      CLKIN_IN   => gtpRefClk,
      RST_IN     => fpgaRst,
      CLKFX_OUT  => clk200,
      CLK0_OUT   => sysClk125,
      LOCKED_OUT => dcmLocked);

  -- Synchronize sysRst125
  SysRstSyncInst : entity work.RstSync
    generic map (
      DELAY_G        => DELAY_G,
      IN_POLARITY_G  => '0',
      OUT_POLARITY_G => '1')
    port map (
      clk      => sysClk125,
      asyncRst => dcmLocked,
      syncRst  => sysRst125);

  -- Synchronize rst200
  Clk200RstSyncInst : entity work.RstSync
    generic map (
      DELAY_G        => DELAY_G,
      IN_POLARITY_G  => '0',
      OUT_POLARITY_G => '1')
    port map (
      clk      => clk200,
      asyncRst => dcmLocked,
      syncRst  => rst200);  

  -- Ethernet module
  EthFrontEnd_1 : entity work.EthFrontEnd
    port map (
      gtpClk        => sysClk125,
      gtpClkRst     => sysRst125,
      gtpRefClk     => sysClk125,
      gtpRefClkOut  => open,
      cmdEn         => frontEndCmdCntlOut.cmdEn,
      cmdOpCode     => frontEndCmdCntlOut.cmdOpCode,
      cmdCtxOut     => frontEndCmdCntlOut.cmdCtxOut,
      regReq        => frontEndRegCntlOut.regReq,
      regOp         => frontEndRegCntlOut.regOp,
      regInp        => frontEndRegCntlOut.regInp,
      regAck        => frontEndRegCntlIn.regAck,
      regFail       => frontEndRegCntlIn.regFail,
      regAddr       => frontEndRegCntlOut.regAddr,
      regDataOut    => frontEndRegCntlOut.regDataOut,
      regDataIn     => frontEndRegCntlIn.regDataIn,
      frameTxEnable => frontEndUsDataIn.frameTxEnable,
      frameTxSOF    => frontEndUsDataIn.frameTxSOF,
      frameTxEOF    => frontEndUsDataIn.frameTxEOF,
      frameTxAfull  => frontEndUsDataOut.frameTxAfull,
      frameTxData   => frontEndUsDataIn.frameTxData,
      gtpRxN        => udpRxN,
      gtpRxP        => udpRxP,
      gtpTxN        => udpTxN,
      gtpTxP        => udpTxP);

  intTriggerExtIn.nimA  <= not triggerExtIn.nimA;
  intTriggerExtIn.nimB  <= not triggerExtIn.nimB;
  intTriggerExtIn.cmosA <= not triggerExtIn.cmosA;
  intTriggerExtIn.cmosB <= not triggerExtIn.cmosB;

  --------------------------------------------------------------------------------------------------
  -- KPIX Core
  --------------------------------------------------------------------------------------------------
  KpixDaqCore_1 : entity work.KpixDaqCore
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk             => sysClk125,
      sysRst             => sysRst125,
      clk200             => clk200,
      rst200             => rst200,
      frontEndRegCntlOut => frontEndRegCntlOut,
      frontEndRegCntlIn  => frontEndRegCntlIn,
      frontEndCmdCntlOut => frontEndCmdCntlOut,
      frontEndUsDataOut  => frontEndUsDataOut,
      frontEndUsDataIn   => frontEndUsDataIn,
      triggerExtIn       => intTriggerExtIn,
      evrOut             => evrOut,
      evrIn              => open,       -- No EVR module
      ebFifoOut          => ebFifoOut,
      ebFifoIn           => ebFifoIn,
      debugOutA          => debugOutA,
      debugOutB          => debugOutB,
      kpixClkOut         => kpixClk,
      kpixTriggerOut     => kpixTrigger,
      kpixResetOut       => intKpixResetOut,
      kpixSerTxOut       => intKpixSerTxOut,
      kpixSerRxIn        => intKpixSerRxIn);

  --------------------------------------------------------------------------------------------------
  -- Event Builder FIFO
  --------------------------------------------------------------------------------------------------
  EventBuilderFifo_1 : EventBuilderFifo
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
  U_KpixClkDDR : ODDR
    port map (
      Q  => kpixClkOut,
      CE => '1',
      C  => kpixClk,
      D1 => '1',
      D2 => '0',
      R  => '0',
      S  => '0'
      );

  -- Some signals are inverted due to KpixCon board features
  serTxInvert : process (intKpixSerTxOut) is
  begin
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      if (i mod 2 = 0) then
        kpixSerTxOut(i) <= not intKpixSerTxOut(i);
      else
        kpixSerTxOut(i) <= intKpixSerTxOut(i);
      end if;
    end loop;
  end process serTxInvert;

  serRxInvert : process (intKpixSerRxIn) is
  begin
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      if (i mod 2 = 0) then
        intKpixSerRxin(i) <= not kpixSerRxin(i);
      else
        intKpixSerRxin(i) <= kpixSerRxin(i);
      end if;
    end loop;
  end process serRxInvert;

  OBUF_RST : OBUF
    port map (
      I => not intKpixResetOut,
      O => kpixRstOut);


  OBUF_TRIG : OBUF
    port map (
      I => kpixTrigger,
      O => kpixTriggerOut);


end architecture rtl;
