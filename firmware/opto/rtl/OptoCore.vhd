-------------------------------------------------------------------------------
-- Title         : KPIX Optical Interface FPGA Core Module
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : OptoCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/25/2007
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the optical interface FPGA on the KPIX Test Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/25/2005: created.
-- 07/24/2007: Added inter-word usb delay
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity OptoCore is 
   port ( 

      -- System clock, reset
      fpgaRstL      : in    std_logic;                     -- Asynchronous local reset
      sysClk20      : in    std_logic;                     -- 20Mhz system clock
      kpixClk       : in    std_logic;                     -- Kpix Clock
      kpixLock      : in    std_logic;                     -- Kpix DLL Lock

      -- Clock Selection
      clkSelA       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelB       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelC       : out   std_logic_vector(4  downto 0); -- Clock selection
      clkSelD       : out   std_logic_vector(4  downto 0); -- Clock selection
      coreState     : out   std_logic_vector(2  downto 0); -- State of internal core

      -- Jumper & LEDS
      jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
      ledL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs

      -- Debug connector
      debug         : out   std_logic_vector(31 downto 0); -- Debug connector

      -- USB Controller
      usbDin        : in    std_logic_vector(7  downto 0); -- USB Controller Data In
      usbDout       : out   std_logic_vector(7  downto 0); -- USB Controller Data Out
      usbRdL        : out   std_logic;                     -- USB Controller Read
      usbWr         : out   std_logic;                     -- USB Controller Write
      usbTxeL       : in    std_logic;                     -- USB Controller Tx Ready
      usbRxfL       : in    std_logic;                     -- USB Controller Rx Ready
      usbPwrEnL     : in    std_logic;                     -- USB Controller Power Enable
      usbDenL       : out   std_logic;                     -- USB Output Enable

      -- Optical Interface to Kpix devices
      reset         : out   std_logic;                     -- Reset to KPIX devices
      forceTrig     : out   std_logic;                     -- Force trigger to KPIX Devices
      commandA      : out   std_logic;                     -- Command to KPIX A devices
      commandB      : out   std_logic;                     -- Command to KPIX B devices
      commandC      : out   std_logic;                     -- Command to KPIX C devices
      dataA         : in    std_logic;                     -- Data from from KPIX A devices
      dataB         : in    std_logic;                     -- Data from from KPIX B devices
      dataC         : in    std_logic;                     -- Data from from KPIX C devices

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
      dacClrL       : out   std_logic                      -- Cal Data Clear
   );
end OptoCore;


-- Define architecture for core module
architecture OptoCore of OptoCore is 

   -- USB Interface
   component UsbWord
      port (
         sysClk20      : in     std_logic;                     -- 20Mhz system clock
         syncRst       : in     std_logic;                     -- System reset
         txFifoData    : in     std_logic_vector(15 downto 0); -- TX FIFO Data
         txFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
         txFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
         txFifoRd      : out    std_logic;                     -- TX FIFO Read
         txFifoEmpty   : in     std_logic;                     -- TX FIFO Empty
         rxFifoData    : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         rxFifoSOF     : out    std_logic;                     -- TX FIFO Start of Frame
         rxFifoType    : out    std_logic_vector(1  downto 0); -- TX FIFO Data Type
         rxFifoWr      : out    std_logic;                     -- RX FIFO Write
         rxFifoFull    : in     std_logic;                     -- RX FIFO Full
         usbDin        : in     std_logic_vector(7  downto 0); -- USB Controller Data In
         usbDout       : out    std_logic_vector(7  downto 0); -- USB Controller Data Out
         usbRdL        : out    std_logic;                     -- USB Controller Read
         usbWr         : out    std_logic;                     -- USB Controller Write
         usbTxeL       : in     std_logic;                     -- USB Controller Tx Ready
         usbRxfL       : in     std_logic;                     -- USB Controller Rx Ready
         usbPwrEnL     : in     std_logic;                     -- USB Controller Power Enable
         usbDenL       : out    std_logic;                     -- USB Output Enable
         usbRxLedL     : out    std_logic;                     -- Receive Activity LED
         usbTxLedL     : out    std_logic;                     -- Transmit Activity LED
         usbLoopEnL    : in     std_logic;                     -- USB Interface Loop Enable
         usbDebug      : out    std_logic_vector(31 downto 0)  -- USB Interface debug
      );
   end component;

   -- Upstream Buffer
   component UpstreamData
      port (
         sysClk        : in    std_logic;                       -- 20Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         kpixClk       : in    std_logic;                       -- 20Mhz system clock
         kpixRst       : in    std_logic;                       -- System reset
         trainFifoReq  : in    std_logic;                       -- FIFO Write Request
         trainFifoAck  : out   std_logic;                       -- FIFO Write Grant
         trainFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         trainFifoWr   : in    std_logic;                       -- FIFO Write Strobe
         trainFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         kpixAFifoReq  : in    std_logic;                       -- FIFO Write Request
         kpixAFifoAck  : out   std_logic;                       -- FIFO Write Grant
         kpixAFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         kpixAFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         kpixBFifoReq  : in    std_logic;                       -- FIFO Write Request
         kpixBFifoAck  : out   std_logic;                       -- FIFO Write Grant
         kpixBFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         kpixBFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         kpixCFifoReq  : in    std_logic;                       -- FIFO Write Request
         kpixCFifoAck  : out   std_logic;                       -- FIFO Write Grant
         kpixCFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         kpixCFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         kpixDFifoReq  : in    std_logic;                       -- FIFO Write Request
         kpixDFifoAck  : out   std_logic;                       -- FIFO Write Grant
         kpixDFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         kpixDFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         locFifoReq    : in    std_logic;                       -- FIFO Write Request
         locFifoAck    : out   std_logic;                       -- FIFO Write Grant
         locFifoSOF    : in    std_logic;                       -- FIFO Word SOF
         locFifoData   : in    std_logic_vector(15 downto 0);   -- FIFO Word
         txFifoData    : out   std_logic_vector(15 downto 0);   -- TX FIFO Data
         txFifoSOF     : out   std_logic;                       -- TX FIFO Start of Frame
         txFifoType    : out   std_logic_vector(1  downto 0);   -- TX FIFO Data Type
         txFifoRd      : in    std_logic;                       -- TX FIFO Read
         txFifoEmpty   : out   std_logic;                       -- TX FIFO Empty
         trainFifoFull : out   std_logic                        -- Train FIFO is full
      );
   end component;

   -- Downstream Buffer
   component DownstreamData
      port (
         rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
         rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
         rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
         rxFifoWr      : in     std_logic;                     -- RX FIFO Write
         rxFifoFull    : out    std_logic;                     -- RX FIFO Full
         kpixData      : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         kpixSOF       : out    std_logic;                     -- RX FIFO Start of Frame
         kpixWr        : out    std_logic;                     -- RX FIFO Write
         kpixFull      : in     std_logic;                     -- RX FIFO Full
         locData       : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         locSOF        : out    std_logic;                     -- RX FIFO Start of Frame
         locWr         : out    std_logic;                     -- RX FIFO Write
         locFull       : in     std_logic                      -- RX FIFO Full
      );
   end component;

   -- Kpix Controller
   component KpixControl
      port (
         kpixClk       : in    std_logic;                       -- 20Mhz system clock
         kpixRst       : in    std_logic;                       -- System reset
         sysClk        : in    std_logic;                       -- 20Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         checkSumErr   : out   std_logic;                     -- Checksum error flag
         writeData     : in    std_logic_vector(31 downto 0);   -- Write Data
         readData      : out   std_logic_vector(31 downto 0);   -- Read Data
         writeEn       : in    std_logic;                       -- Write strobe
         address       : in    std_logic_vector(7  downto 0);   -- Address select
         coreState     : out   std_logic_vector(2  downto 0);   -- State of internal core
         trainFifoFull : in    std_logic;                       -- Train FIFO is full
         kpixRunLed    : out   std_logic;                       -- Kpix RUN LED
         reset         : out   std_logic;                       -- Kpix Reset
         forceTrig     : out   std_logic;                       -- Kpix Force Trigger
         bncInA        : in    std_logic;                       -- BNC Interface A input
         bncInB        : in    std_logic;                       -- BNC Interface B input
         bncOutA       : out   std_logic;                       -- BNC Interface A output
         bncOutB       : out   std_logic;                       -- BNC Interface B output
         nimInA        : in    std_logic;                       -- NIM Interface A input
         nimInB        : in    std_logic;                       -- NIM Interface B input
         trainFifoReq  : out   std_logic;                       -- FIFO Write Request
         trainFifoAck  : in    std_logic;                       -- FIFO Write Grant
         trainFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         trainFifoWr   : out   std_logic;                       -- FIFO Write Strobe
         trainFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         cmdFifoData   : in    std_logic_vector(15 downto 0);   -- RX FIFO Data
         cmdFifoSOF    : in    std_logic;                       -- RX FIFO Start of Frame
         cmdFifoWr     : in    std_logic;                       -- RX FIFO Write
         cmdFifoFull   : out   std_logic;                       -- RX FIFO Full
         kpixAFifoReq  : out   std_logic;                       -- FIFO Write Request
         kpixAFifoAck  : in    std_logic;                       -- FIFO Write Grant
         kpixAFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         kpixAFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         kpixBFifoReq  : out   std_logic;                       -- FIFO Write Request
         kpixBFifoAck  : in    std_logic;                       -- FIFO Write Grant
         kpixBFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         kpixBFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         kpixCFifoReq  : out   std_logic;                       -- FIFO Write Request
         kpixCFifoAck  : in    std_logic;                       -- FIFO Write Grant
         kpixCFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         kpixCFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         kpixDFifoReq  : out   std_logic;                       -- FIFO Write Request
         kpixDFifoAck  : in    std_logic;                       -- FIFO Write Grant
         kpixDFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         kpixDFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         serDataA      : out   std_logic;                       -- Serial data out A
         serDataB      : out   std_logic;                       -- Serial data out B
         serDataC      : out   std_logic;                       -- Serial data out C
         rspDataA    : in    std_logic;                         -- Incoming serial data A
         rspDataB    : in    std_logic;                         -- Incoming serial data B
         rspDataC    : in    std_logic                          -- Incoming serial data C
      );
   end component;

   -- Command Decoder
   component CmdControl
      port (
         sysClk        : in    std_logic;                     -- 20Mhz system clock
         sysRst        : in    std_logic;                     -- System reset
         kpixClk       : in    std_logic;                     -- 20Mhz system clock
         kpixRst       : in    std_logic;                     -- System reset
         checkSumErr   : in    std_logic;                     -- Checksum error flag
         mstRstCmd     : out   std_logic;                     -- Master reset command
         kpixRstCmd    : out   std_logic;                     -- Kpix reset command
         fifoRxData    : in    std_logic_vector(15 downto 0); -- RX FIFO Data
         fifoRxSOF     : in    std_logic;                     -- RX FIFO Start of Frame
         fifoRxWr      : in    std_logic;                     -- RX FIFO Write
         fifoRxFull    : out   std_logic;                     -- RX FIFO Full
         fifoTxReq     : out   std_logic;                     -- RX FIFO Request
         fifoTxAck     : in    std_logic;                     -- RX FIFO Grant
         fifoTxData    : out   std_logic_vector(15 downto 0); -- RX FIFO Data
         fifoTxSOF     : out   std_logic;                     -- RX FIFO Start of Frame
         clkSelA       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelB       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelC       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelD       : out   std_logic_vector(4  downto 0); -- Clock select
         jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
         writeData     : out   std_logic_vector(31 downto 0); -- Write Data
         readData      : in    std_logic_vector(31 downto 0); -- Read Data
         writeEn       : out   std_logic;                     -- Write strobe
         address       : out   std_logic_vector(7  downto 0)  -- Address select
      );
   end component;


   -- Local signals
   signal sysRst        : std_logic;
   signal kpixRst       : std_logic;
   signal usbRxLedL     : std_logic;
   signal usbTxLedL     : std_logic;
   signal txFifoData    : std_logic_vector(15 downto 0);
   signal txFifoSOF     : std_logic;
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
   signal trainFifoWr   : std_logic;
   signal trainFifoData : std_logic_vector(15 downto 0);
   signal kpixAFifoReq  : std_logic;
   signal kpixAFifoAck  : std_logic;
   signal kpixAFifoSOF  : std_logic;
   signal kpixAFifoData : std_logic_vector(15 downto 0);
   signal kpixBFifoReq  : std_logic;
   signal kpixBFifoAck  : std_logic;
   signal kpixBFifoSOF  : std_logic;
   signal kpixBFifoData : std_logic_vector(15 downto 0);
   signal kpixCFifoReq  : std_logic;
   signal kpixCFifoAck  : std_logic;
   signal kpixCFifoSOF  : std_logic;
   signal kpixCFifoData : std_logic_vector(15 downto 0);
   signal kpixDFifoReq  : std_logic;
   signal kpixDFifoAck  : std_logic;
   signal kpixDFifoSOF  : std_logic;
   signal kpixDFifoData : std_logic_vector(15 downto 0);
   signal locFifoReq    : std_logic;
   signal locFifoAck    : std_logic;
   signal locFifoSOF    : std_logic;
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
   signal checkSumErr   : std_logic;
   signal clkCnt        : std_logic_vector(4 downto 0);
   signal sysClk1       : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

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
         kpixDly0 <= not jumpL(1) or not kpixLock after tpd;
         kpixDly1 <= kpixDly0                     after tpd;
         kpixRst  <= kpixDly1                     after tpd;
      end if;
   end process;


   -- Reset generation, sysRst
   process ( sysClk20, fpgaRstL, mstRstCmd ) begin
      if fpgaRstL = '0' or mstRstCmd = '1' then
         sysDly0 <= '1' after tpd;
         sysDly1 <= '1' after tpd;
         sysRst  <= '1' after tpd;
      elsif rising_edge(sysClk20) then
         sysDly0 <= not jumpL(1) or not kpixLock after tpd;
         sysDly1 <= sysDly0                      after tpd;
         sysRst  <= sysDly1                      after tpd;
      end if;
   end process;


   -- USB Interface
   U_Usb: UsbWord port map (
      sysClk20    => sysClk20,     syncRst     => sysRst,
      txFifoData  => txFifoData,   txFifoSOF   => txFifoSOF,
      txFifoType  => txFifoType,   txFifoRd    => txFifoRd,
      txFifoEmpty => txFifoEmpty,  rxFifoData  => rxFifoData,
      rxFifoSOF   => rxFifoSOF,    rxFifoType  => rxFifoType,
      rxFifoWr    => rxFifoWr,     rxFifoFull  => rxFifoFull,
      usbDin      => usbDin,       usbDout     => usbDout,
      usbRdL      => usbRdL,       usbWr       => usbWr,
      usbTxeL     => usbTxeL,      usbRxfL     => usbRxfL,
      usbPwrEnL   => usbPwrEnL,    usbDenL     => usbDenL,
      usbRxLedL   => usbRxLedL,    usbTxLedL   => usbTxLedL,
      usbLoopEnL  => '1',          usbDebug    => open
   );


   -- Upstream Buffer
   U_Upstream: UpstreamData port map (
      sysClk        => sysClk20,       sysRst        => sysRst,
      kpixClk       => kpixClk,        kpixRst       => kpixRst,
      trainFifoReq  => trainFifoReq,   trainFifoAck  => trainFifoAck,
      trainFifoSOF  => trainFifoSOF,   trainFifoWr   => trainFifoWr,
      trainFifoData => trainFifoData,  kpixAFifoReq  => kpixAFifoReq,
      kpixAFifoAck  => kpixAFifoAck,   kpixAFifoSOF  => kpixAFifoSOF,
      kpixAFifoData => kpixAFifoData,  kpixBFifoReq  => kpixBFifoReq,
      kpixBFifoAck  => kpixBFifoAck,   kpixBFifoSOF  => kpixBFifoSOF,
      kpixBFifoData => kpixBFifoData,  kpixCFifoReq  => kpixCFifoReq,
      kpixCFifoAck  => kpixCFifoAck,   kpixCFifoSOF  => kpixCFifoSOF,
      kpixCFifoData => kpixCFifoData,  kpixDFifoReq  => kpixDFifoReq,
      kpixDFifoAck  => kpixDFifoAck,   kpixDFifoSOF  => kpixDFifoSOF,
      kpixDFifoData => kpixDFifoData,  locFifoReq    => locFifoReq,
      locFifoAck    => locFifoAck,     locFifoSOF    => locFifoSOF,
      locFifoData   => locFifoData,    txFifoData    => txFifoData,
      txFifoSOF     => txFifoSOF,      txFifoType    => txFifoType,
      txFifoRd      => txFifoRd,       txFifoEmpty   => txFifoEmpty,
      trainFifoFull => trainFifoFull

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
      sysClk        => sysClk20,       sysRst        => sysRst,
      kpixClk       => kpixClk,        kpixRst       => kpixRst,
      writeData     => writeData,      readData      => readData,
      writeEn       => writeEn,        address       => address,
      reset         => reset,
      forceTrig     => forceTrig,      bncInA        => bncInA,
      bncInB        => bncInB,         bncOutA       => bncOutA,
      bncOutB       => bncOutB,        nimInA        => nimInA,
      nimInB        => nimInB,         trainFifoReq  => trainFifoReq,
      trainFifoAck  => trainFifoAck,   trainFifoSOF  => trainFifoSOF,
      trainFifoWr   => trainFifoWr,    trainFifoData => trainFifoData,
      cmdFifoData   => kpixData,       cmdFifoSOF    => kpixSOF,
      cmdFifoWr     => kpixWr,         cmdFifoFull   => kpixFull,
      kpixAFifoReq  => kpixAFifoReq,   kpixAFifoAck  => kpixAFifoAck,
      kpixAFifoSOF  => kpixAFifoSOF,   kpixAFifoData => kpixAFifoData,
      kpixBFifoReq  => kpixBFifoReq,   kpixBFifoAck  => kpixBFifoAck,
      kpixBFifoSOF  => kpixBFifoSOF,   kpixBFifoData => kpixBFifoData,
      kpixCFifoReq  => kpixCFifoReq,   kpixCFifoAck  => kpixCFifoAck,
      kpixCFifoSOF  => kpixCFifoSOF,   kpixCFifoData => kpixCFifoData,
      kpixDFifoReq  => kpixDFifoReq,   kpixDFifoAck  => kpixDFifoAck,
      kpixDFifoSOF  => kpixDFifoSOF,   kpixDFifoData => kpixDFifoData,
      serDataA      => commandA,       serDataB      => commandB,
      serDataC      => commandC,       rspDataA      => dataA,
      rspDataB      => dataB,          rspDataC      => dataC,
      trainFifoFull => trainFifoFull,  kpixRunLed    => kpixRunLed,
      checkSumErr   => checkSumErr,    coreState     => coreState
   );



   -- Command Decoder
   U_CmdControl: CmdControl port map (
      sysClk      => sysClk20,    sysRst      => sysRst,
      kpixClk     => kpixClk,     kpixRst     => kpixRst,
      checkSumErr => checkSumErr, mstRstCmd   => mstRstCmd,
      kpixRstCmd  => kpixRstCmd,  fifoRxData  => locData,
      fifoRxSOF   => locSOF,      fifoRxWr    => locWr,
      fifoRxFull  => locFull,     fifoTxReq   => locFifoReq,
      fifoTxAck   => locFifoAck,  fifoTxData  => locFifoData,
      fifoTxSOF   => locFifoSOF,  clkSelA     => clkSelA,
      clkSelB     => clkSelB,     clkSelC     => clkSelC,
      clkSelD     => clkSelD,
      jumpL       => jumpL,       writeData   => writeData,
      readData    => readData,    writeEn     => writeEn,
      address     => address
   );

   
   -- 1Mhz Clock Generator
   process ( sysClk20, sysRst ) begin
      if sysRst = '1' then
         sysClk1 <= '0'           after tpd;
         clkCnt  <= (others=>'0') after tpd;
      elsif rising_edge(sysClk20) then

         -- Generate 1Mhz Clock
         if clkCnt = 19 then
            sysClk1 <= '1'           after tpd;
            clkCnt  <= (others=>'0') after tpd;
         else
            sysClk1 <= '0'           after tpd;
            clkCnt  <= clkCnt + 1    after tpd;
         end if;
      end if;
   end process;

   debug(31 downto 0) <= (others=>'0');

end OptoCore;

