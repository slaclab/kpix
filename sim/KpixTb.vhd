-------------------------------------------------------------------------------
-- Title         : KPIX Asic Test Bench
-- Project       : SID, KPIX ASIC
-------------------------------------------------------------------------------
-- File          : KpixTb.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/10/2007
-------------------------------------------------------------------------------
-- Description:
-- Test Bench for KPIX ASIC & OPTO FPGA
-------------------------------------------------------------------------------
-- Copyright (c) 2006 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/10/2007: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity KpixTb is end KpixTb;


-- Define architecture
architecture KpixTb of KpixTb is

   -- Opto FPGA
   component Opto
      port (
         iFpgaRstL      : in    std_logic;
         iSysClk20      : in    std_logic;
         iSysClk200     : in    std_logic;
         kpixLock       : in    std_logic;
         iJumpL         : in    std_logic_vector(3  downto 0);
         oLedL          : out   std_logic_vector(3  downto 0);
         oDebug         : out   std_logic_vector(31 downto 0);
         oDbgClk        : out   std_logic;
         oForceTrig     : out   std_logic;
         ioUsbData      : inout std_logic_vector(7  downto 0);
         oUsbRdL        : out   std_logic;
         oUsbWr         : out   std_logic;
         iUsbTxeL       : in    std_logic;
         iUsbRxfL       : in    std_logic;
         iUsbPwrEnL     : in    std_logic;
         oSysclk        : out   std_logic;
         oReset         : out   std_logic;
         oCommandA      : out   std_logic;
         oCommandB      : out   std_logic;
         oCommandC      : out   std_logic;
         iDataA         : in    std_logic;
         iDataB         : in    std_logic;
         iDataC         : in    std_logic;
         iBncInA        : in    std_logic;
         iBncInB        : in    std_logic;
         oBncOutA       : out   std_logic;
         oBncOutB       : out   std_logic;
         iNimInA        : in    std_logic;
         iNimInB        : in    std_logic;
         iAdcSData      : in    std_logic;
         oAdcSclk       : out   std_logic;
         oAdcCsL        : out   std_logic;
         oDacDin        : out   std_logic;
         oDacSclk       : out   std_logic;
         oDacCsL        : out   std_logic;
         oDacClrL       : out   std_logic
      );
   end component;


   -- Kpix simulation, analog
   component Kpix
      port (
         ext_clk        : in    std_logic;
         reset_c        : in    std_logic;
         trig           : in    std_logic;
         command_c      : in    std_logic;
         rdback_p       : out   std_logic
      );
   end component;


   -- Kpix simulation, digital
   component RtlKpix
      port (
         ext_clk        : in    std_logic;
         reset_c        : in    std_logic;
         trig           : in    std_logic;
         command_c      : in    std_logic;
         rdback_p       : out   std_logic
      );
   end component;


   -- USB Chip
   component UsbChip
      port (
         sysClk       : in    std_logic;
         sysRst       : in    std_logic;
         usbDin       : in    std_logic_vector(7  downto 0);
         usbDout      : out   std_logic_vector(7  downto 0);
         usbRdL       : in    std_logic;
         usbWr        : in    std_logic;
         usbTxeL      : out   std_logic;
         usbRxfL      : out   std_logic;
         usbPwrEnL    : out   std_logic 
      );
   end component;


   -- Internal signals
   signal iFpgaRstL      : std_logic;
   signal iFpgaRst       : std_logic;
   signal iSysClk20      : std_logic;
   signal iSysClk200     : std_logic;
   signal kpixLock       : std_logic;
   signal iJumpL         : std_logic_vector(3  downto 0);
   signal oLedL          : std_logic_vector(3  downto 0);
   signal oDebug         : std_logic_vector(31 downto 0);
   signal oDbgClk        : std_logic;
   signal oForceTrig     : std_logic;
   signal ioUsbData      : std_logic_vector(7  downto 0);
   signal usbDin         : std_logic_vector(7  downto 0);
   signal usbDout        : std_logic_vector(7  downto 0);
   signal oUsbRdL        : std_logic;
   signal oUsbWr         : std_logic;
   signal iUsbTxeL       : std_logic;
   signal iUsbRxfL       : std_logic;
   signal iUsbPwrEnL     : std_logic;
   signal oSysclk        : std_logic;
   signal oReset         : std_logic;
   signal oCommandA      : std_logic;
   signal oCommandB      : std_logic;
   signal oCommandC      : std_logic;
   signal iDataA         : std_logic;
   signal iDataB         : std_logic;
   signal iDataC         : std_logic;
   signal iBncInA        : std_logic;
   signal iBncInB        : std_logic;
   signal oBncOutA       : std_logic;
   signal oBncOutB       : std_logic;
   signal iNimInA        : std_logic;
   signal iNimInB        : std_logic;
   signal iAdcSData      : std_logic;
   signal oAdcSclk       : std_logic;
   signal oAdcCsL        : std_logic;
   signal oDacDin        : std_logic;
   signal oDacSclk       : std_logic;
   signal oDacCsL        : std_logic;
   signal oDacClrL       : std_logic;

begin

   -- 20Mhz User Clock generation
   process 
   begin
      iSysClk20 <= '0';
      wait for (50 ns / 2);
      iSysClk20 <= '1';
      wait for (50 ns / 2);
   end process;

   -- 200Mhz User Clock generation
   process 
   begin
      iSysClk200 <= '0';
      wait for (5 ns / 2);
      iSysClk200 <= '1';
      wait for (5 ns / 2);
   end process;

   -- Reset generation
   process 
   begin
      iFpgaRstL <= '0';
      wait for (50 ns * 20);
      iFpgaRstL <= '1';
      wait;
   end process;

   -- Reset generation
   process 
   begin
      kpixLock  <= '0';
      wait for (50 ns * 5);
      kpixLock  <= '1';
      wait;
   end process;


   -- Invert reset
   iFpgaRst <= not iFpgaRstL;


   -- Jumper
   iJumpL <= (others=>'1');


   -- Unused inputs
   iBncInA   <= '0';
   iBncInB   <= '0';
   iNimInA   <= '0';
   iNimInB   <= '0';
   iAdcSData <= '0';


   -- Unused Kpix
   iDataA <= '0';
   iDataB <= '0';

   -- Kpix simulation
   U_KpixC: Kpix port map (   -- Analog
   --U_KpixC: RtlKpix port map ( -- Digital
      ext_clk    => oSysclk,    reset_c    => oReset,
      trig       => oForceTrig, command_c  => oCommandC,
      rdback_p   => iDataC
   );


   -- Opto FPGA
   U_Opto: Opto port map (
      iFpgaRstL  => iFpgaRstL,   iSysClk20  => iSysClk20,
      iSysClk200 => iSysClk200,  kpixLock   => kpixLock,
      iJumpL     => iJumpL,      oLedL      => oLedL,
      oDebug     => oDebug,      oDbgClk    => oDbgClk,
      oForceTrig => oForceTrig,  ioUsbData  => ioUsbData,
      oUsbRdL    => oUsbRdL,     oUsbWr     => oUsbWr,
      iUsbTxeL   => iUsbTxeL,    iUsbRxfL   => iUsbRxfL,
      iUsbPwrEnL => iUsbPwrEnL,  oSysclk    => oSysclk,
      oReset     => oReset,      oCommandA  => oCommandA,
      oCommandB  => oCommandB,   oCommandC  => oCommandC,
      iDataA     => iDataA,      iDataB     => iDataB,
      iDataC     => iDataC,      iBncInA    => iBncInA,
      iBncInB    => iBncInB,     oBncOutA   => oBncOutA,
      oBncOutB   => oBncOutB,    iNimInA    => iNimInA,
      iNimInB    => iNimInB,     iAdcSData  => iAdcSData,
      oAdcSclk   => oAdcSclk,    oAdcCsL    => oAdcCsL,
      oDacDin    => oDacDin,     oDacSclk   => oDacSclk,
      oDacCsL    => oDacCsL,     oDacClrL   => oDacClrL
   );


   -- Read control
   ioUsbData <= usbDout when oUsbRdL = '0' else (others=>'Z');
   usbDin    <= ioUsbData;

   -- USB Chip
   U_UsbChip: UsbChip port map (
      sysClk    => iSysClk20,  sysRst  => iFpgaRst, 
      usbDin    => usbDin,     usbDout => usbDout, 
      usbRdL    => oUsbRdL,    usbWr   => oUsbWr,   
      usbTxeL   => iUsbTxeL,   usbRxfL => iUsbRxfL,
      usbPwrEnL => iUsbPwrEnL
   );

end KpixTb;

