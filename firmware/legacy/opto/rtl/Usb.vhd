-------------------------------------------------------------------------------
-- Title         : USB Interface Module
-- Project       : SID, KPIX ASIC
-------------------------------------------------------------------------------
-- File          : Usb.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 02/17/2005
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the USB interface. This module will move data
-- between the FT245BM USB FIFO device and two 8 bit FIFOs, one for transmit
-- (out to PC) and the other for receive (in from PC).
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 10/16/2006: Adjusted timing to optimize data flow.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity Usb is port ( 

      -- System clock, reset
      sysClk20      : in     std_logic;                     -- 20Mhz system clock
      syncRst       : in     std_logic;                     -- System reset

      -- TX FIFO Interface
      txFifoData    : in     std_logic_vector(7  downto 0); -- TX FIFO Data
      txFifoRd      : buffer std_logic;                     -- TX FIFO Read
      txFifoEmpty   : in     std_logic;                     -- TX FIFO Empty

      -- RX FIFO Interface
      rxFifoData    : out    std_logic_vector(7  downto 0); -- RX FIFO Data
      rxFifoWr      : buffer std_logic;                     -- RX FIFO Write
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

   -- Keep from combinging output registers
   attribute syn_preserve : boolean;
   attribute syn_preserve of usbRdL: signal is true;
   attribute syn_preserve of usbWr : signal is true;

end Usb;


-- Define architecture for USB module
architecture Usb of Usb is 

   -- USB Interface States
   constant U_IDLE   : std_logic_vector(3 downto 0) := "0001"; -- IDLE
   constant U_RX_A   : std_logic_vector(3 downto 0) := "0010"; -- RX
   constant U_RX_B   : std_logic_vector(3 downto 0) := "0011"; -- RX
   constant U_RX_C   : std_logic_vector(3 downto 0) := "0100"; -- RX
   constant U_RX_D   : std_logic_vector(3 downto 0) := "0101"; -- RX
   constant U_TX_A   : std_logic_vector(3 downto 0) := "0110"; -- TX
   constant U_TX_B   : std_logic_vector(3 downto 0) := "0111"; -- TX
   constant U_TX_C   : std_logic_vector(3 downto 0) := "1000"; -- TX
   signal   curState : std_logic_vector(3 downto 0);
   signal   nxtState : std_logic_vector(3 downto 0);

   -- Local signals
   signal intRd      : std_logic;                     -- Internal USB read
   signal intWr      : std_logic;                     -- Internal USB write
   signal intDen     : std_logic;                     -- Internal USB write data enable
   signal locRdEn    : std_logic;                     -- Incoming USB data reg enable
   signal locRdEnDly : std_logic;                     -- Incoming USB data reg enable, delay
   signal intDin     : std_logic_vector(7 downto 0);  -- Internal copy of data
   signal intTxe     : std_logic;                     -- Internal USB TX Ready
   signal intRxf     : std_logic;                     -- Internal USB RX Ready
   signal intPwrEn   : std_logic;                     -- Internal USB Pwr En
   signal tmpTxe     : std_logic;                     -- Internal USB TX Ready
   signal tmpRxf     : std_logic;                     -- Internal USB RX Ready
   signal tmpPwrEn   : std_logic;                     -- Internal USB Pwr En
   signal intLoopEn  : std_logic;                     -- Internal USB loop en
   signal rxLedCnt   : std_logic_vector(20 downto 0); -- Internal Rx LED blink count
   signal txLedCnt   : std_logic_vector(20 downto 0); -- Internal Tx LED blink count

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Connect debug signals
   usbDebug(31 downto 24) <= (others=>'0');
   usbDebug(23)           <= txFifoRd;
   usbDebug(22)           <= txFifoEmpty;
   usbDebug(21)           <= rxFifoWr;
   usbDebug(20)           <= rxFifoFull;
   usbDebug(19)           <= intWr;
   usbDebug(18)           <= intRd;
   usbDebug(17)           <= intRxf;
   usbDebug(16)           <= intTxe;
   usbDebug(15 downto  8) <= txFifoData;
   usbDebug(7  downto  0) <= intDin;


   -- Register all external interface signals at IO pads
   -- Use falling edge to minimize delays
   process (sysClk20, syncRst ) begin
      if syncRst = '1' then
         intDin     <= (others=>'0') after tpd;
         intTxe     <= '0'           after tpd;
         intRxf     <= '0'           after tpd;
         intPwrEn   <= '0'           after tpd;
         tmpTxe     <= '0'           after tpd;
         tmpRxf     <= '0'           after tpd;
         tmpPwrEn   <= '0'           after tpd;
         usbDout    <= (others=>'0') after tpd;
         usbRdL     <= '1'           after tpd;
         usbWr      <= '0'           after tpd;
         intLoopEn  <= '0'           after tpd;
         usbDenL    <= '1'           after tpd;
         locRdEnDly <= '0'           after tpd;
      elsif falling_edge(sysClk20) then

         -- Delayed copy of read enable
         locRdEnDly <= locRdEn;

         -- Incoming data has enable
         if locRdEn = '1' then
            intDin <= usbDin after tpd;
         end if;

         -- Outgoing data has mux
         if intLoopEn = '1' then
            usbDout <= intDin     after tpd;
         else
            usbDout <= txFifoData after tpd;
         end if;

         -- Incoming control signals
         tmpTxe   <= not usbTxeL   after tpd;
         tmpRxf   <= not usbRxfL   after tpd;
         tmpPwrEn <= not usbPwrEnL after tpd;
         intTxe   <= tmpTxe        after tpd;
         intRxf   <= tmpRxf        after tpd;
         intPwrEn <= tmpPwrEn      after tpd;

         -- Outgoing control signals
         usbRdL   <= not intRd  after tpd;
         usbWr    <= intWr      after tpd;
         usbDenL  <= not intDen after tpd;

         -- jumper
         intLoopEn <= not usbLoopEnL after tpd;

      end if;
   end process;


   -- Connect FIFO write data
   rxFifoData <= intDin;
   rxFifoWr   <= locRdEnDly and not intLoopEn;


   -- Synchronous state signals
   process (sysClk20, syncRst ) begin
      if syncRst = '1' then
         curState <= U_IDLE after tpd;
      elsif rising_edge(sysClk20) then
         curState <= nxtState after tpd;
      end if;
   end process;


   -- Async state signals
   process ( curState, intTxe, intRxf, intLoopEn, txFifoEmpty, rxFifoFull ) begin
      case curState is 

         -- Idle, wait for available rx data, or local tx data
         when U_IDLE =>

            -- Send data to PC
            if ( intLoopEn = '0' and intTxe = '1' and txFifoEmpty = '0' ) then
               nxtState <= U_TX_A;
               txFifoRd <= '1';

            -- Get data from PC
            elsif ( intRxf = '1' and rxFifoFull = '0' ) then
               nxtState <= U_RX_A;
               txFifoRd <= '0';
            else
               nxtState <= curState;
               txFifoRd <= '0';
            end if;

            -- Idle signals
            intWr    <= '0';
            intRd    <= '0';
            intDen   <= '0';
            locRdEn  <= '0';


         -- Read strobe asserted
         when U_RX_A =>

            -- Read strobe gets asserted, to next state
            intRd    <= '1';
            nxtState <= U_RX_B;

            -- Idle signals
            intWr    <= '0';
            intDen   <= '0';
            locRdEn  <= '0';
            txFifoRd <= '0';


         -- One cycle delay with read strobe asserted
         when U_RX_B =>

            -- Read strobe gets asserted, to next state
            intRd    <= '1';
            nxtState <= U_RX_C;

            -- Idle signals
            intWr    <= '0';
            intDen   <= '0';
            locRdEn  <= '0';
            txFifoRd <= '0';


         -- De-assert read strobe, sample data
         when U_RX_C =>

            -- De-assert read strobe, register data
            intRd    <= '0';
            locRdEn  <= '1';

            -- Transmit right away if in loopback mode
            if intLoopEn = '1' then
               nxtState <= U_TX_A;
            else
               nxtState <= U_RX_D;
            end if;

            -- Idle signals
            intWr    <= '0';
            intDen   <= '0';
            txFifoRd <= '0';


         -- Wait for TXF to go low
         when U_RX_D =>
            intRd    <= '0';
            locRdEn  <= '0';
            intWr    <= '0';
            intDen   <= '0';
            txFifoRd <= '0';

            -- Wait for RXF to assert
            if intRxf = '0' then
               nxtState <= U_IDLE;
            else
               nxtState <= U_RX_D;
            end if;


         -- Assert write strobe
         when U_TX_A =>

            -- Assert write
            intWr    <= '1';
            intDen   <= '1';
            nxtState <= U_TX_B;

            -- Idle signals
            txFifoRd <= '0';
            intRd    <= '0';
            locRdEn  <= '0';


         -- Hold write strobe
         when U_TX_B =>

            -- Assert write
            intWr    <= '1';
            intDen   <= '1';
            nxtState <= U_TX_C;

            -- Idle signals
            txFifoRd <= '0';
            intRd    <= '0';
            locRdEn  <= '0';


         -- Hold data one cycle, wait for TXE low
         when U_TX_C =>

            -- Hold data output enable
            intWr    <= '0';

            if intTxe = '0' then
               nxtState <= U_IDLE;
               intDen   <= '0';
            else
               nxtState <= U_TX_C;
               intDen   <= '1';
            end if;

            -- Idle signals
            txFifoRd <= '0';
            intRd    <= '0';
            locRdEn  <= '0';


         -- Default if error
         when others =>
            nxtState <= U_IDLE;
            txFifoRd <= '0';
            intRd    <= '0';
            intWr    <= '0';
            intDen   <= '0';
            locRdEn  <= '0';

      end case;
   end process;


   -- RX/TX LED Blinker
   process ( sysClk20, syncRst ) begin
      if syncRst = '1' then
         usbRxLedL <= '1'           after tpd;
         usbTxLedL <= '1'           after tpd;
         rxLedCnt  <= (others=>'0') after tpd;
         txLedCnt  <= (others=>'0') after tpd;
      elsif rising_edge(sysClk20) then

         -- Rx detected
         if curState = U_TX_A or curState = U_TX_B or curState = U_TX_C then
            usbRxLedL <= '0'           after tpd;
            rxLedCnt  <= (others=>'1') after tpd;

         -- Stop counting at zero
         elsif rxLedCnt = 0 then
            usbRxLedL <= '1' after tpd;

         -- Count down
         else 
            rxLedCnt <= rxLedCnt - 1 after tpd;
         end if;

         -- Tx detected
         if curState = U_RX_A or curState = U_RX_B or curState = U_RX_C or curState = U_RX_D then
            usbTxLedL <= '0'           after tpd;
            txLedCnt  <= (others=>'1') after tpd;

         -- Stop counting at zero
         elsif txLedCnt = 0 then
            usbTxLedL <= '1' after tpd;

         -- Count down
         else 
            txLedCnt <= txLedCnt - 1 after tpd;
         end if;
      end if;
   end process;

end Usb;
