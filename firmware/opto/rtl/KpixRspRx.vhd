-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Response Frame Receiver
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixRspRx.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the response frame receiver.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 12/12/2004: Added frame integrity test
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity KpixRspRx is 
   port ( 

      -- System clock, reset
      kpixClk     : in    std_logic;                       -- 20Mhz system clock
      kpixRst     : in    std_logic;                       -- System reset

      -- FIFO Interface, req/ack type interface
      fifoReq     : out   std_logic;                       -- FIFO Write Request
      fifoAck     : in    std_logic;                       -- FIFO Write Grant
      fifoSOF     : out   std_logic;                       -- FIFO Word SOF
      fifoData    : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Parity error output
      parError    : out   std_logic;                       -- Parity error detected

      -- KPIX Address and enable
      kpixAddr    : in    std_logic_vector(1  downto 0);   -- Kpix address
      kpixEnable  : in    std_logic;                       -- Kpix Enable

      -- Incoming serial data
      rspData     : in    std_logic;                       -- Incoming serial data

      -- Status Data
      statusValue : out   std_logic_vector(31 downto 0);   -- KPIX status register
      statusRx    : out   std_logic;                       -- KPIX status received

      -- Kpix version
      kpixVer     : in    std_logic                        -- Kpix Version

   );
end KpixRspRx;


-- Define architecture
architecture KpixRspRx of KpixRspRx is

   -- Local signals
   signal shiftData   : std_logic_vector(54 downto 0);
   signal shiftCount  : std_logic_vector(8  downto 0);
   signal headParErr  : std_logic;
   signal dataParErr  : std_logic;
   signal checkSum    : std_logic_vector(15 downto 0);
   signal intData     : std_logic;

   -- State machine
   constant ST_IDLE  : std_logic_vector(3 downto 0) := "0000";
   constant ST_MARK  : std_logic_vector(3 downto 0) := "0001";
   constant ST_SHIFT : std_logic_vector(3 downto 0) := "0010";
   constant ST_CHECK : std_logic_vector(3 downto 0) := "0011";
   constant ST_REQ0  : std_logic_vector(3 downto 0) := "0100";
   constant ST_REQ1  : std_logic_vector(3 downto 0) := "0101";
   constant ST_REQ2  : std_logic_vector(3 downto 0) := "0110";
   constant ST_REQ3  : std_logic_vector(3 downto 0) := "0111";
   constant ST_SKIP  : std_logic_vector(3 downto 0) := "1000";
   signal   curState : std_logic_vector(3 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Receive data input
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intData <= '0' after tpd;
      elsif rising_edge(kpixClk) then
         intData <= rspData after tpd;
      end if;
   end process;

   -- Temperature Value
   statusValue <= shiftData(46 downto 15);

   -- Receive data shift
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         fifoReq    <= '0'           after tpd;
         fifoSOF    <= '0'           after tpd;
         fifoData   <= (others=>'0') after tpd;
         shiftData  <= (others=>'0') after tpd;
         shiftCount <= (others=>'0') after tpd;
         parError   <= '0'           after tpd;
         checkSum   <= (others=>'0') after tpd;
         statusRx   <= '0'           after tpd;
         curState   <= ST_IDLE       after tpd;
      elsif rising_edge(kpixClk) then

         -- State machine
         case curState is

            -- Idle, wait for start bit
            when ST_IDLE =>

               -- Start bit
               if intData = '1' and kpixEnable = '1' then
                  curState   <= ST_MARK       after tpd;
                  shiftData  <= (others=>'0') after tpd;
                  shiftCount <= (others=>'0') after tpd;
               end if;
          
               -- Clear request flag and parity error
               checkSum <= (others=>'0') after tpd;
               fifoReq  <= '0'           after tpd;
               parError <= '0'           after tpd;
               statusRx <= '0'           after tpd;

            -- Shift in marker
            when ST_MARK =>
            
               -- Shift counter
               shiftCount <= shiftCount + 1 after tpd;

               -- Shift in data
               if kpixVer = '0' then
                  shiftData(54 downto 0) <= intData & shiftData(54 downto 1) after tpd;
               else
                  shiftData(47 downto 0) <= intData & shiftData(47 downto 1) after tpd;
               end if;

               -- Bit 4 is the frame type bit
               if shiftCount = 4 then

                  -- If frame type is 0 keep shifting
                  if intData = '0' then
                     curState <= ST_SHIFT after tpd;
                  else
                     curState <= ST_SKIP after tpd;
                  end if;
               end if;

            -- Shift in the rest of the frame
            when ST_SHIFT =>
            
               -- Shift counter
               shiftCount <= shiftCount + 1 after tpd;

               -- Shift in data
               if kpixVer = '0' then
                  shiftData(54 downto 0) <= intData & shiftData(54 downto 1) after tpd;
               else
                  shiftData(47 downto 0) <= intData & shiftData(47 downto 1) after tpd;
               end if;

               -- Bit 54 is the last bit
               if (kpixVer = '0' and shiftCount = 54) or (kpixVer = '1' and shiftCount = 47) then
                  curState <= ST_CHECK after tpd;
               end if;

            -- Check parity of received data
            when ST_CHECK =>

               -- An error existted
               if headParErr = '1' or dataParErr = '1' or shiftData(3 downto 0) /= "1010" then
                  curState <= ST_IDLE after tpd;
                  parError <= '1'     after tpd;

               -- Async frame
               elsif shiftData(13 downto 5) = "000011101" then -- Addr=7,W=0,C=1
                  curState <= ST_IDLE after tpd;
                  statusRx <= '1'     after tpd;

               -- Standard frame
               else
                  curState <= ST_REQ0 after tpd;
                  fifoReq  <= '1'     after tpd;
               end if;

               fifoSOF <= '1' after tpd;

               -- Output first word of data
               if kpixVer = '0' then
                  fifoData(15 downto 11) <= (others=>'0')           after tpd;
                  fifoData(10 downto  9) <= kpixAddr                after tpd;
                  fifoData(8)            <= shiftData(12)           after tpd;
                  fifoData(7)            <= shiftData(13)           after tpd;
                  fifoData(6  downto  0) <= shiftData(20 downto 14) after tpd;
                  checkSum(15 downto 11) <= (others=>'0')           after tpd;
                  checkSum(10 downto  9) <= kpixAddr                after tpd;
                  checkSum(8)            <= shiftData(12)           after tpd;
                  checkSum(7)            <= shiftData(13)           after tpd;
                  checkSum(6  downto  0) <= shiftData(20 downto 14) after tpd;
               else
                  fifoData(15 downto 11) <= (others=>'0')           after tpd;
                  fifoData(10 downto  9) <= kpixAddr                after tpd;
                  fifoData(8)            <= shiftData(5)            after tpd;
                  fifoData(7)            <= shiftData(6)            after tpd;
                  fifoData(6  downto  0) <= shiftData(13 downto 7)  after tpd;
                  checkSum(15 downto 11) <= (others=>'0')           after tpd;
                  checkSum(10 downto  9) <= kpixAddr                after tpd;
                  checkSum(8)            <= shiftData(5)            after tpd;
                  checkSum(7)            <= shiftData(6)            after tpd;
                  checkSum(6  downto  0) <= shiftData(13 downto 7)  after tpd;
               end if;

            -- Write data 0
            when ST_REQ0 =>

               -- Shift new data on grant
               if fifoAck = '1' then
                  fifoSOF  <= '0' after tpd;

                  -- Output second word of data
                  if kpixVer = '0' then
                     fifoData <= shiftData(37 downto 22) after tpd;
                     checkSum <= checkSum + shiftData(37 downto 22) after tpd;
                  else
                     fifoData <= shiftData(30 downto 15) after tpd;
                     checkSum <= checkSum + shiftData(30 downto 15) after tpd;
                  end if;
              
                  -- Next state
                  curState <= ST_REQ1 after tpd;
               end if;

            -- Write data 1
            when ST_REQ1 =>

               -- Output third word of data
               fifoSOF  <= '0'                     after tpd;

               if kpixVer = '0' then
                  fifoData <= shiftData(53 downto 38) after tpd;
                  checkSum <= checkSum + shiftData(53 downto 38) after tpd;
               else
                  fifoData <= shiftData(46 downto 31) after tpd;
                  checkSum <= checkSum + shiftData(46 downto 31) after tpd;
               end if;
           
               -- Next state
               curState <= ST_REQ2 after tpd;

            -- Write data 2
            when ST_REQ2 =>

               -- Output last word of data
               fifoSOF  <= '0'      after tpd;
               fifoData <= checkSum after tpd;

               -- Next state
               curState <= ST_REQ3 after tpd;

            -- Write data 3
            when ST_REQ3 =>

               -- Clear request
               fifoReq  <= '0'     after tpd;
               curState <= ST_IDLE after tpd;

            -- Skip data frame
            when ST_SKIP =>
  
               -- Increment shift counter
               shiftCount <= shiftCount + 1 after tpd;

               -- Bit 459 is the last bit
               if (kpixVer = '0' and shiftCount = 469) or (kpixVer = '1' and shiftCount = 463) then
                  curState <= ST_IDLE after tpd;
               end if;

            -- Just in case
            when others => curState <= ST_IDLE after tpd;
         end case;
      end if;
   end process;


   -- Parity computation
   process ( shiftData, kpixVer ) begin
      if kpixVer = '0' then

         -- Header parity calculation
         headParErr <= shiftData(0)  xor shiftData(1)  xor shiftData(2)  xor shiftData(3)  xor 
                       shiftData(4)  xor shiftData(5)  xor shiftData(6)  xor shiftData(7)  xor 
                       shiftData(8)  xor shiftData(9)  xor shiftData(10) xor shiftData(11) xor 
                       shiftData(12) xor shiftData(13) xor shiftData(14) xor shiftData(15) xor 
                       shiftData(16) xor shiftData(17) xor shiftData(18) xor shiftData(19) xor 
                       shiftData(20) xor shiftData(21);

         -- Data parity calculation
         dataParErr <= shiftData(22) xor shiftData(23) xor shiftData(24) xor shiftData(25) xor 
                       shiftData(26) xor shiftData(27) xor shiftData(28) xor shiftData(29) xor 
                       shiftData(30) xor shiftData(31) xor shiftData(32) xor shiftData(33) xor 
                       shiftData(34) xor shiftData(35) xor shiftData(36) xor shiftData(37) xor 
                       shiftData(38) xor shiftData(39) xor shiftData(40) xor shiftData(41) xor 
                       shiftData(42) xor shiftData(43) xor shiftData(44) xor shiftData(45) xor 
                       shiftData(46) xor shiftData(47) xor shiftData(48) xor shiftData(49) xor 
                       shiftData(50) xor shiftData(51) xor shiftData(52) xor shiftData(53) xor
                       shiftData(54);
      else
         -- Header parity calculation
         headParErr <= shiftData(0)  xor shiftData(1)  xor shiftData(2)  xor shiftData(3)  xor 
                       shiftData(4)  xor shiftData(5)  xor shiftData(6)  xor shiftData(7)  xor 
                       shiftData(8)  xor shiftData(9)  xor shiftData(10) xor shiftData(11) xor 
                       shiftData(12) xor shiftData(13) xor shiftData(14);

         -- Data parity calculation
         dataParErr <= shiftData(15) xor shiftData(16) xor shiftData(17) xor shiftData(18) xor 
                       shiftData(19) xor shiftData(20) xor shiftData(21) xor shiftData(22) xor 
                       shiftData(23) xor shiftData(24) xor shiftData(25) xor shiftData(26) xor 
                       shiftData(27) xor shiftData(28) xor shiftData(29) xor shiftData(30) xor 
                       shiftData(31) xor shiftData(32) xor shiftData(33) xor shiftData(34) xor 
                       shiftData(35) xor shiftData(36) xor shiftData(37) xor shiftData(38) xor 
                       shiftData(39) xor shiftData(40) xor shiftData(41) xor shiftData(42) xor 
                       shiftData(43) xor shiftData(44) xor shiftData(45) xor shiftData(46) xor
                       shiftData(47);
      end if;
   end process;

end KpixRspRx;

