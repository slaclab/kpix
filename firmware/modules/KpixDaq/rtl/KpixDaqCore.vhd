-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixDaqCore.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-17
-- Last update: 2013-02-20
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
use work.FrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.KpixPkg.all;
use work.KpixRegCntlPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;
use work.TriggerPkg.all;
use work.KpixLocalPkg.all;
use work.KpixClockGenPkg.all;
use work.EvrPkg.all;

entity KpixDaqCore is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 4);
  port (
    sysClk : in sl;                     -- 125 MHz
    sysRst : in sl;

    clk200 : in sl;                     -- Used by KpixClockGen
    rst200 : in sl;

    -- Front End Interface (Generic. Could be Ethernet, PGP or other)
    frontEndRegCntlOut : in  FrontEndRegCntlOutType;
    frontEndRegCntlIn  : out FrontEndRegCntlInType;
    frontEndCmdCntlOut : in  FrontEndCmdCntlOutType;
    frontEndUsDataOut  : in  FrontEndUsDataOutType;
    frontEndUsDataIn   : out FrontEndUsDataInType;

    softwareReset : out sl;

    -- Trigger interface
    triggerExtIn : in TriggerExtInType;

    -- EVR Interface
    evrOut : in  EvrOutType;
    evrIn  : out EvrInType;

    -- Interface to (possibly) external EventBuilder FIFO
    ebFifoOut : in  EventBuilderFifoOutType;
    ebFifoIn  : out EventBuilderFifoInType;

    debugOutA : out sl;
    debugOutB : out sl;

    -- Interface to KPiX modules
    kpixClkOut     : out sl;
    kpixTriggerOut : out sl;
    kpixResetOut   : out sl;
    kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G-1 downto 0);
    kpixSerRxIn    : in  slv(NUM_KPIX_MODULES_G-1 downto 0));


end entity KpixDaqCore;

architecture rtl of KpixDaqCore is

  -- Clock and reset for kpix clocked modules
  signal kpixClk    : sl;
  signal kpixClkRst : sl;

  signal kpixRegCntlIn  : FrontEndRegCntlOutType;
  signal kpixRegCntlOut : FrontEndRegCntlInType;

  -- Front end accessible registers
  signal kpixClockGenRegsIn : KpixClockGenRegsInType;
  signal triggerRegsIn      : TriggerRegsInType;
  signal kpixConfigRegs     : KpixConfigRegsType;
  signal kpixDataRxRegsIn   : KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
  signal kpixDataRxRegsOut  : KpixDataRxRegsOutArray(NUM_KPIX_MODULES_G-1 downto 0);
  signal kpixLocalRegsIn    : KpixLocalRegsInType;

  -- Triggers
  signal triggerOut : TriggerOutType;

  -- KPIX Rx Data Interface (with Event Builder)
  signal kpixDataRxOut : KpixDataRxOutArray(NUM_KPIX_MODULES_G-1 downto 0);
  signal kpixDataRxIn  : KpixDataRxInArray(NUM_KPIX_MODULES_G-1 downto 0);

  -- KPIX Rx Reg Interface
  -- One extra for the internal kpix
  signal kpixRegRxOut : KpixRegRxOutArray(NUM_KPIX_MODULES_G downto 0);

  -- KPIX Local signals
  signal kpixLocalSysOut : KpixLocalSysOutType;
  signal analogState     : slv(2 downto 0);
  signal readoutState    : slv(2 downto 0);
  signal prechargeBus    : sl;

  -- Timestamp interface to EventBuilder
  signal timestampIn  : TimestampInType;
  signal timestampOut : TimestampOutType;

  -- Internal Kpix Signals
  -- One extra for internal kpix
  signal intKpixResetOut : sl;
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G downto 0);
  
begin

  kpixClkOut <= kpixClk;


  --------------------------------------------------------------------------------------------------
  -- Decode local register accesses
  -- Pass KPIX register accesses to KpixRegCntl
  --------------------------------------------------------------------------------------------------
  FrontEndRegDecoder_1 : entity work.FrontEndRegDecoder
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk             => sysClk,
      sysRst             => sysRst,
      frontEndRegCntlOut => frontEndRegCntlOut,
      frontEndRegCntlIn  => frontEndRegCntlIn,
      softwareReset      => softwareReset,
      kpixRegCntlOut     => kpixRegCntlOut,
      kpixRegCntlIn      => kpixRegCntlIn,
      evrIn              => evrIn,
      evrOut             => evrOut,
      triggerRegsIn      => triggerRegsIn,
      kpixConfigRegs     => kpixConfigRegs,
      kpixClockGenRegsIn => kpixClockGenRegsIn,
      kpixLocalRegsIn    => kpixLocalRegsIn,
      kpixDataRxRegsIn   => kpixDataRxRegsIn,
      kpixDataRxRegsOut  => kpixDataRxRegsOut);

  --------------------------------------------------------------------------------------------------
  -- Generate the KPIX Clock
  --------------------------------------------------------------------------------------------------
  KpixClockGen_1 : entity work.KpixClockGen
    generic map (
      DELAY_G => DELAY_G)
    port map (
      clk200       => clk200,
      rst200       => rst200,
      extRegsIn    => kpixClockGenRegsIn,
      analogState  => analogState,
      readoutState => readoutState,
      prechargeBus => prechargeBus,
      kpixClk      => kpixClk,
      kpixClkRst   => kpixClkRst);

  --------------------------------------------------------------------------------------------------
  -- Trigger generator
  --------------------------------------------------------------------------------------------------
  Trigger_1 : entity work.Trigger
    generic map (
      DELAY_G => DELAY_G)
    port map (
      sysClk             => sysClk,
      sysRst             => sysRst,
      frontEndCmdCntlOut => frontEndCmdCntlOut,
      evrOut             => evrOut,
      kpixLocalSysOut    => kpixLocalSysOut,
      triggerRegsIn      => triggerRegsIn,
      kpixConfigRegs     => kpixConfigRegs,
      triggerExtIn       => triggerExtIn,
      triggerOut         => triggerOut,
      timestampIn        => timestampIn,
      timestampOut       => timestampOut);

  kpixTriggerOut <= triggerOut.trigger;

  --------------------------------------------------------------------------------------------------
  -- Event Builder
  --------------------------------------------------------------------------------------------------
  EventBuilder_1 : entity work.EventBuilder
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk            => sysClk,
      sysRst            => sysRst,
      triggerOut        => triggerOut,
      timestampIn       => timestampIn,
      timestampOut      => timestampOut,
      evrOut            => evrOut,
      kpixLocalSysOut   => kpixLocalSysOut,
      kpixDataRxOut     => kpixDataRxOut,
      kpixDataRxIn      => kpixDataRxIn,
      kpixClk           => kpixClk,
      kpixConfigRegs    => kpixConfigRegs,
      triggerRegsIn     => triggerRegsIn,
      ebFifoIn          => ebFifoIn,
      ebFifoOut         => ebFifoOut,
      frontEndUsDataOut => frontEndUsDataOut,
      frontEndUsDataIn  => frontEndUsDataIn);


  kpixSerTxOut                                  <= intKpixSerTxOut(NUM_KPIX_MODULES_G-1 downto 0);
  intKpixSerRxIn(NUM_KPIX_MODULES_G-1 downto 0) <= kpixSerRxIn;

  --------------------------------------------------------------------------------------------------
  -- KPIX Register Controller
  -- Handles reads and writes to KPIX registers through the FrontEnd interface
  --------------------------------------------------------------------------------------------------
  KpixRegCntl_1 : entity work.KpixRegCntl
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk           => sysClk,
      sysRst           => sysRst,
      kpixRegCntlIn    => kpixRegCntlIn,
      kpixRegCntlOut   => kpixRegCntlOut,
      triggerOut       => triggerOut,
      kpixAnalogState  => analogState,
      kpixReadoutState => readoutState,
      kpixConfigRegs   => kpixConfigRegs,
      kpixClk          => kpixClk,
      kpixClkRst       => kpixClkRst,
      kpixRegRxOut     => kpixRegRxOut,
      kpixSerTxOut     => intKpixSerTxOut,
      kpixTriggerOut   => open,
      kpixResetOut     => intKpixResetOut);

  kpixResetOut <= intKpixResetOut;

  --------------------------------------------------------------------------------------------------
  -- KPIX Register Rx
  -- Deserializes data from a KPIX and presents it to KpixRegCntl
  -- when a register response is detected
  -- Must instantiate one for every connected KPIX including the local kpix
  --------------------------------------------------------------------------------------------------
  KpixRegRxGen : for i in NUM_KPIX_MODULES_G downto 0 generate
    KpixRegRxInst : entity work.KpixRegRx
      generic map (
        DELAY_G   => DELAY_G,
        KPIX_ID_G => i)
      port map (
        kpixClk        => kpixClk,
        kpixClkRst     => kpixClkRst,
        kpixConfigRegs => kpixConfigRegs,
        kpixSerRxIn    => intKpixSerRxIn(i),
        kpixRegRxOut   => kpixRegRxOut(i));
  end generate KpixRegRxGen;

  --------------------------------------------------------------------------------------------------
  -- KPIX Data Parser
  -- Parses incomming sample data into individual samples which are fed to the EventBuilder
  -- Must instantiate one for every connected KPIX including the local kpix
  --------------------------------------------------------------------------------------------------
  KpixDataRxGen : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
    KpixDataRxInst : entity work.KpixDataRx
      generic map (
        DELAY_G   => DELAY_G,
        KPIX_ID_G => i)
      port map (
        kpixClk        => kpixClk,
        kpixClkRst     => kpixClkRst,
        kpixSerRxIn    => intKpixSerRxIn(i),
        kpixRegRxOut   => kpixRegRxOut(i),
        sysClk         => sysClk,
        sysRst         => sysRst,
        kpixConfigRegs => kpixConfigRegs,
        extRegsIn      => kpixDataRxRegsIn(i),
        extRegsOut     => kpixDataRxRegsOut(i),
        kpixDataRxOut  => kpixDataRxOut(i),
        kpixDataRxIn   => kpixDataRxIn(i));
  end generate KpixDataRxGen;

  ----------------------------------------
  -- Local KPIX Device
  ----------------------------------------
  KpixLocalInst : entity work.KpixLocal
    port map (
      kpixClk         => kpixClk,
      kpixClkRst      => kpixClkRst,
      debugOutA       => debugOutA,
      debugOutB       => debugOutB,
      debugASel       => kpixLocalRegsIn.debugASel,
      debugBSel       => kpixLocalRegsIn.debugBSel,
      kpixReset       => intKpixResetOut,
      kpixCmd         => intKpixSerTxOut(NUM_KPIX_MODULES_G),
      kpixData        => intKpixSerRxIn(NUM_KPIX_MODULES_G),
      analogState     => analogState,
      readoutState    => readoutState,
      prechargeBus    => prechargeBus,
      calStrobeOut    => open,
      sysClk          => sysClk,
      sysRst          => sysRst,
      kpixLocalSysOut => kpixLocalSysOut
      );

end architecture rtl;
