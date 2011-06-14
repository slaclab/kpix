-------------------------------------------------------------------------------
-- Title         : KPIX Optical Interface FPGA Core Module
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixConCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/07/2010
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the optical interface FPGA on the KPIX Test Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/07/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;
use work.EthClientPackage.all;

entity KpixConCore is 
   port ( 

      -- System clock, reset
      fpgaRstL      : in    std_logic;                     -- Asynchronous local reset
      sysClk        : in    std_logic;                     -- 125Mhz system clock
      sysClk200     : in    std_logic;                     -- 200Mhz system clock
      kpixClk       : in    std_logic;                     -- Kpix Clock
      divCount      : in    std_logic_vector(4  downto 0); -- Kpix Clock
      kpixLock      : in    std_logic;                     -- Kpix DLL Lock

      -- Ddr clock, rest
      ddrClk        : in    std_logic;                     -- 125Mhz ddr clock
      ddrRst        : in    std_logic;                     -- ddr reset

      -- Clock Selection
      clkSelA       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelB       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelC       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelD       : out   std_logic_vector(4  downto 0); -- Clock selection
      coreState     : out   std_logic_vector(2  downto 0); -- State of internal core

      -- Jumper & LEDS
      jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
      ledL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs

      -- Optical Interface to Kpix devices
      reset         : out   std_logic;                     -- Reset to KPIX devices
      forceTrig     : out   std_logic;                     -- Force trigger to KPIX Devices
      command       : out   std_logic_vector(31 downto 0); -- Command to KPIX devices
      data          : in    std_logic_vector(31 downto 0); -- Data from from KPIX devices

      -- Kpix Data read interface
      kpixRdEdge    : out   std_logic;                     -- Edge to read kpix data
      kpixRdPhase   : out   std_logic_vector(4  downto 0); -- Phase shift to read kpix data
      kpixRd        : in    std_logic;                     -- Kpix Data Read

      -- External signals
      bncInA        : in    std_logic;                     -- BNC Interface A input
      bncInB        : in    std_logic;                     -- BNC Interface B input
      bncOutA       : out   std_logic;                     -- BNC Interface A output
      bncOutB       : out   std_logic;                     -- BNC Interface B output
      nimInA        : in    std_logic;                     -- NIM Interface A input
      nimInB        : in    std_logic;                     -- NIM Interface B input

      -- ADC Interface
      adcSData      : in    std_logic;                     -- ADC Serial Data In
      adcSclk       : out   std_logic;                     -- ADC Serial Clock Out
      adcCsL        : out   std_logic;                     -- ADC Chip Select Out

      -- Calibration DAC
      dacDin        : out   std_logic;                     -- Cal Data Data
      dacSclk       : out   std_logic;                     -- Cal Data Clock
      dacCsL        : out   std_logic;                     -- Cal Data Chip Select
      dacClrL       : out   std_logic;                     -- Cal Data Clear

      -- SRAM 0 interface
      ddr0RdNWr     : out   std_logic;                     -- ddr0 R/W
      ddr0LdL       : out   std_logic;                     -- ddr0 active low Load
      ddr0Data      : inout std_logic_vector(17 downto 0); -- ddr0 data bus
      ddr0Addr      : out   std_logic_vector(21 downto 0); -- ddr0 address bus

      -- SRAM 1 interface
      ddr1RdNWr     : out   std_logic;                     -- ddr1 R/W
      ddr1LdL       : out   std_logic;                     -- ddr1 active low Load
      ddr1Data      : inout std_logic_vector(17 downto 0); -- ddr1 data bus
      ddr1Addr      : out   std_logic_vector(21 downto 0); -- ddr1 address bus

      -- Ethernet Interface
      TXP_0         : out   std_logic;                     -- Ethernet Transmiter Data
      TXN_0         : out   std_logic;                     -- Ethernet Transmiter Data
      RXP_0         : in    std_logic;                     -- Ethernet Receiver Data
      RXN_0         : in    std_logic;                     -- Ethernet Receiver Data
      TXN_1_UNUSED  : out   std_logic;                     -- Ethernet Transmiter Data
      TXP_1_UNUSED  : out   std_logic;                     -- Ethernet Transmiter Data
      RXN_1_UNUSED  : in    std_logic;                     -- Ethernet Receiver Data
      RXP_1_UNUSED  : in    std_logic;                     -- Ethernet Receiver Data
      gtpClk        : in    std_logic;                     -- Clock for ethernet interface
      gtpClkOut     : out   std_logic;                     -- Clock out from GTP
      gtpClkRef     : in    std_logic                      -- Clock for ethernet interface
   );
end KpixConCore;


-- Define architecture for core module
architecture KpixConCore of KpixConCore is 


   -- Local signals
   signal sysRst        : std_logic;
   signal kpixRst       : std_logic;
   signal usbRxLedL     : std_logic;
   signal usbTxLedL     : std_logic;
   signal usbLoopEnL    : std_logic;
   signal txFifoData    : std_logic_vector(15 downto 0);
   signal txFifoSOF     : std_logic;
   signal txFifoEOF     : std_logic;
   signal txFifoType    : std_logic_vector(1  downto 0);
   signal txFifoRd      : std_logic;
   signal txFifoEmpty   : std_logic;
   signal rxFifoData    : std_logic_vector(15 downto 0);
   signal rxFifoSOF     : std_logic;
   signal rxFifoType    : std_logic_vector(1  downto 0);
   signal rxFifoWr      : std_logic;
   signal rxFifoFull    : std_logic;
   signal trainFifoReq  : std_logic;
   signal trainFifoAck  : std_logic;
   signal trainFifoSOF  : std_logic;
   signal trainFifoEOF  : std_logic;
   signal trainFifoWr   : std_logic;
   signal trainFifoData : std_logic_vector(15 downto 0);
   signal kpixRspReq    : std_logic;
   signal kpixRspAck    : std_logic;
   signal kpixRspWr     : std_logic;
   signal kpixRspSOF    : std_logic;
   signal kpixRspEOF    : std_logic;
   signal kpixRspData   : std_logic_vector(15 downto 0);
   signal locFifoReq    : std_logic;
   signal locFifoAck    : std_logic;
   signal locFifoWr     : std_logic;
   signal locFifoSOF    : std_logic;
   signal locFifoEOF    : std_logic;
   signal locFifoData   : std_logic_vector(15 downto 0);
   signal trainFifoFull : std_logic;
   signal writeData     : std_logic_vector(31 downto 0);
   signal readData      : std_logic_vector(31 downto 0);
   signal writeEn       : std_logic;
   signal address       : std_logic_vector(7  downto 0);
   signal kpixRunLed    : std_logic;
   signal kpixData      : std_logic_vector(15 downto 0);
   signal kpixSOF       : std_logic;
   signal kpixWr        : std_logic;
   signal kpixFull      : std_logic;
   signal locData       : std_logic_vector(15 downto 0);
   signal locSOF        : std_logic;
   signal locWr         : std_logic;
   signal locFull       : std_logic;
   signal mstRstCmd     : std_logic;
   signal kpixRstCmd    : std_logic;
   signal kpixDly0      : std_logic;
   signal kpixDly1      : std_logic;
   signal sysDly0       : std_logic;
   signal sysDly1       : std_logic;
   signal sys200Dly0    : std_logic;
   signal sys200Dly1    : std_logic;
   signal sysRst200     : std_logic;
   signal checkSumErr   : std_logic;
   signal clkCnt        : std_logic_vector(4 downto 0);
   signal fifoRd        : std_logic;
   signal fifoEmpty     : std_logic;
   signal fifoDin       : std_logic_vector(31 downto 0);
   signal fifoFull      : std_logic;
   signal fifoDout      : std_logic_vector(31 downto 0);
   signal rspData       : std_logic_vector(31 downto 0);

   -- Ethernet Signals
   signal ipAddr          : IPAddrType;
   signal macAddr         : MacAddrType;
   signal udpTxValid      : std_logic;
   signal udpTxReady      : std_logic;
   signal udpTxEOF        : std_logic;
   signal udpTxLength     : std_logic_vector(15 downto 0);
   signal udpTxData       : std_logic_vector(7  downto 0);
   signal udpRxValid      : std_logic;
   signal udpRxData       : std_logic_vector(7 downto 0);
   signal udpRxGood       : std_logic;
   signal udpRxError      : std_logic;
   signal ethTxLength     : std_logic_vector(15 downto 0);
   signal ethTxEmpty      : std_logic;
   signal ethTxSOF        : std_logic;
   signal ethTxEOF        : std_logic;
   signal ethTxData       : std_logic_vector(15 downto 0);
   signal ethTxType       : std_logic_vector(1  downto 0);
   signal ethTxRd         : std_logic;
   signal ethRxValid      : std_logic;
   signal ethRxData       : std_logic_vector(7 downto 0);
   signal ethRxGood       : std_logic;
   signal ethRxError      : std_logic;
   signal gtpClkRst       : std_logic;
   signal reset_r         : std_logic_vector(3 downto 0);
   
   -- Chipscope signals 
   constant enableChipScope : integer := 1;
   signal csControl0        : std_logic_vector(35 downto 0);
   signal csControl1        : std_logic_vector(35 downto 0);
   signal csControl2        : std_logic_vector(35 downto 0);
   signal csControl3        : std_logic_vector(35 downto 0);
   signal csControl4        : std_logic_vector(35 downto 0);
   signal csStat            : std_logic_vector(15 downto 0);
   signal csCntrl           : std_logic_vector(15 downto 0);
   signal pktNum            : std_logic_vector(3  downto 0);
   signal sysDebug          : std_logic_vector(63 downto 0);
   signal EthGtpRst         : std_logic;
   signal EthIntRst         : std_logic;
   

begin

   
   -- Define jumpers
   -- <= not jumpL(3);
   -- <= not jumpL(2);
   -- <= not jumpL(1);
   -- <= not jumpL(0);
   
   
   -- Define LEDs
   ledL(3) <= not kpixRunLed;
   ledL(2) <= usbTxLedL;
   ledL(1) <= usbRxLedL;
   ledL(0) <= kpixRst;

   -- ADC & DAC are unused for now
   dacDin  <= '0';
   dacSclk <= '0';
   dacCsL  <= '1';
   dacClrL <= '1';
   adcSclk <= '0';
   adcCsL  <= '1';

   -- Reset generation, kpixRst
   process ( kpixClk, fpgaRstL, mstRstCmd, kpixRstCmd ) begin
      if fpgaRstL = '0' or mstRstCmd = '1' or kpixRstCmd = '1' then
         kpixDly0 <= '1' after tpd;
         kpixDly1 <= '1' after tpd;
         kpixRst  <= '1' after tpd;
      elsif rising_edge(kpixClk) then
         kpixDly0 <= not kpixLock after tpd; --not jumpL(1) or 
         kpixDly1 <= kpixDly0                     after tpd;
         kpixRst  <= kpixDly1                     after tpd;
      end if;
   end process;

   -- Reset generation, sysRst
   process ( sysClk, fpgaRstL, mstRstCmd ) begin
      if fpgaRstL = '0' or mstRstCmd = '1' then
         sysDly0 <= '1' after tpd;
         sysDly1 <= '1' after tpd;
         sysRst  <= '1' after tpd;
      elsif rising_edge(sysClk) then
         sysDly0 <= not kpixLock after tpd; -- not jumpL(1) or 
         sysDly1 <= sysDly0      after tpd;
         sysRst  <= sysDly1      after tpd;
      end if;
   end process;

   -- Reset generation, sysRst
   process ( sysClk200, fpgaRstL, mstRstCmd ) begin
      if fpgaRstL = '0' or mstRstCmd = '1' then
         sys200Dly0 <= '1' after tpd;
         sys200Dly1 <= '1' after tpd;
         sysRst200  <= '1' after tpd;
      elsif rising_edge(sysClk200) then
         sys200Dly0 <= not kpixLock after tpd; -- not jumpL(1) or 
         sys200Dly1 <= sys200Dly0   after tpd;
         sysRst200  <= sys200Dly1   after tpd;
      end if;
   end process;

   -- Reset generation, gtpClkRst
   process(gtpClkRef, fpgaRstL, mstRstCmd)
   begin
     if (fpgaRstL = '0' or mstRstCmd = '1') then
       reset_r <= "1111";
     elsif rising_edge(gtpClkRef) then
       reset_r <= reset_r(2 downto 0) & (not kpixLock);
     end if;
   end process;
  
   gtpClkRst <= reset_r(3);

   process ( sysClk200, sysRst200 ) begin
      if sysRst200 = '1' then
         fifoDin  <= (others=>'0');
      elsif rising_edge(sysClk200) then
         fifoDin  <= data;
      end if;
   end process;

   U_KpixDataFifo : afifo_35x512 port map (
      din (34 downto 32) => "000",
      din (31 downto  0) => fifoDin,
      wr_clk             => sysClk200,
      wr_en              => kpixRd,
      rst                => sysRst200,
      rd_en              => fifoRd,
      rd_clk             => kpixClk,
      dout(34 downto 32) => open,
      dout(31 downto  0) => fifoDout,
      empty              => fifoEmpty,
      full               => fifoFull,
      wr_data_count      => open );
   
   fifoRd  <= not fifoEmpty;
   rspData <= fifoDout;

   EthGtpRst <= gtpClkRst or csCntrl(0);
   -- GTP Client
   U_EthClientGtp : EthClientGtp generic map ( UdpPort => 8192 ) port map (
      gtpClk      => gtpClk,
      gtpClkOut   => gtpClkOut,
      gtpClkRef   => gtpClkRef,
      gtpClkRst   => EthGtpRst,
      ipAddr      => ipAddr,
      macAddr     => macAddr,
      udpTxValid  => udpTxValid,
      udpTxEOF    => udpTxEOF,
      udpTxReady  => udpTxReady,
      udpTxData   => udpTxData,
      udpTxLength => udpTxLength,
      udpRxValid  => udpRxValid,
      udpRxData   => udpRxData,
      udpRxGood   => udpRxGood,
      udpRxError  => udpRxError,
      gtpRxN      => RXN_0,
      gtpRxP      => RXP_0,
      gtpTxN      => TXN_0,
      gtpTxP      => TXP_0,
      cScopeCtrl1 => csControl1,
      cScopeCtrl2 => csControl2
   );

   EthIntRst <= sysRst or csCntrl(0);
   -- Ethernet Interface
   U_EthInterface : EthInterface port map (
      sysClk      => sysClk,      sysRst      => EthIntRst,
      gtpClk      => gtpClkRef,   gtpClkRst   => gtpClkRst,
      ethTxRd     => txFifoRd,    ethTxEmpty  => txFifoEmpty,
      ethTxSOF    => txFifoSOF,   ethTxEOF    => txFifoEOF,
      ethTxData   => txFifoData,  ethTxType   => txFifoType,
      udpTxValid  => udpTxValid,  udpTxLength => udpTxLength,
      udpTxEOF    => udpTxEOF,    udpTxReady  => udpTxReady,
      udpTxData   => udpTxData,   csControl   => csControl4
   );

   U_KpixDataFrmtr : KpixDataFrmtr port map (
      sysClk      => sysClk,       sysRst      => sysRst,
      emacClk     => gtpClkRef,    emacClkRst  => gtpClkRst,
      rxFifoData  => rxFifoData,
      rxFifoSOF   => rxFifoSOF,    rxFifoType  => rxFifoType,
      rxFifoWr    => rxFifoWr,     rxFifoFull  => rxFifoFull,
      ethRxValid  => udpRxValid,   ethRxData   => udpRxData,
      ethRxGood   => udpRxGood,    ethRxError  => udpRxError,
      csControl   => csControl4
   );

--    U_EthTestCounter : EthTestCounter port map (
--       sysClk      => sysClk,       sysRst      => sysRst,
--       emacClk     => gtpClkRef,    emacClkRst  => gtpClkRst,
--       txFifoData  => txFifoData1,  txFifoSOF   => txFifoSOF1,
--       txFifoType  => txFifoType1,  txFifoRd    => txFifoRd1,
--       txFifoEmpty => txFifoEmpty1, rxFifoData  => rxFifoData1,
--       rxFifoSOF   => rxFifoSOF1,   rxFifoType  => rxFifoType1,
--       rxFifoWr    => rxFifoWr1,    rxFifoFull  => rxFifoFull1,
--       cScopeCtrl  => csControl4,   txFifoEOF   => txFifoEOF1
--    );
      
   -- Loopback block
--    U_EthClientTest : EthClientTest port map (
--       sysClk          => sysClk,
--       sysRst          => sysRst,
--       emacClk         => gtpClkRef,
--       emacClkRst      => gtpClkRst,
--       cScopeCtrl      => csControl1,
--       ethTxSOF        => ethTxSOF,
--       ethTxEOF        => ethTxEOF,
--       ethTxEmpty      => ethTxEmpty,
--       ethTxData       => ethTxData,
--       ethTxType       => ethTxType,
--       ethTxRd         => ethTxRd,
--       ethRxValid      => udpRxValid,
--       ethRxData       => udpRxData,
--       ethRxGood       => udpRxGood,
--       ethRxError      => udpRxError
--    );
   
   -- Upstream Buffer
   U_Upstream: UpstreamData port map (
      sysClk        => sysClk,         sysRst        => sysRst,
      gtpClk        => gtpClkRef,      gtpClkRst     => gtpClkRst,
      trainFifoReq  => trainFifoReq,   trainFifoAck  => trainFifoAck,
      trainFifoSOF  => trainFifoSOF,   trainFifoWr   => trainFifoWr,
      trainFifoData => trainFifoData,  kpixRspReq    => kpixRspReq,
      kpixRspAck    => kpixRspAck,     kpixRspSOF    => kpixRspSOF,
      kpixRspData   => kpixRspData,    kpixRspWr     => kpixRspWr,
      locFifoReq    => locFifoReq,     locFifoWr     => locFifoWr,
      locFifoAck    => locFifoAck,     locFifoSOF    => locFifoSOF,
      locFifoData   => locFifoData,    txFifoData    => txFifoData,
      txFifoSOF     => txFifoSOF,      txFifoType    => txFifoType,
      txFifoRd      => txFifoRd,       txFifoEmpty   => txFifoEmpty,
      trainFifoFull => trainFifoFull,  locFifoEOF    => locFifoEOF,
      kpixRspEOF    => kpixRspEOF,     trainFifoEOF  => trainFifoEOF,
      txFifoEOF     => txFifoEOF,      csControl     => csControl2
   );


   -- Downstream Buffer
   U_Downstream: DownstreamData port map (
      rxFifoData => rxFifoData,  rxFifoSOF  => rxFifoSOF,
      rxFifoType => rxFifoType,  rxFifoWr   => rxFifoWr,
      rxFifoFull => rxFifoFull,  kpixData   => kpixData,
      kpixSOF    => kpixSOF,     kpixWr     => kpixWr,
      kpixFull   => kpixFull,    locData    => locData,
      locSOF     => locSOF,      locWr      => locWr,
      locFull    => locFull
   );


   -- Kpix Controller
   U_Control: KpixControl port map (
      sysClk        => sysClk,         sysRst        => sysRst,
      kpixClk       => kpixClk,        kpixRst       => kpixRst,
      ddrClk        => ddrClk,         ddrRst        => ddrRst,
      writeData     => writeData,      readData      => readData,
      writeEn       => writeEn,        address       => address,
      reset         => reset,          csEnable      => csCntrl,
      forceTrig     => forceTrig,      bncInA        => bncInA,
      bncInB        => bncInB,         bncOutA       => bncOutA,
      bncOutB       => bncOutB,        nimInA        => nimInA,
      nimInB        => nimInB,         trainFifoReq  => trainFifoReq,
      trainFifoAck  => trainFifoAck,   trainFifoSOF  => trainFifoSOF,
      trainFifoWr   => trainFifoWr,    trainFifoData => trainFifoData,
      trainFifoEOF  => trainFifoEOF,   trainFifoFull => trainFifoFull,
      cmdFifoData   => kpixData,       cmdFifoSOF    => kpixSOF,
      cmdFifoWr     => kpixWr,         cmdFifoFull   => kpixFull,
      kpixRspReq    => kpixRspReq,     kpixRspAck    => kpixRspAck,
      kpixRspSOF    => kpixRspSOF,     kpixRspData   => kpixRspData,
      kpixRspEOF    => kpixRspEOF,     kpixRspWr     => kpixRspWr,
      ddr0RdNWr     => ddr0RdNWr,      ddr0LdL       => ddr0LdL,
      ddr0Data      => ddr0Data,       ddr0Addr      => ddr0Addr,
      ddr1RdNWr     => ddr1RdNWr,      ddr1LdL       => ddr1LdL,
      ddr1Data      => ddr1Data,       ddr1Addr      => ddr1Addr,
      serData       => command,        rspData       => rspData,
      kpixRunLed    => kpixRunLed,
      checkSumErr   => checkSumErr,    coreState     => coreState,
      csControl1    => csControl1,     csControl2    => csControl2,
      csControl3    => csControl4
   );



   -- Command Decoder
   U_CmdControl: CmdControl port map (
      sysClk      => sysClk,      sysRst      => sysRst,
      kpixClk     => kpixClk,     kpixRst     => kpixRst,
      checkSumErr => checkSumErr, mstRstCmd   => mstRstCmd,
      kpixRstCmd  => kpixRstCmd,  fifoRxData  => locData,
      fifoRxSOF   => locSOF,      fifoRxWr    => locWr,
      fifoRxFull  => locFull,     fifoTxReq   => locFifoReq,
      fifoTxAck   => locFifoAck,  fifoTxData  => locFifoData,
      fifoTxSOF   => locFifoSOF,  fifoTxEOF   => locFifoEOF,
      fifoTxWr    => locFifoWr,
      clkSelB     => clkSelB,     clkSelC     => clkSelC,
      clkSelD     => clkSelD,     clkSelA     => clkSelA,
      kpixRdPhase => kpixRdPhase, kpixRdEdge  => kpixRdEdge,
      jumpL       => jumpL,       writeData   => writeData,
      readData    => readData,    writeEn     => writeEn,
      address     => address,     csControl   => csControl1
   );

   -- IP Address, 192.168.0.1
   ipAddr(3) <= x"c0";
   ipAddr(2) <= x"A8";
   ipAddr(1) <= x"00";
   ipAddr(0) <= x"01";

   -- MAC Address
   macAddr(0) <= x"08";
   macAddr(1) <= x"00";
   macAddr(2) <= x"56";
   macAddr(3) <= x"00";
   macAddr(4) <= x"03";
   macAddr(5) <= x"01";

   ---------------------------------
   -- Debug Block
   ---------------------------------
--    sysDebug (63 downto 61) <= pktNum(2 downto 0);
   sysDebug (63)           <= fifoFull;
   sysDebug (62)           <= fifoEmpty;
   sysDebug (61)           <= fifoRd;
   sysDebug (60)           <= kpixRd;
   sysDebug (59)           <= trainFifoWr;
   sysDebug (58)           <= trainFifoEOF;
   sysDebug (57)           <= trainFifoSOF;
   sysDebug (56)           <= trainFifoAck;
   sysDebug (55)           <= trainFifoReq;
   sysDebug (54)           <= kpixRspEOF;
   sysDebug (53)           <= kpixRspSOF;
   sysDebug (52)           <= kpixRspAck;
   sysDebug (51)           <= kpixRspReq;
   sysDebug (50)           <= udpTxValid;
   sysDebug (49)           <= udpTxReady;
   sysDebug (48)           <= udpRxValid;
   sysDebug (47 downto 32) <= trainFifoData;
--    sysDebug (31 downto 16) <= kpixRspData;
--    sysDebug (15 downto  8) <= udpTxData;
--    sysDebug (7  downto  0) <= udpRxData;
   sysDebug (10 downto  6) <= divCount;
   sysDebug (5  downto  4) <= rspData(1 downto 0);
   sysDebug (3  downto  2) <= fifoDout(1 downto 0);
   sysDebug (1  downto  0) <= fifoDin(1 downto 0);
   
--    process (sysRst, sysClk) begin
--       if sysRst = '1' then
--          pktNum <= (OTHERS=>'0') after tpd;
--       elsif rising_edge(sysClk) then
--          if trainFifoEOF = '1' then
--             pktNum <= pktNum + 1 after tpd;
--          end if;
--       end if;
--    end process;
   
   csStat <= (OTHERS => '0');

   chipscope : if (enableChipScope = 1) generate   

      U_v5_icon : v5_icon port map ( 
         CONTROL0 => csControl0,
         CONTROL1 => csControl1,
         CONTROL2 => csControl2,
         CONTROL3 => csControl3,
         CONTROL4 => csControl4
      );

      U_SysClk_ila : v5_ila port map (
         CONTROL  => csControl0,
         CLK      => sysClk200, --gtpClkRef
         TRIG0    => sysDebug
      );

      U_v5_vio : v5_vio port map (
         CONTROL  => csControl3,
         CLK      => sysClk,
         SYNC_IN  => csStat,
         SYNC_OUT => csCntrl
      );

   end generate chipscope;

end KpixConCore;

