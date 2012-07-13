-------------------------------------------------------------------------------
-- Title         : USB Interface Module, 16-bit word receive / transmit
-- Project       : SID
-------------------------------------------------------------------------------
-- File          : Usb.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/20/2007
-------------------------------------------------------------------------------
-- Description:
-- This module is a wrapper to the USB interface which receives and transmits
-- data as 16-bit words. The RX/TX words include a start of frame marker 
-- as well as 2-bit type flag.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/20/2007: created.
-- 07/25/2007: Created delay option between USB transfers.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity UsbWord is port ( 

      -- System clock, reset
      sysClk20      : in     std_logic;                     -- 20Mhz system clock
      syncRst       : in     std_logic;                     -- System reset

      -- TX FIFO Interface
      txFifoData    : in     std_logic_vector(15 downto 0); -- TX FIFO Data
      txFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
      txFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
      txFifoRd      : out    std_logic;                     -- TX FIFO Read
      txFifoEmpty   : in     std_logic;                     -- TX FIFO Empty

      -- RX FIFO Interface
      rxFifoData    : out    std_logic_vector(15 downto 0); -- RX FIFO Data
      rxFifoSOF     : out    std_logic;                     -- TX FIFO Start of Frame
      rxFifoType    : out    std_logic_vector(1  downto 0); -- TX FIFO Data Type
      rxFifoWr      : out    std_logic;                     -- RX FIFO Write
      rxFifoFull    : in     std_logic;                     -- RX FIFO Full

      -- USB Controller
      usbDin        : in     std_logic_vector(7  downto 0); -- USB Controller Data In
      usbDout       : out    std_logic_vector(7  downto 0); -- USB Controller Data Out
      usbRdL        : out    std_logic;                     -- USB Controller Read
      usbWr         : out    std_logic;                     -- USB Controller Write
      usbTxeL       : in     std_logic;                     -- USB Controller Tx Ready
      usbRxfL       : in     std_logic;                     -- USB Controller Rx Ready
      usbPwrEnL     : in     std_logic;                     -- USB Controller Power Enable
      usbDenL       : out    std_logic;                     -- USB Output Enable

      -- Debug & LED
      usbRxLedL     : out    std_logic;                     -- Receive Activity LED
      usbTxLedL     : out    std_logic;                     -- Transmit Activity LED
      usbLoopEnL    : in     std_logic;                     -- USB Interface Loop Enable
      usbDebug      : out    std_logic_vector(31 downto 0)  -- USB Interface debug
   );

end UsbWord;


-- Define architecture for USB module
architecture UsbWord of UsbWord is 

   -- USB Interface Module
   component Usb
      port (
         sysClk20      : in     std_logic;                     -- 20Mhz system clock
         syncRst       : in     std_logic;                     -- System reset
         txFifoData    : in     std_logic_vector(7  downto 0); -- TX FIFO Data
         txFifoRd      : buffer std_logic;                     -- TX FIFO Read
         txFifoEmpty   : in     std_logic;                     -- TX FIFO Empty
         rxFifoData    : out    std_logic_vector(7  downto 0); -- RX FIFO Data
         rxFifoWr      : buffer std_logic;                     -- RX FIFO Write
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

   -- Local signals
   signal locTxFifoData  : std_logic_vector(7  downto 0);
   signal locTxFifoRd    : std_logic;
   signal locTxFifoEmpty : std_logic;
   signal locRxFifoData  : std_logic_vector(7  downto 0);
   signal locRxFifoWr    : std_logic;
   signal locRxFifoFull  : std_logic;
   signal txCount        : std_logic_vector(1  downto 0);
   signal nxtTxCount     : std_logic_vector(1  downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin


   -- Transmit direction. 

   -- Byte counter for transmit
   process (sysClk20, syncRst ) begin
      if syncRst = '1' then
         txCount  <= (others=>'0') after tpd;
      elsif rising_edge(sysClk20) then
         txCount <= nxtTxCount after tpd;
      end if;
   end process;

   -- State transition logic
   process ( txCount, txFifoEmpty, locTxFifoRd, txFifoType, txFifoSOF, txFifoData ) begin
      case txCount is

         -- Wait for first read from USB block, 
         -- pass on FIFO status, pass on FIFO read
         -- Output data as if this was the third byte from previous read
         when "00" =>
            locTxFifoEmpty            <= txFifoEmpty;
            txFifoRd                  <= locTxFifoRd;
            locTxFifoData(7 downto 6) <= "01";
            locTxFifoData(5 downto 0) <= txFifoData(15 downto 10);

            if locTxFifoRd = '1' then
               nxtTxCount <= "01";
            else
               nxtTxCount <= txCount;
            end if;

         -- First read has occured, pass read data to USB block
         -- Don't read from FIFO, fake FIFO non-empty
         when "01" =>
            locTxFifoEmpty            <= '0';
            txFifoRd                  <= '0';
            locTxFifoData(7)          <= '1';
            locTxFifoData(6)          <= txFifoSOF;
            locTxFifoData(5 downto 4) <= txFifoType;
            locTxFifoData(3 downto 0) <= txFifoData(3 downto 0);

            if locTxFifoRd = '1' then
               nxtTxCount <= "10";
            else
               nxtTxCount <= txCount;
            end if;

         -- Second read has occured, pass read data to USB block
         -- Don't read from FIFO, fake FIFO non-empty. Reset
         -- counter on read.
         when "10" =>
            locTxFifoEmpty            <= '0';
            txFifoRd                  <= '0';
            locTxFifoData(7 downto 6) <= "00";
            locTxFifoData(5 downto 0) <= txFifoData(9 downto 4);

            if locTxFifoRd = '1' then
               nxtTxCount <= "00";
            else
               nxtTxCount <= txCount;
            end if;

         -- Just in case
         when others => 
            locTxFifoEmpty <= '1';
            txFifoRd       <= '0';
            locTxFifoData  <= (others=>'0');
            nxtTxCount     <= "00";
      end case;
   end process;


   -- Receive direction. 

   -- Forward FIFO status
   locRxFifoFull <= rxFifoFull;

   -- Convert byte data into 16-bit words
   process (sysClk20, syncRst ) begin
      if syncRst = '1' then
         rxFifoData <= (others=>'0') after tpd;
         rxFifoSOF  <= '0'           after tpd;
         rxFifoType <= "00"          after tpd;
         rxFifoWr   <= '0'           after tpd;
      elsif falling_edge(sysClk20) then

         -- FIFO Write
         if locRxFifoWr = '1' then

            -- Byte 0
            if locRxFifoData(7) = '1' then
               rxFifoData(3 downto 0) <= locRxFifoData(3 downto 0) after tpd;
               rxFifoType             <= locRxFifoData(5 downto 4) after tpd;
               rxFifoSOF              <= locRxFifoData(6)          after tpd;
               rxFifoWr               <= '0'                       after tpd;
            else

               -- Byte 1 
               if locRxFifoData(6) = '0' then
                  rxFifoData(9 downto 4) <= locRxFifoData(5 downto 0) after tpd;
                  rxFifoWr               <= '0'                       after tpd;
               
               -- Byte 2
               else 
                  rxFifoData(15 downto 10) <= locRxFifoData(5 downto 0) after tpd;
                  rxFifoWr                 <= '1'                       after tpd;
               end if;
            end if;
         else
            rxFifoWr <= '0' after tpd;
         end if;
      end if;
   end process;


   -- USB interface module
   U_USB: Usb port map (
      sysClk20    => sysClk20,       syncRst     => syncRst,
      txFifoData  => locTxFifoData,  txFifoRd    => locTxFifoRd,
      txFifoEmpty => locTxFifoEmpty, rxFifoData  => locRxFifoData,
      rxFifoWr    => locRxFifoWr,    rxFifoFull  => locRxFifoFull,
      usbDin      => usbDin,         usbDout     => usbDout,
      usbRdL      => usbRdL,         usbWr       => usbWr,
      usbTxeL     => usbTxeL,        usbRxfL     => usbRxfL,
      usbPwrEnL   => usbPwrEnL,      usbDenL     => usbDenL,
      usbRxLedL   => usbRxLedL,      usbTxLedL   => usbTxLedL,
      usbLoopEnL  => usbLoopEnL,     usbDebug    => usbDebug
   );

end UsbWord;
