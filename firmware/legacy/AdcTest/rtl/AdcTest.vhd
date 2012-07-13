-------------------------------------------------------------------------------
-- Title         : ADC Test FPGA, Top Level
-------------------------------------------------------------------------------
-- File          : AdcTest.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/06/2009
-------------------------------------------------------------------------------
-- Description:
-- Top level source code for ADC test FPGA.
-------------------------------------------------------------------------------
-- Copyright (c) 2009 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/06/2009: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity AdcTest is 
   port ( 

      -- System clock, reset
      fpgaRstL      : in    std_logic;
      sysClk20In    : in    std_logic;

      -- USB Controller
      usbData       : inout std_logic_vector(7  downto 0);
      usbRdL        : out   std_logic;
      usbWr         : out   std_logic;
      usbTxeL       : in    std_logic;
      usbRxfL       : in    std_logic;
      usbPwrEnL     : in    std_logic;
 
      -- DAC Signals
      calCsL        : out   std_logic;
      calClrL       : out   std_logic;
      calSClk       : out   std_logic;
      calSDin       : out   std_logic;

      -- ADC Signals
      adcEnable     : out   std_logic;
      adcClk        : out   std_logic;
      adcDout       : in    std_logic 
   );
end AdcTest;


-- Define architecture for core module
architecture AdcTest of AdcTest is 

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

   -- Command Decoder
   component CmdControl
      port (
         sysClk        : in    std_logic;
         sysRst        : in    std_logic;
         rxFifoData    : in    std_logic_vector(15 downto 0);
         rxFifoSOF     : in    std_logic;
         rxFifoType    : in    std_logic_vector(1  downto 0);
         rxFifoWr      : in    std_logic;
         rxFifoFull    : out   std_logic;
         txFifoData    : out   std_logic_vector(15 downto 0);
         txFifoSOF     : out   std_logic;
         txFifoType    : out   std_logic_vector(1  downto 0);
         txFifoRd      : in    std_logic;
         txFifoEmpty   : out   std_logic;                       -- TX FIFO Empty
         calCsL        : out   std_logic;
         calClrL       : out   std_logic;
         calSClk       : out   std_logic;
         calSDin       : out   std_logic;
         adcEnable     : out   std_logic;
         adcClk        : out   std_logic;
         adcDout       : in    std_logic 
      );
   end component;

   -- Xilinx components
   component IBUFG  port ( O : out std_logic; I  : in std_logic ); end component;

   -- Local signals
   signal sysClk20    : std_logic;
   signal sysDly0     : std_logic;
   signal sysDly1     : std_logic;
   signal sysRst      : std_logic;
   signal txFifoData  : std_logic_vector(15 downto 0);
   signal txFifoSOF   : std_logic;
   signal txFifoType  : std_logic_vector(1  downto 0);
   signal txFifoRd    : std_logic;
   signal txFifoEmpty : std_logic;
   signal rxFifoData  : std_logic_vector(15 downto 0);
   signal rxFifoSOF   : std_logic;
   signal rxFifoType  : std_logic_vector(1  downto 0);
   signal rxFifoWr    : std_logic;
   signal rxFifoFull  : std_logic;
   signal usbDin      : std_logic_vector(7  downto 0);
   signal usbDout     : std_logic_vector(7  downto 0);
   signal usbDenL     : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin


   -- Connect system clock to global buffer
   U_SysClk20 : IBUFG port map ( I => sysClk20In, O => sysClk20 );


   -- Reset generation, sysRst
   process ( sysClk20, fpgaRstL ) begin
      if fpgaRstL = '0' then
         sysDly0 <= '1' after tpd;
         sysDly1 <= '1' after tpd;
         sysRst  <= '1' after tpd;
      elsif rising_edge(sysClk20) then
         sysDly0 <= '0'     after tpd;
         sysDly1 <= sysDly0 after tpd;
         sysRst  <= sysDly1 after tpd;
      end if;
   end process;


   -- USB Interface
   U_Usb: UsbWord port map (
      sysClk20    => sysClk20,     
      syncRst     => sysRst,
      txFifoData  => txFifoData,   
      txFifoSOF   => txFifoSOF,
      txFifoType  => txFifoType,   
      txFifoRd    => txFifoRd,
      txFifoEmpty => txFifoEmpty,  
      rxFifoData  => rxFifoData,
      rxFifoSOF   => rxFifoSOF,    
      rxFifoType  => rxFifoType,
      rxFifoWr    => rxFifoWr,     
      rxFifoFull  => rxFifoFull,
      usbDin      => usbDin,       
      usbDout     => usbDout,
      usbRdL      => usbRdL,       
      usbWr       => usbWr,
      usbTxeL     => usbTxeL,      
      usbRxfL     => usbRxfL,
      usbPwrEnL   => usbPwrEnL,    
      usbDenL     => usbDenL,
      usbRxLedL   => open,
      usbTxLedL   => open,
      usbLoopEnL  => '1',          
      usbDebug    => open
   );


   -- USB Data 
   usbData <= usbDout when usbDenL = '0' else (others=>'Z');
   usbDin  <= usbData;


   -- Command Decoder
   U_CmdControl: CmdControl port map (
      sysClk        => sysClk20,
      sysRst        => sysRst,
      rxFifoData    => rxFifoData,
      rxFifoSOF     => rxFifoSOF,
      rxFifoType    => rxFifoType,
      rxFifoWr      => rxFifoWr,
      rxFifoFull    => rxFifoFull,
      txFifoData    => txFifoData,
      txFifoSOF     => txFifoSOF,
      txFifoType    => txFifoType,
      txFifoRd      => txFifoRd,
      txFifoEmpty   => txFifoEmpty,
      calCsL        => calCsL,
      calClrL       => calClrL,
      calSClk       => calSClk,
      calSDin       => calSDin,
      adcEnable     => adcEnable,
      adcClk        => adcClk,
      adcDout       => adcDout
   );
   

end AdcTest;

