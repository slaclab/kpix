-------------------------------------------------------------------------------
-- Title      : KpixSmall
-------------------------------------------------------------------------------
-- File       : KpixSmall.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2013-07-17
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
use work.EvrCorePkg.all;
library unisim;
use unisim.vcomponents.all;

entity KpixSmall is
   
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
      kpixClkOutP     : out sl;
      kpixClkOutN     : out sl;
      kpixRstOut      : out sl;
      kpixTriggerOutP : out sl;
      kpixTriggerOutN : out sl;
      kpixSerTxOut    : out slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixSerRxIn     : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixSmall;

architecture rtl of KpixSmall is

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

   signal softwareReset : sl;

   -- Fake Evr Interface
   signal evrConfigIntfIn  : EvrConfigIntfInType;   -- sysClk
   signal evrConfigIntfOut : EvrConfigIntfOutType;  -- sysClk
   signal evrOut : EvrOutType := (eventStream => (others => '0'),
                                  dataStream  => (others => '0'),
                                  trigger     => '0',
                                  seconds     => (others => '0'),
                                  offset      => (others => '0'),
                                  errors      => (others => '0'));
   
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

   fpgaRst <= not fpgaRstL or softwareReset;

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
         TPD_G          => DELAY_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => sysClk125,
         asyncRst => dcmLocked,
         syncRst  => sysRst125);

   -- Synchronize rst200
   Clk200RstSyncInst : entity work.RstSync
      generic map (
         TPD_G          => DELAY_G,
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
         clk200        => clk200,
         rst200        => rst200,
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

   -- Route triggers to their proper inputs
   intTriggerIn.nimA  <= not triggerExtIn.nimA;
   intTriggerIn.nimB  <= not triggerExtIn.nimB;
   intTriggerIn.cmosA <= not triggerExtIn.cmosA;
   intTriggerIn.cmosB <= not triggerExtIn.cmosB;

   -------------------------------------------------------------------------------------------------
   -- EVR Core. Needed to make EVR registers work, even if they aren't used in this case
   -------------------------------------------------------------------------------------------------
   EvrCore_1 : entity work.EvrCore
      generic map (
         TPD_G => DELAY_G)
      port map (
         evrRecClk        => '0',
         evrRst           => '0',
         phyIn            => (rxData => (others => '0'), rxDataK => (others => '0'), decErr => (others => '0'), dispErr => (others => '0')),
         evrOut           => open,
         sysClk           => sysClk125,
         sysRst           => sysRst125,
         evrConfigIntfIn  => evrConfigIntfIn,
         evrConfigIntfOut => evrConfigIntfOut,
         sysEvrOut        => open);

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
         evrOut             => evrOut,  -- No EVR module in KpixSmall
         sysEvrOut          => evrOut,
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
   regCntlMux : process (frontEndRegCntlOut, evrConfigIntfOut, frontEndRegCntlInKpix) is
   begin
      -- Create EVR register interface inputs from frontEndRegCntlOut signals
      evrConfigIntfIn.req    <= frontEndRegCntlOut.regReq and toSl(frontEndRegCntlOut.regAddr(23 downto 20) = "0010");
      evrConfigIntfIn.wrEna  <= frontEndRegCntlOut.regOp;
      evrConfigIntfIn.dataIn <= frontEndRegCntlOut.regDataOut;
      evrConfigIntfIn.addr   <= frontEndRegCntlOut.regAddr(7 downto 0);

      -- Mux EVR and KpixDaq register interface signals onto frontEndRegCntlIn
      if (frontEndRegCntlOut.regAddr(23 downto 20) = "0010") then
         frontEndRegCntlIn.regDataIn <= evrConfigIntfOut.dataOut;
         frontEndRegCntlIn.regAck    <= evrConfigIntfOut.ack;
         frontEndRegCntlIn.regFail   <= '0';
      else
         frontEndRegCntlIn <= frontEndRegCntlInKpix;
      end if;
   end process regCntlMux;


   OBUF_KPIX_CLK : entity work.ClkOutBufDiff
      port map (
         clkIn   => kpixClk,
         clkOutP => kpixClkOutP,
         clkOutN => kpixClkOutN);

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


end architecture rtl;
