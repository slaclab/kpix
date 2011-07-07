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

entity KpixCmdTx is 
   port ( 

      -- System clock, reset
      sysClk20      : in    std_logic;                     -- 20Mhz system clock
      syncRst       : in    std_logic;                     -- System reset
      kpixClk       : in    std_logic;                     -- Kpix Clock
      kpixRst       : in    std_logic;                     -- Kpix Reset

      -- Checksum error
      checkSumErr   : out   std_logic;                     -- Checksum error flag

      -- FIFO Interface
      fifoData      : in    std_logic_vector(15 downto 0); -- RX FIFO Data
      fifoSOF       : in    std_logic;                     -- RX FIFO Start of Frame
      fifoWr        : in    std_logic;                     -- RX FIFO Write
      fifoFull      : out   std_logic;                     -- RX FIFO Full

      -- Hardware driven acquisition command generation, broadcast
      genAcquire    : in    std_logic;                     -- Force command acquire
      genCalibrate  : in    std_logic;                     -- Force command calibrate

      -- Outgoing serial data lins
      serDataA      : out   std_logic;                     -- Serial data out A
      serDataB      : out   std_logic;                     -- Serial data out B
      serDataC      : out   std_logic;                     -- Serial data out C
      serDataD      : out   std_logic                      -- Serial data out D
   );

end KpixCmdTx;


-- Define architecture
architecture KpixCmdTx of KpixCmdTx is 

   -- FIFO
   component afifo_17x32 port (
      din:      IN  std_logic_VECTOR(16 downto 0);
      wr_en:    IN  std_logic;
      wr_clk:   IN  std_logic;
      rd_en:    IN  std_logic;
      rd_clk:   IN  std_logic;
      rst:      IN  std_logic;
      dout:     OUT std_logic_VECTOR(16 downto 0);
      full:     OUT std_logic;
      empty:    OUT std_logic 
   ); end component;

   -- Local signals
   signal locDout       : std_logic_vector(16 downto 0);
   signal locDin        : std_logic_vector(16 downto 0);
   signal locRd         : std_logic;
   signal locEmpty      : std_logic;
   signal locData       : std_logic_vector(15 downto 0);
   signal locSOF        : std_logic;
   signal txSerData     : std_logic_vector(54 downto 0);
   signal txDataBit     : std_logic;
   signal kpixSel       : std_logic_vector(3  downto 0);
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

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

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

                  -- Broadcast
                  kpixSel <= "1111" after tpd;

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
                     txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                     txSerData(4)            <= '0'                 after tpd; -- Frame Type
                     txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                     txSerData(6)            <= locData(7)          after tpd; -- Write bit
                     txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '0' and locData(7) = '1' then
                        kpixSel <= "1111" after tpd;
                     else
                        case locData(10 downto 9) is
                           when "00"   => kpixSel <= "0001" after tpd;
                           when "01"   => kpixSel <= "0010" after tpd;
                           when "10"   => kpixSel <= "0100" after tpd;
                           when "11"   => kpixSel <= "1000" after tpd;
                           when others => kpixSel <= "0000" after tpd;
                        end case;
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
                     txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                     txSerData(4)            <= '0'                 after tpd; -- Frame Type
                     txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                     txSerData(6)            <= locData(7)          after tpd; -- Write bit
                     txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel <= "1111" after tpd;
                     else
                        case locData(10 downto 9) is
                           when "00"   => kpixSel <= "0001" after tpd;
                           when "01"   => kpixSel <= "0010" after tpd;
                           when "10"   => kpixSel <= "0100" after tpd;
                           when "11"   => kpixSel <= "1000" after tpd;
                           when others => kpixSel <= "0000" after tpd;
                        end case;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;

                  else

                     -- Get lower bits of data
                     txSerData(30 downto 15) <= locData after tpd;

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
                     txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                     txSerData(4)            <= '0'                 after tpd; -- Frame Type
                     txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                     txSerData(6)            <= locData(7)          after tpd; -- Write bit
                     txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel <= "1111" after tpd;
                     else
                        case locData(10 downto 9) is
                           when "00"   => kpixSel <= "0001" after tpd;
                           when "01"   => kpixSel <= "0010" after tpd;
                           when "10"   => kpixSel <= "0100" after tpd;
                           when "11"   => kpixSel <= "1000" after tpd;
                           when others => kpixSel <= "0000" after tpd;
                        end case;
                     end if;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= TX_READ1 after tpd;

                  else

                     -- Get upper bits of data
                     txSerData(46 downto 31) <= locData after tpd;

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
                     txSerData(3  downto 0)  <= "1010"              after tpd; -- Marker
                     txSerData(4)            <= '0'                 after tpd; -- Frame Type
                     txSerData(5)            <= locData(8)          after tpd; -- C/R Bit
                     txSerData(6)            <= locData(7)          after tpd; -- Write bit
                     txSerData(13 downto 7)  <= locData(6 downto 0) after tpd; -- CMD ID

                     -- Get Kpix Enables, commands with write bit set
                     if locData(11) = '1' and locData(8) = '1' and locData(7) = '1' then
                        kpixSel <= "1111" after tpd;
                     else
                        case locData(10 downto 9) is
                           when "00"   => kpixSel <= "0001" after tpd;
                           when "01"   => kpixSel <= "0010" after tpd;
                           when "10"   => kpixSel <= "0100" after tpd;
                           when "11"   => kpixSel <= "1000" after tpd;
                           when others => kpixSel <= "0000" after tpd;
                        end case;
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
               txSerData(14) <= headParCalc after tpd;
               txSerData(47) <= dataParCalc after tpd;

               -- Output data
               txDataBit <= txSerData(conv_integer(txCount)) after tpd;

               -- Last bit
               if txCount = 47 then
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
                  curState <= TX_IDLE after tpd;
               end if;

            -- Default
            when others=> curState <= TX_IDLE after tpd;
         end case;
      end if;
   end process;


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


   -- Serial data out to KPIX devices
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         serDataA <= '0' after tpd;
         serDataB <= '0' after tpd;
         serDataC <= '0' after tpd;
         serDataD <= '0' after tpd;
      elsif rising_edge(kpixClk) then
         serDataA <= txDataBit and kpixSel(0) after tpd;
         serDataB <= txDataBit and kpixSel(1) after tpd;
         serDataC <= txDataBit and kpixSel(2) after tpd;
         serDataD <= txDataBit and kpixSel(3) after tpd;
      end if;
   end process;

end KpixCmdTx;

