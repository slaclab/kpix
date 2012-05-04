-------------------------------------------------------------------------------
-- Title         : KPIX Optical Interface FPGA Core Module
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/03/2012
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the optical interface FPGA on the KPIX Test Board.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/03/2012: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.Version.all;

entity KpixCore is 
   port ( 

      -- Clocks
      sysClk           : in  std_logic;
      sysClkRst        : in  std_logic;
      kpixClk          : in  std_logic;
      kpixClkRst       : in  std_logic;

      -- Commands
      cmdEn            : in  std_logic;
      cmdOpCode        : in  std_logic_vector(7  downto 0);

      -- Registers
      regReq           : in  std_logic;
      regOp            : in  std_logic;
      regInp           : in  std_logic;
      regAck           : out std_logic;
      regFail          : out std_logic;
      regAddr          : in  std_logic_vector(23 downto 0);
      regDataOut       : in  std_logic_vector(31 downto 0);
      regDataIn        : out std_logic_vector(31 downto 0);

      -- Data
      frameTxEnable    : out std_logic;
      frameTxSOF       : out std_logic;
      frameTxEOF       : out std_logic;
      frameTxAfull     : in  std_logic;
      frameTxData      : out std_logic_vector(31 downto 0);

      -- KPIX Interface
      kpixReset        : out std_logic;
      kpixCommand      : out std_logic_vector(15 downto 0);
      kpixData         : in  std_logic_vector(15 downto 0);
      kpixTrig         : out std_logic;

      -- Inputs
      nimInA           : in  std_logic;

      -- Outputs
      debugOutA        : out std_logic;
      debugOutB        : out std_logic;

      -- Kpix state
      kpixState        : out std_logic_vector(3 downto 0);

      -- Configuration
      clkSelIdle       : out std_logic_vector(4 downto 0);
      clkSelAcquire    : out std_logic_vector(4 downto 0);
      clkSelDigitize   : out std_logic_vector(4 downto 0);
      clkSelReadout    : out std_logic_vector(4 downto 0);
      clkSelPrecharge  : out std_logic_vector(4 downto 0)
   );
end KpixCore;


-- Define architecture for core module
architecture KpixCore of KpixCore is 

   -- Local KPIX
   component KpixLocal 
      port ( 
         kpixClk       : in    std_logic;                       -- 20Mhz system clock
         kpixClkRst    : in    std_logic;                       -- System reset
         debugOutA     : out   std_logic;                       -- BNC Interface A output
         debugOutB     : out   std_logic;                       -- BNC Interface B output
         debugASel     : in    std_logic_vector(4 downto 0);    -- BNC Output A Select
         debugBSel     : in    std_logic_vector(4 downto 0);    -- BNC Output B Select
         kpixReset     : in    std_logic;                       -- Kpix reset
         kpixCmd       : in    std_logic;                       -- Command data in
         kpixData      : out   std_logic;                       -- Response Data out
         coreState     : out   std_logic_vector(3 downto 0);    -- Core state value
         kpixBunch     : out   std_logic_vector(12 downto 0);   -- Bunch count value
         calStrobeOut  : out   std_logic
      );
   end component;

   -- Local signals
   signal iclkSelIdle       : std_logic_vector(4 downto 0);
   signal iclkSelAcquire    : std_logic_vector(4 downto 0);
   signal iclkSelDigitize   : std_logic_vector(4 downto 0);
   signal iclkSelReadout    : std_logic_vector(4 downto 0);
   signal iclkSelPrecharge  : std_logic_vector(4 downto 0);
   signal kpixRegReq        : std_logic;
   signal kpixRegAck        : std_logic;
   signal kpixRegFail       : std_logic;
   signal kpixRegSel        : std_logic_vector(7 downto 0);
   signal kpixRegDataIn     : std_logic_vector(31 downto 0);
   signal debugASel         : std_logic_vector(4 downto 0);
   signal debugBSel         : std_logic_vector(4 downto 0);
   signal extTrigEnable     : std_logic;
   signal kpixBunch         : std_logic_vector(12 downto 0);
   signal calStrobeOut      : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   ----------------------------------------
   -- Local Registers   
   ----------------------------------------
   clkSelIdle       <= iclkSelIdle;
   clkSelAcquire    <= iclkSelAcquire;
   clkSelDigitize   <= iclkSelDigitize;
   clkSelReadout    <= iclkSelReadout;
   clkSelPrecharge  <= iclkSelPrecharge;

   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         regAck            <= '0'           after tpd;
         regFail           <= '0'           after tpd;
         regDataIn         <= (others=>'0') after tpd;
         iclkSelReadout    <= (others=>'0') after tpd;
         iclkSelDigitize   <= (others=>'0') after tpd;
         iclkSelAcquire    <= (others=>'0') after tpd;
         iclkSelIdle       <= (others=>'0') after tpd;
         iclkSelPrecharge  <= (others=>'0') after tpd;
         kpixRegReq        <= '0'           after tpd;
         kpixRegSel        <= (others=>'0') after tpd;
         debugASel         <= (others=>'0') after tpd;
         debugBSel         <= (others=>'0') after tpd;
         extTrigEnable     <= '0'           after tpd;
      elsif rising_edge(sysClk) then

         -- Local Registers
         if regAddr(23 downto 20) = 0 then
            kpixRegReq  <= '0'           after tpd;
            kpixRegSel  <= (others=>'0') after tpd;

            -- Version
            if regAddr(19 downto 0) = 0 then
               regAck    <= regReq      after tpd;
               regFail   <= '0'         after tpd;
               regDataIn <= FpgaVersion after tpd;

            -- Clock Select Regsiter A
            elsif regAddr(19 downto 0) = 1 then
               regAck                  <= regReq          after tpd;
               regFail                 <= '0'             after tpd;
               regDataIn(31 downto 29) <= (others=>'0')   after tpd;
               regDataIn(28 downto 24) <= iclkSelReadout  after tpd;
               regDataIn(23 downto 21) <= (others=>'0')   after tpd;
               regDataIn(20 downto 16) <= iclkSelDigitize after tpd;
               regDataIn(15 downto 13) <= (others=>'0')   after tpd;
               regDataIn(12 downto  8) <= iclkSelAcquire  after tpd;
               regDataIn(7  downto  5) <= (others=>'0')   after tpd;
               regDataIn(4  downto  0) <= iclkSelIdle     after tpd;

               if regOp = '1' then
                  iclkSelReadout   <= regDataOut(28 downto 24) after tpd;
                  iclkSelDigitize  <= regDataOut(20 downto 16) after tpd;
                  iclkSelAcquire   <= regDataOut(12 downto  8) after tpd;
                  iclkSelIdle      <= regDataOut(4  downto  0) after tpd;
               end if;

            -- Clock Select Regsiter B
            elsif regAddr(19 downto 0) = 2 then
               regAck                  <= regReq           after tpd;
               regFail                 <= '0'              after tpd;
               regDataIn(31 downto  5) <= (others=>'0')    after tpd;
               regDataIn(4  downto  0) <= iclkSelPrecharge after tpd;

               if regOp = '1' then
                  iclkSelPrecharge <= regDataOut(4  downto  0) after tpd;
               end if;

            -- Debug select register
            elsif regAddr(19 downto 0) = 3 then
               regAck                  <= regReq           after tpd;
               regFail                 <= '0'              after tpd;
               regDataIn(31 downto  5) <= (others=>'0')    after tpd;
               regDataIn(12 downto  8) <= debugBSel        after tpd;
               regDataIn(7  downto  5) <= (others=>'0')    after tpd;
               regDataIn(4  downto  0) <= debugASel        after tpd;

               if regOp = '1' then
                  debugBSel <= regDataOut(12 downto  8) after tpd;
                  debugASel <= regDataOut(4  downto  0) after tpd;
               end if;

            -- Trigger control register
            elsif regAddr(19 downto 0) = 4 then
               regAck                  <= regReq           after tpd;
               regFail                 <= '0'              after tpd;
               regDataIn(31 downto  1) <= (others=>'0')    after tpd;
               regDataIn(0)            <= extTrigEnable    after tpd;

               if regOp = '1' then
                  extTrigEnable <= regDataOut(0) after tpd;
               end if;
            end if;

         -- KPIX Address space
         elsif regAddr(23 downto 20) = 1 then
            kpixRegReq  <= regReq               after tpd;
            kpixRegSel  <= regAddr(15 downto 8) after tpd;
            regAck      <= kpixRegAck           after tpd;
            regFail     <= kpixRegFail          after tpd;
            regDataIn   <= kpixRegDataIn        after tpd;

         else
            kpixRegReq  <= '0'           after tpd;
            kpixRegSel  <= (others=>'0') after tpd;
         end if;
      end if;
   end process;

   ----------------------------------------
   -- Local KPIX Device
   ----------------------------------------
   U_KpixLocal : KpixLocal port map ( 
      kpixClk       => kpixClk,
      kpixClkRst    => kpixClkRst,
      debugOutA     => debugOutA,
      debugOutB     => debugOutB,
      debugASel     => debugASel,
      debugBSel     => debugBSel,
      kpixReset     => '0',
      kpixCmd       => '0',
      kpixData      => open,
      coreState     => kpixState,
      kpixBunch     => kpixBunch,
      calStrobeOut  => calStrobeOut
   );









   frameTxEnable    <= '0';
   frameTxSOF       <= '0';
   frameTxEOF       <= '0';
   frameTxData      <= (others=>'0');
   kpixReset        <= '0';
   kpixCommand      <= (others=>'0');
   kpixTrig         <= '0';
   kpixState        <= (others=>'0');

   kpixRegAck       <= '0';
   kpixRegFail      <= '0';
   kpixRegDataIn    <= (others=>'0');

end KpixCore;

