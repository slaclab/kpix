-------------------------------------------------------------------------------
-- Title         : KPIX KpixCon FPGA Top Level Module
-- Project       : W_SI, KPIX KpixCon Board
-------------------------------------------------------------------------------
-- File          : KpixCon.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/07/2010
-------------------------------------------------------------------------------
-- Description:
-- Top level VHDL source file for the test FPGA pn the KPIX KpixCon Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/07/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.KpixConPkg.all;
USE work.ALL;
use UNISIM.VCOMPONENTS.ALL;

entity KpixCon is 
   port ( 

      -- System clock, reset
      iFpgaRstL      : in    std_logic;                     -- Asynchronous local reset
      iSysClk125P    : in    std_logic;                     -- 20Mhz system clock positive
      iSysClk125N    : in    std_logic;                     -- 20Mhz system clock negative  

      -- Jumper, Debug & Spare Signals
      iJumpL         : in    std_logic_vector(3  downto 0); -- KpixCon jumpers, active low
      oLedL          : out   std_logic_vector(3  downto 0); -- FPGA LEDs
      oForceTrig     : out   std_logic;

      -- Optical Interface
      oClkOutA       : inout std_logic;                     -- Clock to KPIX devices
      oClkOutB       : inout std_logic;                     -- Clock to KPIX devices
      oClkOutC       : inout std_logic;                     -- Clock to KPIX devices
      oClkOutD       : inout std_logic;                     -- Clock to KPIX devices
      oReset         : out   std_logic;                     -- Reset to KPIX devices
      oCommand       : out   std_logic_vector(31 downto 0); -- Command to KPIX devices
      iData          : in    std_logic_vector(31 downto 0); -- Data from from KPIX devices
      
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
      oDacClrL       : out   std_logic;                     -- Cal Data Clear

      -- SRAM 0 interface
      ddr0ClkOutP    : out   std_logic;
      ddr0ClkOutN    : out   std_logic;
      ddr0RdNWr      : out   std_logic;                     -- ddr0 R/W
      ddr0LdL        : out   std_logic;                     -- ddr0 active low Load
      ddr0Data       : inout std_logic_vector(17 downto 0); -- ddr0 data bus
      ddr0Addr       : out   std_logic_vector(21 downto 0); -- ddr0 address bus

      -- SRAM 1 interface
      ddr1ClkOutP    : out   std_logic;
      ddr1ClkOutN    : out   std_logic;
      ddr1RdNWr      : out   std_logic;                     -- ddr1 R/W
      ddr1LdL        : out   std_logic;                     -- ddr1 active low Load
      ddr1Data       : inout std_logic_vector(17 downto 0); -- ddr1 data bus
      ddr1Addr       : out   std_logic_vector(21 downto 0); -- ddr1 address bus
      
      -- Ethernet Interface
      oTXP_0         : out std_logic;
      oTXN_0         : out std_logic;
      iRXP_0         : in  std_logic;
      iRXN_0         : in  std_logic;
      oTXN_1_UNUSED  : out std_logic;
      oTXP_1_UNUSED  : out std_logic;
      iRXN_1_UNUSED  : in  std_logic;
      iRXP_1_UNUSED  : in  std_logic;

      -- GTP Reference Clock
      MGTCLK_P       : in  std_logic;
      MGTCLK_N       : in  std_logic
   );
end KpixCon;


-- Define architecture for top level module
architecture KpixCon of KpixCon is 

   -- Synthesis control attributes
   attribute syn_useioff    : boolean;
   attribute syn_useioff    of KpixCon : architecture is true;
   attribute xc_fast_auto   : boolean;
   attribute xc_fast_auto   of KpixCon : architecture is false;
   attribute syn_noclockbuf : boolean;
   attribute syn_noclockbuf of KpixCon : architecture is true;
   
   -- IO Pad components
   component IBUF     port ( O : out std_logic; I  : in std_logic ); end component;
   component IBUFG    port ( O : out std_logic; I  : in std_logic ); end component;
   component BUFG     port ( O : out std_logic; I  : in std_logic ); end component;
   component OBUF     port ( O : out std_logic; I  : in std_logic ); end component;
   component IBUFGDS  port ( O : out std_logic; I  : in std_logic; IB  : in std_logic ); end component;
   
   -- BiDir Pad
   component IOBUF  
      port ( 
         O  : out   std_logic; 
         IO : inout std_logic; 
         I  : in    std_logic;
         T  : in    std_logic 
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
         --DUTY_CYCLE_CORRECTION : boolean;
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
   for all : IBUFGDS use entity Unisim.IBUFGDS (ibufgds_v);
   for all : OBUF    use entity Unisim.OBUF    (obuf_v);
   for all : IOBUF   use entity Unisim.IOBUF   (iobuf_v);
   for all : BUFGMUX use entity Unisim.BUFGMUX (bufgmux_v);
   for all : BUFIO   use entity Unisim.BUFIO   (bufio_v);
   for all : BUFR    use entity Unisim.BUFR    (bufr_v);
   for all : BUFG    use entity Unisim.BUFG    (bufg_v);
   -- synopsys translate_on


   -- Interface Signals
   signal fpgaRstL      : std_logic;                     -- Asynchronous local reset
   signal kpixClk       : std_logic;                     --
   signal kpixClkL      : std_logic;                     --
   signal kpixLock      : std_logic;                     --
   signal jumpL         : std_logic_vector(3  downto 0); -- Test jumpers, active low
   signal clkSel        : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelA       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelB       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelC       : std_logic_vector(4  downto 0); -- Clock selection
   signal clkSelD       : std_logic_vector(4  downto 0); -- Clock selection
   signal coreState     : std_logic_vector(2  downto 0); -- State of internal core
   signal ledL          : std_logic_vector(3  downto 0); -- FPGA LEDs
   signal forceTrig     : std_logic;
   signal sysclkA       : std_logic;                     -- Clock to KPIX devices
   signal sysclkB       : std_logic;                     -- Clock to KPIX devices
   signal sysclkC       : std_logic;                     -- Clock to KPIX devices
   signal sysclkD       : std_logic;                     -- Clock to KPIX devices
   signal reset         : std_logic;                     -- Reset to KPIX devices
   signal resetL        : std_logic;                     -- Reset to KPIX devices
   signal command       : std_logic_vector(31 downto 0); -- Command to KPIX devices
   signal commandL      : std_logic_vector(31 downto 0); -- Inverted command to KPIX devices
   signal data          : std_logic_vector(31 downto 0); -- Data from from KPIX devices
   signal dataL         : std_logic_vector(31 downto 0); -- Inverted data from from KPIX devices
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
   signal TXP_0         : std_logic;                     -- Ethernet Transmiter Data
   signal TXN_0         : std_logic;                     -- Ethernet Transmiter Data
   signal RXP_0         : std_logic;                     -- Ethernet Receiver Data
   signal RXN_0         : std_logic;                     -- Ethernet Receiver Data
   signal TXN_1_UNUSED  : std_logic;                     -- Ethernet Transmiter Data
   signal TXP_1_UNUSED  : std_logic;                     -- Ethernet Transmiter Data
   signal RXN_1_UNUSED  : std_logic;                     -- Ethernet Receiver Data
   signal RXP_1_UNUSED  : std_logic;                     -- Ethernet Receiver Data
   
   -- Local signals
   signal dllRst        : std_logic;
   signal tmpClk125     : std_logic;
   signal sysClk125     : std_logic;
   signal tmpClk270     : std_logic;
   signal sysClk270     : std_logic;
   signal dllClk125     : std_logic;
   signal divCount      : std_logic_vector(4 downto 0);
   signal divClk        : std_logic;
   signal sysClk200     : std_logic;
   signal dllClk200     : std_logic;
   signal gtpClk        : std_logic;
   signal gtpClkOut     : std_logic;
   signal gtpClkRef     : std_logic;
   signal dllDdrClk     : std_logic;
   signal ddrClk        : std_logic;
   signal ddrRst        : std_logic;
   signal ddrRstCnt     : std_logic_vector(3 downto 0);
   signal ddrLocked     : std_logic;
   signal syncDdrRstIn  : std_logic_vector(2 downto 0);
   signal ddrRstIn      : std_logic;
   signal oDdr0Addr     : std_logic_vector(21 downto 0);
   signal oDdr1Addr     : std_logic_vector(21 downto 0);
   signal rdClkDelay    : std_logic_vector(4 downto 0);
   signal rdClkEdge     : std_logic;
   signal kpixRd        : std_logic;
   
begin

   -- Invert signals to make up for mistake in board
   resetL   <= not reset;
   commandL <= not command;
   data     <= ((not dataL) and x"55555555") or (dataL and x"aaaaaaaa"); --Interweaving data and dataL
   
   -- Core module
   U_KpixConCore: KpixConCore port map (
      fpgaRstL      => fpgaRstL,         sysClk       => sysClk125,
      kpixClk       => kpixClk,          sysClk200    => sysClk200,
      kpixLock      => kpixLock,         divCount     => divCount,
      ddrClk        => ddrClk,           ddrRst       => ddrRst,
      clkSelA       => clkSelA,          clkSelB      => clkSelB,
      clkSelC       => clkSelC,          clkSelD      => clkSelD,
      coreState     => coreState,        jumpL        => jumpL,
      ledL          => ledL,             reset        => reset,
      forceTrig     => forceTrig,        kpixRd       => kpixRd,
      ddr0RdNWr     => ddr0RdNWr,        ddr0LdL      => ddr0LdL,
      ddr0Data      => ddr0Data,         ddr0Addr     => oDdr0Addr,
      ddr1RdNWr     => ddr1RdNWr,        ddr1LdL      => ddr1LdL,
      ddr1Data      => ddr1Data,         ddr1Addr     => oDdr1Addr,
      command       => command,          data         => data,
      kpixRdPhase   => rdClkDelay,       kpixRdEdge   => rdClkEdge,
      bncInA        => bncInA,           bncInB       => bncInB,
      bncOutA       => bncOutA,          bncOutB      => bncOutB,
      nimInA        => nimInA,           nimInB       => nimInB,
      adcSData      => adcSData,         adcSclk      => adcSclk,
      adcCsL        => adcCsL,           dacDin       => dacDin,
      dacSclk       => dacSclk,          dacCsL       => dacCsL,
      dacClrL       => dacClrL,          TXP_0        => TXP_0,
      TXN_0         => TXN_0,            RXP_0        => RXP_0,
      RXN_0         => RXN_0,            TXN_1_UNUSED => TXN_1_UNUSED,
      TXP_1_UNUSED  => TXP_1_UNUSED,     RXN_1_UNUSED => RXN_1_UNUSED,
      RXP_1_UNUSED  => RXP_1_UNUSED,     gtpClk       => gtpClk,
      gtpClkRef     => gtpClkRef,        gtpClkOut    => gtpClkOut
   );


   -- Incoming clock & reset
   U_FpgaRstL : IBUF    port map ( I => iFpgaRstL, O => fpgaRstL );
   U_SysClk125: IBUFGDS port map ( I => iSysClk125P, IB => iSysClk125N, O => tmpClk125 );
   U_GtpClk   : IBUFGDS port map ( I => MGTCLK_P,    IB => MGTCLK_N,    O => gtpClk );
   U_GtpClkRef: BUFG    port map ( I => gtpClkOut,  O => gtpClkRef );

   -- DLL reset
   dllRst <= not fpgaRstL;

   -- 200Mhz clock multiplier
   U_ClkMultDll : DCM_ADV 
      generic map (
         DFS_FREQUENCY_MODE    => "LOW",  DLL_FREQUENCY_MODE    => "HIGH",
         --DUTY_CYCLE_CORRECTION => false,
         CLKIN_DIVIDE_BY_2     => false,
         CLK_FEEDBACK          => "1X",   CLKOUT_PHASE_SHIFT    => "NONE",
         STARTUP_WAIT          => false,  PHASE_SHIFT           => 0,
         CLKFX_MULTIPLY        => 8,      CLKFX_DIVIDE          => 5, -- 125*8/5 = 200 MHz
         CLKDV_DIVIDE          => 2.0,
         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
         DCM_PERFORMANCE_MODE  => "MAX_SPEED", 
         CLKIN_PERIOD          => 8.0,
         FACTORY_JF            => X"F0F0"
      )
      port map (
         CLKIN    => tmpClk125,   CLKFB    => sysClk125,
         CLK0     => dllClk125,   CLK90    => open,
         CLK180   => open,        CLK270   => tmpClk270, 
         CLK2X    => open,        CLK2X180 => open,
         CLKDV    => open,        CLKFX    => dllClk200,
         CLKFX180 => open,        LOCKED   => kpixLock,
         PSDONE   => open,
         PSCLK    => '0',
         PSEN     => '0',
         PSINCDEC => '0',
         RST      => dllRst,
         DCLK     => '0',
         DADDR    => (others=>'0'),
         DI       => (others=>'0'),
         DO       => open,
         DRDY     => open,
         DWE      => '0',
         DEN      => '0'
      );

   -- Connect 200Mhz clock to global buffer
   U_BUF200M: BUFGMUX port map (
      O  => sysClk200,
      I0 => dllClk200,
      I1 => '0',
      S  => '0'
   );

   -- Connect 125Mhz clock to global buffer
   U_BUF125M: BUFGMUX port map (
      O  => sysClk125,
      I0 => dllClk125,
      I1 => '0',
      S  => '0'
   );

   -- Global Buffer For Phase Clock
   U_BUF125M270: BUFGMUX port map (
      O  => sysClk270,
      I0 => tmpClk270,
      I1 => '0',
      S  => '0'
   );

   -- Control clock divide counter
   process ( sysClk200, kpixLock ) begin
      if kpixLock = '0' then
         divCount  <= (others=>'0');
         divClk    <= '0';
         kpixRd    <= '0';
         clkSel    <= "00100";
      elsif rising_edge(sysClk200) then
      
         -- Generate read enable strobe
         if divCount = rdClkDelay and divClk = rdClkEdge then
            kpixRd <= '1';
         else
            kpixRd <= '0';
         end if;

         -- Invert clock each time count reaches div value
         -- Choose new clock setting at this boundary
         if divCount = clkSel then
            divCount <= (others=>'0');
            divClk   <= not divClk;

            -- Clock rate select
            case coreState is

               -- Idle
               when "000" => clkSel <= clkSelD;

               -- Acquisition
               when "001" => clkSel <= clkSelA;

               -- Digitization
               when "010" => clkSel <= clkSelB;

               -- Readout
               when "100" => clkSel <= clkSelC;

               -- Default
               when others => clkSel <= clkSelD;
            end case;
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
   
   -- Jumper, Debug & Spare Signals
   U_Jump3        : IBUF port map ( I => iJumpL(3), O => jumpL(3)  );
   U_Jump2        : IBUF port map ( I => iJumpL(2), O => jumpL(2)  );
   U_Jump1        : IBUF port map ( I => iJumpL(1), O => jumpL(1)  );
   U_Jump0        : IBUF port map ( I => iJumpL(0), O => jumpL(0)  );
   U_Led3         : OBUF port map ( I => ledL(3),   O => oLedL(3)  );
   U_Led2         : OBUF port map ( I => ledL(2),   O => oLedL(2)  );
   U_Led1         : OBUF port map ( I => ledL(1),   O => oLedL(1)  );
   U_Led0         : OBUF port map ( I => ledL(0),   O => oLedL(0)  );
   U_ForceTrig    : OBUF port map ( I => forceTrig, O => oForceTrig);

   -- Optical Interface
   U_TXP_0        : OBUF  port map ( I => TXP_0,         O => oTXP_0);
   U_TXN_0        : OBUF  port map ( I => TXN_0,         O => oTXN_0);
   U_RXP_0        : IBUF  port map ( I => iRXP_0,        O => RXP_0);
   U_RXN_0        : IBUF  port map ( I => iRXN_0,        O => RXN_0);
   U_TXN_1_UNUSED : OBUF  port map ( I => TXN_1_UNUSED,  O => oTXN_1_UNUSED);
   U_TXP_1_UNUSED : OBUF  port map ( I => TXP_1_UNUSED,  O => oTXP_1_UNUSED);
   U_RXN_1_UNUSED : IBUF  port map ( I => iRXN_1_UNUSED, O => RXN_1_UNUSED);
   U_RXP_1_UNUSED : IBUF  port map ( I => iRXP_1_UNUSED, O => RXP_1_UNUSED);
   
   kpixClkL <= not kpixClk;
   U_GenSysclkA : FDDRRSE port map ( 
      Q  => sysclkA, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );
   U_GenSysclkB : FDDRRSE port map ( 
      Q  => sysclkB, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );
   U_GenSysclkC : FDDRRSE port map ( 
      Q  => sysclkC, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );
   U_GenSysclkD : FDDRRSE port map ( 
      Q  => sysclkD, 
      CE => '1',
      C0 => kpixClkL,
      C1 => kpixClk,
      D0 => '1',      
      D1 => '0',      
      R  => '0',      
      S  => '0'
   );
   U_ClkOutA      : OBUF  port map ( I => sysclkA,  O => oClkOutA);
   U_ClkOutB      : OBUF  port map ( I => sysclkB,  O => oClkOutB);
   U_ClkOutC      : OBUF  port map ( I => sysclkC,  O => oClkOutC);
   U_ClkOutD      : OBUF  port map ( I => sysclkD,  O => oClkOutD);
   U_Reset        : OBUF  port map ( I => resetL,   O => oReset);

   U_Command0     : OBUF  port map ( O => oCommand(0),  I => commandL(0));
   U_Command1     : OBUF  port map ( O => oCommand(1),  I => command(1));
   U_Command2     : OBUF  port map ( O => oCommand(2),  I => commandL(2));
   U_Command3     : OBUF  port map ( O => oCommand(3),  I => command(3));
   U_Command4     : OBUF  port map ( O => oCommand(4),  I => commandL(4));
   U_Command5     : OBUF  port map ( O => oCommand(5),  I => command(5));
   U_Command6     : OBUF  port map ( O => oCommand(6),  I => commandL(6));
   U_Command7     : OBUF  port map ( O => oCommand(7),  I => command(7));
   U_Command8     : OBUF  port map ( O => oCommand(8),  I => commandL(8));
   U_Command9     : OBUF  port map ( O => oCommand(9),  I => command(9));
   U_Command10    : OBUF  port map ( O => oCommand(10), I => commandL(10));
   U_Command11    : OBUF  port map ( O => oCommand(11), I => command(11));
   U_Command12    : OBUF  port map ( O => oCommand(12), I => commandL(12));
   U_Command13    : OBUF  port map ( O => oCommand(13), I => command(13));
   U_Command14    : OBUF  port map ( O => oCommand(14), I => commandL(14));
   U_Command15    : OBUF  port map ( O => oCommand(15), I => command(15));
   U_Command16    : OBUF  port map ( O => oCommand(16), I => commandL(16));
   U_Command17    : OBUF  port map ( O => oCommand(17), I => command(17));
   U_Command18    : OBUF  port map ( O => oCommand(18), I => commandL(18));
   U_Command19    : OBUF  port map ( O => oCommand(19), I => command(19));
   U_Command20    : OBUF  port map ( O => oCommand(20), I => commandL(20));
   U_Command21    : OBUF  port map ( O => oCommand(21), I => command(21));
   U_Command22    : OBUF  port map ( O => oCommand(22), I => commandL(22));
   U_Command23    : OBUF  port map ( O => oCommand(23), I => command(23));
   U_Command24    : OBUF  port map ( O => oCommand(24), I => commandL(24));
   U_Command25    : OBUF  port map ( O => oCommand(25), I => command(25));
   U_Command26    : OBUF  port map ( O => oCommand(26), I => commandL(26));
   U_Command27    : OBUF  port map ( O => oCommand(27), I => command(27));
   U_Command28    : OBUF  port map ( O => oCommand(28), I => commandL(28));
   U_Command29    : OBUF  port map ( O => oCommand(29), I => command(29));
   U_Command30    : OBUF  port map ( O => oCommand(30), I => commandL(30));
   U_Command31    : OBUF  port map ( O => oCommand(31), I => command(31));

   U_Data0        : IBUF  port map ( I => iData(0),  O => dataL(0));
   U_Data1        : IBUF  port map ( I => iData(1),  O => dataL(1));
   U_Data2        : IBUF  port map ( I => iData(2),  O => dataL(2));
   U_Data3        : IBUF  port map ( I => iData(3),  O => dataL(3));
   U_Data4        : IBUF  port map ( I => iData(4),  O => dataL(4));
   U_Data5        : IBUF  port map ( I => iData(5),  O => dataL(5));
   U_Data6        : IBUF  port map ( I => iData(6),  O => dataL(6));
   U_Data7        : IBUF  port map ( I => iData(7),  O => dataL(7));
   U_Data8        : IBUF  port map ( I => iData(8),  O => dataL(8));
   U_Data9        : IBUF  port map ( I => iData(9),  O => dataL(9));
   U_Data10       : IBUF  port map ( I => iData(10), O => dataL(10));
   U_Data11       : IBUF  port map ( I => iData(11), O => dataL(11));
   U_Data12       : IBUF  port map ( I => iData(12), O => dataL(12));
   U_Data13       : IBUF  port map ( I => iData(13), O => dataL(13));
   U_Data14       : IBUF  port map ( I => iData(14), O => dataL(14));
   U_Data15       : IBUF  port map ( I => iData(15), O => dataL(15));
   U_Data16       : IBUF  port map ( I => iData(16), O => dataL(16));
   U_Data17       : IBUF  port map ( I => iData(17), O => dataL(17));
   U_Data18       : IBUF  port map ( I => iData(18), O => dataL(18));
   U_Data19       : IBUF  port map ( I => iData(19), O => dataL(19));
   U_Data20       : IBUF  port map ( I => iData(20), O => dataL(20));
   U_Data21       : IBUF  port map ( I => iData(21), O => dataL(21));
   U_Data22       : IBUF  port map ( I => iData(22), O => dataL(22));
   U_Data23       : IBUF  port map ( I => iData(23), O => dataL(23));
   U_Data24       : IBUF  port map ( I => iData(24), O => dataL(24));
   U_Data25       : IBUF  port map ( I => iData(25), O => dataL(25));
   U_Data26       : IBUF  port map ( I => iData(26), O => dataL(26));
   U_Data27       : IBUF  port map ( I => iData(27), O => dataL(27));
   U_Data28       : IBUF  port map ( I => iData(28), O => dataL(28));
   U_Data29       : IBUF  port map ( I => iData(29), O => dataL(29));
   U_Data30       : IBUF  port map ( I => iData(30), O => dataL(30));
   U_Data31       : IBUF  port map ( I => iData(31), O => dataL(31));

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

   ---------------------------------
   -- SRAM Clocking
   ---------------------------------

   -- POS 0
   U_Gen0KClkP : ODDR port map ( 
      Q  => ddr0ClkOutP,
      C  => sysClk270,
      CE => '1',
      D1 => '1',      
      D2 => '0',      
      R  => '0',      
      S  => '0'
   );

   -- NEG 0
   U_Gen0KClkN : ODDR port map (
      Q  => ddr0ClkOutN,
      C  => sysClk270,
      CE => '1',
      D1 => '0',      
      D2 => '1',      
      R  => '0',      
      S  => '0'
   );

   -- POS 1
   U_Gen1KClkP : ODDR port map ( 
      Q  => ddr1ClkOutP,
      C  => sysClk270,
      CE => '1',
      D1 => '1',      
      D2 => '0',      
      R  => '0',      
      S  => '0'
   );

   -- NEG 1
   U_Gen1KClkN : ODDR port map (
      Q  => ddr1ClkOutN,
      C  => sysClk270,
      CE => '1',
      D1 => '0',      
      D2 => '1',      
      R  => '0',      
      S  => '0'
   );

   -- DCM For PGP Clock & User Clock
   U_DdrDcm: DCM_ADV
      generic map (
         DFS_FREQUENCY_MODE    => "LOW",       
         DLL_FREQUENCY_MODE    => "HIGH",
         CLKIN_DIVIDE_BY_2     => FALSE,
         CLK_FEEDBACK          => "1X",        
         CLKOUT_PHASE_SHIFT    => "FIXED",
         STARTUP_WAIT          => false,       
         PHASE_SHIFT           => 140,
         CLKFX_MULTIPLY        => 2,
         CLKFX_DIVIDE          => 1,
         CLKDV_DIVIDE          => 2.0,         
         CLKIN_PERIOD          => 8.0,
         DCM_PERFORMANCE_MODE  => "MAX_SPEED", 
         FACTORY_JF            => X"F0F0",
         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS"
      )
      port map (
         CLKIN    => sysClk125,     CLKFB    => ddrClk,
         CLK0     => dllDdrClk,     CLK90    => open,
         CLK180   => open,          CLK270   => open, 
         CLK2X    => open,          CLK2X180 => open,
         CLKDV    => open,          CLKFX    => open,
         CLKFX180 => open,          LOCKED   => ddrLocked,
         PSDONE   => open,          PSCLK    => '0',
         PSINCDEC => '0',           PSEN     => '0',
         DCLK     => '0',           DADDR    => (others=>'0'),
         DI       => (others=>'0'), DO       => open,
         DRDY     => open,          DWE      => '0',
         DEN      => '0',           RST      => dllRst
      );

   -- Connect generated clock to global buffer
   U_BUFDDR: BUFG port map (
      O  => ddrClk,
      I  => dllDdrClk
   );

   -- Reset source
   ddrRstIn <= (not ddrLocked) or dllRst;

   -- DDR Clock Synced Reset
   process ( ddrClk, ddrRstIn ) begin
      if ddrRstIn = '1' then
         syncDdrRstIn <= (others=>'0') after tpd;
         ddrRstCnt    <= (others=>'0') after tpd;
         ddrRst       <= '1'           after tpd;
      elsif rising_edge(ddrClk) then

         -- Sync local reset, lock and power on reset to local clock
         -- Negative asserted signal
         syncDdrRstIn(0) <= '1'             after tpd;
         syncDdrRstIn(1) <= syncDdrRstIn(0) after tpd;
         syncDdrRstIn(2) <= syncDdrRstIn(1) after tpd;

         -- Reset counter on reset
         if syncDdrRstIn(2) = '0' then
            ddrRstCnt <= (others=>'0') after tpd;
            ddrRst    <= '1' after tpd;

         -- Count Up To Max Value
         elsif ddrRstCnt = "1111" then
            ddrRst <= '0' after tpd;

         -- Increment counter
         else
            ddrRst    <= '1' after tpd;
            ddrRstCnt <= ddrRstCnt + 1 after tpd;
         end if;
      end if;
   end process;

   U_Ddr0Addr0      : OBUF  port map ( O => ddr0Addr(0),   I => oDdr0Addr(0));
   U_Ddr0Addr1      : OBUF  port map ( O => ddr0Addr(1),   I => oDdr0Addr(1));
   U_Ddr0Addr2      : OBUF  port map ( O => ddr0Addr(2),   I => oDdr0Addr(2));
   U_Ddr0Addr3      : OBUF  port map ( O => ddr0Addr(3),   I => oDdr0Addr(3));
   U_Ddr0Addr4      : OBUF  port map ( O => ddr0Addr(4),   I => oDdr0Addr(4));
   U_Ddr0Addr5      : OBUF  port map ( O => ddr0Addr(5),   I => oDdr0Addr(5));
   U_Ddr0Addr6      : OBUF  port map ( O => ddr0Addr(6),   I => oDdr0Addr(6));
   U_Ddr0Addr7      : OBUF  port map ( O => ddr0Addr(7),   I => oDdr0Addr(7));
   U_Ddr0Addr8      : OBUF  port map ( O => ddr0Addr(8),   I => oDdr0Addr(8));
   U_Ddr0Addr9      : OBUF  port map ( O => ddr0Addr(9),   I => oDdr0Addr(9));
   U_Ddr0Addr10     : OBUF  port map ( O => ddr0Addr(10),  I => oDdr0Addr(10));
   U_Ddr0Addr11     : OBUF  port map ( O => ddr0Addr(11),  I => oDdr0Addr(11));
   U_Ddr0Addr12     : OBUF  port map ( O => ddr0Addr(12),  I => oDdr0Addr(12));
   U_Ddr0Addr13     : OBUF  port map ( O => ddr0Addr(13),  I => oDdr0Addr(13));
   U_Ddr0Addr14     : OBUF  port map ( O => ddr0Addr(14),  I => oDdr0Addr(14));
   U_Ddr0Addr15     : OBUF  port map ( O => ddr0Addr(15),  I => oDdr0Addr(15));
   U_Ddr0Addr16     : OBUF  port map ( O => ddr0Addr(16),  I => oDdr0Addr(16));
   U_Ddr0Addr17     : OBUF  port map ( O => ddr0Addr(17),  I => oDdr0Addr(17));
   U_Ddr0Addr18     : OBUF  port map ( O => ddr0Addr(18),  I => oDdr0Addr(18));
   U_Ddr0Addr19     : OBUF  port map ( O => ddr0Addr(19),  I => oDdr0Addr(19));
   U_Ddr0Addr20     : OBUF  port map ( O => ddr0Addr(20),  I => oDdr0Addr(20));
   U_Ddr0Addr21     : OBUF  port map ( O => ddr0Addr(21),  I => oDdr0Addr(21));

   U_Ddr1Addr0      : OBUF  port map ( O => ddr1Addr(0),   I => oDdr1Addr(0));
   U_Ddr1Addr1      : OBUF  port map ( O => ddr1Addr(1),   I => oDdr1Addr(1));
   U_Ddr1Addr2      : OBUF  port map ( O => ddr1Addr(2),   I => oDdr1Addr(2));
   U_Ddr1Addr3      : OBUF  port map ( O => ddr1Addr(3),   I => oDdr1Addr(3));
   U_Ddr1Addr4      : OBUF  port map ( O => ddr1Addr(4),   I => oDdr1Addr(4));
   U_Ddr1Addr5      : OBUF  port map ( O => ddr1Addr(5),   I => oDdr1Addr(5));
   U_Ddr1Addr6      : OBUF  port map ( O => ddr1Addr(6),   I => oDdr1Addr(6));
   U_Ddr1Addr7      : OBUF  port map ( O => ddr1Addr(7),   I => oDdr1Addr(7));
   U_Ddr1Addr8      : OBUF  port map ( O => ddr1Addr(8),   I => oDdr1Addr(8));
   U_Ddr1Addr9      : OBUF  port map ( O => ddr1Addr(9),   I => oDdr1Addr(9));
   U_Ddr1Addr10     : OBUF  port map ( O => ddr1Addr(10),  I => oDdr1Addr(10));
   U_Ddr1Addr11     : OBUF  port map ( O => ddr1Addr(11),  I => oDdr1Addr(11));
   U_Ddr1Addr12     : OBUF  port map ( O => ddr1Addr(12),  I => oDdr1Addr(12));
   U_Ddr1Addr13     : OBUF  port map ( O => ddr1Addr(13),  I => oDdr1Addr(13));
   U_Ddr1Addr14     : OBUF  port map ( O => ddr1Addr(14),  I => oDdr1Addr(14));
   U_Ddr1Addr15     : OBUF  port map ( O => ddr1Addr(15),  I => oDdr1Addr(15));
   U_Ddr1Addr16     : OBUF  port map ( O => ddr1Addr(16),  I => oDdr1Addr(16));
   U_Ddr1Addr17     : OBUF  port map ( O => ddr1Addr(17),  I => oDdr1Addr(17));
   U_Ddr1Addr18     : OBUF  port map ( O => ddr1Addr(18),  I => oDdr1Addr(18));
   U_Ddr1Addr19     : OBUF  port map ( O => ddr1Addr(19),  I => oDdr1Addr(19));
   U_Ddr1Addr20     : OBUF  port map ( O => ddr1Addr(20),  I => oDdr1Addr(20));
   U_Ddr1Addr21     : OBUF  port map ( O => ddr1Addr(21),  I => oDdr1Addr(21));
   
end KpixCon;

