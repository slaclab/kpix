-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Frame Transmitter
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixCmdTx.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the frame transmitter. This module sends out
-- command frames stored in an asynchronous FIFO. 
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 08/07/2007: Added gen calibrate input.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixCmdTx is 
   port ( 

      -- System clock, reset
      sysClk20      : in    std_logic;                     -- 20Mhz system clock
      syncRst       : in    std_logic;                     -- System reset
      kpixClk       : in    std_logic;                     -- Kpix Clock
      kpixRst       : in    std_logic;                     -- Kpix Reset

      -- Checksum error
      checkSumErr   : out   std_logic;                     -- Checksum error flag

      -- Kpix version
      kpixVer       : in    std_logic;                     -- Kpix Version

      -- FIFO Interface
      fifoData      : in    std_logic_vector(15 downto 0); -- RX FIFO Data
      fifoSOF       : in    std_logic;                     -- RX FIFO Start of Frame
      fifoWr        : in    std_logic;                     -- RX FIFO Write
      fifoFull      : out   std_logic;                     -- RX FIFO Full
      
      -- Hardware driven acquisition command generation, broadcast
      genAcquire    : in    std_logic;                     -- Force command acquire
      genCalibrate  : in    std_logic;                     -- Force command calibrate

      -- Outgoing serial data lins
      serData       : out   std_logic_vector(31 downto 0); -- Serial data out
      serDataL      : out   std_logic;                     -- Serial data out from local kPIX

      -- Chipscope control
      csControl     : inout std_logic_vector(35 downto 0)  -- Chip Scope Control
   );

end KpixCmdTx;


-- Define architecture
architecture KpixCmdTx of KpixCmdTx is 

   -- Local signals
   signal locDout       : std_logic_vector(16 downto 0);
   signal locDin        : std_logic_vector(16 downto 0);
   signal locRd         : std_logic;
   signal locEmpty      : std_logic;
   signal locData       : std_logic_vector(15 downto 0);
   signal locSOF        : std_logic;
   signal txSerData     : std_logic_vector(54 downto 0);
   signal txDataBit     : std_logic;
   signal kpixSelL      : std_logic;
   signal kpixSel       : std_logic_vector(31 downto 0);
   signal fifoRdEn      : std_logic;
   signal fifoRdDly     : std_logic;
   signal txCount       : std_logic_vector(5  downto 0);
   signal checkSum      : std_logic_vector(15 downto 0);
   signal headParCalc   : std_logic;
   signal dataParCalc   : std_logic;

   -- State machine
   constant TX_IDLE  : std_logic_vector(2 downto 0) := "001";
   constant TX_READ0 : std_logic_vector(2 downto 0) := "010";
   constant TX_READ1 : std_logic_vector(2 downto 0) := "011";
   constant TX_READ2 : std_logic_vector(2 downto 0) := "100";
   constant TX_READ3 : std_logic_vector(2 downto 0) := "101";
   constant TX_DATA  : std_logic_vector(2 downto 0) := "110";
   constant TX_DONE  : std_logic_vector(2 downto 0) := "111";
   signal   curState : std_logic_vector(2 downto 0);

   -- Chip Scope signals
   constant enableChipScope : integer := 0;
   signal sysDebug          : std_logic_vector(63 downto 0);
   
begin

   -- Debug Block
   sysDebug (63 downto 53) <= (OTHERS => '0');
   sysDebug (52 downto 21) <= kpixSel;
   sysDebug (20 downto 5)  <= locData;
   sysDebug (4 downto 2)   <= curState;
   sysDebug (1)            <= kpixSelL;
   sysDebug (0)            <= txDataBit;
   
   chipscope : if (enableChipScope = 1) generate   
      U_DataRx_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => kpixClk,
         TRIG0   => sysDebug
      );
   end generate chipscope;  

   -- Data going into FIFO
   locDin(15 downto  0) <= fifoData;
   locDin(16)           <= fifoSOF;

   -- Transmit fIFO
   U_TX_FIFO: afifo_17x32 port map (
      wr_clk   => sysClk20,  rd_clk => kpixClk,
      din      => locDin,    wr_en  => fifoWr,
      rd_en    => locRd,     dout   => locDout, 
      full     => fifoFull,  empty  => locEmpty,
      rst      => syncRst
   );

   -- FIFO Output
   locData <= locDout(15 downto  0);
   locSOF  <= locDout(16);


   -- Control FIFO reads
   locRd <= fifoRdEn and not locEmpty;

   -- State machine to read from FIFO and generate 
   -- command structure
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         txSerData   <= (others=>'0') after tpd;
         txDataBit   <= '0'           after tpd;
         kpixSel     <= (others=>'0') after tpd;
         kpixSelL    <= '0'           after tpd;
         fifoRdEn    <= '0'           after tpd;
         fifoRdDly   <= '0'           after tpd;
         txCount     <= (others=>'0') after tpd;
         curState    <= TX_IDLE       after tpd;
         checkSum    <= (others=>'0') after tpd;
         checkSumErr <= '0'           after tpd; 
      elsif rising_edge(kpixClk) then

         -- Delayed copy of read
         fifoRdDly <= locRd after tpd;

         -- Current state
         case curState is 

            -- IDLE, Wait for data in FIFO or force command
            when TX_IDLE =>

               -- Clear counter
               txCount     <= (others=>'0') after tpd;
               checkSumErr <= '0'           after tpd; 

               -- Force command, setup acquire command
               if genAcquire = '1' then

                  fifoRdEn  <= '0' after tpd;   

                  -- Setup command
                  if kpixVer = '0' then
                     txSerData(3  downto 0)  <= "1010"        after tpd; -- Marker
                     txSerData(4)            <= '0'           after tpd; -- Frame Type
                     txSerData(11 downto 5)  <= "0000000"     after tpd; -- Address = 0
                     txSerData(12)           <= '0'           after tpd; -- C/R Bit
                     txSerData(13)           <= '1'           after tpd; -- Write bit
                     txSerData(54 downto 21) <= (others=>'0') after tpd; -- Unused write data

                     -- Calibrate ?
                     if genCalibrate = '1' then
                        txSerData(20 downto 14) <= "0000011"     after tpd; -- CMD ID
                     else
                        txSerData(20 downto 14) <= "0000010"     after tpd; -- CMD ID
                     end if;
                  else
                     txSerData(3  downto 0)  <= "1010"        after tpd; -- Marker
                     txSerData(4)            <= '0'           after tpd; -- Frame Type
                     txSerData(11 downto 5)  <= "0000000"     after tpd; -- Address = 0
                     txSerData(5)            <= '0'           after tpd; -- C/R Bit
                     txSerData(6)            <= '1'           after tpd; -- Write bit
                     txSerData(47 downto 14) <= (others=>'0') after tpd; -- Unused write data

                     -- Calibrate ?
                     if genCalibrate = '1' then
                        txSerData(13 downto 7) <= "0000011"     after tpd; -- CMD ID
                     else
                        txSerData(13 downto 7) <= "0000010"     after tpd; -- CMD ID
                     end if;
                  end if;

                  -- Broadcast
                  kpixSel  <= (OTHERS=>'1') after tpd;
                  kpixSelL <= '1'           after tpd;

                  -- Go to tx state, set start bit
                  curState  <= TX_DATA after tpd;
                  txDataBit <= '1'     after tpd;

               -- FIFO is ready, read data from FIFO
               elsif locEmpty = '0' then
                  txDataBit <= '0'      after tpd;
                  fifoRdEn  <= '1'      after tpd;   
                  curState  <= TX_READ0 after tpd;
               end if;

            -- Read data from FIFO, data 0
            when TX_READ0 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Go back to IDLE if value is not SOF
                  if locSOF = '0' then
                     fifoRdEn <= '0'     after tpd;
                     curState <= TX_IDLE after tpd;
                  
                  -- Otherwise store data, increment counter, read again
                  else

                     -- Get command frame data
                     if kpixVer = '0' then
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(11 downto 5)  <= "0000000"           after tpd; -- Address = 0
                        txSerData(12)           <= locData(8)          after tpd; -- C/R Bit
                        txSerData(13)           <= locData(7)          after tpd; -- Write bit
                        txSerData(20 downto 14) <= locData(6 downto 0) after tpd; -- CMD ID
                     else
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                        txSerData(6)            <= locData(7)          after tpd; -- Write bit
                        txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID
                     end if;

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '0' and locData(7) = '1' then
                        kpixSel  <= (OTHERS=>'1') after tpd;
                        kpixSelL <= '1'           after tpd;
                     else
                        if(locData(15) = '1') then
                           kpixSelL <= '1'           after tpd;
                           kpixSel  <= (OTHERS=>'0') after tpd;
                        else
                           kpixSelL <= '0'           after tpd;
                           kpixSel  <= conv_5to32(locData(14 downto 12)&locData(10 downto 9)) after tpd;
                        end if;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;
                  end if;
               end if;

            -- Read data from FIFO, data 1
            when TX_READ1 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- SOF is detected
                  if locSOF = '1' then

                     -- Get command frame data
                     if kpixVer = '0' then
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(11 downto 5)  <= "0000000"           after tpd; -- Address = 0
                        txSerData(12)           <= locData(8)          after tpd; -- C/R Bit
                        txSerData(13)           <= locData(7)          after tpd; -- Write bit
                        txSerData(20 downto 14) <= locData(6 downto 0) after tpd; -- CMD ID
                     else
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                        txSerData(6)            <= locData(7)          after tpd; -- Write bit
                        txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID
                     end if;

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel  <= (OTHERS=>'1') after tpd;
                        kpixSelL <= '1'           after tpd;
                     else
                        if(locData(15) = '1') then
                           kpixSelL <= '1'           after tpd;
                           kpixSel  <= (OTHERS=>'0') after tpd;
                        else
                           kpixSelL <= '0'           after tpd;
                           kpixSel  <= conv_5to32(locData(14 downto 12)&locData(10 downto 9)) after tpd;
                        end if;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;

                  else

                     -- Get lower bits of data
                     if kpixVer = '0' then
                        txSerData(37 downto 22) <= locData after tpd;
                     else
                        txSerData(30 downto 15) <= locData after tpd;
                     end if;

                     -- Checksum
                     checkSum <= checkSum + locData after tpd;

                     -- Next Data
                     curState <= TX_READ2 after tpd;
                  end if;
               end if;

            -- Read data from FIFO, data 2
            when TX_READ2 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- SOF is detected
                  if locSOF = '1' then

                     -- Get command frame data
                     if kpixVer = '0' then
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(11 downto 5)  <= "0000000"           after tpd; -- Address = 0
                        txSerData(12)           <= locData(8)          after tpd; -- C/R Bit
                        txSerData(13)           <= locData(7)          after tpd; -- Write bit
                        txSerData(20 downto 14) <= locData(6 downto 0) after tpd; -- CMD ID
                     else
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                        txSerData(6)            <= locData(7)          after tpd; -- Write bit
                        txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID
                     end if;

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel  <= (OTHERS=>'1') after tpd;
                        kpixSelL <= '1'           after tpd;
                     else
                        if(locData(15) = '1') then
                           kpixSelL <= '1'           after tpd;
                           kpixSel  <= (OTHERS=>'0') after tpd;
                        else
                           kpixSelL <= '0'           after tpd;
                           kpixSel  <= conv_5to32(locData(14 downto 12)&locData(10 downto 9)) after tpd;
                        end if;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;

                  else

                     -- Get upper bits of data
                     if kpixVer = '0' then
                        txSerData(53 downto 38) <= locData after tpd;
                     else
                        txSerData(46 downto 31) <= locData after tpd;
                     end if;

                     -- Checksum
                     checkSum <= checkSum + locData after tpd;

                     -- Next Data
                     curState <= TX_READ3 after tpd;
                  end if;
               end if;

            -- Read data from FIFO, data 3
            when TX_READ3 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- SOF is detected
                  if locSOF = '1' then

                     -- Get command frame data
                     if kpixVer = '0' then
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(11 downto 5)  <= "0000000"           after tpd; -- Address = 0
                        txSerData(12)           <= locData(8)          after tpd; -- C/R Bit
                        txSerData(13)           <= locData(7)          after tpd; -- Write bit
                        txSerData(20 downto 14) <= locData(6 downto 0) after tpd; -- CMD ID
                     else
                        txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                        txSerData(4)            <= '0'                 after tpd; -- Frame Type
                        txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                        txSerData(6)            <= locData(7)          after tpd; -- Write bit
                        txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID
                     end if;

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel  <= (OTHERS=>'1') after tpd;
                        kpixSelL <= '1'           after tpd;
                     else
                        if(locData(15) = '1') then
                           kpixSelL <= '1'           after tpd;
                           kpixSel  <= (OTHERS=>'0') after tpd;
                        else
                           kpixSelL <= '0'           after tpd;
                           kpixSel  <= conv_5to32(locData(14 downto 12)&locData(10 downto 9)) after tpd;
                        end if;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;

                  else

                     -- No more reads
                     fifoRdEn <= '0' after tpd;

                     -- Compare checksum
                     if checkSum /= locData then
                        curState    <= TX_IDLE after tpd;
                        checkSumErr <= '1'     after tpd; 
                     else
                        curState  <= TX_DATA after tpd;
                        txDataBit <= '1'     after tpd; -- Start Bit
                     end if;
                  end if;
               end if;

            -- Transmit data
            when TX_DATA =>

               -- Store header and data parity
               if kpixVer = '0' then
                  txSerData(21) <= headParCalc after tpd;
                  txSerData(54) <= dataParCalc after tpd;
               else
                  txSerData(14) <= headParCalc after tpd;
                  txSerData(47) <= dataParCalc after tpd;
               end if;

               -- Output data
               txDataBit <= txSerData(conv_integer(txCount)) after tpd;

               -- Last bit
               if (kpixVer = '0' and txCount = 54) or (kpixVer = '1' and txCount = 47) then
                  curState <= TX_DONE       after tpd;
                  txCount  <= (others=>'0') after tpd;
               else
                  txCount <= txCount + 1 after tpd;
               end if;

            -- Done state, wait between command frames
            when TX_DONE =>

               -- Keep counting
               txCount   <= txCount + 1 after tpd;
               txDataBit <= '0'         after tpd;

               -- Wait 4 clocks
               if txCount = 4 then
                  curState <= TX_IDLE       after tpd;
                  kpixSelL <= '0'           after tpd;
                  kpixSel  <= (OTHERS=>'0') after tpd;
               end if;

            -- Default
            when others=> curState <= TX_IDLE after tpd;
         end case;
      end if;
   end process;


   -- Parity computation
   process ( txSerData, kpixVer ) begin
      if kpixVer = '0' then

         -- Header parity calculation
         headParCalc <= txSerData(0)  xor txSerData(1)  xor txSerData(2)  xor txSerData(3)  xor 
                        txSerData(4)  xor txSerData(5)  xor txSerData(6)  xor txSerData(7)  xor 
                        txSerData(8)  xor txSerData(9)  xor txSerData(10) xor txSerData(11) xor 
                        txSerData(12) xor txSerData(13) xor txSerData(14) xor txSerData(15) xor 
                        txSerData(16) xor txSerData(17) xor txSerData(18) xor txSerData(19) xor 
                        txSerData(20);

         -- Data parity calculation
         dataParCalc <= txSerData(22) xor txSerData(23) xor txSerData(24) xor txSerData(25) xor 
                        txSerData(26) xor txSerData(27) xor txSerData(28) xor txSerData(29) xor 
                        txSerData(30) xor txSerData(31) xor txSerData(32) xor txSerData(33) xor 
                        txSerData(34) xor txSerData(35) xor txSerData(36) xor txSerData(37) xor 
                        txSerData(38) xor txSerData(39) xor txSerData(40) xor txSerData(41) xor 
                        txSerData(42) xor txSerData(43) xor txSerData(44) xor txSerData(45) xor 
                        txSerData(46) xor txSerData(47) xor txSerData(48) xor txSerData(49) xor 
                        txSerData(50) xor txSerData(51) xor txSerData(52) xor txSerData(53);
      else
         -- Header parity calculation
         headParCalc <= txSerData(0)  xor txSerData(1)  xor txSerData(2)  xor txSerData(3)  xor 
                        txSerData(4)  xor txSerData(5)  xor txSerData(6)  xor txSerData(7)  xor 
                        txSerData(8)  xor txSerData(9)  xor txSerData(10) xor txSerData(11) xor 
                        txSerData(12) xor txSerData(13);

         -- Data parity calculation
         dataParCalc <= txSerData(15) xor txSerData(16) xor txSerData(17) xor txSerData(18) xor 
                        txSerData(19) xor txSerData(20) xor txSerData(21) xor txSerData(22) xor 
                        txSerData(23) xor txSerData(24) xor txSerData(25) xor txSerData(26) xor 
                        txSerData(27) xor txSerData(28) xor txSerData(29) xor txSerData(30) xor 
                        txSerData(31) xor txSerData(32) xor txSerData(33) xor txSerData(34) xor 
                        txSerData(35) xor txSerData(36) xor txSerData(37) xor txSerData(38) xor 
                        txSerData(39) xor txSerData(40) xor txSerData(41) xor txSerData(42) xor 
                        txSerData(43) xor txSerData(44) xor txSerData(45) xor txSerData(46);
      end if;
   end process;


   -- Serial data out to KPIX devices
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         serData  <= (OTHERS=>'0') after tpd;
         serDataL <= '0'           after tpd;
      elsif rising_edge(kpixClk) then
         serData  <= and_1to32(txDataBit, kpixSel) after tpd;
         serDataL <= txDataBit and kpixSelL        after tpd;
      end if;
   end process;

end KpixCmdTx;

