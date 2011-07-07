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

entity KpixTrainData is 
   port ( 

      -- System clock, reset
      kpixClk      : in    std_logic;                       -- 20Mhz system clock
      kpixRst      : in    std_logic;                       -- System reset

      -- Train Number
      trainNumRst  : in    std_logic;                       -- Train sequence number reset
      trainNum     : out   std_logic_vector(31 downto 0);   -- Train sequence number
      acqDone      : out   std_logic;                       -- Kpix Cycle Complete

      -- Input to train generator
      isRunning    : in    std_logic;                       -- Sequence is running
      deadCount    : in    std_logic_vector(12 downto 0);   -- Inter-train dead count
      extRecord    : in    std_logic;                       -- External trigger accept input, To be implemented

      -- FIFO Interface, req/ack type interface
      fifoReq      : out   std_logic;                       -- FIFO Write Request
      fifoAck      : in    std_logic;                       -- FIFO Write Grant
      fifoSOF      : out   std_logic;                       -- FIFO Word SOF
      fifoWr       : out   std_logic;                       -- FIFO Write Strobe
      fifoData     : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Parity error count
      parErrCount  : out   std_logic_vector(7  downto 0);   -- Parity error count
      parErrRst    : in    std_logic;                       -- Parity error count reset

      -- KPIX Enables
      dropData     : in    std_logic;                       -- Drop data control
      rawData      : in    std_logic;                       -- Raw data enable
      kpixEnA      : in    std_logic;                       -- KPIX A Enable
      kpixEnB      : in    std_logic;                       -- KPIX B Enable
      kpixEnC      : in    std_logic;                       -- KPIX C Enable

      -- Incoming serial data streams
      rspDataA     : in    std_logic;                       -- Incoming serial data A
      rspDataB     : in    std_logic;                       -- Incoming serial data B
      rspDataC     : in    std_logic;                       -- Incoming serial data C

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
      statusRxC    : in    std_logic

   );
end KpixTrainData;


-- Define architecture
architecture KpixTrainData of KpixTrainData is

   -- Kpix Data Processor
   component KpixDataRx
      generic (
         CsEnable : integer := 0    -- Enable chipscope core
      ); port (
         kpixClk      : in    std_logic;                       -- 20Mhz system clock
         kpixRst      : in    std_logic;                       -- System reset
         fifoReq      : out   std_logic;                       -- FIFO Write Request
         fifoAck      : in    std_logic;                       -- FIFO Write Grant
         fifoWr       : out   std_logic;                       -- FIFO Write Strobe
         fifoData     : out   std_logic_vector(15 downto 0);   -- FIFO Word
         rawData      : in    std_logic;                       -- Raw data enable
         dataError    : out   std_logic;                       -- Parity error detected
         kpixAddr     : in    std_logic_vector(1  downto 0);   -- Kpix address
         kpixColCnt   : in    std_logic_vector(4  downto 0);   -- Column count
         kpixEnable   : in    std_logic;                       -- Kpix Enable
         inReadout    : out   std_logic;                       -- Start of train marker
         rspData      : in    std_logic                        -- Incoming serial data
      );
   end component;

   -- Trigger timestamp process
   component KpixTrigRec port ( 
         kpixClk       : in    std_logic;                       -- 20Mhz system clock
         kpixRst       : in    std_logic;                       -- System reset
         extRecord     : in    std_logic;                       -- External trigger accept input, To be implemented
         kpixBunch     : in    std_logic_vector(12 downto 0);   -- Bunch count value
         fifoReq       : out   std_logic;                       -- FIFO Write Request
         fifoAck       : in    std_logic;                       -- FIFO Write Grant
         fifoWr        : out   std_logic;                       -- FIFO Write Strobe
         fifoData      : out   std_logic_vector(15 downto 0)    -- FIFO Word
      );
   end component;

   -- Local signals
   signal intErrCount     : std_logic_vector(7  downto 0);
   signal intErrFlag      : std_logic;
   signal eventCount      : std_logic_vector(14 downto 0);
   signal muxFifoWr       : std_logic;
   signal muxFifoData     : std_logic_vector(15 downto 0);
   signal fifoReqA        : std_logic;
   signal fifoReqB        : std_logic;
   signal fifoReqC        : std_logic;
   signal fifoReqT        : std_logic;
   signal fifoAckA        : std_logic;
   signal fifoAckB        : std_logic;
   signal fifoAckC        : std_logic;
   signal fifoAckT        : std_logic;
   signal fifoWrA         : std_logic;
   signal fifoWrB         : std_logic;
   signal fifoWrC         : std_logic;
   signal fifoWrT         : std_logic;
   signal fifoDataA       : std_logic_vector(15 downto 0);
   signal fifoDataB       : std_logic_vector(15 downto 0);
   signal fifoDataC       : std_logic_vector(15 downto 0);
   signal fifoDataT       : std_logic_vector(15 downto 0);
   signal parErrorA       : std_logic;
   signal parErrorB       : std_logic;
   signal parErrorC       : std_logic;
   signal inReadoutA      : std_logic;
   signal inReadoutB      : std_logic;
   signal inReadoutC      : std_logic;
   signal intEnableA      : std_logic;
   signal intEnableB      : std_logic;
   signal intEnableC      : std_logic;
   signal intSOF          : std_logic;
   signal intWr           : std_logic;
   signal intData         : std_logic_vector(15 downto 0);
   signal checkSum        : std_logic_vector(15 downto 0);
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
   constant ST_TRIG  : std_logic_vector(3 downto 0) := "0111";
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

   -- Train number
   trainNum  <= intTrainNum;

   -- Acq Done
   acqDone <= intAcqDone;

   -- External FIFO connections
   fifoSOF  <= intSOF;
   fifoWr   <= intWr;
   fifoData <= intData;

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
            parErrorB = '1' or parErrorC = '1')) then
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
         if intWr = '1' and intSOF = '1' then
            eventCount <= (others=>'0') after tpd;
            checkSum   <= intData       after tpd;
         else

            -- Event counter
            if muxFifoWr = '1' or (muxStatRx = '1' and (curState = ST_STAT0 or curState = ST_STAT1 or curState = ST_STAT2)) then
               eventCount <= eventCount + 1 after tpd;
            end if;

            -- Checksum
            if intWr = '1' then
               checkSum <= checkSum + intData after tpd;
            end if;
         end if;
      end if;
   end process;


   -- Combinitorial source selector
   process ( muxEn, muxSel, fifoWrA, fifoWrB, fifoWrC, fifoWrT,
             fifoDataA, fifoDataB, fifoDataC, fifoDataT ) begin
      if muxEn = '1' then
         case muxSel is 
            when "00" =>
               muxFifoWr   <= fifoWrA;
               muxFifoData <= fifoDataA;
               fifoAckA    <= '1';
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckT    <= '0';
            when "01" =>
               muxFifoWr   <= fifoWrB;
               muxFifoData <= fifoDataB;
               fifoAckA    <= '0';
               fifoAckB    <= '1';
               fifoAckC    <= '0';
               fifoAckT    <= '0';
            when "10" =>
               muxFifoWr   <= fifoWrC;
               muxFifoData <= fifoDataC;
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= '1';
               fifoAckT    <= '0';
            when "11" =>
               muxFifoWr   <= fifoWrT;
               muxFifoData <= fifoDataT;
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckT    <= '1';
            when others =>
               muxFifoWr   <= '0';
               muxFifoData <= (others=>'0');
               fifoAckA    <= '0';
               fifoAckB    <= '0';
               fifoAckC    <= '0';
               fifoAckT    <= '0';
         end case;
      else
         muxFifoWr   <= '0';
         muxFifoData <= (others=>'0');
         fifoAckA    <= '0';
         fifoAckB    <= '0';
         fifoAckC    <= '0';
         fifoAckT    <= '0';
      end if;
   end process;


   -- Combinitorial status selector
   process ( muxStatSel, intStatusValueA, intStatusRxA, intStatusValueB, 
             intStatusRxB, intStatusValueC, intStatusRxC ) begin
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
         when others => 
            muxStat   <= (others=>'0');
            muxStatRx <= '0';
      end case;
   end process;


   -- Data move state machine
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         fifoReq         <= '0'           after tpd;
         intWr           <= '0'           after tpd;
         muxStatSel      <= "00"          after tpd;
         muxSel          <= "00"          after tpd;
         muxEn           <= '0'           after tpd;
         intData         <= (others=>'0') after tpd;
         intSOF          <= '0'           after tpd;
         trainNumInc     <= '0'           after tpd;
         intStatusValueA <= (others=>'0') after tpd;
         intStatusRxA    <= '0'           after tpd;
         intStatusValueB <= (others=>'0') after tpd;
         intStatusRxB    <= '0'           after tpd;
         intStatusValueC <= (others=>'0') after tpd;
         intStatusRxC    <= '0'           after tpd;
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


         -- State machine
         case curState is

            -- Idle, wait for fifo request
            when ST_IDLE =>
               intAcqDone <= '0' after tpd;

               -- Train is starting, generate header
               if inReadoutA = '1' or inReadoutB = '1' or inReadoutC = '1' then
                  fifoReq  <= '1'      after tpd;
                  intWr    <= '1'      after tpd;
                  curState <= ST_HEAD0 after tpd;
               else
                  fifoReq  <= '0'      after tpd;
                  intWr    <= '0'      after tpd;
               end if;

               -- Clear mux controls
               muxSel     <= "00" after tpd;
               muxEn      <= '0'  after tpd;
               muxStatSel <= "00" after tpd;

               -- Setup first word of FIFO data
               intSOF    <= '1'                      after tpd;
               intData   <= intTrainNum(15 downto 0) after tpd;
               statusClr <= '0'                      after tpd;

            -- Write header data 0
            when ST_HEAD0 =>

               -- Wait for ACK
               if fifoAck = '1' then

                  -- Setup second word of FIFO data
                  intSOF      <= '0'                        after tpd;
                  intData     <= intTrainNum(31 downto 16)  after tpd;
                  trainNumInc <= '1'                        after tpd;

                  -- Select Kpix 0
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "00"     after tpd;
                  curState <= ST_KPIX0 after tpd;
               end if;

            -- Accept data from KPIX 0 if ready
            when ST_KPIX0 =>

               -- Clear train number increment flag
               trainNumInc <= '0' after tpd;

               -- Pass data from selected source
               intData <= muxFifoData after tpd;
               intWr   <= muxFifoWr   after tpd;

               -- Kpix 0 is no longer requesting data
               if fifoReqA = '0' then
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "01"     after tpd;
                  curState <= ST_KPIX1 after tpd;
               end if;

            -- Accept data from KPIX 1 if ready
            when ST_KPIX1 =>

               -- Pass data from selected source
               intData <= muxFifoData after tpd;
               intWr   <= muxFifoWr   after tpd;

               -- Kpix 0 is no longer requesting data
               if fifoReqB = '0' then
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "10"     after tpd;
                  curState <= ST_KPIX2 after tpd;
               end if;

            -- Accept data from KPIX 2 if ready
            when ST_KPIX2 =>

               -- Pass data from selected source
               intData <= muxFifoData after tpd;
               intWr   <= muxFifoWr   after tpd;

               -- Kpix 0 is no longer requesting data
               if fifoReqC = '0' then
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "11"     after tpd;
                  curState <= ST_TRIG  after tpd;
               end if;

            -- Accept data from TRIG if ready
            when ST_TRIG =>

               -- Pass data from selected source
               intData <= muxFifoData after tpd;
               intWr   <= muxFifoWr   after tpd;

               -- Trigger is no longer requesting data
               if fifoReqT = '0' then
                  muxEn    <= '0'      after tpd;
                  muxSel   <= "00"     after tpd;
                  curState <= ST_CHECK after tpd;
               end if;

            -- Check to see if we are done
            when ST_CHECK =>

               -- Is the frame done?
               if inReadoutA = '0' and inReadoutB = '0' and inReadoutC = '0' then
                  curState <= ST_STAT0 after tpd;
               else
                  curState <= ST_KPIX0 after tpd;
                  muxEn    <= '1'      after tpd;
                  muxSel   <= "00"     after tpd;
               end if;
               intWr <= '0' after tpd;

            -- Append status record, Word 0
            when ST_STAT0 =>
               intData(15 downto 14) <= "01"          after tpd; -- Marker
               intData(13 downto 12) <= "00"          after tpd; -- Bucket = 0
               intData(11 downto 10) <= muxStatSel    after tpd; -- Kpix address
               intData(9  downto  0) <= (others=>'0') after tpd; -- Channel = 0
               intWr                 <= muxStatRx     after tpd;
               curState              <= ST_STAT1      after tpd;

            -- Append status record, Word 1
            when ST_STAT1 =>
               intData(15)           <= '1'           after tpd; -- Special Flag = 1
               intData(14)           <= '0'           after tpd; -- Time Bit 12
               intData(13)           <= '0'           after tpd; -- Range Bit = 0
               intData(12)           <= '0'           after tpd; -- Empty Bit = 0
               intData(11 downto  0) <= (others=>'0') after tpd; -- Time, lower bits
               intWr                 <= muxStatRx     after tpd;
               curState              <= ST_STAT2      after tpd;

            -- Append status record, Word 2
            when ST_STAT2 =>
               intData(15)           <= '0'                   after tpd; -- Future Bit = 0
               intData(14)           <= '0'                   after tpd; -- Trig Bit = 0
               intData(13)           <= '0'                   after tpd; -- Bad Count = 0
               intData(12 downto  8) <= (others=>'0')         after tpd; -- ADC Value
               intData(7  downto  0) <= muxStat(31 downto 24) after tpd; -- ADC Value
               intWr                 <= muxStatRx             after tpd;

               -- Loop through each kpix
               if muxStatSel = "10" then
                  curState <= ST_TAIL0  after tpd;
               else
                  muxStatSel <= muxStatSel + 1 after tpd;
                  curState   <= ST_STAT0       after tpd;
               end if;

            -- Write tail data 0
            when ST_TAIL0 =>

               -- Setup third word of FIFO data
               intData(15)          <= '1'        after tpd;
               intData(14 downto 0) <= eventCount after tpd;
               intWr                <= '1'        after tpd;
               curState             <= ST_TAIL1   after tpd;

            -- Write tail data 0
            when ST_TAIL1 =>

               -- Setup third word of FIFO data
               intData(15)           <= isRunning  after tpd;
               intData(14)           <= '0'        after tpd;
               intData(13)           <= intErrFlag after tpd;
               intData(12 downto  0) <= deadCount  after tpd;
               intWr                 <= '1'        after tpd;
               curState              <= ST_TAIL2   after tpd;

            -- Delay one clock for checksum
            when ST_TAIL2 =>

               -- No Write, go to next state
               intWr    <= '0'      after tpd;
               curState <= ST_TAIL3 after tpd;

            -- Check to see if we are done
            when ST_TAIL3 =>

               -- Write checksum
               intData    <= checkSum after tpd;
               intWr      <= '1'      after tpd;
               statusClr  <= '1'      after tpd;
               intAcqDone <= '1'      after tpd;
               curState   <= ST_IDLE  after tpd;

            -- Just in case
            when others => curState <= ST_IDLE after tpd;
         end case;
      end if;
   end process;


   -- Combine enables with drop data control
   intEnableA <= kpixEnA and not dropData;
   intEnableB <= kpixEnB and not dropData;
   intEnableC <= kpixEnC and not dropData;

   -- Generate column count
   kpixColCnt <= "11111" when kpixVer = '0' else "01111";


   -- Kpix 0, serial data reciver
   U_KpixA: KpixDataRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqA,    fifoAck      => fifoAckA,
      fifoWr     => fifoWrA,     fifoData     => fifoDataA,
      rawData    => rawData,     dataError    => parErrorA,
      kpixAddr   => "00",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableA,  
      inReadout  => inReadoutA,  rspData      => rspDataA
   );

   --fifoReqA <= '0';
   --fifoWrA <= '0';
   --fifoDataA <= (others=>'0');
   --parErrorA <= '0';
   --inReadoutA <= '0';


   -- Kpix 1, serial data reciver
   U_KpixB: KpixDataRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqB,    fifoAck      => fifoAckB,
      fifoWr     => fifoWrB,     fifoData     => fifoDataB,
      rawData    => rawData,     dataError    => parErrorB,
      kpixAddr   => "01",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableB,  
      inReadout  => inReadoutB,  rspData      => rspDataB
   );


   --fifoReqB <= '0';
   --fifoWrB <= '0';
   --fifoDataB <= (others=>'0');
   --parErrorB <= '0';
   --inReadoutB <= '0';


   -- Kpix 2, serial data reciver
   U_KpixC: KpixDataRx generic map ( CsEnable => 0 ) port map (
      kpixClk    => kpixClk,     kpixRst      => kpixRst,
      fifoReq    => fifoReqC,    fifoAck      => fifoAckC,
      fifoWr     => fifoWrC,     fifoData     => fifoDataC,
      rawData    => rawData,     dataError    => parErrorC,
      kpixAddr   => "10",        kpixColCnt   => kpixColCnt,
      kpixEnable => intEnableC,  
      inReadout  => inReadoutC,  rspData      => rspDataC
   );

   -- Trigger data processor
   U_Trig: KpixTrigRec port map ( 
      kpixClk   => kpixClk,
      kpixRst   => kpixRst,
      extRecord => extRecord,
      kpixBunch => kpixBunch,
      fifoReq   => fifoReqT,    
      fifoAck   => fifoAckT, 
      fifoWr    => fifoWrT, 
      fifoData  => fifoDataT 
   );

end KpixTrainData;

