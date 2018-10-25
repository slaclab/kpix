-------------------------------------------------------------------------------
-- Title      : RyanTest
-------------------------------------------------------------------------------
-- File       : RyanTest.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2012-09-28
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
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

entity RyanTest is
  
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

    uartTx    : out std_logic;
    uartRx    : in  std_logic;

    -- External Trigger
    triggerExtIn : in TriggerExtInType;

    -- Interface to KPiX modules
    kpixClkOutP     : out sl;
    kpixClkOutN     : out sl;
    kpixRstOut      : out sl;
    kpixTriggerOutP : out sl;
    kpixTriggerOutN : out sl;
    kpixSerTxOut    : out slv(NUM_KPIX_MODULES_G-1 downto 0);
    kpixSerRxIn     : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity RyanTest;

architecture rtl of RyanTest is



  signal fpgaRst       : sl;
  signal gtpRefClk     : sl;
  signal gtpRefClkOut  : sl;
  signal gtpRefClkBufg : sl;
  signal sysClk125     : sl;
  signal sysRst125     : sl;
  signal clk200        : sl;
  signal rst200        : sl;
  signal dcmLocked     : sl;

  -- Front End Signals
  signal frontEndRegCntlIn  : FrontEndRegCntlInType;
  signal frontEndRegCntlOut : FrontEndRegCntlOutType;
  signal frontEndCmdCntlOut : FrontEndCmdCntlOutType;
  signal frontEndUsDataOut  : FrontEndUsDataOutType;
  signal frontEndUsDataIn   : FrontEndUsDataInType;
  
  -- No EVR interface, will be undriven
  signal evrOut : EvrOutType;

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

   COMPONENT test_cpu
     PORT (
       Clk : IN STD_LOGIC;
       Reset : IN STD_LOGIC;
       IO_Addr_Strobe : OUT STD_LOGIC;
       IO_Read_Strobe : OUT STD_LOGIC;
       IO_Write_Strobe : OUT STD_LOGIC;
       IO_Address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       IO_Byte_Enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       IO_Write_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       IO_Read_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       IO_Ready : IN STD_LOGIC;
       UART_Rx : IN STD_LOGIC;
       UART_Tx : OUT STD_LOGIC
     );
   END COMPONENT;

begin



  fpgaRst <= not fpgaRstL;

  -- Input clock buffer
  GtpRefClkIbufds : IBUFDS
    port map (
      I  => gtpRefClkP,
      IB => gtpRefClkN,
      O  => gtpRefClk);

  GtpRefClkOutBufg : BUFG
    port map (
      I => gtpRefClkOut,
      O => gtpRefClkBufg);

  -- Generate clocks
  main_dcm_1 : main_dcm
    port map (
      CLKIN_IN   => gtpRefClkBufg,
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
      gtpRefClk     => gtpRefClk,
      gtpRefClkOut  => gtpRefClkOut,
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

  intTriggerIn.nimA  <= not triggerExtIn.nimA;
  intTriggerIn.nimB  <= not triggerExtIn.nimB;
  intTriggerIn.cmosA <= not triggerExtIn.cmosA;
  intTriggerIn.cmosB <= not triggerExtIn.cmosB;
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
      triggerExtIn       => intTriggerIn,
      evrOut             => evrOut,     -- No EVR module in RyanTest
      evrIn              => open,
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


  OBUF_KPIX_CLK : OBUFDS
    port map (
      I  => kpixClk,
      O  => kpixClkOutP,
      OB => kpixClkOutN);

  SER_TX_OBUF_GEN : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
    OBUF_TX : OBUF
      port map (
        I => intKpixSerTxOut(i),
        O => kpixSerTxOut(i));
  end generate;

  SER_RX_IBUF_GEN : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
    IBUF_RX : IBUF
      port map (
        I => kpixSerRxIn(i),
        O => intKpixSerRxIn(i));
  end generate;

  OBUF_RST : OBUF
    port map (
      I => kpixRst,
      O => kpixRstOut);


  OBUF_TRIG : OBUFDS
    port map (
      I  => kpixTrigger,
      O  => kpixTriggerOutP,
      OB => kpixTriggerOutN);



  U_test_cpu: test_cpu
  PORT MAP (
    Clk => sysClk125,
    Reset => sysRst125,
    IO_Addr_Strobe => open,
    IO_Read_Strobe => open,
    IO_Write_Strobe => open,
    IO_Address => open,
    IO_Byte_Enable => open,
    IO_Write_Data => open,
    IO_Read_Data => x"00000000",
    IO_Ready => '0',
    UART_Rx => uartRx,
    UART_Tx => uartTx
  );

end architecture rtl;
