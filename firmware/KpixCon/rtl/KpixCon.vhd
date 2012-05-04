-------------------------------------------------------------------------------
-- Title         : KPIX KpixCon FPGA Top Level Module
-- Project       : W_SI, KPIX KpixCon Board
-------------------------------------------------------------------------------
-- File          : KpixCon.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/03/2012
-------------------------------------------------------------------------------
-- Description:
-- Top level VHDL source file for the test FPGA on the KPIX KpixCon Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/04/2012: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use UNISIM.VCOMPONENTS.ALL;

entity KpixCon is 
   port ( 

      -- System clock, reset
      fpgaRstL      : in    std_logic;
      gtpRefClkP    : in    std_logic;
      gtpRefClkN    : in    std_logic;

      -- KPIX Interface
      kpixClkOut     : out   std_logic_vector(1 downto 0);
      kpixTrigOut    : out   std_logic_vector(1 downto 0);
      kpixReset      : out   std_logic;
      kpixCommand    : out   std_logic_vector(15 downto 0);
      kpixData       : in    std_logic_vector(15 downto 0);
      
      -- External signals
      nimInA         : in    std_logic;
      debugOutA      : out   std_logic;
      debugOutB      : out   std_logic;

      -- Ethernet Interface
      udpTxP         : out std_logic;
      udpTxN         : out std_logic;
      udpRxP         : in  std_logic;
      udpRxN         : in  std_logic
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

   -- KPIX Con Core Block
   component KpixCore
      port (
         sysClk           : in  std_logic;
         sysClkRst        : in  std_logic;
         kpixClk          : in  std_logic;
         kpixClkRst       : in  std_logic;
         cmdEn            : in  std_logic;
         cmdOpCode        : in  std_logic_vector(7  downto 0);
         regReq           : in  std_logic;
         regOp            : in  std_logic;
         regInp           : in  std_logic;
         regAck           : out std_logic;
         regFail          : out std_logic;
         regAddr          : in  std_logic_vector(23 downto 0);
         regDataOut       : in  std_logic_vector(31 downto 0);
         regDataIn        : out std_logic_vector(31 downto 0);
         frameTxEnable    : out std_logic;
         frameTxSOF       : out std_logic;
         frameTxEOF       : out std_logic;
         frameTxAfull     : in  std_logic;
         frameTxData      : out std_logic_vector(31 downto 0);
         kpixReset        : out std_logic;
         kpixCommand      : out std_logic_vector(15 downto 0);
         kpixData         : in  std_logic_vector(15 downto 0);
         kpixTrig         : out std_logic;
         nimInA           : in  std_logic;
         debugOutA        : out std_logic;
         debugOutB        : out std_logic;
         kpixState        : out std_logic_vector(3 downto 0);
         clkSelIdle       : out std_logic_vector(4 downto 0);
         clkSelAcquire    : out std_logic_vector(4 downto 0);
         clkSelDigitize   : out std_logic_vector(4 downto 0);
         clkSelReadout    : out std_logic_vector(4 downto 0);
         clkSelPrecharge  : out std_logic_vector(4 downto 0)
      );
   end component;

   -- Ethernet front end
   component EthFrontEnd
      port (
         gtpClk           : in  std_logic;
         gtpClkRst        : in  std_logic;
         gtpRefClk        : in  std_logic;
         gtpRefClkOut     : out std_logic;
         cmdEn            : out std_logic;
         cmdOpCode        : out std_logic_vector(7  downto 0);
         regReq           : out std_logic;
         regOp            : out std_logic;
         regInp           : out std_logic;
         regAck           : in  std_logic;
         regFail          : in  std_logic;
         regAddr          : out std_logic_vector(23 downto 0);
         regDataOut       : out std_logic_vector(31 downto 0);
         regDataIn        : in  std_logic_vector(31 downto 0);
         frameTxEnable    : in  std_logic;
         frameTxSOF       : in  std_logic;
         frameTxEOF       : in  std_logic;
         frameTxAfull     : out std_logic;
         frameTxData      : in  std_logic_vector(31 downto 0);
         gtpRxN           : in  std_logic;
         gtpRxP           : in  std_logic;
         gtpTxN           : out std_logic;
         gtpTxP           : out std_logic
      );
   end component;

   -- Local Signals
   signal sysRst           : std_logic;
   signal gtpRefClk        : std_logic;
   signal gtpRefClkOut     : std_logic;
   signal dcmClk125        : std_logic;
   signal dcmClk200        : std_logic;
   signal dcmLock          : std_logic;
   signal sync125RstIn     : std_logic_vector(2 downto 0);
   signal rst125Cnt        : std_logic_vector(3 downto 0);
   signal sysClk125        : std_logic;
   signal sysClk125Rst     : std_logic;
   signal sync200RstIn     : std_logic_vector(2 downto 0);
   signal rst200Cnt        : std_logic_vector(3 downto 0);
   signal cmdEn            : std_logic;
   signal cmdOpCode        : std_logic_vector(7  downto 0);
   signal regReq           : std_logic;
   signal regOp            : std_logic;
   signal regInp           : std_logic;
   signal regAck           : std_logic;
   signal regFail          : std_logic;
   signal regAddr          : std_logic_vector(23 downto 0);
   signal regDataOut       : std_logic_vector(31 downto 0);
   signal regDataIn        : std_logic_vector(31 downto 0);
   signal frameTxEnable    : std_logic;
   signal frameTxSOF       : std_logic;
   signal frameTxEOF       : std_logic;
   signal frameTxAfull     : std_logic;
   signal frameTxData      : std_logic_vector(31 downto 0);
   signal sysClk200        : std_logic;
   signal sysClk200Rst     : std_logic;
   signal clkSelIdle       : std_logic_vector(4 downto 0);
   signal clkSelAcquire    : std_logic_vector(4 downto 0);
   signal clkSelDigitize   : std_logic_vector(4 downto 0);
   signal clkSelReadout    : std_logic_vector(4 downto 0);
   signal clkSelPrecharge  : std_logic_vector(4 downto 0);
   signal kpixClk          : std_logic;
   signal kpixClkRst       : std_logic;
   signal kpixState        : std_logic_vector(3 downto 0);
   signal divCount         : std_logic_vector(9 downto 0);
   signal divClk           : std_logic;
   signal divClkRst        : std_logic;
   signal clkSel           : std_logic_vector(9 downto 0);
   signal kpixTrig         : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Reset
   sysRst <= (not fpgaRstL);

   -- Input Buffer
   U_ClkRefClk    : IBUFDS  port map ( I => gtpRefClkP,    IB => gtpRefClkN,  O => gtpRefClk );

   -- DCM
   U_RefDcm: DCM_ADV
      generic map (
         DFS_FREQUENCY_MODE    => "LOW",
         DLL_FREQUENCY_MODE    => "HIGH",
         CLKIN_DIVIDE_BY_2     => FALSE,
         CLK_FEEDBACK          => "1X",
         CLKOUT_PHASE_SHIFT    => "NONE",
         STARTUP_WAIT          => false,
         PHASE_SHIFT           => 0,
         CLKFX_MULTIPLY        => 8,
         CLKFX_DIVIDE          => 5,
         CLKDV_DIVIDE          => 2.0,
         CLKIN_PERIOD          => 8.0,
         DCM_PERFORMANCE_MODE  => "MAX_SPEED",
         FACTORY_JF            => X"F0F0",
         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS"
      )
      port map (
         CLKIN    => gtpRefClkOut,  CLKFB    => sysClk125,
         CLK0     => dcmClk125,     CLK90    => open,
         CLK180   => open,          CLK270   => open, 
         CLK2X    => open,          CLK2X180 => open,
         CLKDV    => open,          CLKFX    => dcmClk200,
         CLKFX180 => open,          LOCKED   => dcmLock,
         PSDONE   => open,          PSCLK    => '0',
         PSINCDEC => '0',           PSEN     => '0',
         DCLK     => '0',           DADDR    => (others=>'0'),
         DI       => (others=>'0'), DO       => open,
         DRDY     => open,          DWE      => '0',
         DEN      => '0',           RST      => sysRst
      );

   U_SysClk125Buff : BUFG port map ( I => dcmClk125,   O => sysClk125 );
   U_SysClk200Buff : BUFG port map ( I => dcmClk200,   O => sysClk200 );

   -- sysClk125 Reset generation
   process ( sysClk125, sysRst ) begin
      if sysRst = '1' then
         sync125RstIn <= (others=>'0') after tpd;
         rst125Cnt    <= (others=>'0') after tpd;
         sysClk125Rst <= '1'           after tpd;
      elsif rising_edge(sysClk125) then

         sync125RstIn(0) <= dcmLock         after tpd;
         sync125RstIn(1) <= sync125RstIn(0) after tpd;
         sync125RstIn(2) <= sync125RstIn(1) after tpd;

         if sync125RstIn(2) = '0' then
            rst125Cnt    <= (others=>'0') after tpd;
            sysClk125Rst <= '1'           after tpd;

         elsif rst125Cnt = "1111" then
            sysClk125Rst <= '0' after tpd;

         else
            sysClk125Rst <= '1'           after tpd;
            rst125Cnt    <= rst125Cnt + 1 after tpd;
         end if;
      end if;
   end process;

   -- sysClk200 Reset generation
   process ( sysClk200, sysRst ) begin
      if sysRst = '1' then
         sync200RstIn <= (others=>'0') after tpd;
         rst200Cnt    <= (others=>'0') after tpd;
         sysClk200Rst <= '1'           after tpd;
      elsif rising_edge(sysClk200) then

         sync200RstIn(0) <= dcmLock         after tpd;
         sync200RstIn(1) <= sync200RstIn(0) after tpd;
         sync200RstIn(2) <= sync200RstIn(1) after tpd;

         if sync200RstIn(2) = '0' then
            rst200Cnt    <= (others=>'0') after tpd;
            sysClk200Rst <= '1'           after tpd;

         elsif rst200Cnt = "1111" then
            sysClk200Rst <= '0' after tpd;

         else
            sysClk200Rst <= '1'           after tpd;
            rst200Cnt    <= rst200Cnt + 1 after tpd;
         end if;
      end if;
   end process;

   -- KPIX Clock Generation
   process ( sysClk200, sysClk200Rst ) begin
      if sysClk200Rst = '1' then
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
            if kpixState = "1010" then
               clkSel <= "00000" & clkSelPrecharge;

            -- Clock rate select
            else case kpixState(2 downto 0) is

               -- Idle
               when "000" => clkSel <= "00000" & clkSelIdle;

               -- Acquisition
               when "001" => clkSel <= "00000" & clkSelAcquire;

               -- Digitization
               when "010" => clkSel <= "00000" & clkSelDigitize;

               -- Readout
               when "100" => clkSel <= "00000" & clkSelReadout;

               -- Default
               when others => clkSel <= "00000" & clkSelIdle;
            end case;
            end if;
         else
            divCount <= divCount + 1;
         end if;
      end if;
   end process;

   U_KpixClkBuff : BUFG port map ( I => divClk,   O => kpixClk );

   -- Reset generation
   process ( kpixClk, sysClk200Rst ) begin
      if sysClk200Rst = '1' then
         divClkRst  <= '1' after tpd;
         kpixClkRst <= '1' after tpd;
      elsif rising_edge(kpixClk) then
         divClkRst  <= '0'       after tpd;
         kpixClkRst <= divClkRst after tpd;
      end if;
   end process;

   -- Ethernet front end
   U_EthFrontEnd : EthFrontEnd port map (
      gtpClk           => sysClk125,
      gtpClkRst        => sysClk125Rst,
      gtpRefClk        => gtpRefClk,
      gtpRefClkOut     => gtpRefClkOut,
      cmdEn            => cmdEn,
      cmdOpCode        => cmdOpCode,
      regReq           => regReq,
      regOp            => regOp,
      regInp           => regInp,
      regAck           => regAck,
      regFail          => regFail,
      regAddr          => regAddr,
      regDataOut       => regDataOut,
      regDataIn        => regDataIn,
      frameTxEnable    => frameTxEnable,
      frameTxSOF       => frameTxSOF,
      frameTxEOF       => frameTxEOF,
      frameTxAfull     => frameTxAfull,
      frameTxData      => frameTxData,
      gtpRxN           => udpRxN,
      gtpRxP           => udpRxP,
      gtpTxN           => udpTxN,
      gtpTxP           => udpTxP
   );

   -- KPIX Con Core Block
   U_KpixCore : KpixCore port map (
      sysClk           => sysClk125,
      sysClkRst        => sysClk125Rst,
      kpixClk          => kpixClk,
      kpixClkRst       => kpixClkRst,
      cmdEn            => cmdEn,
      cmdOpCode        => cmdOpCode,
      regReq           => regReq,
      regOp            => regOp,
      regInp           => regInp,
      regAck           => regAck,
      regFail          => regFail,
      regAddr          => regAddr,
      regDataOut       => regDataOut,
      regDataIn        => regDataIn,
      frameTxEnable    => frameTxEnable,
      frameTxSOF       => frameTxSOF,
      frameTxEOF       => frameTxEOF,
      frameTxAfull     => frameTxAfull,
      frameTxData      => frameTxData,
      kpixReset        => kpixReset,
      kpixCommand      => kpixCommand,
      kpixData         => kpixData,
      kpixTrig         => kpixTrig,
      nimInA           => nimInA,
      debugOutA        => debugOutA,
      debugOutB        => debugOutB,  
      kpixState        => kpixState,
      clkSelIdle       => clkSelIdle,
      clkSelAcquire    => clkSelAcquire,
      clkSelDigitize   => clkSelDigitize,
      clkSelReadout    => clkSelReadout,
      clkSelPrecharge  => clkSelPrecharge
   );
  
   -- Output KPIX clocks
   GenClk : for i in 1 downto 0 generate 
      U_KpixClkDDR : ODDR port map ( 
         Q  => kpixClkOut(i),
         CE => '1',
         C  => kpixClk,
         D1 => '1',      
         D2 => '0',      
         R  => '0',      
         S  => '0'
      );
   end generate;

   kpixTrigOut(0) <= kpixTrig;
   kpixTrigOut(1) <= kpixTrig;
 
end KpixCon;

