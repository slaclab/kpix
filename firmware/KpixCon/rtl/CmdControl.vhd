-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Command Controller
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : CmdControl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the command decoder control of the KPIX FPGA
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 07/24/2007: Added inter-word usb delay
-- 08/12/2007: Added temperature value read
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.Version.all;
use work.KpixConPkg.all;

entity CmdControl is 
   port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                     -- 125Mhz system clock
      sysRst        : in    std_logic;                     -- System reset
      kpixClk       : in    std_logic;                     -- 20Mhz system clock
      kpixRst       : in    std_logic;                     -- System reset

      -- Incoming checksum error flag
      checkSumErr   : in    std_logic;                     -- Checksum error flag

      -- Outgoing reset commands
      mstRstCmd     : out   std_logic;                     -- Master reset command
      kpixRstCmd    : out   std_logic;                     -- Kpix reset command

      -- Incoming FIFO Interface
      fifoRxData    : in    std_logic_vector(15 downto 0); -- RX FIFO Data
      fifoRxSOF     : in    std_logic;                     -- RX FIFO Start of Frame
      fifoRxWr      : in    std_logic;                     -- RX FIFO Write
      fifoRxFull    : out   std_logic;                     -- RX FIFO Full
      
      -- Outgoing FIFO Interface
      fifoTxReq     : out   std_logic;                     -- RX FIFO Request
      fifoTxAck     : in    std_logic;                     -- RX FIFO Grant
      fifoTxWr      : out   std_logic;                     -- RX FIFO Write
      fifoTxData    : out   std_logic_vector(15 downto 0); -- RX FIFO Data
      fifoTxSOF     : out   std_logic;                     -- RX FIFO Start of Frame
      fifoTxEOF     : out   std_logic;                     -- RX FIFO End of Frame

      -- Clock select output
      clkSelA       : out   std_logic_vector(4  downto 0); -- Clock select
      clkSelB       : out   std_logic_vector(4  downto 0); -- Clock select
      clkSelC       : out   std_logic_vector(4  downto 0); -- Clock select
      clkSelD       : out   std_logic_vector(4  downto 0); -- Clock select

      -- Jumper inputs
      jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low

      -- Interface to local register controller
      writeData     : out   std_logic_vector(31 downto 0); -- Write Data
      readData      : in    std_logic_vector(31 downto 0); -- Read Data
      writeEn       : out   std_logic;                     -- Write strobe
      address       : out   std_logic_vector(7  downto 0); -- Address select

      -- Kpix Data Read Phase
      kpixRdPhase   : out   std_logic_vector(4  downto 0); -- Phase shift to read kpix data
      kpixRdEdge    : out   std_logic;                     -- Edge to read kpix data

      -- Debug
      csControl     : inout  std_logic_vector(35 downto 0) -- Chip Scope Control
   );
end CmdControl;


-- Define architecture
architecture CmdControl of CmdControl is

   -- Local signals
   signal locDout       : std_logic_vector(16 downto 0);
   signal locDin        : std_logic_vector(16 downto 0);
   signal locRd         : std_logic;
   signal locEmpty      : std_logic;
   signal locData       : std_logic_vector(15 downto 0);
   signal locSOF        : std_logic;
   signal fifoRdEn      : std_logic;
   signal fifoRdDly     : std_logic;
   signal checkSum      : std_logic_vector(15 downto 0);
   signal locWriteData  : std_logic_vector(31 downto 0);
   signal locReadData   : std_logic_vector(31 downto 0);
   signal locWriteEn    : std_logic;
   signal locWrCmd      : std_logic;
   signal intWriteEn    : std_logic;
   signal locAddress    : std_logic_vector(7  downto 0);
   signal scratchPad    : std_logic_vector(31 downto 0);
   signal intClkSelA    : std_logic_vector(4  downto 0);
   signal intClkSelB    : std_logic_vector(4  downto 0);
   signal intClkSelC    : std_logic_vector(4  downto 0);
   signal intClkSelD    : std_logic_vector(4  downto 0);
   signal intRdPhase    : std_logic_vector(7  downto 0);
   signal intRdEdge     : std_logic_vector(7  downto 0);
   signal locCsumErr    : std_logic;
   signal checkErrCnt   : std_logic_vector(7  downto 0);
   signal csumClear     : std_logic;
   signal clkRst0       : std_logic;
   signal clkRst1       : std_logic;
   signal clkRst        : std_logic;
   signal fifoDout      : std_logic_vector(15 downto 0);
   signal fifoDin       : std_logic_vector(15 downto 0);
   signal fifoRd        : std_logic;
   signal fifoWr        : std_logic;
   signal fifoFull      : std_logic;
   signal fifoEmpty     : std_logic;
   signal fifoSOFout    : std_logic;
   signal fifoEOFout    : std_logic;
   signal fifoSOFin     : std_logic;
   signal fifoEOFin     : std_logic;
   
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
   constant ST_RSP3  : std_logic_vector(3 downto 0) := "1010";
   signal   curState : std_logic_vector(3 downto 0);

   -- Chip Scope signals
   constant enChipScope  : integer := 0;
   signal   sysDebug     : std_logic_vector(63 downto 0);
   
begin

   ----------------------------------------------------------
   ------------------ Debug Block ---------------------------
   
   sysDebug (63 downto 56) <= locAddress;
   sysDebug (55 downto 52) <= curState;
   sysDebug (51)           <= locWrCmd;
   sysDebug (50 downto 35) <= locReadData(15 downto 0);
   sysDebug (34)           <= fifoEmpty;
   sysDebug (33)           <= fifoWr;
   sysDebug (32)           <= fifoRd;
   sysDebug (31 downto 16) <= fifoDin;
   sysDebug (15 downto  0) <= fifoDout;

   chipscope : if (enChipScope = 1) generate   
      U_CmdControl_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => kpixClk,
         TRIG0   => sysDebug
      );
   end generate chipscope;
   
   ---------------------- Debug Block ----------------------------
   ---------------------------------------------------------------

   -- Outputs
   clkSelA     <= intClkSelA;
   clkSelB     <= intClkSelB;
   clkSelC     <= intClkSelC;
   clkSelD     <= intClkSelD;
   writeData   <= locWriteData;
   address     <= locAddress;
   kpixRdPhase <= intRdPhase(4 downto 0);
   kpixRdEdge  <= intRdEdge(0);

   -- Data going into FIFO
   locDin(15 downto  0) <= fifoRxData;
   locDin(16)           <= fifoRxSOF;

   -- Downstream Fifo
   U_ST_FIFO: afifo_17x32 port map (
      wr_clk   => sysClk,     rd_clk => kpixClk,
      din      => locDin,     wr_en  => fifoRxWr,
      rd_en    => locRd,      dout   => locDout, 
      full     => fifoRxFull, empty  => locEmpty,
      rst      => sysRst
   );

   -- FIFO Output
   locData <= locDout(15 downto  0);
   locSOF  <= locDout(16);

   fifoTxReq  <= not fifoEmpty;
   fifoTxWr   <= fifoTxAck and (not fifoEmpty);
   fifoTxEOF  <= fifoEOFout;
   fifoTxSOF  <= fifoSOFout;
   fifoTxData <= fifoDout;
   fifoRd     <= fifoTxAck and (not fifoEmpty);

   -- Upstream Fifo
   U_UP_Fifo : afifo_18x1k port map(
      rd_clk             => sysClk,
      rd_en              => fifoRd,
      dout(17)           => fifoEOFout,
      dout(16)           => fifoSOFout,
      dout(15 downto 0)  => fifoDout,
      rst                => kpixRst,
      wr_clk             => kpixClk,
      wr_en              => fifoWr,
      din(17)            => fifoEOFin,
      din(16)            => fifoSOFin,
      din(15 downto 0)   => fifoDin ,
      empty              => fifoEmpty,
      full               => fifoFull);

   -- Local read mux and write control
   process ( locAddress, readData, jumpL, scratchPad, intClkSelA, intClkSelB, 
             intClkSelC, intClkSelD, intWriteEn, checkErrCnt ) begin
      case locAddress is

         -- Version / Master Reset Register
         when "00000000" => 
            locReadData <= FpgaVersion;
            locWriteEn  <= intWriteEn;
            writeEn     <= '0';

         -- Jumper / Kpix Reset Register
         when "00000001" => 
            locReadData <= x"0000000" & (not jumpL);
            locWriteEn  <= intWriteEn;
            writeEn     <= '0';

         -- Scratchpad Register
         when "00000010" => 
            locReadData <= scratchPad;
            locWriteEn  <= intWriteEn;
            writeEn     <= '0';

         -- Clock Select Register
         when "00000011" => 
            locReadData(31 downto 29) <= (others=>'0');
            locReadData(28 downto 24) <= intClkSelD;
            locReadData(23 downto 21) <= (others=>'0');
            locReadData(20 downto 16) <= intClkSelC;
            locReadData(15 downto 13) <= (others=>'0');
            locReadData(12 downto  8) <= intClkSelB;
            locReadData(7  downto  5) <= (others=>'0');
            locReadData(4  downto  0) <= intClkSelA;
            locWriteEn                <= intWriteEn;
            writeEn                   <= '0';

         -- Checksum error counter
         when "00000100" => 
            locReadData <= x"000000" & checkErrCnt;
            locWriteEn  <= intWriteEn;
            writeEn     <= '0';

          -- Kpix Data Read Phase Register
         when "00000101" => 
            locReadData(31 downto 16) <= (OTHERS=>'0');
            locReadData(15 downto  8) <= intRdEdge;
            locReadData(7  downto  0) <= intRdPhase;
            locWriteEn                <= intWriteEn;
            writeEn                   <= '0';

        when others => 
            locReadData <= readData;
            locWriteEn  <= '0';
            writeEn     <= intWriteEn; 
      end case;
   end process;


   -- Write Commands
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         scratchPad  <= (others=>'0') after tpd;
         intRdPhase  <= x"03"         after tpd;
         intRdEdge   <= x"01"         after tpd;
         mstRstCmd   <= '0'           after tpd;
         kpixRstCmd  <= '0'           after tpd;
         csumClear   <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- Write strobe
         if locWriteEn = '1' then

            -- Master reset register
            if locAddress = "00000000" then
               mstRstCmd <= '1' after tpd;
            end if;

            -- Kpixreset register
            if locAddress = "00000001" then
               kpixRstCmd <= '1' after tpd;
            end if;

            -- Scratch pad register
            if locAddress = "00000010" then
               scratchPad <= locWriteData after tpd;
            end if;

            -- Checksum error Counter
            if locAddress = "00000100" then
               csumClear <= '1' after tpd;
            end if;

            -- Kpix Data Read Phase Register
            if locAddress = "00000101" then
               intRdEdge  <= locWriteData(15 downto 8) after tpd;
               intRdPhase <= locWriteData(7  downto 0) after tpd;
            end if;

         else
            mstRstCmd  <= '0' after tpd;
            kpixRstCmd <= '0' after tpd;
            csumClear  <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Synchronize master reset to kpixClk for special case
   process (kpixClk, sysRst ) begin
      if sysRst = '1' then
         clkRst0 <= '1' after tpd;
         clkRst1 <= '1' after tpd;
         clkRst  <= '1' after tpd;
      elsif rising_edge(kpixClk) then
         clkRst0 <= '0'     after tpd;
         clkRst1 <= clkRst0 after tpd;
         clkRst  <= clkRst1 after tpd;
      end if;
   end process;


   -- Clock control register has a special reset case
   process (kpixClk, clkRst ) begin
      if clkRst = '1' then
         intClkSelA <= "00100" after tpd;
         intClkSelB <= "00100" after tpd;
         intClkSelC <= "00100" after tpd;
         intClkSelD <= "00100" after tpd;
      elsif rising_edge(kpixClk) then

         -- Write strobe
         if locWriteEn = '1' then

            -- Clock Select register
            if locAddress = "00000011" then
               intClkSelD <= locWriteData(28 downto 24) after tpd;
               intClkSelC <= locWriteData(20 downto 16) after tpd;
               intClkSelB <= locWriteData(12 downto  8) after tpd;
               intClkSelA <= locWriteData(4  downto  0) after tpd;
            end if;
         end if;
      end if;
   end process;


   -- Checksum error counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         checkErrCnt <= (others=>'0');
      elsif rising_edge(kpixClk) then

         -- error counter clear
         if csumClear = '1' then
            checkErrCnt <= (others=>'0');

         -- Error counter input
         elsif checkErrCnt /= x"FFFF" and (locCsumErr = '1' or checkSumErr = '1') then
            checkErrCnt <= checkErrCnt + 1;
         end if;
      end if;
   end process;


   -- Control FIFO reads
   locRd <= fifoRdEn and not locEmpty;

   -- State machine to read from FIFO and generate 
   -- command / response bus cycles
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         fifoRdEn     <= '0'           after tpd;
         fifoWr       <= '0'           after tpd;
         fifoRdDly    <= '0'           after tpd;
         curState     <= ST_IDLE       after tpd;
         checkSum     <= (others=>'0') after tpd;
         locWriteData <= (others=>'0') after tpd;
         intWriteEn   <= '0'           after tpd;
         locAddress   <= (others=>'0') after tpd;
         locWrCmd     <= '0'           after tpd;
         fifoDin      <= (others=>'0') after tpd;
         fifoSOFin    <= '0'           after tpd;
         fifoEOFin    <= '0'           after tpd;
         locCsumErr   <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- Delayed copy of read
         fifoRdDly <= locRd;

         -- Current state
         case curState is 

            -- IDLE, Wait for data in FIFO or force command
            when ST_IDLE =>

               -- Clear write 
               intWriteEn <= '0' after tpd;
               locCsumErr <= '0' after tpd;
               fifoEOFin  <= '0' after tpd;
               fifoWr     <= '0' after tpd;

               -- FIFO is ready, start read
               if locEmpty = '0' then
                  fifoRdEn  <= '1'      after tpd;   
                  curState  <= ST_READ0 after tpd;
               end if;

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

            -- Read data from FIFO, data 1
            when ST_READ1 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Get lower bits of data
                  locWriteData(15 downto 0) <= locData after tpd;

                  -- Checksum
                  checkSum <= checkSum + locData after tpd;

                  -- Next Data
                  curState <= ST_READ2 after tpd;
               end if;

            -- Read data from FIFO, data 2
            when ST_READ2 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- Get upper bits of data
                  locWriteData(31 downto 16) <= locData after tpd;

                  -- Checksum
                  checkSum <= checkSum + locData after tpd;

                  -- Next Data
                  curState <= ST_READ3 after tpd;
               end if;

            -- Read data from FIFO, data 3
            when ST_READ3 =>

               -- Value was just read
               if fifoRdDly = '1' then

                  -- No more reads
                  fifoRdEn <= '0' after tpd;

                  -- Compare checksum
                  if checkSum /= locData then
                     curState   <= ST_IDLE after tpd;
                     locCsumErr <= '1'     after tpd;
                  else
                     curState  <= ST_CMD after tpd;
                  end if;
               end if;

            -- Address has been put out, read or write?
            when ST_CMD =>

               -- Command is a write
               if locWrCmd = '1' then
                  intWriteEn <= '1'     after tpd;
                  curState   <= ST_IDLE after tpd;

               -- Command is a read, start read cycle
               elsif fifoFull = '0' then

                  -- Setup first word of response
                  fifoWr                  <= '1'           after tpd;
                  fifoDin(15 downto 8)    <= (others=>'0') after tpd;
                  fifoDin(7  downto 0)    <= locAddress    after tpd;
                  fifoSOFin               <= '1'           after tpd;
                  fifoEOFin               <= '0'           after tpd;

                  -- Checksum
                  checkSum(15 downto 8) <= (others=>'0') after tpd;
                  checkSum(7  downto 0) <= locAddress    after tpd;

                  -- Next state
                  curState <= ST_RSP0 after tpd;
               end if;

            -- First word of response
            when ST_RSP0 =>

               if fifoFull = '0' then

                  -- Second word of response
                  fifoDin    <= locReadData(15 downto 0) after tpd;
                  fifoSOFin  <= '0'                      after tpd;
                  fifoEOFin  <= '0'                      after tpd;
                  fifoWr     <= '1'                      after tpd;

                  -- Checksum
                  checkSum <= checkSum + locReadData(15 downto 0) after tpd;

                  -- Next state
                  curState <= ST_RSP1 after tpd;

               else
                  fifoWr     <= '0'                      after tpd;

               end if;

            -- Second word of response
            when ST_RSP1 =>

               if fifoFull = '0' then

                  -- Second word of response
                  fifoDin    <= locReadData(31 downto 16) after tpd;
                  fifoSOFin  <= '0'                       after tpd;
                  fifoEOFin  <= '0'                       after tpd;
                  fifoWr     <= '1'                       after tpd;
                  -- Checksum
                  checkSum <= checkSum + locReadData(31 downto 16) after tpd;

                  -- Next state
                  curState <= ST_RSP2 after tpd;
               else
                  fifoWr     <= '0'                       after tpd;

               end if;

            -- Third word of response
            when ST_RSP2 =>

               if fifoFull = '0' then

                  -- Second word of response
                  fifoDin    <= checkSum after tpd;
                  fifoSOFin  <= '0'      after tpd;
                  fifoEOFin  <= '1'      after tpd;
                  fifoWr     <= '1'      after tpd;
                  curState   <= ST_RSP3  after tpd;
               else
                  fifoWr     <= '0'      after tpd;

               end if;

            -- Last word of response
            when ST_RSP3 =>

               -- Second word of response
               fifoEOFin  <= '0'      after tpd;
               curState   <= ST_IDLE  after tpd;
               fifoWr     <= '0'      after tpd;

            -- Default
            when others=> curState <= ST_IDLE after tpd;
         end case;
      end if;
   end process;

end CmdControl;

