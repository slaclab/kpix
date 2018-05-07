-------------------------------------------------------------------------------
-- Title      : KpixEmtb
-------------------------------------------------------------------------------
-- File       : KpixEmtb.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2013-05-14
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

entity KpixEmtb is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 31;
    FRONT_END_G : string := "PGP");     -- "PGP" or "ETH"

  port (
    -- System reset
    fpgaRstL : in sl;

    -- PGP clock - 156.25 MHz
    pgpRefClkP : in sl;
    pgpRefClkN : in sl;

    -- PGP Interface
    pgpTxP : out sl;
    pgpTxN : out sl;
    pgpRxP : in  sl;
    pgpRxN : in  sl;

    -- Evr clock and interface
    evrClkP : in sl;
    evrClkN : in sl;
--    evrTxP  : out sl;
--    evrTxN  : out sl;
    evrRxP  : in sl;
    evrRxN  : in sl;

    -- Internal Kpix debug
    debugOutA : out sl;
    debugOutB : out sl;

    -- External Triggers
    cmosIn : in sl;
    lemoIn : in sl;


    -- Interface to KPiX modules
    kpixClkOutP     : out slv(3 downto 0);
    kpixClkOutN     : out slv(3 downto 0);
    kpixRstOut      : out sl;
    kpixTriggerOutP : out slv(3 downto 0);
    kpixTriggerOutN : out slv(3 downto 0);
    kpixSerTxOut    : out slv(NUM_KPIX_MODULES_G-1 downto 0);
    kpixSerRxIn     : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixEmtb;

architecture rtl of KpixEmtb is



  signal fpgaRst : sl;

  signal pgpRefClk     : sl;
  signal pgpRefClkOut  : sl;
  signal pgpRefClkBufg : sl;
  signal pgpClk        : sl;
  signal pgpReset      : sl;
  signal pgpClk2x      : sl;


  signal sysClk125 : sl;
  signal sysRst125 : sl;
  signal clk200    : sl;
  signal rst200    : sl;
  signal dcmLocked : sl;

  signal evrClk : sl;

  -- Front End Signals
  signal frontEndRegCntlIn  : FrontEndRegCntlInType;
  signal frontEndRegCntlOut : FrontEndRegCntlOutType;
  signal frontEndCmdCntlOut : FrontEndCmdCntlOutType;
  signal frontEndUsDataOut  : FrontEndUsDataOutType;
  signal frontEndUsDataIn   : FrontEndUsDataInType;

  signal softwareReset : sl;
  signal ponResetL     : sl;

  -- EVR Signals
  signal evrIn     : EvrInType;
  signal evrOut    : EvrOutType;        -- evrClk
  signal evrRegIn  : EvrRegInType;      -- sysClk
  signal evrRegOut : EvrRegOutType;     -- sysClk

  -- Front End Reg Cntl Ouputs from kpixDaq
  signal frontEndRegCntlInKpix : FrontEndRegCntlInType;

  -- Event Builder FIFO signals
  -- Optionaly pass this through as IO to external FIFO
  signal ebFifoOut : EventBuilderFifoOutType;
  signal ebFifoIn  : EventBuilderFifoInType;

  signal kpixTrigger  : sl;
  signal intTriggerIn : TriggerExtInType;

  -- Internal Kpix signals
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G-1 downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G-1 downto 0);
  signal kpixClk         : sl;
  signal kpixRst         : sl;

  -- Stupid XST forces component declarations for generated cores
  component main_dcm is
    port (
      CLKIN_IN   : in  sl;
      RST_IN     : in  sl;
      CLKFX_OUT  : out sl;
      CLK0_OUT   : out sl;
      LOCKED_OUT : out sl);
  end component main_dcm;

  component EventBuilderFifo
    port (
      clk   : in  sl;
      rst   : in  sl;
      din   : in  slv(71 downto 0);
      wr_en : in  sl;
      rd_en : in  sl;
      dout  : out slv(71 downto 0);
      full  : out sl;
      empty : out sl;
      valid : out sl
      );
  end component;

  -- Component declaration needed for verilog modules too
  component EventReceiverTop is
    generic (
      USE_CHIPSCOPE : integer);
    port (
      Reset           : in  std_logic;
      m_Timing_MGTCLK : in  std_logic;
      p_Timing_MGTCLK : in  std_logic;
      RXN_IN          : in  std_logic;
      RXP_IN          : in  std_logic;
      EventStream     : out std_logic_vector(7 downto 0);
      DataStream      : out std_logic_vector(7 downto 0);
      evrTrigger      : out std_logic;
      evrRegDataOut   : out std_logic_vector(31 downto 0);
      evrRegWrEna     : in  std_logic;
      evrRegDataIn    : in  std_logic_vector(31 downto 0);
      evrRegAddr      : in  std_logic_vector(7 downto 0);
      evrRegEna       : in  std_logic;
      cxiClk          : in  std_logic;
      cxiClkRst       : in  std_logic;
      evrClk          : out std_logic;
      evrDebug        : out std_logic_vector(63 downto 0);
      outSeconds      : out std_logic_vector(31 downto 0);
      outOffset       : out std_logic_vector(31 downto 0);
      evrErrors       : out std_logic_vector(15 downto 0);
      countReset      : in  std_logic);
  end component EventReceiverTop;

  component Pgp2FrontEnd is
    port (
      pgpRefClk     : in  std_logic;
      pgpRefClkOut  : out std_logic;
      pgpClk        : in  std_logic;
      pgpClk2x      : in  std_logic;
      pgpReset      : in  std_logic;
      locClk        : in  std_logic;
      locReset      : in  std_logic;
      cmdEn         : out std_logic;
      cmdOpCode     : out std_logic_vector(7 downto 0);
      cmdCtxOut     : out std_logic_vector(23 downto 0);
      regReq        : out std_logic;
      regOp         : out std_logic;
      regInp        : out std_logic;
      regAck        : in  std_logic;
      regFail       : in  std_logic;
      regAddr       : out std_logic_vector(23 downto 0);
      regDataOut    : out std_logic_vector(31 downto 0);
      regDataIn     : in  std_logic_vector(31 downto 0);
      frameTxEnable : in  std_logic;
      frameTxSOF    : in  std_logic;
      frameTxEOF    : in  std_logic;
      frameTxEOFE   : in  std_logic;
      frameTxData   : in  std_logic_vector(63 downto 0);
      frameTxAFull  : out std_logic;
      pgpRxN        : in  std_logic;
      pgpRxP        : in  std_logic;
      pgpTxN        : out std_logic;
      pgpTxP        : out std_logic);
  end component Pgp2FrontEnd;

begin

  fpgaRst   <= not fpgaRstL or softwareReset;
  ponResetL <= not fpgaRst;             -- Pgp2GtpClk needs active low for ponReset

  -- Input clock buffer
  PgpRefClkIbufds : IBUFDS
    port map (
      I  => pgpRefClkP,
      IB => pgpRefClkN,
      O  => pgpRefClk);

  -- Run input clock through BUFG before sending to Pgp2GtpClk DCM
--  PgpRefClkOutBufg : BUFG
--    port map (
--      I => pgpRefClkOut,
--      O => pgpRefClkBufg);

  -- Create pgpClk2x and sysClk125 from 156.25 MHz input clock
  Pgp2GtpClk_1 : entity work.Pgp2GtpClk
    generic map (
      UserFxDiv  => 5,
      UserFxMult => 4)                  -- 4/5 * 156.25 = 125 MHz
    port map (
      pgpRefClk => pgpRefClkOut,
      ponResetL => ponResetL,
      locReset  => '0',
      pgpClk    => pgpClk,
      pgpReset  => pgpReset,
      pgpClk2x  => pgpClk2x,
      userClk   => sysClk125,
      userReset => sysRst125,
      pgpClkIn  => pgpClk,
      userClkIn => sysClk125);

  -- Generate 200 MHz clock
  main_dcm_1 : main_dcm
    port map (
      CLKIN_IN   => sysClk125,
      RST_IN     => sysRst125,
      CLKFX_OUT  => clk200,
      CLK0_OUT   => open,
      LOCKED_OUT => dcmLocked);

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

  -- PGP module
  PgpFrontEnd_1 : Pgp2FrontEnd
    port map (
      pgpRefClk     => pgpRefClk,       -- Direct input from pins
      pgpRefClkOut  => pgpRefClkOut,    -- Send this to DCM
      pgpClk        => pgpClk,
      pgpClk2x      => pgpClk2x,
      pgpReset      => pgpReset,
      locClk        => sysClk125,
      locReset      => sysRst125,
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
      frameTxEOFE   => frontEndUsDataIn.frameTxEOFE,
      frameTxData   => frontEndUsDataIn.frameTxData,
      frameTxAFull  => frontEndUsDataOut.frameTxAFull,
      pgpRxN        => pgpRxN,
      pgpRxP        => pgpRxP,
      pgpTxN        => pgpTxN,
      pgpTxP        => pgpTxP);

  -- Event Receiver
--  EventReceiverTop_1 : EventReceiverTop
--    generic map (
--      USE_CHIPSCOPE => 0)
--    port map (
--      Reset           => fpgaRst,
--      m_Timing_MGTCLK => evrClkN,
--      p_Timing_MGTCLK => evrClkP,
--      RXN_IN          => evrRxN,
--      RXP_IN          => evrRxP,
--      EventStream     => evrOut.eventStream,
--      DataStream      => evrOut.dataStream,
--      evrTrigger      => evrOut.trigger,
--      evrRegDataOut   => evrRegOut.dataOut,
--      evrRegWrEna     => evrRegIn.wrEna,
--      evrRegDataIn    => evrRegIn.dataIn,
--      evrRegAddr      => evrRegIn.addr,
--      evrRegEna       => evrRegIn.ena,
--      cxiClk          => sysClk125,
--      cxiClkRst       => sysRst125,
--      evrClk          => evrClk,
--      evrDebug        => evrOut.debug,
--      outSeconds      => evrOut.seconds,
--      outOffset       => evrOut.offset,
--      evrErrors       => evrOut.errors,
--      countReset      => evrIn.countReset);

  evrOut.eventStream <= (others => '0');
  evrOut.dataStream  <= (others => '0');
  evrOut.trigger     <= '0';
  evrRegOut.dataOut  <= (others => '0');
  evrOut.debug       <= (others => '0');
  evrOut.seconds     <= (others => '0');
  evrOut.offset      <= (others => '0');
  evrOut.errors      <= (others => '0');

  -- Route triggers to their proper inputs
  intTriggerIn.nimA  <= not lemoIn;
  intTriggerIn.nimB  <= '0';
  intTriggerIn.cmosA <= not cmosIn;
  intTriggerIn.cmosB <= '0';
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
      frontEndRegCntlIn  => frontEndRegCntlInKpix,
      frontEndCmdCntlOut => frontEndCmdCntlOut,
      frontEndUsDataOut  => frontEndUsDataOut,
      frontEndUsDataIn   => frontEndUsDataIn,
      softwareReset      => softwareReset,
      triggerExtIn       => intTriggerIn,
      evrOut             => evrOut,
      evrIn              => evrIn,
      ebFifoOut          => ebFifoOut,
      ebFifoIn           => ebFifoIn,
      debugOutA          => debugOutA,
      debugOutB          => debugOutB,
      kpixClkOut         => kpixClk,
      kpixTriggerOut     => kpixTrigger,
      kpixResetOut       => kpixRst,
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

  --------------------------------------------------------------------------------------------------
  -- Front End Reg Cntl Mux
  --------------------------------------------------------------------------------------------------
  regCntlMux : process (frontEndRegCntlOut, evrRegOut, frontEndRegCntlInKpix) is
  begin
    -- Create EVR register interface inputs from frontEndRegCntlOut signals
    evrRegIn.ena    <= frontEndRegCntlOut.regReq and toSl(frontEndRegCntlOut.regAddr(23 downto 20) = "0010");
    evrRegIn.wrEna  <= frontEndRegCntlOut.regOp;
    evrRegIn.dataIn <= frontEndRegCntlOut.regDataOut;
    evrRegIn.addr   <= frontEndRegCntlOut.regAddr(7 downto 0);

    -- Mux EVR and KpixDaq register interface signals onto frontEndRegCntlIn
    if (frontEndRegCntlOut.regAddr(23 downto 20) = "0010") then
      frontEndRegCntlIn.regDataIn <= evrRegOut.dataOut;
      frontEndRegCntlIn.regAck    <= frontEndRegCntlOut.regReq;
      frontEndRegCntlIn.regFail   <= '0';
    else
      frontEndRegCntlIn <= frontEndRegCntlInKpix;
    end if;
  end process regCntlMux;


  --------------------------------------------------------------------------------------------------
  -- KPIX IO Buffers
  --------------------------------------------------------------------------------------------------
  CLK_TRIG_OBUF_GEN : for i in 3 downto 0 generate

    OBUF_KPIX_CLK : entity work.ClkOutBuf
      port map (
        clkIn   => kpixClk,
        clkOutP => kpixClkOutP(i),
        clkOutN => kpixClkOutN(i));

    OBUF_KPIX_TRIG : OBUFDS
      port map (
        I  => kpixTrigger,
        O  => kpixTriggerOutP(i),
        OB => kpixTriggerOutN(i));
  end generate;

  SER_TX_RX_OBUF_GEN : for i in NUM_KPIX_MODULES_G-1 downto 0 generate

    OBUF_KPIX_TX : OBUF
      port map (
        I => intKpixSerTxOut(i),
        O => kpixSerTxOut(i));

    IBUF_KPIX_RX : IBUF
      port map (
        I => kpixSerRxIn(i),
        O => intKpixSerRxIn(i));
  end generate;

  OBUF_KPIX_RST : OBUF
    port map (
      I => kpixRst,
      O => kpixRstOut);

end architecture rtl;
