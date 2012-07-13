-------------------------------------------------------------------------------
-- Title         : ADC Test FPGA, DAC Control
-------------------------------------------------------------------------------
-- File          : DacCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 08/12/2009
-------------------------------------------------------------------------------
-- Description:
-- 16-bit ADC Control
-------------------------------------------------------------------------------
-- Copyright (c) 2009 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 08/12/2009: created.
-------------------------------------------------------------------------------
use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity DacCntrl is 
   port ( 

      -- Input clocks & reset
      sysClk       : in     std_logic;
      sysRst       : in     std_logic;

      -- Write Data
      cmdWrEn      : in     std_logic;
      cmdWData     : in     std_logic_vector(15 downto 0);
      cmdWrAck     : out    std_logic;

      -- Interface to DAC
      calCsL       : out    std_logic;
      calClrL      : out    std_logic;
      calSClk      : out    std_logic;
      calSDin      : out    std_logic
   );

end DacCntrl;


-- Define architecture for core level module
architecture DacCntrlArch of DacCntrl is

   -- Local signals
   signal dacCnt     : std_logic_vector(4 downto 0);
   signal dacCs      : std_logic;
   signal intSData   : std_logic;
   signal intCs      : std_logic;
   signal calClkEn   : std_logic;
   signal cmdWrEnDly : std_logic;

begin

   -- Drive clear 
   calClrL <= not sysRst;

   -- Drive clock
   calSClk <= not sysClk when calClkEn = '1' else '0';

   -- Drive ack
   cmdWrAck <= '1' when cmdWrEn = '1' and dacCnt = 23 else '0';

   -- Calibration DAC load control counter
   process ( sysClk, sysRst ) begin

      if sysRst = '1' then
         dacCnt     <= (others => '0');
         dacCs      <= '0';
         calClkEn   <= '0';
         cmdWrEnDly <= '0';
      elsif rising_edge(sysClk) then

         -- Delayed version of write enable
         cmdWrEnDly <= cmdWrEn;

         -- Start the sequence following a write or debug set
         if cmdWrEn = '1' and cmdWrEnDly = '0' then
            dacCnt   <= (others => '0');
            calClkEn <= '1';

         -- Start chip select mid cycle
         elsif dacCnt = 3 then
            dacCs  <= '1';
            dacCnt <= dacCnt + 1;

         -- Keep chip select asserted until count hits max
         elsif dacCnt = 19 then
            dacCs  <= '0';
            dacCnt <= dacCnt + 1;

         elsif dacCnt = 23 then
            calClkEn <= '0';

         else
            dacCnt <= dacCnt + 1;
         end if;
      end if;
   end process;


   -- Calibration data MUX & IO Pads
   process ( sysClk, sysRst ) begin

      if sysRst = '1' then
         intSData <= '0';
         intCs    <= '0';
         calCsL   <= '0';
         calSDin  <= '0';
      elsif rising_edge(sysClk) then

         -- Drive IO pad signals
         calCsL   <= not intCs;
         calSDin  <= intSData;

         -- Delay chip select to line up with data
         intCs <= dacCs;

         -- Select data bit to output
         case dacCnt is
            when "00100" => intSData <= cmdWData(15);
            when "00101" => intSData <= cmdWData(14);
            when "00110" => intSData <= cmdWData(13);
            when "00111" => intSData <= cmdWData(12);
            when "01000" => intSData <= cmdWData(11);
            when "01001" => intSData <= cmdWData(10);
            when "01010" => intSData <= cmdWData(9);
            when "01011" => intSData <= cmdWData(8);
            when "01100" => intSData <= cmdWData(7);
            when "01101" => intSData <= cmdWData(6);
            when "01110" => intSData <= cmdWData(5);
            when "01111" => intSData <= cmdWData(4);
            when "10000" => intSData <= cmdWData(3);
            when "10001" => intSData <= cmdWData(2);
            when "10010" => intSData <= cmdWData(1);
            when "10011" => intSData <= cmdWData(0);
            when others  => intSData <= '0';
         end case;
      end if;
   end process;

end DacCntrlArch;

