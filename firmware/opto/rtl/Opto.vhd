-------------------------------------------------------------------------------
-- Title         : KPIX Opto FPGA Top Level Module
-- Project       : W_SI, KPIX Opto Board
-------------------------------------------------------------------------------
-- File          : Opto.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Top level VHDL source file for the test FPGA pn the KPIX Opto Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity Opto is 
   port ( 

      -- System clock, reset
      iFpgaRstL      : in    std_logic;                     -- Asynchronous local reset
      iSysClk20      : in    std_logic;                     -- 20Mhz system clock

      -- Jumper, Debug & Spare Signals
      iJumpL         : in    std_logic_vector(3  downto 0); -- Opto jumpers, active low
      oLedL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs
      oDebug         : out   std_logic_vector(31 downto 0); -- Debug connector
      oDbgClk        : out   std_logic;                     -- Debug clock
      oForceTrig     : out   std_logic;

      -- USB Controller
      ioUsbData      : inout std_logic_vector(7  downto 0); -- USB Controller Data
      oUsbRdL        : out   std_logic;                     -- USB Controller Read
      oUsbWr         : out   std_logic;                     -- USB Controller Write
      iUsbTxeL       : in    std_logic;                     -- USB Controller Tx Ready
      iUsbRxfL       : in    std_logic;                     -- USB Controller Rx Ready
      iUsbPwrEnL     : in    std_logic;                     -- USB Controller Power Enable

      -- Optical Interface
      oSysclk        : inout std_logic;                     -- Clock to KPIX devices
      oReset         : out   std_logic;                     -- Reset to KPIX devices
      oCommandA      : out   std_logic;                     -- Command to KPIX A devices
      oCommandB      : out   std_logic;                     -- Command to KPIX B devices
      oCommandC      : out   std_logic;                     -- Command to KPIX C devices
      iDataA         : in    std_logic;                     -- Data from from KPIX A devices
      iDataB         : in    std_logic;                     -- Data from from KPIX B devices
      iDataC         : in    std_logic;                     -- Data from from KPIX C devices

      -- External signals
      iBncInA        : in    std_logic;                     -- BNC Interface A input
      iBncInB        : in    std_logic;                     -- BNC Interface B input
      oBncOutA       : out   std_logic;                     -- BNC Interface A output
      oBncOutB       : out   std_logic;                     -- BNC Interface B output
      iNimInA        : in    std_logic;                     -- NIM Interface A input
      iNimInB        : in    std_logic;                     -- NIM Interface B input

      -- ADC Interface
      iAdcSData      : in    std_logic;                     -- ADC Serial Data In
      oAdcSclk       : out   std_logic;                     -- ADC Serial Clock Out
      oAdcCsL        : out   std_logic;                     -- ADC Chip Select Out

      -- Calibration DAC
      oDacDin        : out   std_logic;                     -- Cal Data Data
      oDacSclk       : out   std_logic;                     -- Cal Data Clock
      oDacCsL        : out   std_logic;                     -- Cal Data Chip Select
      oDacClrL       : out   std_logic                      -- Cal Data Clear
   );
end Opto;


-- Define architecture for top level module
architecture Opto of Opto is 

   -- Synthesis control attributes
   attribute syn_useioff    : boolean;
   attribute syn_useioff    of Opto : architecture is true;
   attribute xc_fast_auto   : boolean;
   attribute xc_fast_auto   of Opto : architecture is false;
   attribute syn_noclockbuf : boolean;
   attribute syn_noclockbuf of Opto : architecture is true;

   -- IO Pad components
   component IBUF   port ( O : out std_logic; I  : in std_logic ); end component;
   component IBUFG  port ( O : out std_logic; I  : in std_logic ); end component;
   component OBUF   port ( O : out std_logic; I  : in std_logic ); end component;

   -- BiDir Pad
   component IOBUF  
      port ( 
         O  : out   std_logic; 
         IO : inout std_logic; 
         I  : in    std_logic;
         T  : in std_logic 
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

   -- Xilinx DCM component
   component DCM
      generic (
         DFS_FREQUENCY_MODE    : string;
         DLL_FREQUENCY_MODE    : string;
         DUTY_CYCLE_CORRECTION : boolean;
         CLKIN_DIVIDE_BY_2     : boolean;
         CLK_FEEDBACK          : string;
         CLKOUT_PHASE_SHIFT    : string;
         STARTUP_WAIT          : boolean;
         PHASE_SHIFT           : integer;
         CLKFX_MULTIPLY        : integer;
         CLKFX_DIVIDE          : integer;
         CLKDV_DIVIDE          : real;
         DESKEW_ADJUST         : string;
         CLKIN_PERIOD          : real       := 10.0;
         DSS_MODE              : string     := "NONE";
         FACTORY_JF            : bit_vector := X"C080"
      );
      port (
         CLK0     : out std_logic;
         CLK180   : out std_logic;
         CLK270   : out std_logic;
         CLK2X    : out std_logic;
         CLK2X180 : out std_logic;
         CLK90    : out std_logic;
         CLKDV    : out std_logic;
         CLKFX    : out std_logic;
         CLKFX180 : out std_logic;
         LOCKED   : out std_logic;
         PSDONE   : out std_logic;
         STATUS   : out std_logic_vector(7 downto 0);    
         CLKFB    : in  std_logic;
         CLKIN    : in  std_logic;
         DSSEN    : in  std_logic;
         PSCLK    : in  std_logic;    
         PSEN     : in  std_logic;
         PSINCDEC : in  std_logic;
         RST      : in  std_logic
      );
   end component;


   -- For simulation
   -- synopsys translate_off
   for all : IBUF    use entity Unisim.IBUF    (ibuf_v);
   for all : IBUFG   use entity Unisim.IBUFG   (ibufg_v);
   for all : OBUF    use entity Unisim.OBUF    (obuf_v);
   for all : IOBUF   use entity Unisim.IOBUF   (iobuf_v);
   for all : BUFGMUX use entity Unisim.BUFGMUX (bufgmux_v);
   -- synopsys translate_on

   -- Core
   component OptoCore
      port (
         fpgaRstL      : in    std_logic;                     -- Asynchronous local reset
         sysClk20      : in    std_logic;                     -- 20Mhz system clock
         kpixClk       : in    std_logic;                     --
         kpixLock      : in    std_logic;                     --
         jumpL         : in    std_logic_vector(3  downto 0); -- Test jumpers, active low
         clkSelA       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelB       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelC       : out   std_logic_vector(4  downto 0); -- Clock selection
         clkSelD       : out   std_logic_vector(4  downto 0); -- Clock selection
         coreState     : out   std_logic_vector(3  downto 0); -- State of internal core
         ledL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs
         debug         : out   std_logic_vector(31 downto 0); -- Debug connector
         usbDin        : in    std_logic_vector(7  downto 0); -- USB Controller Data In
         usbDout       : out   std_logic_vector(7  downto 0); -- USB Controller Data Out
         usbRdL        : out   std_logic;                     -- USB Controller Read
         usbWr         : out   std_logic;                     -- USB Controller Write
         usbTxeL       : in    std_logic;                     -- USB Controller Tx Ready
         usbRxfL       : in    std_logic;                     -- USB Controller Rx Ready
         usbPwrEnL     : in    std_logic;                     -- USB Controller Power Enable
         usbDenL       : out   std_logic;                     -- USB Output Enable
         reset         : out   std_logic;                     -- Reset to KPIX devices
         forceTrig     : out   std_logic;
         commandA      : out   std_logic;                     -- Command to KPIX A devices
         commandB      : out   std_logic;                     -- Command to KPIX B devices
         commandC      : out   std_logic;                     -- Command to KPIX C devices
         dataA         : in    std_logic;                     -- Data from from KPIX A devices
         dataB         : in    std_logic;                     -- Data from from KPIX B devices
         dataC         : in    std_logic;                     -- Data from from KPIX C devices
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
         trainNumClk   : in    std_logic 
      );
   end component;

   -- Interface Signals
   signal fpgaRstL      : std_logic;                     -- Asynchronous local reset
   signal sysClk20      : std_logic;                     -- 20Mhz system clock
   signal kpixClk       : std_logic;                     --
   signal kpixClkL      : std_logic;                     --
   signal kpixLock      : std_logic;                     --
   signal jumpL         : std_logic_vector(3  downto 0); -- Test jumpers, active low
   signal clkSel        : std_logic_vector(9  downto 0); -- Clock selection
   signal clkSelA       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelB       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelC       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelD       : std_logic_vector(4  downto 0); -- Clock selection
   signal coreState     : std_logic_vector(3  downto 0); -- State of internal core
   signal ledL          : std_logic_vector(3  downto 0); -- FPGA LEDs
   signal debug         : std_logic_vector(31 downto 0); -- Debug connector
   signal dbgClk        : std_logic;                     -- Debug clock
   signal forceTrig     : std_logic;
   signal usbDin        : std_logic_vector(7  downto 0); -- USB Controller Data In
   signal usbDout       : std_logic_vector(7  downto 0); -- USB Controller Data Out
   signal usbRdL        : std_logic;                     -- USB Controller Read
   signal usbWr         : std_logic;                     -- USB Controller Write
   signal usbTxeL       : std_logic;                     -- USB Controller Tx Ready
   signal usbRxfL       : std_logic;                     -- USB Controller Rx Ready
   signal usbPwrEnL     : std_logic;                     -- USB Controller Power Enable
   signal usbDenL       : std_logic;                     -- USB Output Enable
   signal sysclk        : std_logic;                     -- Clock to KPIX devices
   signal reset         : std_logic;                     -- Reset to KPIX devices
   signal commandA      : std_logic;                     -- Command to KPIX A devices
   signal commandB      : std_logic;                     -- Command to KPIX B devices
   signal commandC      : std_logic;                     -- Command to KPIX C devices
   signal dataA         : std_logic;                     -- Data from from KPIX A devices
   signal dataB         : std_logic;                     -- Data from from KPIX B devices
   signal dataC         : std_logic;                     -- Data from from KPIX C devices
   signal bncInA        : std_logic;                     -- BNC Interface A input
   signal bncInB        : std_logic;                     -- BNC Interface B input
   signal bncOutA       : std_logic;                     -- BNC Interface A output
   signal bncOutB       : std_logic;                     -- BNC Interface B output
   signal nimInA        : std_logic;                     -- NIM Interface A input
   signal nimInB        : std_logic;                     -- NIM Interface B input
   signal adcSData      : std_logic;                     -- ADC Serial Data In
   signal adcSclk       : std_logic;                     -- ADC Serial Clock Out
   signal adcCsL        : std_logic;                     -- ADC Chip Select Out
   signal dacDin        : std_logic;                     -- Cal Data Data
   signal dacSclk       : std_logic;                     -- Cal Data Clock
   signal dacCsL        : std_logic;                     -- Cal Data Chip Select
   signal dacClrL       : std_logic;                     -- Cal Data Clear

   -- Local signals
   signal dllRst        : std_logic;
   signal tmpClk20      : std_logic;
   signal dllClk20      : std_logic;
   signal divCount      : std_logic_vector(9 downto 0);
   signal divClk        : std_logic;
   signal sysClk200     : std_logic;
   signal dllClk200     : std_logic;
   signal trainNumClk   : std_logic;
   signal itrainNumClk  : std_logic;
   signal trainNumCnt   : std_logic_vector(15 downto 0);

begin

   -- Core module
   U_OptoCore: OptoCore port map (
      fpgaRstL  => fpgaRstL,   sysClk20    => sysClk20,
      kpixClk   => kpixClk,    kpixLock    => kpixLock,
      clkSelA   => clkSelA,    clkSelB     => clkSelB,
      clkSelC   => clkSelC,    clkSelD     => clkSelD,
      coreState => coreState,  jumpL       => jumpL,     
      ledL      => ledL,       debug       => debug,
      usbDin    => usbDin,     usbDout     => usbDout,
      usbRdL    => usbRdL,     usbWr       => usbWr,
      usbTxeL   => usbTxeL,    usbRxfL     => usbRxfL,
      usbPwrEnL => usbPwrEnL,  usbDenL     => usbDenL,
      reset     => reset,      forceTrig   => forceTrig,
      commandA  => commandA,   commandB    => commandB,
      commandC  => commandC,   dataA       => dataA,
      dataB     => dataB,      dataC       => dataC,
      bncInA    => bncInA,     bncInB      => bncInB,
      bncOutA   => bncOutA,    bncOutB     => bncOutB,
      nimInA    => nimInA,     nimInB      => nimInB,
      adcSData  => adcSData,   adcSclk     => adcSclk,
      adcCsL    => adcCsL,     dacDin      => dacDin,
      dacSclk   => dacSclk,    dacCsL      => dacCsL,
      dacClrL   => dacClrL,    trainNumClk => trainNumClk
   );


   -- Incoming clock & reset
   U_FpgaRstL : IBUF  port map ( I => iFpgaRstL, O => fpgaRstL );
   U_SysClk20 : IBUFG port map ( I => iSysClk20, O => tmpClk20 );

   -- DLL reset
   dllRst <= not fpgaRstL;

   -- 20Mhz clock multiplier
   U_ClkMultDll : DCM 
      generic map (
         DFS_FREQUENCY_MODE    => "LOW",  DLL_FREQUENCY_MODE    => "LOW",
         DUTY_CYCLE_CORRECTION => FALSE,  CLKIN_DIVIDE_BY_2     => FALSE,
         CLK_FEEDBACK          => "1X",   CLKOUT_PHASE_SHIFT    => "NONE",
         STARTUP_WAIT          => false,  PHASE_SHIFT           => 0,
         CLKFX_MULTIPLY        => 20,     CLKFX_DIVIDE          => 2,
         CLKDV_DIVIDE          => 2.0,
         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
         CLKIN_PERIOD          => 50.0,
         DSS_MODE              => "NONE",
         FACTORY_JF            => X"C080"
      )
      port map (
         CLKIN    => tmpClk20,    CLKFB    => sysClk20,
         CLK0     => dllClk20,    CLK90    => open,
         CLK180   => open,        CLK270   => open, 
         CLK2X    => open,        CLK2X180 => open,
         CLKDV    => open,        CLKFX    => dllClk200,
         CLKFX180 => open,        LOCKED   => kpixLock,
         PSDONE   => open,        STATUS   => open,
         DSSEN    => '0',         PSCLK    => '0',
         PSEN     => '0',         PSINCDEC => '0',
         RST      => dllRst
      );


   -- Connect 20Mhz clock to global buffer
   U_BUF20M: BUFGMUX port map (
      O  => sysClk20,
      I0 => dllClk20,
      I1 => '0',
      S  => '0'
   );


   -- Connect 200Mhz div clock to global buffer
   U_BUF200M: BUFGMUX port map (
      O  => sysClk200,
      I0 => dllClk200,
      I1 => '0',
      S  => '0'
   );

   
   -- Control clock divide counter
   process ( sysClk200, kpixLock ) begin
      if kpixLock = '0' then
         divCount  <= (others=>'0');
         divClk    <= '0';
         clkSel    <= "0000000100";
      elsif rising_edge(sysClk200) then

         -- Invert clock each time count reaches div value
         -- Choose new clock setting at this boundary
         if divCount = clkSel then
            divCount <= (others=>'0');
            divClk   <= not divClk;

            -- Precharge extension
            if coreState = "1010" then
               clkSel <= "1111111111";

            -- Clock rate select
            else case coreState(2 downto 0) is

               -- Idle
               when "000" => clkSel <= "00000" & clkSelD;

               -- Acquisition
               when "001" => clkSel <= "00000" & clkSelA;

               -- Digitization
               when "010" => clkSel <= "00000" & clkSelB;

               -- Readout
               when "100" => clkSel <= "00000" & clkSelC;

               -- Default
               when others => clkSel <= "00000" & clkSelD;
            end case;
            end if;
         else
            divCount <= divCount + 1;
         end if;
      end if;
   end process;


   -- Connect mult clock to global buffer
   U_BUFkpix: BUFGMUX port map (
      O  => kpixClk,
      I0 => divClk,
      I1 => '0',
      S  => '0'
   );


   -- Debug Clock Output
   U_GenDbgClk : FDDRRSE port map ( 
      Q  => dbgClk, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );


   -- Control clock divide counter
   process ( sysClk20, kpixLock ) begin
      if kpixLock = '0' then
         trainNumCnt <= (others=>'0');
      elsif rising_edge(sysClk20) then
         if trainNumCnt = 10000 then
            trainNumCnt  <= (others=>'0');
            itrainNumClk <= not itrainNumClk;
         else
            trainNumCnt  <= trainNumCnt + 1;
         end if;
      end if;
   end process;


   U_BUFTrain: BUFGMUX port map (
      O  => trainNumClk,
      I0 => itrainNumClk,
      I1 => '0',
      S  => '0'
   );


   -- Jumper, Debug & Spare Signals
   U_Jump3        : IBUF port map ( I => iJumpL(3), O => jumpL(3)  );
   U_Jump2        : IBUF port map ( I => iJumpL(2), O => jumpL(2)  );
   U_Jump1        : IBUF port map ( I => iJumpL(1), O => jumpL(1)  );
   U_Jump0        : IBUF port map ( I => iJumpL(0), O => jumpL(0)  );
   U_Led3         : OBUF port map ( I => ledL(3),   O => oLedL(3)  );
   U_Led2         : OBUF port map ( I => ledL(2),   O => oLedL(2)  );
   U_Led1         : OBUF port map ( I => ledL(1),   O => oLedL(1)  );
   U_Led0         : OBUF port map ( I => ledL(0),   O => oLedL(0)  );
   U_Debug31      : OBUF port map ( I => debug(31), O => oDebug(31));
   U_Debug30      : OBUF port map ( I => debug(30), O => oDebug(30));
   U_Debug29      : OBUF port map ( I => debug(29), O => oDebug(29));
   U_Debug28      : OBUF port map ( I => debug(28), O => oDebug(28));
   U_Debug27      : OBUF port map ( I => debug(27), O => oDebug(27));
   U_Debug26      : OBUF port map ( I => debug(26), O => oDebug(26));
   U_Debug25      : OBUF port map ( I => debug(25), O => oDebug(25));
   U_Debug24      : OBUF port map ( I => debug(24), O => oDebug(24));
   U_Debug23      : OBUF port map ( I => debug(23), O => oDebug(23));
   U_Debug22      : OBUF port map ( I => debug(22), O => oDebug(22));
   U_Debug21      : OBUF port map ( I => debug(21), O => oDebug(21));
   U_Debug20      : OBUF port map ( I => debug(20), O => oDebug(20));
   U_Debug19      : OBUF port map ( I => debug(19), O => oDebug(19));
   U_Debug18      : OBUF port map ( I => debug(18), O => oDebug(18));
   U_Debug17      : OBUF port map ( I => debug(17), O => oDebug(17));
   U_Debug16      : OBUF port map ( I => debug(16), O => oDebug(16));
   U_Debug15      : OBUF port map ( I => debug(15), O => oDebug(15));
   U_Debug14      : OBUF port map ( I => debug(14), O => oDebug(14));
   U_Debug13      : OBUF port map ( I => debug(13), O => oDebug(13));
   U_Debug12      : OBUF port map ( I => debug(12), O => oDebug(12));
   U_Debug11      : OBUF port map ( I => debug(11), O => oDebug(11));
   U_Debug10      : OBUF port map ( I => debug(10), O => oDebug(10));
   U_Debug9       : OBUF port map ( I => debug(9),  O => oDebug(9));
   U_Debug8       : OBUF port map ( I => debug(8),  O => oDebug(8));
   U_Debug7       : OBUF port map ( I => debug(7),  O => oDebug(7));
   U_Debug6       : OBUF port map ( I => debug(6),  O => oDebug(6));
   U_Debug5       : OBUF port map ( I => debug(5),  O => oDebug(5));
   U_Debug4       : OBUF port map ( I => debug(4),  O => oDebug(4));
   U_Debug3       : OBUF port map ( I => debug(3),  O => oDebug(3));
   U_Debug2       : OBUF port map ( I => debug(2),  O => oDebug(2));
   U_Debug1       : OBUF port map ( I => debug(1),  O => oDebug(1));
   U_Debug0       : OBUF port map ( I => debug(0),  O => oDebug(0));
   U_DbgClk       : OBUF port map ( I => dbgClk,    O => oDbgClk);
   U_ForceTrig    : OBUF port map ( I => forceTrig, O => oForceTrig);

   -- USB Controller
   U_UsbData7     : IOBUF port map ( I => usbDout(7), O => usbDin(7), T => usbDenL, IO => ioUsbData(7));
   U_UsbData6     : IOBUF port map ( I => usbDout(6), O => usbDin(6), T => usbDenL, IO => ioUsbData(6));
   U_UsbData5     : IOBUF port map ( I => usbDout(5), O => usbDin(5), T => usbDenL, IO => ioUsbData(5));
   U_UsbData4     : IOBUF port map ( I => usbDout(4), O => usbDin(4), T => usbDenL, IO => ioUsbData(4));
   U_UsbData3     : IOBUF port map ( I => usbDout(3), O => usbDin(3), T => usbDenL, IO => ioUsbData(3));
   U_UsbData2     : IOBUF port map ( I => usbDout(2), O => usbDin(2), T => usbDenL, IO => ioUsbData(2));
   U_UsbData1     : IOBUF port map ( I => usbDout(1), O => usbDin(1), T => usbDenL, IO => ioUsbData(1));
   U_UsbData0     : IOBUF port map ( I => usbDout(0), O => usbDin(0), T => usbDenL, IO => ioUsbData(0));
   U_UsbRd        : OBUF  port map ( I => usbRdL,     O => oUsbRdL);
   U_UsbWr        : OBUF  port map ( I => usbWr,      O => oUsbWr);
   U_UsbTxe       : IBUF  port map ( I => iUsbTxeL,   O => usbTxeL);
   U_UsbRxf       : IBUF  port map ( I => iUsbRxfL,   O => usbRxfL);
   U_UsbPwrEn     : IBUF  port map ( I => iUsbPwrEnL, O => usbPwrEnL);

   -- Optical Interface
   kpixClkL <= not kpixClk;
   U_GenSysclk : FDDRRSE port map ( 
      Q  => sysclk, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );
   U_SysclkO      : OBUF  port map ( I => sysclk,   O => oSysclk);
   U_Reset        : OBUF  port map ( I => reset,    O => oReset);
   U_CommandA     : OBUF  port map ( I => commandA, O => oCommandA);
   U_CommandB     : OBUF  port map ( I => commandB, O => oCommandB);
   U_CommandC     : OBUF  port map ( I => commandC, O => oCommandC);
   U_DataA        : IBUF  port map ( I => iDataA,   O => dataA);
   U_DataB        : IBUF  port map ( I => iDataB,   O => dataB);
   U_DataC        : IBUF  port map ( I => iDataC,   O => dataC);

   -- Misc Signal Interface
   U_BncInA       : IBUF  port map ( I => iBncInA,  O => bncInA);
   U_BncInB       : IBUF  port map ( I => iBncInB,  O => bncInB);
   U_BncOutA      : OBUF  port map ( I => bncOutA,  O => oBncOutA);
   U_BncOutB      : OBUF  port map ( I => bncOutB,  O => oBncOutB);
   U_NimInA       : IBUF  port map ( I => iNimInA,  O => nimInA);
   U_NimInB       : IBUF  port map ( I => iNimInB,  O => nimInB);

   -- ADC Interface
   U_AdcSdata     : IBUF  port map ( I => iAdcSdata, O => adcSdata);
   U_AdcSclk      : OBUF  port map ( I => adcSclk,   O => oAdcSclk);
   U_AdcCsL       : OBUF  port map ( I => adcCsL,    O => oAdcCsL);

   -- Calibration DAC
   U_DacDin        : OBUF  port map ( I => dacDin,  O => oDacDin);
   U_DacSclk       : OBUF  port map ( I => dacSclk, O => oDacSclk);
   U_DacCsL        : OBUF  port map ( I => dacCsL,  O => oDacCsL);
   U_DacClrL       : OBUF  port map ( I => dacClrL, O => oDacClrL);

end Opto;

