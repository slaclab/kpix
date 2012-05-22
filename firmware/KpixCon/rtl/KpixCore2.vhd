-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixCore2.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-17
-- Last update: 2012-05-22
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
use work.EthRegDecoderPkg.all;
use work.EventBuilderFifoPkg.all;
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;
use work.TriggerPkg.all;

entity KpixCore is
  
  generic (
    DELAY_G                        : time           := 1 ns;
    NUM_KPIX_MODULES_G             : KpixNumberType := 4;
    KPIX_CLOCK_COUNTER_SIZE_G      : natural        := 5;
    KPIX_DATA_RX_NUM_ROW_BUFFERS_G : natural        := 4;
    KPIX_DATA_RX_RAM_WIDTH_G       : natural        := 14);

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

    -- Interface to (possibly) external EventBuilder FIFO
    ebFifoOut : in  EventBuilderFifoOutType;
    ebFifoIn  : out EventBuilderFifoInType;

    -- State of local kpix (needed for clock gen)
    kpixState : in slv(3 downto 0);

    -- Interface to KPiX modules
    kpixClkOut   : out sl;
    kpixRstOut   : out sl;
    kpixSerTxOut : out slv(NUM_KPIX_MODULES_C-2 downto 0);
    kpixSerRxIn  : in  slv(NUM_KPIX_MODULES_C-2 downto 0));


end entity KpixCore;

architecture rtl of KpixCore is

  -- Clock and reset for kpix clocked modules
  signal kpixClk : sl;
  signal kpixClkRst : sl;

  -- Singals between RegDecoder and modules with local registers
  signal ethRegDecoderIn  : EthRegDecoderInType;
  signal ethRegDecoderOut : EthRegDecoderOutType;

  signal kpixRegCntlIn  : EthRegCntlOutType;
  signal kpixRegCntlOut : EthRegCntlInType;

  -- Trigger to start data capture
  signal triggerOut : TriggerOutType;

  -- KPIX Rx Data Interface
  signal kpixDataRxOut : KpixDataRxOutArray(0 to NUM_KPIX_MODULES_G-1);
  signal kpixDataRxIn  : KpixDataRxInArray(0 to NUM_KPIX_MODULES_G-1);

  -- KPIX Rx Reg Interface
  signal kpixRegRxOut : KpixRegRxOutArray(0 to NUM_KPIX_MODULES_G-1);

  -- Internal Kpix Signals
  signal intKpixRstOut   : sl;
  signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_C-1 downto 0);
  signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_C-1 downto 0));
  signal kpixState : slv(2 downto 0);

  
begin

  kpixClkOut <= kpixClk;
  

  --------------------------------------------------------------------------------------------------
  -- Decode local register accesses
  -- Pass KPIX register accesses to KpixRegCntl
  --------------------------------------------------------------------------------------------------
  EthRegDecoder_1 : entity work.EthRegDecoder
    generic map (
      DELAY_G => DELAY_G)
    port map (
      sysClk           => sysClk,
      sysRst           => sysRst,
      ethRegCntlOut    => ethRegCntlOut,
      ethRegCntlIn     => ethRegCntlIn,
      ethRegDecoderIn  => ethRegDecoderIn,
      ethRegDecoderOut => ethRegDecoderOut,
      kpixRegCntlOut   => kpixRegCntlOut,
      kpixRegCntlIn    => kpixRegCntlIn);

  --------------------------------------------------------------------------------------------------
  -- Generate the KPIX Clock
  --------------------------------------------------------------------------------------------------
  KpixClockGen_1 : entity work.KpixClockGen
    generic map (
      DELAY_G        => DELAY_G,
      COUNTER_SIZE_G => KPIX_CLOCK_COUNTER_SIZE_G)
    port map (
      sysClk           => sysClk,
      sysRst           => sysRst,
      clk200           => clk200,
      rst200           => rst200,
      ethRegDecoderOut => ethRegDecoderOut,
      ethRegDecoderIn  => ethRegDecoderIn,
      kpixState        => kpixState,
      kpixClk          => kpixClk,
      kpixRst          => kpixClkRst);

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

  intKpixSerRxIn <= kpixSerRxIn;
  kpixSerTxOut <= intKpixSerTxOut;

  --------------------------------------------------------------------------------------------------
  -- KPIX Register Controller
  -- Handles reads and writes to KPIX registers through the Eth interface
  --------------------------------------------------------------------------------------------------
  KpixRegCntl_1 : entity work.KpixRegCntl
    generic map (
      DELAY_G            => DELAY_G,
      NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
    port map (
      sysClk        => sysClk,
      sysRst        => sysRst,
      kpixClk       => kpixClk,
      kpixRst       => kpixClkRst,
      ethRegCntlOut => kpixRegCntlIn,
      ethRegCntlIn  => kpixRegCntlOut,
      triggerOut    => triggerOut,
      kpixRegRxOut  => kpixRegRxOut,
      kpixSerTxOut  => intKpixSerTxOut);

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
        DELAY_G           => DELAY_G,
        KPIX_ID_G         => i,
        NUM_ROW_BUFFERS_G => KPIX_DATA_RX_NUM_ROW_BUFFERS_G,
        RAM_WIDTH_G       => KPIX_DATA_RX_RAM_WIDTH_G)
      port map (
        sysClk           => sysClk,
        sysRst           => sysRst,
        kpixClk          => kpixClk,
        kpixRst          => kpixClkRst,
        kpixSerRxIn      => intKpixSerRxIn(i),
        kpixRegRxOut     => kpixRegRxOut(i),
        kpixDataRxOut    => kpixDataRxOut(i),
        kpixDataRxIn     => kpixDataRxIn(i),
        ethRegDecoderOut => ethRegDecoderOut,
        ethRegDecoderIn  => ethRegDecoderIn);
  end generate KpixDataRxGen;

    ----------------------------------------
   -- Local KPIX Device
   ----------------------------------------
   U_KpixLocal : KpixLocal port map ( 
      kpixClk       => kpixClk,
      kpixClkRst    => kpixRst,
      debugOutA     => debugOutA,
      debugOutB     => debugOutB,
      debugASel     => debugASel,
      debugBSel     => debugBSel,
      kpixReset     => 
      kpixCmd       => intKpixSerTxOut(NUM_KPIX_MODULES_G-1),
      kpixData      => intKpixSerRxIn(NUM_KPIX_MODULES_G-1),
      coreState     => kpixState,
      kpixBunch     => open,
      calStrobeOut  => open
   );

end architecture rtl;
