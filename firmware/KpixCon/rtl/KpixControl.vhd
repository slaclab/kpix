-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Kpix Controller
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixControl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the control of the KPIX devices
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 08/12/2007: Added external trigger accept input
-- 09/19/2007: Added raw data control flag.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixControl is 
   port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                       -- 125Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- Kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
      kpixRst       : in    std_logic;                       -- kpix reset

      -- Ddr clock, rest
      ddrClk        : in    std_logic;                       -- 125Mhz ddr clock
      ddrRst        : in    std_logic;                       -- ddr reset

      -- Check sum error output
      checkSumErr   : out   std_logic;                       -- Checksum error flag

      -- Interface to local register controller
      writeData     : in    std_logic_vector(31 downto 0);   -- Write Data
      readData      : out   std_logic_vector(31 downto 0);   -- Read Data
      writeEn       : in    std_logic;                       -- Write strobe
      address       : in    std_logic_vector(7  downto 0);   -- Address select

      -- Core state
      coreState     : out   std_logic_vector(2 downto 0);    -- Core state value

      -- Train Buffer Status
      trainFifoFull : in    std_logic;                       -- Train FIFO is full

      -- Run LED
      kpixRunLed    : out   std_logic;                       -- Kpix RUN LED

      -- Kpix force trigger
      reset         : out   std_logic;                       -- Kpix Reset
      forceTrig     : out   std_logic;                       -- Kpix Force Trigger

      -- IO Ports
      bncInA        : in    std_logic;                       -- BNC Interface A input
      bncInB        : in    std_logic;                       -- BNC Interface B input
      bncOutA       : out   std_logic;                       -- BNC Interface A output
      bncOutB       : out   std_logic;                       -- BNC Interface B output
      nimInA        : in    std_logic;                       -- NIM Interface A input
      nimInB        : in    std_logic;                       -- NIM Interface B input

      -- FIFO Interface for train data
      trainFifoReq  : out   std_logic;                       -- FIFO Write Request
      trainFifoAck  : in    std_logic;                       -- FIFO Write Grant
      trainFifoSOF  : out   std_logic;                       -- FIFO Word SOF
      trainFifoEOF  : out   std_logic;                       -- FIFO Word EOF
      trainFifoWr   : out   std_logic;                       -- FIFO Write Strobe
      trainFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Command FIFO Interface
      cmdFifoData   : in    std_logic_vector(15 downto 0);   -- RX FIFO Data
      cmdFifoSOF    : in    std_logic;                       -- RX FIFO Start of Frame
      cmdFifoWr     : in    std_logic;                       -- RX FIFO Write
      cmdFifoFull   : out   std_logic;                       -- RX FIFO Full
      
      -- Kpix Response FIFO interface
      kpixRspReq    : out   std_logic;                       -- FIFO Write Request
      kpixRspAck    : in    std_logic;                       -- FIFO Write Grant
      kpixRspWr     : out   std_logic;                       -- FIFO Write Request
      kpixRspSOF    : out   std_logic;                       -- FIFO Word SOF
      kpixRspEOF    : out   std_logic;                       -- FIFO Word EOF
      kpixRspData   : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- SRAM 0 interface
      ddr0RdNWr     : out   std_logic;                       -- ddr0 R/W
      ddr0LdL       : out   std_logic;                       -- ddr0 active low Load
      ddr0Data      : inout std_logic_vector(17 downto 0);   -- ddr0 data bus
      ddr0Addr      : out   std_logic_vector(21 downto 0);   -- ddr0 address bus

      -- SRAM 1 interface
      ddr1RdNWr     : out   std_logic;                       -- ddr1 R/W
      ddr1LdL       : out   std_logic;                       -- ddr1 active low Load
      ddr1Data      : inout std_logic_vector(17 downto 0);   -- ddr1 data bus
      ddr1Addr      : out   std_logic_vector(21 downto 0);   -- ddr1 address bus
      
      -- Outgoing serial data lins
      serData       : out   std_logic_vector(31 downto 0);   -- Serial data out
      
      -- Incoming serial data streams
      rspData       : in    std_logic_vector(31 downto 0);   -- Incoming serial data
      
      -- Debug
      csControl1    : inout  std_logic_vector(35 downto 0);  -- Chip Scope Control
      csControl2    : inout  std_logic_vector(35 downto 0);  -- Chip Scope Control
      csControl3    : inout  std_logic_vector(35 downto 0);  -- Chip Scope Control
      csEnable      : in     std_logic_vector(15 downto 0)   -- Chip scope inputs
   );   
end KpixControl;

        
-- Define architecture
architecture KpixControl of KpixControl is


   -- Local signals
   signal trainNum      : array16x32;
   signal trainNumRst   : std_logic;
   signal isRunning     : std_logic;
   signal deadCount     : std_logic_vector(31 downto 0);
   signal deadCountRst  : std_logic;
   signal deadCountExt  : std_logic;
   signal rspErrCount   : std_logic_vector(7  downto 0);
   signal dataErrCount  : array16x8;
   signal parErrRst     : std_logic;
   signal dropData      : std_logic;
   signal rawData       : std_logic;
   signal extAcquire    : std_logic;
   signal extCalibrate  : std_logic;
   signal genAcquire    : std_logic;
   signal genCalibrate  : std_logic;
   signal serDataL      : std_logic;
   signal rspDataL      : std_logic;
   signal bncASel       : std_logic_vector(4  downto 0);
   signal bncBSel       : std_logic_vector(4  downto 0);
   signal cntrlReg      : std_logic_vector(31 downto 0);
   signal extControl    : std_logic_vector(31 downto 0);
   signal trigControl   : std_logic_vector(31 downto 0);
   signal acqDone       : std_logic_vector(15 downto 0);
   signal syncExtern0   : std_logic;
   signal syncExtern1   : std_logic;
   signal syncExtern2   : std_logic;
   signal muxExtern     : std_logic;
   signal extRunning    : std_logic;
   signal extTriggered  : std_logic;
   signal extCount      : std_logic_vector(15 downto 0);
   signal extRecord     : std_logic;
   signal intRspData    : std_logic_vector(31 downto 0);
   signal kpixVer       : std_logic;
   signal kpixBunch     : std_logic_vector(12 downto 0);
   signal calStrobeOut  : std_logic;
   signal statusValue   : array32x32;
   signal statusRx      : std_logic_vector(31 downto 0);
   signal sramSel       : std_logic_vector(1  downto 0);
   signal nxtSel        : std_logic_vector(1  downto 0);
   signal fifoReq       : std_logic_vector(7  downto 0);
   signal fifoAck       : std_logic_vector(31 downto 0);
   signal fifoSOF       : std_logic_vector(7  downto 0);
   signal fifoEOF       : std_logic_vector(7  downto 0);
   signal fifoPad       : std_logic_vector(7  downto 0);
   signal fifoWr        : std_logic_vector(7  downto 0);
   signal fifoData      : array8x32;
   signal sram0Req      : std_logic;
   signal sram0Ack      : std_logic;
   signal sram0SOF      : std_logic;
   signal sram0EOF      : std_logic;
   signal sram0Wr       : std_logic;
   signal sram0Data     : std_logic_vector(15 downto 0);
   signal sram1Req      : std_logic;
   signal sram1Ack      : std_logic;
   signal sram1SOF      : std_logic;
   signal sram1EOF      : std_logic;
   signal sram1Wr       : std_logic;
   signal sram1Data     : std_logic_vector(15 downto 0);

   -- Chip Scope signals
   constant enableChipScope : integer := 0;
   signal   kpixDebug       : array32x64;
   signal   trainDebug      : array8x64;
   signal   sysDebug        : std_logic_vector(63 downto 0);
   signal   debug           : std_logic_vector(63 downto 0);
   signal   csDebug         : std_logic_vector(63 downto 0);
   signal   ddr0Debug       : std_logic_vector(63 downto 0);
   signal   ddr1Debug       : std_logic_vector(63 downto 0);
   signal   pktNum          : std_logic_vector(5  downto 0);
   
begin

   debug <= trainDebug(conv_integer(csEnable(10 downto  8))) when csEnable(7) = '0' else kpixDebug (conv_integer(csEnable(15 downto 11)));
   csDebug <= debug when csEnable(6) = '1' else sysDebug;

   sysDebug (63)           <= sram0EOF;
   sysDebug (62)           <= sram0Ack;
   sysDebug (61)           <= sram0Wr;
   sysDebug (60)           <= sram0Req;
   sysDebug (59 downto 54) <= pktNum(5 downto 0);
   sysDebug (53 downto 52) <= sramSel;
   sysDebug (51)           <= fifoEOF(conv_integer(csEnable(10 downto 8)));
   sysDebug (50)           <= fifoWr(conv_integer(csEnable(10 downto 8)));
   sysDebug (49)           <= fifoAck(conv_integer(csEnable(10 downto 8)));
   sysDebug (48)           <= fifoReq(conv_integer(csEnable(10 downto 8)));
   sysDebug (47 downto 32) <= sram0Data;
   sysDebug (31 downto 0)  <= fifoData(conv_integer(csEnable(10 downto 8)));

   
   chipscope : if (enableChipScope = 1) generate   
      U_TrainData_ila : v5_ila port map (
         CONTROL => csControl1,
         CLK     => sysClk,
         TRIG0   => csDebug
      );
   end generate chipscope;  

   intRspData <= rspData;

   -- Derive kpix reset signal
   reset <= kpixRst;

   -- Connect calib/acquire signals
   genAcquire   <= extAcquire; 
   genCalibrate <= extCalibrate; 


   -- Read data mux
   process ( address, cntrlReg, rspErrCount, dataErrCount, 
             extControl, trigControl, trainNum, deadCount ) begin
      case address is
         when "00001000" => readData <= cntrlReg;
         when "00001001" => readData <= x"0000" & rspErrCount & dataErrCount(0);
         when "00001011" => readData <= trigControl;
         when "00001101" => readData <= deadCount;
         when "00001110" => readData <= extControl;
         when others     => 
            if address(7 downto 4) = 1 then
               readData <= trainNum(conv_integer(address(3 downto 0)));
            else
               readData <= (others=>'0');
            end if;
      end case;
   end process;


   -- write data control
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         cntrlReg     <= (others=>'0') after tpd;
         parErrRst    <= '0'           after tpd;
         extControl   <= (others=>'0') after tpd;
         trigControl  <= (others=>'0') after tpd;
         trainNumRst  <= '0'           after tpd;
         deadCountRst <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- Write strobe
         if writeEn = '1' then
            if address = "00001000" then cntrlReg     <= writeData after tpd; end if;
            if address = "00001001" then parErrRst    <= '1'       after tpd; end if;
            if address = "00001011" then trigControl  <= writeData after tpd; end if;
            if address = "00001100" then trainNumRst  <= '1'       after tpd; end if;
            if address = "00001101" then deadCountRst <= '1'       after tpd; end if;
            if address = "00001110" then extControl   <= writeData after tpd; end if;
         else
            parErrRst    <= '0' after tpd;
            trainNumRst  <= '0' after tpd;
            deadCountRst <= '0' after tpd;
         end if;
      end if;
   end process;

   -- Register bits
   kpixVer     <= cntrlReg(28);
   bncBSel     <= cntrlReg(25 downto 21);
   bncASel     <= cntrlReg(20 downto 16);
   rawData     <= cntrlReg(5);
   dropData    <= cntrlReg(4);

   -- Led output
   isRunning  <= extRunning; 
   kpixRunLed <= isRunning;


   -- Dead time counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         deadCount <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then

         -- Reset dead count
         if deadCountRst = '1' then
            deadCount <= (others=>'0') after tpd;

         -- Dead count increment, auto run
         elsif deadCountExt = '1' then
            deadCount <= deadCount + 1 after tpd;
         end if;
      end if;
   end process;


   -- Choose external trigger source
   process ( extControl, bncInA, bncInB, nimInA, nimInB ) begin
      case extControl(22 downto 20) is
         when "000"  => extRecord <= '0';
         when "001"  => extRecord <= not nimInA;
         when "010"  => extRecord <= not nimInB;
         when "011"  => extRecord <= not bncInA;
         when "100"  => extRecord <= not bncInB;
         when "101"  => extRecord <= calStrobeOut;
         when others => extRecord <= '0';
      end case;
   end process;


   -- Choose run control source
   process ( extControl, bncInA, bncInB, nimInA, nimInB ) begin
      case extControl(18 downto 16) is
         when "000"  => muxExtern <= '0';
         when "001"  => muxExtern <= not nimInA;
         when "010"  => muxExtern <= not nimInB;
         when "011"  => muxExtern <= not bncInA;
         when "100"  => muxExtern <= not bncInB;
         when others => muxExtern <= '0';
      end case;
   end process;


   -- State machine for external run control
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         extAcquire   <= '0'           after tpd;
         extCalibrate <= '0'           after tpd;
         syncExtern0  <= '0'           after tpd;
         syncExtern1  <= '0'           after tpd;
         syncExtern2  <= '0'           after tpd;
         extRunning   <= '0'           after tpd;
         extCount     <= (others=>'0') after tpd;
         deadCountExt <= '0'           after tpd;
         extTriggered <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- Double sync input
         syncExtern0 <= muxExtern   after tpd;
         syncExtern1 <= syncExtern0 after tpd;
         syncExtern2 <= syncExtern1 after tpd;

         -- Running flag
         if extControl(18 downto 16) = 0 then
            extRunning <= '0' after tpd;
         else
            extRunning <= '1' after tpd;
         end if;

         -- Currently not triggered
         if extTriggered = '0' then

            -- Reset count
            extCount     <= (others=>'0') after tpd;
            extAcquire   <= '0'           after tpd;
            extCalibrate <= '0'           after tpd;

            -- Run is triggered, catch rising edge
            if syncExtern1 = '1' and syncExtern2 = '0' then

               -- Is FIFO ready?
               if trainFifoFull = '0' then
                  extTriggered <= '1' after tpd;
                  deadCountExt <= '0' after tpd;

               -- Fifo is not ready, skip and increment dead count
               else
                  deadCountExt <= '1' after tpd;
               end if;
            else
               deadCountExt <= '0' after tpd;
            end if;

         -- Delay is running
         else

            -- Count until delay matches, then send command
            if extCount = extControl(15 downto 0) then
               extAcquire   <= '1'            after tpd;
               extCalibrate <= extControl(19) after tpd;
               extTriggered <= '0'            after tpd;
            end if;

            -- Run counter
            extCount <= extCount + 1 after tpd;

         end if;
      end if;
   end process;

   -- Combinatorial SRAM Selector
   process (sram0Req, sram1Req, sram0EOF, sram1EOF, sram0SOF, sram1SOF, trainFifoAck,
            sram0Wr, sram0Data, sram1Wr, sram1Data, sramSel ) begin
      case sramSel is
         when "11" =>
            sram0Ack      <= '0';
            sram1Ack      <= '0';
            trainFifoSOF  <= '0';
            trainFifoEOF  <= '0';
            trainFifoWr   <= '0';
            trainFifoData <= (OTHERS =>'0');
            
            if sram0Req = '1' then
               nxtSel       <= "00";
               trainFifoReq <= '1';
            elsif sram1Req = '1' then
               nxtSel      <= "01";
               trainFifoReq <= '1';
            else
               nxtSel       <= "11";
               trainFifoReq <= '0';
            end if;
            
         when "00" =>
            sram0Ack      <= trainFifoAck;
            sram1Ack      <= '0';
            trainFifoSOF  <= sram0SOF;
            trainFifoEOF  <= sram0EOF;
            trainFifoWr   <= sram0Wr;
            trainFifoData <= sram0Data;
            
            if sram0EOF = '0' then
               nxtSel       <= "00";
               trainFifoReq <= '1';
            else
               nxtSel       <= "11";
               trainFifoReq <= '0';
            end if;
            
         when "01" =>
            sram0Ack      <= '0';
            sram1Ack      <= trainFifoAck;
            trainFifoSOF  <= sram1SOF;
            trainFifoEOF  <= sram1EOF;
            trainFifoWr   <= sram1Wr;
            trainFifoData <= sram1Data;
            
            if sram1EOF = '0' then
               nxtSel       <= "01";
               trainFifoReq <= '1';
            else
               nxtSel       <= "11";
               trainFifoReq <= '0';
            end if;
            
         when others =>
            nxtSel        <= "11";
            sram0Ack      <= '0';
            sram1Ack      <= '0';
            trainFifoSOF  <= '0';
            trainFifoEOF  <= '0';
            trainFifoWr   <= '0';
            trainFifoData <= (OTHERS =>'0');
            trainFifoReq  <= '0';
      end case;
   end process;
   
   process (sysClk, sysRst) begin
      if sysRst = '1' then
         sramSel <= "11"          after tpd;
--          pktNum  <= (OTHERS=>'0') after tpd;
      elsif rising_edge(sysClk) then
         sramSel <= nxtSel after tpd;
         
--          if sram0EOF = '1' or sram1EOF = '1' then
--             pktNum <= pktNum + 1;
--          end if;

      end if;
   end process;
   
   -- Local Kpix Core
   U_KpixLocal: KpixLocal port map (
      kpixClk     => kpixClk,    kpixRst      => kpixRst,
      bncOutA     => bncOutA,
      bncOutB     => bncOutB,    bncASel      => bncASel,
      bncBSel     => bncBSel,    reset        => kpixRst,
      serData     => serDataL,   rspData      => rspDataL,
      forceTrig   => forceTrig,  trigControl  => trigControl,
      nimInA      => nimInA,     nimInB       => nimInB,
      bncInA      => bncInA,     bncInB       => bncInB,
      kpixVer     => kpixVer,    coreState    => coreState,
      kpixBunch   => kpixBunch,  calStrobeOut => calStrobeOut
   );

   -- Response data processor
   U_ResponseData: KpixRespData port map (
      sysClk       => sysClk,         sysRst        => sysRst,
      kpixClk      => kpixClk,        kpixRst       => kpixRst,
      kpixRspReq   => kpixRspReq,     kpixRspAck    => kpixRspAck,
      kpixRspSOF   => kpixRspSOF,     kpixRspData   => kpixRspData,
      kpixRspEOF   => kpixRspEOF,     kpixRspWr     => kpixRspWr,
      kpixVer      => kpixVer,
      parErrCount  => rspErrCount,    parErrRst     => parErrRst,
      rspData      => intRspData,     rspDataL      => rspDataL,
      statusValue  => statusValue,    statusRx      => statusRx,
      csControl    => csControl2
   );

   -- Train 0 data processor
   U_TrainData0: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(0),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(0),
      fifoAck      => fifoAck(0),             fifoSOF     => fifoSOF(0),
      fifoWr       => fifoWr(0),              fifoData    => fifoData(0),
      fifoPad      => fifoPad(0),             fifoEOF     => fifoEOF(0),
      parErrCount  => dataErrCount(0),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(0),
      rspDataB     => intRspData(1),          rspDataC    => intRspData(2),
      rspDataD     => intRspData(3),          trainNumRst => trainNumRst,
      acqDone      => acqDone(0),             extRecord   => extRecord,
      serialNum    => "0000",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(0),         statusRxA   => statusRx(0),
      statusValueB => statusValue(1),         statusRxB   => statusRx(1),
      statusValueC => statusValue(2),         statusRxC   => statusRx(2),
      statusValueD => statusValue(3),         statusRxD   => statusRx(3),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(0),
      kpixDebugA   => kpixDebug(0),           kpixDebugB  => kpixDebug(1),
      kpixDebugC   => kpixDebug(2),           kpixDebugD  => kpixDebug(3)
   );

   -- Train 1 data processor
   U_TrainData1: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(1),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(1),
      fifoAck      => fifoAck(1),             fifoSOF     => fifoSOF(1),
      fifoWr       => fifoWr(1),              fifoData    => fifoData(1),
      fifoPad      => fifoPad(1),             fifoEOF     => fifoEOF(1),
      parErrCount  => dataErrCount(1),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(4),
      rspDataB     => intRspData(5),          rspDataC    => intRspData(6),
      rspDataD     => intRspData(7),          trainNumRst => trainNumRst,
      acqDone      => acqDone(1),             extRecord   => extRecord,
      serialNum    => "0001",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(4),         statusRxA   => statusRx(4),
      statusValueB => statusValue(5),         statusRxB   => statusRx(5),
      statusValueC => statusValue(6),         statusRxC   => statusRx(6),
      statusValueD => statusValue(7),         statusRxD   => statusRx(7),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(1),
      kpixDebugA   => kpixDebug(4),           kpixDebugB  => kpixDebug(5),
      kpixDebugC   => kpixDebug(6),           kpixDebugD  => kpixDebug(7)
   );

   -- Train 2 data processor
   U_TrainData2: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(2),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(2),
      fifoAck      => fifoAck(2),             fifoSOF     => fifoSOF(2),
      fifoWr       => fifoWr(2),              fifoData    => fifoData(2),
      fifoPad      => fifoPad(2),             fifoEOF     => fifoEOF(2),
      parErrCount  => dataErrCount(2),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(8),
      rspDataB     => intRspData(9),          rspDataC    => intRspData(10),
      rspDataD     => intRspData(11),         trainNumRst => trainNumRst,
      acqDone      => acqDone(2),             extRecord   => extRecord,
      serialNum    => "0010",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(8),         statusRxA   => statusRx(8),
      statusValueB => statusValue(9),         statusRxB   => statusRx(9),
      statusValueC => statusValue(10),        statusRxC   => statusRx(10),
      statusValueD => statusValue(11),        statusRxD   => statusRx(11),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(2),
      kpixDebugA   => kpixDebug(8),           kpixDebugB  => kpixDebug(9),
      kpixDebugC   => kpixDebug(10),          kpixDebugD  => kpixDebug(11)
   );
   
   -- Train 3 data processor
   U_TrainData3: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(3),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(3),
      fifoAck      => fifoAck(3),             fifoSOF     => fifoSOF(3),
      fifoWr       => fifoWr(3),              fifoData    => fifoData(3),
      fifoPad      => fifoPad(3),             fifoEOF     => fifoEOF(3),
      parErrCount  => dataErrCount(3),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(12),
      rspDataB     => intRspData(13),         rspDataC    => intRspData(14),
      rspDataD     => intRspData(15),         trainNumRst => trainNumRst,
      acqDone      => acqDone(3),             extRecord   => extRecord,
      serialNum    => "0011",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(12),        statusRxA   => statusRx(12),
      statusValueB => statusValue(13),        statusRxB   => statusRx(13),
      statusValueC => statusValue(14),        statusRxC   => statusRx(14),
      statusValueD => statusValue(15),        statusRxD   => statusRx(15),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(3),
      kpixDebugA   => kpixDebug(12),          kpixDebugB  => kpixDebug(13),
      kpixDebugC   => kpixDebug(14),          kpixDebugD  => kpixDebug(15)
   );

   -- SRAM 0 Interface
   U_DDR0: KpixDdrData port map (
      sysClk       => sysClk,               sysRst       => sysRst,
      ddrClk       => ddrClk,               ddrRst       => ddrRst,
      ddrRdNWr     => ddr0RdNWr,            ddrLdL       => ddr0LdL,
      ddrData      => ddr0Data,             ddrAddr      => ddr0Addr,
      sramReq      => sram0Req,             sramAck      => sram0Ack,
      sramSOF      => sram0SOF,             sramEOF      => sram0EOF,
      sramWr       => sram0Wr,              sramData     => sram0Data,
      trainReq     => fifoReq (3 downto 0), trainAck     => fifoAck(3 downto 0),
      trainSOF     => fifoSOF (3 downto 0), trainEOF     => fifoEOF(3 downto 0),
      trainPad     => fifoPad (3 downto 0), trainWr      => fifoWr (3 downto 0),
      trainData(0) => fifoData(0),          trainData(1) => fifoData(1),
      trainData(2) => fifoData(2),          trainData(3) => fifoData(3),
      csControl1   => csControl1,           csControl2   => csControl2,
      csEnable     => csEnable
   );

   -- Train 4 data processor
   U_TrainData4: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(4),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(4),
      fifoAck      => fifoAck(4),             fifoSOF     => fifoSOF(4),
      fifoWr       => fifoWr(4),              fifoData    => fifoData(4),
      fifoPad      => fifoPad(4),             fifoEOF     => fifoEOF(4),
      parErrCount  => dataErrCount(4),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(16),
      rspDataB     => intRspData(17),         rspDataC    => intRspData(18),
      rspDataD     => intRspData(19),         trainNumRst => trainNumRst,
      acqDone      => acqDone(4),             extRecord   => extRecord,
      serialNum    => "0100",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(16),        statusRxA   => statusRx(16),
      statusValueB => statusValue(17),        statusRxB   => statusRx(17),
      statusValueC => statusValue(18),        statusRxC   => statusRx(18),
      statusValueD => statusValue(19),        statusRxD   => statusRx(19),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(4),
      kpixDebugA   => kpixDebug(16),          kpixDebugB  => kpixDebug(17),
      kpixDebugC   => kpixDebug(18),          kpixDebugD  => kpixDebug(19)
   );

   -- Train 5 data processor
   U_TrainData5: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(5),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(5),
      fifoAck      => fifoAck(5),             fifoSOF     => fifoSOF(5),
      fifoWr       => fifoWr(5),              fifoData    => fifoData(5),
      fifoPad      => fifoPad(5),             fifoEOF     => fifoEOF(5),
      parErrCount  => dataErrCount(5),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(20),
      rspDataB     => intRspData(21),         rspDataC    => intRspData(22),
      rspDataD     => intRspData(23),         trainNumRst => trainNumRst,
      acqDone      => acqDone(5),             extRecord   => extRecord,
      serialNum    => "0101",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(20),        statusRxA   => statusRx(20),
      statusValueB => statusValue(21),        statusRxB   => statusRx(21),
      statusValueC => statusValue(22),        statusRxC   => statusRx(22),
      statusValueD => statusValue(23),        statusRxD   => statusRx(23),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(5),
      kpixDebugA   => kpixDebug(20),          kpixDebugB  => kpixDebug(21),
      kpixDebugC   => kpixDebug(22),          kpixDebugD  => kpixDebug(23)
   );

   -- Train 6 data processor
   U_TrainData6: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(6),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(6),
      fifoAck      => fifoAck(6),             fifoSOF     => fifoSOF(6),
      fifoWr       => fifoWr(6),              fifoData    => fifoData(6),
      fifoPad      => fifoPad(6),             fifoEOF     => fifoEOF(6),
      parErrCount  => dataErrCount(6),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(24),
      rspDataB     => intRspData(25),         rspDataC    => intRspData(26),
      rspDataD     => intRspData(27),         trainNumRst => trainNumRst,
      acqDone      => acqDone(6),             extRecord   => extRecord,
      serialNum    => "0110",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(24),        statusRxA   => statusRx(24),
      statusValueB => statusValue(25),        statusRxB   => statusRx(25),
      statusValueC => statusValue(26),        statusRxC   => statusRx(26),
      statusValueD => statusValue(27),        statusRxD   => statusRx(27),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(6),
      kpixDebugA   => kpixDebug(24),          kpixDebugB  => kpixDebug(25),
      kpixDebugC   => kpixDebug(26),          kpixDebugD  => kpixDebug(27)
   );
   
   -- Train 7 data processor
   U_TrainData7: KpixTrainData port map (
      sysClk       => sysClk,                 sysRst      => sysRst,
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum(7),            isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => fifoReq(7),
      fifoAck      => fifoAck(7),             fifoSOF     => fifoSOF(7),
      fifoWr       => fifoWr(7),              fifoData    => fifoData(7),
      fifoPad      => fifoPad(7),             fifoEOF     => fifoEOF(7),
      parErrCount  => dataErrCount(7),        parErrRst   => parErrRst,
      dropData     => dropData,               rspDataA    => intRspData(28),
      rspDataB     => intRspData(29),         rspDataC    => intRspData(30),
      rspDataD     => intRspData(31),         trainNumRst => trainNumRst,
      acqDone      => acqDone(7),             extRecord   => extRecord,
      serialNum    => "0111",
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValue(28),        statusRxA   => statusRx(28),
      statusValueB => statusValue(29),        statusRxB   => statusRx(29),
      statusValueC => statusValue(30),        statusRxC   => statusRx(30),
      statusValueD => statusValue(31),        statusRxD   => statusRx(31),
      kpixBunch    => kpixBunch,              trainDebug  => trainDebug(7),
      kpixDebugA   => kpixDebug(28),          kpixDebugB  => kpixDebug(29),
      kpixDebugC   => kpixDebug(30),          kpixDebugD  => kpixDebug(31)
   );

   -- SRAM 1 Interface
   U_DDR1: KpixDdrData port map (
      sysClk       => sysClk,               sysRst       => sysRst,
      ddrClk       => ddrClk,               ddrRst       => ddrRst,
      ddrRdNWr     => ddr1RdNWr,            ddrLdL       => ddr1LdL,
      ddrData      => ddr1Data,             ddrAddr      => ddr1Addr,
      sramReq      => sram1Req,             sramAck      => sram1Ack,
      sramSOF      => sram1SOF,             sramEOF      => sram1EOF,
      sramWr       => sram1Wr,              sramData     => sram1Data,
      trainReq     => fifoReq (7 downto 4), trainAck     => fifoAck(7 downto 4),
      trainSOF     => fifoSOF (7 downto 4), trainEOF     => fifoEOF(7 downto 4),
      trainPad     => fifoPad (7 downto 4), trainWr      => fifoWr (7 downto 4),
      trainData(0) => fifoData(4),          trainData(1) => fifoData(5),
      trainData(2) => fifoData(6),          trainData(3) => fifoData(7),
      csEnable     => csEnable
   );

   -- Kpix command transmitter
   U_CmdTx: KpixCmdTx port map (
      sysClk20    => sysClk,      syncRst      => sysRst,
      kpixClk     => kpixClk,     kpixRst      => kpixRst,
      fifoData    => cmdFifoData, fifoSOF      => cmdFifoSOF,
      fifoWr      => cmdFifoWr,   fifoFull     => cmdFifoFull,
      genAcquire  => genAcquire,  genCalibrate => genCalibrate,
      serData     => serData,     serDataL     => serDataL,
      checkSumErr => checkSumErr, kpixVer      => kpixVer,
      csControl   => csControl1
   );
   
end KpixControl;