-------------------------------------------------------------------------------
-- Title         : KpixCon Client, Core Package File
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : KpixConPkg.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 1/27/2011
-------------------------------------------------------------------------------
-- Description:
-- Core package file for general purpose KpixCon firmware.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 1/27/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
LIBRARY Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package KpixConPkg is

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

   -- Custom arrays
   type array16x8  is array (15 downto 0) of STD_LOGIC_VECTOR (7  downto 0);
   type array4x32  is array (3  downto 0) of STD_LOGIC_VECTOR (31 downto 0);
   type array8x32  is array (7  downto 0) of STD_LOGIC_VECTOR (31 downto 0);
   type array16x32 is array (15 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
   type array4x64  is array (3  downto 0) of STD_LOGIC_VECTOR (63 downto 0);
   type array8x64  is array (7  downto 0) of STD_LOGIC_VECTOR (63 downto 0);
   type array32x16 is array (31 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
   type array32x32 is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
   type array32x64 is array (31 downto 0) of STD_LOGIC_VECTOR (63 downto 0);
   
   -- Custom Functions
   function conv_32to5 (value : std_logic_vector(31 downto 0)) return std_logic_vector;
   function conv_5to32 (value : std_logic_vector(4  downto 0)) return std_logic_vector;
   function and_1to32  (databit: std_logic; databus : std_logic_vector(31 downto 0)) return std_logic_vector;
   function priority_encoder (state : std_logic_vector(5 downto 0); select1 : std_logic_vector(31 downto 0);
                              select2 : std_logic; select3 : std_logic; select4 : std_logic) return std_logic_vector;
   -- Chipscope ICON
   component v5_icon
     PORT (
       CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CONTROL3 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CONTROL4 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CONTROL2 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
   end component;

   -- Chipscope ILA
   component v5_ila
     PORT (
       CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CLK : IN STD_LOGIC;
       TRIG0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0));
   end component;

   -- Chipscope VIO
   component v5_vio
     PORT (
       CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
       CLK : IN STD_LOGIC := 'X';
       SYNC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
       SYNC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
   end component;

   -- ASYNC FIFO
   component afifo_35x512 port (
      din:           IN std_logic_VECTOR(34 downto 0);
      rd_clk:        IN std_logic;
      rd_en:         IN std_logic;
      rst:           IN std_logic;
      wr_clk:        IN std_logic;
      wr_en:         IN std_logic;
      dout:          OUT std_logic_VECTOR(34 downto 0);
      empty:         OUT std_logic;
      full:          OUT std_logic;
      wr_data_count: OUT std_logic_VECTOR(8 downto 0));
   end component;

   component afifo_20x8k port (
      din:           IN std_logic_VECTOR(19 downto 0);
      rd_clk:        IN std_logic;
      rd_en:         IN std_logic;
      rst:           IN std_logic;
      wr_clk:        IN std_logic;
      wr_en:         IN std_logic;
      dout:          OUT std_logic_VECTOR(19 downto 0);
      empty:         OUT std_logic;
      full:          OUT std_logic;
      wr_data_count: OUT std_logic_VECTOR(12 downto 0));
   end component;

   -- ASYNC FIFO
   component afifo_18x1k port (
      rd_clk:IN  std_logic;
      wr_clk:IN  std_logic;
      din:   IN  std_logic_VECTOR(17 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(17 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic
   ); end component;

   -- DPRAM
   component dpram_sync_1kx14 port (
      clka  : IN  std_logic;
      dina  : IN  std_logic_VECTOR(13 downto 0);
      addra : IN  std_logic_VECTOR(9 downto 0);
      wea   : IN  std_logic_VECTOR(0 downto 0);
      clkb  : IN  std_logic;
      addrb : IN  std_logic_VECTOR(9 downto 0);
      doutb : OUT std_logic_VECTOR(13 downto 0));
   end component;

   -- ASYNC FIFO
   component afifo_17x32 port (
      din:      IN  std_logic_vector(16 downto 0);
      wr_en:    IN  std_logic;
      wr_clk:   IN  std_logic;
      rd_en:    IN  std_logic;
      rd_clk:   IN  std_logic;
      rst:      IN  std_logic;
      dout:     OUT std_logic_vector(16 downto 0);
      full:     OUT std_logic;
      empty:    OUT std_logic 
   ); end component;

   -- Core
   component KpixConCore
      port (
         fpgaRstL      : in    std_logic;                     -- Asynchronous local reset
         sysClk        : in    std_logic;                     -- 125Mhz system clock
         sysClk200     : in    std_logic;                     -- 200Mhz system clock
         kpixClk       : in    std_logic;                     --
         divCount      : in    std_logic_vector(4  downto 0); -- Kpix Clock
         kpixLock      : in    std_logic;                     --
         ddrRst        : in    std_logic;                     -- ddr reset
         ddrClk        : in    std_logic;                     -- 125Mhz ddr clock
         jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
         clkSelA       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelB       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelC       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelD       : out   std_logic_vector(4  downto 0); -- Clock selection
         coreState     : out   std_logic_vector(2  downto 0); -- State of internal core
         ledL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs
         reset         : out   std_logic;                     -- Reset to KPIX devices
         forceTrig     : out   std_logic;
         command       : out   std_logic_vector(31 downto 0); -- Command to KPIX A devices
         data          : in    std_logic_vector(31 downto 0); -- Data from from KPIX C devices
         kpixRdEdge    : out   std_logic;                     -- Edge to read kpix data
         kpixRdPhase   : out   std_logic_vector(4  downto 0); -- Phase shift to read kpix data
         kpixRd        : in    std_logic;                     -- Kpix Data Read
         bncInA        : in    std_logic;                     -- BNC Interface A input
         bncInB        : in    std_logic;                     -- BNC Interface B input
         bncOutA       : out   std_logic;                     -- BNC Interface A output
         bncOutB       : out   std_logic;                     -- BNC Interface B output
         nimInA        : in    std_logic;                     -- NIM Interface A input
         nimInB        : in    std_logic;                     -- NIM Interface B input
         adcSData      : in    std_logic;                     -- ADC Serial Data In
         adcSclk       : out   std_logic;                     -- ADC Serial Clock Out
         adcCsL        : out   std_logic;                     -- ADC Chip Select Out
         dacDin        : out   std_logic;                     -- Cal Data Data
         dacSclk       : out   std_logic;                     -- Cal Data Clock
         dacCsL        : out   std_logic;                     -- Cal Data Chip Select
         dacClrL       : out   std_logic;                     -- Cal Data Clear
         ddr0RdNWr     : out   std_logic;                     -- ddr0 R/W
         ddr0LdL       : out   std_logic;                     -- ddr0 active low Load
         ddr0Data      : inout std_logic_vector(17 downto 0); -- ddr0 data bus
         ddr0Addr      : out   std_logic_vector(21 downto 0); -- ddr0 address bus
         ddr1RdNWr     : out   std_logic;                     -- ddr1 R/W
         ddr1LdL       : out   std_logic;                     -- ddr1 active low Load
         ddr1Data      : inout std_logic_vector(17 downto 0); -- ddr1 data bus
         ddr1Addr      : out   std_logic_vector(21 downto 0); -- ddr1 address bus
         TXP_0         : out   std_logic;                     -- Ethernet Transmiter Data
         TXN_0         : out   std_logic;                     -- Ethernet Transmiter Data
         RXP_0         : in    std_logic;                     -- Ethernet Receiver Data
         RXN_0         : in    std_logic;                     -- Ethernet Receiver Data
         TXN_1_UNUSED  : out   std_logic;                     -- Ethernet Transmiter Data
         TXP_1_UNUSED  : out   std_logic;                     -- Ethernet Transmiter Data
         RXN_1_UNUSED  : in    std_logic;                     -- Ethernet Receiver Data
         RXP_1_UNUSED  : in    std_logic;                     -- Ethernet Receiver Data
         gtpClk        : in    std_logic;                     -- Clock for ethernet interface
         gtpClkOut     : out   std_logic;                     -- Clock out from GTP
         gtpClkRef     : in    std_logic                      -- Clock for ethernet interface
      );
   end component;

   -- Upstream Buffer
   component UpstreamData
      port (
         sysClk        : in    std_logic;                       -- 20Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         gtpClk        : in    std_logic;                       -- 125Mhz gtp clock
         gtpClkRst     : in    std_logic;                       -- Synchronous reset input
         trainFifoReq  : in    std_logic;                       -- FIFO Write Request
         trainFifoAck  : out   std_logic;                       -- FIFO Write Grant
         trainFifoSOF  : in    std_logic;                       -- FIFO Word SOF
         trainFifoEOF  : in    std_logic;                       -- FIFO Word EOF
         trainFifoWr   : in    std_logic;                       -- FIFO Write Strobe
         trainFifoData : in    std_logic_vector(15 downto 0);   -- FIFO Word
         kpixRspReq    : in    std_logic;                       -- FIFO Write Request
         kpixRspAck    : out   std_logic;                       -- FIFO Write Grant
         kpixRspWr     : in    std_logic;                       -- FIFO Write
         kpixRspSOF    : in    std_logic;                       -- FIFO Word SOF
         kpixRspEOF    : in    std_logic;                       -- FIFO Word EOF
         kpixRspData   : in    std_logic_vector(15 downto 0);   -- FIFO Word
         locFifoReq    : in    std_logic;                       -- FIFO Write Request
         locFifoAck    : out   std_logic;                       -- FIFO Write Grant
         locFifoWr     : in    std_logic;                       -- FIFO Write
         locFifoSOF    : in    std_logic;                       -- FIFO Word SOF
         locFifoEOF    : in    std_logic;                       -- FIFO Word EOF
         locFifoData   : in    std_logic_vector(15 downto 0);   -- FIFO Word
         txFifoData    : out   std_logic_vector(15 downto 0);   -- TX FIFO Data
         txFifoSOF     : out   std_logic;                       -- TX FIFO Start of Frame
         txFifoEOF     : out   std_logic;                       -- TX FIFO End of Frame
         txFifoType    : out   std_logic_vector(1  downto 0);   -- TX FIFO Data Type
         txFifoRd      : in    std_logic;                       -- TX FIFO Read
         txFifoEmpty   : out   std_logic;                       -- TX FIFO Empty
         trainFifoFull : out   std_logic;                       -- Train FIFO is full
         csControl     : inout std_logic_vector(35 downto 0)    -- Chip Scope Control
      );
   end component;

   -- Downstream Buffer
   component DownstreamData
      port (
         rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
         rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
         rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
         rxFifoWr      : in     std_logic;                     -- RX FIFO Write
         rxFifoFull    : out    std_logic;                     -- RX FIFO Full
         kpixData      : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         kpixSOF       : out    std_logic;                     -- RX FIFO Start of Frame
         kpixWr        : out    std_logic;                     -- RX FIFO Write
         kpixFull      : in     std_logic;                     -- RX FIFO Full
         locData       : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         locSOF        : out    std_logic;                     -- RX FIFO Start of Frame
         locWr         : out    std_logic;                     -- RX FIFO Write
         locFull       : in     std_logic                      -- RX FIFO Full
      );
   end component;

   -- Kpix Controller
   component KpixControl
      port (
         kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
         kpixRst       : in    std_logic;                       -- System reset
         sysClk        : in    std_logic;                       -- 60Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         ddrClk        : in    std_logic;                       -- 125Mhz ddr clock
         ddrRst        : in    std_logic;                       -- ddr reset
         checkSumErr   : out   std_logic;                       -- Checksum error flag
         writeData     : in    std_logic_vector(31 downto 0);   -- Write Data
         readData      : out   std_logic_vector(31 downto 0);   -- Read Data
         writeEn       : in    std_logic;                       -- Write strobe
         address       : in    std_logic_vector(7  downto 0);   -- Address select
         coreState     : out   std_logic_vector(2  downto 0);   -- State of internal core
         trainFifoFull : in    std_logic;                       -- Train FIFO is full
         kpixRunLed    : out   std_logic;                       -- Kpix RUN LED
         reset         : out   std_logic;                       -- Kpix Reset
         forceTrig     : out   std_logic;                       -- Kpix Force Trigger
         bncInA        : in    std_logic;                       -- BNC Interface A input
         bncInB        : in    std_logic;                       -- BNC Interface B input
         bncOutA       : out   std_logic;                       -- BNC Interface A output
         bncOutB       : out   std_logic;                       -- BNC Interface B output
         nimInA        : in    std_logic;                       -- NIM Interface A input
         nimInB        : in    std_logic;                       -- NIM Interface B input
         trainFifoReq  : out   std_logic;                       -- FIFO Write Request
         trainFifoAck  : in    std_logic;                       -- FIFO Write Grant
         trainFifoSOF  : out   std_logic;                       -- FIFO Word SOF
         trainFifoEOF  : out   std_logic;                       -- FIFO Word EOF
         trainFifoWr   : out   std_logic;                       -- FIFO Write Strobe
         trainFifoData : out   std_logic_vector(15 downto 0);   -- FIFO Word
         cmdFifoData   : in    std_logic_vector(15 downto 0);   -- RX FIFO Data
         cmdFifoSOF    : in    std_logic;                       -- RX FIFO Start of Frame
         cmdFifoWr     : in    std_logic;                       -- RX FIFO Write
         cmdFifoFull   : out   std_logic;                       -- RX FIFO Full
         kpixRspReq    : out   std_logic;                       -- FIFO Write Request
         kpixRspAck    : in    std_logic;                       -- FIFO Write Grant
         kpixRspWr     : out   std_logic;                       -- FIFO Write Request
         kpixRspSOF    : out   std_logic;                       -- FIFO Word SOF
         kpixRspEOF    : out   std_logic;                       -- FIFO Word EOF
         kpixRspData   : out   std_logic_vector(15 downto 0);   -- FIFO Word
         ddr0RdNWr     : out   std_logic;                       -- ddr0 R/W
         ddr0LdL       : out   std_logic;                       -- ddr0 active low Load
         ddr0Data      : inout std_logic_vector(17 downto 0);   -- ddr0 data bus
         ddr0Addr      : out   std_logic_vector(21 downto 0);   -- ddr0 address bus
         ddr1RdNWr     : out   std_logic;                       -- ddr1 R/W
         ddr1LdL       : out   std_logic;                       -- ddr1 active low Load
         ddr1Data      : inout std_logic_vector(17 downto 0);   -- ddr1 data bus
         ddr1Addr      : out   std_logic_vector(21 downto 0);   -- ddr1 address bus
         serData       : out   std_logic_vector(31 downto 0);   -- Serial data out
         rspData       : in    std_logic_vector(31 downto 0);   -- Incoming serial data
         csControl1    : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
         csControl2    : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
         csControl3    : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
         csEnable      : in    std_logic_vector(15 downto 0)    -- Chip scope inputs
      );
   end component;

   component KpixRespData
      port ( 
         sysClk        : in    std_logic;                       -- 125Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
         kpixRst       : in    std_logic;                       -- System reset
         kpixRspReq    : out   std_logic;                       -- FIFO Write Request
         kpixRspAck    : in    std_logic;                       -- FIFO Write Grant
         kpixRspWr     : out   std_logic;                       -- FIFO Write
         kpixRspSOF    : out   std_logic;                       -- FIFO Word SOF
         kpixRspEOF    : out   std_logic;                       -- FIFO Word EOF
         kpixRspData   : out   std_logic_vector(15 downto 0);   -- FIFO Word
         parErrCount   : out   std_logic_vector(7 downto 0);    -- Parity error detected
         parErrRst     : in    std_logic;                       -- Parity error count reset
         rspData       : in    std_logic_vector(31 downto 0);   -- Incoming serial data
         rspDataL      : in    std_logic ;                      -- Incoming serial data
         statusValue   : out   array32x32;                      -- KPIX status register
         statusRx      : out   std_logic_vector(31 downto 0);   -- KPIX status received
         kpixVer       : in    std_logic ;                      -- Kpix Version
         csControl     : inout std_logic_vector(35 downto 0)    -- Chip Scope Control
      );
   end component;

   -- Kpix Response Processor
   component KpixRspRx
      generic (
         CsEnable    : integer := 0                           -- Enable chipscope core
      );port (
         kpixClk     : in    std_logic;                       -- 20Mhz system clock
         kpixRst     : in    std_logic;                       -- System reset
         fifoReq     : out   std_logic;                       -- FIFO Write Request
         fifoAck     : in    std_logic;                       -- FIFO Write Grant
         fifoSOF     : out   std_logic;                       -- FIFO Word SOF
         fifoEOF     : out   std_logic;                       -- FIFO Word EOF
         fifoData    : out   std_logic_vector(15 downto 0);   -- FIFO Word
         parError    : out   std_logic;                       -- Parity error detected
         kpixAddr    : in    std_logic_vector(5  downto 0);   -- Kpix address
         rspData     : in    std_logic;                       -- Incoming serial data
         statusValue : out   std_logic_vector(31 downto 0);   -- KPIX status register
         statusRx    : out   std_logic;                       -- KPIX status received
         kpixVer     : in    std_logic;                       -- Kpix Version
         csControl   : inout std_logic_vector(35 downto 0)    -- Chip Scope Control
      );
   end component;

   -- Train Data Processor
   component KpixTrainData
      port (
         sysClk       : in    std_logic;                       -- 125Mhz sys clock
         sysRst       : in    std_logic;                       -- sys reset
         kpixClk      : in    std_logic;                       -- 20Mhz system clock
         kpixRst      : in    std_logic;                       -- System reset
         trainNumRst  : in    std_logic;                       -- Train sequence number reset
         trainNum     : out   std_logic_vector(31 downto 0);   -- Train sequence number
         acqDone      : out   std_logic;                       -- Kpix Cycle Complete
         isRunning    : in    std_logic;                       -- Sequence is running
         deadCount    : in    std_logic_vector(12 downto 0);   -- Inter-train dead count
         extRecord    : in    std_logic;                       -- External trigger accept input, To be implemented
         serialNum    : in    std_logic_vector(3  downto 0);   -- Train Serial Number
         fifoReq      : out   std_logic;                       -- FIFO Write Request
         fifoAck      : in    std_logic;                       -- FIFO Write Grant
         fifoSOF      : out   std_logic;                       -- FIFO Word SOF
         fifoEOF      : out   std_logic;                       -- FIFO Word EOF
         fifoPad      : out   std_logic;                       -- FIFO Word Padding
         fifoWr       : out   std_logic;                       -- FIFO Write Strobe
         fifoData     : out   std_logic_vector(15 downto 0);   -- FIFO Word
         parErrCount  : out   std_logic_vector(7  downto 0);   -- Parity error count
         parErrRst    : in    std_logic;                       -- Parity error count reset
         dropData     : in    std_logic;                       -- Drop data control
         rawData      : in    std_logic;                       -- Raw data enable
         rspDataA     : in    std_logic;                       -- Incoming serial data A
         rspDataB     : in    std_logic;                       -- Incoming serial data B
         rspDataC     : in    std_logic;                       -- Incoming serial data C
         rspDataD     : in    std_logic;                       -- Incoming serial data D
         kpixVer      : in    std_logic;                       -- Kpix Version
         kpixBunch    : in    std_logic_vector(12 downto 0);   -- Bunch count value
         statusValueA : in    std_logic_vector(31 downto 0);
         statusRxA    : in    std_logic;
         statusValueB : in    std_logic_vector(31 downto 0);
         statusRxB    : in    std_logic;
         statusValueC : in    std_logic_vector(31 downto 0);
         statusRxC    : in    std_logic;
         statusValueD : in    std_logic_vector(31 downto 0);
         statusRxD    : in    std_logic;
         trainDebug   : out   std_logic_vector(63 downto 0);
         kpixDebugA   : out   std_logic_vector(63 downto 0);
         kpixDebugB   : out   std_logic_vector(63 downto 0);
         kpixDebugC   : out   std_logic_vector(63 downto 0);
         kpixDebugD   : out   std_logic_vector(63 downto 0)
      );
   end component;

   -- Kpix Data Processor
   component KpixDataRx
      port (
         sysClk       : in    std_logic;                       -- 60Mhz system clock
         sysRst       : in    std_logic;                       -- System reset
         kpixClk      : in    std_logic;                       -- 20Mhz kpix clock
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
         kpixVer      : in    std_logic;                       -- Kpix version
         inReadout    : out   std_logic;                       -- Start of train marker
         rspData      : in    std_logic;                       -- Incoming serial data
         kpixDebug    : out   std_logic_vector(63 downto 0)    -- Chip Scope Control
      );
   end component;

   -- SRAM Data Interface
   component KpixDdrData
      port (
         ddrClk       : in    std_logic;                       -- 125Mhz ddr clock
         ddrRst       : in    std_logic;                       -- ddr reset
         ddrRdNWr     : out   std_logic;                       -- ddr R/W
         ddrLdL       : out   std_logic;                       -- ddr active low Load
         ddrData      : inout std_logic_vector(17 downto 0);   -- ddr data bus
         ddrAddr      : out   std_logic_vector(21 downto 0);   -- ddr address bus
         sysClk       : in    std_logic;                       -- 125Mhz system clock
         sysRst       : in    std_logic;                       -- system reset  
         sramReq      : out   std_logic;                       -- sram Write Request
         sramAck      : in    std_logic;                       -- sram Write Grant
         sramSOF      : out   std_logic;                       -- sram Word SOF
         sramEOF      : out   std_logic;                       -- sram Word EOF
         sramWr       : out   std_logic;                       -- sram Write Strobe
         sramData     : out   std_logic_vector(15 downto 0);   -- sram Word
         trainReq     : in    std_logic_vector(3 downto 0);    -- train Write Request
         trainAck     : out   std_logic_vector(3 downto 0);    -- train Write Grant
         trainSOF     : in    std_logic_vector(3 downto 0);    -- train Word SOF
         trainEOF     : in    std_logic_vector(3 downto 0);    -- train Word EOF
         trainPad     : in    std_logic_vector(3 downto 0);    -- train Word EOF
         trainWr      : in    std_logic_vector(3 downto 0);    -- train Write Strobe
         trainData    : in    array4x32;                       -- train Word
         csControl1   : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
         csControl2   : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
         csEnable     : in    std_logic_vector(15 downto 0)    -- Chip scope inputs
      );
   end component;

   -- SRAM controller
   component KpixDdrDataRx
      port (
         sysClk            : in  std_logic;                      -- 125Mhz sys clock
         sysRst            : in  std_logic;                      -- sys reset
         trainReq          : in  std_logic;                      -- train Write Request
         trainAck          : out std_logic;                      -- train Write Grant
         trainSOF          : in  std_logic;                      -- train Word SOF
         trainEOF          : in  std_logic;                      -- train Word EOF
         trainPad          : in  std_logic;                      -- train Word Padding
         trainWr           : in  std_logic;                      -- train Write Strobe
         trainData         : in  std_logic_vector(31 downto 0);  -- train Word
         memWr             : out std_logic;
         memWrEn           : in  std_logic;
         memWrAddr         : out std_logic_vector(18 downto 0);
         memWrData         : out std_logic_vector(31 downto 0);
         memWrSOF          : out std_logic;
         memWrEOF          : out std_logic;
         memWrPad          : out std_logic;
         memRd             : out std_logic;
         memRdEn           : in  std_logic;
         memRdAddr         : out std_logic_vector(18 downto 0);
         memRdLast         : out std_logic;
         sysDebug          : out std_logic_vector(63 downto 0)
      );
   end component;
   
   -- Trigger timestamp process
   component KpixTrigRec port ( 
         sysClk        : in    std_logic;                       -- 60Mhz system clock
         sysRst        : in    std_logic;                       -- System reset
         kpixClk       : in    std_logic;                       -- 20Mhz kpix clock
         kpixRst       : in    std_logic;                       -- System reset
         extRecord     : in    std_logic;                       -- External trigger accept input, To be implemented
         kpixBunch     : in    std_logic_vector(12 downto 0);   -- Bunch count value
         fifoReq       : out   std_logic;                       -- FIFO Write Request
         fifoAck       : in    std_logic;                       -- FIFO Write Grant
         fifoWr        : out   std_logic;                       -- FIFO Write Strobe
         fifoData      : out   std_logic_vector(15 downto 0)    -- FIFO Word
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
         serData       : out   std_logic_vector(31 downto 0); -- Serial data out
         serDataL      : out   std_logic;                     -- Serial data out from local kPIX
         kpixVer       : in    std_logic;                     -- Kpix Version
         csControl     : inout std_logic_vector(35 downto 0)  -- Chip Scope Control
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
         coreState     : out   std_logic_vector(2 downto 0);    -- Core state value
         rspData       : out   std_logic;                       -- Response Data out
         forceTrig     : out   std_logic;                       -- Force trigger signal
         trigControl   : in    std_logic_vector(31 downto 0);   -- Trigger control register
         kpixVer       : in    std_logic;                       -- Kpix Version
         kpixBunch     : out   std_logic_vector(12 downto 0);   -- Bunch count value
         calStrobeOut  : out   std_logic
      );
   end component;

   -- Command Decoder
   component CmdControl
      port (
         sysClk        : in    std_logic;                     -- 20Mhz system clock
         sysRst        : in    std_logic;                     -- System reset
         kpixClk       : in    std_logic;                     -- 20Mhz system clock
         kpixRst       : in    std_logic;                     -- System reset
         checkSumErr   : in    std_logic;                     -- Checksum error flag
         mstRstCmd     : out   std_logic;                     -- Master reset command
         kpixRstCmd    : out   std_logic;                     -- Kpix reset command
         fifoRxData    : in    std_logic_vector(15 downto 0); -- RX FIFO Data
         fifoRxSOF     : in    std_logic;                     -- RX FIFO Start of Frame
         fifoRxWr      : in    std_logic;                     -- RX FIFO Write
         fifoRxFull    : out   std_logic;                     -- RX FIFO Full
         fifoTxReq     : out   std_logic;                     -- RX FIFO Request
         fifoTxAck     : in    std_logic;                     -- RX FIFO Grant
         fifoTxWr      : out   std_logic;                     -- RX FIFO Write
         fifoTxData    : out   std_logic_vector(15 downto 0); -- RX FIFO Data
         fifoTxSOF     : out   std_logic;                     -- RX FIFO Start of Frame
         fifoTxEOF     : out   std_logic;                     -- RX FIFO End of Frame
         clkSelA       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelB       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelC       : out   std_logic_vector(4  downto 0); -- Clock select
         clkSelD       : out   std_logic_vector(4  downto 0); -- Clock select
         jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
         writeData     : out   std_logic_vector(31 downto 0); -- Write Data
         readData      : in    std_logic_vector(31 downto 0); -- Read Data
         writeEn       : out   std_logic;                     -- Write strobe
         address       : out   std_logic_vector(7  downto 0); -- Address select
         kpixRdPhase   : out   std_logic_vector(4  downto 0); -- Phase shift to read kpix data
         kpixRdEdge    : out   std_logic;                     -- Edge to read kpix data
         csControl     : inout  std_logic_vector(35 downto 0) -- Chip Scope Control
      );
   end component;

   -- Data Formatter
   component KpixDataFrmtr
      port ( 
         sysClk        : in     std_logic;                     -- 200Mhz system clock
         sysRst        : in     std_logic;                     -- System reset
         emacClk       : in     std_logic;
         emacClkRst    : in     std_logic;
         rxFifoData    : out    std_logic_vector(15 downto 0); -- RX FIFO Data
         rxFifoSOF     : out    std_logic;                     -- TX FIFO Start of Frame
         rxFifoType    : out    std_logic_vector(1  downto 0); -- TX FIFO Data Type
         rxFifoWr      : out    std_logic;                     -- RX FIFO Write
         rxFifoFull    : in     std_logic;                     -- RX FIFO Full
         ethRxValid    : in     std_logic;
         ethRxData     : in     std_logic_vector(7 downto 0);
         ethRxGood     : in     std_logic;
         ethRxError    : in     std_logic;
         csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      );
   end component;

   -- Counter to test Ethernet Interface
   component EthTestCounter port ( 
         -- Ethernet clock & reset
         emacClk       : in     std_logic;
         emacClkRst    : in     std_logic;
         sysClk        : in     std_logic;
         sysRst        : in     std_logic;
         cScopeCtrl    : inout  std_logic_vector(35 downto 0);
         -- TX FIFO Interface
         txFifoData    : out    std_logic_vector(15 downto 0); -- TX FIFO Data
         txFifoSOF     : out    std_logic;                     -- TX FIFO Start of Frame
         txFifoEOF     : out    std_logic;                     -- TX FIFO End of Frame
         txFifoType    : out    std_logic_vector(1  downto 0); -- TX FIFO Data Type
         txFifoRd      : in     std_logic;                     -- TX FIFO Read
         txFifoEmpty   : out    std_logic;                     -- TX FIFO Empty
         -- RX FIFO Interface
         rxFifoData    : in     std_logic_vector(15 downto 0); -- RX FIFO Data
         rxFifoSOF     : in     std_logic;                     -- TX FIFO Start of Frame
         rxFifoType    : in     std_logic_vector(1  downto 0); -- TX FIFO Data Type
         rxFifoWr      : in     std_logic;                     -- RX FIFO Write
         rxFifoFull    : out    std_logic                      -- RX FIFO Full
      );
   end component;

end KpixConPkg;

package body KpixConPkg is

   -- Custom Functions
   function conv_32to5 (value : std_logic_vector(31 downto 0)) return std_logic_vector is
      begin
            if value(0)  = '1' then return ("00000");
         elsif value(1)  = '1' then return ("00001");
         elsif value(2)  = '1' then return ("00010");
         elsif value(3)  = '1' then return ("00011");
         elsif value(4)  = '1' then return ("00100");
         elsif value(5)  = '1' then return ("00101");
         elsif value(6)  = '1' then return ("00110");
         elsif value(7)  = '1' then return ("00111");
         elsif value(8)  = '1' then return ("01000");
         elsif value(9)  = '1' then return ("01001");
         elsif value(10) = '1' then return ("01010");
         elsif value(11) = '1' then return ("01011");
         elsif value(12) = '1' then return ("01100");
         elsif value(13) = '1' then return ("01101");
         elsif value(14) = '1' then return ("01110");
         elsif value(15) = '1' then return ("01111");
         elsif value(16) = '1' then return ("10000");
         elsif value(17) = '1' then return ("10001");
         elsif value(18) = '1' then return ("10010");
         elsif value(19) = '1' then return ("10011");
         elsif value(20) = '1' then return ("10100");
         elsif value(21) = '1' then return ("10101");
         elsif value(22) = '1' then return ("10110");
         elsif value(23) = '1' then return ("10111");
         elsif value(24) = '1' then return ("11000");
         elsif value(25) = '1' then return ("11001");
         elsif value(26) = '1' then return ("11010");
         elsif value(27) = '1' then return ("11011");
         elsif value(28) = '1' then return ("11100");
         elsif value(29) = '1' then return ("11101");
         elsif value(30) = '1' then return ("11110");
         elsif value(31) = '1' then return ("11111");
         end if;
      end conv_32to5;
      
   function conv_5to32 (value : std_logic_vector(4 downto 0)) return std_logic_vector is
      begin
         case (value) is
            when "00000" => return (x"00000001");
            when "00001" => return (x"00000002");
            when "00010" => return (x"00000004");
            when "00011" => return (x"00000008");
            when "00100" => return (x"00000010");
            when "00101" => return (x"00000020");
            when "00110" => return (x"00000040");
            when "00111" => return (x"00000080");
            when "01000" => return (x"00000100");
            when "01001" => return (x"00000200");
            when "01010" => return (x"00000400");
            when "01011" => return (x"00000800");
            when "01100" => return (x"00001000");
            when "01101" => return (x"00002000");
            when "01110" => return (x"00004000");
            when "01111" => return (x"00008000");
            when "10000" => return (x"00010000");
            when "10001" => return (x"00020000");
            when "10010" => return (x"00040000");
            when "10011" => return (x"00080000");
            when "10100" => return (x"00100000");
            when "10101" => return (x"00200000");
            when "10110" => return (x"00400000");
            when "10111" => return (x"00800000");
            when "11000" => return (x"01000000");
            when "11001" => return (x"02000000");
            when "11010" => return (x"04000000");
            when "11011" => return (x"08000000");
            when "11100" => return (x"10000000");
            when "11101" => return (x"20000000");
            when "11110" => return (x"40000000");
            when "11111" => return (x"80000000");
         end case;
      end conv_5to32;

   function and_1to32 (databit: std_logic; databus : std_logic_vector(31 downto 0)) return std_logic_vector is
      variable value : std_logic_vector(31 downto 0);
      begin
         value(0)  := databit and databus(0);
         value(1)  := databit and databus(1);
         value(2)  := databit and databus(2);
         value(3)  := databit and databus(3);
         value(4)  := databit and databus(4);
         value(5)  := databit and databus(5);
         value(6)  := databit and databus(6);
         value(7)  := databit and databus(7);
         value(8)  := databit and databus(8);
         value(9)  := databit and databus(9);
         value(10) := databit and databus(10);
         value(11) := databit and databus(11);
         value(12) := databit and databus(12);
         value(13) := databit and databus(13);
         value(14) := databit and databus(14);
         value(15) := databit and databus(15);
         value(16) := databit and databus(16);
         value(17) := databit and databus(17);
         value(18) := databit and databus(18);
         value(19) := databit and databus(19);
         value(20) := databit and databus(20);
         value(21) := databit and databus(21);
         value(22) := databit and databus(22);
         value(23) := databit and databus(23);
         value(24) := databit and databus(24);
         value(25) := databit and databus(25);
         value(26) := databit and databus(26);
         value(27) := databit and databus(27);
         value(28) := databit and databus(28);
         value(29) := databit and databus(29);
         value(30) := databit and databus(30);
         value(31) := databit and databus(31);
         return(value);
      end and_1to32;

   function priority_encoder (state : std_logic_vector(5 downto 0); select1 : std_logic_vector(31 downto 0);
                              select2: std_logic; select3  : std_logic; select4  : std_logic) return std_logic_vector is
      variable value : std_logic_vector(5 downto 0);
      begin
         case state is
            when "000000" =>
                  if select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               else  value := state; end if;
            when "000001" =>
                  if select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               else  value := state; end if;
            when "000010" =>
                  if select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               else  value := state; end if;
            when "000011" =>
                  if select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               else  value := state; end if;
            when "000100" =>
                  if select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               else  value := state; end if;
            when "000101" =>
                  if select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               else  value := state; end if;
            when "000110" =>
                  if select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               else  value := state; end if;
            when "000111" =>
                  if select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               else  value := state; end if;
            when "001000" =>
                  if select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               else  value := state; end if;
            when "001001" =>
                  if select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               else  value := state; end if;
            when "001010" =>
                  if select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               else  value := state; end if;
            when "001011" =>
                  if select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               else  value := state; end if;
            when "001100" =>
                  if select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               else  value := state; end if;
            when "001101" =>
                  if select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               else  value := state; end if;
            when "001110" =>
                  if select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               else  value := state; end if;
            when "001111" =>
                  if select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               else  value := state; end if;
            when "010000" =>
                  if select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               else  value := state; end if;
            when "010001" =>
                  if select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               else  value := state; end if;
            when "010010" =>
                  if select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               else  value := state; end if;
            when "010011" =>
                  if select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               else  value := state; end if;
            when "010100" =>
                  if select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               else  value := state; end if;
            when "010101" =>
                  if select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               else  value := state; end if;
            when "010110" =>
                  if select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               else  value := state; end if;
            when "010111" =>
                  if select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               else  value := state; end if;
            when "011000" =>
                  if select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               else  value := state; end if;
            when "011001" =>
                  if select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               else  value := state; end if;
            when "011010" =>
                  if select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               else  value := state; end if;
            when "011011" =>
                  if select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               else  value := state; end if;
            when "011100" =>
                  if select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               else  value := state; end if;
            when "011101" =>
                  if select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               else  value := state; end if;
            when "011110" =>
                  if select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               else  value := state; end if;
            when "011111" =>
                  if select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               else  value := state; end if;
            when "100000" =>
                  if select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               else  value := state; end if;
            when "100001" =>
                  if select3     = '1' then value := "100001";
               elsif select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               else  value := state; end if;
            when "100010" =>
                  if select4     = '1' then value := "100010";
               elsif select1(0)  = '1' then value := "000000";
               elsif select1(1)  = '1' then value := "000001";
               elsif select1(2)  = '1' then value := "000010";
               elsif select1(3)  = '1' then value := "000011";
               elsif select1(4)  = '1' then value := "000100";
               elsif select1(5)  = '1' then value := "000101";
               elsif select1(6)  = '1' then value := "000110";
               elsif select1(7)  = '1' then value := "000111";
               elsif select1(8)  = '1' then value := "001000";
               elsif select1(9)  = '1' then value := "001001";
               elsif select1(10) = '1' then value := "001010";
               elsif select1(11) = '1' then value := "001011";
               elsif select1(12) = '1' then value := "001100";
               elsif select1(13) = '1' then value := "001101";
               elsif select1(14) = '1' then value := "001110";
               elsif select1(15) = '1' then value := "001111";
               elsif select1(16) = '1' then value := "010000";
               elsif select1(17) = '1' then value := "010001";
               elsif select1(18) = '1' then value := "010010";
               elsif select1(19) = '1' then value := "010011";
               elsif select1(20) = '1' then value := "010100";
               elsif select1(21) = '1' then value := "010101";
               elsif select1(22) = '1' then value := "010110";
               elsif select1(23) = '1' then value := "010111";
               elsif select1(24) = '1' then value := "011000";
               elsif select1(25) = '1' then value := "011001";
               elsif select1(26) = '1' then value := "011010";
               elsif select1(27) = '1' then value := "011011";
               elsif select1(28) = '1' then value := "011100";
               elsif select1(29) = '1' then value := "011101";
               elsif select1(30) = '1' then value := "011110";
               elsif select1(31) = '1' then value := "011111";
               
               elsif select2     = '1' then value := "100000";
               elsif select3     = '1' then value := "100001";
               else  value := state; end if;
            when others =>
               value := state;
         end case;
         return (value);
      end priority_encoder;

end KpixConPkg;
