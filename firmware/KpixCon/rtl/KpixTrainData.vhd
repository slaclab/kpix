-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Train Data Receiver
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixTrainData.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the data frame receiver.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 08/12/2007: Added external trigger accept input
-- 08/13/2007: Fixed external trigger accept input
-- 09/19/2007: Added ability to shift up all data in raw data mode.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixTrainData is 
   port ( 
      -- System clock, reset
      sysClk       : in    std_logic;                       -- 125Mhz system clock
      sysRst       : in    std_logic;                       -- System reset

      -- Kpix clock, reset
      kpixClk      : in    std_logic;                       -- 20Mhz kpix clock
      kpixRst      : in    std_logic;                       -- kpix reset

      -- Train Number
      trainNumRst  : in    std_logic;                       -- Train sequence number reset
      trainNum     : out   std_logic_vector(31 downto 0);   -- Train sequence number
      acqDone      : out   std_logic;                       -- Kpix Cycle Complete

      -- Input to train generator
      isRunning    : in    std_logic;                       -- Sequence is running
      deadCount    : in    std_logic_vector(12 downto 0);   -- Inter-train dead count
      extRecord    : in    std_logic;                       -- External trigger accept input, To be implemented
      serialNum    : in    std_logic_vector(3  downto 0);   -- Train Serial Number

      -- FIFO Interface, req/ack type interface
      fifoReq      : out   std_logic;                       -- FIFO Write Request
      fifoAck      : in    std_logic;                       -- FIFO Write Grant
      fifoSOF      : out   std_logic;                       -- FIFO Word SOF
      fifoEOF      : out   std_logic;                       -- FIFO Word EOF
      fifoPad      : out   std_logic;                       -- FIFO Word Padding
      fifoWr       : out   std_logic;                       -- FIFO Write Strobe
      fifoData     : out   std_logic_vector(31 downto 0);   -- FIFO Word

      -- Parity error count
      parErrCount  : out   std_logic_vector(7  downto 0);   -- Parity error count
      parErrRst    : in    std_logic;                       -- Parity error count reset

      -- KPIX Enables
      dropData     : in    std_logic;                       -- Drop data control
      rawData      : in    std_logic;                       -- Raw data enable

      -- Incoming serial data streams
      rspDataA     : in    std_logic;                       -- Incoming serial data A
      rspDataB     : in    std_logic;                       -- Incoming serial data B
      rspDataC     : in    std_logic;                       -- Incoming serial data C
      rspDataD     : in    std_logic;                       -- Incoming serial data D

      -- Kpix Version
      kpixVer      : in    std_logic;                       -- Kpix Version

      -- Kpix bunch crossing
      kpixBunch    : in    std_logic_vector(12 downto 0);   -- Bunch count value

      -- Status receive, to be implemented
      statusValueA : in    std_logic_vector(31 downto 0);
      statusRxA    : in    std_logic;
      statusValueB : in    std_logic_vector(31 downto 0);
      statusRxB    : in    std_logic;
      statusValueC : in    std_logic_vector(31 downto 0);
      statusRxC    : in    std_logic;
      statusValueD : in    std_logic_vector(31 downto 0);
      statusRxD    : in    std_logic;

      -- Debug
      trainDebug   : out   std_logic_vector(63 downto 0);
      kpixDebugA   : out   std_logic_vector(63 downto 0);
      kpixDebugB   : out   std_logic_vector(63 downto 0);
      kpixDebugC   : out   std_logic_vector(63 downto 0);
      kpixDebugD   : out   std_logic_vector(63 downto 0)
      
   );
end KpixTrainData;


-- Define architecture
architecture KpixTrainData of KpixTrainData is

   -- Local signals
   signal intErrCount     : std_logic_vector(7  downto 0);
   signal intErrFlag      : std_logic;
   signal eventCount      : std_logic_vector(14 downto 0);
   signal muxFifoWr       : std_logic;
   signal muxFifoData     : std_logic_vector(15 downto 0);
   signal fifoReqA        : std_logic;
   signal fifoReqB        : std_logic;
   signal fifoReqC        : std_logic;
   signal fifoReqD        : std_logic;
   signal fifoAckA        : std_logic;
   signal fifoAckB        : std_logic;
   signal fifoAckC        : std_logic;
   signal fifoAckD        : std_logic;
   signal fifoWrA         : std_logic;
   signal fifoWrB         : std_logic;
   signal fifoWrC         : std_logic;
   signal fifoWrD         : std_logic;
   signal fifoDataA       : std_logic_vector(15 downto 0);
   signal fifoDataB       : std_logic_vector(15 downto 0);
   signal fifoDataC       : std_logic_vector(15 downto 0);
   signal fifoDataD       : std_logic_vector(15 downto 0);
   signal parErrorA       : std_logic;
   signal parErrorB       : std_logic;
   signal parErrorC       : std_logic;
   signal parErrorD       : std_logic;
   signal inReadoutA      : std_logic;
   signal inReadoutB      : std_logic;
   signal inReadoutC      : std_logic;
   signal inReadoutD      : std_logic;
   signal intEnableA      : std_logic;
   signal intEnableB      : std_logic;
   signal intEnableC      : std_logic;
   signal intEnableD      : std_logic;
   signal intSOF          : std_logic;
   signal intEOF          : std_logic;
   signal intPad          : std_logic;
   signal intFull         : std_logic;
   signal intEmpty        : std_logic;
   signal intWr           : std_logic;
   signal intRd           : std_logic;
   signal intData         : std_logic_vector(31 downto 0);
   signal msbData         : std_logic;
   signal fifoCnt         : std_logic_vector(8 downto 0);
   signal checkSum        : std_logic_vector(15 downto 0);
   signal intSum          : std_logic_vector(15 downto 0);
   signal sumWr           : std_logic;
   signal muxEn           : std_logic;
   signal muxSel          : std_logic_vector(1  downto 0);
   signal intTrainNum     : std_logic_vector(31 downto 0);
   signal trainNumInc     : std_logic;
   signal intStatusValueA : std_logic_vector(31 downto 0);
   signal intStatusRxA    : std_logic;
   signal intStatusValueB : std_logic_vector(31 downto 0);
   signal intStatusRxB    : std_logic;
   signal intStatusValueC : std_logic_vector(31 downto 0);
   signal intStatusRxC    : std_logic;
   signal intStatusValueD : std_logic_vector(31 downto 0);
   signal intStatusRxD    : std_logic;
   signal muxStatSel      : std_logic_vector(1  downto 0);
   signal muxStat         : std_logic_vector(31 downto 0);
   signal muxStatRx       : std_logic;
   signal statusClr       : std_logic;
   signal kpixColCnt      : std_logic_vector(4 downto 0);
   signal intAcqDone      : std_logic;

   -- State machine, reciever
   constant ST_IDLE  : std_logic_vector(3 downto 0) := "0001";
   constant ST_HEAD0 : std_logic_vector(3 downto 0) := "0010";
   constant ST_HEAD1 : std_logic_vector(3 downto 0) := "0011";
   constant ST_KPIX0 : std_logic_vector(3 downto 0) := "0100";
   constant ST_KPIX1 : std_logic_vector(3 downto 0) := "0101";
   constant ST_KPIX2 : std_logic_vector(3 downto 0) := "0110";
   constant ST_KPIX3 : std_logic_vector(3 downto 0) := "0111";
--   constant ST_TRIG  : std_logic_vector(3 downto 0) := "0111";
   constant ST_CHECK : std_logic_vector(3 downto 0) := "1000";
   constant ST_STAT0 : std_logic_vector(3 downto 0) := "1001";
   constant ST_STAT1 : std_logic_vector(3 downto 0) := "1010";
   constant ST_STAT2 : std_logic_vector(3 downto 0) := "1011";
   constant ST_TAIL0 : std_logic_vector(3 downto 0) := "1100";
   constant ST_TAIL1 : std_logic_vector(3 downto 0) := "1101";
   constant ST_TAIL2 : std_logic_vector(3 downto 0) := "1110";
   constant ST_TAIL3 : std_logic_vector(3 downto 0) := "1111";
   signal   curState : std_logic_vector(3 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin
   -- Debug Block
   trainDebug (63)           <= msbData;
   trainDebug (62)           <= intEOF;
   trainDebug (61)           <= sumWr;
   trainDebug (60)           <= intFull;
   trainDebug (59)           <= '0';
   trainDebug (58 downto 57) <= muxSel;
   trainDebug (56 downto 53) <= curState;
   trainDebug (52)           <= muxFifoWr;
   trainDebug (51)           <= fifoAckB;
   trainDebug (50)           <= fifoAckA;
   trainDebug (49)           <= fifoReqB;
   trainDebug (48)           <= fifoReqA;
   trainDebug (47 downto 32) <= muxFifoData;
   trainDebug (31 downto 16) <= checkSum;
   trainDebug (15 downto  0) <= intSum;

   -- Train number
   trainNum  <= intTrainNum;

   -- Acq Done
   acqDone <= intAcqDone;

   -- External FIFO connections
   fifoReq <= not intEmpty;
--   fifoWr  <= fifoAck and (not intEmpty);
   intRd   <= fifoAck and (not intEmpty);

   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         fifoWr <= '0' after tpd;
      elsif rising_edge(sysClk) then
         fifoWr <= intRd after tpd; -- Delay Write signal by one cycle
      end if;
   end process;

   U_TrainFifo: afifo_35x512 port map(
      rd_clk             => sysClk,
      rd_en              => intRd,
      dout(34)           => fifoPad,
      dout(33)           => fifoEOF,
      dout(32)           => fifoSOF,
      dout(31 downto 0)  => fifoData,
      rst                => kpixRst,
      wr_clk             => kpixClk,
      wr_en              => intWr,
      din(34)            => intPad,
      din(33)            => intEOF,
      din(32)            => intSOF,
      din(31 downto 0)   => intData,
      empty              => intEmpty,
      full               => intFull,
      wr_data_count      => fifoCnt);

   -- Error count output
   parErrCount <= intErrCount;
   intErrFlag <= '0' when intErrCount = 0 else '1';

   -- Error Counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intErrCount <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then
         if parErrRst = '1' then
            intErrCount <= (others=>'0') after tpd;
         elsif (intErrCount /= 255 and (parErrorA = '1' or 
            parErrorB = '1' or parErrorC = '1' or parErrorD = '1')) then
               intErrCount <= intErrCount + 1 after tpd;
         end if;
      end if;
   end process;


   -- End of train detector and event counter, checksum
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         eventCount  <= (others=>'0') after tpd;
         checkSum    <= (others=>'0') after tpd;
         intTrainNum <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then

         -- Train number
         if trainNumRst = '1' then
            intTrainNum <= (others=>'0') after tpd;
         elsif trainNumInc = '1' then
            intTrainNum <= intTrainNum + 1 after tpd;
         end if;

         -- New train, reset marker, counter and checksum
         if sumWr = '1' and intSOF = '1' then
            eventCount <= (others=>'0') after tpd;
            checkSum   <= intSum        after tpd;
         else

            -- Event counter
            if muxFifoWr = '1' or (muxStatRx = '1' and (curState = ST_STAT0 or curState = ST_STAT1 or curState = ST_STAT2)) then
               eventCount <= eventCount + 1 after tpd;
            end if;

            -- Checksum
            if sumWr = '1' then
               checkSum <= checkSum + intSum after tpd;
            end if;
         end if;
      end if;
   end process;


   -- Combinitorial source selector
   process ( muxEn, muxSel, fifoWrA, fifoWrB, fifoWrC, fifoWrD,
             fifoDataA, fifoDataB, fifoDataC, fifoDataD, intFull ) begin
      if muxEn = '1' then
         case muxSel is 
            when "00" =>
               muxFifoWr   <= fifoWrA;
               muxFifoData <= fifoDataA;
               fifoAckA    <= not intFull;
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckD    <= '0';
            when "01" =>
               muxFifoWr   <= fifoWrB;
               muxFifoData <= fifoDataB;
               fifoAckA    <= '0';
               fifoAckB    <= not intFull;
               fifoAckC    <= '0';
               fifoAckD    <= '0';
            when "10" =>
               muxFifoWr   <= fifoWrC;
               muxFifoData <= fifoDataC;
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= not intFull;
               fifoAckD    <= '0';
            when "11" =>
               muxFifoWr   <= fifoWrD;
               muxFifoData <= fifoDataD;
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckD    <= not intFull;
            when others =>
               muxFifoWr   <= '0';
               muxFifoData <= (others=>'0');
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckD    <= '0';
         end case;
      else
         muxFifoWr   <= '0';
         muxFifoData <= (others=>'0');
         fifoAckA    <= '0';
         fifoAckB    <= '0';
         fifoAckC    <= '0';
         fifoAckD    <= '0';
      end if;
   end process;


   -- Combinitorial status selector
   process ( muxStatSel, intStatusValueA, intStatusRxA, intStatusValueB, 
             intStatusRxB, intStatusValueC, intStatusRxC, intStatusValueD, intStatusRxD ) begin
      case muxStatSel is 
         when "00"   => 
            muxStat   <= intStatusValueA;
            muxStatRx <= intStatusRxA;
         when "01"   => 
            muxStat   <= intStatusValueB;
            muxStatRx <= intStatusRxB;
         when "10"   => 
            muxStat   <= intStatusValueC;
            muxStatRx <= intStatusRxC;
         when "11"   => 
            muxStat   <= intStatusValueD;
            muxStatRx <= intStatusRxD;
         when others => 
            muxStat   <= (others=>'0');
            muxStatRx <= '0';
      end case;
   end process;


   -- Data move state machine
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         msbData         <= '0'           after tpd;
         intWr           <= '0'           after tpd;
         sumWr           <= '0'           after tpd;
         muxStatSel      <= "00"          after tpd;
         muxSel          <= "00"          after tpd;
         muxEn           <= '0'           after tpd;
         intSum          <= (others=>'0') after tpd;
         intData         <= (others=>'0') after tpd;
         intSOF          <= '0'           after tpd;
         intEOF          <= '0'           after tpd;
         intPad          <= '0'           after tpd;
         trainNumInc     <= '0'           after tpd;
         intStatusValueA <= (others=>'0') after tpd;
         intStatusRxA    <= '0'           after tpd;
         intStatusValueB <= (others=>'0') after tpd;
         intStatusRxB    <= '0'           after tpd;
         intStatusValueC <= (others=>'0') after tpd;
         intStatusRxC    <= '0'           after tpd;
         intStatusValueD <= (others=>'0') after tpd;
         intStatusRxD    <= '0'           after tpd;
         statusClr       <= '0'           after tpd;
         intAcqDone      <= '0'           after tpd;
         curState        <= ST_IDLE       after tpd;
      elsif rising_edge(kpixClk) then

         -- Receive status values
         if statusRxA = '1' then
            intStatusValueA <= statusValueA after tpd;
            intStatusRxA    <= '1'          after tpd;
         elsif statusClr = '1' then 
            intStatusRxA    <= '0'          after tpd;
         end if;
         if statusRxB = '1' then
            intStatusValueB <= statusValueB after tpd;
            intStatusRxB    <= '1'          after tpd;
         elsif statusClr = '1' then 
            intStatusRxB    <= '0'          after tpd;
         end if;
         if statusRxC = '1' then
            intStatusValueC <= statusValueC after tpd;
            intStatusRxC    <= '1'          after tpd;
         elsif statusClr = '1' then 
            intStatusRxC    <= '0'          after tpd;
         end if;
         if statusRxD = '1' then
            intStatusValueD <= statusValueD after tpd;
            intStatusRxD    <= '1'          after tpd;
         elsif statusClr = '1' then 
            intStatusRxD    <= '0'          after tpd;
         end if;


         -- State machine
         case curState is

            -- Idle, wait for data
            when ST_IDLE =>
               intAcqDone <= '0' after tpd;

               -- Train is starting, generate header
               if (inReadoutA = '1' or inReadoutB = '1' or inReadoutC = '1' or inReadoutD = '1') and intFull = '0' then
                  intWr       <= '1'      after tpd;
                  sumWr       <= '1'      after tpd;
                  muxEn       <= '1'      after tpd;
                  muxSel      <= "00"     after tpd;
                  trainNumInc <= '1'      after tpd;
                  curState    <= ST_KPIX0 after tpd;
               else
                  intWr       <= '0'      after tpd;
                  sumWr       <= '0'      after tpd;
                  muxSel      <= "00"     after tpd;
                  muxEn       <= '0'      after tpd;
                  trainNumInc <= '0'      after tpd;
               end if;

               -- Clear mux controls
               muxStatSel  <= "00" after tpd;
               msbData     <= '0'  after tpd;

               -- Setup first word of FIFO data
               intSOF      <= '1'  after tpd;
               intEOF      <= '0'  after tpd;
               intPad      <= '0'  after tpd;
               statusClr   <= '0'  after tpd;
               intData(27 downto  0) <= intTrainNum(27 downto 0) after tpd;
               intData(31 downto 28) <= serialNum                after tpd;
               intSum      <= (serialNum & intTrainNum(27 downto 16)) + intTrainNum(15 downto 0) after tpd;

            -- Write header data 0
            when ST_HEAD0 =>

               if intFull = '0' then

                  -- Setup second word of FIFO data
                  intSOF      <= '0'                                 after tpd;
                  intWr       <= '1'                                 after tpd;
                  intData(11 downto 0 ) <= intTrainNum(27 downto 16) after tpd;
                  intData(15 downto 12) <= serialNum                 after tpd;
                  trainNumInc <= '1'                                 after tpd;

                  -- Select Kpix 0
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "00"     after tpd;
                  curState <= ST_KPIX0 after tpd;
               else
                  intWr    <= '0'      after tpd;
               end if;

            -- Accept data from KPIX 0 if ready
            when ST_KPIX0 =>

               -- Clear train number increment flag
               trainNumInc <= '0' after tpd;
               intSOF      <= '0' after tpd;

               -- Pass data from selected source
               if intFull = '0' then
                  intWr   <= muxFifoWr and msbData after tpd;
                  intSum  <= muxFifoData after tpd;
                  sumWr   <= muxFifoWr   after tpd;
                    
                  if muxFifoWr = '1' and msbData = '0' then
                     intData(15 downto  0) <= muxFifoData after tpd;
                     msbData               <= '1'         after tpd;
                  elsif muxFifoWr = '1' then
                     intData(31 downto 16) <= muxFifoData after tpd;
                     msbData               <= '0'         after tpd;
                  end if;
                  
                  -- Kpix 0 is no longer requesting data
                  if fifoReqA = '0' then
                     muxEn    <= '1'      after tpd;
                     muxSel   <= "01"     after tpd;
                     curState <= ST_KPIX1 after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Accept data from KPIX 1 if ready
            when ST_KPIX1 =>

               -- Pass data from selected source
               if intFull = '0' then
                  intWr   <= muxFifoWr and msbData after tpd;
                  intSum  <= muxFifoData after tpd;
                  sumWr   <= muxFifoWr   after tpd;
                  
                  if muxFifoWr = '1' and msbData = '0' then
                     intData(15 downto  0) <= muxFifoData after tpd;
                     msbData               <= '1'         after tpd;
                  elsif muxFifoWr = '1' then
                     intData(31 downto 16) <= muxFifoData after tpd;
                     msbData               <= '0'         after tpd;
                  end if;

                  -- Kpix 1 is no longer requesting data
                  if fifoReqB = '0' then
                     muxEn    <= '1'      after tpd;
                     muxSel   <= "10"     after tpd;
                     curState <= ST_KPIX2 after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Accept data from KPIX 2 if ready
            when ST_KPIX2 =>

               -- Pass data from selected source
               if intFull = '0' then
                  intWr   <= muxFifoWr and msbData after tpd;
                  intSum  <= muxFifoData after tpd;
                  sumWr   <= muxFifoWr   after tpd;
                  
                  if muxFifoWr = '1' and msbData = '0' then
                     intData(15 downto  0) <= muxFifoData after tpd;
                     msbData               <= '1'         after tpd;
                  elsif muxFifoWr = '1' then
                     intData(31 downto 16) <= muxFifoData after tpd;
                     msbData               <= '0'         after tpd;
                  end if;

                  -- Kpix 2 is no longer requesting data
                  if fifoReqC = '0' then
                     muxEn    <= '1'      after tpd;
                     muxSel   <= "11"     after tpd;
                     curState <= ST_KPIX3 after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Accept data from KPIX 3 if ready
            when ST_KPIX3 =>

               -- Pass data from selected source
               if intFull = '0' then
                  intWr   <= muxFifoWr and msbData after tpd;
                  intSum  <= muxFifoData after tpd;
                  sumWr   <= muxFifoWr   after tpd;
                  
                  if muxFifoWr = '1' and msbData = '0' then
                     intData(15 downto  0) <= muxFifoData after tpd;
                     msbData               <= '1'         after tpd;
                  elsif muxFifoWr = '1' then
                     intData(31 downto 16) <= muxFifoData after tpd;
                     msbData               <= '0'         after tpd;
                  end if;

                  -- Kpix 3 is no longer requesting data
                  if fifoReqD = '0' then
                     muxEn    <= '0'      after tpd;
                     muxSel   <= "00"     after tpd;
                     curState <= ST_CHECK  after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Accept data from TRIG if ready
--             when ST_TRIG =>
-- 
--                -- Pass data from selected source
--                intData <= muxFifoData after tpd;
--                intWr   <= muxFifoWr   after tpd;
-- 
--                -- Trigger is no longer requesting data
--                if fifoReqT = '0' then
--                   muxEn    <= '0'      after tpd;
--                   muxSel   <= "00"     after tpd;
--                   curState <= ST_CHECK after tpd;
--                end if;

            -- Check to see if we are done
            when ST_CHECK =>

               -- Is the frame done?
               if inReadoutA = '0' and inReadoutB = '0' and inReadoutC = '0' and inReadoutD = '0' then
                  curState <= ST_STAT0 after tpd;
               else
                  curState <= ST_KPIX0 after tpd;
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "00"     after tpd;
               end if;
               intWr <= '0' after tpd;
               sumWr <= '0' after tpd;

            -- Append status record, Word 0
            when ST_STAT0 =>
               if intFull = '0' then
                  intWr    <= muxStatRx and msbData after tpd;
                  curState <= ST_STAT1              after tpd;
                  sumWr    <= muxStatRx             after tpd;
                  intSum   <= "0100" & muxStatSel & "0000000000" after tpd;
                  
                  if msbData = '0' then
                     intData(15 downto 14) <= "01"          after tpd; -- Marker
                     intData(13 downto 12) <= "00"          after tpd; -- Bucket = 0
                     intData(11 downto 10) <= muxStatSel    after tpd; -- Kpix address
                     intData(9  downto  0) <= (others=>'0') after tpd; -- Channel = 0
                     msbData               <= '1'           after tpd;
                  else
                     intData(31 downto 30) <= "01"          after tpd; -- Marker
                     intData(29 downto 28) <= "00"          after tpd; -- Bucket = 0
                     intData(27 downto 26) <= muxStatSel    after tpd; -- Kpix address
                     intData(25 downto 16) <= (others=>'0') after tpd; -- Channel = 0
                     msbData               <= '0'           after tpd;
                  end if;
               else
                  intWr                    <= '0'           after tpd;
                  sumWr                    <= '0'           after tpd;
               end if;
               
            -- Append status record, Word 1
            when ST_STAT1 =>
               if intFull = '0' then
                  intWr    <= muxStatRx and msbData after tpd;
                  curState <= ST_STAT2              after tpd;
                  intSum   <= x"8000"               after tpd;
                  sumWr    <= muxStatRx             after tpd;
                  
                  if msbData = '0' then
                     intData(15)           <= '1'           after tpd; -- Special Flag = 1
                     intData(14)           <= '0'           after tpd; -- Time Bit 12
                     intData(13)           <= '0'           after tpd; -- Range Bit = 0
                     intData(12)           <= '0'           after tpd; -- Empty Bit = 0
                     intData(11 downto  0) <= (others=>'0') after tpd; -- Time, lower bits
                     msbData               <= '1'           after tpd;
                  else
                     intData(31)           <= '1'           after tpd; -- Special Flag = 1
                     intData(30)           <= '0'           after tpd; -- Time Bit 12
                     intData(29)           <= '0'           after tpd; -- Range Bit = 0
                     intData(28)           <= '0'           after tpd; -- Empty Bit = 0
                     intData(27 downto 16) <= (others=>'0') after tpd; -- Time, lower bits
                     msbData               <= '0'           after tpd;
                  end if;
               else
                  intWr                    <= '0'           after tpd;
                  sumWr                    <= '0'           after tpd;
               end if;

            -- Append status record, Word 2
            when ST_STAT2 =>
               if intFull = '0' then
                  intWr    <= muxStatRx and msbData after tpd;
                  sumWr    <= muxStatRx             after tpd;
                  intSum   <= x"00" & muxStat(31 downto 24) after tpd;
                  
                  if msbData = '0' then
                     intData(15)           <= '0'                   after tpd; -- Future Bit = 0
                     intData(14)           <= '0'                   after tpd; -- Trig Bit = 0
                     intData(13)           <= '0'                   after tpd; -- Bad Count = 0
                     intData(12 downto  8) <= (others=>'0')         after tpd; -- ADC Value
                     intData(7  downto  0) <= muxStat(31 downto 24) after tpd; -- ADC Value
                     msbData               <= '1'                   after tpd;
                  else
                     intData(31)           <= '0'                   after tpd; -- Future Bit = 0
                     intData(30)           <= '0'                   after tpd; -- Trig Bit = 0
                     intData(29)           <= '0'                   after tpd; -- Bad Count = 0
                     intData(28 downto 24) <= (others=>'0')         after tpd; -- ADC Value
                     intData(23 downto 16) <= muxStat(31 downto 24) after tpd; -- ADC Value
                     msbData               <= '0'                   after tpd;
                  end if;

                  -- Loop through each kpix
                  if muxStatSel = "11" then
                     curState <= ST_TAIL0  after tpd;
                  else
                     muxStatSel <= muxStatSel + 1 after tpd;
                     curState   <= ST_STAT0       after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Write tail data 0
            when ST_TAIL0 =>
            
               if intFull = '0' then
                  curState <= ST_TAIL1 after tpd;
                  intSum   <= '1' & eventCount after tpd;
                  sumWr    <= '1'              after tpd;
                  -- Setup third word of FIFO data
                  if msbData = '0' then
                     intData(15)           <= '1'        after tpd;
                     intData(14 downto 0)  <= eventCount after tpd;
                     intWr                 <= '0'        after tpd;
                     msbData               <= '1'        after tpd;
                  else
                     intData(31)           <= '1'        after tpd;
                     intData(30 downto 16) <= eventCount after tpd;
                     intWr                 <= '1'        after tpd;
                     msbData               <= '0'        after tpd;
                  end if;
               else
                  intWr <= '0' after tpd;
                  sumWr <= '0' after tpd;
               end if;

            -- Write tail data 0
            when ST_TAIL1 =>

               if intFull = '0' then
                  curState <= ST_TAIL2 after tpd;
                  sumWr    <= '1'      after tpd;
                  intSum   <= isRunning & '0' & intErrFlag & deadCount after tpd;
                  -- Setup third word of FIFO data
                  if msbData = '0' then
                     intData(15)           <= isRunning  after tpd;
                     intData(14)           <= '0'        after tpd;
                     intData(13)           <= intErrFlag after tpd;
                     intData(12 downto  0) <= deadCount  after tpd;
                     intWr                 <= '0'        after tpd;
                     msbData               <= '1'        after tpd;
                  else
                     intData(31)           <= isRunning  after tpd;
                     intData(30)           <= '0'        after tpd;
                     intData(29)           <= intErrFlag after tpd;
                     intData(28 downto 16) <= deadCount  after tpd;
                     intWr                 <= '1'        after tpd;
                     msbData               <= '0'        after tpd;
                  end if;
               else
                  intWr                 <= '0'           after tpd;
                  sumWr                 <= '0'           after tpd;
               end if;

            -- Delay one clock for checksum
            when ST_TAIL2 =>

               -- No Write, go to next state
               intWr    <= '0'      after tpd;
               sumWr    <= '0'      after tpd;
               curState <= ST_TAIL3 after tpd;

            -- Check to see if we are done
            when ST_TAIL3 =>

               if intFull = '0' then
                  -- Write checksum
                  if msbData = '0' then
                     intData(15 downto  0) <= checkSum      after tpd;
                     intPad                <= '1'           after tpd;
                     intData(31 downto 16) <= (OTHERS=>'0') after tpd;
                  else
                     intPad                <= '0'           after tpd;
                     intData(31 downto 16) <= checkSum      after tpd;
                  end if;
                  
                  intWr      <= '1'      after tpd;
                  intEOF     <= '1'      after tpd;
                  statusClr  <= '1'      after tpd;
                  intAcqDone <= '1'      after tpd;
                  curState   <= ST_IDLE  after tpd;
               else
                  intWr      <= '0'      after tpd;
               end if;

            -- Just in case
            when others => curState <= ST_IDLE after tpd;
         end case;
      end if;
   end process;


   -- Combine enables with drop data control
   intEnableA <= not dropData;
   intEnableB <= not dropData;
   intEnableC <= not dropData;
   intEnableD <= not dropData;

   -- Generate column count
   kpixColCnt <= "00001" when kpixVer = '0' else "01111";


   -- Kpix 0, serial data reciver
   U_KpixA: KpixDataRx port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqA,    fifoAck      => fifoAckA,
      fifoWr     => fifoWrA,     fifoData     => fifoDataA,
      rawData    => rawData,     dataError    => parErrorA,
      kpixAddr   => "00",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableA,  kpixVer      => kpixVer,
      inReadout  => inReadoutA,  rspData      => rspDataA,
      kpixDebug  => kpixDebugA
   );


   -- Kpix 1, serial data reciver
   U_KpixB: KpixDataRx port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqB,    fifoAck      => fifoAckB,
      fifoWr     => fifoWrB,     fifoData     => fifoDataB,
      rawData    => rawData,     dataError    => parErrorB,
      kpixAddr   => "01",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableB,  kpixVer      => kpixVer,
      inReadout  => inReadoutB,  rspData      => rspDataB,
      kpixDebug  => kpixDebugB
   );


   -- Kpix 2, serial data reciver
   U_KpixC: KpixDataRx port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqC,    fifoAck      => fifoAckC,
      fifoWr     => fifoWrC,     fifoData     => fifoDataC,
      rawData    => rawData,     dataError    => parErrorC,
      kpixAddr   => "10",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableC,  kpixVer      => kpixVer,
      inReadout  => inReadoutC,  rspData      => rspDataC,
      kpixDebug  => kpixDebugC
   );

   -- Kpix 2, serial data reciver
   U_KpixD: KpixDataRx port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqD,    fifoAck      => fifoAckD,
      fifoWr     => fifoWrD,     fifoData     => fifoDataD,
      rawData    => rawData,     dataError    => parErrorD,
      kpixAddr   => "11",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableD,  kpixVer      => kpixVer,
      inReadout  => inReadoutD,  rspData      => rspDataD,
      kpixDebug  => kpixDebugD
   );

   -- Trigger data processor
--    U_Trig: KpixTrigRec port map ( 
--       kpixClk   => kpixClk,
--       kpixRst   => kpixRst,
--       extRecord => extRecord,
--       kpixBunch => kpixBunch,
--       fifoReq   => fifoReqT,    
--       fifoAck   => fifoAckT, 
--       fifoWr    => fifoWrT, 
--       fifoData  => fifoDataT 
--    );

end KpixTrainData;

