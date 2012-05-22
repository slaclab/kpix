-------------------------------------------------------------------------------
-- Title      : KpixCon
-------------------------------------------------------------------------------
-- File       : KpixCon2.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
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
use work.KpixPkg.all;
use work.EthFrontEndPkg.all;

entity KpixCon is
  
  generic (
    DELAY_G                        : time           := 1 ns;
    NUM_KPIX_MODULES_G             : KpixNumberType := 4;
    KPIX_CLOCK_COUNTER_SIZE_G      : natural        := 5;
    KPIX_DATA_RX_NUM_ROW_BUFFERS_G : natural        := 4;
    KPIX_DATA_RX_RAM_WIDTH_G       : natural        := 14);

  port (
    -- System clock, reset
    fpgaRstL   : in sl;
    gtpRefClkP : in std_logic;
    gtpRefClkN : in std_logic;

    -- Ethernet Interface
    udpTxP : out std_logic;
    udpTxN : out std_logic;
    udpRxP : in  std_logic;
    udpRxN : in  std_logic

    -- Interface to KPiX modules
    kpixClkOut   : out slv(NUM_KPIX_MODULES_C-2 downto 0);
    kpixRstOut   : out slv(NUM_KPIX_MODULES_C-2 downto 0);
    kpixSerTxOut : out slv(NUM_KPIX_MODULES_C-2 downto 0);
    kpixSerRxIn  : in  slv(NUM_KPIX_MODULES_C-2 downto 0));

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

  -- Internal Kpix signals
  signal intKpixState    : slv(3 downto 0);
  signal intKpixClkOut   :  slv(NUM_KPIX_MODULES_C-1 downto 0);
  signal intKpixRstOut   :  slv(NUM_KPIX_MODULES_C-1 downto 0);
  signal intKpixSerTxOut :  slv(NUM_KPIX_MODULES_C-1 downto 0);
  signal intKpixSerRxIn  :  slv(NUM_KPIX_MODULES_C-1 downto 0);

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
  SysRstSync : entity work.RstSync
    generic map (
      DELAY_G    => DELAY_G,
      POLARITY_G => '1')
    port map (
      clk      => sysClk125,
      asyncRst => fpgaRst,
      syncRst  => sysRst125);

  -- Synchronize rst200
  SysRstSync : entity work.RstSync
    generic map (
      DELAY_G    => DELAY_G,
      POLARITY_G => '1')
    port map (
      clk      => clk200,
      asyncRst => fpgaRst,
      syncRst  => sysRst125);  

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
      frameTxEnable => ethUsDataOut.frameTxEnable,
      frameTxSOF    => ethUsDataOut.frameTxSOF,
      frameTxEOF    => ethUsDataOut.frameTxEOF,
      frameTxAfull  => ethUsDataIn.frameTxAfull,
      frameTxData   => ethUsDataOut.frameTxData,
      gtpRxN        => gtpRxN,
      gtpRxP        => gtpRxP,
      gtpTxN        => gtpTxN,
      gtpTxP        => gtpTxP);

  --------------------------------------------------------------------------------------------------
  -- KPIX Core
  --------------------------------------------------------------------------------------------------
  KpixCore_1 : entity work.KpixCore
    generic map (
      DELAY_G                        => DELAY_G,
      NUM_KPIX_MODULES_G             => NUM_KPIX_MODULES_G,
      KPIX_CLOCK_COUNTER_SIZE_G      => KPIX_CLOCK_COUNTER_SIZE_G,
      KPIX_DATA_RX_NUM_ROW_BUFFERS_G => KPIX_DATA_RX_NUM_ROW_BUFFERS_G,
      KPIX_DATA_RX_RAM_WIDTH_G       => KPIX_DATA_RX_RAM_WIDTH_G)
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
      ebFifoOut     => ebFifoOut,
      ebFifoIn      => ebFifoIn,
      kpixState     => intKpixState,
      kpixClkOut    => intKpixClkOut,
      kpixRstOut    => intKpixRstOut,
      kpixSerTxOut  => intKpixSerTxOut,
      kpixSerRxIn   => intKpixSerRxIn);

  --------------------------------------------------------------------------------------------------
  -- Event Builder FIFO
  --------------------------------------------------------------------------------------------------

 

 

     -- Output KPIX clocks
   GenClk : for i in 1 downto 0 generate 
      U_KpixClkDDR : ODDR port map ( 
         Q  => kpixClkOut(i),
         CE => '1',
         C  => kpixClk,
         D1 => '1',      
         D2 => '0',      
         R  => '0',      
         S  => '0'
      );
   end generate;
  
end architecture rtl;
