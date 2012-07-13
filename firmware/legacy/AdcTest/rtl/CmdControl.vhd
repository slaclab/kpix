-------------------------------------------------------------------------------
-- Title         : ADC Test FPGA, Top Level
-------------------------------------------------------------------------------
-- File          : CmdControl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/06/2009
-------------------------------------------------------------------------------
-- Description:
-- Command decode and ADC read.
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

entity CmdControl is 
   port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                     -- 20Mhz system clock
      sysRst        : in    std_logic;                     -- System reset

      -- Incoming USB
      rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
      rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
      rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
      rxFifoWr      : in     std_logic;                     -- RX FIFO Write
      rxFifoFull    : out    std_logic;                     -- RX FIFO Full

      -- Outgoing USB Interface
      txFifoData    : out   std_logic_vector(15 downto 0);   -- TX FIFO Data
      txFifoSOF     : out   std_logic;                       -- TX FIFO Start of Frame
      txFifoType    : out   std_logic_vector(1  downto 0);   -- TX FIFO Data Type
      txFifoRd      : in    std_logic;                       -- TX FIFO Read
      txFifoEmpty   : out   std_logic;                       -- TX FIFO Empty

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
end CmdControl;


-- Define architecture
architecture CmdControl of CmdControl is

   -- DS FIFO
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

   -- US FIFO
   component afifo_19x8k port (
      din:           IN std_logic_VECTOR(18 downto 0);
      rd_clk:        IN std_logic;
      rd_en:         IN std_logic;
      rst:           IN std_logic;
      wr_clk:        IN std_logic;
      wr_en:         IN std_logic;
      dout:          OUT std_logic_VECTOR(18 downto 0);
      empty:         OUT std_logic;
      full:          OUT std_logic;
      wr_data_count: OUT std_logic_VECTOR(12 downto 0));
   end component;

   -- DDR Output Flip Flop
   component FDDRRSE
      port (
         Q  : out std_logic;
         C0 : in std_logic;
         C1 : in std_logic;
         CE : in std_logic;
         D0 : in std_logic;
         D1 : in std_logic;
         R  : in std_logic;
         S  : in std_logic
      );
   end component;

   -- Xilinx global clock buffer component
   component BUFGMUX 
      port ( 
         O  : out std_logic; 
         I0 : in std_logic;
         I1 : in std_logic;  
         S  : in std_logic 
      ); 
   end component;

   -- DAC Control
   component DacCntrl
      port ( 
         sysClk       : in    std_logic;
         sysRst       : in    std_logic;
         cmdWrEn      : in     std_logic;
         cmdWData     : in     std_logic_vector(15 downto 0);
         cmdWrAck     : out    std_logic;
         calCsL       : out    std_logic;
         calClrL      : out    std_logic;
         calSClk      : out    std_logic;
         calSDin      : out    std_logic
      );
   end component;

   -- Local signals
   signal fifoDin       : std_logic_vector(18 downto 0);
   signal fifoDout      : std_logic_vector(18 downto 0);
   signal locDout       : std_logic_vector(16 downto 0);
   signal locDin        : std_logic_vector(16 downto 0);
   signal locRd         : std_logic;
   signal locEmpty      : std_logic;
   signal locData       : std_logic_vector(15 downto 0);
   signal locSOF        : std_logic;
   signal fifoRdEn      : std_logic;
   signal fifoRdDly     : std_logic;
   signal checkSum      : std_logic_vector(15 downto 0);
   signal locReadData   : std_logic_vector(31 downto 0);
   signal locReady      : std_logic;
   signal locAddress    : std_logic_vector(7  downto 0);
   signal locWrCmd      : std_logic;
   signal locWrData     : std_logic_vector(31 downto 0);
   signal intWrEn       : std_logic;
   signal fifoTxWr      : std_logic;
   signal fifoTxData    : std_logic_vector(15 downto 0);
   signal fifoTxSOF     : std_logic;
   signal adcReadEn     : std_logic;
   signal adcDone       : std_logic;
   signal adcCnt        : std_logic_vector(3  downto 0);
   signal subCnt        : std_logic_vector(15 downto 0);
   signal setCnt        : std_logic_vector(31 downto 0);
   signal adcShift      : std_logic_vector(9  downto 0);
   signal adcSel        : std_logic_vector(31 downto 0);
   signal posAdcData    : std_logic;
   signal negAdcData    : std_logic;
   signal selAdcData    : std_logic;
   signal adcReadEnDly  : std_logic;
   signal adcReadEdge   : std_logic;
   signal shiftEn       : std_logic;
   signal adcWe         : std_logic;
   signal sysClkAdcL    : std_logic;
   signal locCmd        : std_logic;
   signal cntWe         : std_logic;
   signal tmpDone       : std_logic;
   signal syncDone      : std_logic;
   signal tmpReadEn     : std_logic;
   signal dlyReadEn     : std_logic;
   signal sysClkSel     : std_logic;
   signal sysClkAdc     : std_logic;
   signal dacWrEn       : std_logic;
   signal dacWrAck      : std_logic;

   -- State machine
   constant ST_IDLE  : std_logic_vector(3 downto 0) := "0001";
   constant ST_READ0 : std_logic_vector(3 downto 0) := "0010";
   constant ST_READ1 : std_logic_vector(3 downto 0) := "0011";
   constant ST_READ2 : std_logic_vector(3 downto 0) := "0100";
   constant ST_READ3 : std_logic_vector(3 downto 0) := "0101";
   constant ST_CMD   : std_logic_vector(3 downto 0) := "0110";
   constant ST_RSP0  : std_logic_vector(3 downto 0) := "0111";
   constant ST_RSP1  : std_logic_vector(3 downto 0) := "1000";
   constant ST_RSP2  : std_logic_vector(3 downto 0) := "1001";
   signal   curState : std_logic_vector(3 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Data going into FIFO
   locDin(15 downto  0) <= rxFifoData;
   locDin(16)           <= rxFifoSOF;

   -- Transmit fIFO
   U_ST_FIFO: afifo_17x32 port map (
      wr_clk   => sysClk,     rd_clk => sysClk,
      din      => locDin,     wr_en  => rxFifoWr,
      rd_en    => locRd,      dout   => locDout, 
      full     => rxFifoFull, empty  => locEmpty,
      rst      => sysRst
   );

   -- FIFO Output
   locData <= locDout(15 downto  0);
   locSOF  <= locDout(16);

   -- Local read mux and write control
   process ( locAddress,  adcSel, adcShift, adcDone, intWrEn, setCnt ) begin
      case locAddress is

         -- Version
         when "00000000" => 
            locReadData <= x"A0000003";
            adcReadEn   <= '0';
            locReady    <= '1';
            adcWe       <= '0';
            cntWe       <= '0';
            dacWrEn     <= '0';

         -- ADC Config
         when "00000001" => 
            locReadData <= adcSel;
            adcReadEn   <= '0';
            locReady    <= '1';
            adcWe       <= intWrEn;
            cntWe       <= '0';
            dacWrEn     <= '0';

         -- Set Count
         when "00000010" => 
            locReadData <= setCnt;
            adcReadEn   <= '0';
            locReady    <= '1';
            adcWe       <= '0';
            cntWe       <= intWrEn;
            dacWrEn     <= '0';

         -- Set DAC
         when "00000011" => 
            locReadData <= (others=>'0');
            adcReadEn   <= '0';
            locReady    <= dacWrAck;
            adcWe       <= '0';
            cntWe       <= '0';
            dacWrEn     <= intWrEn;

         -- ADC Read
         when "00000111" => 
            locReadData <= x"0000" & "000000" & adcShift;
            adcReadEn   <= locCmd;
            locReady    <= syncDone;
            adcWe       <= '0';
            cntWe       <= '0';
            dacWrEn     <= '0';

         when others => 
            locReadData <= (others=>'0');
            adcReadEn   <= '0';
            locReady    <= '1';
            adcWe       <= '0';
            cntWe       <= '0';
            dacWrEn     <= '0';
      end case;
   end process;


   -- ACD Write Control, double sync ack
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         adcSel       <= (others=>'0') after tpd;
         setCnt       <= (others=>'0') after tpd;
         tmpDone      <= '0'           after tpd;
         syncDone     <= '0'           after tpd;
      elsif rising_edge(sysClk) then

         -- Config write
         if adcWe = '1' then
            adcSel <= locWrData after tpd;
         end if;

         -- Count write
         if cntWe = '1' then
            setCnt <= locWrData after tpd;
         end if;

         -- Double sync ready
         tmpDone  <= adcDone after tpd;
         syncDone <= tmpDone after tpd;
      end if;
   end process;


   -- Control FIFO reads
   locRd <= fifoRdEn and not locEmpty;

   -- State machine to read from FIFO and generate 
   -- command / response bus cycles
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         fifoRdEn     <= '0'           after tpd;
         fifoRdDly    <= '0'           after tpd;
         curState     <= ST_IDLE       after tpd;
         checkSum     <= (others=>'0') after tpd;
         locAddress   <= (others=>'0') after tpd;
         locWrCmd     <= '0'           after tpd;
         intWrEn      <= '0'           after tpd;
         fifoTxWr     <= '0'           after tpd;
         fifoTxData   <= (others=>'0') after tpd;
         fifoTxSOF    <= '0'           after tpd;
         locWrData    <= (others=>'0') after tpd;
         locCmd       <= '0'           after tpd;
      elsif rising_edge(sysClk) then

         -- Delayed copy of read
         fifoRdDly <= locRd;

         -- Current state
         case curState is 

            -- IDLE, Wait for data in FIFO or force command
            when ST_IDLE =>

               -- FIFO is ready, start read
               if locEmpty = '0' then
                  fifoRdEn  <= '1'      after tpd;   
                  curState  <= ST_READ0 after tpd;
               end if;
               intWrEn  <= '0' after tpd;
               fifoTxWr <= '0' after tpd;
               locCmd   <= '0' after tpd;

            -- Read data from FIFO, data 0
            when ST_READ0 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Go back to IDLE if value is not SOF
                  if locSOF = '0' then
                     fifoRdEn <= '0'     after tpd;
                     curState <= ST_IDLE after tpd;
                  
                  -- Otherwise store data, increment counter, read again
                  else

                     -- Read another
                     fifoRdEn <= '1' after tpd;

                     -- Store address and write flag
                     locWrCmd   <= locData(8)          after tpd;
                     locAddress <= locData(7 downto 0) after tpd;

                     -- Checksum
                     checkSum <= locData after tpd;

                     -- Next Data
                     curState <= ST_READ1 after tpd;
                  end if;
               end if;
               locCmd   <= '0' after tpd;

            -- Read data from FIFO, data 1
            when ST_READ1 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Get lower bits of data
                  locWrData(15 downto 0) <= locData after tpd;

                  -- Checksum
                  checkSum <= checkSum + locData after tpd;

                  -- Next Data
                  curState <= ST_READ2 after tpd;
               end if;
               locCmd   <= '0' after tpd;

            -- Read data from FIFO, data 2
            when ST_READ2 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Get upper bits of data
                  locWrData(31 downto 16) <= locData after tpd;

                  -- Checksum
                  checkSum <= checkSum + locData after tpd;

                  -- Next Data
                  curState <= ST_READ3 after tpd;
               end if;
               locCmd   <= '0' after tpd;

            -- Read data from FIFO, data 3
            when ST_READ3 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- No more reads
                  fifoRdEn <= '0' after tpd;

                  -- Compare checksum
                  if checkSum /= locData then
                     curState <= ST_IDLE after tpd;
                  else
                     curState <= ST_CMD after tpd;
                  end if;
               end if;
               locCmd   <= '0' after tpd;

            -- Address has been put out, read or write?
            when ST_CMD =>
               locCmd <= '1' after tpd;

               -- Command is a write
               if locWrCmd = '1' then
                  intWrEn <= '1'     after tpd;

                  if locReady = '1' then
                     curState <= ST_IDLE after tpd;
                  end if;

               -- Command is a read, wait for ready
               elsif locReady = '1' then

                  -- Setup first word of response
                  fifoTxWr                <= '1'           after tpd;
                  fifoTxData(15 downto 8) <= (others=>'0') after tpd;
                  fifoTxData(7  downto 0) <= locAddress    after tpd;
                  fifoTxSOF               <= '1'           after tpd;

                  -- Checksum
                  checkSum(15 downto 8) <= (others=>'0') after tpd;
                  checkSum(7  downto 0) <= locAddress    after tpd;

                  -- Next state
                  curState <= ST_RSP0 after tpd;
               end if;


            -- First word of response
            when ST_RSP0 =>

               -- Second word of response
               fifoTxWr   <= '1'                      after tpd;
               fifoTxData <= locReadData(15 downto 0) after tpd;
               fifoTxSOF  <= '0'                      after tpd;

               -- Checksum
               checkSum <= checkSum + locReadData(15 downto 0) after tpd;

               -- Next state
               curState <= ST_RSP1 after tpd;
               locCmd   <= '0'     after tpd;


            -- Second word of response
            when ST_RSP1 =>

               -- Second word of response
               fifoTxWr   <= '1'                       after tpd;
               fifoTxData <= locReadData(31 downto 16) after tpd;
               fifoTxSOF  <= '0'                       after tpd;

               -- Checksum
               checkSum <= checkSum + locReadData(31 downto 16) after tpd;

               -- Next state
               curState <= ST_RSP2 after tpd;
               locCmd   <= '0'     after tpd;

            -- Third word of response
            when ST_RSP2 =>

               -- Second word of response
               fifoTxWr   <= '1'      after tpd;
               fifoTxData <= checkSum after tpd;
               fifoTxSOF  <= '0'      after tpd;
               curState   <= ST_IDLE  after tpd;
               locCmd     <= '0'      after tpd;

            -- Default
            when others=> curState <= ST_IDLE after tpd;
         end case;
      end if;
   end process;

   -- Connect data to FIFO
   fifoDin(18)           <= fifoTxSOF;
   fifoDin(17 downto 16) <= "00";
   fifoDin(15 downto  0) <= fifoTxData;

   -- Async FIFO
   U_UsFifo : afifo_19x8k port map (
      din    => fifoDin,
      rd_clk => sysClk,
      rd_en  => txFifoRd,
      rst    => sysRst,
      wr_clk => sysClk,
      wr_en  => fifoTxWr,
      dout   => fifoDout,
      empty  => txFifoEmpty,
      full   => open,
      wr_data_count => open
   );

   -- Connect outgoing FIFO data
   txFifoData <= fifoDout(15 downto 0);
   txFifoType <= "10";
   txFifoSOF  <= fifoDout(18);


   -- Generate local clock for ADC interface
   process (sysClk, sysRst ) begin
      if sysRst = '1' then
         subCnt    <= (others=>'0') after tpd;
      elsif rising_edge(sysClk) then
         subCnt    <= subCnt + 1 after tpd;
      end if;
   end process;


   -- Choose frequency
   sysClkSel <= sysClk     when setCnt = 0  else -- 20    Mhz
                subCnt(0)  when setCnt = 1  else -- 10    Mhz
                subCnt(1)  when setCnt = 2  else -- 5     Mhz
                subCnt(2)  when setCnt = 3  else -- 2.5   Mhz
                subCnt(3)  when setCnt = 4  else -- 1.3   Mhz
                subCnt(4)  when setCnt = 5  else -- 625   Khz
                subCnt(5)  when setCnt = 6  else -- 312.5 Khz
                subCnt(6)  when setCnt = 7  else -- 156.3 Khz
                subCnt(7)  when setCnt = 8  else -- 78    Khz
                subCnt(8)  when setCnt = 9  else -- 39    Khz
                subCnt(9)  when setCnt = 10 else -- 19.5  Khz
                subCnt(10) when setCnt = 11 else -- 9.8   Khz
                subCnt(11) when setCnt = 12 else -- 4.9   Khz
                subCnt(12) when setCnt = 13 else -- 2.4   Khz
                subCnt(13) when setCnt = 14 else -- 1.2   Khz
                subCnt(14) when setCnt = 15 else -- 610   Hz    
                subCnt(15) when setCnt = 16 else -- 305   Hz    
                '0';

   -- Connect to global buffer
   U_BUFLOCM: BUFGMUX port map (
      O  => sysClkAdc,
      I0 => sysClkSel,
      I1 => '0',
      S  => '0'
   );


   -- ACD Read Control
   process (sysClkAdc, sysRst ) begin
      if sysRst = '1' then
         adcCnt       <= (others=>'0') after tpd;
         adcShift     <= (others=>'0') after tpd;
         adcReadEnDly <= '0'           after tpd;
         adcReadEdge  <= '0'           after tpd;
         shiftEn      <= '0'           after tpd;
         adcEnable    <= '0'           after tpd;
         adcDone      <= '0'           after tpd;
         tmpReadEn    <= '0'           after tpd;
         dlyReadEn    <= '0'           after tpd;
      elsif rising_edge(sysClkAdc) then

         -- Double sample enable
         tmpReadEn <= adcReadEn after tpd;
         dlyReadEn <= tmpReadEn after tpd;

         -- Detect edge of enable
         adcReadEnDly <= dlyReadEn after tpd;
         adcReadEdge  <= dlyReadEn and not adcReadEnDly after tpd;

         -- Run start
         if adcReadEdge = '1' then
            adcCnt <= (others=>'1')      after tpd;
         elsif adcCnt /= 0 then
            adcCnt <= adcCnt - 1 after tpd;
         end if;

         -- Shift enable
         if adcCnt = 10 then
            shiftEn <= '1' after tpd;
         elsif adcCnt = 0 then
            shiftEn <= '0' after tpd;
         end if;

         -- ADC Enable
         if adcCnt = 14 then
            adcEnable <= '1' after tpd;
         elsif adcCnt = 12 then
            adcEnable <= '0' after tpd;
         end if;

         -- Shift data
         if shiftEn = '1' then
            adcShift <= adcShift(8 downto 0) & selAdcData;
         end if;

         -- ADC is done
         if adcCnt = 0 and dlyReadEn = '1' and adcReadEnDly = '1' then
            adcDone <= '1' after tpd;
         else
            adcDone <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Incoming data, register at both edges
   process (sysClkAdc, sysRst ) begin
      if sysRst = '1' then
         posAdcData <= '0' after tpd;
      elsif rising_edge(sysClkAdc) then
         posAdcData <= adcDout after tpd;
      end if;
   end process;
   process (sysClkAdc, sysRst ) begin
      if sysRst = '1' then
         negAdcData <= '0' after tpd;
      elsif falling_edge(sysClkAdc) then
         negAdcData <= adcDout after tpd;
      end if;
   end process;

   -- MUX Adc data
   selAdcData <= negAdcData when adcSel(0) = '0' else posAdcData;

   -- Inverted copy of clock
   sysClkAdcL <= not sysClkAdc;

   -- ADC clock generation
   U_GenClk : FDDRRSE port map (
      Q  => adcClk, 
      CE => '1',
      C0 => sysClkAdc,
      C1 => sysClkAdcL,
      D0 => '1',      
      D1 => '0',
      R  => '0',      
      S  => '0'
   );


   -- DAC Control
   U_DacCntrl: DacCntrl port map ( 
      sysClk   => sysClk,
      sysRst   => sysRst,
      cmdWrEn  => dacWrEn,
      cmdWData => locWrData(15 downto 0),
      cmdWrAck => dacWrAck,
      calCsL   => calCsL,
      calClrL  => calClrL,
      calSClk  => calSClk,
      calSDin  => calSDin
   );

end CmdControl;

