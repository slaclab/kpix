-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixCore2.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-17
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
use work.EthFrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.KpixPkg.all;
use work.KpixRegCntlPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;
use work.TriggerPkg.all;
use work.KpixLocalPkg.all;
use work.KpixClockGenPkg.all;

entity KpixCore is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 5);
  port (
    sysClk : in sl;                     -- 125 MHz
    sysRst : in sl;

    clk200 : in sl;                     -- Used by KpixClockGen
    rst200 : in sl;

    -- Ethernet Interface (Should just make generic so PGP works as well)
    ethRegCntlOut : in  EthRegCntlOutType;
    ethRegCntlIn  : out EthRegCntlInType;
    ethCmdCntlOut : in  EthCmdCntlOutType;
    ethUsDataOut  : in  EthUsDataOutType;
    ethUsDataIn   : out EthUsDataInType;

    -- Trigger interface
    triggerIn : in TriggerInType;

    -- Interface to (possibly) external EventBuilder FIFO
    ebFifoOut : in  EventBuilderFifoOutType;
    ebFifoIn  : out EventBuilderFifoInType;

    debugOutA : out sl;
    debugOutB : out sl;

    -- Interface to KPiX modules
    kpixClkOut     : out sl;
    kpixTriggerOut : out sl;
    kpixResetOut   : out sl;
    kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G-2 downto 0);
    kpixSerRxIn    : in  slv(NUM_KPIX_MODULES_G-2 downto 0));


end entity KpixCore;

architecture rtl of KpixCore is

  -- Clock and reset for kpix clocked modules
  signal kpixClk    : sl;
  signal kpixClkRst : sl;

  signal kpixRegCntlIn  : EthRegCntlOutType;
  signal kpixRegCntlOut : EthRegCntlInType;

  -- Ethernet accessible registers
  signal kpixClockGenRegsIn : KpixClockGenRegsInType;
  signal triggerRegsIn      : TriggerRegsInType;
  signal kpixRegCntlRegsIn  : KpixRegCntlRegsInType;
  signal kpixDataRxRegsIn   : KpixDataRxRegsInArray(0 to NUM_KPIX_MODULES_G-1);
  signal kpixDataRxRegsOut  : KpixDataRxRegsOutArray(0 to NUM_KPIX_MODULES_G-1);
  signal kpixLocalRegsIn    : KpixLocalRegsInType;

  -- Triggers
  signal triggerOut : TriggerOutType;

  -- KPIX Rx Data Interface (with Event Builder)
  signal kpixDataRxOut : KpixDataRxOutArray(0 to NUM_KPIX_MODULES_G-1);
  signal kpixDataRxIn  : KpixDataRxInArray(0 to NUM_KPIX_MODULES_G-1);

  -- KPIX Rx Reg Interface
  signal kpixRegRxOut : KpixRegRxOutArray(0 to NUM_KPIX_MODULES_G-1);

  -- KPIX Local signals
  signal kpixLocalOut : KpixLocalOutType;

  -- Internal Kpix Signals
  signal intKpixRstOut   : sl;
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G-1 downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G-1 downto 0);
  
begin

  kpixClkOut <= kpixClk;


  --------------------------------------------------------------------------------------------------
  -- Decode local register accesses
  -- Pass KPIX register accesses to KpixRegCntl
  --------------------------------------------------------------------------------------------------
  EthRegDecoder_1 : entity work.EthRegDecoder
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk             => sysClk,
      sysRst             => sysRst,
      ethRegCntlOut      => ethRegCntlOut,
      ethRegCntlIn       => ethRegCntlIn,
      kpixRegCntlOut     => kpixRegCntlOut,
      kpixRegCntlIn      => kpixRegCntlIn,
      triggerRegsIn      => triggerRegsIn,
      kpixRegCntlRegsIn  => kpixRegCntlRegsIn,
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
      kpixLocalOut => kpixLocalOut,
      kpixClk      => kpixClk,
      kpixRst      => kpixClkRst);

  --------------------------------------------------------------------------------------------------
  -- Trigger generator
  --------------------------------------------------------------------------------------------------
  Trigger_1 : entity work.Trigger
    generic map (
      DELAY_G => DELAY_G)
    port map (
      sysClk        => sysClk,
      sysRst        => sysRst,
      ethCmdCntlOut => ethCmdCntlOut,
      kpixLocalOut  => kpixLocalOut,
      extRegsIn     => triggerRegsIn,
      triggerIn     => triggerIn,
      triggerOut    => triggerOut);

  --------------------------------------------------------------------------------------------------
  -- Event Builder
  --------------------------------------------------------------------------------------------------
  EventBuilder_1 : entity work.EventBuilder
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk        => sysClk,
      sysRst        => sysRst,
      triggerOut    => triggerOut,
      kpixDataRxOut => kpixDataRxOut,
      kpixDataRxIn  => kpixDataRxIn,
      ebFifoIn      => ebFifoIn,
      ebFifoOut     => ebFifoOut,
      ethUsDataOut  => ethUsDataOut,
      ethUsDataIn   => ethUsDataIn);


  kpixSerTxOut                                  <= intKpixSerTxOut(NUM_KPIX_MODULES_G-2 downto 0);
  intKpixSerRxIn(NUM_KPIX_MODULES_G-2 downto 0) <= kpixSerRxIn;

  --------------------------------------------------------------------------------------------------
  -- KPIX Register Controller
  -- Handles reads and writes to KPIX registers through the Eth interface
  --------------------------------------------------------------------------------------------------
  KpixRegCntl_1 : entity work.KpixRegCntl
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk         => sysClk,
      sysRst         => sysRst,
      ethRegCntlOut  => kpixRegCntlIn,
      ethRegCntlIn   => kpixRegCntlOut,
      triggerOut     => triggerOut,
      extRegsIn      => kpixRegCntlRegsIn,
      kpixClk        => kpixClk,
      kpixClkRst     => kpixClkRst,
      kpixRegRxOut   => kpixRegRxOut,
      kpixSerTxOut   => intKpixSerTxOut,
      kpixTriggerOut => kpixTriggerOut,
      kpixResetOut   => kpixResetOut);

  --------------------------------------------------------------------------------------------------
  -- KPIX Register Rx
  -- Deserializes data from a KPIX and presents it to KpixRegCntl
  -- when a register response is detected
  -- Must instantiate one for every connected KPIX including the local kpix
  --------------------------------------------------------------------------------------------------
  KpixRegRxGen : for i in 0 to NUM_KPIX_MODULES_G-1 generate
    KpixRegRxInst : entity work.KpixRegRx
      generic map (
        DELAY_G   => DELAY_G,
        KPIX_ID_G => i)
      port map (
        kpixClk      => kpixClk,
        kpixRst      => kpixClkRst,
        kpixSerRxIn  => intKpixSerRxIn(i),
        kpixRegRxOut => kpixRegRxOut(i));
  end generate KpixRegRxGen;

  --------------------------------------------------------------------------------------------------
  -- KPIX Data Parser
  -- Parses incomming sample data into individual samples which are fed to the EventBuilder
  -- Must instantiate one for every connected KPIX including the local kpix
  --------------------------------------------------------------------------------------------------
  KpixDataRxGen : for i in 0 to NUM_KPIX_MODULES_G-1 generate
    KpixDataRxInst : entity work.KpixDataRx
      generic map (
        DELAY_G   => DELAY_G,
        KPIX_ID_G => i)
      port map (
        kpixClk       => kpixClk,
        kpixClkRst    => kpixClkRst,
        kpixSerRxIn   => intKpixSerRxIn(i),
        kpixRegRxOut  => kpixRegRxOut(i),
        sysClk        => sysClk,
        sysRst        => sysRst,
        extRegsIn     => kpixDataRxRegsIn(i),
        extRegsOut    => kpixDataRxRegsOut(i),
        kpixDataRxOut => kpixDataRxOut(i),
        kpixDataRxIn  => kpixDataRxIn(i));
  end generate KpixDataRxGen;

  ----------------------------------------
  -- Local KPIX Device
  ----------------------------------------
  KpixLocalInst : entity work.KpixLocal
    port map (
      kpixClk      => kpixClk,
      kpixClkRst   => kpixClkRst,
      debugOutA    => debugOutA,
      debugOutB    => debugOutB,
      debugASel    => kpixLocalRegsIn.debugASel,
      debugBSel    => kpixLocalRegsIn.debugBSel,
      kpixReset    => '0',
      kpixCmd      => intKpixSerTxOut(NUM_KPIX_MODULES_G-1),
      kpixData     => intKpixSerRxIn(NUM_KPIX_MODULES_G-1),
      coreState    => kpixLocalOut.kpixState,
      kpixBunch    => open,
      calStrobeOut => open
      );

end architecture rtl;
