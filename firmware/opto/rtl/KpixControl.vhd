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

entity KpixControl is 
   port ( 

      -- System clock, reset
      sysClk        : in    std_logic;                       -- 20Mhz system clock
      sysRst        : in    std_logic;                       -- System reset

      -- Kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz system clock
      kpixRst       : in    std_logic;                       -- System reset

      -- Check sum error output
      checkSumErr   : out   std_logic;                       -- Checksum error flag

      -- Interface to local register controller
      writeData     : in    std_logic_vector(31 downto 0);   -- Write Data
      readData      : out   std_logic_vector(31 downto 0);   -- Read Data
      writeEn       : in    std_logic;                       -- Write strobe
      address       : in    std_logic_vector(7  downto 0);   -- Address select

      -- Core state
      coreState     : out   std_logic_vector(3 downto 0);    -- Core state value

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
      trainFifoWr   : out   std_logic;                       -- FIFO Write Strobe
      trainFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Command FIFO Interface
      cmdFifoData   : in    std_logic_vector(15 downto 0);   -- RX FIFO Data
      cmdFifoSOF    : in    std_logic;                       -- RX FIFO Start of Frame
      cmdFifoWr     : in    std_logic;                       -- RX FIFO Write
      cmdFifoFull   : out   std_logic;                       -- RX FIFO Full

      -- Kpix 0 response FIFO interface
      kpixAFifoReq  : out   std_logic;                       -- FIFO Write Request
      kpixAFifoAck  : in    std_logic;                       -- FIFO Write Grant
      kpixAFifoSOF  : out   std_logic;                       -- FIFO Word SOF
      kpixAFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix 1 response FIFO interface
      kpixBFifoReq  : out   std_logic;                       -- FIFO Write Request
      kpixBFifoAck  : in    std_logic;                       -- FIFO Write Grant
      kpixBFifoSOF  : out   std_logic;                       -- FIFO Word SOF
      kpixBFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix 2 response FIFO interface
      kpixCFifoReq  : out   std_logic;                       -- FIFO Write Request
      kpixCFifoAck  : in    std_logic;                       -- FIFO Write Grant
      kpixCFifoSOF  : out   std_logic;                       -- FIFO Word SOF
      kpixCFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Kpix 3 response FIFO interface
      kpixDFifoReq  : out   std_logic;                       -- FIFO Write Request
      kpixDFifoAck  : in    std_logic;                       -- FIFO Write Grant
      kpixDFifoSOF  : out   std_logic;                       -- FIFO Word SOF
      kpixDFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Outgoing serial data lins
      serDataA      : out   std_logic;                       -- Serial data out A
      serDataB      : out   std_logic;                       -- Serial data out B
      serDataC      : out   std_logic;                       -- Serial data out C

      -- Incoming serial data streams
      rspDataA    : in    std_logic;                         -- Incoming serial data A
      rspDataB    : in    std_logic;                         -- Incoming serial data B
      rspDataC    : in    std_logic                          -- Incoming serial data C
   );
end KpixControl;


-- Define architecture
architecture KpixControl of KpixControl is

   -- Train Data Processor
   component KpixTrainData
      port (
         kpixClk      : in    std_logic;                       -- 20Mhz system clock
         kpixRst      : in    std_logic;                       -- System reset
         trainNum     : out   std_logic_vector(31 downto 0);   -- Train sequence number
         trainNumRst  : in    std_logic;                       -- Train sequence number reset
         acqDone      : out   std_logic;                       -- Kpix Cycle Complete
         isRunning    : in    std_logic;                       -- Sequence is running
         deadCount    : in    std_logic_vector(12 downto 0);   -- Inter-train dead count
         extRecord    : in    std_logic;                       -- External trigger accept input
         fifoReq      : out   std_logic;                       -- FIFO Write Request
         fifoAck      : in    std_logic;                       -- FIFO Write Grant
         fifoSOF      : out   std_logic;                       -- FIFO Word SOF
         fifoWr       : out   std_logic;                       -- FIFO Write Strobe
         fifoData     : out   std_logic_vector(15 downto 0);   -- FIFO Word
         parErrCount  : out   std_logic_vector(7  downto 0);   -- Parity error count
         parErrRst    : in    std_logic;                       -- Parity error count reset
         dropData     : in    std_logic;                       -- Drop data control
         rawData      : in    std_logic;                       -- Raw data enable
         kpixEnA      : in    std_logic;                       -- KPIX A Enable
         kpixEnB      : in    std_logic;                       -- KPIX B Enable
         kpixEnC      : in    std_logic;                       -- KPIX C Enable
         rspDataA     : in    std_logic;                       -- Incoming serial data A
         rspDataB     : in    std_logic;                       -- Incoming serial data B
         rspDataC     : in    std_logic;                       -- Incoming serial data C
         kpixVer      : in    std_logic;                       -- Kpix Version
         statusValueA : in    std_logic_vector(31 downto 0);
         statusRxA    : in    std_logic;
         statusValueB : in    std_logic_vector(31 downto 0);
         statusRxB    : in    std_logic;
         statusValueC : in    std_logic_vector(31 downto 0);
         statusRxC    : in    std_logic;
         kpixBunch    : in    std_logic_vector(12 downto 0)    -- Bunch count value
      );
   end component;

   -- Kpix Serial Command Transmitter
   component KpixCmdTx
      port (
         sysClk20      : in    std_logic;                     -- 20Mhz system clock
         syncRst       : in    std_logic;                     -- System reset
         kpixClk       : in    std_logic;                     -- Kpix Clock
         kpixRst       : in    std_logic;                     -- Kpix Reset
         checkSumErr   : out   std_logic;                     -- Checksum error flag
         fifoData      : in    std_logic_vector(15 downto 0); -- RX FIFO Data
         fifoSOF       : in    std_logic;                     -- RX FIFO Start of Frame
         fifoWr        : in    std_logic;                     -- RX FIFO Write
         fifoFull      : out   std_logic;                     -- RX FIFO Full
         genAcquire    : in    std_logic;                     -- Force command acquire
         genCalibrate  : in    std_logic;                     -- Force command calibrate
         serDataA      : out   std_logic;                     -- Serial data out A
         serDataB      : out   std_logic;                     -- Serial data out B
         serDataC      : out   std_logic;                     -- Serial data out C
         serDataD      : out   std_logic                      -- Serial data out D
      );
   end component;

   -- Kpix Response Processor
   component KpixRspRx
      port (
         kpixClk     : in    std_logic;                       -- 20Mhz system clock
         kpixRst     : in    std_logic;                       -- System reset
         fifoReq     : out   std_logic;                       -- FIFO Write Request
         fifoAck     : in    std_logic;                       -- FIFO Write Grant
         fifoSOF     : out   std_logic;                       -- FIFO Word SOF
         fifoData    : out   std_logic_vector(15 downto 0);   -- FIFO Word
         parError    : out   std_logic;                       -- Parity error detected
         kpixAddr    : in    std_logic_vector(1  downto 0);   -- Kpix address
         kpixEnable  : in    std_logic;                       -- Kpix Enable
         rspData     : in    std_logic;                       -- Incoming serial data
         statusValue : out   std_logic_vector(31 downto 0);   -- KPIX status register
         statusRx    : out   std_logic                        -- KPIX status received
      );
   end component;

   -- Local KPIX Core
   component KpixLocal
      port (
         kpixClk       : in    std_logic;                       -- 20Mhz system clock
         kpixRst       : in    std_logic;                       -- System reset
         bncOutA       : out   std_logic;                       -- BNC Interface A output
         bncOutB       : out   std_logic;                       -- BNC Interface B output
         bncASel       : in    std_logic_vector(4 downto 0);    -- BNC Output A Select
         bncBSel       : in    std_logic_vector(4 downto 0);    -- BNC Output B Select
         nimInA        : in    std_logic;                       -- NIM Interface A input
         nimInB        : in    std_logic;                       -- NIM Interface B input
         bncInA        : in    std_logic;                       -- BNC Interface A input
         bncInB        : in    std_logic;                       -- BNC Interface B input
         reset         : in    std_logic;                       -- Kpix reset
         serData       : in    std_logic;                       -- Command data in
         coreState     : out   std_logic_vector(3 downto 0);    -- Core state value
         rspData       : out   std_logic;                       -- Response Data out
         forceTrig     : out   std_logic;                       -- Force trigger signal
         trigControl   : in    std_logic_vector(31 downto 0);   -- Trigger control register
         kpixBunch     : out   std_logic_vector(12 downto 0);   -- Bunch count value
         calStrobeOut  : out   std_logic
      );
   end component;


   -- Local signals
   signal trainNum      : std_logic_vector(31 downto 0);
   signal trainNumRst   : std_logic;
   signal isRunning     : std_logic;
   signal deadCount     : std_logic_vector(31 downto 0);
   signal deadCountRst  : std_logic;
   signal deadCountExt  : std_logic;
   signal parErrCount   : std_logic_vector(7  downto 0);
   signal dataErrCount  : std_logic_vector(7  downto 0);
   signal parErrRst     : std_logic;
   signal dropData      : std_logic;
   signal rawData       : std_logic;
   signal kpixEnA       : std_logic;
   signal kpixEnB       : std_logic;
   signal kpixEnC       : std_logic;
   signal kpixEnD       : std_logic;
   signal extAcquire    : std_logic;
   signal extCalibrate  : std_logic;
   signal genAcquire    : std_logic;
   signal genCalibrate  : std_logic;
   signal parErrorA     : std_logic;
   signal parErrorB     : std_logic;
   signal parErrorC     : std_logic;
   signal parErrorD     : std_logic;
   signal serDataD      : std_logic;
   signal rspDataD      : std_logic;
   signal bncASel       : std_logic_vector(4  downto 0);
   signal bncBSel       : std_logic_vector(4  downto 0);
   signal cntrlReg      : std_logic_vector(31 downto 0);
   signal extControl    : std_logic_vector(31 downto 0);
   signal trigControl   : std_logic_vector(31 downto 0);
   signal acqDone       : std_logic;
   signal syncExtern0   : std_logic;
   signal syncExtern1   : std_logic;
   signal syncExtern2   : std_logic;
   signal muxExtern     : std_logic;
   signal extRunning    : std_logic;
   signal extTriggered  : std_logic;
   signal extCount      : std_logic_vector(15 downto 0);
   signal extRecord     : std_logic;
   signal intRspDataA   : std_logic;
   signal intRspDataB   : std_logic;
   signal intRspDataC   : std_logic;
   signal kpixVer       : std_logic;
   signal statusValueA  : std_logic_vector(31 downto 0);
   signal statusRxA     : std_logic;
   signal statusValueB  : std_logic_vector(31 downto 0);
   signal statusRxB     : std_logic;
   signal statusValueC  : std_logic_vector(31 downto 0);
   signal statusRxC     : std_logic;
   signal kpixBunch     : std_logic_vector(12 downto 0);
   signal calStrobeOut  : std_logic; 


   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Register incoming response, pos edge
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intRspDataA <= '0' after tpd;
         intRspDataB <= '0' after tpd;
         intRspDataC <= '0' after tpd;
      elsif rising_edge(kpixClk) then
         intRspDataA <= rspDataA after tpd;
         intRspDataB <= rspDataB after tpd;
         intRspDataC <= rspDataC after tpd;
      end if;
   end process;

   -- Derice kpix reset signal
   reset <= kpixRst;

   -- Connect calib/acquire signals
   genAcquire   <= extAcquire; 
   genCalibrate <= extCalibrate; 


   -- Read data mux
   process ( address, cntrlReg, parErrCount, dataErrCount, 
             extControl, trigControl, trainNum, deadCount ) begin
      case address is
         when "00001000" => readData <= cntrlReg;
         when "00001001" => readData <= x"0000" & parErrCount & dataErrCount;
         when "00001011" => readData <= trigControl;
         when "00001100" => readData <= trainNum;
         when "00001101" => readData <= deadCount;
         when "00001110" => readData <= extControl;
         when others     => readData <= (others=>'0');
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
   kpixEnD     <= not cntrlReg(3);
   kpixEnC     <= not cntrlReg(2);
   kpixEnB     <= not cntrlReg(1);
   kpixEnA     <= not cntrlReg(0);


   -- Response error counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         parErrCount <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then
         if parErrRst = '1' then
            parErrCount <= (others=>'0') after tpd;
         elsif (parErrCount /= 255 and (parErrorA = '1' or 
            parErrorB = '1' or parErrorC = '1' or parErrorD = '1')) then
               parErrCount <= parErrCount + 1 after tpd;
         end if;
      end if;
   end process;


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


   -- Local Kpix Core
   U_KpixLocal: KpixLocal port map (
      kpixClk     => kpixClk,    kpixRst      => kpixRst,
      bncOutA     => bncOutA,
      bncOutB     => bncOutB,    bncASel      => bncASel,
      bncBSel     => bncBSel,    reset        => kpixRst,
      serData     => serDataD,   rspData      => rspDataD,
      forceTrig   => forceTrig,  trigControl  => trigControl,
      nimInA      => nimInA,     nimInB       => nimInB,
      bncInA      => bncInA,     bncInB       => bncInB,
      coreState    => coreState,
      kpixBunch   => kpixBunch,  calStrobeOut => calStrobeOut
   );


   -- Train data processor
   U_TrainData: KpixTrainData port map (
      kpixClk      => kpixClk,                kpixRst     => kpixRst,
      trainNum     => trainNum,               isRunning   => isRunning,
      deadCount    => deadCount(12 downto 0), fifoReq     => trainFifoReq,
      fifoAck      => trainFifoAck,           fifoSOF     => trainFifoSOF,
      fifoWr       => trainFifoWr,            fifoData    => trainFifoData,
      parErrCount  => dataErrCount,           parErrRst   => parErrRst,
      dropData     => dropData,               kpixEnA     => kpixEnA,
      kpixEnB      => kpixEnB,                kpixEnC     => kpixEnC,
      rspDataA     => intRspDataA,            rspDataB    => intRspDataB,
      rspDataC     => intRspDataC,            trainNumRst => trainNumRst,
      acqDone      => acqDone,                extRecord   => extRecord,
      rawData      => rawData,                kpixVer     => kpixVer,
      statusValueA => statusValueA,           statusRxA   => statusRxA,
      statusValueB => statusValueB,           statusRxB   => statusRxB,
      statusValueC => statusValueC,           statusRxC   => statusRxC,
      kpixBunch    => kpixBunch
   );


   -- Kpix command transmitter
   U_CmdTx: KpixCmdTx port map (
      sysClk20    => sysClk,      syncRst      => sysRst,
      kpixClk     => kpixClk,     kpixRst      => kpixRst,
      fifoData    => cmdFifoData, fifoSOF      => cmdFifoSOF,
      fifoWr      => cmdFifoWr,   fifoFull     => cmdFifoFull,
      genAcquire  => genAcquire,  genCalibrate => genCalibrate,
      serDataA    => serDataA,    serDataB     => serDataB,
      serDataC    => serDataC,    serDataD     => serDataD,
      checkSumErr => checkSumErr
   );


   -- Kpix A Response Processor
   U_RespRxA: KpixRspRx port map (
      kpixClk    => kpixClk,      kpixRst     => kpixRst,
      fifoReq    => kpixAFifoReq, fifoAck     => kpixAFifoAck,
      fifoSOF    => kpixAFifoSOF, fifoData    => kpixAFifoData,
      parError   => parErrorA,    kpixAddr    => "00",
      kpixEnable => kpixEnA,      rspData     => intRspDataA,
      statusValue => statusValueA,
      statusRx   => statusRxA
   );


   -- Kpix B Response Processor
   U_RespRxB: KpixRspRx port map (
      kpixClk    => kpixClk,      kpixRst    => kpixRst,
      fifoReq    => kpixBFifoReq, fifoAck    => kpixBFifoAck,
      fifoSOF    => kpixBFifoSOF, fifoData   => kpixBFifoData,
      parError   => parErrorB,    kpixAddr   => "01",
      kpixEnable => kpixEnB,      rspData    => intRspDataB,
      statusValue => statusValueB,
      statusRx   => statusRxB
   );


   -- Kpix C Response Processor
   U_RespRxC: KpixRspRx port map (
      kpixClk    => kpixClk,      kpixRst    => kpixRst,
      fifoReq    => kpixCFifoReq, fifoAck    => kpixCFifoAck,
      fifoSOF    => kpixCFifoSOF, fifoData   => kpixCFifoData,
      parError   => parErrorC,    kpixAddr   => "10",
      kpixEnable => kpixEnC,      rspData    => intRspDataC,
      statusValue => statusValueC,
      statusRx   => statusRxC
   );


   -- Kpix D Response Processor
   U_RespRxD: KpixRspRx port map (
      kpixClk    => kpixClk,      kpixRst     => kpixRst,
      fifoReq    => kpixDFifoReq, fifoAck     => kpixDFifoAck,
      fifoSOF    => kpixDFifoSOF, fifoData    => kpixDFifoData,
      parError   => parErrorD,    kpixAddr    => "11",
      kpixEnable => kpixEnD,      rspData     => rspDataD,
      statusValue => open,
      statusRx   => open
   );

end KpixControl;

